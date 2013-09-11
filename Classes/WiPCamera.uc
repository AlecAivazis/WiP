class WiPCamera extends Camera;

var vector CameraTranslateScale;
var float CameraZOffset;

simulated event PostBeginPlay()
{
	super.PostBeginPlay();
}

function UpdateViewTarget(out TViewTarget OutVT, float DeltaTime)
{
	local vector		CamStart, X, Y, Z, CamDir;
	local CameraActor	CamActor;
	local bool			bDoNotApplyModifiers;
	local WiPPlayerController controller;
    local float CollisionRadius;

	// Default FOV on viewtarget
	OutVT.POV.FOV = DefaultFOV;

	// Viewing through a camera actor.
	CamActor = CameraActor(OutVT.Target);
	if( CamActor != None )
	{
		CamActor.GetCameraView(DeltaTime, OutVT.POV);

		// Grab aspect ratio from the CameraActor.
		bConstrainAspectRatio	= bConstrainAspectRatio || CamActor.bConstrainAspectRatio;
		OutVT.AspectRatio		= CamActor.AspectRatio;

		// See if the CameraActor wants to override the PostProcess settings used.
		CamOverridePostProcessAlpha = CamActor.CamOverridePostProcessAlpha;
		CamPostProcessSettings = CamActor.CamOverridePostProcess;
	}
	else{
		// Give Pawn Viewtarget a chance to dictate the camera position.
		// If Pawn doesn't override the camera view, then we proceed with our own defaults
		if( Pawn(OutVT.Target) == None ||
			!Pawn(OutVT.Target).CalcCamera(DeltaTime, OutVT.POV.Location, OutVT.POV.Rotation, OutVT.POV.FOV) )
		{
			// don't apply modifiers when using these debug camera modes.
			bDoNotApplyModifiers = TRUE;
            controller = WiPPlayerController(PCOwner);
            
            // use the rotation of the pawn
            if (controller != none)
                OutVT.POV.Rotation = Controller.Rotation;
            else
                OutVT.POV.Rotation = Rotation;

            // calculate camera location from pawn location
            CollisionRadius = 36;

            CamStart = Controller.Pawn.Location;
            CamStart.Z += CameraZOffset;

            GetAxes(OutVT.POV.Rotation, X, Y, Z);
            X *= CollisionRadius * CameraTranslateScale.X;
            Y *= CollisionRadius * CameraTranslateScale.Y;
            Z *= CollisionRadius * -1.0f;
            CamDir = X + Y + Z;

            OutVT.POV.Location = CamStart - CamDir;
			
		}
	}

	if( !bDoNotApplyModifiers )
	{
		// Apply camera modifiers at the end (view shakes for example)
		ApplyCameraModifiers(DeltaTime, OutVT.POV);
	}
	//`log( WorldInfo.TimeSeconds  @ GetFuncName() @ OutVT.Target @ OutVT.POV.Location @ OutVT.POV.Rotation @ OutVT.POV.FOV );
}



DefaultProperties
{
	CameraZOffset=30
    CameraTranslateScale=(X=5,Y=-1,Z=1)
}
