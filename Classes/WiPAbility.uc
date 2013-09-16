class WiPAbility extends Object;

// the current level of the spell
var RepNotify int level;
// the mana costs of the spell
var(Ability) const array<float> ResourceCosts;
// the damage of the spell (before modifiers)
var(Ability) const array<float> Damages;
// the max range of the spell
var(Ability) const array<float> MaxRanges;
// the damage multipliers (a percentage of ability power)
var(Ability) const array<float> Multipliers;


simulated function float GetRange(){
    if (Level > 0)
       return MaxRanges[Level-1];
    else
        return 0;
}


defaultproperties
{
     Level =1
}