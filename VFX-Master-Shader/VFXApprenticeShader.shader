Shader "VFX/VFXApprenticeShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _GradientMap("Gradient map", 2D) = "white" {} 
 
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
    }
    SubShader
    {
        Tags { "RenderType"="Opaque"}
        Offset -1, -1
        LOD 100
 
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma shader_feature VERTEX_OFFSET
            // make fog work
            #pragma multi_compile_fog
 
            #include "UnityCG.cginc"
 
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };
 
            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float2 displUV : TEXCOORD2;
                float4 vertex : SV_POSITION;
            };
 
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _GradientMap;
            float _Contrast;
            float _Power;
 
            fixed4 _Color;
 
            float4 _PanningSpeed;
             
            float _Cutoff;
            fixed4 _BurnCol;
            float _BurnSize;
 
            float _VertexOffsetAmount;
 
            sampler2D _DisplacementGuide;
            float4 _DisplacementGuide_ST;
            float _DisplacementAmount;
 
            v2f vert (appdata v)
            {
                v2f o;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
 
                #ifdef VERTEX_OFFSET
                float vertOffset = tex2Dlod(_MainTex, float4(o.uv + _Time.y * _PanningSpeed.xy, 1, 1)).x;
                vertOffset = ((vertOffset * 2) - 1) * _VertexOffsetAmount;
                v.vertex.xyz += vertOffset * v.normal;
                #endif
 
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.displUV = TRANSFORM_TEX(v.uv, _DisplacementGuide);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }
 
            fixed4 frag (v2f i) : SV_Target
            {
 
                float2 uv = i.uv;
                float2 displUV = i.displUV;
 
                //UV Panning
                uv += _Time.y * _PanningSpeed.xy;
                displUV += _Time.y * _PanningSpeed.zw;
 
                //Displacement
                float2 displ = tex2D(_DisplacementGuide, displUV).xy;
                displ = ((displ * 2) - 1) * _DisplacementAmount;
 
                //Contrast and power
                float col = pow(saturate(lerp(0.5, tex2D(_MainTex, uv + displ).x, _Contrast)), _Power);
 
                //Clipping
                half test = col - _Cutoff;
                clip(test);
 
                fixed4 rampCol = tex2D(_GradientMap, float2(col, 0));
                fixed4 finalCol = fixed4(rampCol.rgb * _Color.rgb * rampCol.a, 1) + _BurnCol * step(test, _BurnSize) * smoothstep(0.001, 0.1, _Cutoff);
                 
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, finalCol);
                return finalCol;
            }
            ENDCG
        }
    }
}
