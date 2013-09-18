class WiPDebuff extends Actor
      DependsOn(WiPStatModifier);;

// the time over which this DoT occurs
var(Ability) const array<float> Duration;
// the time in between ticks
var(Ability) const array<float> TickTime;
// the target of this DoT
var WiPPawn target;

var WiPAbility source;

// the stat change of this buf
var(Ability) StatChange StatChange;

// the level of this debuff (set when activated, by the activating spell)
var int Level;

simulated function Activate(WiPPawn dotTarget){
    `log("activated debuff " @ self);

    target = dotTarget;

    SetTimer(GetTickTime(), true, NameOf(DoTTick));
    SetTimer(GetDuration(), false, NameOf(Deactivate));
}

simulated function float GetDuration(){
    return Duration[Level - 1];
}

simulated function float GetTickTime(){
    return TickTime[Level-1];
}


// damage the target for Damage/Duration
simulated function DoTTick(){

    local float TickDamage;

    // The damage per tick is the total damage dividded by the number of ticks
    TickDamage =  source.GetDamage()/(GetDuration()/GetTickTime());

    `log("Debuff tick" @ target);

     Target.TakeDamage(TickDamage,source.caster.Controller,target.Location,Source.MomentumTransfer * Normal(Velocity), Source.MyDamageType,, self);
}

simulated function Deactivate(){
    `log("Deactivating " @ self);
    ClearTimer(NameOf(DoTTick));
    Destroy();
}

defaultProperties
{
}