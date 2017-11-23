Shader "Custom/ShockWave"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Radius("Radius", float) = 1.0
        _Thickness("Thickness", float) = 0.5
        _CenterX("CenterX", float) = 0.5
        _CenterY("CenterY", float) = 0.5
        _SizeX("SizeX", float) = 1
        _SizeY("SizeY", float) = 1
        _Hardness("Harndess", float) = 1.0
        _Invert("Invert", Range(-1.0, 1.0)) = 0
 
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
            float _Radius;
            float _Hardness;
            float _CenterX;
            float _CenterY;
            float _SizeX;
            float _SizeY;
            float _Invert;
            float _Thickness;
 
            float _DisplacementAmount;
 
            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 c = tex2D(_MainTex, i.uv);
                float dist = length(float2(i.uv.x - _CenterX, i.uv.y - _CenterY) * float2(_SizeX, _SizeY));
                float rd = _Thickness/2;
                float rc = _Radius - rd;
                float circle = saturate(abs(dist - rc) / _Thickness);
                float circleAlpha = pow(circle, pow(_Hardness, 2));
                float a = (_Invert > 0) ? circleAlpha * _Invert : (1 - circleAlpha) * (-_Invert);
                half4 mask = (c.rgb, a * c.a);
 
                float2 displ_uv = i.uv + mask * _DisplacementAmount;
                half4 distortedCol = tex2D(_MainTex, displ_uv);
                return distortedCol;
            }
            ENDCG
        }
    }
}
