Shader "Unlit/PortalCard"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BaseColor("Base color", color) = (1,1,1,1)
        _MaxCamDist("Max Camera distance", float) = 100
        _MinAlphaValue("Min alpha value", Range(0.0, 1.0)) = 0.0
        _MaxAlphaValue("Max alpha value", Range(0.0, 1.0)) = 1.0
        _FallOffU("Falloff U", float) = 0.0
        _FallOffV("Falloff V", float) = 0.0
    }
    SubShader
    {
        Tags {"Queue"="Transparent" "RenderType"="Transparent" }
        LOD 100
 
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha
 
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
                float4 worldPos : TEXCOORD1;
            };
 
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _BaseColor;
            float _MaxCamDist;
            float _MinAlphaValue;
            float _MaxAlphaValue;
            float _FallOffU;
            float _FallOffV;
 
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }
             
            fixed4 frag (v2f i) : SV_Target
            {
                const float PI = 3.14159;
                fixed4 col = tex2D(_MainTex, i.uv) * _BaseColor;
                float camDist = distance(i.worldPos, _WorldSpaceCameraPos);
                col.a =  lerp(_MinAlphaValue, _MaxAlphaValue, saturate(camDist/_MaxCamDist));
                float falloffU = pow((sin(i.uv.x * PI) + 1) / 2, _FallOffU);
                float falloffV = pow((sin(i.uv.y * PI) + 1) / 2, _FallOffV);
                col.a *= falloffU * falloffV;
                return col;
            }
            ENDCG
        }
    }
}
