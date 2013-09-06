class WiPCreepAIController extends WiPAIController;


// the current pawn (typecasted version of Pawn)
var WiPCreepPawn creepPawn;
// the index in the route
var int routeIndex;


event Possess(Pawn inPawn, bool bVehicleTransition)
{
    Super.Possess(inPawn, bVehicleTransition);
	inPawn.SetMovementPhysics();
}



function Initialize(){
    
    `log('Called initialize');

    // cache a type casted version of Pawn
    CreepPawn = WiPCreepPawn(Pawn);

    // start at the beginning of the route
    routeIndex = 0;

    // begin AI loop
    WhatToDoNext();
    SetTimer(0.25f, true, NameOf(WhatToDoNext));
}

function WhatToDoNext(){

    `log("The Creep AI is ticking... " @ creepPawn);
}

defaultproperties{}
