class Weapon_Sniper extends UTWeap_LinkGun;


DefaultProperties
{

    FireInterval(0)=+0.24
    Spread(0)=0

	Begin Object Class=UDKSkeletalMeshComponent Name=GunMesh
        SkeletalMesh=SkeletalMesh'WP_LinkGun.Mesh.SK_WP_Linkgun_3P'
        HiddenGame=FALSE
        HiddenEditor=FALSE
    End Object
    Mesh=GunMesh
    Components.Add(GunMesh)

	// Damage
	InstantHitDamage(0)=10

	WeaponFireTypes(0)=EWFT_Projectile
	WeaponFireTypes(1)=EWFT_InstantHit
	WeaponProjectiles(0)=class'UTProj_Rocket' // UTProj_LinkPowerPlasma if linked (see GetProjectileClass() )
	InstantHitDamageTypes(1)=class'UTDmgType_LinkBeam'

	WeaponRange=500


	WeaponAttachmentSocketName=WeaponPoint
}
