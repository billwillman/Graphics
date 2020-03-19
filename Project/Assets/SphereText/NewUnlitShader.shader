Shader "Unlit/NewUnlitShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_ProjTex("Texture", 2D) = "black" {}
	}
		SubShader
	{
		Tags { "RenderType" = "Opaque" }
		LOD 100

		Pass
		{
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
                float2 uv : TEXCOORD0;
				float4 proj : TEXCOORD1;
                UNITY_FOG_COORDS(2)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
			sampler2D _ProjTex;
            float4 _MainTex_ST;
			// 投影矩阵
			uniform float4x4 _ProjMat;

            v2f vert (appdata v)
            {
                v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				float4 vv = mul(unity_ObjectToWorld, v.vertex);
				o.proj = mul(_ProjMat, vv);
				o.proj.xy = (o.proj.xy + 1)/2.0;
				//o.proj.xy = (o.proj.xy + 1);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
				fixed4 c2 = tex2D(_ProjTex, i.proj); // tex2D和tex2Dproj区别，tex2Dproj内部会对xyz/w 
				fixed4 c = c2 * col;
				//fixed4 c2 = tex2Dproj(_ProjTex, UNITY_PROJ_COORD(i.proj));
                // apply fog
                //UNITY_APPLY_FOG(i.fogCoord, c2);

                return c;
            }
            ENDCG
        }
    }
}
