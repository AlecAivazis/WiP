class WiPChampion extends WiPPawn
    implements (WiPAttackable);

// white damage
var(Damage) int WhiteDamage;
// white damage type
var(Damage) class<DamageType> WhiteDamageType;


simulated event PostBeginPlay(){

    super.PostBeginPlay();

    `log("Created a champion =================");
}


function AddDefaultInventory()
{
	InvManager.CreateInventory(class'Weapon_Sniper'); //InvManager is the pawn's InventoryManager
	// InvManager.CreateInventory(class'UTWeap_LinkGun'); //InvManager is the pawn's InventoryManager

}



/*****************************************************************
*   Interface - WiPAttackble                                     *
******************************************************************/

// return the actor implimenting this interface
simulated function Actor getActor(){
    return self;
}

// return the amount of white damage (auto attacks)
simulated function int getWhiteDamage(){
    return 50;
}

// return the actors attacking priority - lower than creeps
simulated function int getAttackPriority(Actor Attacker){
    return 5;
}

// return the damage type for white damage
simulated function class<DamageType> GetDamageType(){
    return WhiteDamageType;
}

// need to impliment 
simulated function GetWeaponFiringLocationAndRotation(out Vector FireLocation, out Rotator FireRotation);

defaultProperties
{
    WhiteDamage = 50
	WhiteDamageType = class'DamageType'

}