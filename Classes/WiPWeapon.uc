class WiPWeapon extends UDKWeapon;

simulated function ProcessInstantHit(byte FiringMode, ImpactInfo Impact, optional int NumHits){
    `log("fired weapon.");
}

simulated function float GetFireInterval( byte FireModeNum )
{
	return FireInterval[FireModeNum] > 0 ? FireInterval[FireModeNum] : 0.01;
}


DefaultProperties
{
    FiringStatesArray(0)=WeaponFiring
    FireInterval(0)=+0.24
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
