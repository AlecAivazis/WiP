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
	CameraClass=class'WiPCamera'

	//RemoteRole=ROLE_AutonomousProxy
}