class WiPAIController extends AIController;

event Possess(Pawn inPawn, bool bVehicleTransition)
{
    Super.Possess(inPawn, bVehicleTransition);
	inPawn.SetMovementPhysics();
}

defaultproperties{}