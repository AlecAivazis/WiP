class WiPWeaponProjectileFireMode extends WiPWeaponFireMode;

// Archetype of the projectile to use
var(FireMode) const WiPProjectile ProjectileArchetype;

protected function BeginFire(Vector FireLocation, Rotator FireRotation, Actor Enemy){

    local WiPProjectile SpawnedProjectile;
	local WiPNeutralPawn NeutralPawn;


	// Only spawn the projectile on the server
	if (WeaponOwner.GetActor().Role == ROLE_Authority)
	{
		// Spawn projectile
		SpawnedProjectile = WeaponOwner.GetActor().Spawn(ProjectileArchetype.Class,,, FireLocation, FireRotation, ProjectileArchetype);
		if (SpawnedProjectile != None && !SpawnedProjectile.bDeleteMe)
		{
			// Set the weapon owner
			SpawnedProjectile.OwnerAttackInterface = WeaponOwner;
			// Set the enemy
			SpawnedProjectile.Enemy = Enemy;
			// Initialize the projectile
			SpawnedProjectile.Init(Vector(FireRotation));

			SpawnedProjectile.Damage = WeaponOwner.GetWhiteDamage();
			SpawnedProjectile.DamageType = WeaponOwner.GetDamageType();

			neutralPawn = WiPNeutralPawn(WeaponOwner);
			if (neutralPawn != None)
			{
				NeutralPawn.ModifyDamage(SpawnedProjectile.Damage, SpawnedProjectile.DamageType);
			}
		}
	}
}


defaultproperties
{}