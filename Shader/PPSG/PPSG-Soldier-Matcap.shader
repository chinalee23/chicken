// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "PPSG/Soldier Matcap"
{
	Properties
	{
		[HideInInspector] __dirty( "", Int ) = 1
		_Diffuse("Diffuse", 2D) = "white" {}
		_DiffuseIns("DiffuseIns", Range( 0 , 2)) = 1.126967
		_CubeMap("CubeMap", CUBE) = "white" {}
		_CubemapColor("CubemapColor", Color) = (1,0.8482759,0,0)
		_CubeMapIns("CubeMapIns", Range( 0 , 2)) = 1.158525
		_CubemapBlend("CubemapBlend", Range( 0 , 1)) = 0
		_FadeColor("FadeColor", Color) = (0,0,0,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		ZTest LEqual
		ColorMask RGB
		CGPROGRAM
		#pragma target 2.0
		#pragma only_renderers d3d9 d3d11 glcore gles gles3 metal 
		#pragma surface surf Lambert keepalpha  noshadow exclude_path:deferred nolightmap  nodynlightmap nodirlightmap noforwardadd 
		struct Input
		{
			float2 uv_texcoord;
			float3 worldRefl;
			INTERNAL_DATA
		};

		uniform fixed4 _FadeColor;
		uniform sampler2D _Diffuse;
		uniform float4 _Diffuse_ST;
		uniform fixed _DiffuseIns;
		uniform samplerCUBE _CubeMap;
		uniform fixed4 _CubemapColor;
		uniform fixed _CubeMapIns;
		uniform fixed _CubemapBlend;

		void surf( Input i , inout SurfaceOutput o )
		{
			float2 uv_Diffuse = i.uv_texcoord * _Diffuse_ST.xy + _Diffuse_ST.zw;
			fixed4 tex2DNode56 = tex2D( _Diffuse,uv_Diffuse);
			float3 worldrefVec46 = i.worldRefl;
			o.Albedo = ( _FadeColor * lerp( ( tex2DNode56 * _DiffuseIns ) , ( ( ( ( texCUBE( _CubeMap,worldrefVec46) * _CubemapColor ) * tex2DNode56.a ) * 5 ) * _CubeMapIns ) , ( tex2DNode56.a * _CubemapBlend ) ) ).rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=7003
1951;58;1906;910;2441.074;1138.604;1.9;True;True
Node;AmplifyShaderEditor.WorldReflectionVector;46;-2342.411,-662.2816;Float;True;0;FLOAT3;0,0,0;False;FLOAT3;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SamplerNode;45;-2009.221,-728.0748;Float;True;Property;_CubeMap;CubeMap;4;0;Assets/NewArts/Character/Avatar/Common/char_reflection_env.exr;True;0;False;white;LockedToCube;False;Object;-1;Auto;Cube;0;SAMPLER2D;;False;1;FLOAT3;0,0,0;False;2;FLOAT;1.0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1.0;False;FLOAT4;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.ColorNode;66;-1972.173,-460.0091;Float;False;Property;_CubemapColor;CubemapColor;5;0;1,0.8482759,0,0;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SamplerNode;56;-1539.182,-130.1702;Float;True;Property;_Diffuse;Diffuse;0;0;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;FLOAT4;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;64;-1553.141,-582.0667;Float;False;0;FLOAT4;0.0;False;1;COLOR;0.0,0,0,0;False;COLOR
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;71;-1363.725,-592.1379;Float;False;0;COLOR;0.0,0,0,0;False;1;FLOAT;0.0,0,0,0;False;COLOR
Node;AmplifyShaderEditor.RangedFloatNode;63;-1199.265,-461.0962;Float;False;Property;_CubeMapIns;CubeMapIns;6;0;1.158525;0;2;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;68;-834.5878,-819.0119;Float;False;Property;_DiffuseIns;DiffuseIns;1;0;1.126967;0;2;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;70;-877.5094,-133.1587;Float;False;Property;_CubemapBlend;CubemapBlend;7;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.ScaleNode;53;-1235.137,-997.7488;Float;True;5;0;COLOR;0.0;False;COLOR
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;69;-592.134,-401.2226;Float;False;0;FLOAT;0.0;False;1;FLOAT;0.0,0,0,0;False;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;60;-849.2966,-554.0994;Float;False;0;COLOR;0.0;False;1;FLOAT;0.0,0,0,0;False;COLOR
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;67;-458.9142,-1006.459;Float;True;0;FLOAT4;0.0;False;1;FLOAT;0.0,0,0,0;False;FLOAT4
Node;AmplifyShaderEditor.ColorNode;152;-260.2697,-358.4064;Float;False;Property;_FadeColor;FadeColor;9;0;0,0,0,0;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.LerpOp;58;-203.1702,-681.6355;Float;True;0;FLOAT4;0.0;False;1;COLOR;0.0,0,0,0;False;2;FLOAT;0,0,0,0;False;COLOR
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;153;-48.86958,-202.3067;Float;False;0;COLOR;0.0;False;1;COLOR;0,0,0,0;False;COLOR
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;247.1001,-596.7;Fixed;False;True;0;Fixed;ASEMaterialInspector;0;Lambert;PPSG/Soldier Matcap;False;False;False;False;False;False;True;True;True;False;False;True;Back;0;3;False;0;0;Opaque;0.5;True;False;0;False;Opaque;Geometry;ForwardOnly;True;True;True;True;True;True;False;False;False;False;False;False;False;True;True;True;False;False;0;255;255;0;0;0;0;False;0;4;10;25;False;0.5;False;0;Zero;Zero;0;Zero;Zero;Add;Add;0;False;0;0,0,0,0;VertexOffset;False;Cylindrical;Relative;0;;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0.0;False;4;FLOAT;0.0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0.0;False;9;FLOAT;0.0;False;10;OBJECT;0.0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;13;OBJECT;0.0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False
WireConnection;45;1;46;0
WireConnection;64;0;45;0
WireConnection;64;1;66;0
WireConnection;71;0;64;0
WireConnection;71;1;56;4
WireConnection;53;0;71;0
WireConnection;69;0;56;4
WireConnection;69;1;70;0
WireConnection;60;0;53;0
WireConnection;60;1;63;0
WireConnection;67;0;56;0
WireConnection;67;1;68;0
WireConnection;58;0;67;0
WireConnection;58;1;60;0
WireConnection;58;2;69;0
WireConnection;153;0;152;0
WireConnection;153;1;58;0
WireConnection;0;0;153;0
ASEEND*/
//CHKSM=872CBC7CF78EE72191CB7276D499B0292F4E91E6