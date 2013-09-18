class WiPStatModifier extends Object;

// stat name definitions
enum EStat {
     STAT_Damage,
     STAT_MaxHealth,
     STAT_Health, // used to filter out debuffs that deal dmg (DoTs)
     STAT_AttackSpeed,
     STAT_AbilityPower,
     STAT_HealthRegen,
     STAT_MaxMana,
     STAT_ManaRegen,
};

enum EBuffOperation
{
	Operation_Multiplication<DisplayName=Multiplication>,
	Operation_Addition<DisplayName=Addition>,
};


struct StatChange
{
	var(StatChange) EStat Stat;
	var(StatChange) float Amount;
	var(StatChange) EBuffOperation Operation;
};




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