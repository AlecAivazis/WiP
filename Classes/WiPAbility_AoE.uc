class WiPAbility_AoE extends WiPAbility;

// the particle system associated with this ability
var(Ability) const ParticleSystem AbilityParticleSystem;
// the radius of the AoE at various levels
var(Ability) const array<float> Radius;
// wether or not the AoE should affect the caster
var(Ability) bool TargetCaster;

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
        AbilityEffectsReplicated.VHitLocation = HitLocation;
        AbilityEffectsReplicated.RHitRotation = caster.Rotation;
        `log("setting new values for AbilityEffectsReplicated.");
    }
}

// can be overwritten in subclasses for different shapes of AoE
simulated function array<WiPAttackable> GetEnemiesHit(Vector HitLocation){

    local array<WiPAttackable> targetsHit;
    local WiPPawn target;

    // loop over each WiPAttackable in a circle
    // with radius GetRadius(),  centered about HitLocation
    foreach CollidingActors(class'WiPPawn', target, GetRadius(), HitLocation, true,  class'WiPAttackable'){

        if (((!Friendly && (target.GetTeamNum() != caster.GetTeamNum())) || (Friendly && (target.GetTeamNum() == caster.GetTeamNum()))) && target.IsValidToAttack()){
           targetsHit.AddItem(target);
           `log("Added " @ target @ " to the AoE target list...");
        }
    }

    return targetsHit;
};


defaultproperties
{
     AbilityParticleSystem = ParticleSystem'WP_RocketLauncher.Effects.P_WP_RocketLauncher_RocketTrail'
     MyDamageType=class'UTDmgType_Rocket'
     MomentumTransfer = 0
     Friendly = false
     TargetCaster = false
}