AddCSLuaFile("shared.lua")

include("shared.lua")

sound.Add( {
	name = "buzz_sound",
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 35,
	pitch = {98, 102},
	sound = "weapons/medkit/buzz.wav"
} )

sound.Add( {
	name = "flesh_sound",
	channel = CHAN_BODY,
	volume = 1.0,
	level = 50,
	pitch = {97, 103},
	sound = "weapons/medkit/squirt.wav"
} )