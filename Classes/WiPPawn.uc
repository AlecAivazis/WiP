class WiPPawn
    extends Pawn;


// Attack type definition
enum AttackTypes
{
	ATT_Magic,
	ATT_Physical,
};

var ProtectedWrite WiPStatModifier statModifier;
// Weapon firing socket name, the socket is stored within WeaponSkeletalMesh
var(Weapon) const Name WeaponFiringSocketName;
// Weapon skeletalMesh
var(Weapon) const SkeletalMeshComponent WeaponSkeletalMesh;
// Weapon attachment socket
var(Weapon) const Name WeaponAttachmentSocketName;

simulated event PostBeginPlay(){
    super.PostBeginPlay();
    
    if (Role == Role_Authority){

        //create a StatModifier
        statModifier = new class'WiPStatModifier'();

    }
}

simulated function BeginRagdoll(){
	if (WorldInfo.NetMode == NM_DedicatedServer)
	{
		return;
	}

	// Turn off collision
	SetCollision(false, false, false);
	CollisionComponent = Mesh;
	// Always perform kinematic update regardless of distance
	Mesh.MinDistFactorForKinematicUpdate = 0.f;
	// Force an update on the skeletal mesh
	//Mesh.ForceSkelUpdate();
	//Mesh.UpdateRBBonesFromSpaceBases(true, true);
	// Turn on physics assets
	// Mesh.PhysicsWeight = 1.f;
	// Set the physics simulation
	//SetPhysics(PHYS_RigidBody);
	// Unfix all of the bodies on the physics asset instance
    /*	Mesh.PhysicsAssetInstance.SetAllBodiesFixed(false);
	// Set the rigid body channels
	Mesh.SetRBChannel(RBCC_Pawn);
	Mesh.SetRBCollidesWithChannel(RBCC_Default, true);
	Mesh.SetRBCollidesWithChannel(RBCC_Pawn, true);
	Mesh.SetRBCollidesWithChannel(RBCC_Vehicle, true);
	Mesh.SetRBCollidesWithChannel(RBCC_Untitled3, false);
	Mesh.SetRBCollidesWithChannel(RBCC_BlockingVolume, true); */
}

// modify the damage based on the damage type
function ModifyDamage(out float Damage, class<DamageType> DamageType){

    local WiPPawnReplicationInfo pawnRepInfo;

    pawnRepInfo = WiPPawnReplicationInfo(PlayerReplicationInfo);

    if (pawnRepInfo != none){

      //if (DamageType == class'WiPDamageTypePhysical')

        // for now, just leave it untouched
        Damage *= 1;

    }

}

simulated event ReplicatedEvent(name VarName)
{
	// Money was replicated
	Super.ReplicatedEvent(VarName);
}

// called everytime a pawn updates
simulated function Tick(float DeltaTime){
    
    local WiPPawnReplicationInfo pawnRepInfo;
    
    Super.Tick(DeltaTime);
    
    if (Role == Role_Authority){

       recalculateStats();
       
        pawnRepInfo = WiPPawnReplicationInfo(PlayerReplicationInfo);

    }
}

// recalcuate the pawn's stats
function recalculateStats(){
    
   local WiPPawnReplicationInfo pawnRepInfo;

    // local bool JustSpawned;

    if (statModifier == None){
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

 Begin Object Class=SkeletalMeshComponent Name=MyWeaponSkeletalMeshComponent
		CollideActors=false
		BlockRigidBody=false
		bHasPhysicsAssetInstance=false
		bUpdateKinematicBonesFromAnimation=false
		MinDistFactorForKinematicUpdate=0.f
		LightEnvironment=MyLightEnvironment
	End Object
	WeaponSkeletalMesh=MyWeaponSkeletalMeshComponent
	Components.Add(MyWeaponSkeletalMeshComponent)

	Mesh=InitialSkeletalMesh;
	Components.Add(InitialSkeletalMesh);

	InventoryManagerClass=class'WiPInventoryManager';

	// Collision
	BaseEyeHeight=+00008.000000
	EyeHeight=+00008.000000
	
}
