class WiPPawnReplicationInfo extends WiPPlayerReplicationInfo;

// Attack speed multiplier for this unit
var float AttackSpeed;


replication{
    if (bNetDirty)
        AttackSpeed;
}

defaultproperties{}