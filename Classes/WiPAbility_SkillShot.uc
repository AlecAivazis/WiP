class WiPAbility_SkillShot extends WiPAbility;


// this skill shots  projectile class
var(Ability) archetype  const WiPAbility_SkillShot_Projectile AbilityProjectile;

// perform the actual cast of the ability
simulated function PerformAbility(vector HitLocation, rotator HitRotation){

    local WiPAbility_SkillShot_Projectile shot;

    shot = Spawn(AbilityProjectile.class,,,caster.Location,,AbilityProjectile);

    shot.Ability = self;
    shot.init(HitLocation-caster.Location);

    AbilityEffectsReplicated.VHitLocation = caster.Location;
    AbilityEffectsReplicated.RHitRotation = caster.Rotation;
}


defaultproperties
{
}