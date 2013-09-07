class WiPNeutralPawn
    extends WiPPawn
    implements(WiPAttackable);

// money earned by killing the creep
var(Creep) const int moneyToGiveOnKill;
// sight range of creep
var(Creep) const float sightRange;
// weapon range of creep
var(Creep) float defaultWeaponRange;
// experience earned by the creep
var(Creep) const int experienceToGiveOnKill;
// How long an attack takes to do (in seconds) - doesn't change, but does combine with Attack Speed stat.
var(Creep) const float BaseAttackTime;
// Attack speed multiplier for this unit without upgrades/items
var(Stats) const float BaseAttackSpeed;

// weapon range trigger
var ProtectedWrite WiPTrigger weaponRangeTrigger;

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
}

simulated function int GetAttackPriority(Actor Attacker)
{
	return 10;
}


function Actor getActor(){
    return self;
}

function bool isFiring(){
    
    if (WeaponFireMode != none){
        return WeaponFireMode.isFiring();
    }
    
    return false;
}

// start attacking the current enemy
simulated function startFire(byte FireModeNum){
    if (weaponFireMode != none) WeaponFireMode.startFire();
}

defaultproperties{
	BaseAttackTime=2.f
	BaseAttackSpeed=1.f
	SightRange=384.f
}