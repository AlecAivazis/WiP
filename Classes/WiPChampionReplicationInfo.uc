class WiPChampionReplicationInfo extends WiPPawnReplicationInfo;

// The level of the champion
var ProtectedWrite RepNotify int Level;
// How much experience this hero has
var ProtectedWrite RepNotify int Experience;
// Number of Abilities that the champion can level up
var ProtectedWrite RepNotify int nSkillPoints;
// How long (in seconds) the hero will remain dead after a death before reviving.
var ProtectedWrite float ReviveTime;


replication
{
	// Replicate only if the values are dirty, this replication info is owned by the player and from server to client
	if (bNetDirty && bNetOwner)
		Experience, Level, nSkillPoints;

	// Replicate only if the values are dirty and from server to client
	if (bNetDirty)
		ReviveTime;
}


// return the amount of experience needed for a level
simulated function float ExperienceNeededForLevel(int N){
    return (TriangleNumber(N - 1) - 1)*100;
}


// return the n'th triangle number
simulated function int TriangleNumber(int n){
    return (n * (n + 1))/2 ;
}


// give this champion experience
simulated function giveExperience(int exp){

    Experience = Max(Experience + exp, 0);
    
    `log("I just gained experience. Current amount ========== " @ Experience);

    if (Experience >= ExperienceNeededForLevel(Level+1)){
        gainLevel();
    }
}

// gain a level
simulated function gainLevel(){
    // increase the level
    Level++;
    // give the champion a skill point to level an ability
    nSkillPoints++;
}


defaultproperties
{
    Experience = 0
    Level = 1
    ReviveTime = 0.f
}