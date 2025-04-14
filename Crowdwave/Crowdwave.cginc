sampler2D _Udon_VideoTex;
uniform float4 _Udon_VideoTex_TexelSize;

sampler2D _Udon_CrowdwaveMask;
uniform float4x4 _Udon_CrowdwaveMeta;

bool IsVideoAvailable() {
    return _Udon_VideoTex_TexelSize.z > 16;
}

float2 rotate(float2 UV, float angle) {
    angle *= 0.0174533;
    float sinX = sin(angle);
    float cosY = cos(angle);
    float2x2 rotation = float2x2(cosY, -sinX, sinX, cosY);
    return mul(UV.xy, rotation);
}

fixed4 SampleCrowdwave(float3 objectPos)
{

    float2 position = mul(unity_ObjectToWorld, float4(objectPos, 1.0)).xz;

    float2 worldPosition = _Udon_CrowdwaveMeta._m20_m21_m22_m23.xz;
    float4 screenBounds = _Udon_CrowdwaveMeta._m00_m01_m02_m03;
    float2 worldBounds = _Udon_CrowdwaveMeta._m10_m11_m12_m13.xy;
    fixed worldRotation = _Udon_CrowdwaveMeta._m20_m21_m22_m23.w;
    half intensity = _Udon_CrowdwaveMeta._m10_m11_m12_m13.z;
    //_Udon_CrowdwaveMeta._m10_m11_m12_m13.w;
    //_Udon_CrowdwaveMeta._m30_m31_m32_m33;

    intensity = intensity > 1.0 ? intensity - 1.0 : 0.0;

    position -= worldPosition;
    position.xy = rotate(position.xy, worldRotation);
    position.xy += worldBounds / 2.0;
    position.xy /= worldBounds;

    half mask = tex2Dlod(_Udon_CrowdwaveMask, float4(position.xy, 0.0, 0.0));
    if (!IsVideoAvailable() || position.x < 0.0 || position.x > 1.0 || position.y < 0.0 || position.y > 1.0) mask = 0.0;

    position.xy *= screenBounds.xy;
    position.xy += screenBounds.zw;

    fixed3 color = tex2Dlod(_Udon_VideoTex, float4(position.xy, 0.0, 0.0)) * intensity * mask;

    return fixed4(color.xyz, mask);

}