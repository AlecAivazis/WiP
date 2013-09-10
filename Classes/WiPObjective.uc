class WiPObjective extends WiPPawn
    abstract
    placeable;

// static mesh used by the objective
var(Objective) const StaticMeshComponent StaticMesh;
// team that this objective belongs to
var(Objective) const byte TeamIndex;

/*****************************************************************
*   Interface - WiPAttackble                                     *
******************************************************************/

// return the objective's team number
simulated function byte GetTeamNum(){
    return TeamIndex;
}

defaultproperties
{
	Mesh=None
	WeaponSkeletalMesh=None

	Begin Object Class=StaticMeshComponent Name=MyStaticMeshComponent
		LightEnvironment=MyLightEnvironment
		bOverrideLightMapResolution=false
		AlwaysLoadOnClient=true
		AlwaysLoadOnServer=true
	End Object
	StaticMesh=MyStaticMeshComponent
	Components.Add(MyStaticMeshComponent)

	bNoDelete=true
}