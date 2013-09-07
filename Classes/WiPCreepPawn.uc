class WiPCreepPawn // a neutral pawn with a factory
    extends WiPNeutralPawn;

// store the parent factory
var RepNotify WiPCreepFactory Factory;

// Replication Block
replication{
    if (bNetInitial)
        Factory;
}

simulated event PostBeginPlay() {

    if (Role == Role_Authority){
        Factory = WiPCreepFactory(Owner);
    }

	super.PostBeginPlay();
}

/*****************************************************************
*   Interface - WiPAttackble                                     *
******************************************************************/

// return true if the factory still exists
simulated function bool isValidToAttack(){
    return Factory != none && Super.isValidToAttack();
}

defaultproperties{}