class WiPAbility_AoE extends WiPAbility;

// the particle system associated with this ability
var(Ability) const ParticleSystem AbilityParticleSystem;
// the radius of the AoE at various levels
var(Ability) const array<float> Radius;


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

// perform the actual cast of the ability
simulated function cast(WiPChampion source, vector HitLocation){
    local WiPAttackable target;
    local array<WiPAttackable> enemiesHit;
    local float abilityDamage;

    `log("called cast");
    // only castable on the server
    if (source == none) return;

    caster = source;
    if (Role < ROLE_Authority)  {
       return;
    }

    enemiesHit = GetEnemiesHit(HitLocation);

    abilityDamage = GetDamage();

    foreach enemiesHit(target){
            WiPPawn(target).TakeDamage(abilityDamage, Caster.Controller , HitLocation, MomentumTransfer * vect(0,0,0), MyDamageType,, self);
    }

    SpawnEffects(HitLocation);
    startCooldown();
    `log("Current mana " @ source.Mana);
}


// return the AoE radius of the spell
simulated function float GetRadius(){
    return Radius[Level-1];
}


// run on the server to set up emitter replication info
function SpawnEffects(Vector HitLocation){
    `log("Spawning effects!");

    if(AbilityParticleSystem != none){

        `Log("Spawning emitter: " @ AbilityParticleSystem @ " At: " @ HitLocation);
        WorldInfo.MyEmitterPool.SpawnEmitter(AbilityParticleSystem, HitLocation, Rotation);
        AbilityEffectsReplicated.AbilityParticleSystem = AbilityParticleSystem;
        AbilityEffectsReplicated.VHitLocation = HitLocation;
        AbilityEffectsReplicated.RHitRotation = caster.Rotation;
        `log("setting new values for AbilityEffectsReplicated.");
    }
}

// can be overwritten in subclasses for different shapes of AoE
simulated function array<WiPAttackable> GetEnemiesHit(Vector HitLocation){

    local array<WiPAttackable> enemiesHit;
    local WiPPawn target;

    // loop over each WiPAttackable in a circle
    // with radius GetRadius(),  centered about HitLocation
    foreach CollidingActors(class'WiPPawn', target, GetRadius(), HitLocation, true,  class'WiPAttackable'){

        // if its on the opposite team and the caster
        // and is valid to attack
        if (target.GetTeamNum() != caster.GetTeamNum() && target.IsValidToAttack()){
           enemiesHit.AddItem(target);
           `log("Added " @ target @ " to the AoE enemies list...");
        }
    }
    
    return enemiesHit;
};


defaultproperties
{
     AbilityParticleSystem = ParticleSystem'WP_RocketLauncher.Effects.P_WP_RocketLauncher_RocketTrail'
     MyDamageType=class'UTDmgType_Rocket'
     MomentumTransfer = 0
}