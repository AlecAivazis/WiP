class WiPCreepPawn
    extends WiPPawn;

// money earned by killing the creep
var(Creep) const int moneyToGiveOnKill;
// sight range of creep
var(Creep) const float sightRange;
// experience earned by the creep
var(Creep) const int experienceToGiveOnKill;

// store the parent factory
var RepNotify WiPCreepFactory Factory;

// Replication Block
replication{
    if (bNetInitial)
        Factory;
}


simulated event PostBeginPlay()
{
    if (Role == Role_Authority){
        Factory = WiPCreepFactory(Owner);
    }

	super.PostBeginPlay();
}

defaultproperties{
    ControllerClass=class'WiPAIController'
}