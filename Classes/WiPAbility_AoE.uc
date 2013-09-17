class WiPAbility_AoE extends WiPAbility;

// the particle system associated with this ability
var(Ability) const ParticleSystem AbilityParticleSystem;


// called when a RepNotify variable is changed
simulated event ReplicatedEvent(name VarName){

    `log("There was a replication: " @ VarName);

    if (VarName == 'AbilityEffectsReplicated'){

       if (AbilityEffectsReplicated.AbilityParticleSystem != none){

          `log("Replicating the emitter: " @ AbilityEffectsReplicated.AbilityParticleSystem @ " At: " @ AbilityEffectsReplicated.VHitLocation);
          WorldInfo.MyEmitterPool.SpawnEmitter(AbilityEffectsReplicated.AbilityParticleSystem, AbilityEffectsReplicated.VHitLocation);
        }

    } else
        Super.ReplicatedEvent(VarName);
}

// perform the actual cast of the ability
simulated function cast(WiPChampion source, vector HitLocation){

    local array<WiPAttackable> enemiesHit;

    `log("called cast");
    // only castable on the server
    if (source == none) return;

    caster = source;
    if (Role < ROLE_Authority)  {
       return;
    }

    enemiesHit = GetEnemiesHit(HitLocation);

    SpawnEffects(HitLocation);
    startCooldown();
    `log("Current mana " @ source.Mana);
}


// run on the server to set up emitter replication info
function SpawnEffects(Vector HitLocation){
    `log("Spawning effects!");

    if(AbilityParticleSystem != none){

        `Log("Spawning emitter: " @ AbilityParticleSystem @ " At: " @ HitLocation);
        WorldInfo.MyEmitterPool.SpawnEmitter(AbilityParticleSystem, HitLocation,);
        AbilityEffectsReplicated.AbilityParticleSystem = AbilityParticleSystem;
        AbilityEffectsReplicated.VHitLocation = HitLocation;
        AbilityEffectsReplicated.VHitRotation = caster.Location - HitLocation; 
        `log("setting new values for AbilityEffectsReplicated.");
    }
}

function array<WiPAttackable> GetEnemiesHit(Vector HitLocation);


defaultproperties
{
     AbilityParticleSystem = ParticleSystem'WP_RocketLauncher.Effects.P_WP_RocketLauncher_RocketTrail'
}