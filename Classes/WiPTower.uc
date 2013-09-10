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
var(Tower) const float DetectionRadius;

// current targetted enemy
var ProtectedWrite WiPAttackable currentEnemy;

simulated event PostBeginPlay(){
	Super(WiPPawn).PostBeginPlay();

	// Initialize the fire mode
	if (WeaponFireMode != None){
		WeaponFireMode.SetOwner(Self);
	}
}

event TakeDamage(int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser){

    `log("you attacked a tower.");

	Super.TakeDamage(DamageAmount, EventInstigator, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);
}

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
	DetectionRadius=512.f
	BaseAttackDamage=50.f
	PawnDamageType=class'DamageType'
	MoneyToGiveOnKill = 1200
	LastHitMultiplier = 1.2

}