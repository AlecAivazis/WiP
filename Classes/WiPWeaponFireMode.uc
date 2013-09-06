class WiPWeaponFireMode extends Object // fire mode for creeps and towers
    abstract
    EditInlineNew
    HideCategories(Object);

// weapon owner
var ProtectedWrite WiPAttackable weaponOwner;


// set owner of the weapon
function setOwner(WiPAttackable newOwner){
    
    // prevent newOwner == none
    if (newOwner == none) return;
    
    weaponOwner = newOwner;
}