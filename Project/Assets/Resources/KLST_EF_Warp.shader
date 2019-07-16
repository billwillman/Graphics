Shader "KLST/EF/Warp"
{
	//CommandBuffer 热扭曲
	Properties
	{
		_MainTex ("Alpha", 2D) = "white" {}
		_Alpha("半透明度",Range(0,1)) = 1
		_BumpAmt("扭曲强度",Range(0,256)) = 10
		_BumpMap("Normalmap",2D) = "bump"{}
	}
	SubShader
	{
		//在半透明之后渲染
		Tags {"Queue" = "Transparent-250" "RenderType" = "Opaque"}
		LOD 100

		Pass
		{
			Tags{"LightMode" = "Always"}
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uvmain : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
				float4 uvgrab : TEXCOORD2;
				float2 uvbump : TEXCOORD3;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _Alpha;

			float _BumpAmt;
			sampler2D _BumpMap;
			float4 _BumpMap_ST;

			sampler2D _GrabBlurTexture;
			float4 _GrabBlurTexture_TexelSize;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				#if UNITY_UV_STARTS_AT_TOP
					float scale = -1.0;
				#else
					float scale = 1.0;
				#endif

				//RTUV坐标
				o.uvgrab.xy = (float2(o.vertex.x, o.vertex.y * scale) + o.vertex.w) * 0.5;
				o.uvgrab.zw = o.vertex.zw;
				
				o.uvbump = TRANSFORM_TEX(v.uv, _BumpMap);
				o.uvmain = TRANSFORM_TEX(v.uv, _MainTex);

				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float4 col = float4(1,1,1,1);
				half2 bump = UnpackNormal(tex2D(_BumpMap, i.uvbump)).rg;
				float2 offset = bump * _BumpAmt * _GrabBlurTexture_TexelSize.xy;
				i.uvgrab.xy = offset * i.uvgrab.z + i.uvgrab.xy;

				half4 rtTex = tex2Dproj(_GrabBlurTexture, UNITY_PROJ_COORD(i.uvgrab));
				half4 mainTex = tex2D(_MainTex, i.uvmain);
				col.rgb = rtTex.rgb;
				col.a =  _Alpha * mainTex.r;
				
				//UNITY_APPLY_FOG_COLOR(i.fogCoord, col, fixed4(0, 0, 0, 0));

				//UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
}
