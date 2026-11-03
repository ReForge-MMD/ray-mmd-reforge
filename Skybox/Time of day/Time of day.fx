#define ATM_SAMPLES_NUMS 16
#define ATM_CLOUD_ENABLE 1
#define ATM_LIMADARKENING_ENABLE 1

#include "Time of day.conf"

#include "../../shader/Core/math.fxsub"
#include "../../shader/Core/common.fxsub"
#include "../../shader/Lighting/PhaseFunctions.fxsub"

#include "shader/common.fxsub"
#include "shader/atmospheric.fxsub"
#include "shader/cloud.fxsub"

// 1x1 sun transmittance through the cloud layer, consumed by volumetric fog.
shared texture SunOcclusionMap : RENDERCOLORTARGET<
	int2 Dimensions = { 1, 1 };
	string Format = "A16B16G16R16F";
	float4 ClearColor = { 1.0f, 1.0f, 1.0f, 1.0f };
>;

void ScatteringVS(
	in float4 Position   : POSITION,
	out float3 oTexcoord0 : TEXCOORD0,
	out float3 oTexcoord1 : TEXCOORD1,
	out float3 oTexcoord2 : TEXCOORD2,
	out float3 oTexcoord3 : TEXCOORD3,
	out float4 oPosition : POSITION)
{
	oTexcoord0 = normalize(Position.xyz);
	oTexcoord1 = ComputeWaveLengthMie(mWaveLength, mMieColor, mSunTurbidity);
	oTexcoord2 = ComputeWaveLengthRayleigh(mWaveLength) * mRayleighColor;
	oTexcoord3 = ComputeWaveLengthMie(mWaveLength, mCloudColor, mCloudTurbidity);
	oPosition = mul(Position + float4(CameraPosition, 0), matViewProject);
}

float4 ScatteringPS(
	in float3 viewdir : TEXCOORD0,
	in float3 mieLambda : TEXCOORD1,
	in float3 rayleight : TEXCOORD2) : COLOR
{
	float3 V = normalize(viewdir);

	ScatteringParams setting;
	setting.sunRadius = mSunRadius;
	setting.sunRadiance = mSunRadiance;
	setting.mieG = mSunPhase;
	setting.mieHeight = mMieHeight * mUnitDistance;
	setting.rayleighHeight = mRayleighHeight * mUnitDistance;
	setting.earthRadius = mEarthRadius * mUnitDistance;
	setting.earthAtmTopRadius = mEarthAtmoRadius * mUnitDistance;
	setting.earthCenter = float3(0, -setting.earthRadius, 0);
	setting.waveLambdaMie = mieLambda;
	setting.waveLambdaOzone = mOzoneScatteringCoeff * mOzoneMass;
	setting.waveLambdaRayleigh = rayleight;

	float4 insctrColor = ComputeSkyInscattering(setting, CameraPosition + float3(0, mEarthPeopleHeight * mUnitDistance, 0), V, SunDirection);

	return linear2srgb(insctrColor);
}

float4 ScatteringWithCloudsPS(
	in float3 viewdir : TEXCOORD0,
	in float3 mieLambda : TEXCOORD1,
	in float3 rayleight : TEXCOORD2,
	in float3 cloud : TEXCOORD3) : COLOR
{
	float3 V = normalize(viewdir);

	ScatteringParams setting;
	setting.sunRadius = mSunRadius;
	setting.sunRadiance = mSunRadiance;
	setting.mieG = mSunPhase;
	setting.mieHeight = mMieHeight * mUnitDistance;
	setting.rayleighHeight = mRayleighHeight * mUnitDistance;
	setting.earthRadius = mEarthRadius * mUnitDistance;
	setting.earthAtmTopRadius = mEarthAtmoRadius * mUnitDistance;
	setting.earthCenter = float3(0, -setting.earthRadius, 0);
	setting.waveLambdaMie = mieLambda;
	setting.waveLambdaOzone = mOzoneScatteringCoeff * mOzoneMass;
	setting.waveLambdaRayleigh = rayleight;
	setting.cloud = mCloudDensity;
	setting.cloudTop = 9.6 * mUnitDistance;
	setting.cloudBottom = 8.0 * mUnitDistance;
	setting.clouddir = float3(1315.7, 0, -3000) * mCloudSpeed;
	setting.cloudLambda = cloud;

	float4 insctrColor = ComputeCloudsInscattering(setting, CameraPosition + float3(0, mEarthPeopleHeight * mUnitDistance, 0), V, SunDirection);
	return linear2srgb(insctrColor);
}

void CloudOcclusionVS(
	in float4 Position : POSITION,
	out float4 oPosition : POSITION)
{
	oPosition = Position;
}

float4 CloudOcclusionPS() : COLOR0
{
	ScatteringParams setting;
	setting.cloud = mCloudDensity;
	setting.cloudTop = 9.6 * mUnitDistance;
	setting.cloudBottom = 8.0 * mUnitDistance;
	setting.clouddir = float3(1315.7, 0, -3000) * mCloudSpeed;
	setting.earthRadius = mEarthRadius * mUnitDistance;
	setting.earthCenter = float3(0, -setting.earthRadius, 0);

	float3 eye = CameraPosition + float3(0, mEarthPeopleHeight * mUnitDistance, 0);
	float transmittance = HitCloudsTest(setting, eye, -SunDirection, -SunDirection);
	return float4(transmittance, transmittance, transmittance, 1.0f);
}

const float4 BackColor = 0.0;

#define CLOUD_OCCLUSION_PASS \
	pass CloudOcclusion < string Script = "Draw=Buffer;"; > { \
		AlphaTestEnable = FALSE; AlphaBlendEnable = FALSE; \
		ZEnable = FALSE; ZWriteEnable = FALSE; CullMode = NONE; \
		VertexShader = compile vs_3_0 CloudOcclusionVS(); \
		PixelShader  = compile ps_3_0 CloudOcclusionPS(); \
	}

#define CLOUD_OCCLUSION_SCRIPT \
	"RenderColorTarget0=SunOcclusionMap; Clear=Color; Pass=CloudOcclusion;" \
	"RenderColorTarget0=;"

technique MainTech<string MMDPass = "object";
	string Script = CLOUD_OCCLUSION_SCRIPT "Pass=DrawScattering;";
>{
	CLOUD_OCCLUSION_PASS
	pass DrawScattering {
		AlphaTestEnable = FALSE; AlphaBlendEnable = FALSE;\
		VertexShader = compile vs_3_0 ScatteringVS();
		PixelShader  = compile ps_3_0 ScatteringWithCloudsPS();
	}
}
technique MainTechSS<string MMDPass = "object_ss";
	string Script = CLOUD_OCCLUSION_SCRIPT "Pass=DrawScattering;";
>{
	CLOUD_OCCLUSION_PASS
	pass DrawScattering {
		AlphaTestEnable = FALSE; AlphaBlendEnable = FALSE;\
		VertexShader = compile vs_3_0 ScatteringVS();
		PixelShader  = compile ps_3_0 ScatteringWithCloudsPS();
	}
}

technique EdgeTec<string MMDPass = "edge";>{}
technique ShadowTec<string MMDPass = "shadow";>{}
technique ZplotTec<string MMDPass = "zplot";>{}