class WiPAIController extends AIController;

// the current enemy
var PrivateWrite Actor currentEnemy;
// the current enemy's attack interface
var PrivateWrite WiPAttackable currentEnemyAttackInterface;
// cached version of Pawn
var PrivateWrite WiPNeutralPawn cachedPawn;

event Possess(Pawn inPawn, bool bVehicleTransition)
{
	// cache a typecasted inPawn
	cachedPawn = WiPNeutralPawn(inPawn);
	
	if (cachedPawn != none){
        Super.Possess(inPawn, bVehicleTransition);
    
        // set physics for generated pawns
    	inPawn.SetMovementPhysics();
    }
}


// stop targeting current enemy
function ClearCurrentEnemy(){
    currentEnemy = None;
    currentEnemyAttackInterface =  None;
}

// check if there is a direct path between me and a location
function bool canReachDestination(Vector loc){

    local Actor actorHit;
    local Vector hitLocation, hitNormal, extent;


    if (Pawn == none) return false;

    // create the extent of the path
    extent.X = Pawn.GetCollisionRadius();
    extent.Y = Pawn.GetCollisionRadius();
    extent.Z = 1.f;

    // check for line of sight -- just see if there's anything. no need to loop
    if (!FastTrace(loc, Pawn.Location, extent)){
        `log("No line of site...");
        return false;
    }

    /* check for specific actors if necessary - TBI
    foreach TraceActors(class'Actor', actorHit, hitNormal, loc, Pawn.Location, extent){

        // can't walk through towers
        if (WiPTower(actorHit) != None){
            return false;
        }
    }
    */

    return true;
}

function bool isWithinAttackingAngle(Actor target){

    local Vector currentEnemyLocation, pawnLocation;
    // if the current enemy or pawn is invalid, no
    if (currentEnemy == none || cachedPawn == none) return false;
    
    // ignore z-axis
    currentEnemyLocation = currentEnemy.Location;
    currentEnemyLocation.z = 0.f;

    // ignore the z-axis 
    pawnLocation = Pawn.Location;
    pawnLocation.z = 0.f;

    return Vector(Pawn.Rotation) dot Normal(currentEnemyLocation - pawnLocation) >= cachedPawn.weaponFireMode.getAttackingAngle();


}

function bool isWithinAttackingRange(Actor target){


    // if the current enemy or pawn is invalid, no
    if (currentEnemy == none || cachedPawn == none) return false;

    // return true if the current enemy is touching the weapon range trigger
    return cachedPawn.weaponRangeTrigger.Touching.Find(target) != INDEX_NONE;
}

/*****************************************************************
*   State - AttackingEnemy (After pawn has "seen" target)        *
******************************************************************/

state AttackingEnemy{
    
    // executed whever the controller needs to update
    function Tick(float DeltaTime)
	{
		local Vector CurrentDestinationPosition;

		Global.Tick(DeltaTime);

		// Set the focal point if I can see the enemy pawn
		if (FastTrace(currentEnemy.Location, Pawn.Location))
		{
			SetFocalPoint(currentEnemy.Location);
		}
		// Look towards where I am moving
		else
		{
			SetFocalPoint(GetDestinationPosition() + Normal(GetDestinationPosition() - Pawn.Location) * 64.f);
		}

		// Adjust the destination position height to match the pawn height so that ReachedDestination succeeds
		CurrentDestinationPosition = GetDestinationPosition();
		CurrentDestinationPosition.Z = Pawn.Location.Z;
		SetDestinationPosition(CurrentDestinationPosition);
	}

Begin:
    
    // check if the pawn is valid
    if (Pawn == none) Goto('End');
    
CanAttackCurrentEnemy:

    // check if we can attack the current enemy
    if (currentEnemyAttackInterface != none && !currentEnemyAttackInterface.isValidToAttack()){
        ClearCurrentEnemy();
        Goto('End');
    }
    
    // check if currentEnemy is within attacking range
    else if (isWithinAttackingRange(currentEnemy)){
        
        // check if currentEnemy is within attacking angle
        if (isWithingAttackingAngle(currentEnemy)){
            if (!Pawn.isFiring()){
                Pawn.StartFire(0);                
            }
        }
        
    }



}



defaultproperties{}