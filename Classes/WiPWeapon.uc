class WiPWeapon extends UDKWeapon;

// cached a typecasted version of owner
var WiPPawn cachedOwner;

simulated function ProcessInstantHit(byte FiringMode, ImpactInfo Impact, optional int NumHits){
    
    local int damage;
    local WipPawnReplicationInfo pawnRepInfo;
    
    pawnRepInfo = WipPawnReplicationInfo(cachedOwner.PlayerReplicationInfo);
    
    damage = cachedOwner.BaseAttackDamage;
    
    // if there is valid replication info 
    // potentially add if owner is still alive (currentHealth > 0)
    if (pawnRepInfo != none){
        
        // modify the damage based on stuff
        cachedOwner.BuffDamage(damage, cachedOwner.PawnDamageType);
    }

    WiPPawn target = WiPPawn(Impact.ActorHit) != none ? WiPPawn(Impact.ActorHit) : none;

    if (target != none){
        target.TakeDamage(damage, cachedOwner, target.Location, ,cachedOwner.PawnDamageType, ,
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


// return the max range of the weapon
simulated function float MaxRange (){
    return cachedOwner.WeaponRange;

}

// called when the weapon is given to a client
reliable client function ClientGivenTo (Pawn NewOwner, bool bDoNotActivate){
    Super.ClientGivenTo(NewOwner, bDoNotActivate);
    cachedOwner = (WiPPawn(NewOwner) != none) ? WiPPawn(NewOwner) : none;
}

DefaultProperties
{
    FiringStatesArray(0)=WeaponFiring
    Spread(0)=0

	Begin Object Class=UDKSkeletalMeshComponent Name=GunMesh
        SkeletalMesh=SkeletalMesh'WP_LinkGun.Mesh.SK_WP_Linkgun_3P'
        HiddenGame=FALSE
        HiddenEditor=FALSE
    End Object
    Mesh=GunMesh
    Components.Add(GunMesh)

	WeaponFireTypes(0)=EWFT_InstantHit
	WeaponProjectiles(0)=class'UTProj_Rocket' // UTProj_LinkPowerPlasma if linked (see GetProjectileClass() )

	WeaponRange=500
}
