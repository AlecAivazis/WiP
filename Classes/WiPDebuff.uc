class WiPDebuff extends Actor
      DependsOn(WiPStatModifier);;

// the time over which this DoT occurs
var(Debuff) const array<float> Duration;
// the stat change of this buf
var(Debuff) StatChange StatChange;

// the target of this DoT
var WiPPawn target;

var WiPAbility source;



// the level of this debuff (set when activated, by the activating spell)
var int Level;

simulated function Activate(WiPPawn dotTarget){
    `log("activated debuff " @ self);

    target = dotTarget;

    SetTimer(GetDuration(), false, NameOf(Deactivate));
}

simulated function float GetDuration(){
    return Duration[Level - 1];
}


simulated function Deactivate(){
    Destroy();
}

defaultProperties
{
}