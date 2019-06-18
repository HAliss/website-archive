Shader "VFX/VFXMasterShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _GradientMap("Gradient map", 2D) = "white" {} 
 
        //Secondary texture
        [Space(20)]
        [Toggle(SECONDARY_TEX)]
        _HasSecondaryTexture("Has secondary texture", float) = 0
        _SecondaryTex("Secondary texture", 2D) = "white" {}
        _SecondaryPanningSpeed("Secondary panning speed", Vector) = (0,0,0,0)
 
        [Space(20)]
        [HDR]_Color("Color", Color) = (1,1,1,1)
        _PanningSpeed("Panning speed (XY main texture - ZW displacement texture)", Vector) = (0,0,0,0)
        _Contrast("Contrast", float) = 1
        _Power("Power", float) = 1
 
        //Clipping
        [Space(20)]
        _Cutoff("Cutoff", Range(0, 1)) = 0
        [HDR]_BurnCol("Burn color", Color) = (1,1,1,1)
        _BurnSize("Burn size", float) = 0
 
        //Vertex offset
        [Space(20)]
        [Toggle(VERTEX_OFFSET)]
        _VertexOffset("Vertex offset", float) = 0
        _VertexOffsetAmount("Vertex offset amount", float) = 0
 
        //Displacement
        [Space(20)]
        _DisplacementAmount("Displacement", float) = 0
        _DisplacementGuide("DisplacementGuide", 2D) = "white" {}
 
        //Culling
        [Enum(UnityEngine.Rendering.CullMode)]
        _Culling ("Cull Mode", Int) = 2
 
        //Banding
        [Space(20)]
        [Toggle(BANDING)]
        _Banding("Color banding", float) = 0
        _Bands("Number of bands", float) = 3
 
        //Polar coordinates
        [Space(20)]
        [Toggle(POLAR)]
        _PolarCoords("Polar coordinates", float) = 0
 
        //Mask
        [Space(20)]
        [Toggle(CIRCLE_MASK)]
        _CircleMask("Circle mask", float) = 0
        _OuterRadius("Outer radius", Range(0,1)) = 0.5
        _InnerRadius("Inner radius", Range(-1,1)) = 0
        _Smoothness("Smoothness", Range(0,1)) = 0.2
    }
    SubShader
    {
        Tags { "RenderType"="Opaque"}
        Offset -1, -1
        Cull [_Culling]
        LOD 100
 
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma shader_feature VERTEX_OFFSET
            #pragma shader_feature SECONDARY_TEX
            #pragma shader_feature BANDING
            #pragma shader_feature POLAR
            #pragma shader_feature CIRCLE_MASK
            // make fog work
            #pragma multi_compile_fog
 
            #include "UnityCG.cginc"
 
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                fixed4 color : COLOR;
                float3 normal : NORMAL;
            };
 
            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float2 displUV : TEXCOORD2;
                float2 secondaryUV : TEXCOORD3;
                float4 vertex : SV_POSITION;
                fixed4 color : COLOR;
            };
 
            sampler2D _MainTex;
            sampler2D _SecondaryTex;
            float4 _SecondaryTex_ST;
            float4 _MainTex_ST;
            sampler2D _GradientMap;
            float _Contrast;
            float _Power;
 
            fixed4 _Color;
 
            float _Bands;
 
            float4 _PanningSpeed;
            float4 _SecondaryPanningSpeed;
             
            float _Cutoff;
            fixed4 _BurnCol;
            float _BurnSize;
 
            float _VertexOffsetAmount;
 
            sampler2D _DisplacementGuide;
            float4 _DisplacementGuide_ST;
            float _DisplacementAmount;
 
            float _Smoothness;
            float _OuterRadius;
            float _InnerRadius;
 
            v2f vert (appdata v)
            {
                v2f o;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.secondaryUV = TRANSFORM_TEX(v.uv, _SecondaryTex);
 
                #ifdef VERTEX_OFFSET
                float vertOffset = tex2Dlod(_MainTex, float4(o.uv + _Time.y * _PanningSpeed.xy, 1, 1)).x;
                #ifdef SECONDARY_TEX
                float secondTex = tex2Dlod(_SecondaryTex, float4(o.secondaryUV + _Time.y * _SecondaryPanningSpeed.xy, 1, 1)).x;
                vertOffset = vertOffset * secondTex * 2;
                #endif
                vertOffset = ((vertOffset * 2) - 1) * _VertexOffsetAmount;
                v.vertex.xyz += vertOffset * v.normal;
                #endif
 
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.displUV = TRANSFORM_TEX(v.uv, _DisplacementGuide);
                o.color = v.color;
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }
 
            fixed4 frag (v2f i) : SV_Target
            {
 
                // sample the texture
                float2 uv = i.uv;
                float2 displUV = i.displUV;
                float2 secondaryUV = i.secondaryUV;
 
                //Polar coords
                #ifdef POLAR
                float2 mappedUV = (i.uv * 2) - 1;
                uv = float2(atan2(mappedUV.y, mappedUV.x) / UNITY_PI / 2.0 + 0.5, length(mappedUV));
                mappedUV = (i.displUV * 2) - 1;
                displUV = float2(atan2(mappedUV.y, mappedUV.x) / UNITY_PI / 2.0 + 0.5, length(mappedUV));
                mappedUV = (i.secondaryUV * 2) - 1;
                secondaryUV = float2(atan2(mappedUV.y, mappedUV.x) / UNITY_PI / 2.0 + 0.5, length(mappedUV));
                #endif
 
                //UV Panning
                uv += _Time.y * _PanningSpeed.xy;
                displUV += _Time.y * _PanningSpeed.zw;
                secondaryUV += _Time.y * _SecondaryPanningSpeed.xy;
 
                //Displacement
                float2 displ = tex2D(_DisplacementGuide, displUV).xy;
                displ = ((displ * 2) - 1) * _DisplacementAmount;
                 
                float col = pow(saturate(lerp(0.5, tex2D(_MainTex, uv + displ).x, _Contrast)), _Power);
                #ifdef SECONDARY_TEX
                col = col * pow(saturate(lerp(0.5, tex2D(_SecondaryTex, secondaryUV + displ).x, _Contrast)), _Power) * 2;
                #endif
 
                //Masking
                #ifdef CIRCLE_MASK
                float circle = distance(i.uv, float2(0.5, 0.5));
                col *= 1 - smoothstep(_OuterRadius, _OuterRadius + _Smoothness, circle);
                col *= smoothstep(_InnerRadius, _InnerRadius + _Smoothness, circle);
                #endif
 
                float orCol = col;
 
                //Banding
                #ifdef BANDING
                col = round(col * _Bands) / _Bands;
                #endif
                 
                //Clipping
                float cutoff = saturate(_Cutoff + (1 - i.color.a));
                half test = orCol - cutoff;
                clip(test);
 
                //Coloring
                fixed4 rampCol = tex2D(_GradientMap, float2(col, 0));
                fixed4 finalCol = fixed4(rampCol.rgb * _Color.rgb * rampCol.a, 1) + _BurnCol * step(test, _BurnSize) * smoothstep(0.001, 0.5, cutoff);
                 
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, finalCol);            
                return finalCol;
            }
            ENDCG
        }
    }
}
