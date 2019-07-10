// Upgrade NOTE: replaced tex2D unity_Lightmap with UNITY_SAMPLE_TEX2D

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Unlit/Light4"
{
    Properties
    {
		_MainTex("漫反射纹理", 2D) = "white" {}
		_NormalTex("法线纹理", 2D) = "none" {}
		_BumpScale("法线纹理缩放", float) = 1.0
		// 漫反射顔色
		_DiffuseColor("漫反射材质颜色", Color) = (1.0, 1.0, 1.0, 1.0)
		_SpecularColor("高光材质颜色", Color) = (1.0, 1.0, 1.0, 1.0)
		_Gloss("高光区域", Range(0.1, 100)) = 20

		_fAttenuation0("点光源衰减因子1", Range(0.01, 1.0)) = 0.01
		_fAttenuation1("点光源衰减因子2", Range(0.01, 1.0)) = 0.01
		_fAttenuation2("点光源衰减因子3", Range(0.01, 1.0)) = 0.01

		_PointLightRange("自定义点光源范围", float) = 10.0
		_PointLightIndensity("自定义点光源强度", float) = 1.0
		_SHLightingScale("LightProbe缩放比", float) = 1

		[Toggle(Diffuse_HalfLambert)] _HalfLambert("漫反射使用半兰特模型(否則 兰伯特模型)", Int) = 0
		[Toggle(Diffuse_PhoneLight)] _Diffuse_PhoneLight("平行光是否开启高光(否则不开启)", Int) = 0
		[Toggle(Specular_PhoneLight)] _Specular_PhoneLight("点光源是否开启高光(否则不开启)", Int) = 0
		[Toggle(Specular_BlinnPhone)] _Specular_BlinnPhone("高光使用Blinn-Phone模型(否則 Phone模型)", Int) = 0
		[Toggle(Use_NormalMap)] _Use_NormalMap("使用NormalMap(否则 不使用法线贴图)", Int) = 0
		[Toggle(Use_CustomPointAtter)] _Use_CustomPointAtter("使用自定义点光源强度/范围(否则 使用系统)", Int) = 0
		[Toggle(LightAdd_SrcAlphaMode)] _LightAdd_SrcAlphaMode("使用SrcAlpha+One模式混合多光源(否则使用One+One模式)", Int) = 0
		// 必须是LightStatic才行
		[Toggle(Use_LightMap)] _Use_LightMap("LightStatic使用LightMap(否则不使用)", Int) = 0
		[Toggle(Use_LightProbe)] _Use_LightProbe("动态物体使用LightProbe(否则不使用)", Int) = 0
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
			#pragma shader_feature Diffuse_PhoneLight
			#pragma shader_feature Specular_BlinnPhone
			#pragma shader_feature Specular_PhoneLight
			#pragma shader_feature Use_NormalMap
			#pragma shader_feature Use_CustomPointAtter
			#pragma shader_feature LightAdd_SrcAlphaMode
			#pragma shader_feature Use_LightMap
			#pragma shader_feature Use_LightProbe

            struct appdata
            {
                float4 vertex : POSITION;
				float3 normal: NORMAL;
#ifdef Use_NormalMap
				float4 t: TANGENT;
#endif
                float2 uv : TEXCOORD0;
				float2 uv2: TEXCOORD1;
				float4 color: COLOR0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
				float4 uv : TEXCOORD0;
#if Use_NormalMap
				float4 TtoW0: TEXCOORD1;
				float4 TtoW1: TEXCOORD2;
				float4 TtoW2: TEXCOORD3;
#else
				float3 worldVertex: TEXCOORD1;
				// 世界坐标系内法线向量
				float3 worldNormal: TEXCOORD2;
#endif
				float4 color: COLOR0;
#if defined(Use_LightProbe) && !defined(LIGHTMAP_ON)
			//	float3 shlight: COLOR1;
#endif
            };

			// 漫反射贴图
            sampler2D _MainTex;
			// 法线贴图
			sampler2D _NormalTex;


            float4 _MainTex_ST;
			half3 _DiffuseColor;
			half3 _SpecularColor;
			half _Gloss;
			half _fAttenuation0;
			half _fAttenuation1;
			half _fAttenuation2;
			half _BumpScale;

			half _PointLightRange;
			half _PointLightIndensity;
			half _SHLightingScale;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
#ifdef Use_NormalMap
				
				float3 t = v.t.xyz;
				float3 n = v.normal;
				float3 p = cross(n, t) * v.t.w;
				float3x3 mat;
				// 要注意NORMALMAP的坐标系顺序，哪个是X，哪个是Y，哪个是Z。之前就是写错，以N为X,T为Y，P为Z（这是错的）
				// 法线一般都是为蓝色，R,G,B中B表示蓝色，因为一般法线靠近B，所以NORMAL是用Z表示的
				mat[0] = float3(t.x, p.x, n.x);
				mat[1] = float3(t.y, p.y, n.y);
				mat[2] = float3(t.z, p.z, n.z);
				mat = mul(unity_ObjectToWorld, mat); // 切线空间到模型坐标空间再到世界空间
				

				float3 worldVertex = mul(unity_ObjectToWorld, v.vertex);

				o.TtoW0 = float4(mat[0], worldVertex.x);
				o.TtoW1 = float4(mat[1], worldVertex.y);
				o.TtoW2 = float4(mat[2], worldVertex.z);
#else
				o.worldNormal = mul(v.normal, unity_WorldToObject);
				o.worldVertex = mul(unity_ObjectToWorld, v.vertex);
#endif
				
                o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);

				// 只有LightStatic才能用LIGHTMAP， 动态物体只能通过LightProbe使用球协函数计算光照
#if defined(Use_LightMap) && defined(LIGHTMAP_ON)
				o.uv.zw = v.uv2.xy * unity_LightmapST.xy + unity_LightmapST.zw;
#endif
				o.color = v.color * float4(_DiffuseColor, 1.0);

#if defined(Use_LightProbe) && !defined(LIGHTMAP_ON)
		//		float3 worldNormal = mul(v.normal, unity_WorldToObject);
			//	o.shlight = ShadeSH9(float4(worldNormal, 1.0)) * _SHLightingScale;
#endif
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
#ifdef Diffuse_PhoneLight
				/*-------------------高光模型-------------------------*/
#ifdef Specular_BlinnPhone
				half3 spec = CalcLightSpec_BlinnPhone(_LightColor0, _SpecularColor, _Gloss, lightDir, worldNormal, worldViewDir);
#else
			
				half3 spec = CalcLightSpec_Phone(_LightColor0, _SpecularColor, _Gloss, lightDir, worldNormal);
#endif
#else
				half3 spec = half3(0, 0, 0);
#endif
				/*----------------------------------------------------*/
				half3 ret = (diff + spec) * atter;
				return ret;
			}

			// 使用不重要光照颜色却强制使用逐像素光照(支持四种，但前提需要设置为非重要光源)
			half CalcPointLightAtter(half3 lightWorldPos, half3 worldVertex, half att)
			{
				half3 lightDir = lightWorldPos - worldVertex;
				float distance = length(lightDir);
#ifdef Use_CustomPointAtter
				//half ret = pow(((pow(_PointLightRange, 2) - pow(distance, 2)) / pow(_PointLightRange, 2)), 2) * pow(_PointLightIndensity / 2, 3);
				half ret = saturate((1.0 - distance / _PointLightRange) *  _PointLightIndensity);
#else
				half ret = saturate(1.0 / (_fAttenuation0 + _fAttenuation1 * distance + pow(_fAttenuation2, 2)) * att);
#endif
				return ret;
			}

			// 点光源
			half4 PointLight(half3 lightWorldPos, half3 worldVertex, half3 worldNormal, half3 lightColor, half3 diffColor, half att
#ifdef Specular_BlinnPhone
				, half3 worldViewDir
#endif
			)
			{
				half3 lightDir = normalize(lightWorldPos - worldVertex);
				/*-----------------漫反射-----------------------------*/
#ifdef Diffuse_HalfLambert
				// 半兰特模型
				half3 diff = CalcLightDiffuse_HalfLambert(lightColor, _DiffuseColor, worldNormal, lightDir);
#else
				// 兰伯特模型
				half3 diff = CalcLightDiffuse_Lambert(lightColor, _DiffuseColor, worldNormal, lightDir);
#endif
				/*-------------------高光模型-------------------------*/
				// 是否点光源开启高光
#ifdef Specular_PhoneLight
	#ifdef Specular_BlinnPhone
				half3 spec = CalcLightSpec_BlinnPhone(lightColor, _SpecularColor, _Gloss, lightDir, worldNormal, worldViewDir);
	#else

				half3 spec = CalcLightSpec_Phone(lightColor, _SpecularColor, _Gloss, lightDir, worldNormal);
	#endif
#else
				half3 spec = half3(0, 0, 0);
#endif
				/*----------------------------------------------------*/
				half atter = CalcPointLightAtter(lightWorldPos, worldVertex, att);
				half4 ret = half4(diff * diffColor + spec, 1) * atter;
				return ret;
			}

            fixed4 frag (v2f i) : SV_Target
            {
#ifdef Use_NormalMap
				half3 worldVertex = half3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
				half3 normal = UnpackNormal(tex2D(_NormalTex, i.uv.xy));
				normal.xy *= _BumpScale;
				normal.z = sqrt(1.0 - saturate(dot(normal.xy, normal.xy)));
				half3 worldNormal = normalize(half3(dot(i.TtoW0.xyz, normal), dot(i.TtoW1.xyz, normal), dot(i.TtoW2.xyz, normal)));
#else
				half3 worldVertex = i.worldVertex;
				half3 worldNormal = normalize(i.worldNormal);
#endif



#ifdef Specular_BlinnPhone
				half3 worldViewDir = normalize(_WorldSpaceCameraPos.xyz - worldVertex);
#endif

				half4 diffColor = i.color * tex2D(_MainTex, i.uv.xy);

#if defined(Use_LightMap) && defined(LIGHTMAP_ON)
				
				fixed3 lm = DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, i.uv.zw));
				lm.rgb *= diffColor.rgb;
