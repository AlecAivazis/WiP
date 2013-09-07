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
    
    // prevent newOwner == none
    if (newOwner == none) return;

    weaponOwner = newOwner;
}

function bool IsFiring(){
	
    if (weaponOwner != None) return WeaponOwner.GetActor().IsTimerActive(NameOf(Fire), Self);

	return false;
}

function Fire(){
    return;   
}