Shader "Custom/DisplacementImageEffect"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _DisplTex("Displacement Texture", 2D) = "white" {}
        _DisplAmount("Displacement Amount", Range(0, 0.1)) = 1
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
            sampler2D _DisplTex;
            float _DisplAmount;
  
            fixed4 frag (v2f i) : SV_Target
            {
                float2 changingUV = i.uv + _Time.x * 2;
                float2 displ = tex2D(_DisplTex, changingUV).xy;
                displ = ((displ * 2) - 1) * _DisplAmount;
                fixed4 col = tex2D(_MainTex, i.uv + displ);
                return col;
            }
            ENDCG
        }
    }
}
