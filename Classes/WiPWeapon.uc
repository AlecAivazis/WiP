class WiPWeapon extends Weapon;

// cached a typecasted version of owner
var WiPPawn cachedOwner;


// return the number of seconds in between attacks (based on owners attack speed/time)
simulated function float GetFireInterval( byte FireModeNum ){

    local float firingRate;
	local WiPPawnReplicationInfo pawnRepInfo;

	firingRate = cachedOwner.BaseAttackTime;
    // `log("Base firing rate ========================" @ firingRate);
    pawnRepInfo = WiPPawnReplicationInfo(cachedOwner.PlayerReplicationInfo);
    if (pawnRepInfo != none && pawnRepInfo.AttackSpeed > -1.f){
        firingRate /= (1.f + pawnRepInfo.AttackSpeed);
    // `log("Attack Speed ======================" @ pawnRepInfo.AttackSpeed);
    }

   // `log("Final firing rate =================" @firingRate);

    return firingRate;
}


// called when the weapon is given to a client
reliable client function ClientGivenTo (Pawn NewOwner, bool bDoNotActivate){
    Super.ClientGivenTo(NewOwner, bDoNotActivate);
    cachedOwner = (WiPPawn(NewOwner) != none) ? WiPPawn(NewOwner) : none;
}


defaultproperties
{

}