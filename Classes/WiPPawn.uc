class WiPPawn
    extends Pawn;


// Attack type definition
enum AttackTypes
{
	ATT_Magic,
	ATT_Physical,
};

// statModifier
var ProtectedWrite WiPStatModifier statModifier;

// Weapon firing socket name, the socket is stored within WeaponSkeletalMesh
var(Weapon) const Name WeaponFiringSocketName;
// Weapon skeletalMesh
var(Weapon) const SkeletalMeshComponent WeaponSkeletalMesh;
// Weapon attachment socket
var(Weapon) const Name WeaponAttachmentSocketName;
// The type of damage this pawn deals when auto-attacking
var(Weapon) const class<DamageType> PawnDamageType<DisplayName=DamageType>;

// money earned by killing the creep
var(Misc) const int moneyToGiveOnKill;
// money multipler for last hit
var(Misc) const float LastHitMultiplier;
// experience earned by the creep
var(Misc) const int experienceToGiveOnKill;
// range to reward gold/exp
var(Misc) const float rewardRange;
// the name of the melee socket
var(Misc) const Name meleeSocketName;
// the lighting environment for the pawn
var(Misc) const DynamicLightEnvironmentComponent LightEnvironment;

// How much health this pawn has - sync'd with 'Pawn.Health'
var(Stats) float currentHealth;
// How long an attack takes to do (in seconds) - doesn't change, but does combine with Attack Speed stat.
var(Stats) const float BaseAttackTime;
// Attack speed multiplier for this unit without upgrades/items
var(Stats) const float BaseAttackSpeed;
// Attack speed multiplier for this unit without upgrades/items
var(Stats) const float BaseAttackDamage;
// weapon range of creep
var(Stats) float WeaponRange;
// sight range of creep
var(Stats) const float SightRange;
// How many hit points this unit has at level 1 (minus strength hitpoints)
var(Stats) const float BaseHealth;

// the swinging animation (to play during a swing)
var AnimNodePlayCustomAnim SwingAnim;


simulated event PostBeginPlay(){
    super.PostBeginPlay();
    
    if (Role == Role_Authority){
        //create a StatModifier
        statModifier = new class'WiPStatModifier'();
    }

    // set currentHealth to Health
    currentHealth = Health;
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

// modify the incoming damage based on the damage type
function AdjustDamage(out int InDamage, out vector Momentum, Controller InstigatedBy, vector HitLocation, class<DamageType> DamageType, TraceHitInfo HitInfo, Actor DamageCauser){

	Super.AdjustDamage(InDamage, Momentum, InstigatedBy, HitLocation, DamageType, HitInfo, DamageCauser);

}





// replicate variables
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

// buff/debuff damage take compensate for missing, magic amp, etc.
function BuffAttack(out float Damage, class<DamageType> DamageType){
	//if (DamageType == class'UDKMOBADamageTypePhysical')
	Damage *=1 ;
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
simulated singular event Rotator GetBaseAimRotation(){

   local rotator   POVRot;

   POVRot = Rotation;
   POVRot.Pitch = 0;

    SetRotation(POVRot);
   return POVRot;
}

/*
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
*/

// take damage handler
event TakeDamage(int Damage, Controller InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser){
    local int actualDamage;
    local Controller killer;

   // `log("attacked : " @ self);

    //`log("my health is at =========================" @ currentHealth);
    //`log("I'm taking damage!!!!! ====================" @ Damage);
    //`log("This guy hurt me =============== " @ InstigatedBy);

    if (Role < ROLE_Authority || Health <=0){
        return;
    }

    if (DamageType == none){
        DamageType = class'DamageType';
    }

    // make sure it's bigger than zero, if not do zero damage
    Damage = Max(Damage, 0);

    // set physics if its not set and we're not in a vehicle
    if (Physics == PHYS_None && DrivenVehicle == None){
        SetMovementPhysics();
    }
    
    // if we're walking and there's extra z momentum in the damage type
    if (Physics == PHYS_Walking && DamageType.default.bExtraMomentumZ){
		Momentum.Z = FMax(Momentum.Z, 0.4f * VSize(Momentum));
	}

    //
	Momentum = Momentum / Mass; // this is really velocity

	if (DrivenVehicle != None){
		DrivenVehicle.AdjustDriverDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType);
	}

	ActualDamage = Damage;
	WorldInfo.Game.ReduceDamage(ActualDamage, Self, InstigatedBy, HitLocation, Momentum, DamageType, DamageCauser);
	AdjustDamage(ActualDamage, Momentum, InstigatedBy, HitLocation, DamageType, HitInfo, DamageCauser);

	// call Actor's version to handle any SeqEvent_TakeDamage for scripting
	Super(Actor).TakeDamage(ActualDamage, InstigatedBy, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);

	currentHealth -= ActualDamage;
	Health = int(currentHealth);

	if (IsZero(HitLocation)){
		HitLocation = Location;
	}

	if (Health <= 0){
		// pawn died
		Killer = SetKillInstigator(InstigatedBy, DamageType);
		TearOffMomentum = Momentum;
		Died(Killer, DamageType, HitLocation);
	}
	else{
		HandleMomentum(Momentum, HitLocation, DamageType, HitInfo);
		NotifyTakeHit(InstigatedBy, HitLocation, ActualDamage, DamageType, Momentum, DamageCauser);

		if (DrivenVehicle != None){
			DrivenVehicle.NotifyDriverTakeHit(InstigatedBy, HitLocation, ActualDamage, DamageType, Momentum);
		}

		if (InstigatedBy != None && InstigatedBy != Controller){
			LastHitBy = InstigatedBy;
		}
	}

	PlayHit(ActualDamage, InstigatedBy, HitLocation, DamageType, Momentum, HitInfo);
	MakeNoise(1.f);


}

// start the animTree
simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp){
    super.PostInitAnimTree(SkelComp);

    if (SkelComp == Mesh){
        SwingAnim = AnimNodePlayCustomAnim(SkelComp.FindAnimNode('SwingCustomAnim'));
    }
}



