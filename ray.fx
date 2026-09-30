#include "ray.conf"
#include "ray_advanced.conf"

const float4 BackColor = 0.0;
const float4 WhiteColor = 1.0;
const float ClearDepth = 1.0;
const int ClearStencil = 0;

// =============================================================================
// LightingController.pmx (Dedicated Lighting & Shadow Controller)
// =============================================================================
float mLightSunLightP1   : CONTROLOBJECT<string name="LightingController.pmx"; string item = "SunLight+";>;
float mLightSunLightM1   : CONTROLOBJECT<string name="LightingController.pmx"; string item = "SunLight-";>;
float mLightSunLightP2   : CONTROLOBJECT<string name="LightingController"; string item = "SunLight+";>;
float mLightSunLightM2   : CONTROLOBJECT<string name="LightingController"; string item = "SunLight-";>;

float mLightSSAOP1       : CONTROLOBJECT<string name="LightingController.pmx"; string item = "SSAO+";>;
float mLightSSAOM1       : CONTROLOBJECT<string name="LightingController.pmx"; string item = "SSAO-";>;
float mLightSSAOP2       : CONTROLOBJECT<string name="LightingController"; string item = "SSAO+";>;
float mLightSSAOM2       : CONTROLOBJECT<string name="LightingController"; string item = "SSAO-";>;

float mLightSSAORadiusP1 : CONTROLOBJECT<string name="LightingController.pmx"; string item = "SSAORadius+";>;
float mLightSSAORadiusM1 : CONTROLOBJECT<string name="LightingController.pmx"; string item = "SSAORadius-";>;
float mLightSSAORadiusP2 : CONTROLOBJECT<string name="LightingController"; string item = "SSAORadius+";>;
float mLightSSAORadiusM2 : CONTROLOBJECT<string name="LightingController"; string item = "SSAORadius-";>;

float mLightSSDOP1       : CONTROLOBJECT<string name="LightingController.pmx"; string item = "SSDO+";>;
float mLightSSDOM1       : CONTROLOBJECT<string name="LightingController.pmx"; string item = "SSDO-";>;
float mLightSSDOP2       : CONTROLOBJECT<string name="LightingController"; string item = "SSDO+";>;
float mLightSSDOM2       : CONTROLOBJECT<string name="LightingController"; string item = "SSDO-";>;

float mLightSSSSP1       : CONTROLOBJECT<string name="LightingController.pmx"; string item = "SSSS+";>;
float mLightSSSSM1       : CONTROLOBJECT<string name="LightingController.pmx"; string item = "SSSS-";>;
float mLightSSSSP2       : CONTROLOBJECT<string name="LightingController"; string item = "SSSS+";>;
float mLightSSSSM2       : CONTROLOBJECT<string name="LightingController"; string item = "SSSS-";>;

static float mSunLightP   = max(mLightSunLightP1, mLightSunLightP2);
static float mSunLightM   = max(mLightSunLightM1, mLightSunLightM2);
static float mSSAOP       = max(mLightSSAOP1, mLightSSAOP2);
static float mSSAOM       = max(mLightSSAOM1, mLightSSAOM2);
static float mSSAORadiusP = max(mLightSSAORadiusP1, mLightSSAORadiusP2);
static float mSSAORadiusM = max(mLightSSAORadiusM1, mLightSSAORadiusM2);
static float mSSDOP       = max(mLightSSDOP1, mLightSSDOP2);
static float mSSDOM       = max(mLightSSDOM1, mLightSSDOM2);
static float mSSSSP       = max(mLightSSSSP1, mLightSSSSP2);
static float mSSSSM       = max(mLightSSSSM1, mLightSSSSM2);

// =============================================================================
// CameraController.pmx (Dedicated Physical Camera, Lens & DOF Controller)
// =============================================================================
float mCamFstopP1         : CONTROLOBJECT<string name="CameraController.pmx"; string item = "Fstop+";>;
float mCamFstopM1         : CONTROLOBJECT<string name="CameraController.pmx"; string item = "Fstop-";>;
float mCamFstopP2         : CONTROLOBJECT<string name="CameraController"; string item = "Fstop+";>;
float mCamFstopM2         : CONTROLOBJECT<string name="CameraController"; string item = "Fstop-";>;

float mCamFocalLengthP1   : CONTROLOBJECT<string name="CameraController.pmx"; string item = "FocalLength+";>;
float mCamFocalLengthM1   : CONTROLOBJECT<string name="CameraController.pmx"; string item = "FocalLength-";>;
float mCamFocalLengthP2   : CONTROLOBJECT<string name="CameraController"; string item = "FocalLength+";>;
float mCamFocalLengthM2   : CONTROLOBJECT<string name="CameraController"; string item = "FocalLength-";>;

float mCamFocalDistanceP1 : CONTROLOBJECT<string name="CameraController.pmx"; string item = "FocalDistance+";>;
float mCamFocalDistanceM1 : CONTROLOBJECT<string name="CameraController.pmx"; string item = "FocalDistance-";>;
float mCamFocalDistanceP2 : CONTROLOBJECT<string name="CameraController"; string item = "FocalDistance+";>;
float mCamFocalDistanceM2 : CONTROLOBJECT<string name="CameraController"; string item = "FocalDistance-";>;

float mCamFocalRegionP1   : CONTROLOBJECT<string name="CameraController.pmx"; string item = "FocalRegion+";>;
float mCamFocalRegionM1   : CONTROLOBJECT<string name="CameraController.pmx"; string item = "FocalRegion-";>;
float mCamFocalRegionP2   : CONTROLOBJECT<string name="CameraController"; string item = "FocalRegion+";>;
float mCamFocalRegionM2   : CONTROLOBJECT<string name="CameraController"; string item = "FocalRegion-";>;

float mCamBladeCountM1    : CONTROLOBJECT<string name="CameraController.pmx"; string item = "BladeCount-";>;
float mCamBladeCountM2    : CONTROLOBJECT<string name="CameraController"; string item = "BladeCount-";>;

float mCamMeasureMode1    : CONTROLOBJECT<string name="CameraController.pmx"; string item = "MeasureMode";>;
float mCamMeasureMode2    : CONTROLOBJECT<string name="CameraController"; string item = "MeasureMode";>;

float mCamTestMode1       : CONTROLOBJECT<string name="CameraController.pmx"; string item = "TestMode";>;
float mCamTestMode2       : CONTROLOBJECT<string name="CameraController"; string item = "TestMode";>;

float mCamVignette1       : CONTROLOBJECT<string name="CameraController.pmx"; string item = "Vignette";>;
float mCamVignette2       : CONTROLOBJECT<string name="CameraController"; string item = "Vignette";>;

float mCamDispersion1     : CONTROLOBJECT<string name="CameraController.pmx"; string item = "Dispersion";>;
float mCamDispersion2     : CONTROLOBJECT<string name="CameraController"; string item = "Dispersion";>;

float mCamDispersionRadius1 : CONTROLOBJECT<string name="CameraController.pmx"; string item = "DispersionRadius";>;
float mCamDispersionRadius2 : CONTROLOBJECT<string name="CameraController"; string item = "DispersionRadius";>;

static float mFstopP         = max(mCamFstopP1, mCamFstopP2);
static float mFstopM         = max(mCamFstopM1, mCamFstopM2);
static float mFocalLengthP   = max(mCamFocalLengthP1, mCamFocalLengthP2);
static float mFocalLengthM   = max(mCamFocalLengthM1, mCamFocalLengthM2);
static float mFocalDistanceP = max(mCamFocalDistanceP1, mCamFocalDistanceP2);
static float mFocalDistanceM = max(mCamFocalDistanceM1, mCamFocalDistanceM2);
static float mFocalRegionP   = max(mCamFocalRegionP1, mCamFocalRegionP2);
static float mFocalRegionM   = max(mCamFocalRegionM1, mCamFocalRegionM2);
static float mBladeCountM    = max(mCamBladeCountM1, mCamBladeCountM2);
static float mMeasureMode    = max(mCamMeasureMode1, mCamMeasureMode2);
static float mTestMode       = max(mCamTestMode1, mCamTestMode2);
static float mVignette       = max(mCamVignette1, mCamVignette2);
static float mDispersion     = max(mCamDispersion1, mCamDispersion2);
static float mDispersionRadius = max(mCamDispersionRadius1, mCamDispersionRadius2);

// =============================================================================
// BloomController.pmx (Dedicated HDR Bloom & Glare Controller)
// =============================================================================
float mBloomThresholdP1      : CONTROLOBJECT<string name="BloomController.pmx"; string item = "BloomThreshold";>;
float mBloomThresholdP2      : CONTROLOBJECT<string name="BloomController"; string item = "BloomThreshold";>;

float mBloomRadiusP1         : CONTROLOBJECT<string name="BloomController.pmx"; string item = "BloomRadius+";>;
float mBloomRadiusM1         : CONTROLOBJECT<string name="BloomController.pmx"; string item = "BloomRadius-";>;
float mBloomRadiusP2         : CONTROLOBJECT<string name="BloomController"; string item = "BloomRadius+";>;
float mBloomRadiusM2         : CONTROLOBJECT<string name="BloomController"; string item = "BloomRadius-";>;

float mBloomColorAllHP1      : CONTROLOBJECT<string name="BloomController.pmx"; string item = "BloomColorAllH+";>;
float mBloomColorAllHP2      : CONTROLOBJECT<string name="BloomController"; string item = "BloomColorAllH+";>;

float mBloomColorAllSP1      : CONTROLOBJECT<string name="BloomController.pmx"; string item = "BloomColorAllS+";>;
float mBloomColorAllSP2      : CONTROLOBJECT<string name="BloomController"; string item = "BloomColorAllS+";>;

float mBloomColorAllVP1      : CONTROLOBJECT<string name="BloomController.pmx"; string item = "BloomColorAllV+";>;
float mBloomColorAllVM1      : CONTROLOBJECT<string name="BloomController.pmx"; string item = "BloomColorAllV-";>;
float mBloomColorAllVP2      : CONTROLOBJECT<string name="BloomController"; string item = "BloomColorAllV+";>;
float mBloomColorAllVM2      : CONTROLOBJECT<string name="BloomController"; string item = "BloomColorAllV-";>;

float mBloomStarFade1        : CONTROLOBJECT<string name="BloomController.pmx"; string item = "BloomStarFade";>;
float mBloomStarFade2        : CONTROLOBJECT<string name="BloomController"; string item = "BloomStarFade";>;

static float mBloomThresholdP = max(mBloomThresholdP1, mBloomThresholdP2);
static float mBloomRadiusP    = max(mBloomRadiusP1, mBloomRadiusP2);
static float mBloomRadiusM    = max(mBloomRadiusM1, mBloomRadiusM2);
static float mBloomColorAllHP = max(mBloomColorAllHP1, mBloomColorAllHP2);
static float mBloomColorAllSP = max(mBloomColorAllSP1, mBloomColorAllSP2);
static float mBloomColorAllVP = max(mBloomColorAllVP1, mBloomColorAllVP2);
static float mBloomColorAllVM = max(mBloomColorAllVM1, mBloomColorAllVM2);
static float mBloomStarFade   = max(mBloomStarFade1, mBloomStarFade2);

#if SSR_DEBUG
// SSRDebugController.pmx (Dedicated SSR debug controller)
float mSSRDebugTrace      : CONTROLOBJECT<string name="SSRDebugController.pmx"; string item = "SSRTrace";>;
float mSSRDebugConfidence : CONTROLOBJECT<string name="SSRDebugController.pmx"; string item = "SSRConfidence";>;
float mSSRDebugDistance   : CONTROLOBJECT<string name="SSRDebugController.pmx"; string item = "SSRDistance";>;
float mSSRDebugNormal     : CONTROLOBJECT<string name="SSRDebugController.pmx"; string item = "SSRNormal";>;
float mSSRDebugRoughness  : CONTROLOBJECT<string name="SSRDebugController.pmx"; string item = "SSRRoughness";>;
#endif

