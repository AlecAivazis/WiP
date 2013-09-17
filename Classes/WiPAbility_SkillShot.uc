class WiPAbility_SkillShot extends WiPAbility;

// perform the actual cast of the ability
simulated function cast(WiPChampion source, vector HitLocation){

    local WiPAbility_SkillShot_Projectile shot;

    `log("Hey it worked!");
    `log("called cast");
    // only castable on the server
    if (source == none) return;

    caster = source;
    if (Role < ROLE_Authority)  {
       return;
    }

    shot = Spawn(class'WiPAbility_SkillShot_Projectile', self,, caster.Location);
    shot.Ability = self;
    shot.init(HitLocation - caster.Location);


    startCooldown();
    `log("Current mana " @ source.Mana);
}


defaultproperties
{
}