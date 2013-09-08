class WiPWeapon extends UDKWeapon;

// cached a typecasted version of owner
var WiPPawn cachedOwner;

simulated function ProcessInstantHit(byte FiringMode, ImpactInfo Impact, optional int NumHits){
    `log("fired weapon.");
}

// return the number of seconds in between attacks (based on owners attack speed)
simulated function float GetFireInterval( byte FireModeNum ){
	return 3.f;
}


// return the max range of the weapon
simulated function float MaxRange (){
    return 250.f;
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
