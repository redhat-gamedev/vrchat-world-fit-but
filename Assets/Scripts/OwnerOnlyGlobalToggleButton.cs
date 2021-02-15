using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UdonSharp;

public class OwnerOnlyGlobalToggleButton : UdonSharpBehaviour
{
    public GameObject[] TargetObjects;

    [UdonSynced]
    public bool ToggleEnabled = false;

    public override void Interact()
    {
        this.ToggleEnabled = !this.ToggleEnabled;
        OnDeserialization();
    }

    public override void OnDeserialization()
    {
        foreach(GameObject go in this.TargetObjects)
            go.SetActive(this.ToggleEnabled);
    }
}
