class WiPChampionController extends WiPPlayerController;

function InitPlayerReplicationInfo()
{
	PlayerReplicationInfo = Spawn(class'WiPPawnReplicationInfo', Self);
}