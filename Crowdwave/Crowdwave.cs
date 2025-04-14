using UnityEngine;

#if UDONSHARP
using UdonSharp;
using VRC.SDKBase;
using VRC.Udon;
using static VRC.SDKBase.VRCShader;
#endif

#if UDONSHARP
[UdonBehaviourSyncMode(BehaviourSyncMode.None)]
public class Crowdwave : UdonSharpBehaviour
#else
public class Crowdwave : MonoBehaviour
#endif
{
    public Vector2 videoResolution = new Vector2(1920.0f, 1080.0f);
    public Vector4 screenBouds = new Vector4(1920.0f, 1080.0f, 0.0f, 0.0f);
    public float intensity;
    public Texture2D crowdwaveMask;
    private int _crowdwaveMetaID;
    private int _crowdwaveMaskID;
    private UnityEngine.Matrix4x4 crowdwaveMeta;

    public void UpdateCrowdwaveMeta()
    {
        float pixelX = 1.0f / videoResolution.x;
        float pixelY = 1.0f / videoResolution.y;

        Vector3 worldPosition = gameObject.transform.position;

        crowdwaveMeta.m00 = screenBouds.x / videoResolution.x;
        crowdwaveMeta.m01 = screenBouds.y / videoResolution.y;
        crowdwaveMeta.m02 = screenBouds.z * pixelX;
        crowdwaveMeta.m03 = screenBouds.w * pixelY;

        crowdwaveMeta.m10 = gameObject.transform.localScale.x;
        crowdwaveMeta.m11 = gameObject.transform.localScale.z;
        crowdwaveMeta.m12 = intensity + 1.0f;
        crowdwaveMeta.m13 = 0.0f;

        crowdwaveMeta.m20 = worldPosition.x;
        crowdwaveMeta.m21 = worldPosition.y;
        crowdwaveMeta.m22 = worldPosition.z;
        crowdwaveMeta.m23 = -gameObject.transform.rotation.eulerAngles.y;

        crowdwaveMeta.m30 = 0.0f;
        crowdwaveMeta.m31 = 0.0f;
        crowdwaveMeta.m32 = 0.0f;
        crowdwaveMeta.m33 = 0.0f;

        if (crowdwaveMask == null) crowdwaveMask = Texture2D.whiteTexture;

        #if UDONSHARP
            VRCShader.SetGlobalMatrix(_crowdwaveMetaID, crowdwaveMeta);
            VRCShader.SetGlobalTexture(_crowdwaveMaskID, crowdwaveMask);
        #else
            Shader.SetGlobalMatrix(_crowdwaveMetaID, crowdwaveMeta);
            Shader.SetGlobalTexture(_crowdwaveMaskID, crowdwaveMask);
        #endif

    }

    void Start()
    {
        #if UDONSHARP
            _crowdwaveMetaID = PropertyToID("_Udon_CrowdwaveMeta");
            _crowdwaveMaskID = PropertyToID("_Udon_CrowdwaveMask");
        #else
            _crowdwaveMetaID = Shader.PropertyToID("_Udon_CrowdwaveMeta");
            _crowdwaveMaskID = Shader.PropertyToID("_Udon_CrowdwaveMask");
        #endif

        UpdateCrowdwaveMeta();
    }

#if UNITY_EDITOR
    void Update()
    {

        UpdateCrowdwaveMeta();
        
    }
#endif
}
