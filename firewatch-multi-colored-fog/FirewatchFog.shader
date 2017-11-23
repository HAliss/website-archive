Shader "Custom/FirewatchFog"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _FogAmount("Fog amount", float) = 1
        _ColorRamp("Color ramp", 2D) = "white" {}
        _FogIntensity("Fog intensity", float) = 1
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
                float4 scrPos : TEXCOORD1;
            };
 
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.scrPos = ComputeScreenPos(o.vertex);
                return o;
            }
             
            sampler2D _MainTex;
            sampler2D _CameraDepthTexture;
            sampler2D _ColorRamp;
            float _FogAmount;
            float _FogIntensity;
 
            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 orCol = tex2D(_MainTex, i.uv);
                float depthValue = Linear01Depth (tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(i.scrPos)));
                float depthValueMul = depthValue * _FogAmount;
                fixed4 fogCol = tex2D(_ColorRamp, (float2(depthValueMul, 0)));
                return (depthValue < 1) ? lerp(orCol, fogCol, fogCol.a * _FogIntensity) : orCol;
            }
            ENDCG
        }
    }
}
