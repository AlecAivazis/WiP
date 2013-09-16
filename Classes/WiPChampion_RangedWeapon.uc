class WiPChampion_RangedWeapon extends WiPWeapon;

simulated event vector GetPhysicalFireStartLoc(optional vector AimDir){

     local vector newLoc;


     if (cachedOwner == none)
        cachedOwner = WiPPawn(Instigator);

     newLoc = cachedOwner.GetPawnViewLocation();
     newLoc.Z = 310;

     return newLoc;

}


DefaultProperties
{
    FiringStatesArray(0)=WeaponFiring
    WeaponFireTypes(0)=EWFT_Projectile
    WeaponProjectiles(0)=class'WiPWeaponProjectile'
    Spread(0) = 0
}