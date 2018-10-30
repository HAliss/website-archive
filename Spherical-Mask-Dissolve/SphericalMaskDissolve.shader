Shader "Custom/SphericalMaskDissolve" {
    Properties {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        [HDR]_Emission("Emission", Color) = (1,1,1,1)
        _NoiseSize("Noise size", float ) = 1
    }
    SubShader {
        Tags { "RenderType"="Opaque" }
        Cull off
        LOD 200
 
        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows
 
        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0
 
        sampler2D _MainTex;
 
        struct Input {
            float2 uv_MainTex;
            float3 worldPos;
        };
 
        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
 
        fixed4 _Emission;
        float _NoiseSize;
 
        float3 _GLOBALMaskPosition;
        half _GLOBALMaskRadius;
        half _GLOBALMaskSoftness;
 
        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)
 
        float random (float2 input) { 
            return frac(sin(dot(input, float2(12.9898,78.233)))* 43758.5453123);
        }
 
        void surf (Input IN, inout SurfaceOutputStandard o) {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            half dist = distance(_GLOBALMaskPosition, IN.worldPos);
            half sphere = 1 - saturate((dist - _GLOBALMaskRadius) / _GLOBALMaskSoftness);
            clip(sphere - 0.1);
            float squares = step(0.5, random(floor(IN.uv_MainTex * _NoiseSize)));
            half emissionRing = step(sphere - 0.1, 0.1) * squares;
            o.Emission = _Emission * emissionRing;
            o.Albedo = c.rgb;
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
