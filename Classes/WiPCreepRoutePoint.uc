class WiPCreepRoutePoint extends WiPActor
	HideCategories(Attachment, Collision, Physics, Debug, Object)
	Placeable;

// Default properties block
defaultproperties
{
	bEdShouldSnap=true
	bStatic=true
	bNoDelete=true
	bCollideWhenPlacing=true

	Begin Object Class=SpriteComponent Name=Sprite
		Sprite=Texture2D'EditorResources.Flag1'
		HiddenGame=true
		HiddenEditor=false
		AlwaysLoadOnClient=false
		AlwaysLoadOnServer=false
		SpriteCategoryName="Pawns"
	End Object
	Components.Add(Sprite)

	Begin Object Class=CylinderComponent Name=CollisionCylinder
		CollisionRadius=50.f
		CollisionHeight=50.f
	End Object
	CollisionComponent=CollisionCylinder
	Components.Add(CollisionCylinder)
}