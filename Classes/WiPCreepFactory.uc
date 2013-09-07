class WiPCreepFactory extends WiPActor
    placeable;


// by default, CreepFactories will create two types of creeps
var(CreepFactory) const WiPCreepPawn pawnArchetype1;
var(CreepFactory) const WiPCreepPawn pawnArchetype2;

// the number of each archetype we want to generate
var(CreepFactory) const int numArchetype1;
var(CreepFactory) const int numArchetype2;

// the current number of each archetype created
var int numArchetype1_current;
var int numArchetype2_current;

// the spawn interval for creeps
var(CreepFactory) const float spawnInterval;

// the team controlling this factory
var(CreepFactory) const byte teamIndex;

// the route for the creeps to follow
var(CreepFactory) const Route route;

function PostBeginPlay(){

    Super.PostBeginPlay();

    // for development, start spawning 5 seconds after the game starts
    SetTimer(5, false, NameOf(startTimer));
}

function startTimer(){
    // spawn creeps - make sure to check if the archetypes are set
    spawnCreepTimer();
    setTimer(spawnInterval, true, NameOf(SpawnCreepTimer));

}

simulated function byte getTeamNum(){
    return teamIndex;   
}


function spawnCreepTimer(){

    local WiPCreepPawn creepPawn;

    // only spawn archtype1 if its defined
    if (pawnArchetype1 != none){

        // check if we have spawned enough
        if (numArchetype1_current < numArchetype1){
            
            // spawn a pawn of archetype1
            creepPawn = Spawn(pawnArchetype1.Class, Self, ,Location, Rotation, pawnArchetype1);
            if(creepPawn != none){
                connectWithAI(creepPawn);
                numArchetype1_current ++;

                // limit one pawn per spawn
                return;
            }
            
        // check if Archetype2 is define so we can end the timer early
        } else if (pawnArchetype2 == none) {
            ClearTimer(NameOf(SpawnCreepTimer));
        }
    }
    
    // same for archetype 2
    if(pawnArchetype2 != none){
        if (numArchetype2_current < numArchetype2){
            creepPawn = Spawn(pawnArchetype2.Class, Self, ,Location, Rotation, pawnArchetype2);
            if(creepPawn != none){
                connectWithAI(creepPawn);
                numArchetype2_current ++;
            }

        } else ClearTimer(NameOf(SpawnCreepTimer));
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
    spawnInterval = 0.4;
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