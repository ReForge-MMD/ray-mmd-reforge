#define SSR_SELF_VISIBILITY_ENABLE 1

static const float selfVisibility = 0.0; // SSR self-reflection suppression (1.0 = never self-bounce)

#include "../shader/SSR/SSRSelfVisibility.fxsub"
