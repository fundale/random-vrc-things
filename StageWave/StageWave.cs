
using UdonSharp;
using UnityEngine;
using VRC.SDKBase;
using VRC.Udon;
#if UDONSHARP
using static VRC.SDKBase.VRCShader;
#endif

[UdonBehaviourSyncMode(BehaviourSyncMode.None)]
public class StageWave : UdonSharpBehaviour
{
    public Vector2 videoResolution = new Vector2(1920, 1080);
    public Vector4 screenBouds = new Vector4(1920, 1080, 0, 0);
    public float intensity;
    public Texture2D stageWaveMask;
    private int _StageWaveMetaID;
    private int _StageWaveMaskID;
    private UnityEngine.Matrix4x4 stageWaveMeta;

    public void UpdateStageWaveMeta()
    {
        float pixelX = 1f / videoResolution.x;
        float pixelY = 1f / videoResolution.y;

        Vector3 worldPosition = gameObject.transform.position;

        stageWaveMeta.m00 = screenBouds.x / videoResolution.x;
        stageWaveMeta.m01 = screenBouds.y / videoResolution.y;
        stageWaveMeta.m02 = screenBouds.z * pixelX;
        stageWaveMeta.m03 = screenBouds.w * pixelY;

        stageWaveMeta.m10 = gameObject.transform.lossyScale.x;
        stageWaveMeta.m11 = gameObject.transform.localScale.z;
        stageWaveMeta.m12 = intensity + 1f;
        stageWaveMeta.m13 = 0f;

        stageWaveMeta.m20 = worldPosition.x;
        stageWaveMeta.m21 = worldPosition.y;
        stageWaveMeta.m22 = worldPosition.z;
        stageWaveMeta.m23 = -gameObject.transform.rotation.eulerAngles.y;

        stageWaveMeta.m30 = 0f;
        stageWaveMeta.m31 = 0f;
        stageWaveMeta.m32 = 0f;
        stageWaveMeta.m33 = 0f;

        #if UDONSHARP
            VRCShader.SetGlobalMatrix(_StageWaveMetaID, stageWaveMeta);
            VRCShader.SetGlobalTexture(_StageWaveMaskID, stageWaveMask);
        #endif

    }

    void Start()
    {
        _StageWaveMetaID = PropertyToID("_Udon_StageWaveMeta");
        _StageWaveMaskID = PropertyToID("_Udon_StageWaveMask");

        UpdateStageWaveMeta();
    }

#if UNITY_EDITOR
    void Update()
    {

        UpdateStageWaveMeta();
        
    }
#endif
}
