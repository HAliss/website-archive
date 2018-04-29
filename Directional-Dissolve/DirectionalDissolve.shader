Shader "Custom/DirectionalDissolve" {
    Properties {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _DissolveAmount("Dissolve amount", Range(-3,3)) = 0
        _Direction("Direction", vector) = (0,1,0,0)
        [HDR]_Emission("Emission", Color) = (1,1,1,1)
        _EmissionThreshold("Emission threshold", float) = 0.1
        _NoiseSize("Noise size", float ) = 1
    }
    SubShader {
        Tags { "RenderType"="Opaque" "DisableBatching" = "True"}
        LOD 200
        Cull off
 
        CGPROGRAM
        #pragma surface surf Lambert addshadow vertex:vert
 
        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0
 
        sampler2D _MainTex;
 
        struct Input {
            float2 uv_MainTex;
            float3 worldPosAdj;
        };
 
        fixed4 _Color;
        float _DissolveAmount;
        half4 _Direction;
        fixed4 _Emission;
        float _EmissionThreshold;
        float _NoiseSize;
 
        void vert (inout appdata_full v, out Input o) {
            UNITY_INITIALIZE_OUTPUT(Input,o);
            o.worldPosAdj =  mul (unity_ObjectToWorld, v.vertex.xyz);
        }
 
        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)
 
        float random (float2 input) { 
            return frac(sin(dot(input, float2(12.9898,78.233)))* 43758.5453123);
        }
 
        void surf (Input IN, inout SurfaceOutput o) {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            //Clipping
            half test = (dot(IN.worldPosAdj, normalize(_Direction)) + 1) / 2;
            clip (test - _DissolveAmount);
            //Emission noise
            float squares = step(0.5, random(floor(IN.uv_MainTex * _NoiseSize) * _DissolveAmount));
            half emissionRing = step(test - _EmissionThreshold, _DissolveAmount) * squares;
 
            o.Albedo = c.rgb;
            o.Emission = _Emission * emissionRing;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
