class WiPChampion extends WiPPawn
    implements (WiPAttackable);

// the array of spells castable by this champion




simulated event PostBeginPlay(){

    super.PostBeginPlay();

    // Only the server needs to spawn the AIController which is used for pathing
	if (Role == Role_Authority)
	{
		SpawnDefaultController();
	}
	
	currentHealth = BaseHealth;
}

// called when the pawn dies (assign a new respawn time)
function bool Died(Controller Killer, class<DamageType> DamageType, vector HitLocation){
    local WiPChampionReplicationInfo champRepInfo;
    local WiPPlayerReplicationInfo playerRepInfo;


    // get replication information
    champRepInfo = WiPChampionReplicationinfo(PlayerReplicationInfo);
    if (champRepInfo != none) {

        playerRepInfo = WiPPlayerReplicationInfo(champRepInfo.PlayerReplicationInfo);
        if (playerRepInfo != none){

            playerRepInfo.NextRespawnTime = WorldInfo.TimeSeconds + 15.f + (champRepInfo.Level * 5.f);
            `log("player respawn time ============ " @ playerRepInfo.NextRespawnTime );
        }
    }

    return Super.Died(Killer, DamageType, HitLocation);

}


// add the default weapon
function AddDefaultInventory(){
    // add the default weapon for the champion to handle white damage
	InvManager.CreateInventory(class'WiPDefaultWeapon');
	// add the
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
simulated function GetWeaponFiringLocationAndRotation(out Vector FireLocation, out Rotator FireRotation){
    local vector newLoc;
    newLoc = Location;
    newLoc.Z = 10;

    FireLocation = newLoc;
	FireRotation = Rotation;
}


defaultProperties
{

	RewardRange = 2000.f
    BaseHealth = 150.f
    BaseAttackDamage = 50
	BaseAttackTime = 2.f
	PawnDamageType = class'DamageType'
    ControllerClass = class'WiPChampionController'
    ExperienceToGiveOnKill = 200
    MoneyToGiveOnKill = 400
    LastHitMultiplier = 1.2
}