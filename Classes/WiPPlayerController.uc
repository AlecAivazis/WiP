class WiPPlayerController extends GamePlayerController;

var vector PlayerViewOffset;
var rotator CurrentCameraRotation;

function PlayerMove(float DeltaTime){
    local vector X, Y, Z, AltAccel;
    local rotator OldRotation;
    GetAxes(CurrentCameraRotation, X, Y, Z);
    AltAccel = PlayerInput.aForward * Z + PlayerInput.aStrafe
    * Y;
    AltAccel.Z = 0;
    AltAccel = Pawn.AccelRate * Normal(AltAccel);
    OldRotation = Rotation;
    UpdateRotation(DeltaTime);
    if(Role < ROLE_Authority)
    ReplicateMove(DeltaTime, AltAccel, DCLICK_None,
    OldRotation - Rotation);
    else
    ProcessMove(DeltaTime, AltAccel, DCLICK_None,
    OldRotation - Rotation);
}

simulated function PostBeginPlay()
{

   Super.PostBeginPlay();

}

exec function SaySomething(){
     `log("Something....");
}



event Possess(Pawn inPawn, bool bVehicleTransition){

    local WiPChampion champPawn;
    local WiPChampionController champController;
    local WiPPlayerReplicationInfo pri;
	local WiPChampionReplicationInfo champRepInfo;

    Super.Possess(inPawn, bVehicleTransition);

    // only allow players to posses a champion
    champPawn = WiPChampion(inPawn);
    if (champPawn == none) return;

    // spawn the champion's controller
    champController = WiPChampionController(champPawn.Controller);
    if (champController != none){
        champController.Controller = self;
        champController.PlayerController = self;
    }


    // assign the hero pawn's player rep info
    pri = WiPPlayerReplicationInfo(PlayerReplicationInfo);
    if (pri != none){

        // if the pri already has a pawn,
        if (pri.PawnRepInfo == none){
            champRepInfo = Spawn(class'WiPChampionReplicationInfo', self);
        } else {
            champRepInfo = WiPChampionReplicationInfo(pri.PawnRepInfo);
        }

        champRepInfo.Team = PlayerReplicationInfo.Team;
        champRepInfo.PlayerReplicationInfo = PlayerReplicationInfo;

        champPawn.PlayerReplicationInfo = champRepInfo;
        pri.PawnRepInfo = champRepInfo;


    }

    // Restart the player controller
	Restart(bVehicleTransition);
}



// switch equipped weapon
exec function SwitchWeapon(byte slot){
    if (WiPChampion(Pawn) != none){
        WiPChampion(pawn).SwitchWeapon(slot);
    }
}


function UpdateRotation( float DeltaTime )
{
    local Rotator   DeltaRot, newRotation, ViewRotation;

    ViewRotation = Rotation;
    if (Pawn!=none)
    {
      Pawn.SetDesiredRotation(ViewRotation);
    }

    // Calculate Delta to be applied on ViewRotation
    DeltaRot.Yaw   = PlayerInput.aTurn;
    DeltaRot.Pitch   = PlayerInput.aLookUp;

    ProcessViewRotation( DeltaTime, ViewRotation, DeltaRot );
    SetRotation(ViewRotation);

    NewRotation = ViewRotation;
    NewRotation.Roll = Rotation.Roll;

    if ( Pawn != None ){
        Pawn.FaceRotation(NewRotation, deltatime);
        CurrentCameraRotation = NewRotation;
    }
}


DefaultProperties
{
	CameraClass=class'WiP.WiPCamera'
	
        InputClass=WiPInput
	// RemoteRole=ROLE_AutonomousProxy
}