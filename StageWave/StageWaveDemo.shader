Shader "Unlit/StageWaveDemo"
{
    Properties
    {

        [Toggle(_FRAGCOL)] _FragCol ("Use Fragment", Int) = 0
        //_Udon_VideoTex ("Video Texture", 2D) = "black" {}

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

            #pragma shader_feature _FRAGCOL

            #include "UnityCG.cginc"
            #include "StageWave.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 color : COLOR;
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 pos : TEXCOORD1;
            };

            // sampler2D _Udon_VideoTex;
            // uniform float4 _Udon_VideoTex_TexelSize;

            // sampler2D _Udon_StageWaveMask;
            // uniform float4x4 _Udon_StageWaveMeta;

            // bool VideoIsAvailable() { return _Udon_VideoTex_TexelSize.z > 16; }

            // float2 rotate(float2 UV, float angle) {
            //     angle *= 0.0174533;
            //     float sinX = sin(angle);
            //     float cosY = cos(angle);
            //     float2x2 rotation = float2x2(cosY, -sinX, sinX, cosY);
            //     return mul(UV.xy, rotation);
            // }

            // float4 SampleObjectPos(float3 objectPos)
            // {

            //     float2 position = mul(unity_ObjectToWorld, float4(objectPos, 1)).xz;

            //     float2 worldPosition = _Udon_StageWaveMeta._m20_m21_m22_m23.xz;
            //     float4 screenBounds = _Udon_StageWaveMeta._m00_m01_m02_m03;
            //     float2 worldBounds = _Udon_StageWaveMeta._m10_m11_m12_m13.xy;
            //     float worldRotation = _Udon_StageWaveMeta._m20_m21_m22_m23.w;
            //     float intensity = _Udon_StageWaveMeta._m10_m11_m12_m13.z;
            //     //_Udon_StageWaveMeta._m10_m11_m12_m13.w;
            //     //_Udon_StageWaveMeta._m30_m31_m32_m33;

            //     intensity = intensity > 1 ? intensity - 1 : 0;

            //     position -= worldPosition;
            //     position.xy = rotate(position.xy, worldRotation);
            //     position.xy += worldBounds / 2;
            //     position.xy /= worldBounds;

            //     float mask = tex2Dlod(_Udon_StageWaveMask, float4(position.xy, 0, 0));
            //     if (!VideoIsAvailable() || position.x < 0 || position.x > 1 || position.y < 0 || position.y > 1) mask = 0;

            //     position.xy *= screenBounds.xy;
            //     position.xy += screenBounds.zw;

            //     float3 color = tex2Dlod(_Udon_VideoTex, float4(position.xy, 0, 0)) * intensity * mask;

            //     return float4(color.xyz, mask);

            // }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                
                o.uv = v.uv;
                o.pos = v.vertex;
                o.color = SampleObjectPos(0);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {

#if defined(_FRAGCOL)

                return SampleObjectPos(i.pos);
            
#else
                return i.color;
#endif
            }
            ENDCG
        }
    }
}
