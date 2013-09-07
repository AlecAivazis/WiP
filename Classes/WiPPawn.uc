class WiPPawn
    extends Pawn;

var ProtectedWrite WiPStatModifier statModifier;

simulated event PostBeginPlay(){
    super.PostBeginPlay();
    
    if (Role == Role_Authority){

        //create a StatModifier
        statModifier = new class'WiPStatModifier'();

    }


}


simulated event ReplicatedEvent(name VarName)
{
	// Money was replicated
	Super.ReplicatedEvent(VarName);
}

// called everytime a pawn updates
simulated function Tick(float DeltaTime){
    
    Super.Tick(DeltaTime);
    
    if (Role == Role_Authority){
       
       recalculateStats();
    }
}

// recalcuate the pawn's stats
function recalculateStats(){
    
   local WiPPawnReplicationInfo pawnRepInfo;

    // local bool JustSpawned;

    if (statModifier == None){
        `log ("Could not make a statModifier!! ======================================");
        return;
    }
    // Check if this pawn has just spawned
    // JustSpawned = (Abs(WorldInfo.TimeSeconds - SpawnTime) < 0.05f);

    pawnRepInfo = WiPPawnReplicationInfo(PlayerReplicationInfo);
    
    if (pawnRepInfo != none) {
        pawnRepInfo.AttackSpeed = 0.2f;
    }


}

function AddDefaultInventory()
{
	InvManager.CreateInventory(class'Weapon_Sniper'); //InvManager is the pawn's InventoryManager
	// InvManager.CreateInventory(class'UTWeap_LinkGun'); //InvManager is the pawn's InventoryManager

}
/*****************************************************************
*   Interface - WiPAttackble                                     *
******************************************************************/


// return true if the actor is still valid to attack
simulated function bool isValidToAttack(){
    return Controller != None && Health > 0;
}

/*****************************************************************
*   Camera                                                       *
******************************************************************/

//fix aiming to a plane
simulated singular event Rotator GetBaseAimRotation()
{
   local rotator   POVRot, tempRot;

   tempRot = Rotation;
   tempRot.Pitch = 0;
   SetRotation(tempRot);
   POVRot = Rotation;
   POVRot.Pitch = 0;


   return POVRot;
}


//override to make player mesh visible by default
simulated event BecomeViewTarget( PlayerController PC )
{
   local UTPlayerController UTPC;

   Super.BecomeViewTarget(PC);

   if (LocalPlayer(PC.Player) != None)
   {
      UTPC = UTPlayerController(PC);
      if (UTPC != None)
      {
         //set player controller to behind view and make mesh visible
         UTPC.SetBehindView(true);
         UTPawn(PC.Pawn).SetMeshVisibility(UTPC.bBehindView);
         UTPC.bNoCrosshair = true;
      }
   }
}

defaultproperties
{
	Components.Remove(Sprite)
	
	Physics=PHYS_Walking
	bAlwaysRelevant=true
	bReplicateHealthToAll=true

	Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
		ModShadowFadeoutTime=0.25
		MinTimeBetweenFullUpdates=0.2
		AmbientGlow=(R=.01,G=.01,B=.01,A=1)
		AmbientShadowColor=(R=0.15,G=0.15,B=0.15)
		bSynthesizeSHLight=TRUE
	End Object
	Components.Add(MyLightEnvironment)

    Begin Object Class=SkeletalMeshComponent Name=InitialSkeletalMesh
		CastShadow=true
		bCastDynamicShadow=true
		bOwnerNoSee=false
		LightEnvironment=MyLightEnvironment;
        BlockRigidBody=true;
        CollideActors=true;
        BlockZeroExtent=true;
		PhysicsAsset=PhysicsAsset'CH_AnimCorrupt.Mesh.SK_CH_Corrupt_Male_Physics'
		AnimSets(0)=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_AimOffset'
		AnimSets(1)=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_BaseMale'
		AnimTreeTemplate=AnimTree'CH_AnimHuman_Tree.AT_CH_Human'
		SkeletalMesh=SkeletalMesh'CH_LIAM_Cathode.Mesh.SK_CH_LIAM_Cathode'
	End Object

	Mesh=InitialSkeletalMesh;
	Components.Add(InitialSkeletalMesh);

	InventoryManagerClass=class'WiPInventoryManager';

	// Collision
	BaseEyeHeight=+00008.000000
	EyeHeight=+00008.000000
	
}
