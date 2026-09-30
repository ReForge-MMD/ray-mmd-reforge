Ray-MMD Reforge
========
### Heavyweight graphics. Reforged for perfection. ###
<div align="center">
  <img src="./Shader/screenshots/logo.png" alt="logo" width="600">
</div>

　　**Ray-MMD Reforge** is a modified fork of the original Ray-MMD library for [mikumikudance](http://www.geocities.jp/higuchuu4/index_e.htm).
　　Focused on bridging realistic lighting with stylized rendering, Reforge rebuilds the engine pipeline around direct, high-precision screen-space raymarching and ultrafast root-finding algorithms. On top of it sit modern graphics techniques: **Temporal Anti-Aliasing (TAA)**, **Screen Space Global Illumination (SSGI)**, **Hybrid HBAO/SSDO**, and the **AgX tone mapper** — for a stable, physically grounded image out of the box.

Screenshots:
------------
> *Note: These are legacy screenshots from the original Ray-MMD. New showcases demonstrating SSGI, HBAO/SSDO, and TAA are coming soon!*

[![link text](./Shader/screenshots/screen1_small.jpg)](https://raw.githubusercontent.com/ray-cast/ray-mmd/master/Shader/screenshots/screen1.jpg)
[![link text](./Shader/screenshots/screen2_small.png)](https://raw.githubusercontent.com/ray-cast/ray-mmd/master/Shader/screenshots/screen2.png)
[![link text](./Shader/screenshots/screen3_small.jpg)](https://raw.githubusercontent.com/ray-cast/ray-mmd/master/Shader/screenshots/screen3.png)
[![link text](./Shader/screenshots/screen4_small.jpg)](https://raw.githubusercontent.com/ray-cast/ray-mmd/master/Shader/screenshots/screen4.png)

Requirement :
------------
* [MikuMikuDance](http://www.geocities.jp/higuchuu4/index_e.htm) - 926ver (x64) (Without Anti-Aliasing)
* [MikuMikuEffect](https://bowlroll.net/file/35012) - 037ver (x64)
* Direct3D 9 With Shader Model 3.0 (ps_3_0)
* **Powerful GPU recommended** due to advanced shading techniques.

Reforge Exclusive Features (through v1.20.22) :
------------

**Direct Screen-Space Core**
* **Direct 1:1 Screen-Space Architecture**: eliminated the heavy hierarchical depth pyramid (Hi-Z) from both the deferred core and SSR pipeline, freeing all pyramid RenderTarget textures in VRAM and removing downsampling passes in favor of direct G-buffer raymarching, SIMD-vectorized SSR marching, 2D DDA, and Newton root-finding.
* **Octahedral Normal Encoding**: compact and high-precision octahedral representation for unit normal vectors in G-buffer and math pipelines.

**Global Illumination (SSPT / RTGI & SSGI 3.0)**
* **Screen-Space Path Tracing (SSPT / RTGI 3.0 - `GI_ENABLE 3`, Default)**: next-generation path-traced room radiance engine inspired by Marty McFly's qUINT RTGI. Implements low-discrepancy Monte Carlo cosine-weighted hemisphere path tracing with golden angle rotation (`SSPT_GOLDEN_ANGLE = 2.39996323`), 1D Bayer dither stratification, and projected-axis orthonormal tangent frame (`BuildTangentMatrix`).
* **Static Frozen Ray Dithering & À-Trous Spatial Denoising**: per-pixel dither pattern is frozen across frames (no temporal flicker), so all stochastic noise is fully absorbed by the bilateral blur chain — GI output is clean without any temporal accumulation, history buffers, or ghost-trail risk.
* **Progressive Quadratic Ray Stepping & Depth Thickness Gating**: dense near-field precision with broad room reach (`lambda = s * sqrt(s)`), analytical depth thickness gating (`delta = (pSample - pRay) * invThickness`) preventing light leaking through walls, fingers, and hair.
* **Secondary Bounce Feedback & Viewport-Boundary Radiance**: multi-bounce reflection feedback loop (`SSPT_BOUNCES 1`) with emissive transfer and escaped-ray sky radiance sampling preventing dark camera-edge halos.
* **Deferred Ambient Occlusion Post-GI Composite**: deferred SSDO execution and introduced a dedicated post-GI pass (`Shader/PostProcessAOComposite.fxsub`) running after `SSGIFinalCombine`. Uniformly applies Jimenez multi-bounce AO across total composited radiance (direct + IBL + GI), preventing strong indirect bounces from bleaching contact shadows and crevices while preserving clean glass and emissive passthrough.
* **Direct Solar Shadow Retention & Sky Radiance Calibration**: direct shadow gating (`SSPT_SHADOW_RETENTION 0.60`) in SSPT and SSGI resolves scaling indirect bounce against `ShadowMapSamp` via a quadratic penumbra response curve, keeping cast shadows deep and distinct without losing rich color bleeding. Replaced hardcoded unoccluded ray sky radiance with tunable `SSPT_SKY_LIGHT_AMOUNT 0.05` in `SSPT_Trace.fxsub`.
* **Albedo-Driven Dynamic Skin Multi-Bounce & Linearized Cavity AO**: dynamic albedo interreflection curve (`1.0 + (mat.albedo * 2.2) / max(...)`) and softened linear cavity AO in SSPT/SSGI resolves, eliminating skin darkening and crushing in deep shadows.
* **Dielectric Glass Resolve Bypass & Raymarch Transmission**: early-exit zero diffuse GI combine on `SHADINGMODELID_GLASS` preventing milky/matte fogging, and raymarch hit skipping (`continue`) allowing rays to transmit through glass without false bounce or artificial shadows.
* **SSGI 3.0 (`GI_ENABLE 1 / 2`)**: Duff (2017) branchless orthonormal basis, stratified Halton (2, 3) sampling, per-pixel IGN rotation, analytical screen-edge clipping (`ClipRayToScreenEdge`), and early thickness evaluation.
* **Dyadic À-Trous Cross-Bilateral Denoising**: two-pass edge-preserving filter with $5 \times 5$ Karis 0.20 outlier rejection, `[loop]` SM 3.0 instruction optimization, and tangent-plane distance weights (`BilateralPlaneWeight`).
* **Unified Quality Presets (`GI_QUALITY 1..4`)**: shared presets across SSGI and SSPT from Low (12 steps / 4 rays) to Cinematic (16 steps / 16 rays).
* **Rough Specular GI (`SSGI_SPECULAR_GI 1`)**: Fresnel-weighted indirect specular reflections on rough surfaces, with calibrated subtle sheen on skin (`0.25f`).

**Reflections & Occlusion**
* **Vectorized Screen-Space Reflections (SIMD SSRT)**: SSR ray tracing consolidated into a high-performance vectorized linear ray marching core (`Shader/SSR/SSR_Trace.fxsub`) using SIMD 4-sample texture batching, dynamic slope-based tolerance scaling with depth rate-of-change, and direct hit-tap binding to prevent silhouette overshoots and teeth. Reflections feature screen-space border clipping, smooth confidence weighting (grazing-angle, travel distance, far-depth fade, facing tests), and NaN/Inf rejection on FP16 buffers. Includes real-time diagnostic visualization via `SSR_DEBUG` and `SSRDebugController.pmx` (modes: Trace hit/miss/budget, Confidence, Distance, Normal, Roughness).
* **Per-Material Reflection Mask System (4 dedicated MME tabs)**: `SSRMap` (receiver — how much a surface reflects), `SSRReflectMap` (source — how strongly a surface appears in other surfaces' reflections, `Shadow/SSR reflect visibility 0.0–1.0.fx`), `SSRSelfMap` (self-suppression — flagged materials never bounce SSR between each other, `Shadow/SSR self visibility 0.0–1.0.fx`), and `SSRBlurMap` (receiver blur mask — selective roughness boost per subset/material, `Shadow/SSR blur 0.0–1.0.fx`). All masks are preset-driven constants with nothing clipped, work on additive/semi-transparent materials, and never conflict across tabs.
* **Material-Driven SSR Roughness**: SSR blur now follows each material's own smoothness (smoothness maps / MMD shininess) via a perceptual `pow(roughness, 1.5)` pyramid-LOD mapping, consistent with the IBL specular response; global gloss bias tunable via `mSSRSmoothnessDefault` in `ray_advanced.conf`.
* **Stabilized Thin & Curved Glass Refraction**: view-space normal-tilt screen-space offset eliminating planar background object duplication on flat windows, physical thin-glass default (`customA = 0.5`), balanced chromatic dispersion, deflection clamping, and Newton's method 3D root-finding (Mayer et al. 2026).
* **Top-Down Sky Visibility & Heightfield Macro AO**: Snowdrop Engine (GDC 2016) directional horizon search and cone-tracing macro ambient occlusion preventing outdoor skylight and ambient IBL from leaking into covered spaces, under canopies, bridges, roofs, and doorways. Controlled via dedicated `SkyVisibilityController.pmx`.
* **Ground-Truth Ambient Occlusion (GTAO / GTSO)**: reference XeGTAO cosine horizon integration, Jimenez multi-bounce approximation, temporal history stabilization, and directional bent normals.
* **Hybrid HBAO / SSDO**: horizon-based and directional occlusion for accurate contact shading.
* **Contact Shadows**: screen-space contact shadows with depth-discontinuity artifact fixes and continuous penetration-based penumbra.

**Lighting & Shadows**
* **Variance Shadow Maps (VSM)**: moment-filtered cascaded directional sun shadows using Chebyshev's inequality (Donnelly & Lauritzen 2006) with hardware moment filtering, seamless cascade blending, and tunable light bleeding reduction.
* **Directional Water Caustics**: real-time focused underwater light bands and wave curvature flux concentration with chromatic dispersion and a dedicated controller (`CausticsController.pmx`).
* **Screen-Space Global Shadows (SSGS)**: long-range directional raymarched shadows with distance-adaptive soft penumbra expansion, grounding characters and geometry without shadow map dependence.
* **Volumetric Atmosphere & Dynamic Clouds 2.0**: SA_DirectX 3.0 cumulus cloudscapes with Frostbite/Nubis lighting, Beer-Powder scattering, Silver Lining, planetary horizon curvature, and **Adaptive Empty Space Skipping** (2.25x stride with 0.75x boundary refinement) for high-framerate rendering in clear sky regions without edge slicing or visual quality loss.

**Materials & BRDF**
* **Energy-Preserving Oren-Nayar (EON) BRDF**: exact Portsmouth, Kutz & Hill (JCGT 2025) diffuse model preserving energy across all roughness levels.
* **Unified UE Artist Skin SSS Toolchain**: WrappedDiffuse (`w=1/3, n=1.5`), AO-scaled BackScatter, view-dependent InScatter, Beer-Lambert transmission with HSV hue shift, Henyey-Greenstein backlit forward glow (`SubsurfaceShadingBacklitGlow`), and explicit sRGB transmittance authoring.
* **Texture-Space SSS Diffusion (`SSSS_TEXSPACE 1`)**: camera distance-invariant model UV-space irradiance convolution with Christensen-Burley profile, eliminating screen-space silhouette haloing and hair light bleeding.
* **ClearCoat Analytical Refraction & Beer-Lambert Absorption**: Snell refraction angle deflection (`RefractBlendClearCoatApprox`) and thin-layer Beer-Lambert optical transmission through clearcoat without tracing secondary rays.
* **Two-Sided Wrapped Diffuse Transmission**: Steve McAuley (2011) energy-conserving backlit translucency for foliage, leaves, paper, petals, and thin cloth (`SubsurfaceShadingTwoSided`).
* **Analytical Eye Iris Caustic Highlight**: Jimenez (2014) focused iris caustic model for anime and realistic eyes (`EyeIrisCaustic`).
* **Optimized Dual-Lobe Skin Specular & Burley Hair Specular**: single-pass Smith visibility and Fresnel evaluation for dual-profile skin, and Burley energy-preserving aspect ratio parameterization for anisotropic hair highlights without flickering.
* **Band-Limited Hashed Alpha Hair Cutout & Dedicated `_realistic` Presets**: Dave Hoskins `Hash31` without trigonometric precision loss, band-limited boundary stippling (`[ALPHA_THRESHOLD ± 0.12]`) with 100% solid grain-free interior (`alpha >= 0.62`), pass synchronization with SSSS protection, and 40 dedicated `*_realistic.fx` presets across the hair library.
* **Expanded 48-Preset Material Library**: comprehensive PBR and Toon material suites across Architecture, Cloth, Nature, and Sci-Fi.
* **Procedural Eye Cornea Parallax & Micro-Glitter**: true refractive cornea dome with iris parallax depth mapping (`material_eye_anime.fx`) and multi-layer procedural micro-glitter sparkle presets (`material_glitter.fx`).
* **Procedural Foliage Wind Engine**: vertex wind animation engine with four vegetation presets.
* **Practical Real-Time Hex-Tiling**: stochastic equilateral triangle lattice tiling (Mikkelsen 2022) with slope-weighted normal blending, luminance contrast adjustment, height-blended displacement, and distance-adaptive LOD fade.
* **Detail Normal Maps & Micro-Surface Layering**: distance-faded micro-surface normal overlay composited via Reoriented Normal Mapping (RNM).
* **Authorable Shading Knobs**: `SPEC_LIGHT_SIN_ALPHA` (SphereMaxNoH softening), `BRDF_FRESNEL_TYPE 1` (Adobe F82), `BRDF_CLOTH_VIS_CHARLIE 1` (Estevez & Kulla exponential fit), `SKIN_AO_STRENGTH 0.50`, `SKIN_GI_REFLECTANCE_LIGHT 0.68f`, and `SKIN_SSS_MFP_SCALE`.

**Post-Processing & Anti-Aliasing**
* **SMAA Ultra+ (`AA_QUALITY 5`, Default)**: native 1x Ultra pipeline, G-Buffer linear depth predication (`Gbuffer8Map`) resolving fine hair tips and accessory silhouettes, dual-axis bilinear sample weights eliminating diagonal staircasing, subpixel micro-feature reconstruction (`0.65f`), and 12-sample FXAA Preset 12 HQ.
* **Modular PMX Controller Suite**: fully decentralized domain-specific controllers replacing the monolithic legacy `ray_controller.pmx`:
  * `LightingController.pmx`: dedicated lighting & shadow control (`SunLight+/-`, `MultiLight+/-`, `SSAO+/-`, `SSAORadius+/-`, `SSDO+/-`, `SSSS+/-`, `SSGI+/-`).
  * `CameraController.pmx`: physical lens DOF (aperture `Fstop+/-`, `FocalLength+/-`, `FocalDistance+/-`, `FocalRegion+/-`, iris `BladeCount-`), lens optical artifacts (`Vignette`, `Dispersion`, `DispersionRadius`), and focus calibration modes (`TestMode`, `MeasureMode`).
  * `BloomController.pmx`: HDR bloom threshold, radius, HSV tint (`BloomColorAllH/S/V`), and star diffraction burst (`BloomStarFade`).
  * `ColorGradingController.pmx`: 60-morph studio color grading suite (Lift/Gamma/Gain, 2D white balance, creative film presets, exposure).
  * `SkyVisibilityController.pmx`: bent-normal celestial sky occlusion.
  * `CausticsController.pmx`: real-time directional water caustics wave simulation.
  * `DebugController.pmx`: real-time G-buffer, shadow cascade, and SSGS inspection.
  * *Streamlined Architecture*: the bloated monolithic `ray_controller.pmx` has been completely decommissioned and replaced by clean, focused, high-performance specialized controllers.
* **Studio Color Grading Engine & Dedicated Controller (`ColorGradingController.pmx`)**: built-in linear HDR 3-way split-toning (Lift/Gamma/Gain for Shadows, Midtones, and Highlights) with perceptual Naka-Rushton luma partitioning, 2D white balance (Correlated Color Temperature + Green/Magenta Tint), smart skin-preserving Vibrance, branchless 3D Rodrigues Hue rotation, and cinematic creative presets (Teal & Orange, Bleach Bypass, Cross Process, Monochrome) controlled via a dedicated 60-morph PMX controller.
* **G-DLAA Anti-Aliasing**: hybrid geometric and directionally adaptive anti-aliasing (`AA_QUALITY 7`) preserving sharp silhouette edges.
* **Temporal Anti-Aliasing (TAA)**: 5-tap Catmull-Rom bicubic history reconstruction, Karis luma weighting, variance clipping, and depth-validated history.
* **AgX Tone Mapping**: exact 6th-order polynomial implementation of the official Blender 4.0 AgX mapper (default), with an ACES-fitted option.
* **Camera & Object Motion Blur**: cinematic screen-space velocity motion blur reconstructed from camera view-projection history and animated mesh velocity maps with isotropic screen-unit clamping.
* **CineStill 800T Multi-Scale Halation & Spectral Bloom**: physical radial wavelength dispersion and multi-octave red-amber emulsion highlight bleed simulating real 35mm film base back-scattering (`FILMIC_HALATION_MODE 2`).
* **Cinematic Bokeh DOF**: hexagonal and cinematic bokeh with Cat's Eye optical mechanical vignetting deformation.
* **Anti-Firefly Bloom & FidelityFX CAS**: Karis 13-tap downsampling filter and AMD FidelityFX Contrast Adaptive Sharpening.
* **Core Engine Performance Optimizations**: hoisted matrix projections in contact shadows, XeGTAO square-root horizon identity, point/spot light distance clipping, pre-scaled Vogel-disk PCF rotation, SSGI/SSPT rsqrt ray steps, and Gerstner wave Hessian constant precomputations.
* **Clean AA Tail Ping-Pong**: single-consumer pipelines routed through `ShadingMapTemp2` to eliminate D3D9 feedback loops, with HDR `A16B16G16R16F` TAA accumulator.

**Toon Rendering**
* **Community Toon Grading**: shadow color grade (multiply / add / hue-rotate / luminance-preserving warmth), low-saturation auto-tint for colorless albedos, Jashin self-power shadow fallback, and silhouette rim light folded into the cel bands — ported from HAToon2/PAToon2, M4Toon2, Jashin Toon and T_ToonShader as `ray.conf` knobs.
* **Crisp Cel Ramp**: anti-aliased two-band terminator with a half-strength core shadow, hardened cast-shadow edges, stepped anime highlights, flat two-step ambient fill, and full SSGI reception on toon materials.
* **Materials/Toon Library**: the entire material tree duplicated as ready-made cel-shaded presets with per-category shadow colors — skin, hair (including procedural presets), eyes, cloth, foliage — plus base cel and tone-based templates and a README.

**ReForge Material Editor Suite (New Standalone Desktop Tool)**
* **Native PBR Material Authoring Tool (`Extension/MaterialEditor/MaterialEditor.exe`)**: high-performance standalone Rust desktop application with zero external runtime dependencies, built specifically for authoring and generating Ray-MMD materials.
* **Blender-Style Node Graph Canvas**: interactive visual node editor with vector icons for synthesizing physical maps from diffuse textures or procedural generators.
* **Dual Operating Modes**: Single Material Sandbox with instant 3D raymarched primitive previews (sphere, cube, cylinder, plane, Utah teapot) and PMX Model Studio for full character staging.
* **Direct 3D Viewport Picking**: select and highlight material subsets by clicking directly on 3D character geometry via color-coded ID-buffering.
* **Full Physical ShaderMap Synthesis**: Tangent-space Normal maps (Sobel/Scharr, DirectX/OpenGL), Ambient Occlusion, Height, Roughness, Metalness, Cavity/Curvature, Procedural Noise, Hair Strands, Eye Cornea Parallax, RNM Blending, and Channel Packing.
* **Multi-Core Parallel Batch Auto-PBR**: automatically scans and generates complete PBR networks for all subsets in a model across all CPU cores in parallel (Rayon).
* **Unified Project Files (`.rfproj`)**: save and restore full character sessions with all subset material graphs, camera angles, textures, and settings, plus modular `.rfmat` graph exchange.
* **Built-in Onboarding & Quick Start**: 5-step interactive guided tour, quick start wizard, and keyboard shortcuts reference cheat sheet (`F1`).

Standard Features (Inherited) :
------------
* Physically-Based Material: albedo, metallic, smoothness/roughness, specular/reflectance, emissive, etc
* Clear coat material with absorption to simulate a second layer
* Cloth material with cloth-DFG to simulate a specular reflection
* Anisotropic material to simulate a specular reflection
* Special-Case Materials Wetness
* Approximation subsurface scattering materials
* Cook-Torrance microfacet specular BRDF (GGX) and burley diffuse BRDF
* Physical light units & Multiple light sources (Point, spot, sun, reactangle, disk, sphere, tube, ies)
* IES light profiles (point and spot light support)
* HDR linear lighting
* Volumetric light and Volumetric fog (cube and sphere fog support)
* Approximation atmospheric fog and sky scattering
* Image-based lighting based on RGBT encode
* Post-Process Bokeh Depth Of Field, Bloom, Tone-mapping, Color Balance

Resources :
------------
- HDRi
	- sIBL Archive - Hdrlabs.com \[[link](http://www.hdrlabs.com/sibl/archive.html)\].
	- ++skies; - **[aokcub](https://twitter.com/aokcub_cg)** \[[link](https://aokcub.net/cg/incskies/)\].
	- USC Institute \[[link](http://gl.ict.usc.edu/Data/HighResProbes)\].

Credits:
-------------
**Reforge Integrations & Special Thanks:**
* **hbee** - Original "DX RayCast Hair Pack" materials (adapted for procedural generation).
* Credit: material by dendewa (https://dendewa.vercel.app/) - Used for HBAO rendering concepts.
* **ikeno** - Referencing algorithms and mathematical concepts from `ikVXGI` for Global Illumination.

**Original Engine:**
Financially supported on [Patreon](http://www.patreon.com/cubizer):

#### Platinum supporters:
* Penti_mmd
* Robert Shawarden

##### Gold supporters:
* Sarashina - 更科
* Birdway

##### Bronze supporters:
* urara在処
* rin kari
* MMD-Seraph
* Rich El

`Thanks! and other supporters! (If you would like to be added or remove from this list Please contact me)`

Contact:
------------
　　If you are a developer using this as part of your love and considering contacting me, you can submit code by `Pull requests` or Feel free to contact me via `twitter` and `issues`, i'll add your profile to team members, Thanks.

* Reach me via Twitter: [@Rui](https://twitter.com/Rui_cg).

[License (MIT)](https://raw.githubusercontent.com/ray-cast/ray-mmd/master/LICENSE.txt)
-------------------------------------------------------------------------------
	Copyright (C) 2016-2018 Ray-MMD Developers. All rights reserved.
    (Reforge modifications are part of the extended project scope).

	https://github.com/ray-cast/ray-mmd

	Permission is hereby granted, free of charge, to any person obtaining a
	copy of this software and associated documentation files (the "Software"),
	to deal in the Software without restriction, including without limitation
	the rights to use, copy, modify, merge, publish, distribute, sublicense,
	and/or sell copies of the Software, and to permit persons to whom the
	Software is furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included
	in all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
	OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
	BRIAN PAUL BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN
	AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
	CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Credits :
--------
* Screen-Space Path Tracing (SSPT / RTGI) based on Marty McFly's (Pascal Gilcher) qUINT RTGI.
* PBR Screen-Space Reflections with Hierarchical-Z tracing; 2D DDA cell traversal per Morgan McGuire & Michael Mara (2017), min/max depth pyramid acceleration.
* Ultrafast Screen-Space Refractions via Newton's Method based on Chase Mayer, Ulf Assarsson & Erik Sintorn (JCGT 2026).
* Energy-Preserving Oren-Nayar (EON) diffuse BRDF based on Jamie Portsmouth, Peter Kutz & Stephen Hill (JCGT 2025).
* Practical Real-Time Hex-Tiling based on Morten S. Mikkelsen (JCGT 2022).
* Hashed Alpha Testing based on Chris Wyman & Morgan McGuire (I3D 2017).
* Variance Shadow Maps (VSM) based on William Donnelly & Andrew Lauritzen (SI3D 2006).
* Ground-Truth Ambient Occlusion (GTAO) based on Jorge Jimenez, Xian-Chun Wu, Angelo Pesce, Adrian Jarabo (Activision 2016).
* Subpixel Morphological Anti-Aliasing (SMAA 1x Ultra+) based on Jorge Jimenez, Jose I. Echevarria et al. (2012).
* Directionally Adaptive Anti-Aliasing (DLAA / G-DLAA) based on Dmitry Andreev (LucasArts / Game Developer 2011).
* Volumetric Cumulus Cloud Modeling & Lighting based on SA_DirectX 3.0 and Frostbite/Nubis (Decima Engine / Guerrilla Games).
* HBSSDO rendering concepts referenced from [dendewa](https://dendewa.vercel.app/).
* AgX Tone Mapping per the official Blender 4.0 implementation ([link](https://github.com/EaryChow/AgX)).
* Karis anti-firefly downsampling and luma weighting from Brian Karis' "Next Generation Post Processing in Call of Duty: Advanced Warfare".
* Polynomial hash without sine functions based on Dave Hoskins (Hash31).

References :
--------
* Screen-Space Path Tracing / qUINT RTGI (Pascal Gilcher) \[[link](https://github.com/martymcmodding/qUINT)\].
* An Energy-Preserving Oren-Nayar Diffuse BRDF (Portsmouth, Kutz, Hill) \[[link](https://jcgt.org/published/0014/01/01/) | [PDF](./ref-docs/Portsmouth2025EON.pdf)\].
* Practical Real-Time Hex-Tiling (Mikkelsen) \[[link](https://jcgt.org/published/0011/02/01/) | [PDF](./ref-docs/Mikkelsen2022Hex.pdf)\].
* Hashed Alpha Testing (Wyman & McGuire) \[[link](https://research.nvidia.com/publication/2017-02_hashed-alpha-testing)\].
* Ultrafast Screen-Space Refractions and Caustics via Newton's Method \[[link](https://jcgt.org/published/0015/01/03/)\].
* Efficient GPU Screen-Space Ray Tracing (McGuire & Mara) \[[link](https://jcgt.org/published/0003/03/04/)\].
* Variance Shadow Maps (Donnelly & Lauritzen) \[[link](https://www.cs.unc.edu/~geom/technical_reports/variance_shadow_maps.pdf) | [PDF](./ref-docs/vsm_paper.pdf)\].
* Practical Real-Time Strategies for Accurate Indirect Occlusion (GTAO, Jimenez et al.) \[[link](https://www.activision.com/cdn/research/Practical_Real_Time_Strategies_for_Accurate_Indirect_Occlusion_NEW%20VERSION_一提.pdf)\].
* Directionally Adaptive Anti-Aliasing (Andreev) \[[link](https://www.gamedeveloper.com/programming/directionally-adaptive-anti-aliasing-dlaa-)\].
* Real-Time Volumetric Cloudscapes (Nubis / Decima) \[[link](https://advances.realtimerendering.com/s2017/Nubis%20-%20Authoring%20Realtime%20Volumetric%20Cloudscapes%20with%20the%20Decima%20Engine%20-%20Final%20.pdf)\].
* A Survey of Efficient Representations for Independent Unit Vectors \[[link](https://jcgt.org/published/0003/02/01/)\].
* Moving to the Next Generation - The Rendering Technology of Ryse \[[link](http://www.crytek.com/download/2014_03_25_CRYENGINE_GDC_Schultz.pdf)\].
* ACES Filmic Tone Mapping Curve \[[link](https://knarkowicz.wordpress.com/2016/08/31/hdr-display-first-steps/)\].
* Compact Normal Storage for small G-Buffers \[[link](http://aras-p.info/texts/CompactNormalStorage.html)\].
* Convert Blinn-Phong to Beckmann distribution \[[link](http://simonstechblog.blogspot.de/2011/12/microfacet-brdf.html)\].
* Spherical Gaussian approximation for Blinn-Phong, Phong and Fresnel \[[link](https://seblagarde.wordpress.com/2012/06/03/spherical-gaussien-approximation-for-blinn-phong-phong-and-fresnel/)\].
* Horizon Occlusion for IBL \[[link](http://marmosetco.tumblr.com/post/81245981087)\].
* Screen space glossy reflections \[[link](http://roar11.com/2015/07/screen-space-glossy-reflections/)\].
* Parallax Occlusion Map \[[link](http://sunandblackcat.com/tipFullView.php?topicid=28)\].
* Special-Case Materials Wetness \[[link](http://advances.realtimerendering.com/other/2016/naughty_dog/NaughtyDog_TechArt_Final.pdf)\]

#### Material Response Library — `Shader/BRDF.fxsub`
All BRDF/dispatch kernels actually implemented in the material shading unit, with their primary sources:

| Algorithm (symbol) | Source |
|---|---|
| Schlick Fresnel `fresnelSchlick` (F0→F90 interpolation) | E. Schlick 1994, "An Inexpensive BRDF Model for Physically-Based Rendering"; F90-style saturate(50·F0) micro-occlusion from B. Karis 2013 SIGGRAPH shading course notes \[[link](https://blog.selfshadow.com/publications/s2013-shading-course/)\] |
| Adobe F82 Fresnel `fresnelSchlickAdobeF82` (opt-in `BRDF_FRESNEL_TYPE 1`) | Kutz et al. 2021, "Novel aspects of the Adobe Standard Material", Sec. 2.3 (constants pre-folded for CosThetaMax = 1/7) |
| Burley diffuse `BurleyBRDF` | B. Burley 2012, "Physically-Based Shading at Disney" |
| Oren-Nayar diffuse `OrenNayarBRDF` | M. Oren & S. Nayar 1994 |
| Energy-Preserving Oren-Nayar `EonBRDF` + Fujii FON 4th-order directional albedo polynomial | Portsmouth, Kutz & Hill, JCGT 2025 \[[link](https://jcgt.org/published/0014/01/01/)\] |
| GGX / Trowbridge-Reitz distribution `SpecularBRDF_GGX` | B. Walter et al. 2007, "Microfacet Models for Refraction through Rough Surfaces" \[[link](https://www.cs.cornell.edu/~srm/publications/EGSR07-btdf.html)\] |
| Smith joint visibility `k`-form (Vis_SmithJointApprox) | E. Heitz 2014, "Understanding the Masking-Shadowing Function in Microfacet-Based BRDFs" |
| Multi-scattering specular energy compensation | V. Turquin 2018 (private notes) / M. Fdez-Aguera 2019, "A Multiple-Scattering Microfacet Model for Real-Time Image Based Lighting" |
| Blinn-Phong specular `SpecularBRDF_Blinn` (glass) | J. Blinn 1977 |
| Dual-lobe skin specular `DualLobeSkinSpecular` (widths/mix authorable via `SKIN_SPEC_LOBE*`) | dual-specular-lobe skin profile model (two-GGX mix), cf. J. Jimenez et al. 2015 "SEPARABLE SSS" and B. Penner 2011 (GPU Pro 2), with single-pass D-blend and unified Smith joint visibility |
| Anisotropic GGX `SpecularBRDF_GGXAniso` (incl. shifted R/TRBT hair lobes) | Burley 2012 (energy-preserving aspect ratio parameterization); Heitz aniso Smith `Vis_SmithJointAniso` |
| Two-sided wrapped transmission `SubsurfaceShadingTwoSided` (foliage, leaves, cloth, paper) | S. McAuley 2011, "Energy-conserving wrapped diffuse" |
| Analytical Eye Iris Caustic `EyeIrisCaustic` | J. Jimenez 2014, "Next Generation Post Processing in Call of Duty: Advanced Warfare" (focused concave iris caustic highlight) |
| Sphere-light specular softening `SphereMaxNoH` (opt-in `SPEC_LIGHT_SIN_ALPHA`) | G. de Carpentier 2017, "Decima Engine: Advances in Lighting and AA" (largest-NoH over sphere solid angle + Newton iteration) |
| Charlie sheen cloth BRDF `ClothShading` (D_Charlie + Neubelt/Pettineo visibility or full `Vis_Charlie` exponential fit via `BRDF_CLOTH_VIS_CHARLIE`, cloth-DFG directional albedo) | F. Estevez & A. Kulla 2017, "Production Friendly Microfacet Sheen BRDF"; Neubelt & Pettineo 2013 "The Rendering Technologies of Destiny" |
| Scalar half-vector evaluation `InvLenH` / `NoH` / `VoH` in `SurfaceEnergy` | B. Karis 2013 SIGGRAPH course notes (analytical invariant $\|V+L\|^2 = 2 + 2(V \cdot L)$ eliminating 3D vector normalization) |
| Analytical Environment BRDF polynomial fit `EnvBRDFApproxLazarov` / `EnvBRDFApprox` | D. Lazarov 2013, "Getting More Physical in Call of Duty: Black Ops II" (analytical dual-polynomial fit for split-sum DFG integral) |
| Fully-rough microfacet energy preservation `EnergyPreservingFullyRough` | Directional albedo transfer $\int DFG \approx 0.45 \cdot F_0$ converting extreme microfacet roughness ($\alpha \to 1$) into diffuse scattering |
| ClearCoat two-layer specular + Snell refraction + Beer-Lambert absorption | two-layer clearcoat model per K. Weier et al.; analytical Snell refraction angle deflection (`RefractBlendClearCoatApprox`) and Beer-Lambert thin-film optical absorption; (1−Fc)² attenuation |
| Thin-film iridescence `ThinFilmIridescence` | Airy thin-film interference, per-wavelength OPD at 650/532/450 nm (cf. L. Belcour & P. Barla 2017, "A Practical Extendable BRDF for Layered Materials") |
| UE-style artist SSS `SubsurfaceShadingCheatSkin` (WrappedDiffuse w=1/3 n=1.5, AO BackScatter, InScatter^12) | wrapped/translucent cheat shading as popularized in B. Karis' 2013 SIGGRAPH course notes and X. Álvarez screen-space subsurface conventions |
| HSV-luminance-preserving transmittance hue shift `HueShiftTransmittance` | Beer-Lambert transmission-color grading; HSV codec by S. Hocevar / I. Quilez |
| Backlit HG-phase glow `SubsurfaceShadingBacklitGlow` (refracted V + Henyey-Greenstein, opt-in) | Henyey-Greenstein forward-scattering phase evaluated at refraction-corrected view (L.G. Henyey & J.L. Greenstein 1941; thin-tissue transmission per J. Jimenez et al. 2010 "Real-Time Realistic Skin Translucency") |
| Specular micro-occlusion `ComputeSpecularMicroOcclusion` / ambient aperture occlusion | saturate(50·F0) clamp from B. Karis 2013; aperture-based ambient occlusion |
| Toon ramps, YIQ hue rotation, community shadow grading (`ToonBasedShading`, `CelShading`, `ToonShadowGrade`) | HAToon2 / PAToon2, M4Toon2, Jashin Toon, T_ToonShader; YIQ NTSC transform |
| Geometric specular roughness filtration `FilterGeometricRoughness` | D. Young 2015 "specAA" / LEAN/CLEAN-style geometric filtering |

#### Skin SSS Separable Blur — `Shader/PostProcessScattering.fxsub`
* **Separable Screen-Space SSS (13-tap two-pass)**: horizontal + vertical convolution of the SSR-denoised diffusion field with a front-to-back modulated footprint and perspective-aware step — J. Jimenez et al. 2015, "Separable Subsurface Scattering" \[[link](https://www.iryoku.com/sssss/)\].
* **Christensen–Burley Approximate Reflectance Profiles**: 13-tap RGB kernel weights pre-integrated from the Burley-Normalized BSSRDF for two profiles (skin d=(1.9, 1.2, 0.8) mm; subsurface d=(2.4, 1.5, 0.9) mm) — P. Christensen & B. Burley, "Approximate Reflectance Profiles for Efficient Subsurface Scattering", Pixar Technical Memo 15-04 \[[link](https://graphics.pixar.com/library/ApproxBSSRDF/)\].
* **Deferred SSS recombine & tint**: second-pass albedo tint (`sqrt(saturate(albedo))`, strength 0.35) and detail-preservation blend for low-scatter subsurface materials — the industry-standard recombine pattern from the separable SSS screen-space pipeline.
* **Absorption-aware bilateral edge guard**: per-channel depth tolerance modulated by the squared-albedo transport approximation so bright pixels scatter wider and dark pixels cut bleeding — adapted from ikeno's `ikPolishShader` sss.fxsub.

#### Screen-Space Global Illumination — `Shader/SSGI/`
Every algorithm named in the SSGI module comments (`SSGI_Trace / SSGI_Filter / SSGI_Resolve / SSGI_Common`), mapped to its primary source:

| Algorithm (location) | Source |
|---|---|
| Low-ray-count cosine-weighted hemisphere raymarching with radiance gather (`SSGI_Trace.fxsub`) | Monte Carlo cosine-weighted hemisphere sampling; screen-space short-range diffuse tracing following the SSRT-style raymarching introduced in modern deferred engines (concept per McGuire & Mara 2014 screen-space ray tracing) |
| Branchless orthonormal tangent basis `BuildOrthonormalBasis` (`SSGI_Common.fxsub:64`) | T. Duff et al. 2017, "Building an Orthonormal Basis, Revisited", JCGT \[[link](https://jcgt.org/published/0006/01/01/)\] |
| Interleaved Gradient Noise jitter `InterleavedGradientNoise` (`SSGI_Trace.fxsub:82`) | J. Jimenez 2014, "Next Generation Post Processing in Call of Duty: Advanced Warfare", SIGGRAPH course |
| Halton low-discrepancy stratification `Halton2` (`SSGI_Common.fxsub:78–91`) | J. H. Halton 1964, "Algorithm 65: Implement of the Radical-Inverse Quasi-Random Point Sequence" |
| Branchless viewport ray clipping `ClipRayToScreenEdge` (`SSGI_Common.fxsub:115`) | ratio-based ray-minus screen-edge intersection per M. McGuire & M. Mara 2017, "Efficient GPU Screen-Space Ray Tracing" \[[link](https://jcgt.org/published/0003/03/04/)\]. |
| Adaptive depth-thickness visibility gating `ComputeThicknessWeight` (`SSGI_Common.fxsub:127`) | smoothstep thickness gating used by screen-space ray-traced denoisers (cf. E. Heitz et al. 2016, "Spatiotemporal Variance-Guided Filtering, SVGF") |
| Radiance outlier rejection + Karis luminance weighting (`SSGI_Filter.fxsub:66`) | B. Karis 2014, "Next Generation Post Processing in Call of Duty: Advanced Warfare" (SIGGRAPH Advances course) |
| Cross-bilateral edge stops (`BilateralCommon.fxsub`: plane distance, depth, normal similarity, Gaussian spatial falloff) | C. Tomasi & R. Manduchi 1998, "Bilateral Filtering for Gray and Color Images"; tangent-plane distance weighting standard in screen-space GI denoisers |
| Separable À-Trous wavelet blur with dyadic stride 1→2 (`SSGIBlurPS`) | à-trous wavelet transform (P. Dutilleux 1990), modern usage per SVGF (Heitz et al. 2016) "Spatiotemporal variance-guided filtering" |
| Cosine-weighted hemisphere Monte Carlo sampling | cosinelobe importance sampling with Shirley-concentric mapping (M. Shirley & K. Chiu 1997, "A Low Distortion Map Between Disk and Square") |
| Multi-bounce occlusion response (AO² quadratic crevice absorption) + albedo-compensated multi-bounce `multiBounce` (`SSGI_Resolve.fxsub:38–91`) | J. Jimenez et al. 2016 GTAO multi-bounce approximation \[[link](https://www.activision.com/cdn/research/Practical_Real_Time_Strategies_for_Accurate_Indirect_Occlusion_NEW%20VERSION_一提.pdf)\] |
| Reinhard photometric compression for skin reception (`SSGI_Resolve.fxsub:62`) | E. Reinhard et al. 2002, "Photographic Tone Reproduction for Digital Imaging" |
#### Screen-Space Path Tracing (SSPT / RTGI) — `Shader/SSPT/`
Algorithms implemented in the Screen-Space Path Tracing module, mapped to their primary sources:

| Algorithm (location) | Source |
|---|---|
| Screen-space path tracing with golden angle rotation (`SSPT_Trace.fxsub`) | P. Gilcher (Marty McFly) 2019–2023, "qUINT RTGI" \[[link](https://github.com/martymcmodding/qUINT)\]; low-discrepancy golden spiral Monte Carlo cosine hemisphere integration |
| Projected-axis tangent basis `BuildTangentMatrix` (`SSPT_Trace.fxsub`) | P. Gilcher (qUINT RTGI) orthonormal projection around surface normals |
| Progressive quadratic ray stepping $\lambda = s\sqrt{s}$ (`SSPT_Trace.fxsub`) | Progressive near-field/far-field step expansion balancing contact shadow accuracy and room reach |
| Analytical thickness delta gating (`SSPT_Trace.fxsub`) | qUINT RTGI depth thickness delta test eliminating light leaking through thin geometry |
| Secondary bounce indirect feedback loop (`SSPT_Resolve.fxsub`) | Screen-space multi-bounce radiance propagation (`SSPT_BOUNCES`) with emissive transfer |
| Separable cross-bilateral À-Trous wavelet filter (`SSPT_Filter.fxsub`) | Dyadic stride progression with Karis luminance outlier rejection and normal/depth bilateral edge stops |
| Albedo-driven dynamic skin multi-bounce curve (`SSPT_Resolve.fxsub`) | Dynamic interreflection scaling preventing skin crushing under indirect bounces |
| Glass resolve bypass & transmission hit skipping (`SSPT_Resolve.fxsub`, `SSPT_Trace.fxsub`) | Optical glass transmission bypass preserving dielectric transparency without diffuse fogging |
| Direct solar shadow retention (`SSPT_Resolve.fxsub`, `SSGI_Resolve.fxsub`) | Quadratic penumbra gating against directional shadow maps preventing indirect bounce blowout in cast shadows |
| Deferred post-GI ambient occlusion composite (`Shader/PostProcessAOComposite.fxsub`) | Multi-bounce Jimenez AO composite applied post-GI to preserve deep contact darkening and crevice contrast |

* (And many more from the original development team...)

