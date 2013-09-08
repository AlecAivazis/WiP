// An interface that should be implimented if the actor can attack things
// as well as be attacked

interface WiPAttackable;

/*
// return the current health
simulated function float getHealth();

// return the maximum health
simulated function float getMaxHealth();

*/

// Returns the weapon firing location and rotation
simulated function GetWeaponFiringLocationAndRotation(out Vector FireLocation, out Rotator FireRotation);

// return the damage type for white damage
simulated function class<DamageType> GetDamageType();

// return the amount of white damage (auto attacks)
simulated function int getWhiteDamage();

// return the team numbers
simulated function byte GetTeamNum();

simulated function int getAttackPriority(Actor Attacker);

// return the actor implimenting this interface
simulated function Actor getActor();

// return if the actor is still valid to attack
simulated function bool isValidToAttack();