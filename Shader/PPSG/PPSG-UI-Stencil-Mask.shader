// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "PPSG/UI-Stencil-Mask"
{
	Properties
	{
		_Stencil("Stencil ID", Float) = 1
		_StencilComp("Stencil Comparison", Float) = 8
		_StencilOp("Stencil Operation", Float) = 0
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque" "Queue" = "Geometry" }

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
				Ref [_Stencil]
				Comp [_StencilComp]
				Pass [_StencilOp]
			}

			CGPROGRAM
			#pragma exclude_renderers xbox360 ps3
			#pragma vertex vert
			#pragma fragment frag
			ENDCG
		}

		CGINCLUDE
		struct appdata
		{
			float4 vertex : POSITION;
		};

		struct v2f 
		{
			float4 pos : SV_POSITION;
		};

		v2f vert(appdata v)
		{
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);
			return o;
		}

		half4 frag(v2f i) : SV_Target
		{
			return half4(1,1,0,1);
		}
		ENDCG
	
	}	// SubShader
		
	//Fallback "Transparent/VertexLit"
}

