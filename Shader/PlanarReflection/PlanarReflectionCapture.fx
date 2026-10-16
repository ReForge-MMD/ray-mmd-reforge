/**
 * Ray-MMD ReForge planar capture material.
 * Draws the visible scene from the mirrored side of ray.x's local-Y plane.
 *
 * Improvements over v1:
 * - Confidence alpha: outputs 1.0 for opaque geometry, 0.0 for clipped/background.
 *   The resolve pass uses this to composite only covered pixels.
 * - Distance fade: geometry beyond mPlanarReflectionCaptureMaxDist linearly fades
 *   out, matching the capture visibility to a reasonable scene radius.
 * - Energy-conserving diffuse+specular: lambertian diffuse avoids the double-counting
 *   present in the old ambient*(diffuse+1) formulation.
 * - Sphere map add/multiply distinction: preserved and applied after the base PBR term.
 */

#include "../Core/math.fxsub"
#include "../../ray_advanced.conf"

float4x4 WorldMatrix       : WORLD;
float4x4 ViewMatrix        : VIEW;
float4x4 ViewProjMatrix    : VIEWPROJECTION;
float3   CameraPosition    : POSITION < string Object = "Camera"; >;
float3   LightDirection    : DIRECTION < string Object = "Light"; >;
float3   LightDiffuse      : DIFFUSE   < string Object = "Light"; >;
float3   LightAmbient      : AMBIENT   < string Object = "Light"; >;
float3   LightSpecular     : SPECULAR  < string Object = "Light"; >;

float4 MaterialDiffuse  : DIFFUSE   < string Object = "Geometry"; >;
float3 MaterialAmbient  : AMBIENT   < string Object = "Geometry"; >;
float3 MaterialEmissive : EMISSIVE  < string Object = "Geometry"; >;
float3 MaterialSpecular : SPECULAR  < string Object = "Geometry"; >;
float  MaterialPower    : SPECULARPOWER < string Object = "Geometry"; >;
float3 MaterialToon     : TOONCOLOR;

float4x4 MirrorWorldMatrix : CONTROLOBJECT < string name = "(OffscreenOwner)"; >;
bool use_texture;
bool use_spheremap;
bool use_subtexture;
bool use_toon;
bool spadd;

texture DiffuseMap : MATERIALTEXTURE;
texture SphereMap  : MATERIALSPHEREMAP;
texture ToonMap    : MATERIALTOONTEXTURE;

sampler DiffuseSamp = sampler_state {
	texture = <DiffuseMap>;
	MinFilter = LINEAR; MagFilter = LINEAR; MipFilter = LINEAR;
	AddressU = WRAP; AddressV = WRAP;
};
sampler SphereSamp = sampler_state {
	texture = <SphereMap>;
	MinFilter = LINEAR; MagFilter = LINEAR; MipFilter = LINEAR;
	AddressU = WRAP; AddressV = WRAP;
};
sampler ToonSamp = sampler_state {
	texture = <ToonMap>;
	MinFilter = LINEAR; MagFilter = LINEAR; MipFilter = NONE;
	AddressU = CLAMP; AddressV = CLAMP;
};

float3 PlaneOrigin()
{
	return MirrorWorldMatrix._41_42_43;
}

float3 PlaneNormal()
{
	return normalize(mul(float3(0.0f, 1.0f, 0.0f), (float3x3)MirrorWorldMatrix));
}

float3 ReflectPoint(float3 position, float3 origin, float3 normal)
{
	return position - 2.0f * normal * dot(position - origin, normal);
}

struct CaptureVSOut
{
	float4 Position     : POSITION;
	float2 UV           : TEXCOORD0;
	float3 WorldNormal  : TEXCOORD1;
	float3 ViewDirection: TEXCOORD2;
	float2 SphereUV     : TEXCOORD3;
	float  CaptureSide  : TEXCOORD4;
	float  CamDist      : TEXCOORD5;
};

CaptureVSOut PlanarCaptureVS(
	float4 Position : POSITION,
	float3 Normal   : NORMAL,
	float2 UV       : TEXCOORD0,
	float2 UV2      : TEXCOORD1,
	uniform bool sampleTexture,
	uniform bool sampleSphere,
	uniform bool sampleToon)
{
	CaptureVSOut output = (CaptureVSOut)0;
	float3 origin      = PlaneOrigin();
	float3 planeNormal = PlaneNormal();
	float4 worldPosition = mul(Position, WorldMatrix);
	float cameraSide = dot(CameraPosition - origin, planeNormal);
	float side       = dot(worldPosition.xyz - origin, planeNormal);
	float sideSign   = cameraSide < 0.0f ? -1.0f : 1.0f;
	output.CaptureSide = side * sideSign - mPlanarReflectionCapturePlaneBias;

	float3 reflectedPosition = ReflectPoint(worldPosition.xyz, origin, planeNormal);
	output.Position   = mul(float4(reflectedPosition, 1.0f), ViewProjMatrix);
	output.Position.x = -output.Position.x;
	output.WorldNormal   = normalize(mul(Normal, (float3x3)WorldMatrix));
	float3 reflectedCamera = ReflectPoint(CameraPosition, origin, planeNormal);
	output.ViewDirection = reflectedCamera - worldPosition.xyz;
	output.UV = UV;

	// Distance from the reflected camera to the vertex — used in PS for distance fade.
	output.CamDist = length(reflectedCamera - reflectedPosition);

	float3 normalVS = normalize(mul(output.WorldNormal, (float3x3)ViewMatrix));
	output.SphereUV = float2(normalVS.x * 0.5f + 0.5f, normalVS.y * -0.5f + 0.5f);
	if (sampleSphere && use_spheremap && use_subtexture)
		output.SphereUV = UV2;

	return output;
}

