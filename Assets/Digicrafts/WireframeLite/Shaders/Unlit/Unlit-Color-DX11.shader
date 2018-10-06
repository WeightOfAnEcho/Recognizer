//UNITY_SHADER_NO_UPGRADE
// Unlit shader. Simplest possible colored shader.
// - no lighting
// - no lightmap support
// - no texture

Shader "Digicrafts/Wireframe/DX11/Unlit/Color" {
Properties {
	
	_Color ("Main Color", Color) = (0.5,0.5,0.5,1)

	// Wireframe Properties
	[HDR]_WireframeColor ("Color", Color) = (1,1,1,1)
	_WireframeTex ("Texture", 2D) = "white" {}
	[Enum(UV0,0,UV1,1)] _WireframeUV ("UV Set for Texture", Float) = 0
	_WireframeSize ("Size", Range(0.0, 10.0)) = 1
	[Toggle(_WIREFRAME_LIGHTING)]_WireframeLighting ("Color affect by Light", Float) = 0
	[Toggle(_WIREFRAME_AA)]_WireframeAA ("Anti Aliasing", Float) = 0
	[Toggle]_WireframeDoubleSided ("2 Sided", Float) = 0
	_WireframeMaskTex ("Mask Texture", 2D) = "white" {}
	_WireframeTexAniSpeedX ("Speed X", Float) = 0
	_WireframeTexAniSpeedY ("Speed Y", Float) = 0
	[Toggle(_WIREFRAME_VERTEX_COLOR)]_WireframeVertexColor ("VertexColor", Float) = 0

	_WireframeAlphaCutoff ("_WireframeAlphaCutoff", Range(0.0, 1.0)) = 0.5
	[HideInInspector] _WireframeAlphaMode ("__WireframeAlphaMode", Float) = 0
	[HideInInspector] _WireframeCull ("__WireframeCull", Float) = 2
}

SubShader {
	Tags { "RenderType"="Opaque" }
	LOD 100
	Cull [_WireframeCull]
	
	Pass {  
		CGPROGRAM
			#pragma vertex vert
			#pragma geometry geom
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_fog
			#pragma shader_feature _WIREFRAME_LIGHTING
			#pragma shader_feature _WIREFRAME_AA
			#pragma shader_feature _WIREFRAME_ALPHA_NORMAL _WIREFRAME_ALPHA_TEX_ALPHA _WIREFRAME_ALPHA_TEX_ALPHA_INVERT _WIREFRAME_ALPHA_MASK _WIREFRAME_ALPHA_MASK_INVERT
			#pragma shader_feature _WIREFRAME_VERTEX_COLOR
			
			#pragma shader_feature _DebugUV
			uniform fixed4 _Color;

			#define _WIREFRAME_DX11 1																					
			#include "UnityCG.cginc"
			#include "../Core/WireframeCore.cginc"

			struct appdata {
				float4 vertex : POSITION;
				#if _WIREFRAME_VERTEX_COLOR
				float4 color : COLOR0;
				#endif
				float2 uv0 : TEXCOORD0;
				float2 uv1 : TEXCOORD1;
			};
		
			struct v2f {
				float4 pos : SV_POSITION;
				DC_WIREFRAME_COORDS(0,1)
				UNITY_FOG_COORDS(2)
			};
			
			v2f vert (appdata v)
			{
				v2f o;
				#if UNITY_VERSION >= 540
					o.pos = UnityObjectToClipPos(v.vertex);
				#else
					o.pos = mul(UNITY_MATRIX_MVP,v.vertex);
				#endif
				UNITY_TRANSFER_FOG(o,o.vertex);
				DC_WIREFRAME_TRANSFER_COORDS(o);
				return o;
			}
			[maxvertexcount(3)]
			void geom(triangle v2f IN[3], inout TriangleStream<v2f> triStream)
			{
			    IN[0].mass = float4(1,0,0,0);
			    triStream.Append(IN[0]);
			    IN[1].mass = float4(0,1,0,0);
			    triStream.Append(IN[1]); 
			    IN[2].mass = float4(0,0,1,0);
			    triStream.Append(IN[2]);               
			}
			fixed4 frag (v2f i) : COLOR
			{
				fixed4 c = _Color;
				UNITY_APPLY_FOG(i.fogCoord, c);
				UNITY_OPAQUE_ALPHA(c.a);
				DC_APPLY_WIREFRAME(c.rgb,c.a,i)

				#if _DebugUV
					return i.mass;
				#else 
					return c;
				#endif
			}
		ENDCG
	}
}
CustomEditor "WireframeGeneralShaderGUI"
}