#if WATER_CAUSTICS_ENABLE
// CausticsController.pmx (Dedicated separate controller)
float mCstIntensityP1   : CONTROLOBJECT<string name="CausticsController.pmx"; string item = "Intensity+";>;
float mCstIntensityM1   : CONTROLOBJECT<string name="CausticsController.pmx"; string item = "Intensity-";>;
float mCstWaterHeightP1 : CONTROLOBJECT<string name="CausticsController.pmx"; string item = "WaterHeight+";>;
float mCstWaterHeightM1 : CONTROLOBJECT<string name="CausticsController.pmx"; string item = "WaterHeight-";>;
float mCstScaleP1       : CONTROLOBJECT<string name="CausticsController.pmx"; string item = "Scale+";>;
float mCstScaleM1       : CONTROLOBJECT<string name="CausticsController.pmx"; string item = "Scale-";>;
float mCstSpeedP1       : CONTROLOBJECT<string name="CausticsController.pmx"; string item = "Speed+";>;
float mCstSpeedM1       : CONTROLOBJECT<string name="CausticsController.pmx"; string item = "Speed-";>;
float mCstDispersionP1  : CONTROLOBJECT<string name="CausticsController.pmx"; string item = "Dispersion+";>;
float mCstDispersionM1  : CONTROLOBJECT<string name="CausticsController.pmx"; string item = "Dispersion-";>;
float3 mCstWaterPos1    : CONTROLOBJECT<string name="CausticsController.pmx"; string item = "Position";>;

float mCstIntensityP2   : CONTROLOBJECT<string name="CausticsController"; string item = "Intensity+";>;
float mCstIntensityM2   : CONTROLOBJECT<string name="CausticsController"; string item = "Intensity-";>;
float mCstWaterHeightP2 : CONTROLOBJECT<string name="CausticsController"; string item = "WaterHeight+";>;
float mCstWaterHeightM2 : CONTROLOBJECT<string name="CausticsController"; string item = "WaterHeight-";>;
float mCstScaleP2       : CONTROLOBJECT<string name="CausticsController"; string item = "Scale+";>;
float mCstScaleM2       : CONTROLOBJECT<string name="CausticsController"; string item = "Scale-";>;
float mCstSpeedP2       : CONTROLOBJECT<string name="CausticsController"; string item = "Speed+";>;
float mCstSpeedM2       : CONTROLOBJECT<string name="CausticsController"; string item = "Speed-";>;
float mCstDispersionP2  : CONTROLOBJECT<string name="CausticsController"; string item = "Dispersion+";>;
float mCstDispersionM2  : CONTROLOBJECT<string name="CausticsController"; string item = "Dispersion-";>;
float3 mCstWaterPos2    : CONTROLOBJECT<string name="CausticsController"; string item = "Position";>;
#endif

#if SKY_VISIBILITY_ENABLE
#define SKY_VIS_CONTROLLER_AVAILABLE 1
// SkyVisibilityController.pmx (Dedicated separate controller - placed before SSGI)
float mSkyVisIntensityP1 : CONTROLOBJECT<string name="SkyVisibilityController.pmx"; string item = "Intensity+";>;
float mSkyVisIntensityM1 : CONTROLOBJECT<string name="SkyVisibilityController.pmx"; string item = "Intensity-";>;
float mSkyVisP1          : CONTROLOBJECT<string name="SkyVisibilityController.pmx"; string item = "SkyVis+";>;
float mSkyVisM1          : CONTROLOBJECT<string name="SkyVisibilityController.pmx"; string item = "SkyVis-";>;
float mSkyVisRadiusP1    : CONTROLOBJECT<string name="SkyVisibilityController.pmx"; string item = "Radius+";>;
float mSkyVisRadiusM1    : CONTROLOBJECT<string name="SkyVisibilityController.pmx"; string item = "Radius-";>;
float mSkyVisFloorP1     : CONTROLOBJECT<string name="SkyVisibilityController.pmx"; string item = "Floor+";>;
float mSkyVisFloorM1     : CONTROLOBJECT<string name="SkyVisibilityController.pmx"; string item = "Floor-";>;
float mSkyVisContrastP1  : CONTROLOBJECT<string name="SkyVisibilityController.pmx"; string item = "Contrast+";>;
float mSkyVisContrastM1  : CONTROLOBJECT<string name="SkyVisibilityController.pmx"; string item = "Contrast-";>;
float3 mSkyVisPos1       : CONTROLOBJECT<string name="SkyVisibilityController.pmx"; string item = "Position";>;

float mSkyVisIntensityP2 : CONTROLOBJECT<string name="SkyVisibilityController"; string item = "Intensity+";>;
float mSkyVisIntensityM2 : CONTROLOBJECT<string name="SkyVisibilityController"; string item = "Intensity-";>;
float mSkyVisP2          : CONTROLOBJECT<string name="SkyVisibilityController"; string item = "SkyVis+";>;
float mSkyVisM2          : CONTROLOBJECT<string name="SkyVisibilityController"; string item = "SkyVis-";>;
float mSkyVisRadiusP2    : CONTROLOBJECT<string name="SkyVisibilityController"; string item = "Radius+";>;
float mSkyVisRadiusM2    : CONTROLOBJECT<string name="SkyVisibilityController"; string item = "Radius-";>;
float mSkyVisFloorP2     : CONTROLOBJECT<string name="SkyVisibilityController"; string item = "Floor+";>;
float mSkyVisFloorM2     : CONTROLOBJECT<string name="SkyVisibilityController"; string item = "Floor-";>;
float mSkyVisContrastP2  : CONTROLOBJECT<string name="SkyVisibilityController"; string item = "Contrast+";>;
float mSkyVisContrastM2  : CONTROLOBJECT<string name="SkyVisibilityController"; string item = "Contrast-";>;
float3 mSkyVisPos2       : CONTROLOBJECT<string name="SkyVisibilityController"; string item = "Position";>;

static float mSkyVisIntensityP = max(max(mSkyVisIntensityP1, mSkyVisIntensityP2), max(mSkyVisP1, mSkyVisP2));
static float mSkyVisIntensityM = max(max(mSkyVisIntensityM1, mSkyVisIntensityM2), max(mSkyVisM1, mSkyVisM2));
static float mSkyVisRadiusP    = max(mSkyVisRadiusP1, mSkyVisRadiusP2);
static float mSkyVisRadiusM    = max(mSkyVisRadiusM1, mSkyVisRadiusM2);
static float mSkyVisFloorP     = max(mSkyVisFloorP1, mSkyVisFloorP2);
static float mSkyVisFloorM     = max(mSkyVisFloorM1, mSkyVisFloorM2);
static float mSkyVisContrastP  = max(mSkyVisContrastP1, mSkyVisContrastP2);
static float mSkyVisContrastM  = max(mSkyVisContrastM1, mSkyVisContrastM2);
static float3 mSkyVisPos       = any(mSkyVisPos1) ? mSkyVisPos1 : mSkyVisPos2;

static float mSkyVisIntensityCtrl = lerp(lerp(mSkyVisibilityIntensity, 1.35f, mSkyVisIntensityP), 0.0f, mSkyVisIntensityM);
static float mSkyVisRadiusScale   = lerp(lerp(1.0f, 2.5f, mSkyVisRadiusP), 0.25f, mSkyVisRadiusM);
static float mSkyVisFloorCtrl     = lerp(lerp(mSkyVisibilityMinFloor, 0.6f, mSkyVisFloorP), 0.0f, mSkyVisFloorM);
static float mSkyVisContrastCtrl  = lerp(lerp(1.0f, 2.5f, mSkyVisContrastP), 0.4f, mSkyVisContrastM);
#endif

float mDbgSSGIIntensity1 : CONTROLOBJECT<string name="DebugController.pmx"; string item = "SSGIIntensity";>;
float mDbgSSGIConeAngle1 : CONTROLOBJECT<string name="DebugController.pmx"; string item = "SSGIConeAngle";>;
float mDbgSSGIBias1      : CONTROLOBJECT<string name="DebugController.pmx"; string item = "SSGIBias";>;

float mDbgSSGIIntensity2 : CONTROLOBJECT<string name="DebugController"; string item = "SSGIIntensity";>;
float mDbgSSGIConeAngle2 : CONTROLOBJECT<string name="DebugController"; string item = "SSGIConeAngle";>;
float mDbgSSGIBias2      : CONTROLOBJECT<string name="DebugController"; string item = "SSGIBias";>;

// SSGI intensity/cone/bias knobs live on DebugController.pmx only.
static float mDbgSSGIIntensity = max(mDbgSSGIIntensity1, mDbgSSGIIntensity2);
static float mDbgSSGIConeAngle = max(mDbgSSGIConeAngle1, mDbgSSGIConeAngle2);
static float mDbgSSGIBias      = max(mDbgSSGIBias1,      mDbgSSGIBias2);

// ColorGradingController.pmx (Dedicated Studio Color Grading Controller)
#define COLOR_GRADING_CONTROLLER_AVAILABLE 1

// Panel 1: Master / Global
float mCgContrastP1    : CONTROLOBJECT<string name="ColorGradingController.pmx"; string item = "Contrast+";>;
float mCgContrastM1    : CONTROLOBJECT<string name="ColorGradingController.pmx"; string item = "Contrast-";>;
float mCgSaturationP1  : CONTROLOBJECT<string name="ColorGradingController.pmx"; string item = "Saturation+";>;
float mCgSaturationM1  : CONTROLOBJECT<string name="ColorGradingController.pmx"; string item = "Saturation-";>;
float mCgGammaP1       : CONTROLOBJECT<string name="ColorGradingController.pmx"; string item = "Gamma+";>;
float mCgGammaM1       : CONTROLOBJECT<string name="ColorGradingController.pmx"; string item = "Gamma-";>;
float mCgExposureP1    : CONTROLOBJECT<string name="ColorGradingController.pmx"; string item = "Exposure+";>;
float mCgExposureM1    : CONTROLOBJECT<string name="ColorGradingController.pmx"; string item = "Exposure-";>;
float mCgVibranceP1    : CONTROLOBJECT<string name="ColorGradingController.pmx"; string item = "Vibrance+";>;
float mCgVibranceM1    : CONTROLOBJECT<string name="ColorGradingController.pmx"; string item = "Vibrance-";>;
float mCgHueP1         : CONTROLOBJECT<string name="ColorGradingController.pmx"; string item = "Hue+";>;
float mCgHueM1         : CONTROLOBJECT<string name="ColorGradingController.pmx"; string item = "Hue-";>;

float mCgContrastP2    : CONTROLOBJECT<string name="ColorGradingController"; string item = "Contrast+";>;
float mCgContrastM2    : CONTROLOBJECT<string name="ColorGradingController"; string item = "Contrast-";>;
float mCgSaturationP2  : CONTROLOBJECT<string name="ColorGradingController"; string item = "Saturation+";>;
float mCgSaturationM2  : CONTROLOBJECT<string name="ColorGradingController"; string item = "Saturation-";>;
float mCgGammaP2       : CONTROLOBJECT<string name="ColorGradingController"; string item = "Gamma+";>;
float mCgGammaM2       : CONTROLOBJECT<string name="ColorGradingController"; string item = "Gamma-";>;
float mCgExposureP2    : CONTROLOBJECT<string name="ColorGradingController"; string item = "Exposure+";>;
float mCgExposureM2    : CONTROLOBJECT<string name="ColorGradingController"; string item = "Exposure-";>;
float mCgVibranceP2    : CONTROLOBJECT<string name="ColorGradingController"; string item = "Vibrance+";>;
float mCgVibranceM2    : CONTROLOBJECT<string name="ColorGradingController"; string item = "Vibrance-";>;
float mCgHueP2         : CONTROLOBJECT<string name="ColorGradingController"; string item = "Hue+";>;
float mCgHueM2         : CONTROLOBJECT<string name="ColorGradingController"; string item = "Hue-";>;

