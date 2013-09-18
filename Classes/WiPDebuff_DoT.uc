class WiPDebuff_DoT extends WiPDebuff;

// the time in between ticks
var(Debuff) const array<float> TickTime;
// the damage of the spell (before modifiers)
var(Debuff) const array<float> Damages;
// the damage multipliers (a percentage of ability power)
var(Debuff) const array<float> Multipliers;
// the damage type of the spell
var(Debuff) class<DamageType> MyDamageType;

simulated function Activate(WiPPawn dotTarget){

    Super.Activate(dotTarget);

    SetTimer(GetTickTime(), true, NameOf(DoTTick));
}

// damage the target for Damage/Duration
simulated function DoTTick(){

    local float TickDamage;

    // The damage per tick is the total damage dividded by the number of ticks
    TickDamage =  GetTotalDamage()/(GetDuration()/GetTickTime());

    `log("Debuff tick" @ target);

     Target.TakeDamage(TickDamage , source.caster.Controller , target.Location,Source.MomentumTransfer * Normal(Velocity), Source.MyDamageType,, self);
}

simulated function float GetTotalDamage(){
    return Damages[Level-1];
}

// return the time in between ticks
simulated function float GetTickTime(){
    return TickTime[Level-1];
}

simulated function Deactivate(){
    ClearTimer(NameOf(DoTTick));
    Super.Deactivate();
}


defaultproperties
{}