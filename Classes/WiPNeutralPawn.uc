class WiPNeutralPawn
    extends WiPPawn;

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

        WeaponFireMode.SetOwner(Self);

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

defaultproperties{}