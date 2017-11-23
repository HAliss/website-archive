Shader "Custom/NightTime"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NightTime("Night time", Range(0.001, 1)) = 1
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always
  
        Pass
        {
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
  
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }
  
            sampler2D _MainTex;
            float _NightTime;
  
            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                fixed lum = Luminance(col.rgb);
                fixed4 output;
                output.rgb = lerp(col.rgb, fixed3(lum,lum,lum), _NightTime);
                output.a = col.a;
                return (output + _NightTime * fixed4(0, 0, 0.8, 1)) * (1 - _NightTime);
            }
            ENDCG
        }
    }
}
