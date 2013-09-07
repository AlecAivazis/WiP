class WiPWeaponFireMode extends Object // fire mode for creeps and towers
    abstract
    EditInlineNew
    HideCategories(Object);

// weapon owner
var ProtectedWrite WiPAttackable weaponOwner;


function float getAttackingAngle(){
    return 0.9f;
}

// set owner of the weapon
function setOwner(WiPAttackable newOwner){

    local WiPNeutralPawn neutralPawn;
    // prevent newOwner == none
    if (newOwner == none) return;

    weaponOwner = newOwner;

    neutralPawn = WiPNeutralPawn(weaponOwner);
    
    if (neutralPawn != none){
        `log("rep info ===============================" @ neutralPawn.PlayerReplicationInfo);
    }
    

}

function bool IsFiring(){
	
    if (weaponOwner != None) return WeaponOwner.GetActor().IsTimerActive(NameOf(Fire), Self);

	return false;
}

function Fire(){
    `log("pew pew pew");
}

// start firing the weapon
function startFire(){
    
    local float firingRate;
    local WiPNeutralPawn neutralPawn;
    local WiPPawnReplicationInfo pawnRepInfo;

    if (weaponOwner != none){
        fire();

        neutralPawn = WiPNeutralPawn(WeaponOwner);
        if (neutralPawn != none){
            firingRate = neutralPawn.BaseAttackTime;
            
            pawnRepInfo = WiPPawnReplicationInfo(neutralPawn.PlayerReplicationInfo);
        }
    }
}