// Panel 2: White Balance & Shadows (Lift)
float mCgTemperatureP1 : CONTROLOBJECT<string name="ColorGradingController.pmx"; string item = "Temperature+";>;
float mCgTemperatureM1 : CONTROLOBJECT<string name="ColorGradingController.pmx"; string item = "Temperature-";>;
float mCgTintP1        : CONTROLOBJECT<string name="ColorGradingController.pmx"; string item = "Tint+";>;
float mCgTintM1        : CONTROLOBJECT<string name="ColorGradingController.pmx"; string item = "Tint-";>;
float mCgShadowRP1     : CONTROLOBJECT<string name="ColorGradingController.pmx"; string item = "ShadowR+";>;
float mCgShadowRM1     : CONTROLOBJECT<string name="ColorGradingController.pmx"; string item = "ShadowR-";>;
float mCgShadowGP1     : CONTROLOBJECT<string name="ColorGradingController.pmx"; string item = "ShadowG+";>;
float mCgShadowGM1     : CONTROLOBJECT<string name="ColorGradingController.pmx"; string item = "ShadowG-";>;
float mCgShadowBP1     : CONTROLOBJECT<string name="ColorGradingController.pmx"; string item = "ShadowB+";>;
float mCgShadowBM1     : CONTROLOBJECT<string name="ColorGradingController.pmx"; string item = "ShadowB-";>;
float mCgShadowContrastP1   : CONTROLOBJECT<string name="ColorGradingController.pmx"; string item = "ShadowContrast+";>;
float mCgShadowContrastM1   : CONTROLOBJECT<string name="ColorGradingController.pmx"; string item = "ShadowContrast-";>;
float mCgShadowSaturationP1 : CONTROLOBJECT<string name="ColorGradingController.pmx"; string item = "ShadowSaturation+";>;
float mCgShadowSaturationM1 : CONTROLOBJECT<string name="ColorGradingController.pmx"; string item = "ShadowSaturation-";>;
float mCgShadowLiftP1       : CONTROLOBJECT<string name="ColorGradingController.pmx"; string item = "ShadowLift+";>;
float mCgShadowLiftM1       : CONTROLOBJECT<string name="ColorGradingController.pmx"; string item = "ShadowLift-";>;

float mCgTemperatureP2 : CONTROLOBJECT<string name="ColorGradingController"; string item = "Temperature+";>;
float mCgTemperatureM2 : CONTROLOBJECT<string name="ColorGradingController"; string item = "Temperature-";>;
float mCgTintP2        : CONTROLOBJECT<string name="ColorGradingController"; string item = "Tint+";>;
float mCgTintM2        : CONTROLOBJECT<string name="ColorGradingController"; string item = "Tint-";>;
float mCgShadowRP2     : CONTROLOBJECT<string name="ColorGradingController"; string item = "ShadowR+";>;
float mCgShadowRM2     : CONTROLOBJECT<string name="ColorGradingController"; string item = "ShadowR-";>;
float mCgShadowGP2     : CONTROLOBJECT<string name="ColorGradingController"; string item = "ShadowG+";>;
float mCgShadowGM2     : CONTROLOBJECT<string name="ColorGradingController"; string item = "ShadowG-";>;
float mCgShadowBP2     : CONTROLOBJECT<string name="ColorGradingController"; string item = "ShadowB+";>;
float mCgShadowBM2     : CONTROLOBJECT<string name="ColorGradingController"; string item = "ShadowB-";>;
float mCgShadowContrastP2   : CONTROLOBJECT<string name="ColorGradingController"; string item = "ShadowContrast+";>;
float mCgShadowContrastM2   : CONTROLOBJECT<string name="ColorGradingController"; string item = "ShadowContrast-";>;
float mCgShadowSaturationP2 : CONTROLOBJECT<string name="ColorGradingController"; string item = "ShadowSaturation+";>;
float mCgShadowSaturationM2 : CONTROLOBJECT<string name="ColorGradingController"; string item = "ShadowSaturation-";>;
float mCgShadowLiftP2       : CONTROLOBJECT<string name="ColorGradingController"; string item = "ShadowLift+";>;
float mCgShadowLiftM2       : CONTROLOBJECT<string name="ColorGradingController"; string item = "ShadowLift-";>;

// Panel 3: Highlights (Gain) & Midtones (Gamma)
float mCgHighlightRP1       : CONTROLOBJECT<string name="ColorGradingController.pmx"; string item = "HighlightR+";>;
float mCgHighlightRM1       : CONTROLOBJECT<string name="ColorGradingController.pmx"; string item = "HighlightR-";>;
float mCgHighlightGP1       : CONTROLOBJECT<string name="ColorGradingController.pmx"; string item = "HighlightG+";>;
float mCgHighlightGM1       : CONTROLOBJECT<string name="ColorGradingController.pmx"; string item = "HighlightG-";>;
float mCgHighlightBP1       : CONTROLOBJECT<string name="ColorGradingController.pmx"; string item = "HighlightB+";>;
float mCgHighlightBM1       : CONTROLOBJECT<string name="ColorGradingController.pmx"; string item = "HighlightB-";>;
float mCgHighlightContrastP1: CONTROLOBJECT<string name="ColorGradingController.pmx"; string item = "HighlightContrast+";>;
float mCgHighlightContrastM1: CONTROLOBJECT<string name="ColorGradingController.pmx"; string item = "HighlightContrast-";>;
float mCgHighlightSaturationP1: CONTROLOBJECT<string name="ColorGradingController.pmx"; string item = "HighlightSaturation+";>;
float mCgHighlightSaturationM1: CONTROLOBJECT<string name="ColorGradingController.pmx"; string item = "HighlightSaturation-";>;
float mCgHighlightGainP1    : CONTROLOBJECT<string name="ColorGradingController.pmx"; string item = "HighlightGain+";>;
float mCgHighlightGainM1    : CONTROLOBJECT<string name="ColorGradingController.pmx"; string item = "HighlightGain-";>;
float mCgMidtoneRP1         : CONTROLOBJECT<string name="ColorGradingController.pmx"; string item = "MidtoneR+";>;
float mCgMidtoneRM1         : CONTROLOBJECT<string name="ColorGradingController.pmx"; string item = "MidtoneR-";>;
float mCgMidtoneGP1         : CONTROLOBJECT<string name="ColorGradingController.pmx"; string item = "MidtoneG+";>;
float mCgMidtoneGM1         : CONTROLOBJECT<string name="ColorGradingController.pmx"; string item = "MidtoneG-";>;
float mCgMidtoneBP1         : CONTROLOBJECT<string name="ColorGradingController.pmx"; string item = "MidtoneB+";>;
float mCgMidtoneBM1         : CONTROLOBJECT<string name="ColorGradingController.pmx"; string item = "MidtoneB-";>;
float mCgMidtoneContrastP1  : CONTROLOBJECT<string name="ColorGradingController.pmx"; string item = "MidtoneContrast+";>;
float mCgMidtoneContrastM1  : CONTROLOBJECT<string name="ColorGradingController.pmx"; string item = "MidtoneContrast-";>;
float mCgMidtoneSaturationP1: CONTROLOBJECT<string name="ColorGradingController.pmx"; string item = "MidtoneSaturation+";>;
float mCgMidtoneSaturationM1: CONTROLOBJECT<string name="ColorGradingController.pmx"; string item = "MidtoneSaturation-";>;

float mCgHighlightRP2       : CONTROLOBJECT<string name="ColorGradingController"; string item = "HighlightR+";>;
float mCgHighlightRM2       : CONTROLOBJECT<string name="ColorGradingController"; string item = "HighlightR-";>;
float mCgHighlightGP2       : CONTROLOBJECT<string name="ColorGradingController"; string item = "HighlightG+";>;
float mCgHighlightGM2       : CONTROLOBJECT<string name="ColorGradingController"; string item = "HighlightG-";>;
float mCgHighlightBP2       : CONTROLOBJECT<string name="ColorGradingController"; string item = "HighlightB+";>;
float mCgHighlightBM2       : CONTROLOBJECT<string name="ColorGradingController"; string item = "HighlightB-";>;
float mCgHighlightContrastP2: CONTROLOBJECT<string name="ColorGradingController"; string item = "HighlightContrast+";>;
float mCgHighlightContrastM2: CONTROLOBJECT<string name="ColorGradingController"; string item = "HighlightContrast-";>;
float mCgHighlightSaturationP2: CONTROLOBJECT<string name="ColorGradingController"; string item = "HighlightSaturation+";>;
float mCgHighlightSaturationM2: CONTROLOBJECT<string name="ColorGradingController"; string item = "HighlightSaturation-";>;
float mCgHighlightGainP2    : CONTROLOBJECT<string name="ColorGradingController"; string item = "HighlightGain+";>;
float mCgHighlightGainM2    : CONTROLOBJECT<string name="ColorGradingController"; string item = "HighlightGain-";>;
float mCgMidtoneRP2         : CONTROLOBJECT<string name="ColorGradingController"; string item = "MidtoneR+";>;
float mCgMidtoneRM2         : CONTROLOBJECT<string name="ColorGradingController"; string item = "MidtoneR-";>;
float mCgMidtoneGP2         : CONTROLOBJECT<string name="ColorGradingController"; string item = "MidtoneG+";>;
float mCgMidtoneGM2         : CONTROLOBJECT<string name="ColorGradingController"; string item = "MidtoneG-";>;
float mCgMidtoneBP2         : CONTROLOBJECT<string name="ColorGradingController"; string item = "MidtoneB+";>;
float mCgMidtoneBM2         : CONTROLOBJECT<string name="ColorGradingController"; string item = "MidtoneB-";>;
float mCgMidtoneContrastP2  : CONTROLOBJECT<string name="ColorGradingController"; string item = "MidtoneContrast+";>;
float mCgMidtoneContrastM2  : CONTROLOBJECT<string name="ColorGradingController"; string item = "MidtoneContrast-";>;
float mCgMidtoneSaturationP2: CONTROLOBJECT<string name="ColorGradingController"; string item = "MidtoneSaturation+";>;
float mCgMidtoneSaturationM2: CONTROLOBJECT<string name="ColorGradingController"; string item = "MidtoneSaturation-";>;

// Panel 4: Global Balance & Film Presets
float mCgBalanceRP1   : CONTROLOBJECT<string name="ColorGradingController.pmx"; string item = "BalanceR+";>;
float mCgBalanceRM1   : CONTROLOBJECT<string name="ColorGradingController.pmx"; string item = "BalanceR-";>;
float mCgBalanceGP1   : CONTROLOBJECT<string name="ColorGradingController.pmx"; string item = "BalanceG+";>;
float mCgBalanceGM1   : CONTROLOBJECT<string name="ColorGradingController.pmx"; string item = "BalanceG-";>;
float mCgBalanceBP1   : CONTROLOBJECT<string name="ColorGradingController.pmx"; string item = "BalanceB+";>;
float mCgBalanceBM1   : CONTROLOBJECT<string name="ColorGradingController.pmx"; string item = "BalanceB-";>;
float mCgTealOrangeP1 : CONTROLOBJECT<string name="ColorGradingController.pmx"; string item = "TealOrange+";>;
float mCgBleachBypassP1: CONTROLOBJECT<string name="ColorGradingController.pmx"; string item = "BleachBypass+";>;
float mCgCrossProcessP1: CONTROLOBJECT<string name="ColorGradingController.pmx"; string item = "CrossProcess+";>;
float mCgMonochromeP1 : CONTROLOBJECT<string name="ColorGradingController.pmx"; string item = "Monochrome+";>;

float mCgBalanceRP2   : CONTROLOBJECT<string name="ColorGradingController"; string item = "BalanceR+";>;
float mCgBalanceRM2   : CONTROLOBJECT<string name="ColorGradingController"; string item = "BalanceR-";>;
float mCgBalanceGP2   : CONTROLOBJECT<string name="ColorGradingController"; string item = "BalanceG+";>;
float mCgBalanceGM2   : CONTROLOBJECT<string name="ColorGradingController"; string item = "BalanceG-";>;
float mCgBalanceBP2   : CONTROLOBJECT<string name="ColorGradingController"; string item = "BalanceB+";>;
float mCgBalanceBM2   : CONTROLOBJECT<string name="ColorGradingController"; string item = "BalanceB-";>;
float mCgTealOrangeP2 : CONTROLOBJECT<string name="ColorGradingController"; string item = "TealOrange+";>;
float mCgBleachBypassP2: CONTROLOBJECT<string name="ColorGradingController"; string item = "BleachBypass+";>;
float mCgCrossProcessP2: CONTROLOBJECT<string name="ColorGradingController"; string item = "CrossProcess+";>;
float mCgMonochromeP2 : CONTROLOBJECT<string name="ColorGradingController"; string item = "Monochrome+";>;

