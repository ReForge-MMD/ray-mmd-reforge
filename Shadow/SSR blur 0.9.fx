#define SSR_BLUR_ENABLE 1
#define SSR_BLUR_ALPHA_ENABLE 1
#define SSR_BLUR_ALPHA_MAP_ENABLE 1

static const float blurAmount = 0.9; // SSR receiver blur boost (0.0 = base PBR, 1.0 = full diffuse blur)

#include "../shader/SSR/SSRBlur.fxsub"
