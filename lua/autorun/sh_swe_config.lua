local vaporize_convar_flags = bit.bor(FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE)
weaponVaporize = CreateConVar("swp_enable_vaporize","0",vaporize_convar_flags,"Enable/Disable the vaporize function for Updated Star Wars Weapons.")

local stun_convar_flags = bit.bor(FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE)
weaponStun = CreateConVar("swp_enable_stun","0",stun_convar_flags,"Enable/Disable the stun function for Updated Star Wars Weapons.")

local scalpel_convar_flags = bit.bor(FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE)
scalpelHarm = CreateConVar("sw_scalpel_harm","0",scalpel_convar_flags,"Enable/Disable the harm function for the vibro-scalpel.")

local debug_convar_flags = bit.bor(FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE)
SWEDebug = CreateConVar("sw_debug_mode","0",debug_convar_flags,"Enable/Disable debug mode for Updated Star Wars Weapons.")