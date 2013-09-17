class WiPAbility_AoE_Debuff extends WiPAbility_AoE;

// the time over which this DoT occurs
var(Ability) const array<float> duration;
// the time in between ticks
var(Ability) const array<float> tickTime;

defaultproperties
{
}