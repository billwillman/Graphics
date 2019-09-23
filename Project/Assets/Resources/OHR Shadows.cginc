#if !defined(MY_SHADOWS_INCLUDED)
#define MY_SHADOWS_INCLUDED

	#include "UnityCG.cginc"

	//半透明判断
	#if defined (_RENDERING_FADE) || defined(_RENDERING_TRANSPARENT)
		//非透明时
		#if defined (_SEMITRANSPARENT_SHADOWS)
			#define SHADOWS_SEMITRANSPARENT 1
		#else 
			#define _RENDERING_CUTOUT
		#endif
	#endif 

	//半透明与剪切渲染 uv通道启用
	#if defined(_RENDERING_CUTOUT) || defined(SHADOWS_SEMITRANSPARENT)
		#if !defined (_SMOOTHNESS_ALBEDO)
			#define SHADOWS_NEED_UV 1
		#endif 		
	#endif

	float4 _Color;
	sampler2D _MainTex;
	float4 _MainTex_ST;
	float _Cutoff;

	#if defined (_WINDTEX)
		sampler2D _WindNoise;
		float _NoiseScale, _NoiseTime, _WindFrecuency, _WindStrength, _WindGustDistance;
		float4 _NoiseDirection, _WindDirection;
	#endif 

	//unity 阴影抖动模式纹理
	sampler3D _DitherMaskLOD;

	struct VertexInput
	{
		float4 vertex : POSITION;
		float3 normal : NORMAL;
		float2 uv : TEXCOORD0;
		float4 color :COLOR;

	};

	//通过VPOS来访问像素阶段的屏幕空间位置,有vpos的顶点输出
	struct PositionOutput
	{
		#if SHADOWS_SEMITRANSPARENT
			UNITY_VPOS_TYPE vpos : VPOS;
		#else
			float4 psoitions : SV_POSITION;
		#endif

		#if SHADOWS_NEED_UV
			float2 uv : TEXCOORD0;
		#endif 

		#if defined(SHADOWS_CUBE)
			float3 lightVec : TEXCOORD1;
		#endif
	};

	//正常顶点输出
	struct VertexOutput
	{
		float4 position : SV_POSITION;
		//是否对当前AlbedoUV纹理采样
		#if SHADOWS_NEED_UV
			float2 uv : TEXCOORD0;
		#endif

		#if defined (SHADOWS_CUBE)
			float3 lightVec : TEXCOORD1;
		#endif

		#if defined(_WINDTEX)
			float2 noiseUV : TEXCOORD2;
		#endif
		float4 color : COLOR;
	};

	//Alpha
	float GetAlpha(PositionOutput i)
	{
		float alpha = _Color.a;
		#if SHADOWS_NEED_UV
			alpha *= tex2D(_MainTex, i.uv).a;
		#endif	

		return alpha;
	}

	VertexOutput MyShadowVertexProgram(VertexInput v)
	{
		VertexOutput o = (VertexOutput)0;
		//顶点动画
		#if defined(_WINDTEX)
			float4 localSpaceVertex = (v.vertex);

			//转换顶点到世界空间坐标
			float4 worldSpaceVertex = mul(unity_ObjectToWorld, v.vertex);
			//转换顶点高度
			//float height = (localSpaceVertex.y / 2 + 1);

			//扭曲贴图
			o.noiseUV = worldSpaceVertex.xz;
			o.noiseUV += _Time.x * _NoiseTime;
			float3 windNoise = tex2Dlod(_WindNoise, float4(o.noiseUV, 0, 0) * _NoiseScale).rgb;

			//风力计算				
			//worldSpaceVertex.x += sin(_Time.x * _WindFrecuency + worldSpaceVertex.x * _WindGustDistance ) * _WindStrength * _WindDirection.x * windNoise.r * v.color.a;

			//sin 波段
			float XSin = sin(_Time.x * _WindFrecuency + worldSpaceVertex.x * _WindGustDistance);
			worldSpaceVertex.x += (XSin * _WindStrength * _WindDirection.x) * v.color.a * v.color.r + (windNoise.r * _NoiseDirection.x) * v.color.a;

			//剔除高度,防止阴影投射自身
			//worldSpaceVertex.y += sin(_Time.x * _WindFrecuency + worldSpaceVertex.y * _WindGustDistance) * _WindStrength * _WindDirection.y  * v.color.a;
			//float YSin = sin(_Time.x * _WindFrecuency + worldSpaceVertex.y *_WindGustDistance);
			//worldSpaceVertex.y += (YSin * _WindStrength * _WindDirection.y) * v.color.a * v.color.g + (windNoise.g * _NoiseDirection.y) * v.color.a;

			float ZSin = sin(_Time.x * _WindFrecuency + worldSpaceVertex.z * _WindGustDistance);
			worldSpaceVertex.z += (ZSin * _WindStrength * _WindDirection.z) * v.color.a * v.color.b + (windNoise.b * _NoiseDirection.z) * v.color.a;

			//o.vertex = UnityObjectToClipPos(v.vertex);
			float4 worldPso = mul(unity_WorldToObject, worldSpaceVertex);
			//o.position = UnityObjectToClipPos(worldPso);
		#endif

		#if defined (SHADOWS_CUBE)
			o.position = UnityObjectToClipPos(v.vertex);
			o.lightVec = mul(unity_ObjectToWorld, v.vertex).xyz - _LightPositionRange.xyz;
		#else
			#if defined(_WINDTEX)
				o.position = UnityClipSpaceShadowCasterPos(worldPso.xyz, v.normal);
				o.position = UnityApplyLinearShadowBias(o.position);
			#else
				o.position = UnityClipSpaceShadowCasterPos(v.vertex.xyz, v.normal);
				o.position = UnityApplyLinearShadowBias(o.position);
			#endif
		#endif

		#if SHADOWS_NEED_UV
			o.uv = TRANSFORM_TEX(v.uv, _MainTex);
		#endif 
	
		return o;
	}

	

	float4 MyShadowFragmentProgram(PositionOutput i):SV_TARGET
	{
		float alpha = GetAlpha(i);
		#if defined(_RENDERING_CUTOUT)
			clip(alpha - _Cutoff);
		#endif

		//阴影抖动纹理 3D坐标,第三个坐标应该在 0 - 1 之间 
		#if SHADOWS_SEMITRANSPARENT
			float dither = tex3D(_DitherMaskLOD, float3(i.vpos.xy * 0.25, alpha * 0.9375)).a;
			clip(dither - 0.01);
		#endif

		#if defined(SHADOWS_CUBE)
			float depth = length(i.lightVec) + unity_LightShadowBias.x;
			depth *= _LightPositionRange.w;
			return UnityEncodeCubeShadowDepth(depth);
		#else
			return 0;
		#endif	
	}

	
#endif