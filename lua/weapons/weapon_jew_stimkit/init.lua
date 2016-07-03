AddCSLuaFile("shared.lua")

include("shared.lua")

sound.Add( {
	name = "squirt_sound",
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 75,
	pitch = {97, 103},
	sound = "weapons/medkit/sw_syringe.wav"
} )