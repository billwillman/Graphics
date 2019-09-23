#if !defined(MY_LIGHTMAPPING_INCLUDED)
#define MY_LIGHTMAPPING_INCLUDED

	#include "UnityPBSLighting.cginc"
	//光照贴图输出albedo与emissive 颜色,由UnityMetaFragment 函数输出
	#include "UnityMetaPass.cginc"
	
	//unity UnityStandardCore cginc 烘焙

	//float4 _Color;
	//sampler2D _MainTex;
	//float4 _MainTex_ST;
	//
	//half _UVSec;
	//
	//
	//
	//struct Interpolators {
	//	float4 pos : SV_POSITION;
	//	float4 uv : TEXCOORD0;
	//};
	//
	////
	//struct VertexData
	//{
	//	float4 vertex   : POSITION;
	//	half3 normal    : NORMAL;
	//	float2 uv0      : TEXCOORD0;
	//	float2 uv1      : TEXCOORD1;
	//	//#if defined(DYNAMICLIGHTMAP_ON) || defined(UNITY_PASS_META)
	//	float2 uv2      : TEXCOORD2;
	//	//#endif
	//	//#ifdef _TANGENT_TO_WORLD
	//	//	half4 tangent   : TANGENT;
	//	//#endif
	//		//UNITY_VERTEX_INPUT_INSTANCE_ID
	//};
	//
	//half3 Albedo(float4 texcoords)
	//{
	//	half3 albedo = _Color.rgb * tex2D(_MainTex, texcoords.xy).rgb;
	//	//#if _DETAIL
	//	//	#if (SHADER_TARGET < 30)
	//	//		// SM20: instruction count limitation
	//	//		// SM20: no detail mask
	//	//		half mask = 1;
	//	//	#else
	//	//		half mask = DetailMask(texcoords.xy);
	//	//	#endif
	//
	//	//	half3 detailAlbedo = tex2D(_DetailAlbedoMap, texcoords.zw).rgb;
	//
	//	//	#if _DETAIL_MULX2
	//	//		albedo *= LerpWhiteTo(detailAlbedo * unity_ColorSpaceDouble.rgb, mask);
	//	//	#elif _DETAIL_MUL
	//	//		albedo *= LerpWhiteTo(detailAlbedo, mask);
	//	//	#elif _DETAIL_ADD
	//	//		albedo += detailAlbedo * mask;
	//	//	#elif _DETAIL_LERP
	//	//		albedo = lerp(albedo, detailAlbedo, mask);
	//	//	#endif
	//	//#endif
	//	return albedo;
	//}
	//
	//half3 Emission(float2 uv)
	//{
	//	//#ifndef _EMISSION
	//	//	return 0;
	//	//#else
	//	//	return tex2D(_EmissionMap, uv).rgb * _EmissionColor.rgb;
	//	//#endif
	//	return 0;
	//}
	//
	//float4 TexCoords(VertexData v)
	//{
	//	float4 texcoord;
	//	texcoord.xy = TRANSFORM_TEX(v.uv0, _MainTex); // Always source from uv0
	//	//texcoord.zw = TRANSFORM_TEX(((_UVSec == 0) ? v.uv0 : v.uv1), _DetailAlbedoMap);
	//	return texcoord;
	//}
	//
	//struct FragmentCommonData
	//{
	//	half3 diffColor, specColor;
	//	// Note: smoothness & oneMinusReflectivity for optimization purposes, mostly for DX9 SM2.0 level.
	//	// Most of the math is being done on these (1-x) values, and that saves a few precious ALU slots.
	//	half oneMinusReflectivity, smoothness;
	//	float3 normalWorld;
	//	float3 eyeVec;
	//	half alpha;
	//	float3 posWorld;
	//
	//	/*#if UNITY_STANDARD_SIMPLE
	//		half3 reflUVW;
	//	#endif
	//
	//	#if UNITY_STANDARD_SIMPLE
	//		half3 tangentSpaceNormal;
	//	#endif*/
	//};
	//
	//half3 UnityLightmappingAlbedo(half3 diffuse, half3 specular, half smoothness)
	//{
	//	half roughness = SmoothnessToRoughness(smoothness);
	//	half3 res = diffuse;
	//	res += specular * roughness * 0.5;
	//	return res;
	//}
	//
	//#ifndef UNITY_SETUP_BRDF_INPUT
	//#define UNITY_SETUP_BRDF_INPUT SpecularSetup
	//#endif
	//
	//half4 SpecularGloss(float2 uv)
	//{
	//	half4 sg;
	//	/*#ifdef _SPECGLOSSMAP
	//		#if defined(_SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A)
	//			sg.rgb = tex2D(_SpecGlossMap, uv).rgb;
	//			sg.a = tex2D(_MainTex, uv).a;
	//		#else
	//			sg = tex2D(_SpecGlossMap, uv);
	//		#endif
	//		sg.a *= _GlossMapScale;
	//	#else
	//		sg.rgb = _SpecColor.rgb;
	//		#ifdef _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
	//			sg.a = tex2D(_MainTex, uv).a * _GlossMapScale;
	//		#else
	//			sg.a = _Glossiness;
	//		#endif
	//	#endif*/
	//
	//	sg.rgb = _SpecColor.rgb;
	//	sg.a = tex2D(_MainTex, uv).a;
	//
	//	return sg;
	//}
	//
	//Interpolators vert_meta(VertexData v)
	//{
	//	//Interpolators o = (Interpolators)0;
	//	Interpolators o ;
	//	UNITY_INITIALIZE_OUTPUT(Interpolators, o);
	//	o.pos = UnityMetaVertexPosition(v.vertex, v.uv1.xy, v.uv2.xy, unity_LightmapST, unity_DynamicLightmapST);
	//	o.uv = TexCoords(v);
	//	return o;
	//}
	//
	//inline FragmentCommonData SpecularSetup(float4 i_tex)
	//{
	//	half4 specGloss = SpecularGloss(i_tex.xy);
	//	half3 specColor = specGloss.rgb;
	//	half smoothness = specGloss.a;
	//
	//	half oneMinusReflectivity;
	//	half3 diffColor = EnergyConservationBetweenDiffuseAndSpecular(Albedo(i_tex), specColor, /*out*/ oneMinusReflectivity);
	//
	//	FragmentCommonData o = (FragmentCommonData)0;
	//	o.diffColor = diffColor;
	//	o.specColor = specColor;
	//	o.oneMinusReflectivity = oneMinusReflectivity;
	//	o.smoothness = smoothness;
	//	return o;
	//}
	//
	//
	//float4 frag_meta(Interpolators i) : SV_Target
	//{
	//	// we're interested in diffuse & specular colors,
	//	// and surface roughness to produce final albedo.
	//	FragmentCommonData data = UNITY_SETUP_BRDF_INPUT(i.uv);
	//
	//	UnityMetaInput o;
	//	UNITY_INITIALIZE_OUTPUT(UnityMetaInput, o);
	//
	//	//#if defined(EDITOR_VISUALIZATION)
	//		//o.Albedo = data.diffColor;
	//	//#else
	//		o.Albedo = UnityLightmappingAlbedo(data.diffColor, data.specColor, data.smoothness);
	//		//#endif
	//			o.SpecularColor = data.specColor;
	//			o.Emission = Emission(i.uv.xy);
	//
	//			return UnityMetaFragment(o);
	//}

	float4 _Color;
	sampler2D _MainTex;
	float4 _MainTex_ST;

	sampler2D _MetallicMap;
	float _Metallic;
	float _Roughness;

	#if defined(_MAINTEX)
		sampler2D _MainNromalMap;
	#endif

	//sampler2D _EmissionMap;
	float4 _Emission;

	struct VertexData 
	{
		float4 vertex : POSITION;
		float2 uv : TEXCOORD0;
		float2 uv1 : TEXCOORD1;
		//GI 光照贴图坐标
		float2 uv2 : TEXCOORD2;
	};

	struct Interpolators 
	{
		float4 pos : SV_POSITION;
		float4 uv : TEXCOORD0;
	};

	////细节贴图遮罩
	//float GetDetailMask(Interpolators i)
	//{
	//	/*#if defined (_DETAIL_MASK)
	//		return tex2D(_DetailMask, i.uv.xy).a;
	//	#endif*/
	//	return 1;

	//}

	//Albedo
	float3 GetAlbedo(Interpolators i)
	{
		//unity_ColorSpaceDouble unity用于转换Gama与线性空间的贴图 
		float3 albedo = tex2D(_MainTex, i.uv.xy).rgb;
	/*	#if defined (_DETAIL_ALBEDO_MAP)
			float3 details = tex2D(_DetailTex, i.uv.zw).rgb * unity_ColorSpaceDouble;
			albedo = lerp(albedo, albedo * details, GetDetailMask(i));
		#endif*/
		return albedo;
	}

	//金属度
	float GetMetallic(Interpolators i)
	{
		float metallic = 0;
		//读取贴图a通道金属度
		#if defined(_MAINTEX)
			float mapA = tex2D(_MainNromalMap, i.uv.xy).a;
			metallic = mapA * _Metallic;
		#else
			metallic = _Metallic;
		#endif

		return metallic;
	}

	//粗糙度
	float GetSmoothness(Interpolators i)
	{
		float smoothness = 1;
		//读取贴图b通道粗糙度
		#if defined(_MAINTEX)
			float mapB = tex2D(_MainNromalMap, i.uv.xy).b ;
			smoothness = mapB * _Roughness;
		#else
			smoothness = _Roughness;
		#endif

	/*	#if defined(_SMOOTHNESS_ALBEDO)
			smoothness = tex2D(_MainTex, i.uv.xy).a;*/
	/*	#elif defined (_SMOOTHNESS_METALLIC) && defined(_METALLIC_MAP)
			smoothness = tex2D(_MetallicMap, i.uv.xy).a;*/
		//#endif
		return smoothness;
	}

	//自发光贴图
	float3 GetEmission(Interpolators i)
	{
		#if defined(_EMISSION_MAP)
			float3 emission = float3(1, 1, 1);
			float mainTexA = tex2D(_MainTex, i.uv.xy).a;
			emission = mainTexA * _Emission.rgb;
			return  emission;
		#else
			return 0;
		#endif
					
	}

	Interpolators LightmappingVertexProgram(VertexData v)
	{
		//初始化
		Interpolators i = (Interpolators)0;

		//Interpolators i;

		//没有GI光照贴图坐标
		////光照贴图坐标
		//v.vertex.xy = v.uv1 * unity_LightmapST.xy + unity_LightmapST.zw;
		////顶点Z坐标必需存在
		//v.vertex.z = v.vertex.z > 0 ?  0.0001 : 0;
		//o.pos = UnityObjectToClipPos(v.vertex);

		//使用内置 UnityMetaVertexPosition 函数,来获取 uv1,uv2,静态光照,动态光照
		i.pos = UnityMetaVertexPosition(v.vertex, v.uv1, v.uv2, unity_LightmapST, unity_DynamicLightmapST);

		i.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);

		return i;
	}

	float4 LightmappingFragmentProgram(Interpolators i) : SV_TARGET
	{
			UnityMetaInput surfaceData;
			surfaceData.Emission = GetEmission(i);
			//DiffuseAndSpecularFromMetallic  函数内包括 Albedo 颜色与反射率
			float oneMinusReflectivity;
			surfaceData.Albedo = DiffuseAndSpecularFromMetallic(GetAlbedo(i),GetMetallic(i),
				surfaceData.SpecularColor, oneMinusReflectivity);
			//SmoothnessToRoughness 从平滑到粗糙度的转换更好的效果
			float roughness = SmoothnessToRoughness(GetSmoothness(i)) * 0.5;
			surfaceData.Albedo += surfaceData.SpecularColor * roughness;

			//UnityMetaFragment 是否输出albedo emissive
			return UnityMetaFragment(surfaceData);
	
	}

#endif