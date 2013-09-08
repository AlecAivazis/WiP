class WiPNeutralPawn
    extends WiPPawn
    implements(WiPAttackable);

// money earned by killing the creep
var(Creep) const int moneyToGiveOnKill;

// experience earned by the creep
var(Creep) const int experienceToGiveOnKill;



// How much health this pawn has - sync'd with 'Pawn.Health'
var(Stats) float currentHealth;
// How long an attack takes to do (in seconds) - doesn't change, but does combine with Attack Speed stat.
var(Stats) const float BaseAttackTime;
// Attack speed multiplier for this unit without upgrades/items
var(Stats) const float BaseAttackSpeed;
// weapon range of creep
var(Stats) float DefaultWeaponRange;
// sight range of creep
var(Stats) const float SightRange;

// weapon range trigger
var ProtectedWrite WiPTrigger weaponRangeTrigger;

// The type of damage this pawn deals when auto-attacking
var(Weapon) const class<DamageType> PawnDamageType<DisplayName=DamageType>;
// Weapon fire mode
var(Weapon) const editinline instanced WiPWeaponFireMode WeaponFireMode;

simulated event PostBeginPlay(){

    Super.PostBeginPlay();

    // set weapon range detector
    if (WeaponFireMode != none){

        WeaponFireMode.SetOwner(self);

        weaponRangeTrigger = Spawn(class'WiPTrigger',,,Location);
        if (weaponRangeTrigger != none){

            // attack the trigger to the pawn
            weaponRangeTrigger.SetBase(self);

            if (weaponRangeTrigger != none){
                weaponRangeTrigger.triggerCollisionComponent.SetCylinderSize(defaultWeaponRange - GetCollisionRadius(), 64.f);
            }

        }
    }
    
    // set the health float
    currentHealth = float(Health);
}

simulated function int GetAttackPriority(Actor Attacker)
{
	return 10;
}


function Actor getActor(){
    return self;
}

// get the white damage done by this pawn
function int getWhiteDamage(){
    return 20;
}


// return the currentEnemy
simulated function Actor getEnemy(){

    local WiPAIController aiController;

    aiController = WiPAIController(Controller);
    if (aiController != none) return aiController.currentEnemy;
    return none;
}

// return true if the pawn is firing
function bool isFiring(){
    if (WeaponFireMode != none){
        return WeaponFireMode.isFiring();
    }

    return false;
}

// get the type of damage this pawn does as white damage
simulated function class<DamageType> GetDamageType(){
	return PawnDamageType;
}

// start attacking the current enemy
simulated function startFire(byte FireModeNum){
    if (weaponFireMode != none) WeaponFireMode.startFire();
}

function bool Died(Controller Killer, class<DamageType> DamageType, vector HitLocation){
    `log("Died was called");
    // Tell the inventory manager
    if (InvManager != none)    InvManager.OwnerDied();
    // Detach controller
	DetachFromController(true);
	// Destroy the weapon fire
	if (WeaponFireMode != none)    WeaponFireMode.Destroy();
	// Destroy the weapon range trigger
	if (WeaponRangeTrigger != none) WeaponRangeTrigger.Destroy();
	
	bReplicateMovement = false;
	bTearOff = true;
	Velocity += TearOffMomentum;

	BeginRagdoll();
	LifeSpan = 5.f;
	return true;
}

event TakeDamage(int Damage, Controller InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser){


    local int actualDamage;
    local Controller killer;

   `log("my health is at =========================" @ currentHealth);
   `log("I'm taking damage!!!!! ====================" @ Damage);

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
		`log("This pawn has died ========================" @ self);
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


defaultproperties
{
	BaseAttackTime=2.f
	BaseAttackSpeed=1.f
	SightRange=500.f
	PawnDamageType=class'DamageType'
}