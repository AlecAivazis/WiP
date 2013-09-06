class WiPCreepPawn
    extends WiPPawn;

// money earned by killing the creep
var(Creep) const int moneyToGiveOnKill;
// sight range of creep
var(Creep) const float sightRange;
// experience earned by the creep
var(Creep) const int experienceToGiveOnKill;


simulated event PostBeginPlay()
{
	super.PostBeginPlay();
	
	`log("You created a CREEP pawn ========================" @ Controller);
}

defaultproperties{
    ControllerClass=class'WiPCreepAIController'
}