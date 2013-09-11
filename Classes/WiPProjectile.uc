class WiPProjectile extends Projectile
    HideCategories(Movement, Display, Attachment, Physics, Advanced, Debug, Object, Projectile);

// flight particle system
var(WiPProjectile) const ParticleSystemComponent FlightParticleSystem;
// impact particle template
var(WiPProjectile) const ParticleSystem ImpactTemplate;
// impact matierial instance time varying to use for decals
var(WiPProjectile) const MaterialInstanceTimeVarying ImpactDecalMaterialInstanceTimeVarying;
// Impact opacity scalar parameter name
var(WiPProjectile) const Name ImpactDecalOpacityScalarParameterName;
// Impact decal life time
var(WiPProjectile) const float ImpactDecalLifeSpan;
// Impact decal minimum size
var(WiPProjectile) const Vector2D ImpactDecalMinSize;
// Impact decal maximum size
var(WiPProjectile) const Vector2D ImpactDecalMaxSize;
// If true, then the size of the decal is always uniform
var(WiPProjectile) const bool AlwaysUniformlySized;
// These 4 variables are here because we need to hide the 'Projectile' category, because Damage and
// DamageType aren't inherent in MOBA's - they come from the firing entity. But we need to be able
// to set _some_ of the 'Projectile' vars...
// Initial speed of projectile.
var(WiPProjectile)	float WiPSpeed<DisplayName=Speed>;
// Limit on speed of projectile (0 means no limit).
var(WiPProjectile)	float WiPMaxSpeed<DisplayName=MaxSpeed>;
// Sound made when projectile is spawned.
var(WiPProjectile)	SoundCue WiPSpawnSound<DisplayName=SpawnSound>;
// Sound made when projectile hits something.
var(WiPProjectile)	SoundCue WiPImpactSound<DisplayName=ImpactSound>;

// Who owns this projectile
var WiPAttackable OwnerAttackInterface;
// The enemy that this projectile homes in on and attacks
var RepNotify Actor Enemy;
// The type of damage this projectile does
var class<DamageType> DamageType;
// The attack type this projectile inherits
var WiPPawn.AttackTypes AttackType;
// If true, then the explosion effects have been triggered
var ProtectedWrite bool HasExploded;

// replication block
replication{
    if (bNetInitial)
        Enemy;
}



// Called when a variable that has been flagged with RepNotify has finished replicating
simulated event ReplicatedEvent(Name VarName)
{
	// Set the enemy
	if (VarName == NameOf(Enemy))
	{
		if (Enemy != None)
		{
			Init(Normal(Enemy.Location - Location));
		}
	}

	Super.ReplicatedEvent(VarName);
}

// set the velocity of the particle based on the direction
simulated function Init(Vector Direction){
    super.Init(Direction);
    
    // start homing timer
    if (!IsTimerActive(NameOf(HomingTimer)) && Enemy != none){
        SetTimer(0.1f, true, NameOf(HomingTimer));
    }
}


