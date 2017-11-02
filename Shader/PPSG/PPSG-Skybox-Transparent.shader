Shader "PPSG/Skybox-Transparent-NoFog" {

Properties {
	_MainTex ("Base (RGB)", 2D) = "white" {}
}

SubShader {
	Tags {"Queue"="Transparent-20" "IgnoreProjector"="True" "RenderType"="Transparent"}
	LOD 100
	
	ZWrite Off
	Blend SrcAlpha OneMinusSrcAlpha 
	
	// Non-lightmapped
	Pass {
		Tags { "LightMode" = "Vertex" }
		Lighting Off
		Fog {Mode Off}
		SetTexture [_MainTex] { combine texture } 
	}
	
	

}
}
