// An interface that should be implimented if the actor can attack things
// as well as be attacked

interface WiPAttackable;

/*
// return the current health
simulated function float getHealth();

// return the maximum health
simulated function float getMaxHealth();

// return the amount of white damage (auto attacks)
simulated function int getWhiteDamage();

// return the damage type for white damage
simulated function class<DamageType> GetDamageType();

*/

// return if the actor is still valid to attack
simulated function bool isValidToAttack();