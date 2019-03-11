Shader "Custom/LayeredParallax" {
    Properties {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
 
        _ParallaxMap("Parallax map", 2D) = "white" {}
        _Iterations("Iterations", float) = 5
        _OffsetScale("Offset scale", float) = 0
    }
    SubShader {
        Tags { "RenderType"="Opaque" "DisableBatching"="True"}
        LOD 200
 
        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows vertex:vert
 
        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0
 
        sampler2D _MainTex;
        sampler2D _ParallaxMap;
 
        struct Input {
            float2 uv_MainTex;
            float2 uv_ParallaxMap;
            float3 viewDirTangent;
        };
 
        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
        float _OffsetScale;
        float _Iterations;
 
        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)
 
        void vert (inout appdata_full v, out Input o) {
            UNITY_INITIALIZE_OUTPUT(Input,o);
            float4 objCam = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1.0));
            float3 viewDir = v.vertex.xyz - objCam.xyz;
            float tangentSign = v.tangent.w * unity_WorldTransformParams.w;
            float3 bitangent = cross(v.normal.xyz, v.tangent.xyz) * tangentSign;
            o.viewDirTangent = float3(
                dot(viewDir, v.tangent.xyz),
                dot(viewDir, bitangent.xyz),
                dot(viewDir, v.normal.xyz)
            );
        }
 
        void surf (Input IN, inout SurfaceOutputStandard o) {
            float parallax = 0;
            for (int j = 0; j < _Iterations; j ++) {
                float ratio = (float) j / _Iterations;
                parallax +=  tex2D(_ParallaxMap, IN.uv_ParallaxMap + lerp(0, _OffsetScale, ratio) * normalize(IN.viewDirTangent)) * lerp(1, 0, ratio);
            }
            parallax /= _Iterations;
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb + parallax;
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