// Master / Global Grading Controls (Driven exclusively by ColorGradingController)
static float mContrastP_Comb   = max(mCgContrastP1, mCgContrastP2);
static float mContrastM_Comb   = max(mCgContrastM1, mCgContrastM2);
static float mSaturationP_Comb = max(mCgSaturationP1, mCgSaturationP2);
static float mSaturationM_Comb = max(mCgSaturationM1, mCgSaturationM2);
static float mGammaP_Comb      = max(mCgGammaP1, mCgGammaP2);
static float mGammaM_Comb      = max(mCgGammaM1, mCgGammaM2);
static float mExposureP_Comb   = max(mCgExposureP1, mCgExposureP2);
static float mExposureM_Comb   = max(mCgExposureM1, mCgExposureM2);

// White Balance Controls (Driven by ColorGradingController)
static float mTemperatureP_Comb = max(mCgTemperatureP1, mCgTemperatureP2);
static float mTemperatureM_Comb = max(mCgTemperatureM1, mCgTemperatureM2);
static float mTintP             = max(mCgTintP1, mCgTintP2);
static float mTintM             = max(mCgTintM1, mCgTintM2);
static float mColorTint         = mTintP - mTintM;

// Vibrance and Hue Rotation
static float mVibranceP = max(mCgVibranceP1, mCgVibranceP2);
static float mVibranceM = max(mCgVibranceM1, mCgVibranceM2);
static float mColorVibrance = mVibranceP - mVibranceM;

static float mHueP = max(mCgHueP1, mCgHueP2);
static float mHueM = max(mCgHueM1, mCgHueM2);
static float mColorHue = (mHueP - mHueM) * 3.14159265f;

// Color Balance (Driven by ColorGradingController)
static float mColBalanceRP_Comb = max(mCgBalanceRP1, mCgBalanceRP2);
static float mColBalanceRM_Comb = max(mCgBalanceRM1, mCgBalanceRM2);
static float mColBalanceGP_Comb = max(mCgBalanceGP1, mCgBalanceGP2);
static float mColBalanceGM_Comb = max(mCgBalanceGM1, mCgBalanceGM2);
static float mColBalanceBP_Comb = max(mCgBalanceBP1, mCgBalanceBP2);
static float mColBalanceBM_Comb = max(mCgBalanceBM1, mCgBalanceBM2);

// Shadows Grading (Lift)
static float3 mShadowGainP = float3(max(mCgShadowRP1, mCgShadowRP2), max(mCgShadowGP1, mCgShadowGP2), max(mCgShadowBP1, mCgShadowBP2));
static float3 mShadowGainM = float3(max(mCgShadowRM1, mCgShadowRM2), max(mCgShadowGM1, mCgShadowGM2), max(mCgShadowBM1, mCgShadowBM2));
static float mShadowContrastP   = max(mCgShadowContrastP1, mCgShadowContrastP2);
static float mShadowContrastM   = max(mCgShadowContrastM1, mCgShadowContrastM2);
static float mShadowSaturationP = max(mCgShadowSaturationP1, mCgShadowSaturationP2);
static float mShadowSaturationM = max(mCgShadowSaturationM1, mCgShadowSaturationM2);
static float mShadowLiftP       = max(mCgShadowLiftP1, mCgShadowLiftP2);
static float mShadowLiftM       = max(mCgShadowLiftM1, mCgShadowLiftM2);

static float3 mShadowGain       = float3(1.0f, 1.0f, 1.0f) + (mShadowGainP - mShadowGainM) * 0.75f;
static float mShadowContrast    = lerp(lerp(1.0f, 2.0f, mShadowContrastP), 0.5f, mShadowContrastM);
static float mShadowSaturation  = lerp(lerp(1.0f, 2.0f, mShadowSaturationP), 0.0f, mShadowSaturationM);
static float mShadowLift        = (mShadowLiftP - mShadowLiftM) * 0.25f;

// Highlights Grading (Gain)
static float3 mHighlightGainP   = float3(max(mCgHighlightRP1, mCgHighlightRP2), max(mCgHighlightGP1, mCgHighlightGP2), max(mCgHighlightBP1, mCgHighlightBP2));
static float3 mHighlightGainM   = float3(max(mCgHighlightRM1, mCgHighlightRM2), max(mCgHighlightGM1, mCgHighlightGM2), max(mCgHighlightBM1, mCgHighlightBM2));
static float mHighlightContrastP   = max(mCgHighlightContrastP1, mCgHighlightContrastP2);
static float mHighlightContrastM   = max(mCgHighlightContrastM1, mCgHighlightContrastM2);
static float mHighlightSaturationP = max(mCgHighlightSaturationP1, mCgHighlightSaturationP2);
static float mHighlightSaturationM = max(mCgHighlightSaturationM1, mCgHighlightSaturationM2);
static float mHighlightLevelP      = max(mCgHighlightGainP1, mCgHighlightGainP2);
static float mHighlightLevelM      = max(mCgHighlightGainM1, mCgHighlightGainM2);

static float3 mHighlightGain    = (float3(1.0f, 1.0f, 1.0f) + (mHighlightGainP - mHighlightGainM) * 0.75f) * lerp(lerp(1.0f, 2.0f, mHighlightLevelP), 0.25f, mHighlightLevelM);
static float mHighlightContrast = lerp(lerp(1.0f, 2.0f, mHighlightContrastP), 0.5f, mHighlightContrastM);
static float mHighlightSaturation = lerp(lerp(1.0f, 4.0f, mHighlightSaturationP), 0.0f, mHighlightSaturationM);

// Midtones Grading (Gamma)
static float3 mMidtoneGainP     = float3(max(mCgMidtoneRP1, mCgMidtoneRP2), max(mCgMidtoneGP1, mCgMidtoneGP2), max(mCgMidtoneBP1, mCgMidtoneBP2));
static float3 mMidtoneGainM     = float3(max(mCgMidtoneRM1, mCgMidtoneRM2), max(mCgMidtoneGM1, mCgMidtoneGM2), max(mCgMidtoneBM1, mCgMidtoneBM2));
static float mMidtoneContrastP  = max(mCgMidtoneContrastP1, mCgMidtoneContrastP2);
static float mMidtoneContrastM  = max(mCgMidtoneContrastM1, mCgMidtoneContrastM2);
static float mMidtoneSaturationP = max(mCgMidtoneSaturationP1, mCgMidtoneSaturationP2);
static float mMidtoneSaturationM = max(mCgMidtoneSaturationM1, mCgMidtoneSaturationM2);

static float3 mMidtoneGain      = float3(1.0f, 1.0f, 1.0f) + (mMidtoneGainP - mMidtoneGainM) * 0.75f;
static float mMidtoneContrast   = lerp(lerp(1.0f, 2.0f, mMidtoneContrastP), 0.5f, mMidtoneContrastM);
static float mMidtoneSaturation = lerp(lerp(1.0f, 2.0f, mMidtoneSaturationP), 0.0f, mMidtoneSaturationM);

// Film Presets
static float mTealOrange   = max(mCgTealOrangeP1, mCgTealOrangeP2);
static float mBleachBypass = max(mCgBleachBypassP1, mCgBleachBypassP2);
static float mCrossProcess = max(mCgCrossProcessP1, mCgCrossProcessP2);
static float mMonochrome   = max(mCgMonochromeP1, mCgMonochromeP2);

// Check if 3-way grading is engaged
static bool mEnable3WayGrading = (any(mShadowGainP) || any(mShadowGainM) || mShadowContrastP > 0 || mShadowContrastM > 0 || mShadowSaturationP > 0 || mShadowSaturationM > 0 || mShadowLiftP > 0 || mShadowLiftM > 0 ||
                                 any(mHighlightGainP) || any(mHighlightGainM) || mHighlightContrastP > 0 || mHighlightContrastM > 0 || mHighlightSaturationP > 0 || mHighlightSaturationM > 0 || mHighlightLevelP > 0 || mHighlightLevelM > 0 ||
                                 any(mMidtoneGainP) || any(mMidtoneGainM) || mMidtoneContrastP > 0 || mMidtoneContrastM > 0 || mMidtoneSaturationP > 0 || mMidtoneSaturationM > 0);

static float mSSAOScale = lerp(lerp(mSSDOIntensityMin, mSSDOIntensityMax, mSSAOP), 0, mSSAOM);
static float mSSAORadius = lerp(lerp(1.0, 2.0, mSSAORadiusP), 0.5, mSSAORadiusM);
static float mSSDOScale = lerp(lerp(mSSDOIntensityMin, mSSDOIntensityMax, mSSDOP), 0, mSSDOM);
static float mSSSSScale = lerp(lerp(mSSSSIntensityMin, mSSSSIntensityMax, mSSSSP), 0.25, mSSSSM);
static float mSSGIIntensity = lerp(mSSGIIntensityDefault, 5.0, mDbgSSGIIntensity);
static float mSSGIConeAngle = lerp(mSSGIConeAngleDefault, 1.8, mDbgSSGIConeAngle);
static float mSSGIBias = lerp(mSSGIBiasDefault, 2.0, mDbgSSGIBias);
static float mSSRBlur = mSSRBlurDefault;
static float mSSRThickness = mSSRThicknessDefault;
static float mSSROffset = mSSROffsetDefault;
static float mSSRSmoothness = mSSRSmoothnessDefault;
static float mSSRBrightness = mSSRBrightnessDefault;
static float mSSRFresnel = mSSRFresnelDefault;
static float mSunIntensity = lerp(lerp(mLightIntensityMin, mLightIntensityMax, mSunLightP), 0, mSunLightM);
static float mExposure = lerp(lerp(mExposureMin, mExposureMax, mExposureP_Comb), 0, mExposureM_Comb);
static float mBloomRadius = lerp(lerp(2.2, 10, mBloomRadiusP), 0.1, mBloomRadiusM);
static float mBloomThreshold = (1.0 - mBloomThresholdP) / (mBloomThresholdP + 1e-5);
static float mColorContrast = lerp(lerp(1, 2, mContrastP_Comb), 0.5, mContrastM_Comb);
static float mColorSaturation = lerp(lerp(1, 2, mSaturationP_Comb), 0.0, mSaturationM_Comb);
static float mColorGamma = lerp(lerp(1.0, 0.45, mGammaP_Comb), 2.2, mGammaM_Comb);
static float mColorTemperature = lerp(lerp(mTemperature, 1000, mTemperatureP_Comb), 40000, mTemperatureM_Comb);
static float mFstop = lerp(lerp(5.6, 32.0, mFstopP), 1.0, mFstopM);
static float mFocalDistance = lerp(lerp(1, 10.0, mFocalDistanceP), -10.0, mFocalDistanceM);
static float mFocalRegion = lerp(0.0, 10.0, mFocalRegionP);
static float mBladeCount = lerp(10, 5, mBladeCountM);
static float3 mColorBalanceP = float3(mColBalanceRP_Comb, mColBalanceGP_Comb, mColBalanceBP_Comb);
static float3 mColorBalanceM = float3(mColBalanceRM_Comb, mColBalanceGM_Comb, mColBalanceBM_Comb);
#if WATER_CAUSTICS_ENABLE
static float mCstIntensityP   = max(mCstIntensityP1, mCstIntensityP2);
static float mCstIntensityM   = max(mCstIntensityM1, mCstIntensityM2);
static float mCstWaterHeightP = max(mCstWaterHeightP1, mCstWaterHeightP2);
static float mCstWaterHeightM = max(mCstWaterHeightM1, mCstWaterHeightM2);
static float mCstScaleP       = max(mCstScaleP1, mCstScaleP2);
static float mCstScaleM       = max(mCstScaleM1, mCstScaleM2);
static float mCstSpeedP       = max(mCstSpeedP1, mCstSpeedP2);
static float mCstSpeedM       = max(mCstSpeedM1, mCstSpeedM2);
static float mCstDispersionP  = max(mCstDispersionP1, mCstDispersionP2);
static float mCstDispersionM  = max(mCstDispersionM1, mCstDispersionM2);
static float3 mCstWaterPos    = any(mCstWaterPos1) ? mCstWaterPos1 : mCstWaterPos2;

