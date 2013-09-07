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
function startFire(byte FireModeNum){
    if (weaponFireMode != none) WeaponFireMode.startFire();
}

defaultproperties{}