// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "PPSG/UI-Stencil-Texture-Mask"
{
	Properties
	{
		_Stencil("Stencil ID", Float) = 1
		_StencilComp("Stencil Comparison", Float) = 8
		_StencilOp("Stencil Operation", Float) = 2
		_MainTex("Main Texture(RGBA)", 2D) = "white" {}
		_Cutoff("Alpha cutoff", Range(0,1)) = 0.5
	}

		SubShader
		{
			Tags{ "Queue" = "AlphaTest" "IgnoreProjector" = "True" "RenderType" = "TransparentCutout" }

			/*  stencilComp:
			  * Disabled 0
			  * Never 1
			  * Less 2
			  * Equal 3
			  * LessEqual 4
			  * Greater 5
			  * NotEqual 6
			  * GreaterEqual 7
			  * Always 8
			*/

			/* Stencil Operation:
			 * Keep 0
			 * Zero 1
			 * Replace 2
			 * IncrementSaturate 3
			 * DecrementSaturate 4
			 * Invert 5
			 * IncrementWrap 6
			 * DecrementWrap 7
			*/
			Pass
			{
				ColorMask 0
				ZWrite Off

				Stencil
				{
					Ref[_Stencil]
					Comp[_StencilComp]
					Pass[_StencilOp]
				}

				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag

			#include "UnityCG.cginc"
			sampler2D _MainTex;
			float _Cutoff;

			struct appdata
			{
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 texcoord : TEXCOORD0;
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.texcoord = TRANSFORM_UV(0);
				return o;
			}

			half4 frag(v2f i) : SV_Target
			{
				half4 prev = tex2D(_MainTex, i.texcoord);
				if (prev.a < _Cutoff)
					discard;

				return prev;
			}
			ENDCG
			}
		}	// SubShader

		Fallback "Transparent/VertexLit"
}

