class WiPCreepPawn
    extends WiPPawn;

// money earned by killing the creep
var(Creep) const int moneyToGiveOnKill;
// sight range of creep
var(Creep) const float sightRange;
// experience earned by the creep
var(Creep) const int experienceToGiveOnKill;

// Factory that created this creep
var RepNotify WiPCreepFactory Factory;

simulated function int getWhiteDamage(){
    return 5;
}

simulated function int getCurrentHealth(){
    return Health;
}

simulated function int getMaxHealth(){
    return HealthMax;
}


function bool Died(Controller Killer, class<DamageType> DamageType, vector HitLocation)
{
    // impliment these in Hero and Creep Pawn... 

    Destroy();
	return true;
}



defaultproperties{
}