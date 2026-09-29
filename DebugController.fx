#include "ray.conf"
#include "ray_advanced.conf"
#include "shader/common.fxsub"
#include "shader/math.fxsub"
#include "shader/gbuffer.fxsub"
#include "shader/gbuffer_sampler.fxsub"

#if CONTACT_SHADOW_QUALITY >= 1 || SSGS_QUALITY >= 1
#include "shader/Shadows/ContactShadow.fxsub"
#endif

#if SUN_LIGHT_ENABLE && SUN_SHADOW_QUALITY
#include "shader/Shadows/ShadowCommon.fxsub"
#endif

float showAlbedo : CONTROLOBJECT<string name="(self)"; string item = "Albedo";>;
float showNormal : CONTROLOBJECT<string name="(self)"; string item = "Normal";>;
float showSpecular : CONTROLOBJECT<string name="(self)"; string item = "Specular";>;
float showSmoothness : CONTROLOBJECT<string name="(self)"; string item = "Smoothness";>;
float showVisibility : CONTROLOBJECT<string name="(self)"; string item = "Visibility";>;
float showCustomID : CONTROLOBJECT<string name="(self)"; string item = "CustomID";>;
float showCustomDataA : CONTROLOBJECT<string name="(self)"; string item = "CustomDataA";>;
float showCustomDataB : CONTROLOBJECT<string name="(self)"; string item = "CustomDataB";>;
float showDepth : CONTROLOBJECT<string name="(self)"; string item = "Depth";>;

float showAlpha : CONTROLOBJECT<string name="(self)"; string item = "Alpha";>;
float showAlbedoAlpha : CONTROLOBJECT<string name="(self)"; string item = "AlbedoAlpha";>;
float showNormalAlpha : CONTROLOBJECT<string name="(self)"; string item = "NormalAlpha";>;
float showSpecularAlpha : CONTROLOBJECT<string name="(self)"; string item = "SpecularAlpha";>;
float showSmoothnessAlpha : CONTROLOBJECT<string name="(self)"; string item = "SmoothnessAlpha";>;
float showVisibilityAlpha : CONTROLOBJECT<string name="(self)"; string item = "VisibilityAlpha";>;
float showCustomIDAlpha : CONTROLOBJECT<string name="(self)"; string item = "CustomIDAlpha";>;
float showCustomDataAlphaA : CONTROLOBJECT<string name="(self)"; string item = "CustomDataAlphaA";>;
float showCustomDataAlphaB : CONTROLOBJECT<string name="(self)"; string item = "CustomDataAlphaB";>;
float showDepthAlpha : CONTROLOBJECT<string name="(self)"; string item = "DepthAlpha";>;

float showSSAO : CONTROLOBJECT<string name="(self)"; string item = "SSAO";>;
float showSSDO : CONTROLOBJECT<string name="(self)"; string item = "SSDO";>;
float showSSR : CONTROLOBJECT<string name="(self)"; string item = "SSR";>;
float showContactShadow : CONTROLOBJECT<string name="(self)"; string item = "ContactShadow";>;
float showSSGS : CONTROLOBJECT<string name="(self)"; string item = "SSGS";>;
float showShadowMap : CONTROLOBJECT<string name="(self)"; string item = "ShadowMap";>;
float showPSSM : CONTROLOBJECT<string name="(self)"; string item = "PSSM";>;
float showCascades : CONTROLOBJECT<string name="(self)"; string item = "Cascades";>;
float showOutline : CONTROLOBJECT<string name="(self)"; string item = "Outline";>;
float showSSGI : CONTROLOBJECT<string name="(self)"; string item = "SSGI";>;
float showSSGIIntensity : CONTROLOBJECT<string name="(self)"; string item = "SSGIIntensity";>;
float showSSGIConeAngle : CONTROLOBJECT<string name="(self)"; string item = "SSGIConeAngle";>;
float showSSGIBias : CONTROLOBJECT<string name="(self)"; string item = "SSGIBias";>;

texture2D ScnMap : RENDERCOLORTARGET<
	float2 ViewPortRatio = {1.0,1.0};
	bool AntiAlias = false;
	string Format = "X8R8G8B8";
>;
sampler ScnSamp = sampler_state {
	texture = <ScnMap>;
	MinFilter = NONE; MagFilter = NONE; MipFilter = NONE;
	AddressU = CLAMP; AddressV = CLAMP;
};

#if SSDO_QUALITY > 0
shared texture SSDOMap : RENDERCOLORTARGET;
sampler SSDOMapSamp = sampler_state {
	texture = <SSDOMap>;
	MinFilter = NONE; MagFilter = NONE; MipFilter = NONE;
	AddressU = CLAMP; AddressV = CLAMP;
};
#endif

