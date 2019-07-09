Shader "Unlit/Radius"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
	    _MaxRadius("外圆半径", float) = 0.5
        _LineWidth("圆环宽度", float)=0.15
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent"}
		Blend SrcAlpha OneMinusSrcAlpha

        LOD 100

        Pass
        {
			ZWrite Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
			half _MaxRadius;
			half _LineWidth;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
				half center = half2(0.5, 0.5);
				half2 p = i.uv - center;
				half distance2 = p.x * p.x + p.y * p.y;
				half maxDistance2 = _MaxRadius * _MaxRadius;
				half minDistance2 = maxDistance2 - _LineWidth * _LineWidth;
				half alpha1 = step(minDistance2, distance2);
				half alpha2 = step(distance2, maxDistance2);
				half alpha = alpha1 * alpha2;

                fixed4 col = tex2D(_MainTex, i.uv);
				//col.a *= alpha;
				col.a *= alpha;
                return col;
            }
            ENDCG
        }
    }
}
