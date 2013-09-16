class WiPWeaponProjectile extends UDKProjectile;

// wether this projectile passes through enemies 
var const bool PassThrough;

// Called every time the projectile hits an actor
simulated function ProcessTouch(Actor Other, Vector HitLocation, Vector HitNormal){
    local WiPAttackable target;

    // only handle actors that are WiPAttackable
    target = WiPAttackable(Other);
    if (target == none) return;

    // only deal damage if it is okay to do so
    if (!target.isValidToAttack()) return;

    `log("I hit a valid target");

	if (DamageRadius > 0.0){
		Explode( HitLocation, HitNormal );

    }else{

		Other.TakeDamage(GetDamage(),InstigatorController,HitLocation,MomentumTransfer * Normal(Velocity), MyDamageType,, self);
        if(! passThrough){
            destroy();
        }
	}
}

simulated function float GetDamage(){
    
    local WiPChampion instigatorChampion;

    `log("Instigator = " @ Instigator);
    
    if (Instigator == none){
       `log("Instigator was none (GetDamage - WiPWeaponProjectile)");
       return 50;
    }

    instigatorChampion = WiPChampion(Instigator);
    if (instigatorChampion == none ){
       `log("Could not cast instigator to champion (GetDamage - WiPWeaponProjectile)");
       return 50;
    }
    
    `log("Returned " @instigatorChampion.BaseAttackDamage @ " damage");
    return instigatorChampion.BaseAttackDamage;

}




/**
 * Initialize the Projectile
 */
function Init(vector Direction)
{


    SetRotation(rotator(Direction));

	Velocity = Speed * Direction;
	Acceleration = AccelRate * Normal(Velocity);
}

DefaultProperties
{
    Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
        bEnabled=TRUE
    End Object
    Components.Add(MyLightEnvironment)
 
    begin object class=StaticMeshComponent Name=BaseMesh
        StaticMesh=StaticMesh'WP_BioRifle.Mesh.S_Bio_Blob_01'
        LightEnvironment=MyLightEnvironment
    end object

    Components.Add(BaseMesh)

    Damage = 50
    DamageRadius =0
    LifeSpan = 0.5f

}