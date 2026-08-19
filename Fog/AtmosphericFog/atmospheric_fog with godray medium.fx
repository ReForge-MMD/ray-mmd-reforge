// ignore sky fog
#define FOG_DISCARD_SKY 0

#define FOG_WITH_GODRAY 1
#define FOG_WITH_GODRAY_SAMPLES 48

static float FogSampleLength = 0.7f;

// R : default value
// G : min value for Slider Bar
// B : max value for Slider Bar
static float3 FogRangeParams = float3(1.0, 1e-2, 20.0f);
static float3 FogIntensityParams = float3(1.0, 0.1, 10.0f);
static float3 FogDensityParams = float3(100, 1, 5000);
static float3 FogMiePhaseParams = float3(0.76, 0.1, 0.98);
static float3 FogMieTurbidityParams = float3(100, 1, 1000);

static float3 mWaveLength = float3(670e-9,620e-9,580e-9);

#include "atmospheric_fog.fxsub"