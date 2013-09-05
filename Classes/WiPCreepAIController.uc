class WiPCreepAIController extends AIController;

// the current pawn (typecasted version of Pawn)
var WiPCreepPawn creepPawn;
// the index in the route
var int routeIndex;

event PostBeingPlay(){
    Super(Actor).PostBeginPlay();
}


function initialize(){
    
    // cache a type casted version of Pawn
    CreepPawn = WiPCreepPawn(Pawn);
    
    // start at the beginning of the route
    routeIndex = 0;

    // begin AI loop
    aiTick();
    SetTimer(0.25f, true, NameOf(aiTick));
}


function aiTick(){

    `log("The Creep AI is ticking... " @ Pawn);
}

defaultproperties{}