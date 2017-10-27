Shader "PPSG/Lightmapped/Diffuse Multiply" {
Properties {
	_Color ("Main Color", Color) = (1,1,1,1)
	_MainTex ("Base (RGB)", 2D) = "white" {}
	_LightMap ("Lightmap (RGB)", 2D) = "black" {}
	_LightMapMultiplier("Lightmap Multiply", Float) = 1
}

SubShader {
	LOD 200
	Tags { "RenderType" = "Opaque" }
CGPROGRAM
#pragma exclude_renderers xbox360 ps3
#pragma surface surf Lambert exclude_path:deferred exclude_path:prepass noshadow nodynlightmap nolightmap nodirlightmap noforwardadd nolppv noshadowmask 
struct Input {
  float2 uv_MainTex;
  float2 uv2_LightMap;
};
sampler2D _MainTex;
sampler2D _LightMap;
fixed4 _Color;
fixed _LightMapMultiplier;
void surf (Input IN, inout SurfaceOutput o)
{
  o.Albedo = tex2D (_MainTex, IN.uv_MainTex).rgb * _Color;
  half4 lm = tex2D (_LightMap, IN.uv2_LightMap) * _LightMapMultiplier*2-0.35;
  o.Emission = lm.rgb*o.Albedo.rgb;
  o.Alpha = lm.a * _Color.a;
}
ENDCG
}
//FallBack "Legacy Shaders/Lightmapped/VertexLit"
}
