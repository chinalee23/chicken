Shader "PPSG/UI-Stencil"
{
	Properties
	{
		_MainTex("Base (RGB), Alpha (A)", 2D) = "white" {}
		_Stencil("Stencil ID", Float) = 1
	}

	SubShader
	{
			LOD 150
			Tags
			{ 
				"Queue" = "Transparent" 
				"IgnoreProjector" = "True" 
				"RenderType" = "Transparent" 
			}

			Pass
		{
			Stencil
		{
			Ref[_Stencil]
			Comp Equal
		}

			Blend SrcAlpha OneMinusSrcAlpha
			ColorMask RGB
			Lighting Off
			ZWrite Off

			SetTexture[_MainTex]
		{
			Combine Texture * Primary
		}
		} // Pass
	}// SubShader
		
	//Fallback "Transparent/VertexLit"
}

