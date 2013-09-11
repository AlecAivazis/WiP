class WiPChampion extends WiPPawn
    implements (WiPAttackable);




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
    local int eligibleChampions;
    local WiPChampion CurHeroPawn;
    local WiPChampionReplicationInfo champRepInfo;
    local WiPPlayerController playerController;
    local WiPPlayerReplicationInfo playerRepInfo, currentPlayerRepInfo;
    local int moneyToGive, expToGive;


    // get replication information
    champRepInfo = WiPChampionReplicationinfo(PlayerReplicationInfo);
    if (champRepInfo != none) {

        playerRepInfo = WiPPlayerReplicationInfo(champRepInfo.PlayerReplicationInfo);
        if (playerRepInfo != none){

            playerRepInfo.NextRespawnTime = WorldInfo.TimeSeconds + 15.f + (champRepInfo.Level * 5.f);
            `log("player respawn time ============ " @ playerRepInfo.NextRespawnTime );
        }
    }

    // if the killer was a player, give him 1.5 of the money instead
    moneyToGive = MoneyToGiveOnKill;
    
    // count the number of champions around
    eligibleChampions = 0;
    foreach WorldInfo.AllPawns(class'WiPChampion', CurHeroPawn, Location, rewardRange ){
        if (CurHeroPawn.GetTeamNum() != GetTeamNum()){
            eligibleChampions++;
        }
    }

    // iterate over those champions again and reward them
    foreach WorldInfo.AllPawns(class'WiPChampion', CurHeroPawn, Location, rewardRange ){
        // opponents only
        if(CurHeroPawn.GetTeamNum() != GetTeamNum()){

            champRepInfo = WiPChampionReplicationInfo(CurHeroPawn.PlayerReplicationInfo);
            if (champRepInfo != none){

                currentPlayerRepInfo = WiPPlayerReplicationInfo(CurHeroPawn.PlayerReplicationInfo);

                expToGive =ExperienceToGiveOnKill/eligibleChampions;

                // check if we're going to level the hero to give the player the appropriate amt of gold
                if (champRepInfo.willLevel(expToGive)){
                    currentPlayerRepInfo.GiveGold(currentPlayerRepInfo.MoneyToGiveOnLevel);
                }

                champRepInfo.GiveExperience(expToGive);

                // give the killer extra gold for the last hit
                if (CurHeroPawn.Controller == Killer){
                    currentPlayerRepInfo.GiveGold(moneyToGive * LastHitMultiplier);
                }else {
                    currentPlayerRepInfo.GiveGold(moneyToGive);
                }
            }
        }
    }
    

    return Super.Died(Killer, DamageType, HitLocation);

}


// add the default weapon
function AddDefaultInventory(){
	InvManager.CreateInventory(class'UTWeap_LinkGun');
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