Shader "PPSG/Skybox-Opaque-NoFog" {

Properties {
	_MainTex ("Base (RGB)", 2D) = "white" {}
}

SubShader {
	Tags {"Queue"="Geometry+10" "IgnoreProjector"="True" "RenderType"="Opaque"}
	LOD 100
	
	ZWrite Off
	
	// Non-lightmapped
	Pass {
		Tags { "LightMode" = "Vertex" }
		Lighting Off
		Fog {Mode Off}
		SetTexture [_MainTex] { combine texture } 
	}
	
	

}
}
