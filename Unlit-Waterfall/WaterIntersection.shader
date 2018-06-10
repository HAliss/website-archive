Shader "Custom/WaterIntersection"
{
    Properties
    {
       _Color("Main Color", Color) = (1, 1, 1, .5)
       _IntersectionColor("Intersection Color", Color) = (1, 1, 1, .5)
       _IntersectionThresholdMax("Intersection Threshold Max", float) = 1
       _DisplGuide("Displacement guide", 2D) = "white" {}
       _DisplAmount("Displacement amount", float) = 0
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" "RenderType"="Transparent"  }
 
        Pass
        {
           Blend SrcAlpha OneMinusSrcAlpha
           ZWrite Off
 
           CGPROGRAM
           #pragma vertex vert
           #pragma fragment frag
           #pragma multi_compile_fog
           #include "UnityCG.cginc"
 
           struct appdata
           {
               float4 vertex : POSITION;
               float2 uv : TEXCOORD0;
           };
 
           struct v2f
           {
               float2 uv : TEXCOORD0;
               UNITY_FOG_COORDS(1)
               float4 vertex : SV_POSITION;
               float2 displUV : TEXCOORD2;
               float4 scrPos : TEXCOORD3;
           };
 
           sampler2D _CameraDepthTexture;
           float4 _Color;
           float4 _IntersectionColor;
           float _IntersectionThresholdMax;
           sampler2D _DisplGuide;
           float4 _DisplGuide_ST;
 
           v2f vert(appdata v)
           {
               v2f o;
               o.vertex = UnityObjectToClipPos(v.vertex);
               o.scrPos = ComputeScreenPos(o.vertex);
               o.displUV = TRANSFORM_TEX(v.uv, _DisplGuide);
               o.uv = v.uv;
               UNITY_TRANSFER_FOG(o,o.vertex);
               return o;   
           }
 
           half _DisplAmount;
 
            half4 frag(v2f i) : SV_TARGET
            {
               float depth = LinearEyeDepth (tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(i.scrPos)));
 
               float2 displ = tex2D(_DisplGuide, i.displUV - _Time.y / 5).xy;
               displ = ((displ * 2) - 1) * _DisplAmount;
 
               float diff = (saturate(_IntersectionThresholdMax * (depth - i.scrPos.w) + displ));
 
               fixed4 col = lerp(_IntersectionColor, _Color, step(0.5, diff));
 
               UNITY_APPLY_FOG(i.fogCoord, col);
               return col;
            }
 
            ENDCG
        }
    }
    FallBack "VertexLit"
}
