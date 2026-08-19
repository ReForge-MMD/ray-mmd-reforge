#define LIGHT_PARAMS_TYPE 0

static float3 lightRangeParams = float3(100.0, 0.0, 200.0);
static float3 lightIntensityParams = float3(100, 0.0, 2000.0);
static float3 lightAttenuationBulbParams = float3(1.0, 0.0, 5.0);

#define SHADOW_MAP_FROM 1
#define SHADOW_MAP_QUALITY 2

static float2 shadowHardness = float2(0.15, 0.5);

// NOTICE : DO NOT MODIFY IT IF YOU CANT'T UNDERSTAND WHAT IT IS
static float sampleRadius = 3;
static float sampleKernel[7] = {0.071303, 0.131514, 0.189879, 0.214607, 0.189879, 0.131514, 0.071303};

#include "../disk_lighting.fxsub"