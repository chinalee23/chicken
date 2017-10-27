// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

Shader "PPSG/Bumped Specular Detail" {
	Properties{
		_Color("Main Color", Color) = (1,1,1,1)
		_SpecColor("Specular Color", Color) = (0.5, 0.5, 0.5, 1)
		_Shininess("Shininess", Range(0.03, 1)) = 0.078125
		_MainTex("Base (RGB) Gloss (A)", 2D) = "white" {}
		_BumpMap("Normalmap", 2D) = "bump" {}
		_DetailMap("DetailMap", 2D) = "white" {}
	}

		CGINCLUDE
		sampler2D _MainTex;
	sampler2D _BumpMap;
	sampler2D _DetailMap;
	fixed4 _Color;
	half _Shininess;

	struct Input {
		float2 uv_MainTex;
		float2 uv_BumpMap;
		float2 uv3_DetailMap;
		float4 color: COLOR;
	};

	void surf(Input IN, inout SurfaceOutput o) {
		fixed4 tex = tex2D(_MainTex, IN.uv_MainTex) ;
		fixed4 detail = tex2D(_DetailMap, IN.uv3_DetailMap);
		o.Albedo = tex.rgb * _Color.rgb;
		o.Gloss = tex.a;
		o.Alpha = tex.a * _Color.a;
		o.Specular = _Shininess;
		o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
		if(IN.color.r >= 0.5)
		{
			o.Normal.rgb *= detail.r;
			o.Albedo.rgb *= detail.g;
			//o.Gloss += detail.b;
		}	

	}
	ENDCG

		SubShader{
			Tags { "RenderType" = "Opaque" }
			LOD 600

			CGPROGRAM
			#pragma exclude_renderers xbox360 ps3
			#pragma surface surf BlinnPhong exclude_path:deferred exclude_path:prepass noshadow nodynlightmap nodirlightmap  nolppv noshadowmask
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
			#pragma surface surfDiffuse Lambert exclude_path:deferred exclude_path:prepass noshadow nodynlightmap nodirlightmap noforwardadd nolppv noshadowmask


		void surfDiffuse(Input IN, inout SurfaceOutput o) {
			//fixed4 detail = tex2D(_DetailMap, IN.uv3_DetailMap);
			fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			o.Alpha = c.a;
		}
		ENDCG
	}
}
