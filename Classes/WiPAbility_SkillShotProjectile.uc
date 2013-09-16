class WiPAbility_SkillShotProjectile extends UTProjectile;

simulated function PostBeginPlay()
{
	// force ambient sound if not vehicle game mode
	bImportantAmbientSound = !WorldInfo.bDropDetail;
	Super.PostBeginPlay();
	`log("Instigator = " @ Instigator );
}

// called when the projectile touches an actor
simulated function ProcessTouch(Actor Other, Vector HitLocation, Vector HitNormal)
{
	if (DamageRadius > 0.0)
	{
		Explode( HitLocation, HitNormal );
	}
	else
	{
		Other.TakeDamage(Damage,InstigatorController,HitLocation,MomentumTransfer * Normal(Velocity), MyDamageType,, self);
		Shutdown();
	}
}

simulated static function float GetRange(){
          return 400;
}

defaultproperties
{
	ProjFlightTemplate=ParticleSystem'WP_RocketLauncher.Effects.P_WP_RocketLauncher_RocketTrail'
	ProjExplosionTemplate=ParticleSystem'WP_RocketLauncher.Effects.P_WP_RocketLauncher_RocketExplosion'
	ExplosionDecal=MaterialInstanceTimeVarying'WP_RocketLauncher.Decals.MITV_WP_RocketLauncher_Impact_Decal01'
	MyDamageType=class'UTDmgType_Rocket'
	DecalWidth=128.0
	DecalHeight=128.0
	speed= 15.0
	MaxSpeed= 5.0
	Damage=100.0
	DamageRadius=220.0
	MomentumTransfer=0
	LifeSpan=0.5
	AmbientSound=SoundCue'A_Weapon_RocketLauncher.Cue.A_Weapon_RL_Travel_Cue'
	ExplosionSound=SoundCue'A_Weapon_RocketLauncher.Cue.A_Weapon_RL_Impact_Cue'
	RotationRate=(Roll=50000)
	bCollideWorld=true
	CheckRadius=42.0
	bCheckProjectileLight=true
	ProjectileLightClass=class'UTGame.UTRocketLight'
	ExplosionLightClass=class'UTGame.UTRocketExplosionLight'

	bWaitForEffects=true
	bAttachExplosionToVehicles=false
}
