class WiPTower extends WiPObjective
    implements (WiPAttackable);

// Ring static mesh used to highlight the tower
var(Tower) const StaticMeshComponent RingStaticMesh;
// Relative offset to the tower location to specify where the projectile should spawn
var(Tower) const Vector SpawnProjectileOffset;
// weapon range trigger
var ProtectedWrite WiPTrigger weaponRangeTrigger;
// Weapon fire mode
var(Tower) const editinline instanced WiPWeaponFireMode WeaponFireMode;
// Particle system used by the tower
var(Tower) const ParticleSystemComponent ParticleSystem;
// Point light used to light the area around the tower
var(Tower) const LightComponent Light;
// Tower detection radius
var(Tower) const float SightRadius;


// all of the enemies that are in range
var ProtectedWrite array<WiPAttackable> TargetsInSight;
// current targetted enemy
var ProtectedWrite WiPAttackable currentEnemy;
// Sight trigger
var ProtectedWrite WiPTrigger SightTrigger;

// called when this pawn is instantiated
simulated event PostBeginPlay(){
	Super(WiPPawn).PostBeginPlay();

	// Initialize the fire mode
	if (WeaponFireMode != None){
		WeaponFireMode.SetOwner(Self);
	}

	// create the detection trigger
	SightTrigger = Spawn(class'WiPTrigger',,,Location);
	if (SightTrigger != none){

        if (SightTrigger.CollisionCylinderComponent != none){
            SightTrigger.CollisionCyllinder.Component.SetCylinderSize(SightRadius, 64.f);
        }

        SightTrigger.OnTouch = InternalOnTouch;
        SightOnUnTouch = InternalOnUnTouch;

    }
}

// called when this pawn is destroyed
simulated event Destroyed(){

    Super.Destroyed();

    // delete the sight trigger
    if (SightTrigger != none){
        SightTrigger.OnTouch = none;
        SightTrigger.OnUnTouch = none;
        SightTrigger.Destroy();
    }
}

// called whenever a pawn touches the sight detector
simulated function InternalOnUnTouch(Actor Caller, Actor Other){

    local WiPAttackable otherAttackable;

    // make sure the caller is the SightTrigger
    if (Caller != SightTrigger) return;

    otherAttackable = WiPAttackable(Other);
    if (otherAttackable != none){
        TargetsInSight.RemoveItem(otherAttackable);
    }

}


// called whenever a pawn leaves the sight detector
simulated function InternalOnTouch(Actor Caller, Actor Other){
    
    local WiPAttackable otherAttackable;

    // make sure the caller is the SightTrigger
    if (Caller != SightTrigger) return;

    otherAttackable = WiPAttackable(Other);
    if (otherAttackable != none){
        TargetsInSight.AddItem(otherAttackable);
    }

}

// called everytime the tower updates
event Tick(float DeltaTime){

    Super.Tick(DeltaTime);
    
    // only perform currentEnemy assignment on the server
    if (Role != Role_Authority) continue;
    
    // validate currentEnemy
    if (currentEnemy != none){
        if (!currentEnemy.IsValidToAttack() || currentEnemy.GetTeamNum() == GetTeamNum() || TargetsInRange.Find(currentEnemy) == INDEX_NONE)
            currentEnemy = none;
    }
    
    
    


}

// removed for immovable objects

function HandleMomentum(vector Momentum, Vector HitLocation, class<DamageType> DamageType, optional TraceHitInfo HitInfo);

function AddVelocity(vector NewVelocity, vector HitLocation, class<DamageType> DamageType, optional TraceHitInfo HitInfo);


/*****************************************************************
*   Interface - WiPAttackble                                     *
******************************************************************/

simulated function Actor getActor(){
    return self;
}


// get the white damage done by this pawn
function int getWhiteDamage(){
    return BaseAttackDamage;
}

// return the current enemy
simulated function Actor GetEnemy(){
    return currentEnemy.GetActor();
}

// return the attack priority (less than minions but more than players)
simulated function int GetAttackPriority(Actor Attacker){
    return 7;
}

// return if the tower is valid to attack
simulated function bool isValidToAttack(){
    return Health > 0;
}

// return the damage type of the tower
simulated function class<DamageType> GetDamageType(){
    return PawnDamageType;
}

// change the FireLocation and Rotation for projectiles
simulated function GetWeaponFiringLocationAndRotation(out Vector FireLocation, out Rotator FireRotation){
	FireLocation = Location + SpawnProjectileOffset;
	FireRotation = Rotator(CurrentEnemy.GetActor().Location - FireLocation);
}

defaultproperties
{
    Begin Object Class=StaticMeshComponent Name=MyRingStaticMeshComponent
		LightEnvironment=MyLightEnvironment
	End Object
	Components.Add(MyRingStaticMeshComponent)
	RingStaticMesh=MyRingStaticMeshComponent

	Begin Object Class=PointLightComponent Name=MyLightComponent
	End Object
	Components.Add(MyLightComponent)
	Light=MyLightComponent

	Begin Object Class=ParticleSystemComponent Name=MyParticleSystemComponent
		SecondsBeforeInactive=1
	End Object
	Components.Add(MyParticleSystemComponent)
	ParticleSystem=MyParticleSystemComponent

	bDontPossess=true
	bEdShouldSnap=true
	HealthMax=4250
	Health=4250
	SightRadius=512.f
	BaseAttackDamage=50.f
	PawnDamageType=class'DamageType'
	MoneyToGiveOnKill = 1200
	LastHitMultiplier = 1.2

}