Shader "_LME/Diffuse Character" {
	Properties {
		_MainTex( "Base (RGB)", 2D ) = "white" {}
		_AlbedoFactor( "Albedo Factor", Float) = 0.5
		_EmissionFactor( "Emission Factor", Float) = 0.5
		_HighlightColor( "XXXX", Color ) = ( 1, 1, 1 )
		_Ratio( "Ratio", Float ) = 1.0
	}
	SubShader {
		Tags { "RenderType" = "Opaque" }
		LOD 150
		
		CGPROGRAM
		
		#pragma surface surf Lambert

		sampler2D _MainTex;
		fixed _AlbedoFactor;
		fixed _EmissionFactor;
		fixed3 _HighlightColor;
		fixed _Ratio;

		struct Input {
			float2 uv_MainTex;
		};

		void surf( Input IN, inout SurfaceOutput o ) {
			fixed4 c = tex2D( _MainTex, IN.uv_MainTex );
			o.Albedo = c.rgb * _AlbedoFactor * _HighlightColor * _Ratio;
			o.Emission = c.rgb * ( _EmissionFactor + 0.1 ) * _HighlightColor * _Ratio;
			o.Alpha = 1;
		}

		ENDCG
	} 
	FallBack "Mobile/VertexLit"
}
