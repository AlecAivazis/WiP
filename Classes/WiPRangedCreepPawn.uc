class WiPRangedCreepPawn extends WiPCreepPawn;

simulated function PostBeginPlay(){
    super.PostBeginPlay();
    `log("created a ranged pawn!");
}

defaultproperties {
}