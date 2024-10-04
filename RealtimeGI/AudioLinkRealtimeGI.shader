Shader "RealtimeGI/AudioLink"
{
    Properties
    {
        _MainTex ("Pattern Texture", 2D) = "white" {}
        _ColorTint ("Color", Color) = (1, 1, 1, 1)
        _History ("AudioLink History", Range(0, 127)) = 32
        _EmissionStrength ("Emission Strength", Float) = 1
        _EmissionStrengthGI ("GI Emission Strength", Float) = 1

        [Space(5)]
        [Header(RUNTIME LOCKED)]
        [Toggle(_HIDEMESH)] _HideMesh ("Hide Mesh", Int) = 0
        [Toggle(_FULLBRIGHT)] _FullBright ("Full Bright", Int) = 0
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
            #pragma shader_feature _FULLBRIGHT

            #include "UnityCG.cginc"
            #include "Packages/com.llealloo.audiolink/Runtime/Shaders/AudioLink.cginc"

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

            sampler2D _MainTex;
            uniform fixed4 _ColorTint;
            uniform fixed _History;
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

                fixed al = AudioLinkLerp(i.uv * float2(_History, 4)).r;
                #if defined(_FULLBRIGHT)
                al = 1;
                #endif
                al *= _EmissionStrength;

                return al * tex2D(_MainTex, i.uv) * _ColorTint;
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
            #include "Packages/com.llealloo.audiolink/Runtime/Shaders/AudioLink.cginc"

            uniform fixed4 _ColorTint;
            uniform fixed _History;
            uniform fixed _EmissionStrengthGI;
            
            float4 frag_meta2 (v2f_meta i): SV_Target
            {

                FragmentCommonData data = UNITY_SETUP_BRDF_INPUT (i.uv);
                UnityMetaInput o;
                UNITY_INITIALIZE_OUTPUT(UnityMetaInput, o);

                fixed al = AudioLinkLerp(i.uv * float2(_History, 4)).r;
                #if defined(_FULLBRIGHT)
                al = 1;
                #endif
                al *= _EmissionStrengthGI;

                o.Emission = al * tex2D(_MainTex, i.uv) * _ColorTint;
                o.Albedo = 0;
                return UnityMetaFragment(o);
            }

            #pragma vertex vert_meta
            #pragma fragment frag_meta2
            #pragma shader_feature _FULLBRIGHT
            ENDCG
        }
    }
}
