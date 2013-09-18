class WiPAbility_AoE_Debuff extends WiPAbility_AoE;

// the debuff applied by this ability
var(Ability) archetype const WiPDebuff Debuff;

simulated function PerformAbility(vector HitLocation, Rotator HitRotation){
    local WiPAttackable target;
    local array<WiPAttackable> enemiesHit;
    local WiPDebuff wipDebuff;

    enemiesHit = GetEnemiesHit(HitLocation);


    foreach enemiesHit(target){
        wipDebuff =  Spawn(Debuff.class,,,,,Debuff);
        wipDebuff.Level = Level;
        wipDebuff.Source = self;
        WiPPawn(target).AddDebuff(wipDebuff);
    }

    SpawnEffects(HitLocation);
}

// Debuff spells deal no damage
simulated function float GetDamage(){
    
    return 0;
}

defaultproperties
{
}