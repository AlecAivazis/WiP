class WiPNeutralPawn
    extends WiPPawn
    implements(WiPAttackable);



// weapon range trigger
var ProtectedWrite WiPTrigger weaponRangeTrigger;
// Weapon fire mode
var(Weapon) const editinline instanced WiPWeaponFireMode WeaponFireMode;

simulated event PostBeginPlay(){

    Super.PostBeginPlay();

    // set weapon range detector
    if (WeaponFireMode != none){

        WeaponFireMode.SetOwner(self);

        weaponRangeTrigger = Spawn(class'WiPTrigger',,,Location);
        if (weaponRangeTrigger != none){

            // attack the trigger to the pawn
            weaponRangeTrigger.SetBase(self);

            if (weaponRangeTrigger != none){
                weaponRangeTrigger.triggerCollisionComponent.SetCylinderSize(WeaponRange - GetCollisionRadius(), 64.f);
            }

        }
    }

    // set the health float
    currentHealth = float(Health);
}

simulated function int GetAttackPriority(Actor Attacker)
{
	return 10;
}


function Actor getActor(){
    return self;
}

// get the white damage done by this pawn
function int getWhiteDamage(){
    return BaseAttackDamage;
}


// return the currentEnemy
simulated function Actor getEnemy(){

    local WiPAIController aiController;

    aiController = WiPAIController(Controller);
    if (aiController != none) return aiController.currentEnemy;
    return none;
}

// return true if the pawn is firing
function bool isFiring(){
    if (WeaponFireMode != none){
        return WeaponFireMode.isFiring();
    }

    return false;
}

// get the type of damage this pawn does as white damage
simulated function class<DamageType> GetDamageType(){
	return PawnDamageType;
}

// start attacking the current enemy
simulated function startFire(byte FireModeNum){
    if (weaponFireMode != none) WeaponFireMode.startFire();
}

function bool Died(Controller Killer, class<DamageType> DamageType, vector HitLocation){

    local WiPPlayerController playerController;
    local WiPPlayerReplicationInfo playerRepInfo;


    `log("This pawn has died" @ self);

    // reward a last hit to the killer
    if (WiPPlayerController(Killer) != none){
        // grab the killer's controller
        //killerController = WiPChampionController(Killer);

        playerController = WiPPlayerController(Killer);
        playerRepInfo = WiPPlayerReplicationInfo(playerController.PlayerReplicationInfo);
        if (playerRepInfo != none){

            // give the player a last hit and
            playerRepInfo.lastHits++;
           // `log("You got a last hit. Current amount " @ playerRepInfo.lastHits);

        }
    }
    
    // Tell the inventory manager
    if (InvManager != none)    InvManager.OwnerDied();
    // Detach controller
	DetachFromController(true);
	// Destroy the weapon fire
	if (WeaponFireMode != none)    WeaponFireMode.Destroy();
	// Destroy the weapon range trigger
	if (WeaponRangeTrigger != none) WeaponRangeTrigger.Destroy();

	bReplicateMovement = false;
	bTearOff = true;
	Velocity += TearOffMomentum;

	BeginRagdoll();
	LifeSpan = 1.f;
	
    return Super.Died(Killer, DamageType, HitLocation);
}


// return teamIndex
simulated function byte GetTeamNum(){
    if (WiPCreepPawn(self)!=none){
        return WiPCreepPawn(self).Factory.getTeamNum();
    }

    return 3;
}

// change the location/rotation of the projectil to that of the weapon
simulated function GetWeaponFiringLocationAndRotation(out Vector FireLocation, out Rotator FireRotation){
	local Actor currentEnemy;
	currentEnemy = GetEnemy();
	
	/*

	// Grab the skeletal mesh component, abort if it doesn't exist
	if (WeaponSkeletalMesh == None || WeaponSkeletalMesh.SkeletalMesh == None){
		return;
	}

	// Check that FiringSocketName is a valid name of a socket
	if (WeaponSkeletalMesh.GetSocketByName(WeaponFiringSocketName) == None){
		return;
	}

	// Get the current enemy, abort if there is no current enemy
	currentEnemy = GetEnemy();
	if (CurrentEnemy == None){
		return;
	}

	// Grab the world socket location and rotation and forward this to begin fire
	WeaponSkeletalMesh.GetSocketWorldLocationAndRotation(WeaponFiringSocketName, FireLocation, FireRotation);

	*/

	FireLocation = Location;
	FireRotation = Rotator(CurrentEnemy.Location - FireLocation);

}




defaultproperties
{
	BaseAttackSpeed=1.f
	SightRange=500.f
	PawnDamageType=class'DamageType'
	BaseAttackDamage=2.f
	RewardRange = 2000.f
	ExperienceToGiveOnKill = 50
	MoneyToGiveOnKill = 25
	LastHitMultiplier = 1.5
    BaseHealthRegen =0
    BaseMaxHealth = 20
}