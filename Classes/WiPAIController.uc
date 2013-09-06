class WiPAIController extends AIController;

event Possess(Pawn inPawn, bool bVehicleTransition)
{
    Super.Possess(inPawn, bVehicleTransition);
	inPawn.SetMovementPhysics();
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



/*****************************************************************
*   State - AttackingEnemy                                       *
******************************************************************/




defaultproperties{}