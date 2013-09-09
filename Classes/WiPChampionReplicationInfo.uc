class WiPChampionReplicatonInfo extends WiPPawnReplicationInfo;

// The level of the abilities applied to the hero - if you get a level by don't 'use' it, then this lags Level by 1
var ProtectedWrite RepNotify int AppliedLevel;
// How much experience this hero has
var ProtectedWrite RepNotify int Experience;
// How long (in seconds) the hero will remain dead after a death before reviving.
var ProtectedWrite float ReviveTime;

replication
{
	// Replicate only if the values are dirty, this replication info is owned by the player and from server to client
	if (bNetDirty && bNetOwner)
		Experience, AppliedLevel;

	// Replicate only if the values are dirty and from server to client
	if (bNetDirty)
		ReviveTime;
}

