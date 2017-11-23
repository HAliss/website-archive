Shader "Custom/CustomWaveyDisplacement"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Frequency ("Frequency", float) = 10
        _DisplAmount ("Displacement amount", float) = 1
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
            float _Frequency;
            float _DisplAmount;
 
            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 waveyDispl = lerp(fixed4(1,0,0,1), fixed4(0,1,0,1), (sin(i.uv.y * _Frequency) + 1) / 2);
                float2 displUV = float2(waveyDispl.x * _DisplAmount - waveyDispl.y * _DisplAmount, 0);
                fixed4 col = tex2D(_MainTex, i.uv + displUV);
                return col;
            }
            ENDCG
        }
    }
}