// called when the pawn dies
function bool Died(Controller Killer, class<DamageType> DamageType, vector HitLocation){
    local int eligibleChampions;
    local WiPChampion CurHeroPawn;
    local WiPChampionReplicationInfo champRepInfo;
    local WiPPlayerController playerController;
    local WiPPlayerReplicationInfo playerRepInfo, currentPlayerRepInfo;
    local int moneyToGive, expToGive;


    `log("This pawn has died" @ self);

    if (WiPPlayerController(Killer) != none){
        // grab the killer's controller
        //killerController = WiPChampionController(Killer);

        playerController = WiPPlayerController(Killer);
        playerRepInfo = WiPPlayerReplicationInfo(playerController.PlayerReplicationInfo);
        if (playerRepInfo != none){

            // give the player a last hit and
            playerRepInfo.lastHits++;
           // `log("You got a last hit. Current amount " @ playerRepInfo.lastHits);

        }
    }

    // if the killer was a player, give him 1.5 of the money instead
    moneyToGive = MoneyToGiveOnKill;

    // count the number of champions around
    eligibleChampions = 0;
    foreach WorldInfo.AllPawns(class'WiPChampion', CurHeroPawn, Location, rewardRange ){
        if (CurHeroPawn.GetTeamNum() != GetTeamNum()){
            eligibleChampions++;
        }
    }

    // iterate over those champions again and reward them
    foreach WorldInfo.AllPawns(class'WiPChampion', CurHeroPawn, Location, rewardRange ){
        // opponents only
        if(CurHeroPawn.GetTeamNum() != GetTeamNum()){

            champRepInfo = WiPChampionReplicationInfo(CurHeroPawn.PlayerReplicationInfo);
            if (champRepInfo != none){

                currentPlayerRepInfo = WiPPlayerReplicationInfo(CurHeroPawn.PlayerReplicationInfo);

                expToGive =ExperienceToGiveOnKill/eligibleChampions;

                // check if we're going to level the hero to give the player the appropriate amt of gold
                if (champRepInfo.willLevel(expToGive)){
                    currentPlayerRepInfo.GiveGold(currentPlayerRepInfo.MoneyToGiveOnLevel);
                }

                champRepInfo.GiveExperience(expToGive);

                // give the killer extra gold for the last hit
                if (CurHeroPawn.Controller == Killer){
                    currentPlayerRepInfo.GiveGold(moneyToGive * LastHitMultiplier);
                }else {
                    currentPlayerRepInfo.GiveGold(moneyToGive);
                }

            }
        }
    }
    Mesh.SetHidden(true);
    return Super.Died(Killer, DamageType, HitLocation);
}

defaultproperties
{
	Components.Remove(Sprite)

	Physics=PHYS_Walking
	bAlwaysRelevant=true
	bReplicateHealthToAll=true
	BaseHealth=10.f

	Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
		ModShadowFadeoutTime=0.25
		MinTimeBetweenFullUpdates=0.2
		AmbientGlow=(R=.01,G=.01,B=.01,A=1)
		AmbientShadowColor=(R=0.15,G=0.15,B=0.15)
		bSynthesizeSHLight=TRUE
	End Object
	Components.Add(MyLightEnvironment)
    LightEnvironment=MyLightEnvironment

    Begin Object Class=SkeletalMeshComponent Name=InitialSkeletalMesh
		CastShadow=true
		bCastDynamicShadow=true
		bOwnerNoSee=false
		LightEnvironment=MyLightEnvironment
        BlockRigidBody=true
        CollideActors=true
        BlockZeroExtent=true
		PhysicsAsset=PhysicsAsset'CH_AnimCorrupt.Mesh.SK_CH_Corrupt_Male_Physics'
		AnimSets(0)=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_AimOffset'
		AnimSets(1)=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_BaseMale'
		AnimSets(2)=AnimSet'WiP_ASSESTS.Animations.MeleeWeaponAnimSet'
	    	//AnimTreeTemplate=AnimTree'CH_AnimHuman_Tree.AT_CH_Human'
		AnimTreeTemplate=AnimTree'WiP_ASSESTS.Animations.DefaultAnimTree'
		//SkeletalMesh=SkeletalMesh'CH_LIAM_Cathode.Mesh.SK_CH_LIAM_Cathode'
		SkeletalMesh=SkeletalMesh'WiP_ASSESTS.Characters.Bane'
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

    Begin Object Name=CollisionCylinder
    CollisionRadius=+0030.000000
    CollisionHeight=+0062.000000
    End Object
    CylinderComponent=CollisionCylinder
    
    meleeSocketName = WeaponPoint
}
