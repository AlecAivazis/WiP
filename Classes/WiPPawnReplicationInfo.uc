class WiPPawnReplicationInfo extends WiPPlayerReplicationInfo;

// Attack speed multiplier for this unit
var float AttackSpeed;

simulated function bool ShouldBroadCastWelcomeMessage(optional bool bExiting)
{
	// Never broadcast welcome message
	return false;
}

replication{
    if (bNetDirty)
        AttackSpeed;
}

defaultproperties
{}