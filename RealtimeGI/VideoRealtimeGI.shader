Shader "RealtimeGI/Video"
{
    Properties
    {
        //_Udon_VideoTex ("Video Texture", 2D) = "black" {}
        _ColorTint ("Color", Color) = (1, 1, 1, 1)
        _EmissionStrength ("Emission Strength", Float) = 1
        _EmissionStrengthGI ("GI Emission Strength", Float) = 1

        [Space(5)]
        [Header(RUNTIME LOCKED)]
        [Toggle(_HIDEMESH)] _HideMesh ("Hide Mesh", Int) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #pragma shader_feature _HIDEMESH

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _Udon_VideoTex;
            uniform fixed4 _ColorTint;
            uniform fixed _EmissionStrength;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                #if defined(_HIDEMESH)
                discard;
                #endif

                return tex2D(_Udon_VideoTex, i.uv) * _ColorTint * _EmissionStrength;
            }
            ENDCG
        }

        Pass
        {
            Tags {"LightMode"="ShadowCaster"}

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_shadowcaster
            #include "UnityCG.cginc"

            struct v2f { 
                V2F_SHADOW_CASTER;
            };

            v2f vert(appdata_base v)
            {
                v2f o;
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
        }

        Pass
        {
            Name "META"
            Tags {"LightMode"="Meta"}
            Cull Off
            CGPROGRAM

            #include "UnityStandardMeta.cginc"

            sampler2D _Udon_VideoTex;
            uniform fixed4 _ColorTint;
            uniform fixed _EmissionStrengthGI;
            
            float4 frag_meta2 (v2f_meta i): SV_Target
            {

                FragmentCommonData data = UNITY_SETUP_BRDF_INPUT (i.uv);
                UnityMetaInput o;
                UNITY_INITIALIZE_OUTPUT(UnityMetaInput, o);

                o.Emission = tex2D(_Udon_VideoTex, i.uv) * _ColorTint * _EmissionStrengthGI;
                o.Albedo = 0;
                return UnityMetaFragment(o);
            }

            #pragma vertex vert_meta
            #pragma fragment frag_meta2
            ENDCG
        }
    }
}
