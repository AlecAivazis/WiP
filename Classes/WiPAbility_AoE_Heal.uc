class WiPAbility_AoE_Heal extends WiPAbility_AoE;

// the amount that this spell heals for
var(Ability) const array<float> HealAmount;

// wether or not to target the caster
var(Ability) const bool targetSelf;

// return the amount that this spell heals for
simulated function float GetHealAmount(){
  return HealAmount[Level-1];
}


// perform the actual cast of the ability
simulated function cast(WiPChampion source, vector HitLocation){
    local WiPAttackable target;
    local array<WiPAttackable> teamHit;

    `log("called cast");
    // only castable on the server
    if (source == none) return;

    caster = source;
    if (Role < ROLE_Authority)  {
       return;
    }

    teamHit = GetEnemiesHit(HitLocation);

    foreach teamHit(target){
    
       if (target == caster && !targetSelf) continue;

       WiPPawn(target).HealDamage(GetHealAmount(), Caster.Controller , MyDamageType);
    }

    SpawnEffects(caster.Location);
    startCooldown();
    `log("Current mana " @ source.Mana);
}


simulated function array<WiPAttackable> GetEnemiesHit(Vector HitLocation){

    local array<WiPAttackable> teamHit;
    local WiPPawn target;

    // loop over each WiPAttackable in a circle
    // with radius GetRadius(),  centered about HitLocation
    foreach CollidingActors(class'WiPPawn', target, GetRadius(), HitLocation, true,  class'WiPAttackable'){

        // if its on the same team as the caster
        // and is valid to attack
        if (target.GetTeamNum() == caster.GetTeamNum() && target.IsValidToAttack()){

            teamHit.AddItem(target);
           `log("Added " @ target @ " to the AoE team list...");
        }
    }
    
    return teamHit;
};


defaultproperties
{
    MyDamageType=class'UTDmgType_Rocket'
    targetSelf = true
}