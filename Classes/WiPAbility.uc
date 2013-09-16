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
var RepNotify int level;
// the mana costs of the spell
var(Ability) const array<float> ResourceCosts;
// the damage of the spell (before modifiers)
var(Ability) const array<float> Damages;
// the max range of the spell
var(Ability) const array<float> MaxRanges;
// the damage multipliers (a percentage of ability power)
var(Ability) const array<float> Multipliers;
// the particle system associated with this ability
var (Ability) const ParticleSystem AbilityParticleSystem;

var WiPChampion caster;

// associated effects replication info
var RepNotify RepAbilityEffects AbilityEffectsReplicated;

var RepNotify bool test;

//  replication block - used to spawn the particle system across the network
replication
{

    // Whenever changed on the server
    if (bNetDirty)
       AbilityEffectsReplicated, test;
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
    `log("called cast");
    // only castable on the server
    if (source == none) return;

    caster = source;
    if (Role < ROLE_Authority)  {
       return;
    }

    SpawnEffects(HitLocation);
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