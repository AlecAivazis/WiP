class WiPCreepAIController extends AIController;

function initialize(){

    aiTick();
    SetTimer(0.25f, true, NameOf(aiTick));
}


function aiTick(){

    `log("The Creep AI is ticking... " @ Pawn);
}

defaultproperties{}