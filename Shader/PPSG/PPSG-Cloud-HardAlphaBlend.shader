Shader "PPSG/Cloud-HardAlphaBlend"
{
	Properties 
	{
		_CloudTexture("Quantum MetaCloud Texture", 2D) = "black" {}
		_AmbientColor("Ambient Color of Clouds", Color) = (0.2078431,0.2588235,0.2980392,1)
		_SunColor("Sun Color of Clouds", Color) = (0.977612,0.9254484,0.882769,1)
		_CloudContrast("Cloud Contrast", Range(0.1,3) ) = 1
		_Bias("Cloud Density", Range(0.25,0.95) ) = 0.45
		_AlphaCutoff("Cloud Opacity", Range(1,0) ) = 1
	}
	
	SubShader 
	{
			Tags
			{
				"Queue"="Overlay"
				"IgnoreProjector"="True"
				"RenderType"="Transparent"
			}

		
			Cull Off
			ZWrite On
			ZTest LEqual
			ColorMask RGBA
			Fog{
				Mode Off
			}


			CGPROGRAM
			#pragma exclude_renderers xbox360 ps3
			#pragma surface surf SimpleLambert  noambient nolightmap noforwardadd alpha decal:blend vertex:vert exclude_path:deferred exclude_path:prepass noshadow nodynlightmap nodirlightmap nolppv noshadowmask
			#pragma target 2.0


			sampler2D _CloudTexture;
			float4 _AmbientColor;
			float4 _SunColor;
			float _CloudContrast;
			float _Bias;
			float _AlphaCutoff;


			struct Input {
				float2 uv_CloudTexture;

			};

			void vert (inout appdata_full v, out Input o) {
						o.uv_CloudTexture = TRANSFORM_UV(0);
			}
			
			half4 LightingSimpleLambert(SurfaceOutput s, half3 lightDir, half atten) {
				half4 c;
				c.rgb = s.Albedo;
				c.a = s.Alpha;
				return c;
			}

			void surf (Input IN, inout SurfaceOutput o) {
			
				float4 Tex2D0=tex2D(_CloudTexture,IN.uv_CloudTexture);
				float4 Subtract0=float4(Tex2D0.x, Tex2D0.x, Tex2D0.x, Tex2D0.x) - float4( 0.5,0.5,0.5,0.5 );
				float4 Multiply1 = Subtract0 * _CloudContrast.xxxx;
				float4 Add1= Multiply1 + float4( 0.5,0.5,0.5,0.5 );
				float4 Saturate0=saturate(Add1);
				float4 Pow0=pow(Saturate0, log(0.5) / log(_Bias));
				float4 Saturate1=saturate(Pow0);
				float4 Lerp0=lerp(_AmbientColor,_SunColor,Saturate1);

				o.Emission = Lerp0;
				o.Alpha = Tex2D0.y - _AlphaCutoff;
			}
		ENDCG
	}
	//Fallback "Diffuse"
}