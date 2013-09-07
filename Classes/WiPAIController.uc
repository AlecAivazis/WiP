class WiPAIController extends AIController;

// the current enemy
var PrivateWrite Actor currentEnemy;
// the current enemy's attack interface
var PrivateWrite WiPAttackable currentEnemyAttackInterface;
// cached version of Pawn
var PrivateWrite WiPNeutralPawn cachedPawn;

// final destination of a move
var ProtectedWrite vector finalDestination;
// final destination of a move
var ProtectedWrite vector nextMoveLocation;
// final destination of a move
var ProtectedWrite vector adjustedNextMoveLocation;
// Last enemy location
var PrivateWrite Vector lastEnemyLocation;
// Last evaluated attacking location
var PrivateWrite Vector lastEvaluatedAttackingLocation;



// calle when controlled is initialized
event PostBeginPlay()
{
	Super(Actor).PostBeginPlay();

	if (!bDeleteMe && WorldInfo.NetMode != NM_Client)
	{
		// create a new player replication info
		InitPlayerReplicationInfo();
		InitNavigationHandle();

	}

	// have tested - after this call AIController IS a WiPPRI
}

// called when controller possesses a pawn
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


// set defeault replication info to WiP's Pawn Rep Info class
function InitPlayerReplicationInfo()
{
	PlayerReplicationInfo = Spawn(class'WiPPawnReplicationInfo', Self);
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

// return if the target is within the attacking angle
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

// return if the target is within range
function bool isWithinAttackingRange(Actor target){


    // if the current enemy or pawn is invalid, no
    if (currentEnemy == none || cachedPawn == none) return false;

    // return true if the current enemy is touching the weapon range trigger
    return cachedPawn.weaponRangeTrigger.Touching.Find(target) != INDEX_NONE;
}

function findBestAttackingDestination(){
    
    local int i, Slices, Slice;
	local Rotator R;
	local Vector V, SpotLocation, HitLocation, HitNormal, BestAttackingLocation;
	local Actor HitActor;
	local array<Vector> PotentialAttackingLocations;
	local float	BestRating, Rating;
    
    // early exit if we dont have well defined values
    if (currentEnemy == none || Pawn == none || cachedPawn == none || cachedPawn.WeaponFireMode == none || cachedPawn.WeaponRangeTrigger == none){
       `log("Could not find best attack destination (there was a null pointer)");

       return;
    }

    // check if thet LastEnemyLocation hasn't changed much
    if (VSizeSq(lastEnemyLocation - currentEnemy.Location) < 4096.f){

        //set the destination position
        SetDestinationPosition(lastEvaluatedAttackingLocation);
        // set the final destination
        finalDestination = lastEvaluatedAttackingLocation;
        return;
    }   

    if (isWithinAttackingRange(currentEnemy)){
        return;
    }
    
    // update enemy location
    lastEnemyLocation = currentEnemy.Location;

    //generate the possible attacking locations
    Slices = 16;
	Slice = 65536 / Slices;
	R = Rot(0, 0, 0);

	for (i = 0; i < Slices; ++i){
    
        V = currentEnemy.Location + Vector(R) * cachedPawn.weaponRangeTrigger.triggerCollisionComponent.CollisionRadius;
        
        SpotLocation = V;
        if(FindSpot(Pawn.GetCollisionExtent(), SpotLocation)){
            V = SpotLocation;
        }
        
        foreach TraceActors(class'Actor', HitActor, HitLocation, HitNormal, V-Vect(0.f, 0.f, 16384.f), V){

            if (HitActor.bWorldGeometry){

                // adjust the location to represent if the pawn was actually there
                V = HitLocation+Vect(0.f, 0.f, 1.f)*Pawn.GetCollisionHeight();
                
                foreach TraceActors(class'Actor', HitActor, HitLocation, HitNormal, currentEnemy.Location, V){
                    // trace will hit the enemy
                    if (HitActor == currentEnemy) PotentialAttackingLocations.AddItem(V);
                    // something was in the way
                    else if (HitActor.bWorldGeometry || WiPPawn(HitActor) != none){
                        break;
                    }
                }

                break;
            }

        }
        R.Yaw +=Slice;
    }

    // Also add a "staight" attacking position
    V = currentEnemy.Location + Normal(currentEnemy.Location - cachedPawn.Location) * cachedPawn.weaponRangeTrigger.triggerCollisionComponent.CollisionRadius;
    foreach TraceActors(class'Actor', HitActor, HitLocation, HitNormal, V-Vect(0.f, 0.f, 16384.f), V){
        if (HitActor.bWorldGeometry){

            // adjust the location to represent if the pawn was actually there
            V = HitLocation+Vect(0.f, 0.f, 1.f)*Pawn.GetCollisionHeight();

            foreach TraceActors(class'Actor', HitActor, HitLocation, HitNormal, currentEnemy.Location, V){
                // trace will hit the enemy
                if (HitActor == currentEnemy) PotentialAttackingLocations.AddItem(V);
                // something was in the way
                else if (HitActor.bWorldGeometry || WiPPawn(HitActor) != none){
                    break;
                }
            }

            break;
        }

    }

    if (PotentialAttackingLocations.Length > 0)
	{
		BestRating = 65536.f;
		for (i = 0; i < PotentialAttackingLocations.Length; ++i)
		{
			Rating = VSizeSq(PotentialAttackingLocations[i] - Pawn.Location);
			if (IsZero(BestAttackingLocation) || Rating < BestRating)
			{
				BestAttackingLocation = PotentialAttackingLocations[i];
				Rating = BestRating;
			}
		}

		// Check if we need to find a spot which the pawn can move to
		SpotLocation = BestAttackingLocation;
		if (FindSpot(Pawn.GetCollisionExtent(), SpotLocation))
		{
			BestAttackingLocation = SpotLocation;
		}

		// Set the last evaluated attacking location
		LastEvaluatedAttackingLocation = BestAttackingLocation;
		// Set the destination position
		SetDestinationPosition(BestAttackingLocation);
		// Set the final destination
		finalDestination = BestAttackingLocation;
		// Set the focal point
		SetFocalPoint(GetDestinationPosition() + Normal(GetDestinationPosition() - Pawn.Location) * 64.f);
     }
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
        if (isWithinAttackingAngle(currentEnemy)){
            if (!cachedPawn.isFiring()) cachedPawn.startFire(0);
        } else {
            if (cachedPawn.isFiring()) cachedPawn.stopFire(0);
        }

        bPreciseDestination = false;
        
        // in range by not within angle of attack - wait
        Sleep(0.f);
        Goto('CanAttackCurretEnemy');
    }
    
EvaluateBestAttackingPosition:





}



defaultproperties{}