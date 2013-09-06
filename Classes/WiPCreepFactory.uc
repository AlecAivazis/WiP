class WiPCreepFactory extends WiPActor
    placeable;

// the spawn interval for creeps
var const float spawnInterval;

// by default, CreepFactories will create two types of creeps
var(CreepFactory) const WiPCreepPawn pawnArchetype1;
var(CreepFactory) const WiPCreepPawn pawnArchetype2;

// the number of each archetype we want to generate
var(CreepFactory) const int numArchetype1;
var(CreepFactory) const int numArchetype2;

// the route for the creeps to follow
var(CreepFactory) const Route route;

function PostBeginPlay(){

    Super.PostBeginPlay();

    // spawn creeps - make sure to check if the archetypes are set
    spawnCreepTimer();
    // setTimer(spawnInterval, true, NameOf(SpawnCreep));

}


function spawnCreepTimer(){

    local int i;
    local WiPCreepPawn creepPawn;

    // spawn archetype 1 only if its defined
    if (pawnArchetype1 != none){
        for (i = 0; i<numArchetype1; i++){
            creepPawn = Spawn(pawnArchetype1.Class, Self, ,Location, Rotation, pawnArchetype1);
            if(creepPawn != none) connectWithAI(creepPawn);
        }
    }
    
    // spawn archetype 2 only if its defined
    if (pawnArchetype2 != none){
        for (i = 0; i<numArchetype2; i++){
            creepPawn = Spawn(pawnArchetype2.Class, Self, ,Location, Rotation, pawnArchetype2);
            if(creepPawn != none) connectWithAI(creepPawn);
        }
    }
}

function connectWithAI(WiPCreepPawn creepPawn){
    
    local WiPCreepAIController ai;

    // make an ai controller
    ai = Spawn(class'WiPCreepAIController');
    if (ai != none){
        // possess the pawn(no vehicle transition) and initialize the ai
        ai.Possess(creepPawn, false);
        ai.initialize();
    }
}


defaultproperties
{
    spawnInterval = 2.0;
    numArchetype1 = 3;
    numArchetype2 = 3;

    bCollideActors=True
    
    Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
        bEnabled=TRUE
    End Object
    Components.Add(MyLightEnvironment)

    Begin Object Class=StaticMeshComponent Name=PickupMesh
        StaticMesh=StaticMesh'UN_SimpleMeshes.TexPropCube_Dup'
        Materials(0)=Material'EditorMaterials.WidgetMaterial_Y'
        LightEnvironment=MyLightEnvironment
        Scale3D=(X=0.125,Y=0.125,Z=0.125)
    End Object
    Components.Add(PickupMesh)
}