Shader "Custom/ChromaticAberrationShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Amount("Amount", Range(0.0, 1)) = 0.0005
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
            float _Amount;
  
            fixed4 frag (v2f i) : SV_Target
            {
                float colR = tex2D(_MainTex, float2(i.uv.x - _Amount, i.uv.y - _Amount)).r;
                float colG = tex2D(_MainTex, i.uv).g;
                float colB = tex2D(_MainTex, float2(i.uv.x + _Amount, i.uv.y + _Amount)).b;
                return fixed4(colR, colG, colB, 1);
            }
            ENDCG
        }
    }
}
