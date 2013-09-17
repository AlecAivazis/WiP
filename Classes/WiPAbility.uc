class WiPAbility extends ReplicationInfo;

// struct to handle ability replication
struct RepAbilityEffects
{
	// Emitter to spawn
	var ParticleSystem AbilityParticleSystem;
	// Place to spawn the emitter
	var Vector VHitLocation;
	var Rotator RHitRotation;
};

// the current level of the spell
var int level;
// the mana costs of the spell
var(Ability) const array<float> ResourceCosts;
// the damage of the spell (before modifiers)
var(Ability) const array<float> Damages;
// the max range of the spell
var(Ability) const array<float> MaxRanges;
// the damage multipliers (a percentage of ability power)
var(Ability) const array<float> Multipliers;
// the ability's cooldown
var(Ability) const array<float> Cooldowns;

var WiPChampion caster;

// associated effects replication info
var RepNotify RepAbilityEffects AbilityEffectsReplicated;

//  replication block - used to spawn the particle system across the network
replication
{

    // Whenever changed on the server
    if (bNetDirty)
       AbilityEffectsReplicated;
}



// return the mana cost of the ability
simulated function float GetManaCost(){
     if (Level > 0)
        return ResourceCosts[Level-1];
     else
        return -1;
}

// return if not on cooldown
simulated function bool CanActivate(){
    //`log("time left on cooldown: " @  GetTimerCount(NameOf(CooldownTimer)));
    return !IsTimerActive(NameOf(Cooldowntimer)) && Level > 0;
}

// start the cooldown timer
simulated function startCooldown(){        
    //`log("Setting cooldown" @ Cooldowns[Level-1]);
    SetTimer(Cooldowns[Level-1], false, NameOf(CooldownTimer));
}

// cooldown timer
simulated function CooldownTimer(){
    `log("Resetting cooldown");
}

// return the range of the ability
simulated function float GetRange(){
    if (Level <= 0)
        return 0;

    return MaxRanges[Level-1];
}


// return the appropriate damage given the current level
simulated function float GetDamage(){

    local WiPPawnReplicationInfo pawnRepInfo;

    `log("Instigator = " @ Instigator);
    
    if (Instigator == none){
       `log("Instigator was none (GetDamage - WiPWeaponProjectile)");
       return 50;
    }

    pawnRepInfo =  WiPPawnReplicationInfo(Instigator.PlayerReplicationInfo);

    if (pawnRepInfo == none){
       
       `log("Could not get Pawn Rep Info (GetDamage - WiPWeaponProjectile)");
       return 50;
    }
    
    return Damages[Level-1];
}

// tbi by subclasses
simulated function cast(WiPChampion source, vector HitLocation);


defaultproperties
{
     Level =1
}