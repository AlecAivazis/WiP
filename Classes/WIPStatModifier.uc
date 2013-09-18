class WiPStatModifier extends Object;

// stat name definitions
enum EStat {
     STAT_Damage,
     STAT_MaxHealth,
     STAT_AttackSpeed,
     STAT_AbilityPower,
     STAT_HealthRegen,
     STAT_MaxMana,
     STAT_ManaRegen,
};

// the active debuffs affecting the pawn
var ProtectedWrite array<WiPDebuff> debuffs;


// add a debuff to the list
simulated function AddDebuff(WiPDebuff debuff){
    debuffs.AddItem(debuff);
}

// remove a debuff from the list
simulated function RemoveDebuff(WiPDebuff debuff){
    debuffs.RemoveItem(debuff);
}

simulated function float CalculateStat(EStat stat, float baseValue){
    local float NewValue;
    
  //  `log("calculating stat for " @ stat);

    switch (stat){

        case STAT_AttackSpeed:
            NewValue = baseValue;

        case STAT_Damage:
            NewValue = baseValue;

        case STAT_AbilityPower:
            NewValue = baseValue;

        case STAT_MaxHealth:
            NewValue = baseValue;

        case STAT_HealthRegen:
            NewValue = baseValue;

        case STAT_MaxMana:
            NewValue = baseValue;

        case STAT_ManaRegen:
            NewValue = baseValue;

    }

    return NewValue;
}

defaultproperties
{}