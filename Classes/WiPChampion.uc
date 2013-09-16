class WiPChampion extends WiPPawn
    implements (WiPAttackable);

// the default melee weapon archetype
var(Weapon) const archetype WiPChampion_MeleeWeapon DefaultMeleeWeaponArchetype;
// the default melee weapon archetype
var(Weapon) const archetype WiPChampion_RangedWeapon DefaultRangedWeaponArchetype;
// an array of this champions abilities
var(Champion) archetype array<WiPAbility>  Abilities;
// the spell currently activated by the champion
var WiPAbility activatedAbility;


simulated event PostBeginPlay(){

    super.PostBeginPlay();

    // Only the server needs to spawn the AIController which is used for pathing
	if (Role == Role_Authority)
	{
		SpawnDefaultController();
	}

	currentHealth = BaseHealth;


}

// called when the pawn dies (assign a new respawn time)
function bool Died(Controller Killer, class<DamageType> DamageType, vector HitLocation){
    local WiPChampionReplicationInfo champRepInfo;
    local WiPPlayerReplicationInfo playerRepInfo;


    // get replication information
    champRepInfo = WiPChampionReplicationinfo(PlayerReplicationInfo);
    if (champRepInfo != none) {

        playerRepInfo = WiPPlayerReplicationInfo(champRepInfo.PlayerReplicationInfo);
        if (playerRepInfo != none){

            playerRepInfo.NextRespawnTime = WorldInfo.TimeSeconds + 15.f + (champRepInfo.Level * 5.f);
            `log("player respawn time ============ " @ playerRepInfo.NextRespawnTime );
        }
    }

    return Super.Died(Killer, DamageType, HitLocation);

}

// add the default weapon
function AddDefaultInventory(){

    local WiPInventoryManager wipInvManager;

    // add the default weapon for the champion to handle white damage
    wipInvManager = WiPInventoryManager(InvManager);
    if (wipInvManager != none){
        //wipInvManager.CreateInventoryByArchetype(defaultMeleeWeaponArchetype, false);
        wipInvManager.CreateInventoryByArchetype(defaultRangedWeaponArchetype, false);

    }
}

// return attacking rate
function float getAttackingRate(){
    return 0.1f;
}


simulated function float AbilityTargetCenterFromRot(byte slot){

    local vector	POVLoc;
	local rotator	POVRot;
    local float fracAngle, maxRange;

    maxRange = Abilities[slot].GetRange();


	if( Controller != None)
	{
		Controller.GetPlayerViewPoint(POVLoc, POVRot);
	}

    fracAngle = POVRot.Pitch/65536.f;

    // if we are aiming in the first quadrant, return max range
    if (fracAngle > 0 && fracAngle < 0.25f)
       return maxRange;
    
    // if we are aiming in the 4th quadrant, return the correct range
    if (fracAngle > 0.75 && fracAngle < 1){
       return 10;
    }

    return 0;
}


simulated function ActivateSpell(byte slot){

    `log("Activated Spell at Slot " @ slot);

    activatedAbility = Abilities[slot];

    GoToState('ActiveAbility');
}

// return the team number of this pawn
simulated function byte GetTeamNum(){

    return 0;
}

/*****************************************************************
*   Interface - WiPAttackble                                     *
******************************************************************/

// return the actor implimenting this interface
simulated function Actor getActor(){
    return self;
}

// return the amount of white damage (auto attacks)
simulated function int getWhiteDamage(){
    return BaseAttackDamage;
}

// return the actors attacking priority - lower than creeps
simulated function int getAttackPriority(Actor Attacker){
    return 5;
}

// return the damage type for white damage
simulated function class<DamageType> GetDamageType(){
    return PawnDamageType;
}

// need to impliment
simulated function GetWeaponFiringLocationAndRotation(out Vector FireLocation, out Rotator FireRotation){

    local vector newLoc;
    
    newLoc = Location;
    newLoc.Z = 10;

    FireLocation = newLoc;
	FireRotation = Rotation;
}

/*****************************************************************
*   State - Active Ability                                       *
******************************************************************/

state ActiveAbility{

    // called when the state is first entered
    function BeginState(Name PreviousStateName){

        `log("Activated an ability = " @ activatedAbility );

    }

    // overwrite so that click casts the weapon
    simulated function StartFire(byte FireModeNum){
        `log("Casted an ability");
        GoToState('');
    }
}



defaultProperties
{

	RewardRange = 2000.f
    BaseHealth = 150.f
    BaseAttackDamage = 50
	BaseAttackTime = 2.f
	PawnDamageType = class'DamageType'
    ControllerClass = class'WiPChampionController'
    ExperienceToGiveOnKill = 200
    MoneyToGiveOnKill = 400
    LastHitMultiplier = 1.2

    DefaultMeleeWeaponArchetype = WiPChampion_MeleeWeapon'WiP_ASSETS.Archetypes.DefaultChampionMeleeWeapon'
    DefaultRangedWeaponArchetype = WiPChampion_RangedWeapon'WiP_ASSETS.Archetypes.DefaultChampionRangedWeapon'
}