// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Unlit/Light4"
{
    Properties
    {
		_MainTex("Texture", 2D) = "white" {}
		// 漫反射顔色
		_DiffuseColor("漫反射材质颜色", Color) = (1.0, 1.0, 1.0, 1.0)
		_SpecularColor("高光材质颜色", Color) = (1.0, 1.0, 1.0, 1.0)
		_Gloss("高光区域", Range(8, 100)) = 20
		[Toggle(Diffuse_HalfLambert)] _HalfLambert("漫反射使用半兰特模型(否則 兰伯特模型)", Int) = 0
		[Toggle(Specular_BlinnPhone)] _Specular_BlinnPhone("高光使用Blinn-Phone模型(否則 Phone模型)", Int) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque"}
        LOD 100

        Pass
        {
			Tags {"LightMode" = "ForwardBase"}
			
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
			#pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
			#include "Lighting.cginc"
			// shader_feature
			// multi_compile
			#pragma shader_feature Diffuse_HalfLambert
			#pragma shader_feature Specular_BlinnPhone

            struct appdata
            {
                float4 vertex : POSITION;
				float3 normal: NORMAL;
                float2 uv : TEXCOORD0;
				float4 color: COLOR0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
				// 世界坐标系内法线向量
				float3 worldNormal: TEXCOORD2;
#ifdef Specular_BlinnPhone
				float3 worldViewDir: TEXCOORD3;
#endif
				float4 color: COLOR0;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
			half3 _DiffuseColor;
			half3 _SpecularColor;
			half _Gloss;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
				o.worldNormal = mul(v.normal, unity_WorldToObject);
#ifdef Specular_BlinnPhone
				o.worldViewDir = _WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld, v.vertex);
#endif
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.color = v.color * float4(_DiffuseColor, 1.0);
                return o;
            }

			// 环境光颜色
			half3 AmbientLightColor()
			{
				return UNITY_LIGHTMODEL_AMBIENT.xyz;
			}

			// 计算漫反射(兰伯特模型)
			half3 CalcLightDiffuse_Lambert(half3 lightColor, half3 diffColor, half3 worldNomral, half3 lightDir)
			{
				half3 ret = lightColor * diffColor * max(0, dot(worldNomral, lightDir));
				return ret;
			}

			// 计算漫反射（半兰特模型）
			half3 CalcLightDiffuse_HalfLambert(half3 lightColor, half3 diffColor, half3 worldNomral, half3 lightDir)
			{
				half3 ret = lightColor * diffColor * (0.5 * dot(worldNomral, lightDir) + 0.5);
				return ret;
			}

			// 计算Phone高光
			half3 CalcLightSpec_Phone(half3 lightColor, half3 specColor, half gloss, half3 lightDir, half3 worldNormal)
			{
				half3 v = lightDir;
				half3 r = reflect(-v, worldNormal);

				half3 ret = lightColor * specColor * pow(saturate(dot(v, r)), gloss);
				return ret;
			}

			// 计算Blinn-Phone高光
			half3 CalcLightSpec_BlinnPhone(half3 lightColor, half3 specColor, half gloss, half3 lightDir, half3 worldNormal, half3 worldViewDir)
			{
				half3 h = normalize(worldViewDir + lightDir);

				half3 ret = lightColor * specColor * pow(max(0, dot(worldNormal, h)), gloss);
				return ret;
			}

			// 平行光 atter 衰減
			half3 DirectLightColor(half3 worldNormal, half3 diffColor, half atter
#ifdef Specular_BlinnPhone
				, half3 worldViewDir
#endif
			)
			{
				// forwardbase,逐像素光源必然是平行光，_WorldSpaceLightPos0在平行光不是位置而是光源方向
				half3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
				/*-----------------漫反射-----------------------------*/
#ifdef Diffuse_HalfLambert
				// 半兰特模型
				half3 diff = CalcLightDiffuse_HalfLambert(_LightColor0, _DiffuseColor, worldNormal, lightDir);
#else
				// 兰伯特模型
				half3 diff = CalcLightDiffuse_Lambert(_LightColor0, _DiffuseColor, worldNormal, lightDir);
#endif
				diff *= diffColor;
				/*-------------------高光模型-------------------------*/
#ifdef Specular_BlinnPhone
				half3 spec = CalcLightSpec_BlinnPhone(_LightColor0, _SpecularColor, _Gloss, lightDir, worldNormal, worldViewDir);
#else
			
				half3 spec = CalcLightSpec_Phone(_LightColor0, _SpecularColor, _Gloss, lightDir, worldNormal);
#endif
				/*----------------------------------------------------*/
				half3 ret = (diff + spec) * atter;
				return ret;
			}

			// 使用不重要光照颜色却强制使用逐像素光照(支持四种，但前提需要设置为非重要光源)

            fixed4 frag (v2f i) : SV_Target
            {
				half3 worldNormal = normalize(i.worldNormal);
#ifdef Specular_BlinnPhone
				half3 worldViewDir = normalize(i.worldViewDir);
#endif

				half3 diffColor = i.color * tex2D(_MainTex, i.uv);
                // sample the texture
				half3 ambient = AmbientLightColor();
				half3 mixColor = ambient + DirectLightColor(worldNormal, diffColor, 1.0
#ifdef Specular_BlinnPhone
					, worldViewDir
#endif
				);
				fixed4 col = fixed4(mixColor, 1.0);
                return col;
            }
            ENDCG
        }
    }
}
