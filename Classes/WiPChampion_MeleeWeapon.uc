class WiPChampion_MeleeWeapon extends WiPWeapon;

// the name of the base of the melee weapon
var(Weapon) const name SwordHiltSocketName;
// the name of the tip of the melee weapon
var(Weapon) const name SwordTipSocketName;

// the actors hit during the trace
var array<Actor> SwingHitActors;
// the number of swings (currentAmmo)
var array<int> Swings;
// the maximum number of swings
var const int MaxSwings;

reliable client function ClientGivenTo(pawn NewOwner, bool bDoNotActivate){

    local WiPPawn wipPawn;
    
    super.ClientGivenTo(NewOwner, bDoNotActivate);
    
    // make sure the owner is a WiPPawn and has a valid socket
    wipPawn = WiPPawn(NewOwner);
    if (wipPawn != none && wipPawn.Mesh.GetSocketByName(WiPPawn.MeleeSocketName) != none){
        
        // equp the weapon
        Mesh.SetShadowParent(wipPawn.Mesh);
        Mesh.SetLightEnvironment(wipPawn.LightEnvironment);
        wipPawn.Mesh.AttachComponentToSocket(Mesh, wipPawn.meleeSocketName);
    }

    `log("You equipped a melee weapon!");

}

// restore the "ammo" (Swings remaining)
function RestoreAmmo(int Amount, optional byte FireModeNum){
   Swings[FireModeNum] = Min(Amount, MaxSwings);
}

// decriment the swings left counter
function ConsumeAmmo(byte FireModeNum){
   if (HasAmmo(FireModeNum))
   {
      Swings[FireModeNum]--;
   }
}

// clear the actors hit array
simulated function FireAmmunition(){

   SwingHitActors.Remove(0, SwingHitActors.Length);

   if (HasAmmo(CurrentFireMode)){
      super.FireAmmunition();
   }
}


/*****************************************************************
*   State - Swinging                                             *
******************************************************************/


simulated state Swinging extends WeaponFiring{
   simulated event Tick(float DeltaTime)
   {
      super.Tick(DeltaTime);
      TraceSwing();
   }

   simulated event EndState(Name NextStateName)
   {
      super.EndState(NextStateName);
      SetTimer(GetFireInterval(CurrentFireMode), false, nameof(ResetSwings));
   }
}

function ResetSwings(){
   RestoreAmmo(MaxSwings);
}

function Vector GetSwordSocketLocation(Name SocketName){
   local Vector SocketLocation;
   local Rotator SwordRotation;
   local SkeletalMeshComponent SMC;

   SMC = SkeletalMeshComponent(Mesh);

   if (SMC != none && SMC.GetSocketByName(SocketName) != none)
   {
      SMC.GetSocketWorldLocationAndRotation(SocketName, SocketLocation, SwordRotation);
   }

   return SocketLocation;
}

function bool AddToSwingHitActors(Actor HitActor){
   local int i;

   for (i = 0; i < SwingHitActors.Length; i++)
   {
      if (SwingHitActors[i] == HitActor)
      {
         return false;
      }
   }

   SwingHitActors.AddItem(HitActor);
   return true;
}

function TraceSwing(){
   local Actor HitActor;
   local Vector HitLoc, HitNorm, SwordTip, SwordHilt, Momentum;
   local int DamageAmount;

   SwordTip = GetSwordSocketLocation(SwordTipSocketName);
   SwordHilt = GetSwordSocketLocation(SwordHiltSocketName);
   DamageAmount = FCeil(InstantHitDamage[CurrentFireMode]);

   foreach TraceActors(class'Actor', HitActor, HitLoc, HitNorm, SwordTip, SwordHilt)
   {
      if (HitActor != self && AddToSwingHitActors(HitActor))
      {
         Momentum = Normal(SwordTip - SwordHilt) * InstantHitMomentum[CurrentFireMode];
         HitActor.TakeDamage(DamageAmount, Instigator.Controller, HitLoc, Momentum, class'DamageType');
      }
   }
}

defaultproperties
{
    
    Begin Object Class=SkeletalMeshComponent Name=SwordSkeletalMeshComponent
       bCacheAnimSequenceNodes=false
       AlwaysLoadOnClient=true
       AlwaysLoadOnServer=true
       CastShadow=true
       BlockRigidBody=true
       bUpdateSkelWhenNotRendered=false
       bIgnoreControllersWhenNotRendered=true
       bUpdateKinematicBonesFromAnimation=true
       bCastDynamicShadow=true
       RBChannel=RBCC_Untitled3
       RBCollideWithChannels=(Untitled3=true)
       bOverrideAttachmentOwnerVisibility=true
       bAcceptsDynamicDecals=false
       bHasPhysicsAssetInstance=true
       TickGroup=TG_PreAsyncWork
       MinDistFactorForKinematicUpdate=0.2f
       bChartDistanceFactor=true
       RBDominanceGroup=20
       Scale=1.f
       bAllowAmbientOcclusion=false
       bUseOnePassLightingOnTranslucency=true
       bPerBoneMotionBlur=true
    End Object
    Mesh=SwordSkeletalMeshComponent
    
    MaxSwings=2
   Swings(0)=2

   bMeleeWeapon=true;
   bInstantHit=true;
   bCanThrow=false;

   FiringStatesArray(0)="Swinging"

   WeaponFireTypes(0)=EWFT_Custom
}