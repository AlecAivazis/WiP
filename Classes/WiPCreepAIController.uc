class WiPCreepAIController extends WiPAIController;


// the current pawn (typecasted version of Pawn)
var WiPCreepPawn creepPawn;
// the index in the route
var int routeIndex;




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

    // check that we are a valid pawn
    if (creepPawn == none){
        ClearTimer(NameOf(WhatToDoNext));
        return;
    }
    

    // see if we aren't moving, start doing so
    if(!IsInState('WalkingAlongRoute'))
        GotoState('WalkingAlongRoute');


}





/*****************************************************************
*   State                                                       *
******************************************************************/

state WalkingAlongRoute{
    
    // called when the state is first entered
    
    function BeginState(Name PreviousStateName){

        `log("Creep is starting to walk..... =================================");

        // check that we have values for everything
        if (creepPawn != none && creepPawn.Factory != none && creepPawn.Factory.Route != none){
            
            `log("Passed initial state checks ================================");

            // set the pawn's destination to the appropriate actor in its route
            SetDestinationPosition(CreepPawn.Factory.Route.RouteList[RouteIndex].Actor.Location);
            // set the pawn's focal point
            SetFocalPoint(GetDestinationPosition() + Normal(GetDestinationPosition()-Pawn.Location) *64.f);
        }

    }

Begin:
    
    // check that the pawn is valid, if not then go to the end
    if (creepPawn == none) Goto('End');

Move:
    
    // if there's a direct path
    //if (canReachDestination(GetDestinationPosition())){
    if (true){
        // move to the destination
        bPreciseDestination = true;

    }







}



defaultproperties{}