static float mCausticsIntensity  = lerp(lerp(WATER_CAUSTICS_INTENSITY, WATER_CAUSTICS_INTENSITY * 3.0f, mCstIntensityP), 0.0f, mCstIntensityM);
static float mWaterHeight        = WATER_CAUSTICS_SURFACE_Y + mCstWaterPos.y + lerp(lerp(0.0f, 30.0f, mCstWaterHeightP), -30.0f, mCstWaterHeightM);
static float mCausticsFreqScale  = lerp(lerp(1.15f, 3.0f, mCstScaleP), 0.3f, mCstScaleM);
static float mCausticsSpeedScale = lerp(lerp(1.0f, 2.5f, mCstSpeedP), 0.1f, mCstSpeedM);
static float mCausticsDispScale  = lerp(lerp(1.0f, 3.0f, mCstDispersionP), 0.0f, mCstDispersionM);
#endif

#include "shader/Core/math.fxsub"
#include "shader/Core/common.fxsub"
#include "shader/Core/textures.fxsub"
#if (AA_QUALITY == 6) || POST_MOTION_BLUR_ENABLE || (GI_ENABLE > 0)
#	include "shader/PostProcess/PostProcessMatrix.fxsub"
#endif
#include "shader/Core/gbuffer.fxsub"
#include "shader/Lighting/ibl.fxsub"
#include "shader/Lighting/BRDF.fxsub"
#include "shader/PostProcess/ColorGrading.fxsub"
#if SUN_SHADOW_QUALITY && SUN_LIGHT_ENABLE
#	include "shader/Shadows/ShadowMapGen.fxsub"
#	include "shader/Shadows/ShadowBilateralBlur.fxsub"
#endif
#include "shader/Lighting/ShadingMaterials.fxsub"



#if SSDO_QUALITY && (IBL_QUALITY || SUN_LIGHT_ENABLE)
#if SSAO_TYPE == 0
#	include "shader/Occlusion/PostProcessOcclusion.fxsub"
#elif SSAO_TYPE == 1
#	include "shader/Occlusion/PostProcessOcclusionHBAO.fxsub"
#elif SSAO_TYPE == 2
#	include "shader/Occlusion/PostProcessOcclusionGTAO.fxsub"
#endif
#endif

#if SSSS_QUALITY
#	include "shader/Subsurface/PostProcessScattering.fxsub"
#endif

#if OUTLINE_QUALITY == 2
#	include "shader/AntiAliasing/EdgeLineAA.fxsub"
#endif

#if TOON_ENABLE == 2
#	include "shader/PostProcess/PostProcessDiffusion.fxsub"
#endif

#if SSR_QUALITY
#	include "shader/SSR/SSR_Main.fxsub"
#endif

#if GI_ENABLE
#	include "shader/GI/SSGI/PostProcessSSGI.fxsub"
#endif

#ifndef BOKEH_MODE
#	define BOKEH_MODE 0
#endif

#if BOKEH_MODE == 1
#	include "shader/PostProcess/PostProcessBokeh.fxsub"
#elif BOKEH_MODE == 2
#	include "shader/PostProcess/PostProcessHexagonalBokeh.fxsub"
#endif

#if HDR_EYE_ADAPTATION
#	include "shader/PostProcess/PostProcessEyeAdaptation.fxsub"
#endif

#if HDR_STAR_MODE
#	include "shader/PostProcess/PostProcessLensflare.fxsub"
#endif

#if HDR_FLARE_MODE
#	include "shader/PostProcess/PostProcessGhost.fxsub"
#endif

#if HDR_BLOOM_MODE
#	include "shader/PostProcess/PostProcessBloom.fxsub"
#endif

#include "shader/PostProcess/PostProcessHDR.fxsub"

#if AA_QUALITY == 1
#	include "shader/AntiAliasing/FXAA3.fxsub"
#endif

#if AA_QUALITY >= 2 && AA_QUALITY <= 5
#	include "shader/AntiAliasing/SMAA.fxsub"
#endif

#if AA_QUALITY == 6
#	include "shader/AntiAliasing/TAA.fxsub"
#endif

#if AA_QUALITY == 7
#	include "shader/AntiAliasing/DLAA.fxsub"
#endif

#if POST_MOTION_BLUR_ENABLE
#	include "shader/PostProcess/PostProcessMotionBlur.fxsub"
#endif

#if POST_SHARPEN_ENABLE
#	include "shader/PostProcess/PostProcessSharpen.fxsub"
#endif


float4 ScreenSpaceQuadVS(
	in float4 Position : POSITION,
	in float4 Texcoord : TEXCOORD,
	out float4 oTexcoord0 : TEXCOORD0,
	out float3 oTexcoord1 : TEXCOORD1) : POSITION
{
	oTexcoord0 = Texcoord;
	oTexcoord0.xy += ViewportOffset;
	oTexcoord0.zw = oTexcoord0.xy * ViewportSize;
	oTexcoord1 = -mul(Position, matProjectInverse).xyz;
	return Position;
}

float4 ScreenSpaceQuadOffsetVS(
	in float4 Position : POSITION,
	in float2 Texcoord : TEXCOORD,
	out float2 oTexcoord : TEXCOORD0,
	uniform float2 offset) : POSITION
{
	oTexcoord = Texcoord + offset * 0.5;
	return Position;
}

float Script : STANDARDSGLOBAL<
	string ScriptOutput = "color";
	string ScriptClass  = "scene";
	string ScriptOrder  = "postprocess";
> = 0.8;

technique DeferredLighting<
	string Script =
#if SSSS_QUALITY && SSSS_TEXSPACE
	"RenderColorTarget0=SSSUVLightMap; ClearSetColor=BackColor; Clear=Color;"
	"RenderColorTarget0=SSSUVAlbedoMap; ClearSetColor=BackColor; Clear=Color;"
#endif
	"RenderColorTarget=ScnMap;"
	"RenderDepthStencilTarget=DepthBuffer;"
	"ClearSetColor=BackColor;"
	"ClearSetDepth=ClearDepth;"
	"Clear=Color;"
	"Clear=Depth;"
	"ScriptExternal=Color;"

#if SUN_SHADOW_QUALITY && SUN_LIGHT_ENABLE
	"RenderColorTarget=ShadowMap;"
	"ClearSetColor=WhiteColor;"
	"Clear=Color;"
	"Pass=ShadowMapGen;"
	"ClearSetColor=BackColor;"
#if SUN_SHADOW_BLUR
	"RenderColorTarget=ShadowMapTemp; Pass=ShadowBlurX;"
	"RenderColorTarget=ShadowMap;     Pass=ShadowBlurY;"
#endif
#endif

#if !GI_ENABLE
// GI disabled: SSDO runs before shading (classic path, AO applied in ShadingMaterials).
#if SSDO_QUALITY && (IBL_QUALITY || SUN_LIGHT_ENABLE)
	"RenderColorTarget=SSDOMap; Pass=SSDO;"
#if SSDO_BLUR_RADIUS
	"RenderColorTarget=SSDOMapTemp; Pass=SSDOBlurX;"
	"RenderColorTarget=SSDOMap;     Pass=SSDOBlurY;"
#endif
#endif
#endif

#if OUTLINE_QUALITY == 2
	"RenderColorTarget=EdgeEdgeMap;  Clear=Color; Pass=EdgeEdgeDetection;"
	"RenderColorTarget=EdgeBlendMap; Clear=Color; Pass=EdgeBlendingWeightCalculation;"
	"RenderColorTarget=OutlineTempMap; Pass=EdgeNeighborhoodBlending;"
#endif

#if GI_ENABLE
	// AO runs BEFORE shading/GI: ShadingMaterial/IBL consume SSDOMap directly and
	// the final composite no longer needs a post-GI AO multiply pass.
#if SSDO_QUALITY && (IBL_QUALITY || SUN_LIGHT_ENABLE)
	"RenderColorTarget=SSDOMap; Pass=SSDO;"
#if SSDO_BLUR_RADIUS
	"RenderColorTarget=SSDOMapTemp; Pass=SSDOBlurX;"
	"RenderColorTarget=SSDOMap;     Pass=SSDOBlurY;"
#endif
#endif
#endif

#if SSSS_QUALITY && SSSS_TEXSPACE
	// Texture-space SSS field: convolve the UV-wrapped skin irradiance once
	// before the deferred composite consumes it (WRAP addressing, coverage-
	// weighted kernel).
	"RenderColorTarget=SSSUVLightTemp; Pass=SSSSTexSpaceUVBlurX;"
	"RenderColorTarget=SSSUVLightMap;  Pass=SSSSTexSpaceUVBlurY;"
#endif

#if SSSS_QUALITY
	"RenderColorTarget0=ShadingMapTemp;"
	"RenderColorTarget1=ShadingMapTempSpecular;"
	"Pass=ShadingOpacity;"
	"RenderColorTarget1=;"

	"RenderDepthStencilTarget=DepthBuffer;"
	"RenderColorTarget=;"
	"Clear=Depth;"
	"Pass=SSSSStencilTest;"
	"RenderColorTarget=ShadingMap; Clear=Color; Pass=SSSSBlurX;"
	"RenderColorTarget=ShadingMapTemp;	Pass=SSSSBlurY;"
	"RenderColorTarget=ShadingMapTemp;	Pass=ShadingOpacityAlbedo;"
	"RenderColorTarget=ShadingMapTemp;	Pass=ShadingOpacitySpecular;"
	"RenderColorTarget=ShadingMap;		Pass=ShadingTransparent;"
#else
	"RenderColorTarget=ShadingMapTemp;	Pass=ShadingOpacity;"
	"RenderColorTarget=ShadingMap;		Pass=ShadingTransparent;"
#endif

#if TOON_ENABLE == 2
	"RenderColorTarget=ShadingMapTemp; 	Pass=DiffusionBlurX;"
	"RenderColorTarget=ShadingMap; 		Pass=DiffusionBlurY;"
#endif

#if GI_ENABLE
	// Reject trace outliers first; blur and resolve reconstruct a low-frequency GI field.
	"RenderColorTarget=SSGIMapTemp; Clear=Color; Pass=SSGI;"
	"RenderColorTarget=SSGIMap;     Pass=SSGIPrefilter;"
	"RenderColorTarget=SSGIMapTemp; Pass=SSGIBlurX;"
	"RenderColorTarget=SSGIMap;     Pass=SSGIBlurY;"
	"RenderColorTarget=SSGIMapTemp; Pass=SSGIBlurX2;"
	"RenderColorTarget=SSGIMap;     Pass=SSGIBlurY2;"
	"RenderColorTarget=ShadingMap;  Pass=SSGIFinalCombine;"
#endif

#if SSR_QUALITY
	"RenderColorTarget=SSRLightX1Map;"
	"Clear=Color;"
	"Pass=SSR_Trace;"

	"RenderColorTarget=SSRLightX2MapTemp; Pass=SSR_BlurX2;"
	"RenderColorTarget=SSRLightX2Map;	  Pass=SSR_BlurY2;"
	"RenderColorTarget=SSRLightX3MapTemp; Pass=SSR_BlurX3;"
	"RenderColorTarget=SSRLightX3Map;	  Pass=SSR_BlurY3;"
	"RenderColorTarget=SSRLightX4MapTemp; Pass=SSR_BlurX4;"
	"RenderColorTarget=SSRLightX4Map;	  Pass=SSR_BlurY4;"

	"RenderColorTarget=ShadingMap;		  Pass=SSR_Resolve;"
#endif

#if BOKEH_MODE == 1
	"RenderColorTarget=AutoFocalMap;          Clear=Color; Pass=ComputeFocalDistance;"
	"RenderColorTarget=FocalBokehKernelMap;   Clear=Color; Pass=ComputeBokehKernel;"
	"RenderColorTarget=FocalCoCMap;           Clear=Color; Pass=ComputeBokehWeight;"
	"RenderColorTarget=FocalBokehMap;         Clear=Color; Pass=ComputeBokehFarPrefilter;"
	"RenderColorTarget=FocalBokehFarMap;      Clear=Color; Pass=ComputeBokehFar;"
	"RenderColorTarget=FocalBokehMap;         Clear=Color; Pass=ComputeBokehNearPrefilter;"
	"RenderColorTarget=FocalBokehNearMap;     Clear=Color; Pass=ComputeBokehNear;"
	"RenderColorTarget=FocalBokehNearBlurMap; Clear=Color; Pass=ComputeBilinearBlur;"

	"RenderColorTarget=ShadingMap; Pass=ComputeBokehFinal;"
#endif

