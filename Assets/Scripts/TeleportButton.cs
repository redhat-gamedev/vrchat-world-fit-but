using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using VRC.SDKBase;
using UdonSharp;

public class TeleportButton : UdonSharpBehaviour
{
    public Transform TargetPoint;

    public override void Interact()
    {
        Networking.LocalPlayer.TeleportTo(this.TargetPoint.position, this.TargetPoint.rotation);
        //base.Interact();
    }
}
