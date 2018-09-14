Shader "Hidden/SphericalMaskPP"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Position("Position", vector) = (0,0,0,0)
        _Radius("Radius", float) = 0.5
        _Softness("Softness", float) = 0.5
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
                float3 worldDirection : TEXCOORD1;
                float4 vertex : SV_POSITION;
            };
             
            float4x4 _ClipToWorld;
 
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
 
                float4 clip = float4(o.vertex.xy, 0.0, 1.0);
                o.worldDirection = mul(_ClipToWorld, clip) - _WorldSpaceCameraPos;
                return o;
            }
             
            sampler2D _MainTex;
 
            sampler2D _CameraDepthTexture;
 
            float4 _Position;
            half _Radius;
            half _Softness;
 
            fixed4 frag (v2f i) : SV_Target
            {
                //Get the depth of the camera
                float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv.xy);
                depth = LinearEyeDepth(depth);
             
                //Get the different colors
                fixed4 col = tex2D(_MainTex, i.uv);
                half lum = Luminance(col.rgb);
                fixed4 colGray = fixed4(lum,lum,lum,1);
 
                //Calculate world position and distance from the spherical mask
                float3 wpos = i.worldDirection * depth + _WorldSpaceCameraPos;
                half d = distance(_Position, wpos);
                half sum = saturate((d - _Radius) / _Softness);
                fixed4 finalColor = lerp(colGray, col, sum);
 
                return finalColor;
            }
            ENDCG
        }
    }
}
