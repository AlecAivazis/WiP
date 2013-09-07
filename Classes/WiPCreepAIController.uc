// Creep AIController - follows creepPawn.Factory.Route

class WiPCreepAIController extends WiPAIController;

// store all of the actors implementing WiPAttackable that are in your Weapon Trigger
var array<WiPAttackable> VisibleAttackables;

// the current pawn (typecasted version of Pawn)
var WiPCreepPawn creepPawn;
// the index in the route
var int routeIndex;
// Sight detection trigger
var WiPTrigger sightDetectionTrigger;
// store the team of creepPawn
var byte teamIndex;


function Initialize(){

    // cache a type casted version of Pawn
    creepPawn = WiPCreepPawn(Pawn);

    teamIndex = creepPawn.getTeamNum();
    
    `log("sight range ======================" @ creepPawn.SightRange);

    // start at the appropriate end of the route
    if ( teamIndex == 1){
        // if we're on the second team, start the minion at the end of the route
        routeIndex = CreepPawn.Factory.Route.RouteList.Length - 1;
    } else {
        routeIndex = 0;
    }

    // begin AI loop
    WhatToDoNext();
    SetTimer(0.25f, true, NameOf(WhatToDoNext));

    // spawn sight detector trigger
    sightDetectionTrigger = Spawn(class'WiPTrigger');
    if(sightDetectionTrigger != none){
        
        // attach it to the creep pawn
        sightDetectionTrigger.SetBase(creepPawn);

        // set sight collision radius
        if (sightDetectionTrigger.triggerCollisionComponent != none)
            sightDetectionTrigger.triggerCollisionComponent.SetCylinderSize(creepPawn.sightRange, 64.F);
            
        //bind the delegates
        sightDetectionTrigger.OnTouch = internalOnSightTrigger;
        sightDetectionTrigger.OnUnTouch = internalOnUnSightTrigger;

    }

}

// Called when the trigger used for sight has been touched
simulated function internalOnSightTrigger(Actor Caller, Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal){

    local WiPAttackable wipAttackable;
    
    // make sure that the caller is who triggered the detection
    if (Caller == sightDetectionTrigger){
        
        // Don't include this pawn
        if (Other == creepPawn) return;
    
        // make sure other implements WiPAttackable
        //  * is valid for attacking
        //  * on a different team
        //  * is not currently in my visible
        wipAttackable = WiPAttackable(Other);
        if (wipAttackable != none && wipAttackable.IsValidToAttack() && creepPawn.GetTeamNum() != wipAttackable.GetTeamNum() && visibleAttackables.Find(wipAttackable) == INDEX_NONE){
            visibleAttackables.AddItem(wipAttackable);
        }
    }
}

//Called when the trigger used for sight has been untouched
simulated function internalOnUnSightTrigger(Actor Caller, Actor Other)
{
	local WiPAttackable wipAttackable;

	// Ensure the caller matches the sight detection trigger
	if (Caller == sightDetectionTrigger)
	{
		// Remove UDKMOBAAttackInterface from the visible attack interfaces array
		wipAttackable = WiPAttackable(Other);
		if (wipAttackable != None)
		{
			visibleAttackables.RemoveItem(wipAttackable);
		}
	}
}

// AI tick
function WhatToDoNext(){
    
    local WiPAttackable AttackInterface, BestAttackInterface;
	local int i, attackPriority, highestAttackPriority;

    // check that we are a valid pawn
    if (creepPawn == none){
        ClearTimer(NameOf(WhatToDoNext));
        return;
    }
    
    //===================
    // Enemy Attack Logic
    //===================

    // if the current enemy is stil valid to attack, of not - clear it
    if (currentEnemy != None){
		attackInterface = WiPAttackable(currentEnemy);
		if (attackInterface != None && (!attackInterface.isValidToAttack() || VSizeSq(Pawn.Location - currentEnemy.Location) >= creepPawn.SightRange))
		{
			clearCurrentEnemy();
		}
	}
	
	// I am not targeting anyone, could I be?
	if (currentEnemy == none){

        // if there are visible attack interfaces, then attack
        if (visibleAttackables.Length > 0){
            
            for (i = 0; i< visibleAttackables.Length; i++){
             
                if (visibleAttackables[i].isValidToAttack()){

                    attackPriority = visibleAttackables[i].getAttackPriority(Self);
                    if (bestAttackInterface == none || highestAttackPriority < attackPriority){
                        bestAttackInterface = visibleAttackables[i];
                        highestAttackPriority = attackPriority;
                    }

                }
            }
        }

        if (bestAttackInterface != none){
            setCurrentEnemy(bestAttackInterface.GetActor(), BestAttackInterface);

            if (!IsInState('AttackingEnemy')) GotoState('AttackingEnemy');
            
            return;
        }

    // else, we have an enemy
    } else {
     
        if (!IsInState('AttackingEnemy')){
            GotoState('AttackingEnemy');
        }
        
        return;

    }

    // see if we aren't moving, start doing so
    if(!IsInState('WalkingAlongRoute'))
        GotoState('WalkingAlongRoute');
}





/*****************************************************************
*   State - WalkingAlongRoute                                    *
******************************************************************/

state WalkingAlongRoute{

    // called when the state is first entered
    function BeginState(Name PreviousStateName){

        // check that we have values for everything
        if (creepPawn != none && creepPawn.Factory != none && creepPawn.Factory.Route != none){

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
    
    if (teamIndex == 1 && routeIndex > 0) routeIndex--;
    else if (teamIndex != 1 && routeIndex != creepPawn.Factory.Route.RouteList.Length -1) routeIndex++ ;
    
    // set the next destination point
    SetDestinationPosition(CreepPawn.Factory.Route.RouteList[RouteIndex].Actor.Location);
    // face our destination
    SetFocalPoint(GetDestinationPosition() + Normal(GetDestinationPosition() - Pawn.Location) * 64.f);
    Sleep(0.f);
    
    // go to the next one
    Goto('begin');



}



defaultproperties{}
