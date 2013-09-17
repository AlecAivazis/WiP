class WiPAbility_SkillShot extends WiPAbility;


// this skill shots  projectile class
var(Ability) archetype  const WiPAbility_SkillShot_Projectile AbilityProjectile;

// called when a RepNotify variable is changed
simulated event ReplicatedEvent(name VarName){
    local WiPAbility_SkillShot_Projectile shot;


    if (VarName == 'AbilityEffectsReplicated'){

       if (AbilityEffectsReplicated.AbilityParticleSystem != none){
          shot = Spawn(class'WiPAbility_SkillShot_Projectile', self,, AbilityEffectsReplicated.VHitLocation);
          shot.Ability = self;
          shot.init(AbilityEffectsReplicated.VHitRotation);
        }

    } else
        Super.ReplicatedEvent(VarName);
}

// perform the actual cast of the ability
simulated function cast(WiPChampion source, vector HitLocation){

    local WiPAbility_SkillShot_Projectile shot;
    local RepAbilityEffects repEffects;

    `log("called cast");
    // only castable on the server
    if (source == none) return;

    caster = source;
    if (Role < ROLE_Authority)  {
       return;
    }

    shot = Spawn(AbilityProjectile.class,,,caster.Location,,AbilityProjectile);

    shot.Ability = self;
    shot.init(HitLocation - caster.Location);

    repEffects.VHitLocation = caster.Location;
    repEffects.VHitRotation = HitLocation - caster.Location;


    startCooldown();
    `log("Current mana " @ source.Mana);
}


defaultproperties
{
}