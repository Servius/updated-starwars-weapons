AddCSLuaFile("shared.lua")

include("shared.lua")

sound.Add( {
	name = "buzz_sound",
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 50,
	pitch = {150, 154},
	sound = "ambient/machines/pneumatic_drill_2.wav"
} )

sound.Add( {
	name = "flesh_sound",
	channel = CHAN_BODY,
	volume = 1.0,
	level = 50,
	pitch = {97, 103},
	sound = "weapons/medkit/sw_syringe.wav"
} )

sound.Add( {
	name = "startup",
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 35,
	pitch = 100,
	sound = "weapons/sw_startup.wav"
} )

sound.Add( {
	name = "shutdown",
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 35,
	pitch = 100,
	sound = "weapons/sw_shutdown.wav"
} )