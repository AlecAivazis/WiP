class WiPAbility_AoE_Heal extends WiPAbility_AoE;

// the amount that this spell heals for
var(Ability) const array<float> HealAmount;

// return the amount that this spell heals for
simulated function float GetHealAmount(){
          return HealAmount[Level-1];
}


simulated function PerformAbility(vector HitLocation, Rotator HitRotation){
    local WiPAttackable target;
    local array<WiPAttackable> teamHit;

    teamHit = GetEnemiesHit(HitLocation);

    foreach teamHit(target){

       if (target == caster && !TargetCaster) continue;

       WiPPawn(target).HealDamage(GetHealAmount(), Caster.Controller , MyDamageType);
    }

    SpawnEffects(caster.Location);
}

defaultproperties
{
    Friendly = true
    TargetCaster = true
}