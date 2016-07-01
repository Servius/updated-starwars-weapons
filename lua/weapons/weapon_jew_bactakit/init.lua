AddCSLuaFile("shared.lua")

include("shared.lua")

sound.Add( {
	name = "use_bacta",
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 30,
	pitch = {95, 110},
	sound = "weapons/medkit/use_bacta.wav"
} )