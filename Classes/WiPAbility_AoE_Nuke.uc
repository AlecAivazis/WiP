class WiPAbility_AoE_Nuke extends WiPAbility_AoE;

simulated function PerformAbility(vector HitLocation, Rotator HitRotation){
    local WiPAttackable target;
    local float abilityDamage;
    local array<WiPAttackable> enemiesHit;

    enemiesHit = GetEnemiesHit(HitLocation);

    abilityDamage = GetDamage();

    foreach enemiesHit(target){
            WiPPawn(target).TakeDamage(abilityDamage, Caster.Controller , HitLocation, MomentumTransfer * vect(0,0,0), MyDamageType,, self);
    }

    SpawnEffects(HitLocation, caster.Rotation);
}

defaultproperties
{
}