class WiPChampion extends WiPPawn
    implements (WiPAttackable);

// white damage
var(Damage) int WhiteDamage;
var(Damage) class<DamageType> WhiteDamageType;


simulated event PostBeginPlay(){
    `log("Created a champion =================");
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
	WhiteDamageType = ATT_Physical

}