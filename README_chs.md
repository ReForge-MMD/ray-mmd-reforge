Ray-MMD
========
###### [English](https://github.com/ray-cast/ray-mmd/blob/master/README.md) &nbsp; [中文文档](https://github.com/ray-cast/ray-mmd/blob/master/README_chs.md)
### 基于物理的渲染 ###
　　<img style="vertical-align: top;" src="./Shader/screenshots/logo.png" alt="logo" height="48px">

　　Ray-MMD是一个自由的,功能强大的[mikumikudance](http://www.geocities.jp/higuchuu4/index_e.htm)扩展包, 提倡以一种易于使用的方式来添加基于物理的渲染和高自由度操作. 使用hlsl语言编写, 一个基于在[mikumikueffect](https://bowlroll.net/file/35012)的DX9环境中的渲染库. 

截图:
------------
[![link text](./Shader/screenshots/screen1_small.jpg)](https://raw.githubusercontent.com/ray-cast/ray-mmd/master/Shader/screenshots/screen1.jpg)
[![link text](./Shader/screenshots/screen2_small.png)](https://raw.githubusercontent.com/ray-cast/ray-mmd/master/Shader/screenshots/screen2.png)
[![link text](./Shader/screenshots/screen3_small.jpg)](https://raw.githubusercontent.com/ray-cast/ray-mmd/master/Shader/screenshots/screen3.png)
[![link text](./Shader/screenshots/screen4_small.jpg)](https://raw.githubusercontent.com/ray-cast/ray-mmd/master/Shader/screenshots/screen4.png)

下载
------------
　[![img](https://img.shields.io/badge/version-1.3.1v2-brightgreen.svg)](https://github.com/ray-cast/ray-mmd/archive/1.3.1v2.zip)
　[![img](https://img.shields.io/badge/version-1.5.0-brightgreen.svg)](https://github.com/ray-cast/ray-mmd/archive/1.5.0.zip)

* [Ray-MMD - 1.3.1v2 (zip)](https://github.com/ray-cast/ray-mmd/archive/1.3.1v2.zip)  (updated: 27. Apr 2017)
* [Ray-MMD - 1.3.1v2 (tar.gz)](https://github.com/ray-cast/ray-mmd/archive/1.3.1v2.tar.gz)  (updated: 27. Apr 2017)
* [Ray-MMD - 1.5.0 (zip)](https://github.com/ray-cast/ray-mmd/archive/1.5.0.zip) (updated: 15. Jan 2018)
* [Ray-MMD - 1.5.0 (tar.gz)](https://github.com/ray-cast/ray-mmd/archive/1.5.0.tar.gz) (updated: 15. Jan 2018)
- 额外扩展
	- [ColorGrading - v1.0.0 (zip)](https://github.com/MikuMikuShaders/ColorGrading/archive/v1.0.0.zip) (updated: 2. Dec 2017, \[[Github](https://github.com/MikuMikuShaders/ColorGrading)\])
	- [FilmGrain - v1.0.0 (zip)](https://github.com/MikuMikuShaders/FilmGrain/archive/v1.0.0.zip) (updated: 2. Dec 2017, \[[Github](https://github.com/MikuMikuShaders/FilmGrain)\])
	- [FXAA - v1.0.0 (zip)](https://github.com/MikuMikuShaders/FXAA/archive/v1.0.0.zip) (updated: 2. Dec 2017, \[[Github](https://github.com/MikuMikuShaders/FXAA)\])
	- [LightBloom - v1.1.1 (zip)](https://github.com/MikuMikuShaders/LightBloom/archive/v1.1.1.zip) (updated: 2. Dec 2017, \[[Github](https://github.com/MikuMikuShaders/LightBloom)\])
	- [SMAA - v1.0.0 (zip)](https://github.com/MikuMikuShaders/SMAA/archive/v1.0.0.zip) (updated: 2. Dec 2017, \[[Github](https://github.com/MikuMikuShaders/SMAA)\])
	- [Spectrum - v1.4.0 (zip)](https://github.com/MikuMikuShaders/Spectrum/archive/v1.4.0.zip) (updated: 2. Dec 2017, \[[Github](https://github.com/MikuMikuShaders/Spectrum)\])
	- [StereoImage - v1.0.0 (zip)](https://github.com/MikuMikuShaders/StereoImage/archive/v1.0.0.zip) (updated: 2. Dec 2017, \[[Github](https://github.com/MikuMikuShaders/StereoImage)\])

需求:
------------
* [MikuMikuDance](http://www.geocities.jp/higuchuu4/index_e.htm) - 926ver (x64) (没有抗锯齿)
* [MikuMikuEffect](https://bowlroll.net/file/35012) - 037ver (x64)
* Direct3D 9 With Shader Model 3.0 (ps_3_0)

快速上手与控制器指南 :
--------------------------------
> **写给原版 Ray-MMD 用户的说明：**  
> 在 **Ray-MMD Reforge** 中，原版庞大的单个 `ray_controller.pmx` 已被完全解耦并重构为模块化的专用控制器。这种模块化架构使得着色器在引入新功能时能够拥有独立的控制面板，而无需修改或膨胀同一个臃肿的文件。

### 基础场景最小推荐控制器（核心 4 件套）
在常规场景中，你**不需要**加载全部控制器。只需通过 MMD 的 `模型控制 (Model Manipulation)` -> `载入` 加载以下 **4 个** 控制器即可满足绝大多数需求：
1. **`LightingController.pmx`** — 太阳光强度、SSAO/SSDO 接触阴影、多光源缩放、次表面散射 (SSSS) 以及 SSGI/SSPT 间接光强度。
2. **`CameraController.pmx`** — 电影级镜头景深 (光圈 F-stop、焦距、对焦距离)、镜头色散与暗角。
3. **`ColorGradingController.pmx`** — 影棚级调色系统 (暗部/中间调/高光 Lift/Gamma/Gain 三向调色、2D 白平衡、曝光度、自然饱和度与电影预设)。
4. **`FogController.pmx`** — 地面雾气、物理双层指数大气高度雾、体积光 (Godrays) 与风场扰动。

### 可选与进阶控制器
仅在场景需要使用特定特效时加载：
* **`BloomController.pmx`** — HDR 泛光阈值、半径、星芒衍射与色彩调整。
* **`SkyVisibilityController.pmx`** — 遮挡区域 (屋顶、桥下、室内) 的宏观天光环境光遮蔽 (Snowdrop 引擎方案)。
* **`CausticsController.pmx`** — 水面材质的方向性水下焦散与波浪模拟。

### 诊断与调试控制器
* **`DebugController.pmx`** — 实时视口 G-Buffer、阴影级联与 SSGS 光线步进诊断。
* **`SSRDebugController.pmx`** — SIMD SSR 屏幕空间反射光线步进诊断 (步数、置信度、粗糙度、法线)。

### 4 步基础场景工作流
1. **载入主着色器：** 将 `ray.x` 拖入 MMD (附件控制 -> 载入)。
2. **载入天空盒：** 载入 `Skybox/` 目录下的天空盒 (例如 `Helipad GoldenHour.pmx`)，并在 MME 的 `EnvLightMap` 标签页为其分配对应的 lighting 着色器。
3. **载入基础控制器：** 载入 `LightingController.pmx`、`CameraController.pmx`、`ColorGradingController.pmx` 和 `FogController.pmx` (模型控制 -> 载入)。
4. **分配模型与材质：** 载入你的模型，在 MME `Main` 标签页分配 `Main/main.fx`，并在 `MaterialMap` 标签页为各个材质槽分配对应的材质 (`Materials/Skin/`、`Materials/Hair/` 等)。

特性:
------------
* 基于物理的材质: 基本色, 金属性, 光滑/粗糙度, 反射率, 自发光, 等 
* 模拟清漆的多层材质 
* 模拟布料材质的镜面反射 
* 各向异性的多层材质 
* 湿度贴图的支持 
* 近似的次表面散射用于模拟玉器和皮肤 
* GGX镜面光照模型和burley的漫反射光照模型 
* 物理的光源 
* 点光源, 聚光灯, 太阳光, 面积光, IES 的多光源的支持 
* 点光源和聚光的IES配置 
* PCF, VSM, PSSM 的软阴影 
* 基于双抛面的全方位点光源阴影
* 高动态范围照明(High-Dynamic Lighting)
* 点光源, 聚光灯, IES 的体积光 
* 方形和球形的体积雾 
* 云隙光效果 
* 模拟雾气和天空的近似的大气散射 
* 地面雾特效 
* 基于RGBT编码的高动态天空盒 
* 基于RGBT编码的高动态图像照明(Image-Based Lighting) 
* 屏幕空间反射 
* 屏幕空间环境光遮蔽 
* 屏幕空间次表面散射 
* 后处理的景深特效 
* 后处理的泛光特效 
* 后处理的人眼适应特效 
* 后处理的色调映射 (ACES-like,Reinhard,Hable,Hejl2015,NaughtyDog support) 
* 后处理的色彩调整 
* FXAA抗锯齿 
* SMAA抗锯齿 

支持者:
-------------
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

`感谢所有对我的支持! (如果你想要在这里添加或者移除请通过下面的方式来联系我)`

联系:
------------
　　如果你是一名热爱图形的开发者，你可以通过`Pull requests`来提交你的代码，或者通过Github的Issue和twitter来加入到我们的团队

* Twitter: [@Rui](https://twitter.com/Rui_cg).

[协议 (MIT)](https://raw.githubusercontent.com/ray-cast/ray-mmd/master/LICENSE.txt)
-------------------------------------------------------------------------------
	Copyright (C) 2016-2018 Rui. 保留所有版权.

	https://github.com/ray-cast/ray-mmd

	被授权人权利:
	被授权人有权利使用、复制、修改、合并、出版发行、散布、再授权及贩售软件及软件的副本。
	被授权人可根据程序的需要修改授权条款为适当的内容。

	被授权人义务:
	在软件和软件的所有副本中都必须包含版权声明和许可声明。由版权持有人及其他责任者“按原样”提供，包括
	但不限于商品的内在保证和特殊目的适用，将不作任何承诺，不做任何明示或暗示的保证。 在任何情况下，不
	管原因和责任依据，也不追究是合同责任、后果责任或侵权行为(包括疏忽或其它)，即使被告知发生损坏的可
	能性，在使用本软件的任何环节造成的任何直接、间接、偶然、特殊、典型或重大的损坏(包括但不限于使用替
	代商品的后果：使用、数据或利益的损失或业务干扰)，版权持有人、其他责任者或作者或所有者概不承担任何责任

	其他重要特性:
	此授权条款并非属Copyleft的自由软件授权条款，允许在自由/开放源码软件或非自由软件（proprietary software）所使用。
	MIT的内容可依照程序著作权者的需求更改内容。此亦为MIT与BSD（The BSD license, 3-clause BSD license）本质上不同处。
	MIT条款可与其他授权条款并存。另外，MIT条款也是自由软件基金会（FSF）所认可的自由软件授权条款，与GPL兼容

引用:
-----------
* Practical Real-Time Hex-Tiling (Mikkelsen) \[[link](https://jcgt.org/published/0011/02/01/) | [PDF](./ref-docs/Mikkelsen2022Hex.pdf)\].
* Moving to the Next Generation - The Rendering Technology of Ryse \[[link](http://www.crytek.com/download/2014_03_25_CRYENGINE_GDC_Schultz.pdf)\].
* ACES Filmic Tone Mapping Curve \[[link](https://knarkowicz.wordpress.com/2016/08/31/hdr-display-first-steps/)\].
* Compact Normal Storage for small G-Buffers \[[link](http://aras-p.info/texts/CompactNormalStorage.html)\].
* Convert Blinn-Phong to Beckmann distribution \[[link](http://simonstechblog.blogspot.de/2011/12/microfacet-brdf.html)\].
* Spherical Gaussian approximation for Blinn-Phong, Phong and Fresnel \[[link](https://seblagarde.wordpress.com/2012/06/03/spherical-gaussien-approximation-for-blinn-phong-phong-and-fresnel/)\].
* Physically Based Area Lights \[[link](http://www.frostbite.com/wp-content/uploads/2014/11/course_notes_moving_frostbite_to_pbr.pdf)\].
* Physics and Math of Shading \[[link](http://blog.selfshadow.com/publications/s2015-shading-course/hoffman/s2015_pbs_physics_math_slides.pdf)\].
* Compact YCoCg Frame Buffer for small IBL-Buffer \[[link](http://jcgt.org/published/0001/01/02/)\].
* RGBM color encoding \[[link](http://graphicrants.blogspot.com/2009/04/rgbm-color-encoding.html)\].
* Horizon Occlusion for IBL \[[link](http://marmosetco.tumblr.com/post/81245981087)\].
* Screen space glossy reflections \[[link](http://roar11.com/2015/07/screen-space-glossy-reflections/)\].
* Parallax Occlusion Map \[[link](http://sunandblackcat.com/tipFullView.php?topicid=28)\].
* Convert Temperature to RGB \[[link](https://github.com/davidf2281/ColorTempToRGB)\].
* Texture repetition \[[link](http://www.iquilezles.org/www/articles/texturerepetition/texturerepetition.htm)\].
* Pre-Integrated Skin Shading \[[link](http://simonstechblog.blogspot.com/2015/02/pre-integrated-skin-shading.html)\]
* Normal Blending in Detail \[[link](http://blog.selfshadow.com/publications/blending-in-detail/)\]
* An Approximation to the Chapman Grazing-Incidence Function for Atmospheric Scattering \[[link](http://www.gameenginegems.net/gemsdb/article.php?id=1133)\]
* Bump map to normal \[[link](https://docs.unrealengine.com/latest/attachments/Engine/Rendering/LightingAndShadows/BumpMappingWithoutTangentSpace/mm_sfgrad_bump.pdf)\]
* Special-Case Materials Wetness \[[link](http://advances.realtimerendering.com/other/2016/naughty_dog/NaughtyDog_TechArt_Final.pdf)\]
* Mip Fog \[[link](http://advances.realtimerendering.com/other/2016/naughty_dog/NaughtyDog_TechArt_Final.pdf)\]
* Gaussian-kernel-calculator \[[link](http://dev.theomader.com/gaussian-kernel-calculator/)\]
* Ray Box Intersection on the GPU \[[link](https://github.com/hpicgs/cgsee/wiki/Ray-Box-Intersection-on-the-GPU)\]
* Hexagonal Bokeh Blur Revisited \[[link](https://colinbarrebrisebois.com/2017/04/18/hexagonal-bokeh-blur-revisited/)\]
* Practical Post-Process Depth of Field \[[link](https://developer.nvidia.com/gpugems/GPUGems3/gpugems3_ch28.html)\]
* Approximation of the IBL’s DFG term for a cloth BRDF \[[link](https://gist.github.com/romainguy/52d0e7f070d9ed7b44a0327d735fe33e)\]
* Real-Time Polygonal-Light Shading with Linearly Transformed Cosines\[[link](https://eheitzresearch.wordpress.com/415-2/)\]
* Limb Darkening model \[[link](http://www.physics.hmc.edu/faculty/esin/a101/limbdarkening.pdf)\]
