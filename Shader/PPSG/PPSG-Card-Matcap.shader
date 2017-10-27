// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "PPSG/Card Matcap"
{
	Properties
	{
		[HideInInspector] __dirty( "", Int ) = 1
		_TextureSample1("Texture Sample 1", 2D) = "white" {}
		_TextureS("Texture S", 2D) = "white" {}
		_Diffuse("Diffuse", 2D) = "white" {}
		_DiffuseIns("DiffuseIns", Range( 0 , 2)) = 1.126967
		_CubeMap("CubeMap", CUBE) = "white" {}
		_CubemapColor("CubemapColor", Color) = (1,0.8482759,0,0)
		_CubeMapIns("CubeMapIns", Range( 0 , 2)) = 1.158525
		_CubemapBlend("CubemapBlend", Range( 0 , 1)) = 0
		_alpha("alpha", Range( 0 , 1)) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 2.0
		#pragma only_renderers d3d9 d3d11 glcore gles gles3 metal 
		#pragma surface surf Lambert alpha:fade keepalpha  noshadow exclude_path:deferred noambient nolightmap  nodynlightmap nodirlightmap vertex:vertexDataFunc 
		struct Input
		{
			float2 texcoord_0;
			float3 worldRefl;
			INTERNAL_DATA
			float2 uv_texcoord;
		};

		uniform sampler2D _Diffuse;
		uniform fixed _DiffuseIns;
		uniform samplerCUBE _CubeMap;
		uniform fixed4 _CubemapColor;
		uniform sampler2D _TextureS;
		uniform float4 _TextureS_ST;
		uniform fixed _CubeMapIns;
		uniform fixed _CubemapBlend;
		uniform sampler2D _TextureSample1;
		uniform fixed _alpha;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			o.texcoord_0.xy = v.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			fixed4 tex2DNode56 = tex2D( _Diffuse,i.texcoord_0);
			float3 worldrefVec46 = i.worldRefl;
			float2 uv_TextureS = i.uv_texcoord * _TextureS_ST.xy + _TextureS_ST.zw;
			o.Albedo = lerp( ( tex2DNode56 * _DiffuseIns ) , ( ( ( ( texCUBE( _CubeMap,worldrefVec46) * _CubemapColor ) * tex2D( _TextureS,uv_TextureS) ) * 5 ) * _CubeMapIns ) , ( tex2DNode56.a * _CubemapBlend ) ).xyz;
			o.Emission = ( tex2DNode56.a * tex2D( _TextureSample1,(abs( i.texcoord_0+_Time.x * float2(0,8 )))) ).xyz;
			o.Alpha = ( _alpha * tex2DNode56.a );
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=7003
1960;43;1906;910;1650.895;293.563;1.3;True;True
Node;AmplifyShaderEditor.WorldReflectionVector;46;-2342.411,-662.2816;Float;True;0;FLOAT3;0,0,0;False;FLOAT3;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.ColorNode;66;-1991.373,-476.0091;Float;False;Property;_CubemapColor;CubemapColor;5;0;1,0.8482759,0,0;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SamplerNode;45;-2009.221,-728.0748;Float;True;Property;_CubeMap;CubeMap;4;0;Assets/NewArts/Character/Avatar/Common/char_reflection_env.exr;True;0;False;white;LockedToCube;False;Object;-1;Auto;Cube;0;SAMPLER2D;;False;1;FLOAT3;0,0,0;False;2;FLOAT;1.0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1.0;False;FLOAT4;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;64;-1553.141,-582.0667;Float;False;0;FLOAT4;0.0;False;1;COLOR;0.0,0,0,0;False;COLOR
Node;AmplifyShaderEditor.SamplerNode;153;-1789.833,-269.2548;Float;True;Property;_TextureS;Texture S;0;0;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;FLOAT4;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.TextureCoordinatesNode;174;-1945.213,214.174;Float;False;0;-1;2;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;FLOAT2;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.TimeNode;173;-1929.414,439.3741;Float;False;FLOAT4;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;71;-1285.725,-597.3378;Float;False;0;COLOR;0.0,0,0,0;False;1;FLOAT4;0,0,0,0;False;FLOAT4
Node;AmplifyShaderEditor.SamplerNode;56;-1452.184,62.02974;Float;True;Property;_Diffuse;Diffuse;0;0;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;FLOAT4;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;68;-834.5878,-819.0119;Float;False;Property;_DiffuseIns;DiffuseIns;1;0;1.126967;0;2;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;63;-898.9653,-394.7961;Float;False;Property;_CubeMapIns;CubeMapIns;6;0;1.158525;0;2;FLOAT
Node;AmplifyShaderEditor.ScaleNode;53;-1235.137,-997.7488;Float;True;5;0;FLOAT4;0.0;False;FLOAT4
Node;AmplifyShaderEditor.RangedFloatNode;70;-756.6094,-118.8587;Float;False;Property;_CubemapBlend;CubemapBlend;7;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.PannerNode;172;-1612.414,413.374;Float;False;0;8;0;FLOAT2;0,0;False;1;FLOAT;0.0;False;FLOAT2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;69;-336.0342,-297.2225;Float;False;0;FLOAT;0.0;False;1;FLOAT;0.0,0,0,0;False;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;60;-617.8975,-635.9988;Float;False;0;FLOAT4;0.0;False;1;FLOAT;0.0,0,0,0;False;FLOAT4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;67;-458.9142,-1006.459;Float;True;0;FLOAT4;0.0;False;1;FLOAT;0.0,0,0,0;False;FLOAT4
Node;AmplifyShaderEditor.SamplerNode;157;-1417.951,416.5084;Float;True;Property;_TextureSample1;Texture Sample 1;-1;0;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;0;SAMPLER2D;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;FLOAT4;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;175;-335.7979,129.3372;Float;False;Property;_alpha;alpha;8;0;1;0;1;FLOAT
Node;AmplifyShaderEditor.LerpOp;58;-9.470304,-507.4361;Float;True;0;FLOAT4;0.0;False;1;FLOAT4;0.0,0,0,0;False;2;FLOAT;0,0,0,0;False;FLOAT4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;163;-524.0496,538.0085;Float;False;0;FLOAT;0.0,0,0,0;False;1;FLOAT4;0.0;False;FLOAT4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;176;74.00452,249.937;Float;False;0;FLOAT;0.0;False;1;FLOAT;0.0;False;FLOAT
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;338.9984,331.8708;Fixed;False;True;0;Fixed;ASEMaterialInspector;0;Lambert;PPSG/Card Matcap;False;False;False;False;True;False;True;True;True;False;False;False;Back;0;3;False;0;0;Transparent;0.5;True;False;0;False;Transparent;Transparent;ForwardOnly;True;True;True;True;True;True;False;False;False;False;False;False;False;True;True;True;False;False;0;255;255;0;0;0;0;False;0;4;10;25;False;0.5;False;0;Zero;Zero;0;Zero;Zero;Add;Add;0;False;0;0,0,0,0;VertexOffset;False;Cylindrical;Relative;0;;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0.0;False;4;FLOAT;0.0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0.0;False;9;FLOAT;0.0;False;10;OBJECT;0.0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;13;OBJECT;0.0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False
WireConnection;45;1;46;0
WireConnection;64;0;45;0
WireConnection;64;1;66;0
WireConnection;71;0;64;0
WireConnection;71;1;153;0
WireConnection;56;1;174;0
WireConnection;53;0;71;0
WireConnection;172;0;174;0
WireConnection;172;1;173;1
WireConnection;69;0;56;4
WireConnection;69;1;70;0
WireConnection;60;0;53;0
WireConnection;60;1;63;0
WireConnection;67;0;56;0
WireConnection;67;1;68;0
WireConnection;157;1;172;0
WireConnection;58;0;67;0
WireConnection;58;1;60;0
WireConnection;58;2;69;0
WireConnection;163;0;56;4
WireConnection;163;1;157;0
WireConnection;176;0;175;0
WireConnection;176;1;56;4
WireConnection;0;0;58;0
WireConnection;0;2;163;0
WireConnection;0;9;176;0
ASEEND*/
//CHKSM=C008C93E73725F51B00BDB0AA6B9CDC5EF7D6700