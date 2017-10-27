// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

Shader "PPSG/Bumped Diffuse Lightmap" {
	Properties{
		_Color("Main Color", Color) = (1,1,1,1)
		_SpecColor("Specular Color", Color) = (0.5, 0.5, 0.5, 1)
		_Shininess("Shininess", Range(0.03, 1)) = 0.078125
		_MainTex("Base (RGB) Gloss (A)", 2D) = "white" {}
		_BumpMap("Normalmap", 2D) = "bump" {}
		_LightMap("Lightmap (RGB)", 2D) = "black" {}
		_LightMapMultiplier("Lightmap Multiply", Float) = 1
	}

		CGINCLUDE
		sampler2D _MainTex;
	sampler2D _BumpMap;
	fixed4 _Color;
	half _Shininess;
	fixed _LightMapMultiplier;
	sampler2D _LightMap;

	struct Input {
		float2 uv_MainTex;
		float2 uv_BumpMap;
		float2 uv3_DetailMap;
		float2 uv2_LightMap;
		float4 color: COLOR;
	};

	void surf(Input IN, inout SurfaceOutput o) {
		fixed4 tex = tex2D(_MainTex, IN.uv_MainTex) ;
		half4 lm = tex2D(_LightMap, IN.uv2_LightMap) * _LightMapMultiplier;
		o.Albedo = tex.rgb * _Color.rgb* lm.rgb;
		o.Gloss = tex.a;
		o.Alpha = tex.a * _Color.a;
		o.Specular = _Shininess;
		o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
	

	}
	ENDCG

		SubShader{
			Tags { "RenderType" = "Opaque" }
			LOD 600

			CGPROGRAM
			#pragma exclude_renderers xbox360 ps3
			#pragma surface surf BlinnPhong exclude_path:deferred exclude_path:prepass noshadow nodynlightmap nodirlightmap nolppv noshadowmask
			#pragma target 3.0
			ENDCG
	}

		SubShader{
			Tags { "RenderType" = "Opaque" }
			LOD 400

			CGPROGRAM
			#pragma exclude_renderers xbox360 ps3
			#pragma surface surf Lambert exclude_path:deferred exclude_path:prepass noshadow nodynlightmap nodirlightmap nolppv noshadowmask
			ENDCG
	}

		SubShader{
			Tags{ "RenderType" = "Opaque" }
			LOD 200

			CGPROGRAM
			#pragma exclude_renderers xbox360 ps3
			#pragma surface surfDiffuse Lambert exclude_path:deferred exclude_path:prepass noshadow nodynlightmap nodirlightmap nolppv noshadowmask


		void surfDiffuse(Input IN, inout SurfaceOutput o) {
			fixed4 tex = tex2D(_MainTex, IN.uv_MainTex) ;
		half4 lm = tex2D(_LightMap, IN.uv2_LightMap) * _LightMapMultiplier;
		o.Albedo = tex.rgb * _Color.rgb* lm.rgb;
		o.Alpha = tex.a * _Color.a;
		}
		ENDCG
	}
}
