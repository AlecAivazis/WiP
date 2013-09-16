class WiPSpell extends Object;

// the current level of the spell
var RepNotify int level;
// the mana costs of the spell
var(Spell) const array<float> ManaCosts;
// the damage of the spell (before modifiers)
var(Spell) const array<float> Damages;
// the damage multipliers (a percentage of ability power)
var(Spell) const array<float> Multipliers;



defaultproperties
{}