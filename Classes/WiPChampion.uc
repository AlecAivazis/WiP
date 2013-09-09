class WiPChampion extends WiPPawn
    implements (WiPAttackable);


simulated event PostBeginPlay(){

    super.PostBeginPlay();

    // Only the server needs to spawn the AIController which is used for pathing
	if (Role == Role_Authority)
	{
		SpawnDefaultController();
        `log("should have spawned the correct controller");
	}
}


// add the default weapon
function AddDefaultInventory(){
	InvManager.CreateInventory(class'WiPWeapon');
}

// return attacking rate
function float getAttackingRate(){
    return 0.1f;
}


// return the team number of this pawn
simulated function byte GetTeamNum(){

    return 0;
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
    return BaseAttackDamage;
}

// return the actors attacking priority - lower than creeps
simulated function int getAttackPriority(Actor Attacker){
    return 5;
}

// return the damage type for white damage
simulated function class<DamageType> GetDamageType(){
    return PawnDamageType;
}

// need to impliment
simulated function GetWeaponFiringLocationAndRotation(out Vector FireLocation, out Rotator FireRotation);

defaultProperties
{
    BaseAttackDamage = 50
	BaseAttackTime = 2.f
	PawnDamageType = class'DamageType'
    ControllerClass = class'WiPChampionController');
}