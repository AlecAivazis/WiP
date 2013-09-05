class WiPMeleeCreepPawn extends WiPCreepPawn;


simulated function PostBeginPlay(){
    super.PostBeginPlay();
    `log("created a melee pawn!");
}

defaultproperties {
}