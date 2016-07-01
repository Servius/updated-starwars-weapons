AddCSLuaFile("shared.lua")

include("shared.lua")

sound.Add( {
	name = "squirt_sound",
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 50,
	pitch = {97, 103},
	sound = "weapons/medkit/squirt.wav"
} )