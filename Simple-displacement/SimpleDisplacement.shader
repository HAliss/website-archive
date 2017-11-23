Shader "Custom/SimpleDisplacement"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _DisplacementMask("Displacement mask", 2D) = "white"
        _DisplacementAmount("Displacement amount", float) = 0
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
            sampler2D _DisplacementMask;
            float _DisplacementAmount;
  
            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 displ = tex2D(_DisplacementMask, i.uv);
                float2 displ_uv = i.uv + displ * _DisplacementAmount;
                fixed4 distortedCol = tex2D(_MainTex, displ_uv);
                return distortedCol;
            }
            ENDCG
        }
    }
}
