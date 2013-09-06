class WiPTrigger extends Actor;

// the collision component
var const CylinderComponent triggerCollisionComponent;

// called when something touches me
simulated singular event Touch(Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal){
    OnTouch(Self, Other, OtherComp, HitLocation, HitNormal);
}

// when that something stops touching me
simulated singular event UnTouch(Actor Other){
    OnUnTouch(Self, Other);
}

// draw the cylinder component for debugging reasons
simulated event Tick(float DeltaTime){
    super.Tick(DeltaTime);
	DrawDebugCylinder(Location + Vect(0.f, 0.f, 1.f) * triggerCollisionComponent.CollisionHeight,
            Location - Vect(0.f, 0.f, 1.f) * triggerCollisionComponent.CollisionHeight,
            triggerCollisionComponent.CollisionRadius, 16, 255, 0, 255);
}

// Called when the trigger touches something
simulated delegate OnTouch(Actor Caller, Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal);

// called when the trigger untouches something
simulated delegate OnUnTouch(Actor Caller, Actor Other);

defaultproperties
{
	Begin Object Class=CylinderComponent Name=CollisionCylinder
		CollisionRadius=+256.f
		CollisionHeight=+64.f
		BlockNonZeroExtent=true
		BlockZeroExtent=false
		BlockActors=false
		CollideActors=true
	End Object
	CollisionComponent=CollisionCylinder
	triggerCollisionComponent=CollisionCylinder
	Components.Add(CollisionCylinder)

	bHidden=true
	bCollideActors=true
	bCollideWorld=false
	bIgnoreEncroachers=true
	bCollideAsEncroacher=true
	bPushedByEncroachers=true
}