// projectile timer loop
simulated function HomingTimer(){
    local WiPAttackable WipAttackable;

    
    // if the enemy doesn't exist, destroy the projectile
    if (Enemy == None){
        `log("Enemy doesn't exist");
        
        // spawn the impact particle effect, if there is one
        if (ImpactTemplate != none && WorldInfo.MyEmitterPool != none){
            // WorldInfo.MyEmitterPool.SpawnEmitter(ImpactTemplate, Location);
        }

        Destroy();
    }

    WipAttackable = WiPAttackable(Enemy);
    if (WipAttackable != none && !WipAttackable.IsValidToAttack()){

        // spawn the impact particle effect
        if (ImpactTemplate != none && WorldInfo.MyEmitterPool != none){
            // WorldInfo.MyEmitterPool.SpawnEmitter(ImpactTemplate, Location);
        }
        
        Destroy();
    }

    Init(Normal(Enemy.Location-Location));


}

// called when the projectile touches something
simulated event Touch(Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal){

  //  `log("called touch");

	// Projectiles only ever hit their targetted enemy
	if (Other == Enemy){
		Super.Touch(Other, OtherComp, HitLocation, HitNormal);
	}
}

// touch event processor
simulated function ProcessTouch(Actor Other, Vector HitLocation, Vector HitNormal)
{
	// Projectiles only ever hit their targetted enemy
	if (Other == Enemy){
		DealEnemyDamage();
		Explode(HitLocation, HitNormal);
	}
}


// called when the projectile hits a wall
simulated singular event HitWall(vector HitNormal, actor Wall, PrimitiveComponent WallComp)
{
	// Abort if I did not touch the enemy
	if (Wall == Enemy){
		DealEnemyDamage();
		Explode(Location, HitNormal);
	}
}

// deal damage to the enemy
simulated function DealEnemyDamage(){

	local Controller AttackingController;
	local int DamageDone;
	local WiPPawn NeutralPawn;
 

 //   `log("called dealEnemyDamage()");

	// Only deal damage on the server
	if (Role == ROLE_Authority && OwnerAttackInterface != None)
	{
		DamageDone = Damage;
		AttackingController = None;
		if (WiPPawn(OwnerAttackInterface) != None){
           // `log("CastedPawn's Team ========== " @WipPawn(OwnerAttackInterface).GetTeamNum());
			AttackingController = WiPPawn(OwnerAttackInterface).Controller;
		    //  `log("Retrieved Pawn's Controller ==========" @ AttackingController);
            NeutralPawn = WiPPawn(Enemy);
			if (NeutralPawn != None){
				// DamageDone *= WiPPawn.GetArmorTypeMultiplier(AttackType);
			     DamageDone *= 1;
            }
		}

       // `log("Attacker: " @ AttackingController);
		Enemy.TakeDamage(DamageDone, AttackingController, Enemy.Location, Velocity, DamageType, , Self);
    }
}

// explode projectile
simulated function Explode(vector HitLocation, vector HitNormal){
	// Create the explosion effects
	SpawnExplosionEffects(HitLocation, HitNormal);

	// Destroy the projectile
	Destroy();
}

// create explosion effects
simulated function SpawnExplosionEffects(vector HitLocation, vector HitNormal){
	local MaterialInstanceTimeVarying MaterialInstanceTimeVarying;
	local float Width, Height;
	local Vector TraceHitLocation, TraceHitNormal;
	local Actor HitActor;

	if (HasExploded){
		return;
	}

	HasExploded = true;

	if (WorldInfo.NetMode != NM_DedicatedServer){
		// Play the impact sound if there is one
		if (ImpactSound != None){
			PlaySound(ImpactSound, true);
		}
	
		// Spawn the impact particle effect if there is one
		if (ImpactTemplate != None && WorldInfo.MyEmitterPool != None){
			WorldInfo.MyEmitterPool.SpawnEmitter(ImpactTemplate, HitLocation, Rotator(HitNormal));
		}
	
		// Spawn the impact decal effect if there is one
		if (ImpactDecalMaterialInstanceTimeVarying != None && WorldInfo.MyDecalManager != None){
			HitNormal = Normal(HitNormal);
			HitActor = Trace(TraceHitLocation, TraceHitNormal, HitLocation - HitNormal * 256.f, HitLocation + HitNormal * 256.f);

			if (HitActor != None && HitActor.bWorldGeometry){
				MaterialInstanceTimeVarying = new () class'MaterialInstanceTimeVarying';

				if (MaterialInstanceTimeVarying != None){
					// Figure out the decal width and height
					Width = RandRange(ImpactDecalMinSize.X, ImpactDecalMaxSize.X);
					Height = (AlwaysUniformlySized) ? Width : RandRange(ImpactDecalMinSize.Y, ImpactDecalMaxSize.Y);
			
					// Set up the MaterialInstanceTimeVarying
					MaterialInstanceTimeVarying.SetParent(ImpactDecalMaterialInstanceTimeVarying);
			
					// Spawn the decal
					WorldInfo.MyDecalManager.SpawnDecal(MaterialInstanceTimeVarying, TraceHitLocation + TraceHitNormal * 8.f, Rotator(-TraceHitNormal), Width, Height, 32.f, false);
			
					// Set the scalar start time; so that the decal doesn't start fading away immediately
					MaterialInstanceTimeVarying.SetScalarStartTime(ImpactDecalOpacityScalarParameterName, ImpactDecalLifeSpan);
				}
			}
		}
	}
}

// Default properties block
defaultproperties
{
	Begin Object Class=ParticleSystemComponent Name=MyParticleSystemComponent
	End Object
	Components.Add(MyParticleSystemComponent)
	FlightParticleSystem=MyParticleSystemComponent

	bCollideWorld=false
	bCollideActors=true
	ImpactDecalLifeSpan=24.f
	ImpactDecalOpacityScalarParameterName="DissolveAmount"
	ImpactDecalMinSize=(X=192.f,Y=192.f)
	ImpactDecalMaxSize=(X=256.f,Y=256.f)
	AlwaysUniformlySized=true
	bNetTemporary=false
	bAlwaysRelevant=true

	WiPMaxSpeed=+02000.000000
	WiPSpeed=+02000.000000
	AttackType=ATT_Magic
}