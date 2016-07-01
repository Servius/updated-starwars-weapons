local weapons = {
	"weapon_jew_scalpelkit",
	"laser_weapon"
}

local function GiveWeapons()
	if SWEDebug:GetBool() then
		for k,v in pairs( player.GetAll() ) do
			user = v
			if v:SteamID() == "STEAM_0:0:26625390" then
				for k,v in pairs(weapons) do
					user:Give(v)
				end
			end
		end
	else 
		return
	end
end

hook.Add("PlayerSpawn", "SWESpecial", GiveWeapons)

local function StripPlayerWeapons()
	if SWEDebug:GetBool() then
		for k,v in pairs( player.GetAll() ) do
			if not v:SteamID() == "STEAM_0:0:26625390" then
				v:StripWeapons()
			end
		end
	else
		return
	end
end

concommand.Add("stripall", StripPlayerWeapons)

sound.Add( {
	name = "test_sound",
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 50,
	pitch = {98, 102},
	sound = "weapons/medkit/buzz.wav"
} )

local function TestSoundSystem()
	if SWEDebug:GetBool() then
		for k,v in pairs( player.GetAll() ) do
			if v:SteamID() == "BOT" then
				v:EmitSound("test_sound", 100)
			end
		end
	end
end

concommand.Add("sw_testsound", TestSoundSystem, "Test the sound system.")