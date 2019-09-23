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

		//�ڲ� LightMap
		

		//Unity LightingMap
		#if LIGHTMAP_UNITY
			#include "AutoLight.cginc"
		#elif LIGHTMAP_INNER		 
			#include "ShadowMask.cginc"
			#include "AutoLightShadowMask.cginc"
		#endif

		//fog ���� ָ�� ָ��ƽ��
		#if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2)
			//����ռ���������
			#if !defined (FOG_DISTANCE)
				//��Ļ�ռ���������
				#define FOG_DEPTH 1
			#endif
			//��ر�
			#define FOG_ON 1
		#endif		
		
		//�������µ���Ӱ����
		//Unity LightingMap
		#if LIGHTMAP_UNITY
			#if !defined(LIGHTMAP_ON) && defined (SHADOWS_SCREEN)
				#if defined(SHADOWS_SHADOWMASK) && !defined(UNITY_NO_SCREENSPACE_SHADOWS)
					#define ADDITIONAL_MASKED_DIRECTIONAL_SHADOWS  1
				#endif
			#endif
			// Subtractive Lighting �����ƹ�ģʽ
			#if defined(LIGHTMAP_ON) && defined(SHADOWS_SCREEN)
				#if defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK)
					#define SUBTRACTIVE_LIGHTING 1
				#endif
			#endif
		#endif

		//����ɫmask uv3
		#if defined(_MASK_MAINTEX)|| defined(_RG_MASK_VERTEX) || defined(_RGB_MASK_VERTEX) 
			#define MASK_VERTEX 1
		#endif
		
		//С���mask
		#if defined(_MAIN_MASK_PROPS) || defined(_RG_MASK_PROPS) || defined(_RGB_MASK_PROPS) 
			#define MASK_PROPS 1
		#endif
	
		//����ɫͨ��
		#if defined(_MAINTEX)
			#define OBJECT_MASK_UV1 1
		#endif
		
	/*	#if defined(MASK_DETAIL)
			#define DETAIL
		#endif*/

		//Mask �Ƿ�ʹ��
		#if defined(MASK_VERTEX)  || defined(MASK_PROPS) 
			#define MASK_ON 1
		#endif

		//windows ������ɫ���Ƿ�ʹ��
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
			//ʵʱGI ������ͼUV
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
			//�ж�ʹ�������Ƶ��������߻����Ǽ����µ������ֵ������һ��binormal
			#if defined(BINORMAL_PER_FRAGMENT)
				float4 tangent : TEXCOORD4;
			#else
				float3 tangent : TEXCOORD4;
				float3 binormal : TEXCOORD5;
			#endif

			//fog ��Ļ�ռ����
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


		//�Է�����ͼ
		//sampler2D _EmissionMap;
		float4 _Emission;
			
		#if LIGHTMAP_UNITY
			////��һ������
			sampler2D _MainTex;
			float4 _MainTex_ST;

			sampler2D _LightMap;
			float4 _LightMap_ST;
			
			//������ɫ
			half4 _Color;		
			float _Cutoff;
		#endif	

		//����,����ǿ��
		sampler2D _MainNromalMap;
		float _NormalAmoutnN1;
		float _Occlusion;

		//�Ƿ�ʹ�ö���ɫͨ������,����,��ɫ
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

		////���� mask uv3 
		//#if defined(DETAIL)
		//	sampler2D _MaskTex;
		//#endif // defined(MASK_DETAIL)

		//���� mask ��ͼ ��ɫ ao ǿ�� uv1 ͨ��
		#if defined(OBJECT_MASK_UV1) 
			sampler2D _MaskTex;
			float4 _MaskTex_ST;

			float4 _ColorG;
			float4 _ColorB;
		#endif

		//���� mask uv3ͨ��
		#if defined(_MASK_DETAIL)
			sampler2D _MaskTex;
			float4 _MaskTex_ST;

		#endif 


		//���� mask ��ͼ ��ɫ ao ǿ�� uv3ͨ��
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

		//�����ȴֲڶ�
		half _Metallic;
		half _Roughness;

		//Ground ������ɫ��,�߶�ͼǿ��
		half _Strength;

		//tex2D(XXXXXX) �����ظ��������ڱ���������ֻ����һ��
		//������
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

			//����ɫͨ��ʹ��
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


		//�ֲڶ�
		float GetRoughness(VertexOutput i)
		{
			float roughness =  _Roughness;

			#if defined(_MAINTEX)
				roughness *= tex2D(_MainNromalMap, i.uv.xy).b;
			#endif

							   
			#if defined(WINDOWS_ON)
				half4 maskTex = tex2D(_MaskTex, i.uv3);
			#endif								

			//����ɫͨ��ʹ��
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
		
		//normal ת��	
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

			//����ɫ���maskͨ������ɫ��normal
			#if defined(_MIAN_VERTEX) 
				normal = UnpackNormalmapCustom(tex2D(_MainNromalMap, i.uv.xy), _NormalAmoutnN1);
			#endif			
			
			//mask ��Ϸ���
			#if defined(_MASK_MAINTEX)
				float3 mainNormal = UnpackScaleNormal(tex2D(_MainNromalMap, i.uv.xy), _NormalAmoutnN1);
				float3 maskNormal = UnpackScaleNormal(tex2D(_MaskNromalMap, i.uv3), _NormalAmoutnN1);
				normal = BlendNormals(mainNormal, maskNormal);
			#endif
			//��ɫ mask��Ϸ���
			#if defined(_RG_VERTEX) || defined(_RG_MASK_VERTEX)
				float3 normalR = UnpackNormalmapCustom(tex2D(_MainNromalMap, i.uv.xy), _NormalAmoutnN1);
				float3 normalG = UnpackNormalmapCustom(tex2D(_GNormalMap, i.uv.zw), _NormalAmoutnN1);
				normal = normalR *  ( i.color.r + i.color.b) + normalG * i.color.g;
			#endif
			//����ɫ RGB ���߻��
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
			
			//������ɫ�����߻�Ϸ�ʽ
			#if defined(_MAINTEX_WINDOWS)
				float3 mainNormal = UnpackScaleNormal(tex2D(_MainNromalMap, i.uv.xy), _NormalAmoutnN1);
				mainNormal.xy = mainNormal.xy *  (1 - maskTex.b);
				float3 maskNormal = UnpackScaleNormal(tex2D(_MaskNromalMap, i.uv3), _NormalAmoutnN1);
				normal = BlendNormals(mainNormal, maskNormal);
			#endif

				//����mask G ͨ�����
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

			//����ɫ mask ����
			#if defined(_MAIN_MASK_PROPS) || defined(_RG_MASK_PROPS) || defined(_RGB_MASK_PROPS)
				normal = UnpackScaleNormal(tex2D(_MaskNromalMap, i.uv3), _NormalAmoutnN1);
			#endif 		

			//����mask ���߻��
			#if	defined(_MASK_DETAIL)
				float3 maskNormal = UnpackNormalmapCustom(tex2D(_MaskTex, i.uv3), _NormalAmoutnN1);
				normal = BlendNormals(maskNormal,normal);
			#endif
			return normal;
		}

		//Ground ����߶�ͼ���
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

		//�Է�����ͼ
		float3 GetEmission(VertexOutput i)
		{
			float3 emission = float3(0, 0, 0);
			//ǰ����Ⱦ
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

			//����maskͨ�� ���� ao uv3
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
			//������
			half3 albedo = half3(1,1,1);			

			//��ɫ���͸�������ֱ��ʹ����ɫ���Ե�һ������
			#if !defined(_RENDERING_FADE) && !defined(_RENDERING_TRANSPARENT)
				half4 mainTex = tex2D(_MainTex, i.uv.xy) * _Color;
			#endif

			//uv1 ����ɫ
			#if defined(_MAINTEX)
				half3 maskG = tex2D(_MaskTex, i.uv.xy).rgb;				
				//albedo = lerp(mainTex,mainTex * maskGColor, _ColorG.a);
				half3 colorG = mainTex *  maskG.g + mainTex * _ColorG.rgb * (1 - maskG.g);
				half3 halfColorG = colorG * maskG.b * _ColorB.rgb * maskG.b + _ColorB.rgb * maskG.b * 0.25;
				half3 colorB = colorG * (1 - maskG.b) * _Color.rgb + halfColorG;
				albedo = colorB;
			#endif

			//mask ����
			#if defined (MASK_ON) || defined(_MASK_DETAIL)
				half4 maskTex = tex2D(_MaskTex, i.uv3);
			#endif			

			//������ɫ��
			#if defined (WINDOWS_ON)
				half4 maskTex = tex2D(_MaskTex, i.uv3);
				half3 windowCol = _ColorGlass.rgb * maskTex.b;
			#endif
			
			//����ɫmask G Tex
			#if defined (_RG_MASK_VERTEX) || defined(_RG_VERTEX) || defined(_MASK_G_WINDOWS) ||defined(_RG_MASK_PROPS)
				half4 GTex = tex2D(_GTex, i.uv.zw) * _ColorGVertex;
			#endif

			//ʹ�ö���ɫ��R G B ͨ��
			#if defined (_RGB_MASK_VERTEX) || defined(_RGB_VERTEX) || defined(_RGB_MASK_PROPS)
				half4 GTex = tex2D(_GTex, i.uv.zw) * _ColorGVertex;
				half4 BTex = tex2D(_BTex, i.uv2.xy) * _ColorBVertex;
			#endif	

			//�±ڶ���ɫ R G B ͨ��
			#if defined(_RGB_VERTEX_PRECIPICE)
				half4 GTex = tex2D(_GTex, i.uv.zw) * _ColorGVertex;
				half4 BTex = tex2D(_BTex, i.uv3.xy) * _ColorBVertex;
			#endif 


			#if defined(_MAINTEX_WINDOWS)
				albedo = mainTex.rgb *  (1 - maskTex.b)+ windowCol;
				albedo = lerp(albedo, albedo* maskTex.r, _Occlusion);
			#endif
			//mask G ͨ�����
			#if defined(_MASK_G_WINDOWS)
				half3 MaskG = (mainTex.rgb * maskTex.g + GTex.rgb *  (1 - maskTex.g)) * (1 - maskTex.b);
				albedo = MaskG + windowCol;
				albedo = lerp(albedo, albedo* maskTex.r, _Occlusion);
			#endif

			//mask G B ͨ���Ļ�ϼ���,G��ɫͨ��,B������
			#if defined (_MASK_MAINTEX) || defined(_MAIN_MASK_PROPS)
				half3 mainCol = mainTex.rgb * (maskTex.b) * _ColorB.rgb * _ColorB.a * 2 + mainTex.rgb * (1 - maskTex.b);
				half maskMixtureCol = lerp(maskTex.g * mainTex.a, 1, maskTex.g);
				albedo = lerp(mainCol, mainCol * _ColorG.rgb, _ColorG.a * 2 * (1 - (maskMixtureCol)));
				albedo = lerp(albedo, albedo * maskTex.r, _Occlusion);
			#endif

			//mask R G ��ɫͨ���Ļ�ϼ��� 
			#if defined (_RG_MASK_VERTEX) || defined(_RG_MASK_PROPS)
				half3 RGCol = (mainTex.rgb * (i.color.r + i.color.b) + GTex.rgb * i.color.g);
				//mask.Bͨ����ɫ���
				RGCol = RGCol * maskTex.b * _ColorB.rgb * _ColorB.a * 2 + RGCol * (1 - maskTex.b);
				//RG roughness
				half RGColA = (mainTex.a *  (i.color.g + i.color.b) + GTex.a * i.color.g );
				//mask.Gͨ����ɫ���
				half maskMixtureCol = lerp(maskTex.g * RGColA, 1, maskTex.g);
				albedo = lerp(RGCol, RGCol * _ColorG.rgb, _ColorG.a * 2 * (1 - (maskMixtureCol)));
				albedo = lerp(albedo, albedo * maskTex.r, _Occlusion);

			#endif

			#if defined (_RGB_MASK_VERTEX) || defined(_RGB_MASK_PROPS)
				half3 RGBCol = (mainTex.rgb *  i.color.r + GTex.rgb * i.color.g + BTex.rgb * i.color.b);
				//mask.Bͨ����ɫ���
				RGBCol = RGBCol * maskTex.b * _ColorB.rgb * _ColorB.a * 2 + RGBCol * (1 - maskTex.b);
				//RGB roughness
				half RGBColA = (mainTex.a * i.color.r + GTex.a * i.color.g + BTex.a * i.color.b);
				//mask.Gͨ����ɫ���
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
			
			//���� ����ɫ��� RG
			#if defined(_RG_VERTEX)
				half3 blend = Blend(mainTex.r, GTex.r, 1, i.color.rgb);
				albedo = mainTex.rgb * (blend.r + blend.b) + GTex.rgb * blend.g;
			#endif

			//���� ����ɫ��� RGB
			#if defined (_RGB_VERTEX)
				half3 blend = Blend(mainTex.r, GTex.r, BTex.r, i.color.rgb);
				albedo = mainTex.rgb *  blend.r + GTex.rgb * blend.g + BTex.rgb * blend.b;
			#endif

			// �±� ����ɫ��ϼ���
			#if defined(_RGB_VERTEX_PRECIPICE)
				half3 blend = Blend(mainTex.a, GTex.a, BTex.a, i.color.rgb);
				albedo = mainTex.rgb *  blend.r + GTex.rgb * blend.g + BTex.rgb * blend.b;
			#endif
			
			//#if defined(_MASK_DETAIL)
			//	albedo = maskTex.rgb;
			//#endif // defined(_MASK_DETAIL)

			//��ʾ����ɫ
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
		//���취��
		float3 CreateBinormal(float3 normal, float3 tangent, float binormalSign)
		{
			//unity_WorldTransformParams ��ֹ�������߿ռ�û��ͬ������
			return cross(normal, tangent.xyz) * (binormalSign * unity_WorldTransformParams.w);
		}
			
		//��������
		VertexOutput MyVertexProgram (VertexInput v)
		{
			//UNITY_INITIALIZE_OUTPUT ��ʼ��VertexOutput
			VertexOutput o;
			UNITY_INITIALIZE_OUTPUT(VertexOutput, o);

			o.pos = UnityObjectToClipPos(v.vertex);

			//���ý���uvͨ��λ��
			float2 inputUV = v.uv;

			//#if defined(_GROUND_UV3) 
			//	inputUV = v.uv3;
			//#endif // defined(_GROUND_UV3)
				
			#if defined(UV3_ON) 
				float2 inputUV3 = v.uv3;			
			#endif // defined(UV3_ON)

			//����ɫ uv R 
			o.uv.xy = TRANSFORM_TEX(inputUV, _MainTex);

			//����ɫ uv G
			#if defined(_MASK_G_WINDOWS) || defined(_RG_MASK_VERTEX) || defined(_RG_VERTEX) || defined(_RG_MASK_PROPS) 
				o.uv.zw = TRANSFORM_TEX(inputUV, _GTex);
			#endif
			//����ɫ uv B
			#if defined (_RGB_MASK_VERTEX) || defined(_RGB_VERTEX) || defined(_RGB_MASK_PROPS) || defined(_RGB_VERTEX_PRECIPICE) 
				o.uv.zw = TRANSFORM_TEX(v.uv, _GTex);
				o.uv2 = TRANSFORM_TEX(v.uv, _BTex);
			#endif

			//mask UV3
			#if defined(MASK_ON) || defined(WINDOWS_ON) || defined(_MASK_DETAIL)
				o.uv3 = TRANSFORM_TEX(inputUV3, _MaskTex);
				//o.uv3 = v.uv3;
			#endif
			//�±� UV3
			#if defined(_RGB_VERTEX_PRECIPICE)
				o.uv3 = TRANSFORM_TEX(inputUV3, _MainTex);
			#endif

			//render texture reflect
			/*#if defined(_RENDERTEX_REFLECT)
				o.screenPos = ComputeScreenPos(o.pos);
			#endif*/

			o.color = v.color;

			o.normal = UnityObjectToWorldNormal(v.normal);
			//���߷���,������ת��������
			#if defined(BINORMAL_PER_FRAGMENT)
				o.tangent = float4(UnityObjectToWorldDir(v.tangent.xyz), v.tangent.w);
			#else
				o.tangent = UnityObjectToWorldDir(v.tangent.xyz);
				o.binormal = CreateBinormal(o.normal, o.tangent,v.tangent.w);
			#endif

			o.worldPos.xyz = mul(unity_ObjectToWorld, v.vertex);

			//fog ��Ļ�ռ����
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

		//Unity ��Ӱ���뵭��
		#if LIGHTMAP_UNITY
			float FadeShadows(VertexOutput i, float attenuation)
			{
				//HANDLE_SHADOWS_BLENDING_IN_GI ������Ӱ,�決��Ӱ���е������� 
				//ADDITIONAL_MASKED_DIRECTIONAL_SHADOWS �������µ�˥��
				#if HANDLE_SHADOWS_BLENDING_IN_GI || ADDITIONAL_MASKED_DIRECTIONAL_SHADOWS
					#if ADDITIONAL_MASKED_DIRECTIONAL_SHADOWS
						attenuation = SHADOW_ATTENUATION(i);
					#endif
					float viewZ = dot(_WorldSpaceCameraPos - i.worldPos, UNITY_MATRIX_V[2].xyz);
					float shadowFadeDistance = UnityComputeShadowFadeDistance(i.worldPos, viewZ);
					float shadowFade = UnityComputeShadowFade(shadowFadeDistance);
					//����Ӱ��ͼ���в���
					float bakedAttenuation = UnitySampleBakedOcclusion(i.lightmapUV, i.worldPos);
					//��Ӱ˥��
					attenuation = UnityMixRealtimeAndBakedShadows(attenuation, bakedAttenuation, shadowFade);
				#endif
					return attenuation;
					
			}
		#endif
				
		//Unity ��Դ���㷽ʽ
		#if LIGHTMAP_UNITY
			UnityLight CreateLight(VertexOutput i)
			{
				UnityLight light;				

				#if SUBTRACTIVE_LIGHTING
					light.dir = float3(0, 1, 1);
					light.color = 0;
				#else
					#if defined(POINT) || defined(SPOT) || defined(POINT_COOKIE)
					//���Դ����
						light.dir = normalize(_WorldSpaceLightPos0.xyz - i.worldPos.xyz);
					#else
					//�����
						light.dir = _WorldSpaceLightPos0.xyz;
					#endif
			
					// #define POINT д��ſ���ȷ����
					//����ʹ�÷���
					UNITY_LIGHT_ATTENUATION(attenuation, i, i.worldPos.xyz);

					//��Ӱ���뵭��
					attenuation = FadeShadows(i, attenuation);

					light.color = _LightColor0.rgb * attenuation;
				#endif

				//light.ndotl = DotClamped(i.normal, light.dir);
				return light;
			}
		#endif

		//Unity ���㷴�����λ��
		#if LIGHTMAP_UNITY
			float3 BoxProjection(float3 direction,float3 position,float4 cubemapPosition,float3 boxMin,float3 boxMax)
			{	
				#if UNITY_SPECCUBE_BOX_PROJECTION
					UNITY_BRANCH
					//if ������ֻ��õ�һ��������ֵ ����������ɫ�����ʹ����ͬ����պ�̽������
					if (cubemapPosition.w > 0)
					{
						//�����߽�
						boxMin -= position;
						boxMax -= position;
						//��λ��ָ���������С�߽�	
						float3 factors = ((direction > 0 ? boxMax : boxMin) - position) / direction;
						//ȡ����Сֵ,��ӽ��߽�λ��
						float scalar = min(min(factors.x, factors.y), factors.z);
						direction = direction * scalar + (position - cubemapPosition);
					}
				#endif
				return direction ;
			}
		#endif		

		//�ڲ� FadeShadows
		#if LIGHTMAP_INNER
			float FadeShadows2(VertexOutput i, float attenuation) 
			{

				float viewZ = dot(_WorldSpaceCameraPos - i.worldPos, UNITY_MATRIX_V[2].xyz);
				float shadowFadeDistance = UnityComputeShadowFadeDistanceExpand(i.worldPos, viewZ);//��Ӱ�Ӿ���

				float shadowFade = UnityComputeShadowFadeExpand(shadowFadeDistance);

				float bakedAttenuation = ComputMask(i.lightmapUV, i.worldPos, _LightMap);//�決��Ӱ��

				attenuation = lerp(attenuation, bakedAttenuation, shadowFade);//UnityMixRealtimeAndBakedShadowsExpand(attenuation, bakedAttenuation, shadowFade);
				return attenuation;
			}
		#endif

		float3 NormalCount(VertexOutput i)
		{
			float3 tangentSpaceNormal = GetTangentSpaceNormal(i);
			//unity ���û�Ϸ��� ��ʽ���Ϸ���ͬ
			#if defined(BINORMAL_PER_FRAGMENT)
					float3 binormal = CreateBinormal(i.normal, i.tangent.xyz, i.tangent.w);
			#else
					float3 binormal = i.binormal;
			#endif		
			//�����ߴ����߿ռ�ת��������ռ�
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
			//�������,�ṩ����ɫƤ����ȡ����			
			i.normal = NormalCount(i);
		}	

		//��ȥģʽ�µļ�ӹ� ͨ����������
		void ApplySubtractiveLighting(VertexOutput i, inout UnityIndirect indirectLight)
		{
			#if SUBTRACTIVE_LIGHTING
				//��ȡ��Ӱ˥��
				UNITY_LIGHT_ATTENUATION(attenuation, i, i.worldPos.xyz);
				attenuation = FadeShadows(i, attenuation);
				//����Lambert ����ģ��
				float ndotl = saturate(dot(i.normal, _WorldSpaceLightPos0.xyz));
				//Lambert �������ͼ��Ӱ˥�� �ƹ���ɫ ��� �õ���Ӱ�赲�Ĺ�������
				float3 shadowedLightEstimate = ndotl * (1 - attenuation) * _LightColor0.rgb;
				//�ӹ�����ͼ�м�ȥ��ֵ���õ��������Ĺ�������
				float3 subtractedLight = indirectLight.diffuse - shadowedLightEstimate;
				//ȡ�ù�����ͼ��ɫ,ȡ���ֵ,����ƥ�䳡��,��ֹ��Ӱ����
				subtractedLight = lerp(subtractedLight, unity_ShadowColor.rgb,_LightShadowData.x);
				//subtractedLight.diffuse = subtractedLight;
				indirectLight.diffuse = min(subtractedLight, indirectLight.diffuse);
				
			#endif
		}

		//Unity ��ӹ�
		#if LIGHTMAP_UNITY
			UnityIndirect CreateIndirectLight(VertexOutput i,float3 viewDir)
			{
				UnityIndirect indirectLight;
				indirectLight.diffuse = 0;
				indirectLight.specular = 0;			
				
				//��г���� ��ǰ����Ⱦ���ӳ���Ⱦ�¼���
				#if defined(FORWARD_BASE_PASS) 
					//��������ͼʹ��ʱ,��ʹ������г��������ӹ�
					#if defined(LIGHTMAP_ON)
						//DecodeLightmap Ϊ��ͼ����
						indirectLight.diffuse = DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, i.lightmapUV));
						//�決��ͼ������ͼ  �Է�����ͼ���в���
						#if defined(DIRLIGHTMAP_COMBINED)
							float4 lightmapDirection = UNITY_SAMPLE_TEX2D_SAMPLER(unity_LightmapInd,unity_Lightmap, i.lightmapUV);
							//ʹ�÷�����ͼ,��DecodeDirectionalLightmap�����뷽�����ݲ�������ɫ
							indirectLight.diffuse = DecodeDirectionalLightmap(indirectLight.diffuse, lightmapDirection, i.normal);
						#endif
						//����ģʽ�µļ�ӹ�
						ApplySubtractiveLighting(i, indirectLight);


					//�����������diffuse��ɫ,ʵʱ��ͼʹ�ò�ͬ����ɫ��ʽ,������ݿ��ܻ���ӵ��決������
					/*#else							
						indirectLight.diffuse += max(0, ShadeSH9(float4(i.normal, 1)));*/
					#endif

					//ʵʱGI �決��ͼ
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

					//unity���� Unity_GlossyEnvironment ʵ�淴�� �ֲڶ� CUBE mipmap�������
					Unity_GlossyEnvironmentData envData;
					envData.roughness = GetRoughness(i);
					//�������λ�� ��ֵ2������̽��
					envData.reflUVW = BoxProjection(reflectionDir,
						i.worldPos.xyz,unity_SpecCube0_ProbePosition,
						unity_SpecCube0_BoxMin,unity_SpecCube0_BoxMax);				
					float3 probe0 = Unity_GlossyEnvironment(UNITY_PASS_TEXCUBE(unity_SpecCube0), unity_SpecCube0_HDR, envData);
					envData.reflUVW = BoxProjection(reflectionDir,
						i.worldPos.xyz, unity_SpecCube1_ProbePosition,
						unity_SpecCube1_BoxMin, unity_SpecCube1_BoxMax);

					//���ƽ̨���ܴ���̽���ϣ���ôʹ��̽��0
					#if UNITY_SPECCUBE_BLENDING
						float interpolator = unity_SpecCube0_BoxMin.w;
						//�Ż�����,ֻ��������̽�����ʱ�Ż�����ֵ���
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

					//���ӳ���Ⱦģʽ��,�Է���н����ж�
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
				//����붥������߾���
				float viewDistance = length(_WorldSpaceCameraPos - i.worldPos.xyz);

				//fog ��Ļ�ռ����
				#if FOG_DEPTH
					viewDistance = UNITY_Z_0_FAR_FROM_CLIPSPACE(i.worldPos.w);
				#endif

				//unity �����, �ڲ�����unityFogFactory����,��Fog��������ɫ֮���ֵ Fog��ɫ�洢��unity_FogColor
				UNITY_CALC_FOG_FACTOR_RAW(viewDistance);

				//ForwardAdd�½�����ɫ����Ϊ��ɫ,�����ظ����㵼�������,ֻ��FORWARD_BASE_PASS����
				float3 fogColor = 0;

				#if defined(FORWARD_BASE_PASS)
					fogColor = unity_FogColor.rgb;
				#endif

				color.rgb = lerp(fogColor, color.rgb, saturate(unityFogFactor));
			#endif
			return color;
		}
		
		//�ڲ� BRDF_PBS2
		#if LIGHTMAP_INNER
			//pbs �㷨
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

			//�ڲ� RreateLight
			UnityLight CreateLight2(VertexOutput i) {
				UnityLight light;

				#if defined(POINT) || defined(POINT_COOKIE) || defined(SPOT)
				light.dir = normalize(_WorldSpaceLightPos0.xyz - i.worldPos.xyz);
				#else
				light.dir = _WorldSpaceLightPos0.xyz;
				#endif

				CURR_UNITY_LIGHT_ATTENUATION(attenuation, i, i.worldPos.xyz);//����Զ��

				attenuation = FadeShadows2(i, attenuation);//�������

				light.color = _LightColor0.rgb * attenuation;


				return light;
			}

			////�ڲ� CreateIndirectLight
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
			

			//����͸���� ��������߹�
			/*#if defined(_RENDERING_TRANSPARENT)
				albedo *= alpha;
				alpha = 1 - oneMinusReflectivity + alpha * oneMinusReflectivity;
			#endif*/

			float4 color = float4(1, 1, 1, 1);

			//#if LIGHTMAP_UNITY
				//����unity pbs  UNITY_BRDF_PBS
				//���� ��ɫ��װ 

			//ƽ�淴��
			/*#if defined (_RENDERTEX_REFLECT)
				albedo += GetRenderTexReflect(i);
			#endif*/

			color = UNITY_BRDF_PBS(albedo, specularTint, oneMinusReflectivity,
				1 - GetRoughness(i),i.normal,viewDir, CreateLight(i), CreateIndirectLight(i,viewDir));			

			//#elif LIGHTMAP_INNER
			//	//�ڲ�LightingMap��������ɫ
			//	color = Inner_BRDF2_Unity_PBS(albedo, specularTint, oneMinusReflectivity,
			//	1 - GetRoughness(i), i.normal, viewDir, CreateLight2(i), CreateIndirectLight2(i, viewDir));
			//#endif

		/*	#if defined(_RENDERING_FADE) || defined(_RENDERING_TRANSPARENT)
				color.a = alpha;
			#endif*/
			//�Է�����ͼ
			color.rgb += GetEmission(i).rgb;

			color = ApplyFog(color, i);

			return color;
		}



#endif		