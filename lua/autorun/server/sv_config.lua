local vaporize_convar_flags = bit.bor(FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE)
weaponVaporize = CreateConVar("sw_enablevaporize","0",vaporize_convar_flags,"Enable/Disable the vaporize function for Updated Star Wars Weapons.")

local stun_convar_flags = bit.bor(FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE)
weaponStun = CreateConVar("sw_enablestun","1",stun_convar_flags,"Enable/Disable the stun function for Updated Star Wars Weapons.")

local scalpel_convar_flags = bit.bor(FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE)
scalpelHarm = CreateConVar("sw_scalpelharm","0",scalpal_convar_flags,"Enable/Disable the harm function for the vibro-scalpel.")