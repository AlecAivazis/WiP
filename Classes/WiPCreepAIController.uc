// Creep AIController - follows creepPawn.Factory.Route

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
*   State - Walking Along Route                                  *
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
    
    // called whenever the controller updates itself
    function Tick(float DeltaTime){

        local vector destination;

        Global.Tick(DeltaTime);

        // adjust currentDestination to be at the height of the pawn
        // so that ReachedDestination succeeds
        destination = GetDestinationPosition();
        destination.Z = Pawn.Location.Z;
        SetDestinationPosition(destination);

    }
    
    // called when the pawn reaches its destination
    event ReachedPreciseDestination(){
        GotoState('WalkingAlongRoute', 'ReachedDestination');
    }

Begin:
    
    // check that the pawn is valid, if not then go to the end
    if (creepPawn == none) Goto('End');

Move:

    // if there's a direct path
    if (canReachDestination(GetDestinationPosition())){
        // move to the destination
        bPreciseDestination = true;

    }

// wait 'til we've reached the destination point
NotAtDestination:

    Sleep(0.f);
    Goto('NotAtDestination');



// we've reached our destination, go to the next one if it exists
ReachedDestination:

    if (routeIndex != creepPawn.Factory.Route.RouteList.Length -1) routeIndex ++ ;
    
    // set the next destination point
    SetDestinationPosition(CreepPawn.Factory.Route.RouteList[RouteIndex].Actor.Location);
    // face our destination
    SetFocalPoint(GetDestinationPosition() + Normal(GetDestinationPosition() - Pawn.Location) * 64.f);
    Sleep(0.f);
    
    // go to the next one
    Goto('begin');



}



defaultproperties{}