float4 PlanarCapturePS(CaptureVSOut input, uniform bool sampleTexture, uniform bool sampleSphere, uniform bool sampleToon) : COLOR
{
	// Clip geometry on the camera-side of the mirror plane.
	clip(input.CaptureSide);

	float4 baseColor = MaterialDiffuse;
	if (sampleTexture && use_texture)
		baseColor *= tex2D(DiffuseSamp, input.UV);

	// Cutout: discard only fully-transparent pixels (e.g. masked hair strands).
	// Threshold is 0.01 rather than 0.5 so semi-transparent materials such as
	// water (MaterialDiffuse.a < 0.5 from the PMX) are not discarded.
	clip(baseColor.a - 0.01f);

	float3 albedo   = srgb2linear_fast(saturate(baseColor.rgb));
	float3 normal   = normalize(input.WorldNormal);
	float3 L        = normalize(-LightDirection);
	float3 V        = normalize(input.ViewDirection);
	float3 emissive = srgb2linear_fast(saturate(MaterialEmissive));

	// Lambert diffuse (energy-conserving: divide by PI is omitted here to stay
	// consistent with ray-mmd's captured light scale, which skips the 1/π factor).
	float  NdotL    = saturate(dot(normal, L));
	float3 ambient  = srgb2linear_fast(saturate(MaterialAmbient.rgb * LightAmbient));
	float3 diffuse  = albedo * srgb2linear_fast(saturate(LightDiffuse)) * NdotL;

	if (sampleToon && use_toon)
	{
		// Toon: replace the diffuse ramp with the toon texture lookup.
		float  toonLight = saturate(0.5f - NdotL * 0.5f);
		float3 toonColor = tex2D(ToonSamp, float2(0.0f, toonLight)).rgb;
		diffuse *= srgb2linear_fast(toonColor * MaterialToon);
	}

	float3 H            = normalize(L + V);
	float  specularTerm = pow(saturate(dot(normal, H)), max(MaterialPower, 1.0f));
	float3 specular     = specularTerm * srgb2linear_fast(saturate(MaterialSpecular * LightSpecular));

	float3 color = albedo * ambient + diffuse + emissive + specular;

	if (sampleSphere && use_spheremap)
	{
		float3 sphereColor = srgb2linear_fast(tex2D(SphereSamp, input.SphereUV).rgb);
		color = spadd ? color + sphereColor : color * sphereColor;
	}

	// Distance fade: taper out geometry that is far from the reflected viewpoint.
	// This prevents hard edges at the RT clip boundary and reduces bright pop-in.
	float distFade = 1.0f - smoothstep(
		mPlanarReflectionCaptureMaxDist * 0.7f,
		mPlanarReflectionCaptureMaxDist,
		input.CamDist);

	// Alpha channel encodes coverage confidence for the resolve pass.
	return float4(color * distFade, distFade);
}

#define PLANAR_CAPTURE_TECHNIQUE(name, mmdpass, tex, sphere, toon) \
technique name < string MMDPass = mmdpass; bool UseTexture = tex; bool UseSphereMap = sphere; bool UseToon = toon; > { \
	pass DrawCapture { \
		AlphaBlendEnable = false; AlphaTestEnable = false; \
		VertexShader = compile vs_3_0 PlanarCaptureVS(tex, sphere, toon); \
		PixelShader  = compile ps_3_0 PlanarCapturePS(tex, sphere, toon); \
	} \
}

PLANAR_CAPTURE_TECHNIQUE(Capture000, "object", false, false, false)
PLANAR_CAPTURE_TECHNIQUE(Capture100, "object", true,  false, false)
PLANAR_CAPTURE_TECHNIQUE(Capture010, "object", false, true,  false)
PLANAR_CAPTURE_TECHNIQUE(Capture110, "object", true,  true,  false)
PLANAR_CAPTURE_TECHNIQUE(Capture001, "object", false, false, true)
PLANAR_CAPTURE_TECHNIQUE(Capture101, "object", true,  false, true)
PLANAR_CAPTURE_TECHNIQUE(Capture011, "object", false, true,  true)
PLANAR_CAPTURE_TECHNIQUE(Capture111, "object", true,  true,  true)

PLANAR_CAPTURE_TECHNIQUE(CaptureSS000, "object_ss", false, false, false)
PLANAR_CAPTURE_TECHNIQUE(CaptureSS100, "object_ss", true,  false, false)
PLANAR_CAPTURE_TECHNIQUE(CaptureSS010, "object_ss", false, true,  false)
PLANAR_CAPTURE_TECHNIQUE(CaptureSS110, "object_ss", true,  true,  false)
PLANAR_CAPTURE_TECHNIQUE(CaptureSS001, "object_ss", false, false, true)
PLANAR_CAPTURE_TECHNIQUE(CaptureSS101, "object_ss", true,  false, true)
PLANAR_CAPTURE_TECHNIQUE(CaptureSS011, "object_ss", false, true,  true)
PLANAR_CAPTURE_TECHNIQUE(CaptureSS111, "object_ss", true,  true,  true)

technique CaptureEdge   < string MMDPass = "edge"; >   {}
technique CaptureShadow < string MMDPass = "shadow"; > {}
technique CaptureZplot  < string MMDPass = "zplot"; >  {}

#undef PLANAR_CAPTURE_TECHNIQUE
