Shader "Unlit/DirectionalCelColoring"
{
	Properties
	{
		_LightColor("Light Color", Color) = (1,1,1,1)
		_MiddleColor("Middle Color", Color) = (1,1,1,1)
		_DarkColor("Dark Color", Color) = (1,1,1,1)	
		_Threshold1("Threshold 1", Range(0, 1)) = 0.33
		_Threshold2("Threshold 2", Range(0, 1)) = 0.66
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
				float lightDot : TEXCOORD0;
			};
			

			fixed4 _LightColor;
			fixed4 _MiddleColor;
			fixed4 _DarkColor;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				half3 normal = normalize(mul(unity_ObjectToWorld, half4(v.normal, 0))).xyz;
				half lightDot = clamp(dot(normal, normalize(_WorldSpaceLightPos0)), -1.0, 1.0);
				o.lightDot = (lightDot + 1) / 2; 
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			float _Threshold1;
			float _Threshold2;

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col;
				if (i.lightDot > 0 && i.lightDot < _Threshold1) col = _LightColor;
				else if (i.lightDot > _Threshold1 && i.lightDot < _Threshold2) col = _MiddleColor;
				else col = _DarkColor;
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
}
