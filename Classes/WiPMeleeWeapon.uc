class WiPMeleeWeapon extends Weapon;

reliable client function ClientGivenTo(pawn NewOwner, bool bDoNotActivate){

    local WiPPawn wipPawn;
    
    super.ClientGivenTo(NewOwner, bDoNotActivate);
    
    // make sure the owner is a WiPPawn and has a valid socket
    wipPawn = WiPPawn(NewOwner);
    if (wipPawn != none && wipPawn.Mesh.GetSocketByName(WiPPawn.MeleeSocketName) != none){
        
        // equp the weapon
        Mesh.SetShadowParent(wipPawn.Mesh);
        Mesh.SetLightEnvironment(wipPawn.LightEnvironment);
        wipPawn.Mesh.AttachComponentToSocket(Mesh, wipPawn.meleeSocketName);
    }

}

defaultproperties
{
    
    Begin Object Class=SkeletalMeshComponent Name=SwordSkeletalMeshComponent
       bCacheAnimSequenceNodes=false
       AlwaysLoadOnClient=true
       AlwaysLoadOnServer=true
       CastShadow=true
       BlockRigidBody=true
       bUpdateSkelWhenNotRendered=false
       bIgnoreControllersWhenNotRendered=true
       bUpdateKinematicBonesFromAnimation=true
       bCastDynamicShadow=true
       RBChannel=RBCC_Untitled3
       RBCollideWithChannels=(Untitled3=true)
       bOverrideAttachmentOwnerVisibility=true
       bAcceptsDynamicDecals=false
       bHasPhysicsAssetInstance=true
       TickGroup=TG_PreAsyncWork
       MinDistFactorForKinematicUpdate=0.2f
       bChartDistanceFactor=true
       RBDominanceGroup=20
       Scale=1.f
       bAllowAmbientOcclusion=false
       bUseOnePassLightingOnTranslucency=true
       bPerBoneMotionBlur=true
    End Object
    Mesh=SwordSkeletalMeshComponent

}