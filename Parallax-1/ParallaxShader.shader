Shader "Custom/ParallaxShader" {
    Properties {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Normal ("Normal", 2D) = "bump" {}
        _Height("Height", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _Parallax("Parallax", float) = 0
    }
    SubShader {
        Tags { "RenderType"="Opaque" }
        LOD 200
 
        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows
 
        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0
 
        sampler2D _MainTex;
        sampler2D _Normal;
        sampler2D _Height;
 
        struct Input {
            float2 uv_MainTex;
            float2 uv_Normal;
            float2 uv_Height;
            float3 viewDir;
        };
 
        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
        float _Parallax;
 
        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)
 
        void surf (Input IN, inout SurfaceOutputStandard o) {
            // Albedo comes from a texture tinted by color
            float heightTex = tex2D(_Height, IN.uv_Height).r;
            float2 parallaxOffset = ParallaxOffset(heightTex, _Parallax, IN.viewDir);
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex + parallaxOffset) * _Color;
            o.Normal = UnpackNormal(tex2D(_Normal, IN.uv_Normal + parallaxOffset));
            o.Albedo = c.rgb;
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
