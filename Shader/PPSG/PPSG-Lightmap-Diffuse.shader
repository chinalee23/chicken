Shader "PPSG/Lightmapped/Transparent Diffuse" {
Properties {
	_Color ("Main Color", Color) = (1,1,1,1)
	_MainTex ("Base (RGB) Trans (A)", 2D) = "white" {}
	_LightMap ("Lightmap (RGB)", 2D) = "black" {}
	_LightMapMultiplier("Lightmap Multiply", Float) = 1
}

SubShader {
	LOD 200
	Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
CGPROGRAM
#pragma exclude_renderers xbox360 ps3
#pragma surface surf Lambert exclude_path:deferred exclude_path:prepass noshadow nodynlightmap nolightmap nodirlightmap noforwardadd nolppv noshadowmask alpha
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
	half4 mainColor = tex2D (_MainTex, IN.uv_MainTex);
  o.Albedo = tex2D (_MainTex, IN.uv_MainTex).rgb * _Color;
  half4 lm = tex2D (_LightMap, IN.uv2_LightMap) * _LightMapMultiplier*2-0.35;
  o.Emission = lm.rgb*o.Albedo.rgb;
  o.Alpha = mainColor.a * _Color.a;
}
ENDCG
}
//FallBack "Legacy Shaders/Lightmapped/VertexLit"
}