#if BOKEH_MODE == 2
	"RenderColorTarget=AutoFocalMap;          Clear=Color; Pass=ComputeFocalDistance;"
	"RenderColorTarget=FocalCoCMap;           Clear=Color; Pass=ComputeBokehWeight;"

	"RenderColorTarget=FocalBokehMap;         Clear=Color; Pass=ComputeBokehFarPrefilter;"
	"RenderColorTarget0=FocalBlur1Map;"
	"RenderColorTarget1=FocalBlur2Map;"
	"Clear=Color;"
	"Pass=ComputeHexagonalBlurX;"
	"RenderColorTarget1=;"

	"RenderColorTarget=FocalHexBokehMap;"
	"Clear=Color;"
	"Pass=ComputeHexagonalBlurY;"

	"RenderColorTarget=FocalBokehMap;         Clear=Color; Pass=ComputeBokehNearPrefilter;"
	"RenderColorTarget=FocalBlur2Map;         Clear=Color; Pass=ComputeBokehBlur;"
	"RenderColorTarget=FocalBlur1Map;         Clear=Color; Pass=ComputeBilinearBlur;"

	"RenderColorTarget=ShadingMap; Pass=ComputeBokehFinal;"
#endif

#if HDR_EYE_ADAPTATION
	"RenderColorTarget=EyeLumMap; 	 Pass=EyeLum;"
	"RenderColorTarget=EyeLumAveMap; Pass=EyeAdapation;"
#endif

#if HDR_BLOOM_MODE
	"RenderColorTarget=DownsampleMap1st; Pass=GlareDetection;"
#if HDR_STAR_MODE || HDR_FLARE_MODE
	"RenderColorTarget=DownsampleMap2nd; Pass=HDRDownsample2nd;"
#endif
	"RenderColorTarget=BloomMap1stTemp;  Pass=BloomBlurX1;"
	"RenderColorTarget=BloomMap1st;		 Pass=BloomBlurY1;"
	"RenderColorTarget=BloomMap2nd;		 Pass=BloomDownsampleX2;"
	"RenderColorTarget=BloomMap2ndTemp;  Pass=BloomBlurX2;"
	"RenderColorTarget=BloomMap2nd;		 Pass=BloomBlurY2;"
	"RenderColorTarget=BloomMap3rd;		 Pass=BloomDownsampleX3;"
	"RenderColorTarget=BloomMap3rdTemp;  Pass=BloomBlurX3;"
	"RenderColorTarget=BloomMap3rd;		 Pass=BloomBlurY3;"
	"RenderColorTarget=BloomMap4th;		 Pass=BloomDownsampleX4;"
	"RenderColorTarget=BloomMap4thTemp;  Pass=BloomBlurX4;"
	"RenderColorTarget=BloomMap4th;		 Pass=BloomBlurY4;"
	"RenderColorTarget=BloomMap5th;		 Pass=BloomDownsampleX5;"
	"RenderColorTarget=BloomMap5thTemp;  Pass=BloomBlurX5;"
	"RenderColorTarget=BloomMap5th;		 Pass=BloomBlurY5;"
#if HDR_STAR_MODE == 1 || HDR_STAR_MODE == 2
	"RenderColorTarget=StreakMap1stTemp; Pass=Star1stStreak1st;"
	"RenderColorTarget=StreakMap1st;	 Pass=Star1stStreak2nd;"
	"RenderColorTarget=StreakMap1stTemp; Pass=Star1stStreak3rd;"
	"RenderColorTarget=StreakMap1st;	 Pass=Star1stStreak4th;"
	"RenderColorTarget=StreakMap2ndTemp; Pass=Star2ndStreak1st;"
	"RenderColorTarget=StreakMap2nd;	 Pass=Star2ndStreak2nd;"
	"RenderColorTarget=StreakMap2ndTemp; Pass=Star2ndStreak3rd;"
	"RenderColorTarget=StreakMap2nd;	 Pass=Star2ndStreak4th;"
#endif
#if HDR_STAR_MODE == 3 || HDR_STAR_MODE == 4
	"RenderColorTarget=StreakMap1st;	 Pass=Star1stStreak1st;"
	"RenderColorTarget=StreakMap1stTemp; Pass=Star1stStreak2nd;"
	"RenderColorTarget=StreakMap1st;	 Pass=Star1stStreak3rd;"
	"RenderColorTarget=StreakMap2nd;	 Pass=Star2ndStreak1st;"
	"RenderColorTarget=StreakMap2ndTemp; Pass=Star2ndStreak2nd;"
	"RenderColorTarget=StreakMap2nd;	 Pass=Star2ndStreak3rd;"
	"RenderColorTarget=StreakMap3rd;	 Pass=Star3rdStreak1st;"
	"RenderColorTarget=StreakMap3rdTemp; Pass=Star3rdStreak2nd;"
	"RenderColorTarget=StreakMap3rd;	 Pass=Star3rdStreak3rd;"
	"RenderColorTarget=StreakMap4th;	 Pass=Star4thStreak1st;"
	"RenderColorTarget=StreakMap4thTemp; Pass=Star4thStreak2nd;"
	"RenderColorTarget=StreakMap4th;	 Pass=Star4thStreak3rd;"
#endif
	"RenderColorTarget=BloomMap1st;		Pass=GlareLightComp;"
#if HDR_FLARE_MODE
	"RenderColorTarget=BloomMap1stTemp; Pass=GhostImage1st;"
	"RenderColorTarget=BloomMap1st;		Pass=GhostImage2nd;"
#endif
#endif

#if AA_QUALITY == 0
#if POST_MOTION_BLUR_ENABLE || POST_SHARPEN_ENABLE
	"RenderColorTarget=ShadingMapTemp2; Pass=HDRTonemapping;"
#else
	"RenderColorTarget=; RenderDepthStencilTarget=; Pass=HDRTonemapping;"
#endif
#else
	"RenderColorTarget=ShadingMapTemp; Pass=HDRTonemapping;"
#endif

#if AA_QUALITY == 1
#if POST_MOTION_BLUR_ENABLE || POST_SHARPEN_ENABLE
	"RenderColorTarget=ShadingMapTemp2; Pass=FXAA;"
#else
	"RenderColorTarget=; RenderDepthStencilTarget=; Pass=FXAA;"
#endif
#endif

#if AA_QUALITY >= 2 && AA_QUALITY <= 5
	"RenderColorTarget=SMAAEdgeMap;  Clear=Color; Pass=SMAAEdgeDetection;"
	"RenderColorTarget=SMAABlendMap; Clear=Color; Pass=SMAABlendingWeightCalculation;"
#if POST_MOTION_BLUR_ENABLE || POST_SHARPEN_ENABLE
	"RenderColorTarget=ShadingMapTemp2; Pass=SMAANeighborhoodBlending;"
#else
	"RenderColorTarget=; RenderDepthStencilTarget=; Pass=SMAANeighborhoodBlending;"
#endif
#endif

#if AA_QUALITY == 6
	"RenderColorTarget0=TAAHistoryMap; RenderColorTarget1=TAADepthMap; Pass=TAAPass;"
	"RenderColorTarget1=;"
#if POST_MOTION_BLUR_ENABLE || POST_SHARPEN_ENABLE
	"RenderColorTarget=ShadingMapTemp2; Pass=TAAFinal;"
#else
	"RenderColorTarget=; RenderDepthStencilTarget=; Pass=TAAFinal;"
#endif
#endif

#if AA_QUALITY == 7
#if POST_MOTION_BLUR_ENABLE || POST_SHARPEN_ENABLE
	"RenderColorTarget=ShadingMapTemp2; Pass=GDLAAPass;"
#else
	"RenderColorTarget=; RenderDepthStencilTarget=; Pass=GDLAAPass;"
#endif
#endif

#if POST_MOTION_BLUR_ENABLE
#if POST_SHARPEN_ENABLE
	"RenderColorTarget=ShadingMapTemp; Pass=PostProcessMotionBlur;"
	"RenderColorTarget=TAAMatrixMap; Pass=TAAMatrixUpdatePass;"
	"RenderColorTarget=; RenderDepthStencilTarget=; Pass=PostProcessSharpen;"
#else
	"RenderColorTarget=; RenderDepthStencilTarget=; Pass=PostProcessMotionBlur;"
	"RenderColorTarget=TAAMatrixMap; Pass=TAAMatrixUpdatePass;"
#endif
#else
#if AA_QUALITY == 6 || (GI_ENABLE > 0)
	"RenderColorTarget=TAAMatrixMap; Pass=TAAMatrixUpdatePass;"
#endif
#if POST_SHARPEN_ENABLE
	"RenderColorTarget=; RenderDepthStencilTarget=; Pass=PostProcessSharpen;"
#endif
#endif

;>
{
#if !GI_ENABLE
#if SSDO_QUALITY && (IBL_QUALITY || SUN_LIGHT_ENABLE)
	// GI disabled: classic SSDO before shading
	pass SSDO<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 ScreenSpaceDirOccPassVS();
		PixelShader  = compile ps_3_0 ScreenSpaceDirOccPassPS();
	}
	pass SSDOBlurX<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 ScreenSpaceQuadVS();
		PixelShader  = compile ps_3_0 ScreenSpaceDirOccBlurPS(SSDOMapSamp, float2(ViewportOffset2.x, 0.0f));
	}
	pass SSDOBlurY<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 ScreenSpaceQuadVS();
		PixelShader  = compile ps_3_0 ScreenSpaceDirOccBlurPS(SSDOMapSampTemp, float2(0.0f, ViewportOffset2.y));
	}
#endif
#endif
#if SUN_LIGHT_ENABLE && SUN_SHADOW_QUALITY
	pass ShadowMapGen<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 ScreenSpaceQuadVS();
		PixelShader  = compile ps_3_0 ShadowMapGenPS();
	}
#if SUN_SHADOW_BLUR
	pass ShadowBlurX<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 ScreenSpaceQuadVS();
		PixelShader  = compile ps_3_0 ShadowMapBlurPS(ShadowMapSamp, float2(ViewportOffset2.x, 0.0f));
	}
	pass ShadowBlurY<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 ScreenSpaceQuadVS();
		PixelShader  = compile ps_3_0 ShadowMapBlurPS(ShadowMapSampTemp, float2(0.0f, ViewportOffset2.y));
	}
#endif
#endif
	pass ShadingOpacity<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 ScreenSpaceQuadVS();
		PixelShader  = compile ps_3_0 ShadingOpacityPS();
	}
	pass ShadingTransparent<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 ScreenSpaceQuadVS();
		PixelShader  = compile ps_3_0 ShadingTransparentPS();
	}
#if SSSS_QUALITY
	pass SSSSStencilTest<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		ColorWriteEnable = false;
		StencilEnable = true;
		StencilFunc = ALWAYS;
		StencilRef = 1;
		StencilPass = REPLACE;
		StencilFail = KEEP;
		StencilZFail = KEEP;
		StencilWriteMask = 1;
		VertexShader = compile vs_3_0 ScreenSpaceQuadVS();
		PixelShader  = compile ps_3_0 SSSSStencilTestPS();
	}
	pass SSSSBlurX<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		StencilEnable = true; StencilFunc = EQUAL; StencilRef = 1; StencilWriteMask = 0;
		VertexShader = compile vs_3_0 SSSGaussBlurVS();
		PixelShader  = compile ps_3_0 SSSGaussBlurPS(ShadingMapTempSamp, ShadingMapTempSamp, float2(1.0, 0.0));
	}
	pass SSSSBlurY<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		StencilEnable = true; StencilFunc = EQUAL; StencilRef = 1; StencilWriteMask = 0;
		VertexShader = compile vs_3_0 SSSGaussBlurVS();
		PixelShader  = compile ps_3_0 SSSGaussBlurPS(ShadingMapSamp, ShadingMapTempSamp, float2(0.0, 1.0));
	}
#if SSSS_TEXSPACE
	pass SSSSTexSpaceUVBlurX<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 ScreenSpaceQuadVS();
		PixelShader  = compile ps_3_0 SSSUVSpaceBlurPS(SSSUVLightMapSamp, float2(1.0, 0.0));
	}
	pass SSSSTexSpaceUVBlurY<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 ScreenSpaceQuadVS();
		PixelShader  = compile ps_3_0 SSSUVSpaceBlurPS(SSSUVLightMapSampTemp, float2(0.0, 1.0));
	}
