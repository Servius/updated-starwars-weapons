local vaporize_convar_flags = bit.bor(FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE)
weaponVaporize = CreateConVar("sv_enablevaporize","0",convar_flags,"Enable/Disable the vaporize function for Updated Star Wars Weapons")

local stun_convar_flags = bit.bor(FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE)
weaponStun = CreateConVar("sv_enablestun","1",convar_flags,"Enable/Disable the stun function for Updated Star Wars Weapons")