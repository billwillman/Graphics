// Upgrade NOTE: replaced 'defined UV2_ON' with 'defined (UV2_ON)'


#if !defined(LIGHTING_INCLUDED)
#define LIGHTING_INCLUDED
		#include "UnityPBSLighting.cginc"
		//#include "UnityGlobalIllumination.cginc"

		#if !defined(_OHR_LIGHTMAP_INNER)
			#define LIGHTMAP_UNITY 1
		#elif !defined(_OHR_LIGHTMAP_UNITY)
			#define LIGHTMAP_INNER 1
		#endif

		//内部 LightMap
		

		//Unity LightingMap
		#if LIGHTMAP_UNITY
			#include "AutoLight.cginc"
		#elif LIGHTMAP_INNER		 
			#include "ShadowMask.cginc"
			#include "AutoLightShadowMask.cginc"
		#endif

		//fog 线性 指数 指数平方
		#if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2)
			//世界空间距离雾计算
			#if !defined (FOG_DISTANCE)
				//屏幕空间深度雾计算
				#define FOG_DEPTH 1
			#endif
			//雾关闭
			#define FOG_ON 1
		#endif		
		
		//多灯情况下的阴影淡化
		//Unity LightingMap
		#if LIGHTMAP_UNITY
			#if !defined(LIGHTMAP_ON) && defined (SHADOWS_SCREEN)
				#if defined(SHADOWS_SHADOWMASK) && !defined(UNITY_NO_SCREENSPACE_SHADOWS)
					#define ADDITIONAL_MASKED_DIRECTIONAL_SHADOWS  1
				#endif
			#endif
			// Subtractive Lighting 减法灯光模式
			#if defined(LIGHTMAP_ON) && defined(SHADOWS_SCREEN)
				#if defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK)
					#define SUBTRACTIVE_LIGHTING 1
				#endif
			#endif
		#endif

		//顶点色mask uv3
		#if defined(_MASK_MAINTEX)|| defined(_RG_MASK_VERTEX) || defined(_RGB_MASK_VERTEX) 
			#define MASK_VERTEX 1
		#endif
		
		//小物件mask
		#if defined(_MAIN_MASK_PROPS) || defined(_RG_MASK_PROPS) || defined(_RGB_MASK_PROPS) 
			#define MASK_PROPS 1
		#endif
	
		//顶点色通道
		#if defined(_MAINTEX)
			#define OBJECT_MASK_UV1 1
		#endif
		
	/*	#if defined(MASK_DETAIL)
			#define DETAIL
		#endif*/

		//Mask 是否使用
		#if defined(MASK_VERTEX)  || defined(MASK_PROPS) 
			#define MASK_ON 1
		#endif

		//windows 窗户着色器是否使用
		#if defined( _WINDOWS) || defined(_MASK_G_WINDOWS)
			#define WINDOWS_ON 1
		#endif

		/*#if defined(_RENDERING_CUTOUT) || defined(_RENDERING_FADE) || defined(_RENDERING_TRANSPARENT)
			#define RENDERING_ON 1
		#endif */

		#if defined(_MASK_DETAIL) || defined(MASK_ON) || defined(WINDOWS_ON) || defined(_RGB_VERTEX_PRECIPICE) 
			#define	UV3_ON 1
		#endif

		#if defined (_RGB_MASK_VERTEX) || defined(_RGB_VERTEX) || defined(_RGB_MASK_PROPS) || defined(_RGB_VERTEX_PRECIPICE) 
			#define UV2_ON 1
		#endif

		struct VertexInput
		{
			float4 vertex : POSITION;
			float2 uv : TEXCOORD0;
			float3 normal : NORMAL;
			float4 tangent : TANGENT;
			float2 uv1 : TEXCOORD1;
			//实时GI 光照贴图UV
			float2 uv2 : TEXCOORD2;
			//#if defined (UV3_ON) 
				float2 uv3 : TEXCOORD3;
			//#endif
			float4 color :COLOR;
		};

		struct VertexOutput
		{
			float4 uv : TEXCOORD0;
			#if defined (UV2_ON)
				float2 uv2 : TEXCOORD1;
			#endif			
			#if defined (UV3_ON) 
				float2 uv3 : TEXCOORD2;
			#endif
			float3 normal : TEXCOORD3;
			float4 color : COLOR;
			float4 pos : SV_POSITION;
			//判断使用切线推导出副切线或者是加入新的纹理插值器创建一个binormal
			#if defined(BINORMAL_PER_FRAGMENT)
				float4 tangent : TEXCOORD4;
			#else
				float3 tangent : TEXCOORD4;
				float3 binormal : TEXCOORD5;
			#endif

			//fog 屏幕空间深度
			#if FOG_DEPTH
				float4 worldPos : TEXCOORD6;
			#else
				float3 worldPos : TEXCOORD6;
			#endif

			UNITY_SHADOW_COORDS(7)			
			//Unity LightingMap
			#if LIGHTMAP_UNITY
				#if defined(LIGHTMAP_ON) || ADDITIONAL_MASKED_DIRECTIONAL_SHADOWS
					float2 lightmapUV : TEXCOORD8;
				#endif
			#elif LIGHTMAP_INNER
				float2 lightmapUV : TEXCOORD8;
			#endif

			//render texture reflect
			/*#if defined(_RENDERTEX_REFLECT)
				float4 screenPos : TEXCOORD9;
			#endif*/

			#if defined(DYNAMICLIGHTMAP_ON)
				float2 dynamicLightmapUV : TEXCOORD10;
			#endif
		};			

		//render texture reflect 
		/*#if defined(_RENDERTEX_REFLECT)
			sampler2D _RefTex;
		#endif*/


		//自发光贴图
		//sampler2D _EmissionMap;
		float4 _Emission;
			
		#if LIGHTMAP_UNITY
			////第一个纹理
			sampler2D _MainTex;
			float4 _MainTex_ST;

			sampler2D _LightMap;
			float4 _LightMap_ST;
			
			//纹理颜色
			half4 _Color;		
			float _Cutoff;
		#endif	

		//法线,法线强度
		sampler2D _MainNromalMap;
		float _NormalAmoutnN1;
		float _Occlusion;

		//是否使用顶点色通道纹理,法线,颜色
		// G B Tex
		#if defined (_RGB_MASK_VERTEX) || defined(_RGB_VERTEX) || defined(_RGB_MASK_PROPS) || defined(_RGB_VERTEX_PRECIPICE) 
			sampler2D _GTex, _BTex;
			float4 _GTex_ST, _BTex_ST;
			sampler2D _GNormalMap, _BNormalMap;
			half4 _ColorGVertex;
			half4 _ColorBVertex;
			half _MetallicG,_MetallicB;
			half _RoughnessG, _RoughnessB;
		#endif

		//G Tex
		#if defined(_MASK_G_WINDOWS) || defined(_RG_MASK_VERTEX) || defined(_RG_VERTEX) || defined(_RG_MASK_PROPS) 
			sampler2D _GTex;
			float4 _GTex_ST;
			sampler2D _GNormalMap;
			half4 _ColorGVertex;
			half _MetallicG;
			half _RoughnessG;
		#endif

		////地面 mask uv3 
		//#if defined(DETAIL)
		//	sampler2D _MaskTex;
		//#endif // defined(MASK_DETAIL)

		//建筑 mask 贴图 颜色 ao 强度 uv1 通道
		#if defined(OBJECT_MASK_UV1) 
			sampler2D _MaskTex;
			float4 _MaskTex_ST;

			float4 _ColorG;
			float4 _ColorB;
		#endif

		//地面 mask uv3通道
		#if defined(_MASK_DETAIL)
			sampler2D _MaskTex;
			float4 _MaskTex_ST;

		#endif 


		//建筑 mask 贴图 颜色 ao 强度 uv3通道
		#if defined (MASK_ON) || defined(WINDOWS_ON) 
			sampler2D _MaskTex;
			float4 _MaskTex_ST;
			sampler2D _MaskNromalMap;
			half4 _ColorGlass;
			half4 _ColorG;
			half4 _ColorB;			
			float _GassMetallic;
			float _GlassRoughness;
		#endif		

		//金属度粗糙度
		half _Metallic;
		half _Roughness;

		//Ground 地面着色器,高度图强度
		half _Strength;

		//tex2D(XXXXXX) 两次重复采样会在编译后代码中只采样一次
		//金属度
		float GetMetallic(VertexOutput i)
		{		
			float metallic = _Metallic;			
			
			#if defined(_MAINTEX)
				metallic = tex2D(_MainNromalMap, i.uv.xy).a * _Metallic;
			#endif


			/*#if defined(_RG_VERTEX) || defined(_RG_MASK_VERTEX) || defined(_RG_MASK_PROPS)
				metallic = _Metallic * (i.color.r + i.color.b) + _MetallicG * i.color.g;
			#endif

			#if defined(_RGB_VERTEX) || defined(_RGB_MASK_VERTEX) || defined(_RGB_MASK_PROPS) || defined(_RGB_VERTEX_PRECIPICE)
				metallic = _Metallic * i.color.r + _MetallicG * i.color.g + _MetallicB * i.color.b;
			#endif*/

			#if defined(_MAINTEX_WINDOWS)
				half4 maskTex = tex2D(_MaskTex, i.uv3);
				metallic = maskTex.b * _GassMetallic + _Metallic * (1 - maskTex.b);
			#endif

			#if defined(_MASK_G_WINDOWS)
				half4 maskTex = tex2D(_MaskTex, i.uv3);
				metallic = maskTex.b * _GassMetallic + (_Metallic *  maskTex.g + _MetallicG * (1 - maskTex.g)) * (1 - maskTex.b);
			#endif

			//顶点色通道使用
			#if defined (_MIAN_VERTEX) || defined(_MASK_MAINTEX) || defined(_MAIN_MASK_PROPS)
				metallic = tex2D(_MainNromalMap, i.uv.xy).a * _Metallic;
			#endif

			#if defined(_RG_VERTEX) || defined(_RG_MASK_VERTEX) || defined(_RG_MASK_PROPS)
				float metallicR = tex2D(_MainNromalMap, i.uv.xy).a * (i.color.r + i.color.b) * _Metallic;
				float metallicG = tex2D(_GNormalMap, i.uv.zw).a * i.color.g * _MetallicG;
				metallic = (metallicR + metallicG);
			#endif

			#if defined(_RGB_VERTEX) || defined(_RGB_MASK_VERTEX) || defined(_RGB_MASK_PROPS) 
				float metallicR = tex2D(_MainNromalMap, i.uv.xy).a * i.color.r * _Metallic;
				float metallicG = tex2D(_GNormalMap, i.uv.zw).a * i.color.g * _MetallicG;
				float metallicB = tex2D(_BNormalMap, i.uv2).a * i.color.b * _MetallicB;
				metallic = (metallicR + metallicG + metallicB);
			#endif

			return metallic;
		}


		//inline half OneMinusReflectivityFromMetallic(half metallic)
		//{
		//	// We'll need oneMinusReflectivity, so
		//	//   1-reflectivity = 1-lerp(dielectricSpec, 1, metallic) = lerp(1-dielectricSpec, 0, metallic)
		//	// store (1-dielectricSpec) in unity_ColorSpaceDielectricSpec.a, then
		//	//    1-reflectivity = lerp(alpha, 0, metallic) = alpha + metallic*(0 - alpha) =
		//	//                  = alpha - metallic * alpha
		//	half oneMinusDielectricSpec = unity_ColorSpaceDielectricSpec.a;
		//	return oneMinusDielectricSpec - metallic * oneMinusDielectricSpec;
		//}

		//inline half3 DiffuseAndSpecularFromMetallic(half3 albedo, half metallic, out half3 specColor, out half oneMinusReflectivity)
		//{
		//	specColor = lerp(unity_ColorSpaceDielectricSpec.rgb, albedo, metallic);
		//	oneMinusReflectivity = OneMinusReflectivityFromMetallic(metallic);
		//	return albedo * oneMinusReflectivity;
		//}


		//粗糙度
		float GetRoughness(VertexOutput i)
		{
			float roughness =  _Roughness;

			#if defined(_MAINTEX)
				roughness *= tex2D(_MainNromalMap, i.uv.xy).b;
			#endif

							   
			#if defined(WINDOWS_ON)
				half4 maskTex = tex2D(_MaskTex, i.uv3);
			#endif								

			//顶点色通道使用
			#if defined (_MIAN_VERTEX) || defined(_MASK_MAINTEX) || defined(_MAIN_MASK_PROPS)
				roughness = tex2D(_MainNromalMap, i.uv.xy).b * _Roughness;
			#endif

			#if defined(_RG_VERTEX) || defined(_RG_MASK_VERTEX) || defined(_RG_MASK_PROPS)
				float roughnessR = tex2D(_MainNromalMap, i.uv.xy).b * (i.color.r + i.color.b) * _Roughness;
				float roughnessG = tex2D(_GNormalMap, i.uv.zw).b * i.color.g * _RoughnessG;
				roughness = (roughnessR + roughnessG) ;
			#endif

			#if defined(_RGB_VERTEX) || defined(_RGB_MASK_VERTEX) || defined(_RGB_MASK_PROPS) 
				float roughnessR = tex2D(_MainNromalMap, i.uv.xy).b * i.color.r * _Roughness;
				float roughnessG = tex2D(_GNormalMap, i.uv.zw).b * i.color.g * _RoughnessG;
				float roughnessB = tex2D(_BNormalMap, i.uv2).b * i.color.b * _RoughnessB;
				roughness = (roughnessR + roughnessG + roughnessB) ;
			#endif	

			#if defined(_RGB_VERTEX_PRECIPICE)
				float roughnessR = tex2D(_MainTex, i.uv.xy).a * i.color.r * _Roughness;
				float roughnessG = tex2D(_GTex, i.uv.xy).a * i.color.g * _RoughnessG;
				float roughnessB = tex2D(_BTex, i.uv3.xy).a * i.color.b * _RoughnessB;
				roughness = (roughnessR + roughnessG + roughnessB);
			#endif

			#if defined(_MAINTEX_WINDOWS)
				roughness = tex2D(_MainTex, i.uv.xy).a * _Roughness * (1 -  maskTex.b)  + (maskTex.b * _GlassRoughness);
			#endif

			#if defined(_MASK_G_WINDOWS)
				float roughnessM = tex2D(_MainTex, i.uv.xy).a * _Roughness * maskTex.g;
				float roughnessG = tex2D(_GTex, i.uv.xy).a * _RoughnessG * (1 - maskTex.g);
				roughness = (roughnessM + roughnessG) * (1 - maskTex.b) + (maskTex.b * _GlassRoughness);
			#endif			

			return roughness;
		}
		
		//normal 转换	
		inline fixed3 UnpackNormalmapCustom(fixed4 packednormal, half bumpScale)
		{
			// This do the trick
			//packednormal.x *= packednormal.w;

			fixed3 normal;
			normal.xy = packednormal.xy * 2 - 1;
			normal.xy *= bumpScale;
			normal.z = sqrt(1 - saturate(dot(normal.xy, normal.xy)));
			return normal;
		}

		//Normal
		float3 GetTangentSpaceNormal(VertexOutput i)
		{
			float3 normal = float3(0, 0, 1);

			#if defined(_MAINTEX)
				normal = UnpackNormalmapCustom(tex2D(_MainNromalMap, i.uv.xy), _NormalAmoutnN1);
			#endif

			#if defined(WINDOWS_ON)
				half4 maskTex = tex2D(_MaskTex, i.uv3);
			#endif

			//顶点色与带mask通道顶点色的normal
			#if defined(_MIAN_VERTEX) 
				normal = UnpackNormalmapCustom(tex2D(_MainNromalMap, i.uv.xy), _NormalAmoutnN1);
			#endif			
			
			//mask 混合法线
			#if defined(_MASK_MAINTEX)
				float3 mainNormal = UnpackScaleNormal(tex2D(_MainNromalMap, i.uv.xy), _NormalAmoutnN1);
				float3 maskNormal = UnpackScaleNormal(tex2D(_MaskNromalMap, i.uv3), _NormalAmoutnN1);
				normal = BlendNormals(mainNormal, maskNormal);
			#endif
			//顶色 mask混合法线
			#if defined(_RG_VERTEX) || defined(_RG_MASK_VERTEX)
				float3 normalR = UnpackNormalmapCustom(tex2D(_MainNromalMap, i.uv.xy), _NormalAmoutnN1);
				float3 normalG = UnpackNormalmapCustom(tex2D(_GNormalMap, i.uv.zw), _NormalAmoutnN1);
				normal = normalR *  ( i.color.r + i.color.b) + normalG * i.color.g;
			#endif
			//顶点色 RGB 法线混合
			#if defined(_RGB_VERTEX) || defined(_RGB_MASK_VERTEX) 
				float3 normalR = UnpackNormalmapCustom(tex2D(_MainNromalMap, i.uv.xy), _NormalAmoutnN1);
				float3 normalG = UnpackNormalmapCustom(tex2D(_GNormalMap, i.uv.zw), _NormalAmoutnN1);
				float3 normalB = UnpackNormalmapCustom(tex2D(_BNormalMap, i.uv2), _NormalAmoutnN1);
				normal = normalR * i.color.r + normalG * i.color.g + normalB * i.color.b;
			#endif

			#if defined(_RGB_VERTEX_PRECIPICE)
				float3 normalR = UnpackScaleNormal(tex2D(_MainNromalMap, i.uv.xy), _NormalAmoutnN1);
				float3 normalG = UnpackScaleNormal(tex2D(_GNormalMap, i.uv.xy), _NormalAmoutnN1);
				float3 normalB = UnpackScaleNormal(tex2D(_BNormalMap, i.uv3.xy), _NormalAmoutnN1);
				normal = normalR * i.color.r + normalG * i.color.g + normalB * i.color.b;
			#endif
			
			//窗户着色器法线混合方式
			#if defined(_MAINTEX_WINDOWS)
				float3 mainNormal = UnpackScaleNormal(tex2D(_MainNromalMap, i.uv.xy), _NormalAmoutnN1);
				mainNormal.xy = mainNormal.xy *  (1 - maskTex.b);
				float3 maskNormal = UnpackScaleNormal(tex2D(_MaskNromalMap, i.uv3), _NormalAmoutnN1);
				normal = BlendNormals(mainNormal, maskNormal);
			#endif

				//窗户mask G 通道混合
			#if defined(_MASK_G_WINDOWS)
				float3 mainNormal = UnpackScaleNormal(tex2D(_MainNromalMap, i.uv.xy), _NormalAmoutnN1);
				mainNormal.xy = mainNormal.xy * maskTex.g;
				float3 normalG = UnpackScaleNormal(tex2D(_GNormalMap, i.uv.xy), _NormalAmoutnN1);
				normalG.xy = normalG.xy * (1 - maskTex.g);
				float3 normalGMixture = BlendNormals(mainNormal, normalG);
				normalGMixture.xy = normalGMixture.xy * (1 - maskTex.b);
				float3 maskNormal = UnpackScaleNormal(tex2D(_MaskNromalMap, i.uv3), _NormalAmoutnN1);
				normal = BlendNormals(normalGMixture, maskNormal);
			#endif

			//顶点色 mask 法线
			#if defined(_MAIN_MASK_PROPS) || defined(_RG_MASK_PROPS) || defined(_RGB_MASK_PROPS)
				normal = UnpackScaleNormal(tex2D(_MaskNromalMap, i.uv3), _NormalAmoutnN1);
			#endif 		

			//地面mask 法线混合
			#if	defined(_MASK_DETAIL)
				float3 maskNormal = UnpackNormalmapCustom(tex2D(_MaskTex, i.uv3), _NormalAmoutnN1);
				normal = BlendNormals(maskNormal,normal);
			#endif
			return normal;
		}

		//Ground 地面高度图混合
		inline half3 Blend(half colR, half colG, half colB, half3 vertexColor)
		{
			half3 blend;
			blend.r = colR * vertexColor.r;
			blend.g = colG * vertexColor.g;
			blend.b = colB * vertexColor.b;

			half ma = max(blend.r, max(blend.g, blend.b));
			blend = max(blend - ma + _Strength, 0) * vertexColor;
			return blend / (blend.r + blend.g + blend.b);
		}

		//自发光贴图
		float3 GetEmission(VertexOutput i)
		{
			float3 emission = float3(0, 0, 0);
			//前向渲染
			#if defined (FORWARD_BASE_PASS)
				#if defined(_EMISSION_MAP)						
						emission = tex2D(_MainTex, i.uv.xy).a * _Emission.rgb;
						return emission;
					#else
						return 0;
					#endif
				#else
						return emission;
			#endif			
		}
		
	/*	float GetAlpha(VertexOutput i)
		{
			float alpha = _Color.a;		

			#if !defined(_SMOOTHNESS_ALBEDO)
				alpha *= tex2D(_MainTex, i.uv.xy).a;
			#endif
			
			return alpha;
		}*/

		//AO
		float GetOcclusion(VertexOutput i)
		{
			//mask.r = ao 
			float ao = 1;

			//所有mask通道 窗户 ao uv3
			#if defined (MASK_ON) || defined (WINDOWS_ON)
				ao = lerp(1, tex2D(_MaskTex, i.uv3).r, _Occlusion);
			#endif	

			//#if defined(_MASK_DETAIL)
			//	ao = lerp(1, tex2D(_MaskTex, i.uv3).b, _Occlusion);
			//#endif // defined(_MASK_DETAIL)


			#if	defined(OBJECT_MASK_UV1)
				ao = lerp(1, tex2D(_MaskTex, i.uv.xy).r, _Occlusion);
			#endif


			/*#if defined(_RENDERING_FADE) || defined(_RENDERING_TRANSPARENT)
				half mainTex = tex2D(_MainTex, i.uv.xy).r;
				ao = lerp(1, mainTex, _Occlusion);
			#endif*/
			return ao;
		}

		//Albedo
		float3 GetAlbedo(VertexOutput i)
		{					
			//反射率
			half3 albedo = half3(1,1,1);			

			//角色与半透明物件不直接使用颜色乘以第一张纹理
			#if !defined(_RENDERING_FADE) && !defined(_RENDERING_TRANSPARENT)
				half4 mainTex = tex2D(_MainTex, i.uv.xy) * _Color;
			#endif

			//uv1 顶点色
			#if defined(_MAINTEX)
				half3 maskG = tex2D(_MaskTex, i.uv.xy).rgb;				
				//albedo = lerp(mainTex,mainTex * maskGColor, _ColorG.a);
				half3 colorG = mainTex *  maskG.g + mainTex * _ColorG.rgb * (1 - maskG.g);
				half3 halfColorG = colorG * maskG.b * _ColorB.rgb * maskG.b + _ColorB.rgb * maskG.b * 0.25;
				half3 colorB = colorG * (1 - maskG.b) * _Color.rgb + halfColorG;
				albedo = colorB;
			#endif

			//mask 遮罩
			#if defined (MASK_ON) || defined(_MASK_DETAIL)
				half4 maskTex = tex2D(_MaskTex, i.uv3);
			#endif			

			//窗户着色器
			#if defined (WINDOWS_ON)
				half4 maskTex = tex2D(_MaskTex, i.uv3);
				half3 windowCol = _ColorGlass.rgb * maskTex.b;
			#endif
			
			//顶点色mask G Tex
			#if defined (_RG_MASK_VERTEX) || defined(_RG_VERTEX) || defined(_MASK_G_WINDOWS) ||defined(_RG_MASK_PROPS)
				half4 GTex = tex2D(_GTex, i.uv.zw) * _ColorGVertex;
			#endif

			//使用顶点色的R G B 通道
			#if defined (_RGB_MASK_VERTEX) || defined(_RGB_VERTEX) || defined(_RGB_MASK_PROPS)
				half4 GTex = tex2D(_GTex, i.uv.zw) * _ColorGVertex;
				half4 BTex = tex2D(_BTex, i.uv2.xy) * _ColorBVertex;
			#endif	

			//崖壁顶点色 R G B 通道
			#if defined(_RGB_VERTEX_PRECIPICE)
				half4 GTex = tex2D(_GTex, i.uv.zw) * _ColorGVertex;
				half4 BTex = tex2D(_BTex, i.uv3.xy) * _ColorBVertex;
			#endif 


			#if defined(_MAINTEX_WINDOWS)
				albedo = mainTex.rgb *  (1 - maskTex.b)+ windowCol;
				albedo = lerp(albedo, albedo* maskTex.r, _Occlusion);
			#endif
			//mask G 通道混合
			#if defined(_MASK_G_WINDOWS)
				half3 MaskG = (mainTex.rgb * maskTex.g + GTex.rgb *  (1 - maskTex.g)) * (1 - maskTex.b);
				albedo = MaskG + windowCol;
				albedo = lerp(albedo, albedo* maskTex.r, _Occlusion);
			#endif

			//mask G B 通道的混合计算,G换色通道,B金属度
			#if defined (_MASK_MAINTEX) || defined(_MAIN_MASK_PROPS)
				half3 mainCol = mainTex.rgb * (maskTex.b) * _ColorB.rgb * _ColorB.a * 2 + mainTex.rgb * (1 - maskTex.b);
				half maskMixtureCol = lerp(maskTex.g * mainTex.a, 1, maskTex.g);
				albedo = lerp(mainCol, mainCol * _ColorG.rgb, _ColorG.a * 2 * (1 - (maskMixtureCol)));
				albedo = lerp(albedo, albedo * maskTex.r, _Occlusion);
			#endif

			//mask R G 换色通道的混合计算 
			#if defined (_RG_MASK_VERTEX) || defined(_RG_MASK_PROPS)
				half3 RGCol = (mainTex.rgb * (i.color.r + i.color.b) + GTex.rgb * i.color.g);
				//mask.B通道颜色混合
				RGCol = RGCol * maskTex.b * _ColorB.rgb * _ColorB.a * 2 + RGCol * (1 - maskTex.b);
				//RG roughness
				half RGColA = (mainTex.a *  (i.color.g + i.color.b) + GTex.a * i.color.g );
				//mask.G通道颜色混合
				half maskMixtureCol = lerp(maskTex.g * RGColA, 1, maskTex.g);
				albedo = lerp(RGCol, RGCol * _ColorG.rgb, _ColorG.a * 2 * (1 - (maskMixtureCol)));
				albedo = lerp(albedo, albedo * maskTex.r, _Occlusion);

			#endif

			#if defined (_RGB_MASK_VERTEX) || defined(_RGB_MASK_PROPS)
				half3 RGBCol = (mainTex.rgb *  i.color.r + GTex.rgb * i.color.g + BTex.rgb * i.color.b);
				//mask.B通道颜色混合
				RGBCol = RGBCol * maskTex.b * _ColorB.rgb * _ColorB.a * 2 + RGBCol * (1 - maskTex.b);
				//RGB roughness
				half RGBColA = (mainTex.a * i.color.r + GTex.a * i.color.g + BTex.a * i.color.b);
				//mask.G通道颜色混合
				half maskMixtureCol = lerp(maskTex.g * RGBColA, 1, maskTex.g);
				albedo = lerp(RGBCol, RGBCol * _ColorG.rgb, _ColorG.a * 2 * (1 - (maskMixtureCol)));
				albedo = lerp(albedo, albedo * maskTex.r, _Occlusion);

			#endif	

		/*	#if defined(_RENDERING_CUTOUT) 
				albedo = mainTex.rgb;
			#endif*/

			#if  defined(_MIAN_VERTEX)
				albedo = mainTex.rgb;				
			#endif // defined(_MIAN_VERTEX)

			#if defined(_RENDERING_FADE) || defined(_RENDERING_TRANSPARENT)
				half3 mainTex = tex2D(_MainTex, i.uv.xy).r * _Color.rgb;
				albedo = mainTex.rgb;
			#endif
			
			//地面 顶点色混合 RG
			#if defined(_RG_VERTEX)
				half3 blend = Blend(mainTex.r, GTex.r, 1, i.color.rgb);
				albedo = mainTex.rgb * (blend.r + blend.b) + GTex.rgb * blend.g;
			#endif

			//地面 顶点色混合 RGB
			#if defined (_RGB_VERTEX)
				half3 blend = Blend(mainTex.r, GTex.r, BTex.r, i.color.rgb);
				albedo = mainTex.rgb *  blend.r + GTex.rgb * blend.g + BTex.rgb * blend.b;
			#endif

			// 崖壁 顶点色混合计算
			#if defined(_RGB_VERTEX_PRECIPICE)
				half3 blend = Blend(mainTex.a, GTex.a, BTex.a, i.color.rgb);
				albedo = mainTex.rgb *  blend.r + GTex.rgb * blend.g + BTex.rgb * blend.b;
			#endif
			
			//#if defined(_MASK_DETAIL)
			//	albedo = maskTex.rgb;
			//#endif // defined(_MASK_DETAIL)

			//显示顶点色
			#if defined (_VERTEX_COLOR)
				albedo = i.color.rgb;
			#endif

			return albedo;		
		}			
		
		//render texture reflect
	/*	#if defined(_RENDERTEX_REFLECT)
			float3 GetRenderTexReflect(VertexOutput i)
			{
				fixed4 reflectColor = fixed4(1, 1, 1, 1);			
				reflectColor = tex2D(_RefTex, i.screenPos.xy / i.screenPos.w);
				return reflectColor.rgb * reflectColor.a;
			}
		#endif	*/
		//创造法线
		float3 CreateBinormal(float3 normal, float3 tangent, float binormalSign)
		{
			//unity_WorldTransformParams 防止镜像切线空间没有同步镜像
			return cross(normal, tangent.xyz) * (binormalSign * unity_WorldTransformParams.w);
		}
			
		//顶点运算
		VertexOutput MyVertexProgram (VertexInput v)
		{
			//UNITY_INITIALIZE_OUTPUT 初始化VertexOutput
			VertexOutput o;
			UNITY_INITIALIZE_OUTPUT(VertexOutput, o);

			o.pos = UnityObjectToClipPos(v.vertex);

			//设置交换uv通道位置
			float2 inputUV = v.uv;

			//#if defined(_GROUND_UV3) 
			//	inputUV = v.uv3;
			//#endif // defined(_GROUND_UV3)
				
			#if defined(UV3_ON) 
				float2 inputUV3 = v.uv3;			
			#endif // defined(UV3_ON)

			//顶点色 uv R 
			o.uv.xy = TRANSFORM_TEX(inputUV, _MainTex);

			//顶点色 uv G
			#if defined(_MASK_G_WINDOWS) || defined(_RG_MASK_VERTEX) || defined(_RG_VERTEX) || defined(_RG_MASK_PROPS) 
				o.uv.zw = TRANSFORM_TEX(inputUV, _GTex);
			#endif
			//顶点色 uv B
			#if defined (_RGB_MASK_VERTEX) || defined(_RGB_VERTEX) || defined(_RGB_MASK_PROPS) || defined(_RGB_VERTEX_PRECIPICE) 
				o.uv.zw = TRANSFORM_TEX(v.uv, _GTex);
				o.uv2 = TRANSFORM_TEX(v.uv, _BTex);
			#endif

			//mask UV3
			#if defined(MASK_ON) || defined(WINDOWS_ON) || defined(_MASK_DETAIL)
				o.uv3 = TRANSFORM_TEX(inputUV3, _MaskTex);
				//o.uv3 = v.uv3;
			#endif
			//崖壁 UV3
			#if defined(_RGB_VERTEX_PRECIPICE)
				o.uv3 = TRANSFORM_TEX(inputUV3, _MainTex);
			#endif

			//render texture reflect
			/*#if defined(_RENDERTEX_REFLECT)
				o.screenPos = ComputeScreenPos(o.pos);
			#endif*/

			o.color = v.color;

			o.normal = UnityObjectToWorldNormal(v.normal);
			//切线方向,从世界转换到物体
			#if defined(BINORMAL_PER_FRAGMENT)
				o.tangent = float4(UnityObjectToWorldDir(v.tangent.xyz), v.tangent.w);
			#else
				o.tangent = UnityObjectToWorldDir(v.tangent.xyz);
				o.binormal = CreateBinormal(o.normal, o.tangent,v.tangent.w);
			#endif

			o.worldPos.xyz = mul(unity_ObjectToWorld, v.vertex);

			//fog 屏幕空间深度
			#if FOG_DEPTH
				o.worldPos.w = o.pos.z;
			#endif

			UNITY_TRANSFER_SHADOW(o, v.uv1);
			#if LIGHTMAP_UNITY
				#if defined(LIGHTMAP_ON) || ADDITIONAL_MASKED_DIRECTIONAL_SHADOWS
					o.lightmapUV = v.uv1 * unity_LightmapST.xy + unity_LightmapST.zw;
				#endif
			#else
				o.lightmapUV = v.uv1 * _LightMap_ST.xy + _LightMap_ST.zw;
			#endif

			#if defined(DYNAMICLIGHTMAP_ON)
				o.dynamicLightmapUV = v.uv2 * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
			#endif

			return o;
		}

		//Unity 阴影淡入淡出
		#if LIGHTMAP_UNITY
			float FadeShadows(VertexOutput i, float attenuation)
			{
				//HANDLE_SHADOWS_BLENDING_IN_GI 跳过阴影,烘焙阴影进行淡化过度 
				//ADDITIONAL_MASKED_DIRECTIONAL_SHADOWS 多灯情况下的衰减
				#if HANDLE_SHADOWS_BLENDING_IN_GI || ADDITIONAL_MASKED_DIRECTIONAL_SHADOWS
					#if ADDITIONAL_MASKED_DIRECTIONAL_SHADOWS
						attenuation = SHADOW_ATTENUATION(i);
					#endif
					float viewZ = dot(_WorldSpaceCameraPos - i.worldPos, UNITY_MATRIX_V[2].xyz);
					float shadowFadeDistance = UnityComputeShadowFadeDistance(i.worldPos, viewZ);
					float shadowFade = UnityComputeShadowFade(shadowFadeDistance);
					//对阴影贴图进行采样
					float bakedAttenuation = UnitySampleBakedOcclusion(i.lightmapUV, i.worldPos);
					//阴影衰减
					attenuation = UnityMixRealtimeAndBakedShadows(attenuation, bakedAttenuation, shadowFade);
				#endif
					return attenuation;
					
			}
		#endif
				
		//Unity 光源计算方式
		#if LIGHTMAP_UNITY
			UnityLight CreateLight(VertexOutput i)
			{
				UnityLight light;				

				#if SUBTRACTIVE_LIGHTING
					light.dir = float3(0, 1, 1);
					light.color = 0;
				#else
					#if defined(POINT) || defined(SPOT) || defined(POINT_COOKIE)
					//点光源方向
						light.dir = normalize(_WorldSpaceLightPos0.xyz - i.worldPos.xyz);
					#else
					//方向灯
						light.dir = _WorldSpaceLightPos0.xyz;
					#endif
			
					// #define POINT 写入才可正确引用
					//内置使用方法
					UNITY_LIGHT_ATTENUATION(attenuation, i, i.worldPos.xyz);

					//阴影淡入淡出
					attenuation = FadeShadows(i, attenuation);

					light.color = _LightColor0.rgb * attenuation;
				#endif

				//light.ndotl = DotClamped(i.normal, light.dir);
				return light;
			}
		#endif

		//Unity 计算反射盒体位置
		#if LIGHTMAP_UNITY
			float3 BoxProjection(float3 direction,float3 position,float4 cubemapPosition,float3 boxMin,float3 boxMax)
			{	
				#if UNITY_SPECCUBE_BOX_PROJECTION
					UNITY_BRANCH
					//if 在这里只会得到一个条件赋值 最终所有颜色处理会使用相同的天空盒探针设置
					if (cubemapPosition.w > 0)
					{
						//调整边界
						boxMin -= position;
						boxMax -= position;
						//将位置指向最大与最小边界	
						float3 factors = ((direction > 0 ? boxMax : boxMin) - position) / direction;
						//取得最小值,最接近边界位置
						float scalar = min(min(factors.x, factors.y), factors.z);
						direction = direction * scalar + (position - cubemapPosition);
					}
				#endif
				return direction ;
			}
		#endif		

		//内部 FadeShadows
		#if LIGHTMAP_INNER
			float FadeShadows2(VertexOutput i, float attenuation) 
			{

				float viewZ = dot(_WorldSpaceCameraPos - i.worldPos, UNITY_MATRIX_V[2].xyz);
				float shadowFadeDistance = UnityComputeShadowFadeDistanceExpand(i.worldPos, viewZ);//求影子距离

				float shadowFade = UnityComputeShadowFadeExpand(shadowFadeDistance);

				float bakedAttenuation = ComputMask(i.lightmapUV, i.worldPos, _LightMap);//烘焙的影子

				attenuation = lerp(attenuation, bakedAttenuation, shadowFade);//UnityMixRealtimeAndBakedShadowsExpand(attenuation, bakedAttenuation, shadowFade);
				return attenuation;
			}
		#endif

		float3 NormalCount(VertexOutput i)
		{
			float3 tangentSpaceNormal = GetTangentSpaceNormal(i);
			//unity 内置混合法线 方式与上方相同
			#if defined(BINORMAL_PER_FRAGMENT)
					float3 binormal = CreateBinormal(i.normal, i.tangent.xyz, i.tangent.w);
			#else
					float3 binormal = i.binormal;
			#endif		
			//将法线从切线空间转换到世界空间
			i.normal = normalize(
				tangentSpaceNormal.x * i.tangent +
				tangentSpaceNormal.y * binormal +
				tangentSpaceNormal.z * i.normal
			);
			float3 normal = i.normal;
			return normal;
		}

		//normal
		void InitializeFragmentNormal(inout VertexOutput i)
		{
			//剥离计算,提供给角色皮肤读取法线			
			i.normal = NormalCount(i);
		}	

		//减去模式下的间接光 通常不做计算
		void ApplySubtractiveLighting(VertexOutput i, inout UnityIndirect indirectLight)
		{
			#if SUBTRACTIVE_LIGHTING
				//获取阴影衰减
				UNITY_LIGHT_ATTENUATION(attenuation, i, i.worldPos.xyz);
				attenuation = FadeShadows(i, attenuation);
				//计算Lambert 光照模型
				float ndotl = saturate(dot(i.normal, _WorldSpaceLightPos0.xyz));
				//Lambert 与光照贴图阴影衰减 灯光颜色 相乘 得到阴影阻挡的光线亮度
				float3 shadowedLightEstimate = ndotl * (1 - attenuation) * _LightColor0.rgb;
				//从光照贴图中减去该值，得到最后调整的光线亮度
				float3 subtractedLight = indirectLight.diffuse - shadowedLightEstimate;
				//取得光照贴图颜色,取最大值,更好匹配场景,防止阴影叠加
				subtractedLight = lerp(subtractedLight, unity_ShadowColor.rgb,_LightShadowData.x);
				//subtractedLight.diffuse = subtractedLight;
				indirectLight.diffuse = min(subtractedLight, indirectLight.diffuse);
				
			#endif
		}

		//Unity 间接光
		#if LIGHTMAP_UNITY
			UnityIndirect CreateIndirectLight(VertexOutput i,float3 viewDir)
			{
				UnityIndirect indirectLight;
				indirectLight.diffuse = 0;
				indirectLight.specular = 0;			
				
				//球谐函数 在前向渲染与延迟渲染下计算
				#if defined(FORWARD_BASE_PASS) 
					//当光照贴图使用时,不使用球面谐波当做间接光
					#if defined(LIGHTMAP_ON)
						//DecodeLightmap 为贴图解码
						indirectLight.diffuse = DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, i.lightmapUV));
						//烘焙贴图方向贴图  对方向贴图进行采样
						#if defined(DIRLIGHTMAP_COMBINED)
							float4 lightmapDirection = UNITY_SAMPLE_TEX2D_SAMPLER(unity_LightmapInd,unity_Lightmap, i.lightmapUV);
							//使用方向贴图,用DecodeDirectionalLightmap来解码方向数据并最终着色
							indirectLight.diffuse = DecodeDirectionalLightmap(indirectLight.diffuse, lightmapDirection, i.normal);
						#endif
						//减法模式下的间接光
						ApplySubtractiveLighting(i, indirectLight);


					//不在这里分配diffuse颜色,实时地图使用不同的颜色格式,因此数据可能会添加到烘焙照明中
					/*#else							
						indirectLight.diffuse += max(0, ShadeSH9(float4(i.normal, 1)));*/
					#endif

					//实时GI 烘焙贴图
					#if defined(DYNAMICLIGHTMAP_ON)

						float3 dynamicLightDiffuse = DecodeRealtimeLightmap(UNITY_SAMPLE_TEX2D(unity_DynamicLightmap, i.dynamicLightmapUV));

						#if defined(DIRLIGHTMAP_COMBINED)
							float4 dynamicLightmapDirection = UNITY_SAMPLE_TEX2D_SAMPLER(unity_DynamicDirectionality, unity_DynamicLightmap, i.dynamicLightmapUV);
							indirectLight.diffuse += DecodeDirectionalLightmap(dynamicLightDiffuse, dynamicLightmapDirection, i.normal);
						#else
						indirectLight.diffuse += dynamicLightDiffuse;
						#endif
					#endif

					#if !defined(LIGHTMAP_ON) && !defined(DYNAMICLIGHTMAP_ON)
						indirectLight.diffuse += max(0, ShadeSH9(float4(i.normal, 1)));
					#endif


					float3 reflectionDir = reflect(-viewDir, i.normal);			

					//unity内置 Unity_GlossyEnvironment 实面反射 粗糙度 CUBE mipmap级别过渡
					Unity_GlossyEnvironmentData envData;
					envData.roughness = GetRoughness(i);
					//反射盒体位置 插值2个盒体探针
					envData.reflUVW = BoxProjection(reflectionDir,
						i.worldPos.xyz,unity_SpecCube0_ProbePosition,
						unity_SpecCube0_BoxMin,unity_SpecCube0_BoxMax);				
					float3 probe0 = Unity_GlossyEnvironment(UNITY_PASS_TEXCUBE(unity_SpecCube0), unity_SpecCube0_HDR, envData);
					envData.reflUVW = BoxProjection(reflectionDir,
						i.worldPos.xyz, unity_SpecCube1_ProbePosition,
						unity_SpecCube1_BoxMin, unity_SpecCube1_BoxMax);

					//如果平台不能处理探针混合，那么使用探针0
					#if UNITY_SPECCUBE_BLENDING
						float interpolator = unity_SpecCube0_BoxMin.w;
						//优化计算,只有在两个探针存在时才会计算插值混合
						UNITY_BRANCH
						if (interpolator < 0.99999)
						{
							float3 probe1 = Unity_GlossyEnvironment(UNITY_PASS_TEXCUBE_SAMPLER(unity_SpecCube1, unity_SpecCube0), unity_SpecCube1_HDR, envData);

							indirectLight.specular = lerp(probe1, probe0, unity_SpecCube0_BoxMin.w);
						}
						else
						{
							indirectLight.specular = probe0;
						}
					#else
						indirectLight.specular = probe0;
					#endif
						//ao
						float occluison = GetOcclusion(i);
						indirectLight.diffuse *= occluison;
						indirectLight.specular *= occluison;

					//在延迟渲染模式下,对反射盒进行判断
					#if defined(DEFERRED_PASS) && UNITY_ENABLE_REFLECTION_BUFFERS
						indirectLight.specular = 0;
					#endif		


				#endif
				return indirectLight;
			}
		#endif

		//fog
		float4 ApplyFog(float4 color, VertexOutput i)
		{
			#if FOG_ON
				//相机与顶点的视线距离
				float viewDistance = length(_WorldSpaceCameraPos - i.worldPos.xyz);

				//fog 屏幕空间深度
				#if FOG_DEPTH
					viewDistance = UNITY_Z_0_FAR_FROM_CLIPSPACE(i.worldPos.w);
				#endif

				//unity 宏计算, 内部创建unityFogFactory变量,在Fog与像素颜色之间插值 Fog颜色存储在unity_FogColor
				UNITY_CALC_FOG_FACTOR_RAW(viewDistance);

				//ForwardAdd下将雾颜色设置为黑色,避免重复计算导致雾过亮,只在FORWARD_BASE_PASS计算
				float3 fogColor = 0;

				#if defined(FORWARD_BASE_PASS)
					fogColor = unity_FogColor.rgb;
				#endif

				color.rgb = lerp(fogColor, color.rgb, saturate(unityFogFactor));
			#endif
			return color;
		}
		
		//内部 BRDF_PBS2
		#if LIGHTMAP_INNER
			//pbs 算法
			//half4 BRDF_PBS2(half3 diffColor, half3 specColor, half oneMinusReflectivity, half smoothness, float3 normal, float3 viewDir, UnityLight light, UnityIndirect gi)
			//{
			//	float3 reflDir = reflect(viewDir, normal);

			//	half nl = saturate(dot(normal, light.dir));
			//	half nv = saturate(dot(normal, viewDir));

			//	// Vectorize Pow4 to save instructions
			//	half2 rlPow4AndFresnelTerm = Pow4(float2(dot(reflDir, light.dir), 1 - nv));  // use R.L instead of N.H to save couple of instructions
			//	half rlPow4 = rlPow4AndFresnelTerm.x; // power exponent must match kHorizontalWarpExp in NHxRoughness() function in GeneratedTextures.cpp
			//	half fresnelTerm = rlPow4AndFresnelTerm.y;

			//	half grazingTerm = saturate(smoothness + (1 - oneMinusReflectivity));

			//	half3 color = BRDF3_Direct(diffColor, specColor, rlPow4, smoothness);
			//	color *= light.color * nl;
			//	color += CurrBRDF3_Indirect(diffColor, specColor, gi, grazingTerm, fresnelTerm);

			//	return half4(color, 1);
			//}

			half4 Inner_BRDF2_Unity_PBS(half3 diffColor, half3 specColor, half oneMinusReflectivity, half smoothness,
				float3 normal, float3 viewDir,
				UnityLight light, UnityIndirect gi)
			{
				float3 halfDir = Unity_SafeNormalize(float3(light.dir) + viewDir);

				half nl = saturate(dot(normal, light.dir));
				float nh = saturate(dot(normal, halfDir));
				half nv = saturate(dot(normal, viewDir));
				float lh = saturate(dot(light.dir, halfDir));

				// Specular term
				half perceptualRoughness = SmoothnessToPerceptualRoughness(smoothness);
				half roughness = PerceptualRoughnessToRoughness(perceptualRoughness);

				#if UNITY_BRDF_GGX

				// GGX Distribution multiplied by combined approximation of Visibility and Fresnel
				// See "Optimizing PBR for Mobile" from Siggraph 2015 moving mobile graphics course
				// https://community.arm.com/events/1155
				half a = roughness;
				float a2 = a * a;

				float d = nh * nh * (a2 - 1.f) + 1.00001f;
				#ifdef UNITY_COLORSPACE_GAMMA
								// Tighter approximation for Gamma only rendering mode!
								// DVF = sqrt(DVF);
								// DVF = (a * sqrt(.25)) / (max(sqrt(0.1), lh)*sqrt(roughness + .5) * d);
					float specularTerm = a / (max(0.32f, lh) * (1.5f + roughness) * d);
				#else
					float specularTerm = a2 / (max(0.1f, lh*lh) * (roughness + 0.5f) * (d * d) * 4);
				#endif

								// on mobiles (where half actually means something) denominator have risk of overflow
								// clamp below was added specifically to "fix" that, but dx compiler (we convert bytecode to metal/gles)
								// sees that specularTerm have only non-negative terms, so it skips max(0,..) in clamp (leaving only min(100,...))
				#if defined (SHADER_API_MOBILE)
					specularTerm = specularTerm - 1e-4f;
				#endif

				#else

				// Legacy
				half specularPower = PerceptualRoughnessToSpecPower(perceptualRoughness);
				// Modified with approximate Visibility function that takes roughness into account
				// Original ((n+1)*N.H^n) / (8*Pi * L.H^3) didn't take into account roughness
				// and produced extremely bright specular at grazing angles

				half invV = lh * lh * smoothness + perceptualRoughness * perceptualRoughness; // approx ModifiedKelemenVisibilityTerm(lh, perceptualRoughness);
				half invF = lh;

				half specularTerm = ((specularPower + 1) * pow(nh, specularPower)) / (8 * invV * invF + 1e-4h);

				#ifdef UNITY_COLORSPACE_GAMMA
					specularTerm = sqrt(max(1e-4f, specularTerm));
				#endif

				#endif

				#if defined (SHADER_API_MOBILE)
					specularTerm = clamp(specularTerm, 0.0, 100.0); // Prevent FP16 overflow on mobiles
				#endif
				#if defined(_SPECULARHIGHLIGHTS_OFF)
					specularTerm = 0.0;
				#endif

								// surfaceReduction = Int D(NdotH) * NdotH * Id(NdotL>0) dH = 1/(realRoughness^2+1)

								// 1-0.28*x^3 as approximation for (1/(x^4+1))^(1/2.2) on the domain [0;1]
								// 1-x^3*(0.6-0.08*x)   approximation for 1/(x^4+1)
				#ifdef UNITY_COLORSPACE_GAMMA
					half surfaceReduction = 0.28;
				#else
					half surfaceReduction = (0.6 - 0.08*perceptualRoughness);
				#endif

				surfaceReduction = 1.0 - roughness * perceptualRoughness*surfaceReduction;

				half grazingTerm = saturate(smoothness + (1 - oneMinusReflectivity));
				half3 color = (diffColor + specularTerm * specColor) * light.color * nl
					+ gi.diffuse * diffColor
					+ surfaceReduction * gi.specular * FresnelLerpFast(specColor, grazingTerm, nv);

				return half4(color, 1);
			}

			//内部 RreateLight
			UnityLight CreateLight2(VertexOutput i) {
				UnityLight light;

				#if defined(POINT) || defined(POINT_COOKIE) || defined(SPOT)
				light.dir = normalize(_WorldSpaceLightPos0.xyz - i.worldPos.xyz);
				#else
				light.dir = _WorldSpaceLightPos0.xyz;
				#endif

				CURR_UNITY_LIGHT_ATTENUATION(attenuation, i, i.worldPos.xyz);//计算远处

				attenuation = FadeShadows2(i, attenuation);//计算近处

				light.color = _LightColor0.rgb * attenuation;


				return light;
			}

			////内部 CreateIndirectLight
			UnityIndirect CreateIndirectLight2(VertexOutput i, float3 viewDir) {
				UnityIndirect indirectLight;
				indirectLight.diffuse = 0;
				indirectLight.specular = 0;
				/*#if defined(VERTEXLIGHT_ON)
					indirectLight.diffuse = i.vertexLightColor;
				#endif*/

				#if defined(FORWARD_BASE_PASS)

					#if defined(CF_LIGHTMAP) 
						indirectLight.diffuse = tex2D(_LightMap, i.lightmapUV.xy).rgb;
					#else 


					#if defined(LIGHTMAP_ON) 
						indirectLight.diffuse = DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, i.lightmapUV));

					#if defined(DIRLIGHTMAP_COMBINED)
						float4 lightmapDirection = UNITY_SAMPLE_TEX2D_SAMPLER(
							unity_LightmapInd, unity_Lightmap, i.lightmapUV
						);
						indirectLight.diffuse = DecodeDirectionalLightmap(
							indirectLight.diffuse, lightmapDirection, i.normal
						);
					#endif

					#else
						indirectLight.diffuse += max(0, ShadeSH9(float4(i.normal, 1)));
					#endif
				#endif

				float3 reflectionDir = reflect(-viewDir, i.normal);
				Unity_GlossyEnvironmentData envData;
				envData.roughness = GetRoughness(i);
				envData.reflUVW = BoxProjection(
					reflectionDir, i.worldPos.xyz,
					unity_SpecCube0_ProbePosition,
					unity_SpecCube0_BoxMin, unity_SpecCube0_BoxMax
				);
				float3 probe0 = Unity_GlossyEnvironment(
					UNITY_PASS_TEXCUBE(unity_SpecCube0), unity_SpecCube0_HDR, envData
				);
				envData.reflUVW = BoxProjection(
					reflectionDir, i.worldPos.xyz,
					unity_SpecCube1_ProbePosition,
					unity_SpecCube1_BoxMin, unity_SpecCube1_BoxMax
				);
				#if UNITY_SPECCUBE_BLENDING
				float interpolator = unity_SpecCube0_BoxMin.w;
				UNITY_BRANCH
					if (interpolator < 0.99999) {
						float3 probe1 = Unity_GlossyEnvironment(
							UNITY_PASS_TEXCUBE_SAMPLER(unity_SpecCube1, unity_SpecCube0),
							unity_SpecCube0_HDR, envData
						);
						indirectLight.specular = lerp(probe1, probe0, interpolator);
					}
					else {
						indirectLight.specular = probe0;
					}
				#else
				indirectLight.specular = probe0;
				#endif

				#if defined(DEFERRED_PASS) && UNITY_ENABLE_REFLECTION_BUFFERS
				indirectLight.specular = 0;
				#endif
				#endif

				return indirectLight;
			}
		#endif

		float4 MyFragmentProgram (VertexOutput i) : SV_Target
		{
			InitializeFragmentNormal(i);

			/*float alpha = GetAlpha(i);
			#if defined(_RENDERING_CUTOUT)
				clip(alpha - _Cutoff);
			#endif		*/			

			float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos.xyz);	

			float3 specularTint = 0;
			float oneMinusReflectivity = 0;
			float3 albedo = float3(1, 1, 1);		

			albedo = DiffuseAndSpecularFromMetallic(GetAlbedo(i), GetMetallic(i), specularTint, oneMinusReflectivity);	
			

			//调整透明度 保留镜面高光
			/*#if defined(_RENDERING_TRANSPARENT)
				albedo *= alpha;
				alpha = 1 - oneMinusReflectivity + alpha * oneMinusReflectivity;
			#endif*/

			float4 color = float4(1, 1, 1, 1);

			//#if LIGHTMAP_UNITY
				//引用unity pbs  UNITY_BRDF_PBS
				//建筑 角色服装 

			//平面反射
			/*#if defined (_RENDERTEX_REFLECT)
				albedo += GetRenderTexReflect(i);
			#endif*/

			color = UNITY_BRDF_PBS(albedo, specularTint, oneMinusReflectivity,
				1 - GetRoughness(i),i.normal,viewDir, CreateLight(i), CreateIndirectLight(i,viewDir));			

			//#elif LIGHTMAP_INNER
			//	//内部LightingMap的最终颜色
			//	color = Inner_BRDF2_Unity_PBS(albedo, specularTint, oneMinusReflectivity,
			//	1 - GetRoughness(i), i.normal, viewDir, CreateLight2(i), CreateIndirectLight2(i, viewDir));
			//#endif

		/*	#if defined(_RENDERING_FADE) || defined(_RENDERING_TRANSPARENT)
				color.a = alpha;
			#endif*/
			//自发光贴图
			color.rgb += GetEmission(i).rgb;

			color = ApplyFog(color, i);

			return color;
		}



#endif		