#endif
	pass ShadingOpacityAlbedo<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = true; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		SrcBlend = DESTCOLOR; DestBlend = ZERO;
		VertexShader = compile vs_3_0 ScreenSpaceQuadVS();
		PixelShader  = compile ps_3_0 ShadingOpacityAlbedoPS();
	}
	pass ShadingOpacitySpecular<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = true; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		SrcBlend = ONE; DestBlend = ONE;
		VertexShader = compile vs_3_0 ScreenSpaceQuadVS();
		PixelShader  = compile ps_3_0 ShadingOpacitySpecularPS();
	}
#endif
#if OUTLINE_QUALITY == 2
	pass EdgeEdgeDetection<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 EdgeEdgeDetectionVS();
		PixelShader  = compile ps_3_0 EdgeLumaEdgeDetectionPS(OutlineMapSamp);
	}
	pass EdgeBlendingWeightCalculation<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 EdgeBlendingWeightCalculationVS();
		PixelShader  = compile ps_3_0 EdgeBlendingWeightCalculationPS(0.0);
	}
	pass EdgeNeighborhoodBlending<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 EdgeNeighborhoodBlendingVS();
		PixelShader  = compile ps_3_0 EdgeNeighborhoodBlendingPS(OutlineMapSamp, ViewportOffset2);
	}
#endif
#if TOON_ENABLE == 2
	pass DiffusionBlurX<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 ScreenSpaceQuadVS();
		PixelShader  = compile ps_3_0 ScreenSpaceBilateralFilterPS(ShadingMapSamp, mDiffusionOffsetX);
	}
	pass DiffusionBlurY<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = true; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		SrcBlend = SRCALPHA; DestBlend = INVSRCALPHA;
		VertexShader = compile vs_3_0 ScreenSpaceQuadVS();
		PixelShader  = compile ps_3_0 ScreenSpaceBilateralFilterPS(ShadingMapTempSamp, mDiffusionOffsetY);
	}
#endif

#if SSR_QUALITY
	pass SSR_Trace<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 ScreenSpaceQuadVS();
		PixelShader  = compile ps_3_0 SSR_TracePS();
	}
	pass SSR_BlurX1<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 ScreenSpaceQuadOffsetVS(ViewportOffset2);
		PixelShader  = compile ps_3_0 SSR_FilterBlurPS(SSRLightX1Samp, SSRBlurStepX1);
	}
	pass SSR_BlurY1<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 ScreenSpaceQuadOffsetVS(ViewportOffset2);
		PixelShader  = compile ps_3_0 SSR_FilterBlurPS(SSRLightX1SampTemp, SSRBlurStepY1);
	}
	pass SSR_BlurX2<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 ScreenSpaceQuadOffsetVS(ViewportOffset2);
		PixelShader  = compile ps_3_0 SSR_FilterBlurPS(SSRLightX1Samp, SSRBlurStepX2);
	}
	pass SSR_BlurY2<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 ScreenSpaceQuadOffsetVS(float2(0.0f, ViewportOffset2.y * 2));
		PixelShader  = compile ps_3_0 SSR_FilterBlurPS(SSRLightX2SampTemp, SSRBlurStepY2);
	}
	pass SSR_BlurX3<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 ScreenSpaceQuadOffsetVS(ViewportOffset2.x * 2);
		PixelShader  = compile ps_3_0 SSR_FilterBlurPS(SSRLightX2Samp, SSRBlurStepX3);
	}
	pass SSR_BlurY3<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 ScreenSpaceQuadOffsetVS(float2(0.0f, ViewportOffset2.y * 4));
		PixelShader  = compile ps_3_0 SSR_FilterBlurPS(SSRLightX3SampTemp, SSRBlurStepY3);
	}
	pass SSR_BlurX4<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 ScreenSpaceQuadOffsetVS(ViewportOffset2.x * 4);
		PixelShader  = compile ps_3_0 SSR_FilterBlurPS(SSRLightX3Samp, SSRBlurStepX4);
	}
	pass SSR_BlurY4<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 ScreenSpaceQuadOffsetVS(float2(0.0f, ViewportOffset2.y * 8));
		PixelShader  = compile ps_3_0 SSR_FilterBlurPS(SSRLightX4SampTemp, SSRBlurStepY4);
	}
	pass SSR_Resolve<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = true; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		SrcBlend = ONE; DestBlend = INVSRCALPHA;
		VertexShader = compile vs_3_0 ScreenSpaceQuadVS();
		PixelShader  = compile ps_3_0 SSR_ResolvePS();
	}
#endif
#if GI_ENABLE
	pass SSGI<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 ScreenSpaceQuadVS();
		PixelShader  = compile ps_3_0 SSGIPassPS();
	}
	pass SSGIPrefilter<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 ScreenSpaceQuadVS();
		PixelShader  = compile ps_3_0 SSGIOutlierRejectPS(SSGIMapSampTemp);
	}
	pass SSGIBlurX<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 ScreenSpaceQuadVS();
		PixelShader  = compile ps_3_0 SSGIBlurPS(SSGIMapSamp, 1.0f, 1.0f);
	}
	pass SSGIBlurY<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 ScreenSpaceQuadVS();
		PixelShader  = compile ps_3_0 SSGIBlurPS(SSGIMapSampTemp, 0.0f, 1.0f);
	}
	pass SSGIBlurX2<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 ScreenSpaceQuadVS();
		PixelShader  = compile ps_3_0 SSGIBlurPS(SSGIMapSamp, 1.0f, 4.0f);
	}
	pass SSGIBlurY2<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 ScreenSpaceQuadVS();
		PixelShader  = compile ps_3_0 SSGIBlurPS(SSGIMapSampTemp, 0.0f, 4.0f);
	}
	pass SSGITemporalDenoise<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 ScreenSpaceQuadVS();
		PixelShader  = compile ps_3_0 SSGITemporalPS(SSGIMapSampTemp, SSGIMapHistorySamp);
	}
	pass SSGIFinalCombine<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = true; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		SrcBlend = ONE; DestBlend = ONE;
		VertexShader = compile vs_3_0 ScreenSpaceQuadVS();
		PixelShader  = compile ps_3_0 SSGIFinalCombinePS();
	}
#if SSDO_QUALITY && (IBL_QUALITY || SUN_LIGHT_ENABLE)
	// AO pass declarations (consumed before shading/GI in the technique script)
	pass SSDO<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 ScreenSpaceDirOccPassVS();
		PixelShader  = compile ps_3_0 ScreenSpaceDirOccPassPS();
	}
	pass SSDOBlurX<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 ScreenSpaceQuadVS();
		PixelShader  = compile ps_3_0 ScreenSpaceDirOccBlurPS(SSDOMapSamp, float2(ViewportOffset2.x, 0.0f));
	}
	pass SSDOBlurY<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 ScreenSpaceQuadVS();
		PixelShader  = compile ps_3_0 ScreenSpaceDirOccBlurPS(SSDOMapSampTemp, float2(0.0f, ViewportOffset2.y));
	}
#endif
#endif
#if BOKEH_MODE == 1
	pass ComputeFocalDistance<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 ScreenSpaceQuadVS();
		PixelShader  = compile ps_3_0 ComputeFocalDistancePS();
	}
	pass ComputeBokehKernel<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 ScreenSpaceQuadVS();
		PixelShader  = compile ps_3_0 ComputeBokehKernelPS();
	}
	pass ComputeBokehWeight<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 ComputeBokehWeightVS();
		PixelShader  = compile ps_3_0 ComputeBokehWeightPS();
	}
	pass ComputeBokehNearPrefilter<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 ScreenSpaceQuadVS();
		PixelShader  = compile ps_3_0 ComputeBokehPrefilterPS(ShadingMapPointSamp, _FocalCoCMap_TexelSize, -1.0f);
	}
	pass ComputeBokehFarPrefilter<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 ScreenSpaceQuadVS();
		PixelShader  = compile ps_3_0 ComputeBokehPrefilterPS(ShadingMapPointSamp, _FocalCoCMap_TexelSize, 1.0f);
	}
	pass ComputeBokehFar<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 ScreenSpaceQuadOffsetVS(_FocalBokehMap_TexelSize.xy);
		PixelShader  = compile ps_3_0 ComputeBokehFarPS(FocalBokehMapPointSamp, FocalBokehMapLinearSamp, _FocalBokehMap_TexelSize);
	}
	pass ComputeBokehNear<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 ScreenSpaceQuadOffsetVS(_FocalBokehMap_TexelSize.xy);
		PixelShader  = compile ps_3_0 ComputeBokehNearPS(FocalBokehMapPointSamp, FocalBokehMapLinearSamp, _FocalBokehMap_TexelSize);
	}
	pass ComputeBilinearBlur<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 ScreenSpaceQuadOffsetVS(_FocalBokehMap_TexelSize.xy);
		PixelShader  = compile ps_3_0 ComputeBilinearBlurPS(FocalBokehNearMapLinearSamp, _FocalBokehMap_TexelSize);
	}
	pass ComputeBokehFinal<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = true; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		DestBlend = INVSRCALPHA; SrcBlend = SRCALPHA;
		VertexShader = compile vs_3_0 ScreenSpaceQuadOffsetVS(float2(0.0f, 0.0f));
		PixelShader  = compile ps_3_0 ComputeBokehFinalPS();
	}
#elif BOKEH_MODE == 2
	pass ComputeFocalDistance<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 ScreenSpaceQuadVS();
		PixelShader  = compile ps_3_0 ComputeFocalDistancePS();
	}
	pass ComputeBokehWeight<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 ComputeBokehWeightVS();
		PixelShader  = compile ps_3_0 ComputeBokehWeightPS();
	}
	pass ComputeBokehNearPrefilter<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 ScreenSpaceQuadVS();
		PixelShader  = compile ps_3_0 ComputeBokehPrefilterPS(ShadingMapPointSamp, _FocalCoCMap_TexelSize, -1.0f);
	}
	pass ComputeBokehFarPrefilter<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 ScreenSpaceQuadVS();
		PixelShader  = compile ps_3_0 ComputeBokehPrefilterPS(ShadingMapPointSamp, _FocalCoCMap_TexelSize, 1.0f);
	}
	pass ComputeHexagonalBlurX<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 ComputeHexagonalBlurXVS(_FocalBokehMap_TexelSize);
		PixelShader  = compile ps_3_0 ComputeHexagonalBlurXPS(FocalBokehMapLinearSamp, _FocalBokehMap_TexelSize);
	}
	pass ComputeHexagonalBlurY<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 ComputeHexagonalBlurYVS(_FocalBokehMap_TexelSize);
		PixelShader  = compile ps_3_0 ComputeHexagonalBlurYPS(FocalBlur1MapLinearSamp, FocalBlur2MapLinearSamp, _FocalBokehMap_TexelSize);
	}
	pass ComputeBokehBlur<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 ScreenSpaceQuadOffsetVS(_FocalBokehMap_TexelSize.xy);
		PixelShader  = compile ps_3_0 ComputeBokehBlurPS(FocalBokehMapPointSamp, FocalBokehMapLinearSamp, _FocalBokehMap_TexelSize);
	}
	pass ComputeBilinearBlur<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 ScreenSpaceQuadOffsetVS(_FocalBokehMap_TexelSize.xy);
		PixelShader  = compile ps_3_0 ComputeBilinearBlurPS(FocalBlur2MapLinearSamp, _FocalBokehMap_TexelSize);
	}
	pass ComputeBokehFinal<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = true; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		DestBlend = INVSRCALPHA; SrcBlend = SRCALPHA;
		VertexShader = compile vs_3_0 ScreenSpaceQuadOffsetVS(float2(0.0f, 0.0f));
		PixelShader  = compile ps_3_0 ComputeBokehFinalPS();
	}
#endif
#if HDR_EYE_ADAPTATION
	pass EyeLum<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 EyeDownsampleVS(ViewportOffset2);
		PixelShader  = compile ps_3_0 EyeDownsamplePS(ShadingMapPointSamp);
	}
	pass EyeAdapation<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 ScreenSpaceQuadVS();
		PixelShader  = compile ps_3_0 EyeAdapationPS();
	}
#endif
#if HDR_BLOOM_MODE
	pass GlareDetection<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 GlareDetectionVS();
		PixelShader  = compile ps_3_0 GlareDetectionPS(ShadingMapPointSamp);
	}
