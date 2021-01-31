using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UdonSharp;

public class ToggleButton : UdonSharpBehaviour
{
    public GameObject TargetObject;

    public override void Interact()
    {
        this.TargetObject.SetActive(!this.TargetObject.activeSelf);
    }
}
