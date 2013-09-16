class WiPGame extends SimpleGame;

var const WiPChampion testChampionArchetype;

var WiPTeamInfo teams[3];

function PreBeginPlay(){
    Super.PreBeginPlay();

    CreateTeam(0);
    CreateTeam(1);
    CreateTeam(2);
}


function createTeam(int teamIndex){
    Teams[teamIndex] = spawn(class'WiPTeamInfo');
    Teams[teamIndex].TeamIndex = TeamIndex;
    GameReplicationInfo.SetTeam(TeamIndex, teams[teamIndex]);
}

function WiPTeamInfo getTeam(int teamIndex){
    return teams[teamIndex];
}

function Pawn SpawnDefaultPawnFor(Controller NewPlayer, NavigationPoint StartSpot)
{
    local Pawn SpawnedPawn;

    if (NewPlayer == none || StartSpot == none)
    {
        return none;
    }

    SpawnedPawn = Spawn(testChampionArchetype.Class,,, StartSpot.Location,, testChampionArchetype);

    return SpawnedPawn;
}

DefaultProperties
{
    bTeamGame=true
	bDelayedStart=false
	PlayerControllerClass=class'WiPPlayerController'
	PlayerReplicationInfoClass=class'WiPPlayerReplicationInfo'
	GameReplicationInfoClass=class'WiPGameReplicationInfo'

	testChampionArchetype = WiPChampion'WiP_ASSETS.Champions.TestChampion'

}