#if SSR_QUALITY > 0
shared texture SSRLightX1Map: RENDERCOLORTARGET;
sampler SSRayTracingSamp = sampler_state {
	texture = <SSRLightX1Map>;
	MinFilter = NONE; MagFilter = NONE; MipFilter = NONE;
	AddressU = CLAMP; AddressV = CLAMP;
};
#endif

#if GI_ENABLE
shared texture SSGIMap : RENDERCOLORTARGET;
sampler SSGIMapSamp = sampler_state {
	texture = <SSGIMap>;
	MinFilter = NONE; MagFilter = NONE; MipFilter = NONE;
	AddressU = CLAMP; AddressV = CLAMP;
};
#endif

#if OUTLINE_QUALITY
shared texture OutlineMap : OFFSCREENRENDERTARGET;
sampler OutlineMapSamp = sampler_state {
	texture = <OutlineMap>;
	MinFilter = LINEAR; MagFilter = LINEAR; MipFilter = NONE;
	AddressU = CLAMP; AddressV = CLAMP;
};
#endif

#if SUN_LIGHT_ENABLE && SUN_SHADOW_QUALITY
#if SUN_SHADOW_QUALITY == 1
#	define SHADOW_MAP_SIZE 1024
#elif SUN_SHADOW_QUALITY == 2
#	define SHADOW_MAP_SIZE 2048
#elif SUN_SHADOW_QUALITY == 3
#	define SHADOW_MAP_SIZE 4096
#elif SUN_SHADOW_QUALITY == 4
#	define SHADOW_MAP_SIZE 8192
#else
#	define SHADOW_MAP_SIZE 2048
#endif

shared texture PSSM1 : OFFSCREENRENDERTARGET;
sampler PSSM1Samp = sampler_state { texture = <PSSM1>; MinFilter = LINEAR; MagFilter = LINEAR; MipFilter = NONE; AddressU = CLAMP; AddressV = CLAMP; };

shared texture ShadowMap : RENDERCOLORTARGET;
sampler ShadowMapSamp = sampler_state { texture = <ShadowMap>; MinFilter = POINT; MagFilter = POINT; MipFilter = NONE; AddressU = CLAMP; AddressV = CLAMP; };

static float4x4 matLightProject = CreateOrthoProject(2.0f, 2.0f, mPSSMDepthZMin, mPSSMDepthZMax);
static float4x4 matLightView = CreateLightViewMatrix(SunDirection, -SunDirection, mLightDistance);
static float4x4 matLightViewProject = mul(matLightView, matLightProject);
static float4x4 matLightViewFromCameraView = mul(matViewInverse, matLightView);
static float4x4 matLightProjectFromCameraView = mul(matViewInverse, matLightViewProject);
static float4x4 lightCropParams = CreateLightCropParams(matLightViewFromCameraView, SHADOW_MAP_SIZE);
#endif

void DebugControllerVS(
	in float4 Position : POSITION,
	in float4 Texcoord : TEXCOORD0,
	out float4 oTexcoord : TEXCOORD0,
	out float3 oViewdir : TEXCOORD1,
	out float4 oPosition : POSITION)
{
	oTexcoord = Texcoord.xyxy + ViewportOffset.xyxy;
	oViewdir = mul(Position, matProjectInverse).xyz;
	oPosition = Position;
}

