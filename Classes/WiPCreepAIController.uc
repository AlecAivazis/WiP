class WiPCreepAIController extends AIController;

// the current pawn (typecasted version of Pawn)
var WiPCreepPawn creepPawn;
// the index in the route
var int routeIndex;

event PostBeingPlay(){
    Super(Actor).PostBeginPlay();
    
    `log("Created an ai! (PostBeginPlay) ========================================");
}


function Initialize(){
    
    `log('Called initialize');

    // cache a type casted version of Pawn
    CreepPawn = WiPCreepPawn(Pawn);

    // start at the beginning of the route
    routeIndex = 0;

    // begin AI loop
    WhatToDoNext();
    // SetTimer(0.25f, true, NameOf(aiTick));
}

event Possess(Pawn inPawn, bool bVehicleTransition)
{
    `log("Possesed pawn");
	Super.Possess(inPawn, bVehicleTransition);
	inPawn.SetMovementPhysics();
}


function WhatToDoNext(){

    `log("The Creep AI is ticking... " @ creepPawn);
}

defaultproperties{}