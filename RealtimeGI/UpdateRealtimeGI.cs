
using UdonSharp;
using UnityEngine;
using VRC.SDKBase;
using VRC.Udon;

[UdonBehaviourSyncMode(BehaviourSyncMode.None)]
public class UpdateRealtimeGI : UdonSharpBehaviour
{
    public MeshRenderer[] GImeshes;

    void Update()
    {

        for (int indx = 0; indx < GImeshes.Length; indx++)
            RendererExtensions.UpdateGIMaterials(GImeshes[indx]);

    }
}
