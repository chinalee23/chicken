Shader "PPSG/VertexAlpha-Diffuse" {
Properties {
	_Color ("Main Color", Color) = (1,1,1,1)
	_MainTex ("Base (RGB)", 2D) = "white" {}
}

SubShader {
	Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
	LOD 200

CGPROGRAM
#pragma exclude_renderers xbox360 ps3
#pragma surface surf Lambert alpha exclude_path:deferred exclude_path:prepass noshadow nodynlightmap nodirlightmap noforwardadd nolppv noshadowmask

sampler2D _MainTex;
fixed4 _Color;

struct Input {
	float2 uv_MainTex;
	float4 color : COLOR;
};

void surf (Input IN, inout SurfaceOutput o) {
	fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
	o.Albedo = c.rgb;
	o.Alpha = c.a * IN.color.a;
}
ENDCG
}

//Fallback "Transparent/VertexLit"
}
