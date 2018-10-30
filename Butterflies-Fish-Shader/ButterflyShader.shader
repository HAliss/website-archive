Shader "Unlit/ButterflyShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_AlphaCutoff("Alpha cutoff", Range(0, 1)) = 0
		_DisplacementAmount("Displacement Amount", float) = 1
		_DisplacementSpeed("Displacement Speed", float ) = 1
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100
		Cull off

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
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _AlphaCutoff;
			float _DisplacementAmount;
			float _DisplacementSpeed;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				float mask = 1 - sin(UNITY_PI * o.uv.x);
				v.vertex.y += sin(_Time.y * _DisplacementSpeed) * _DisplacementAmount * mask;
				o.vertex = UnityObjectToClipPos(v.vertex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				clip(col.a - _AlphaCutoff);
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
}
