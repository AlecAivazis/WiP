class WiPChampion_RangedWeapon extends WiPWeapon;



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




DefaultProperties
{
    FiringStatesArray(0)=WeaponFiring
    WeaponFireTypes(0)=EWFT_Projectile
    WeaponProjectiles(0)=class'WiPWeaponProjectile'
    Spread(0) = 0
}