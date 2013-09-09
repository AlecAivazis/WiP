class WiPPlayerReplicationInfo extends PlayerReplicationInfo;

// pawn rep info
var RepNotify WiPPawnReplicationInfo pawnRepInfo;
// Replication block
replication
{

	// Replicate only if the values are dirty and from server to client
	if (bNetDirty)
		PawnRepInfo;
}

DefaultProperties
{
}
