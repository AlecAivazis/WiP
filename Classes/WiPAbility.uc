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
// the particle system associated with this ability
var(Ability) const ParticleSystem AbilityParticleSystem;

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

// called when a RepNotify variable is changed
simulated event ReplicatedEvent(name VarName){

    `log("There was a replication: " @ VarName);

    if (VarName == 'AbilityEffectsReplicated'){

       if (AbilityEffectsReplicated.AbilityParticleSystem != none){

          `log("Replicating the emitter: " @ AbilityEffectsReplicated.AbilityParticleSystem @ " At: " @ AbilityEffectsReplicated.VHitLocation);
          WorldInfo.MyEmitterPool.SpawnEmitter(AbilityEffectsReplicated.AbilityParticleSystem, AbilityEffectsReplicated.VHitLocation, AbilityEffectsReplicated.RHitRotation);
        }

    } else
        Super.ReplicatedEvent(VarName);
}


// return the range of the ability
simulated function float GetRange(){
    if (Level > 0)
       return MaxRanges[Level-1];
    else
        return 0;
}


// perform the actual cast of the ability
simulated function cast(WiPChampion source, vector HitLocation){
    
    local WiPAbility_SkillShotProjectile shot;

    `log("called cast");
    // only castable on the server
    if (source == none) return;

    caster = source;
    if (Role < ROLE_Authority)  {
       return;
    }

    shot = Spawn(class'WiPAbility_SkillShotProjectile', self,, caster.Location);
    shot.Ability = self;
    shot.init(HitLocation - caster.Location);

    //SpawnEffects(HitLocation);
    startCooldown();
}

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
}


// run on the server to set up emitter replication info
function SpawnEffects(Vector HitLocation){
    `log("Spawning effects!");

    if(AbilityParticleSystem != none){

        `Log("Spawning emitter: " @ AbilityParticleSystem @ " At: " @ HitLocation);
        WorldInfo.MyEmitterPool.SpawnEmitter(AbilityParticleSystem, HitLocation, Rotation);
        AbilityEffectsReplicated.AbilityParticleSystem = AbilityParticleSystem;
        AbilityEffectsReplicated.VHitLocation = HitLocation;
        AbilityEffectsReplicated.RHitRotation = Rotation; 
        `log("setting new values for AbilityEffectsReplicated.");
    }
}

defaultproperties
{
     Level =1
     AbilityParticleSystem = ParticleSystem'WP_RocketLauncher.Effects.P_WP_RocketLauncher_RocketTrail'
}