Shader "KLST/Ground_Height_UV3_PBR"
{
	Properties
	{
		//地面着色器
		_Color("ColorR",Color) = (1,1,1,1)
		_MainTex("RTex", 2D) = "white" {}
		[NoScaleOffset]_MainNromalMap("法线(RG) 粗糙度(B) 金属度(A)",2D) = "bump"{}
		_Metallic("R 金属度",Range(0,1)) = 0
		_Roughness("R 粗糙度",Range(0,1)) = 0
		_ColorGVertex("ColorG",Color) = (1,1,1,1)		
		[NoScaleOffset]_GTex("GTex",2D) = "white"{}
		[NoScaleOffset]_GNormalMap("法线(RG) 粗糙度(B) 金属度(A)",2D) = "bump"{}
		_MetallicG("G 金属度",Range(0,1)) = 0
		_RoughnessG("G 粗糙度",Range(0,1)) = 0
		_ColorBVertex("ColorB",Color) = (1,1,1,1)		
		[NoScaleOffset]_BTex("BTex", 2D) = "white" {}
		[NoScaleOffset]_BNormalMap("法线(RG) 粗糙度(B) 金属度(A)",2D) = "bump"{}
		_MetallicB("B 金属度",Range(0,1)) = 0
		_RoughnessB("B 粗糙度",Range(0,1)) = 0
		_NormalAmoutnN1("法线强度",Range(0,3)) = 1
		_Strength ("高度图强度",Range(0.01,1)) = 1
		_MaskTex("法线(RG) AO(B) 细节(A)",2D) = "bump"{}
		_Occlusion("AO",Range(0,1)) = 1
		_RefTex("Render Tex Reflect",2D) = "white"{}
		_LightMap("LightMap", 2D) = "white"{}

	}
		CGINCLUDE
		//切线推导副法线
		#define BINORMAL_PER_FRAGMENT
		//雾
		#define FOG_DISTANCE
		ENDCG

	SubShader
	{
		Pass
		{
			Tags{"LightMode" = "ForwardBase"}

			CGPROGRAM
			#pragma target 3.0	

			//使用shader_feature减少多编译指令 只会在使用到再会编译,不会为所有组合生成着色器变体
			#pragma shader_feature _ _MIAN_VERTEX _RG_VERTEX _RGB_VERTEX  _VERTEX_COLOR
			//多层细节贴图
			#pragma shader_feature _MASK_DETAIL
			//UV3
			//#pragma shader_feature _GROUND_UV3
			//光照贴图
			//#pragma shader_feature _ _OHR_LIGHTMAP_UNITY _OHR_LIGHTMAP_INNER
			#pragma shader_feature CF_LIGHTMAP
			//RenderTex
			//#pragma shader_feature _RENDERTEX_REFLECT
			#pragma multi_compile_fwdbase
			#pragma multi_compile_fog
			#define FORWARD_BASE_PASS

			#pragma vertex MyVertexProgram
			#pragma fragment MyFragmentProgram

			#include "OHR Lighting.cginc"

			ENDCG
		}

		Pass
		{
			Tags{ "LightMode" = "ShadowCaster" }

			CGPROGRAM
			#pragma target 3.0
			//多重投影编译指令
			#pragma shader_feature _ _ALPHA_MASK_TRANSPARENCY _CUOFF_MASK_TRANSPARENCY
			#pragma multi_compile_shadowcaster

			#pragma vertex MyShadowVertexProgram
			#pragma fragment MyShadowFragmentProgram

			#include "OHR Shadows.cginc"

			ENDCG
		}
		Pass
		{
			Tags{"LightMode" = "Meta"}
			Cull off

			CGPROGRAM

			#pragma vertex LightmappingVertexProgram
			#pragma fragment LightmappingFragmentProgram


			#include "OHR Lightmapping.cginc"

			ENDCG

		}
	}
	CustomEditor "OHRGroundUV3GUI"
}
