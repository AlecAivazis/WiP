class WiPCreepFactory extends WiPActor
    placeable;

var const float spawnInterval;
var const int numMeleeCreep;
var const int numRangedCreep;

function PostBeginPlay(){

    Super.PostBeginPlay();

    spawnCreep();

   // if (spawnInterval > 0.f )
   //     setTimer(spawnInterval, true, NameOf(SpawnCreep));

}

function spawnCreep(){

    local int i;
    local WiPMeleeCreepPawn meleePawn;
    local WiPRangedCreepPawn rangedPawn;
    local WiPCreepAIController ai;

    for (i = 0; i<numMeleeCreep; i++){
        meleePawn = Spawn(class'WiPMeleeCreepPawn',,,Location);
        if (meleePawn != none){
          //  ai = WiPCreepAIController(meleePawn.Controller);
          //  ai.initialize();
        }

    }
    for (i = 0; i<numMeleeCreep; i++){
        //rangedPawn = Spawn(class'WiPRangedCreepPawn',,,Location);
        if (rangedPawn != none){
          //  ai = WiPCreepAIController(rangedPawn.Controller);
          //  ai.initialize();
        }
    }

}


defaultproperties
{
    spawnInterval = 2.0;
    numMeleeCreep = 3;
    numRangedCreep = 3;

    bBlockActors=True
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