#endif

                // sample the texture
				half3 ambient = AmbientLightColor();
#ifdef USING_DIRECTIONAL_LIGHT
				half3 directColor = DirectLightColor(worldNormal, diffColor, 1.0
#ifdef Specular_BlinnPhone
					, worldViewDir
#endif
				);
#else
				half3 directColor = half3(0, 0, 0);
#endif

				half3 lightPos1 = half3(unity_4LightPosX0.x, unity_4LightPosY0.x, unity_4LightPosZ0.x);
				half3 lightPos2 = half3(unity_4LightPosX0.y, unity_4LightPosY0.y, unity_4LightPosZ0.y);
				half3 lightPos3 = half3(unity_4LightPosX0.z, unity_4LightPosY0.z, unity_4LightPosZ0.z);
				half3 lightPos4 = half3(unity_4LightPosX0.w, unity_4LightPosY0.w, unity_4LightPosZ0.w);

				half4 light0Color = PointLight(lightPos1, worldVertex, worldNormal, unity_LightColor[0], diffColor, unity_4LightAtten0.x
#ifdef Specular_BlinnPhone 
					, worldViewDir 
#endif
				);
				//light0Color.a = 0.5f;
				half4 light1Color = PointLight(lightPos2, worldVertex, worldNormal, unity_LightColor[1], diffColor, unity_4LightAtten0.y
#ifdef Specular_BlinnPhone
					, worldViewDir 
#endif
				);
				half4 light2Color = PointLight(lightPos3, worldVertex, worldNormal, unity_LightColor[2], diffColor, unity_4LightAtten0.z
#ifdef Specular_BlinnPhone
					, worldViewDir 
#endif
				);
				half4 light3Color = PointLight(lightPos3, worldVertex, worldNormal, unity_LightColor[3], diffColor, unity_4LightAtten0.w
#ifdef Specular_BlinnPhone
					, worldViewDir
#endif
				);
				//light0Color = half4(0, 0, 0, 0);
				//light1Color = half4(0, 0, 0, 0);
			//	light2Color = half4(0, 0, 0, 0);
			   // light3Color = half4(0, 0, 0, 0);
			//	directColor = half3(0, 0, 0);
			//	ambient = half3(0, 0, 0)

#ifdef _LightAdd_SrcAlphaMode
				half3 mixColor = light0Color.rgb * light0Color.a + directColor;
				mixColor = light1Color.rgb * light1Color.a + mixColor;
				mixColor = light2Color.rgb * light2Color.a + mixColor;
				mixColor = light3Color.rgb * light3Color.a + mixColor;
				mixColor = ambient + mixColor;

				fixed4 col = fixed4(mixColor, 1.0);
#else
				half3 mixColor = ambient + directColor + light0Color.rgb + light1Color.rgb + light2Color.rgb + light3Color.rgb;
				fixed4 col = fixed4(mixColor, 1.0);
#endif

#if defined(Use_LightMap) && defined(LIGHTMAP_ON)
				// 计算LIGHTMAP
				col.rgb += lm.rgb;
#endif

#if defined(Use_LightProbe) && defined(LIGHTMAP_OFF)
				half3 sh3 = ShadeSH9(float4(worldNormal, 1.0)) * _SHLightingScale;
				col.rgb += sh3 * diffColor;
#endif

                return col;
            }
            ENDCG
        }
    }
}
