class WiPPlayerReplicationInfo extends PlayerReplicationInfo;

// pawn rep info
var RepNotify WiPPawnReplicationInfo pawnRepInfo;
// the amount of gold owned by the player
var RepNotify int gold;
// the number of minions killed by the player
var RepNotify int lastHits;
// the amount of money to give to a player when he/she levels
var int moneyToGiveOnLevel;
// the time of the player's next respawn
var float NextRespawnTime;


// Replication block
replication
{
    if(bNetDirty && bNetOwner)
        gold, lastHits;

	// Replicate only if the values are dirty and from server to client
	if (bNetDirty)
		PawnRepInfo;
}


// added money to hero's gold count
simulated function GiveGold(int amount){
    `log("Added " @ amount @ " of gold to your bag.");
    gold = Max(gold+amount, 0);
    `log("Current amount: " @ gold);
}


DefaultProperties
{
    gold = 250
    lastHits = 0
    moneyToGiveOnLevel = 400
}
