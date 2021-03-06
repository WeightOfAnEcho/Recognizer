//UNITY_SHADER_NO_UPGRADE
// Unlit alpha-blended shader.
// - no lighting
// - no lightmap support
// - no per-material color

Shader "Digicrafts/Wireframe/Unlit/Transparent" {
Properties {
	_MainTex ("Base (RGB) Trans (A)", 2D) = "white" {}
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
	Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
	LOD 100
	
	ZWrite Off
	Blend SrcAlpha OneMinusSrcAlpha 
	Cull [_WireframeCull]

	Pass {  
		CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_fog
			#pragma shader_feature _WIREFRAME_LIGHTING
			#pragma shader_feature _WIREFRAME_AA
			#pragma shader_feature _WIREFRAME_ALPHA_NORMAL _WIREFRAME_ALPHA_TEX_ALPHA _WIREFRAME_ALPHA_TEX_ALPHA_INVERT _WIREFRAME_ALPHA_MASK _WIREFRAME_ALPHA_MASK_INVERT
			#pragma shader_feature _WIREFRAME_VERTEX_COLOR
			
			#include "UnityCG.cginc"
			#include "../Core/WireframeCore.cginc"

			struct appdata_t {
				float4 vertex : POSITION;
				#if _WIREFRAME_VERTEX_COLOR
				float4 color : COLOR0;
				#endif
				float2 uv0 : TEXCOORD0;
				float2 uv1 : TEXCOORD1;
				float2 uv4 : TEXCOORD3;
			};

			struct v2f {
				float4 pos : SV_POSITION;
				half2 tex : TEXCOORD0;
				DC_WIREFRAME_COORDS(1,2)
				UNITY_FOG_COORDS(3)
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _Color;			
			
			v2f vert (appdata_t v)
			{
				v2f o;
				#if UNITY_VERSION >= 540
					o.pos = UnityObjectToClipPos(v.vertex);
				#else
					o.pos = mul(UNITY_MATRIX_MVP,v.vertex);
				#endif
				o.tex = TRANSFORM_TEX(v.uv0, _MainTex);
				DC_WIREFRAME_TRANSFER_COORDS(o);
				UNITY_TRANSFER_FOG(o,o.pos);
				return o;
			}
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 c = tex2D(_MainTex, i.tex)*_Color;
				UNITY_APPLY_FOG(i.fogCoord, c);
				DC_APPLY_WIREFRAME(c.rgb,c.a,i)
				return c;
			}
		ENDCG
	}
}
CustomEditor "WireframeGeneralShaderGUI"
}
