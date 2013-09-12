class WiPDefaultWeapon extends Weapon;

// cached a typecasted version of owner
var WiPPawn cachedOwner;



simulated function ProcessInstantHit(byte FiringMode, ImpactInfo Impact, optional int NumHits){
    local float damage;
    local WipPawnReplicationInfo pawnRepInfo;
    local WiPPawn target;

    `log("Called process hit");


    pawnRepInfo = WipPawnReplicationInfo(cachedOwner.PlayerReplicationInfo);

    damage = cachedOwner.BaseAttackDamage;

    // if there is valid replication info
    // potentially add if owner is still alive (currentHealth > 0)
    if (pawnRepInfo != none){

        // modify the damage based on stuff
        cachedOwner.BuffAttack(damage, cachedOwner.PawnDamageType);
    }

    target = (WiPPawn(Impact.HitActor) != none )? WiPPawn(Impact.HitActor) : none;

    if (target != none){
        `log("called enemies' takeDamage()");
        // target.TakeDamage(damage, cachedOwner.Controller , target.Location, none ,cachedOwner.PawnDamageType, , self);
    }
}


// return the number of seconds in between attacks (based on owners attack speed/time)
simulated function float GetFireInterval( byte FireModeNum ){

    local float firingRate;
	local WiPPawnReplicationInfo pawnRepInfo;

	firingRate = cachedOwner.BaseAttackTime;
    // `log("Base firing rate ========================" @ firingRate);
    pawnRepInfo = WiPPawnReplicationInfo(cachedOwner.PlayerReplicationInfo);
    if (pawnRepInfo != none && pawnRepInfo.AttackSpeed > -1.f){
        firingRate /= (1.f + pawnRepInfo.AttackSpeed);
    // `log("Attack Speed ======================" @ pawnRepInfo.AttackSpeed);
    }

   // `log("Final firing rate =================" @firingRate);

    return firingRate;
}

// called when the weapon is given to a client
reliable client function ClientGivenTo (Pawn NewOwner, bool bDoNotActivate){
    Super.ClientGivenTo(NewOwner, bDoNotActivate);
    cachedOwner = (WiPPawn(NewOwner) != none) ? WiPPawn(NewOwner) : none;
}

 
DefaultProperties
{
    FiringStatesArray(0)=WeaponFiring
    WeaponFireTypes(0)=EWFT_Projectile
    WeaponProjectiles(0)=class'WiPWeaponProjectile'
    Spread(0) = 0
}