#if HDR_STAR_MODE || HDR_FLARE_MODE
	pass HDRDownsample2nd<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 HDRDownsampleVS(ViewportOffset2 * 2);
		PixelShader  = compile ps_3_0 HDRDownsample4XPS(DownsampleSamp1st);
	}
#endif
	pass BloomBlurX1<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 ScreenSpaceQuadOffsetVS(BloomOffset1);
		PixelShader  = compile ps_3_0 BloomBlurPS(DownsampleSamp1st, BloomOffsetX1);
	}
	pass BloomBlurY1<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 ScreenSpaceQuadOffsetVS(BloomOffset1);
		PixelShader  = compile ps_3_0 BloomBlurPS(BloomSamp1stTemp, BloomOffsetY1);
	}
	pass BloomDownsampleX2<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 HDRDownsampleVS(BloomOffset1);
		PixelShader  = compile ps_3_0 HDRDownsamplePS(BloomSamp1st, BloomOffset1);
	}
	pass BloomBlurX2<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 ScreenSpaceQuadOffsetVS(BloomOffset2);
		PixelShader  = compile ps_3_0 BloomBlurPS(BloomSamp2nd, BloomOffsetX2);
	}
	pass BloomBlurY2<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 ScreenSpaceQuadOffsetVS(BloomOffset2);
		PixelShader  = compile ps_3_0 BloomBlurPS(BloomSamp2ndTemp, BloomOffsetY2);
	}
	pass BloomDownsampleX3<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 HDRDownsampleVS(BloomOffset2);
		PixelShader  = compile ps_3_0 HDRDownsamplePS(BloomSamp2nd, BloomOffset2);
	}
	pass BloomBlurX3<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 ScreenSpaceQuadOffsetVS(BloomOffset3);
		PixelShader  = compile ps_3_0 BloomBlurPS(BloomSamp3rd, BloomOffsetX3);
	}
	pass BloomBlurY3<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 ScreenSpaceQuadOffsetVS(BloomOffset3);
		PixelShader  = compile ps_3_0 BloomBlurPS(BloomSamp3rdTemp, BloomOffsetY3);
	}
	pass BloomDownsampleX4<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 HDRDownsampleVS(BloomOffset3);
		PixelShader  = compile ps_3_0 HDRDownsamplePS(BloomSamp3rd, BloomOffset3);
	}
	pass BloomBlurX4<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 ScreenSpaceQuadOffsetVS(BloomOffset4);
		PixelShader  = compile ps_3_0 BloomBlurPS(BloomSamp4th, BloomOffsetX4);
	}
	pass BloomBlurY4<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 ScreenSpaceQuadOffsetVS(BloomOffset4);
		PixelShader  = compile ps_3_0 BloomBlurPS(BloomSamp4thTemp, BloomOffsetY4);
	}
	pass BloomDownsampleX5<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 HDRDownsampleVS(BloomOffset4);
		PixelShader  = compile ps_3_0 HDRDownsamplePS(BloomSamp4th, BloomOffset4);
	}
	pass BloomBlurX5<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 ScreenSpaceQuadOffsetVS(BloomOffset5);
		PixelShader  = compile ps_3_0 BloomBlurPS(BloomSamp5th, BloomOffsetX5);
	}
	pass BloomBlurY5<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 ScreenSpaceQuadOffsetVS(BloomOffset5);
		PixelShader  = compile ps_3_0 BloomBlurPS(BloomSamp5thTemp, BloomOffsetY5);
	}
#if HDR_STAR_MODE == 1 || HDR_STAR_MODE == 2
	pass Star1stStreak1st<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 StarStreakVS(float2(0.9, 0), 1);
		PixelShader  = compile ps_3_0 StarStreakPS(DownsampleSamp2nd, star_colorCoeff1st, mBloomStarFade);
	}
	pass Star1stStreak2nd<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 StarStreakVS(float2(0.9, 0), 4);
		PixelShader  = compile ps_3_0 StarStreakPS(StreakSamp1stTemp, star_colorCoeff2nd, 0);
	}
	pass Star1stStreak3rd<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 StarStreakVS(float2(0.9, 0), 16);
		PixelShader  = compile ps_3_0 StarStreakPS(StreakSamp1st, star_colorCoeff3rd, 0);
	}
	pass Star1stStreak4th<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 StarStreakVS(float2(0.9, 0), 64);
		PixelShader  = compile ps_3_0 StarStreakPS(StreakSamp1stTemp, star_colorCoeff4th, 0);
	}
	pass Star2ndStreak1st<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 StarStreakVS(float2(-0.9, 0), 1);
		PixelShader  = compile ps_3_0 StarStreakPS(DownsampleSamp2nd, star_colorCoeff1st, mBloomStarFade);
	}
	pass Star2ndStreak2nd<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 StarStreakVS(float2(-0.9, 0), 4);
		PixelShader  = compile ps_3_0 StarStreakPS(StreakSamp2ndTemp, star_colorCoeff2nd, 0);
	}
	pass Star2ndStreak3rd<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 StarStreakVS(float2(-0.9, 0), 16);
		PixelShader  = compile ps_3_0 StarStreakPS(StreakSamp2nd, star_colorCoeff3rd, 0);
	}
	pass Star2ndStreak4th<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 StarStreakVS(float2(-0.9, 0), 64);
		PixelShader  = compile ps_3_0 StarStreakPS(StreakSamp2ndTemp, star_colorCoeff4th, 0);
	}
#endif
#if HDR_STAR_MODE == 3 || HDR_STAR_MODE == 4
	pass Star1stStreak1st<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 StarStreakVS(float2(0.9, 0.9), 1);
		PixelShader  = compile ps_3_0 StarStreakPS(DownsampleSamp2nd, star_colorCoeff1st, mBloomStarFade);
	}
	pass Star1stStreak2nd<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 StarStreakVS(float2(0.9, 0.9), 4);
		PixelShader  = compile ps_3_0 StarStreakPS(StreakSamp1st, star_colorCoeff2nd, 0);
	}
	pass Star1stStreak3rd<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 StarStreakVS(float2(0.9, 0.9), 16);
		PixelShader  = compile ps_3_0 StarStreakPS(StreakSamp1stTemp, star_colorCoeff3rd, 0);
	}
	pass Star2ndStreak1st<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 StarStreakVS(float2(-0.9, 0.9), 1);
		PixelShader  = compile ps_3_0 StarStreakPS(DownsampleSamp2nd, star_colorCoeff1st, mBloomStarFade);
	}
	pass Star2ndStreak2nd<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 StarStreakVS(float2(-0.9, 0.9), 4);
		PixelShader  = compile ps_3_0 StarStreakPS(StreakSamp2nd, star_colorCoeff2nd, 0);
	}
	pass Star2ndStreak3rd<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 StarStreakVS(float2(-0.9, 0.9), 16);
		PixelShader  = compile ps_3_0 StarStreakPS(StreakSamp2ndTemp, star_colorCoeff3rd, 0);
	}
	pass Star3rdStreak1st<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 StarStreakVS(float2(0.9, -0.9), 1);
		PixelShader  = compile ps_3_0 StarStreakPS(DownsampleSamp2nd, star_colorCoeff1st, mBloomStarFade);
	}
	pass Star3rdStreak2nd<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 StarStreakVS(float2(0.9, -0.9), 4);
		PixelShader  = compile ps_3_0 StarStreakPS(StreakSamp3rd, star_colorCoeff2nd, 0);
	}
	pass Star3rdStreak3rd<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 StarStreakVS(float2(0.9, -0.9), 16);
		PixelShader  = compile ps_3_0 StarStreakPS(StreakSamp3rdTemp, star_colorCoeff3rd, 0);
	}
	pass Star4thStreak1st<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 StarStreakVS(float2(-0.9, -0.9), 1);
		PixelShader  = compile ps_3_0 StarStreakPS(DownsampleSamp2nd, star_colorCoeff1st, mBloomStarFade);
	}
	pass Star4thStreak2nd<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 StarStreakVS(float2(-0.9, -0.9), 4);
		PixelShader  = compile ps_3_0 StarStreakPS(StreakSamp4th, star_colorCoeff2nd, 0);
	}
	pass Star4thStreak3rd<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 StarStreakVS(float2(-0.9, -0.9), 16);
		PixelShader  = compile ps_3_0 StarStreakPS(StreakSamp4thTemp, star_colorCoeff3rd, 0);
	}
#endif
#if HDR_FLARE_MODE
	pass GhostImage1st<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 GhostImageVS(ghost_scalar1st);
		PixelShader  = compile ps_3_0 GhostImagePS(DownsampleSamp2nd, BloomSamp2nd, BloomSamp2nd, ghost_modulation1st, mBloomStarFade);
	}
	pass GhostImage2nd<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = true; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		SrcBlend = ONE; DestBlend = ONE;
		VertexShader = compile vs_3_0 GhostImageVS(ghost_scalar2nd);
		PixelShader  = compile ps_3_0 GhostImagePS(BloomSamp1stTemp, BloomSamp1stTemp, BloomSamp2nd, ghost_modulation2nd, 0);
	}
#endif
	pass GlareLightComp<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = true; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		SrcBlend = ONE; DestBlend = SRCALPHA;
		VertexShader = compile vs_3_0 GlareLightCompVS();
		PixelShader  = compile ps_3_0 GlareLightCompPS();
	}
#endif
	pass HDRTonemapping<string Script= "Draw=Buffer;";>{
		 AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 HDRTonemappingVS();
		PixelShader  = compile ps_3_0 HDRTonemappingPS(ShadingMapPointSamp);
	}
#if AA_QUALITY == 1
	pass FXAA<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 ScreenSpaceQuadVS();
		PixelShader  = compile ps_3_0 FXAA3(ShadingMapTempSamp, ViewportOffset2);
	}
#endif
#if AA_QUALITY >= 2 && AA_QUALITY <= 5
	pass SMAAEdgeDetection<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 SMAAEdgeDetectionVS();
		PixelShader  = compile ps_3_0 SMAAColorEdgeDetectionPS(ShadingMapTempPointSamp);
	}
	pass SMAABlendingWeightCalculation<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 SMAABlendingWeightCalculationVS();
		PixelShader  = compile ps_3_0 SMAABlendingWeightCalculationPS(0.0);
	}
	pass SMAANeighborhoodBlending<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 SMAANeighborhoodBlendingVS();
		PixelShader  = compile ps_3_0 SMAANeighborhoodBlendingPS(ShadingMapTempSamp, true);
	}
#endif
#if AA_QUALITY == 6
	pass TAAPass<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 ScreenSpaceQuadVS();
		PixelShader  = compile ps_3_0 TAAPS(ShadingMapTempSamp);
	}
#endif
#if AA_QUALITY == 6 || POST_MOTION_BLUR_ENABLE || (GI_ENABLE > 0)
	pass TAAMatrixUpdatePass<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 ScreenSpaceQuadVS();
		PixelShader  = compile ps_3_0 TAAMatrixUpdatePS();
	}
#endif
#if POST_MOTION_BLUR_ENABLE
	// Input is always the AA/tonemap output in ShadingMapTemp2 (clean ping-pong:
	// the upstream "single consumer writes into the buffer it samples" case is gone)
	pass PostProcessMotionBlur<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 ScreenSpaceQuadVS();
		PixelShader  = compile ps_3_0 PostProcessMotionBlurPS(ShadingMapTemp2Samp);
	}
#endif
#if AA_QUALITY == 6
	pass TAAFinal<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 ScreenSpaceQuadVS();
		PixelShader  = compile ps_3_0 TAAFinalPS();
	}
#endif
#if AA_QUALITY == 7
	pass GDLAAPass<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 ScreenSpaceQuadVS();
		PixelShader  = compile ps_3_0 GDLAA_PS(ShadingMapTempSamp, ViewportOffset2);
	}
#endif
#if POST_SHARPEN_ENABLE
	pass PostProcessSharpen<string Script= "Draw=Buffer;";>{
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 ScreenSpaceQuadVS();
#if POST_MOTION_BLUR_ENABLE
		PixelShader  = compile ps_3_0 PostProcessSharpenPS(ShadingMapTempSamp, ViewportOffset2);
#else
		PixelShader  = compile ps_3_0 PostProcessSharpenPS(ShadingMapTemp2Samp, ViewportOffset2);
#endif
	}
#endif
}