float4 DebugControllerPS(in float2 coord : TEXCOORD0, in float3 viewdir : TEXCOORD1) : COLOR
{
	float4 MRT1 = tex2Dlod(Gbuffer1Map, float4(coord, 0, 0));
	float4 MRT2 = tex2Dlod(Gbuffer2Map, float4(coord, 0, 0));
	float4 MRT3 = tex2Dlod(Gbuffer3Map, float4(coord, 0, 0));
	float4 MRT4 = tex2Dlod(Gbuffer4Map, float4(coord, 0, 0));

	MaterialParam material;
	DecodeGbuffer(MRT1, MRT2, MRT3, MRT4, material);

	float4 MRT5 = tex2Dlod(Gbuffer5Map, float4(coord, 0, 0));
	float4 MRT6 = tex2Dlod(Gbuffer6Map, float4(coord, 0, 0));
	float4 MRT7 = tex2Dlod(Gbuffer7Map, float4(coord, 0, 0));
	float4 MRT8 = tex2Dlod(Gbuffer8Map, float4(coord, 0, 0));

	MaterialParam materialAlpha;
	DecodeGbuffer(MRT5, MRT6, MRT7, MRT8, materialAlpha);

	float showTotal = showAlbedo + showNormal + showSpecular + showSmoothness + showVisibility + showCustomID + showCustomDataB + showCustomDataA;
	showTotal += showAlpha + showAlbedoAlpha + showSpecularAlpha + showNormalAlpha + showSmoothnessAlpha + showVisibilityAlpha + showCustomIDAlpha + showCustomDataAlphaB + showCustomDataAlphaA;
	showTotal += showDepth + showDepthAlpha + showSSAO + showSSDO + showSSR + showOutline + showSSGI + showContactShadow + showSSGS + showShadowMap + showPSSM + showCascades;

	float3 result = srgb2linear_fast(tex2Dlod(ScnSamp, float4(coord, 0, 0)).rgb) * !any(showTotal);
	result += material.albedo * showAlbedo;
	result += (mul(material.normal, (float3x3)matViewInverse).xyz * 0.5 + 0.5) * showNormal;
	result += material.specular * showSpecular;
	result += material.smoothness * showSmoothness;
	result += material.customDataA * showCustomDataA;
	result += material.customDataB * showCustomDataB;
	result += material.visibility * showVisibility;

	result += materialAlpha.albedo * showAlbedoAlpha;
	result += (mul(materialAlpha.normal, (float3x3)matViewInverse).xyz * 0.5 + 0.5) * showNormalAlpha;
	result += materialAlpha.specular * showSpecularAlpha;
	result += materialAlpha.smoothness * showSmoothnessAlpha;
	result += materialAlpha.customDataA * showCustomDataAlphaA;
	result += materialAlpha.customDataB * showCustomDataAlphaB;
	result += materialAlpha.visibility * showVisibilityAlpha;

	#if OUTLINE_QUALITY
		#if OUTLINE_QUALITY == 3
			float2 offset = 1.0 / (ViewportSize * 2.0);
			coord -= ViewportOffset;
			float4 edge1 = tex2Dlod(OutlineMapSamp, float4(coord, 0, 0));
			float4 edge2 = tex2Dlod(OutlineMapSamp, float4(coord + float2(offset.x, 0), 0, 0));
			float4 edge3 = tex2Dlod(OutlineMapSamp, float4(coord + float2(0, offset.y), 0, 0));
			float4 edge4 = tex2Dlod(OutlineMapSamp, float4(coord + offset, 0, 0));
			float4 edge = (edge1 + edge2 + edge3 + edge4) * 0.25;
		#else
			float4 edge = tex2Dlod(OutlineMapSamp, float4(coord, 0, 0));
		#endif
		result += lerp(float3(1, 1, 1), edge.rgb, edge.a)  * showOutline;
	#endif

	result = linear2srgb(result);

	result += materialAlpha.alpha * showAlpha;
	result += pow(saturate(material.linearDepth / 200), 0.5) * showDepth;
	result += pow(saturate(materialAlpha.linearDepth / 200), 0.5) * showDepthAlpha;

	#if SSDO_QUALITY > 0
		float4 ssao = tex2Dlod(SSDOMapSamp, float4(coord, 0, 0));
		result += ssao.w * showSSAO;
		result += ssao.xyz * showSSDO;
	#endif

	#if SSR_QUALITY > 0
		result += tex2Dlod(SSRayTracingSamp, float4(coord, 0, 0)).rgb * showSSR;
	#endif

	#if GI_ENABLE
		float3 giDebug = tex2Dlod(SSGIMapSamp, float4(coord, 0, 0)).rgb;
		giDebug *= lerp(1.2, 5.0, showSSGIIntensity);
		result += giDebug * showSSGI;
	#endif

	float4 projConstant = GetProjConstant();
	float3 viewPosition = GetViewPosition(projConstant, coord, material.linearDepth);
	float3 L = mul(-SunDirection, (float3x3)matView);

	#if CONTACT_SHADOW_QUALITY >= 1
		result += (1.0f - GetContactShadow(viewPosition, material.normal, L, coord, material.linearDepth)) * showContactShadow;
	#endif

	#if SSGS_QUALITY >= 1
		result += (1.0f - GetGlobalShadow(viewPosition, material.normal, L, coord)) * showSSGS;
	#endif

	#if SUN_LIGHT_ENABLE && SUN_SHADOW_QUALITY
		// Direct shadow map texture (0 = shadow, 1 = lit)
		float shadowMapVal = tex2Dlod(ShadowMapSamp, float4(coord, 0, 0)).r;
		result += shadowMapVal.xxx * showShadowMap;

		// PSSM Cascaded Shadow Map (Cascade 0 - High Resolution Primary Cascade)
		float pssmDepth = tex2Dlod(PSSM1Samp, float4(coord, 0, 0)).r;
		float pssmVisual = pow(saturate(pssmDepth), 0.5f);
		result += pssmVisual.xxx * showPSSM;

		// Cascade Split Color Overlay
		float4 proj = mul(float4(viewPosition, 1.0f), matLightProjectFromCameraView);
		float4 lightPPos01 = proj.xyxy * float4(lightCropParams[0].xy, lightCropParams[1].xy) + float4(lightCropParams[0].zw, lightCropParams[1].zw);
		float4 lightPPos23 = proj.xyxy * float4(lightCropParams[2].xy, lightCropParams[3].xy) + float4(lightCropParams[2].zw, lightCropParams[3].zw);

		float4 lightPPos0 = float4(PosToCoord(lightPPos01.xy), min2(float2(1.0f, 1.0f) - abs(lightPPos01.xy)), 0.0f);
		float4 lightPPos1 = float4(PosToCoord(lightPPos01.zw), min2(float2(1.0f, 1.0f) - abs(lightPPos01.zw)), 1.0f);
		float4 lightPPos2 = float4(PosToCoord(lightPPos23.xy), min2(float2(1.0f, 1.0f) - abs(lightPPos23.xy)), 2.0f);
		float4 lightPPos3 = float4(PosToCoord(lightPPos23.zw), min2(float2(1.0f, 1.0f) - abs(lightPPos23.zw)), 3.0f);

		float3 cascadeColor = float3(0.2, 0.2, 0.2);
		if (lightPPos0.z > 0.0f) cascadeColor = float3(1.0, 0.15, 0.15);      // Cascade 0: Red
		else if (lightPPos1.z > 0.0f) cascadeColor = float3(0.15, 1.0, 0.15); // Cascade 1: Green
		else if (lightPPos2.z > 0.0f) cascadeColor = float3(0.2, 0.4, 1.0);   // Cascade 2: Blue
		else if (lightPPos3.z > 0.0f) cascadeColor = float3(1.0, 1.0, 0.15);  // Cascade 3: Yellow

		result += cascadeColor * showCascades;
	#endif

	if (material.lightModel == SHADINGMODELID_SKIN)
		result += float3(1,0,0) * showCustomID;
	if (material.lightModel == SHADINGMODELID_SUBSURFACE)
		result += float3(0,1,0) * showCustomID;
	if (material.lightModel == SHADINGMODELID_CLOTH)
		result += float3(0,0,1) * showCustomID;
	if (material.lightModel == SHADINGMODELID_EMISSIVE)
		result += float3(1,1,1) * showCustomID;
	if (material.lightModel == SHADINGMODELID_CLEAR_COAT)
		result += float3(1,0,1) * showCustomID;
	if (material.lightModel == SHADINGMODELID_GLASS)
		result += float3(0.2,0.3,0.5) * showCustomID;
	if (material.lightModel == SHADINGMODELID_ANISOTROPY)
		result += float3(1.0,0.5,1.0) * showCustomID;
	if (material.lightModel == SHADINGMODELID_CEL)
		result += float3(0.0,0.5,1.0) * showCustomID;
	if (material.lightModel == SHADINGMODELID_TONEBASED)
		result += float3(0.5,0.5,1.0) * showCustomID;

	if (materialAlpha.lightModel == SHADINGMODELID_SKIN)
		result += float3(1,0,0) * showCustomIDAlpha;
	if (materialAlpha.lightModel == SHADINGMODELID_SUBSURFACE)
		result += float3(0,1,0) * showCustomIDAlpha;
	if (materialAlpha.lightModel == SHADINGMODELID_CLOTH)
		result += float3(0,0,1) * showCustomIDAlpha;
	if (materialAlpha.lightModel == SHADINGMODELID_EMISSIVE)
		result += float3(1,1,1) * showCustomIDAlpha;
	if (materialAlpha.lightModel == SHADINGMODELID_CLEAR_COAT)
		result += float3(1,0,1) * showCustomIDAlpha;
	if (materialAlpha.lightModel == SHADINGMODELID_GLASS)
		result += float3(0.2,0.3,0.5) * showCustomIDAlpha;
	if (materialAlpha.lightModel == SHADINGMODELID_ANISOTROPY)
		result += float3(1.0,0.5,1.0) * showCustomIDAlpha;
	if (material.lightModel == SHADINGMODELID_CEL)
		result += float3(0.0,0.5,1.0) * showCustomIDAlpha;
	if (material.lightModel == SHADINGMODELID_TONEBASED)
		result += float3(0.5,0.5,1.0) * showCustomIDAlpha;

	return float4(result, 1);
}

float Script : STANDARDSGLOBAL<
	string ScriptOutput = "color";
	string ScriptClass = "scene";
	string ScriptOrder = "postprocess";
> = 0.8;

technique DebugController <
	string Script = 
	"RenderColorTarget=ScnMap;"
	"RenderDepthStencilTarget=;"
	"ScriptExternal=Color;"

	"RenderColorTarget=;"
	"RenderDepthStencilTarget=;"
	"Pass=DebugController;"
;> {
	pass DebugController<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = False; ZWriteEnable = False;
		VertexShader = compile vs_3_0 DebugControllerVS();
		PixelShader = compile ps_3_0 DebugControllerPS();
	}
}