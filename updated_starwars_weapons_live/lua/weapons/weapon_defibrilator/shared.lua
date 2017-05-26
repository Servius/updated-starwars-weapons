AddCSLuaFile("shared.lua")

if SERVER then
	util.AddNetworkString("shockEffect")
	AddCSLuaFile("cl_init.lua")
end

if CLIENT then
	SWEP.PrintName = "Defibrillator"
	SWEP.Author = "Custom & Doctor Jew"
	SWEP.Slot = 2
	SWEP.SlotPos = 1
end

function SWEP:Initialize()
	self:SetWeaponHoldType("knife")
	self.CanUse = CurTime()
	self.LastTrack = CurTime() - 20
	self:SetupDataTables()
end

SWEP.Instructions = "Left click to revive.\n Right click to charge."
SWEP.UseHands = true
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.Category = "Other"
SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false
SWEP.AnimPrefix = "rpg"
SWEP.Primary.Damage = 0
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.WorldModel = Model("models/weapons/custom/w_defib.mdl")
SWEP.ViewModel = Model("models/weapons/custom/v_defib.mdl")
SWEP.Indicator = 0
SWEP.RespawnHealth = 50
SWEP.PrintDelay = 0

function SWEP:Deploy()
	self:SetWeaponHoldType("knife")
	self.Indicator = CurTime() - 1

	if CLIENT then
		self:SetWeaponHoldType("knife")
	end

	return true
end

net.Receive("shockEffect", function()
	local ent = net.ReadEntity()
	local owner = net.ReadEntity()
	if not IsValid(ent) then return end
	local pos = 5

	if ent:IsPlayer() then
		pos = 40
	end

	local effect = EffectData()
	effect:SetEntity(ent)
	effect:SetStart(ent:GetPos())
	effect:SetOrigin(ent:GetPos() + Vector(0, 0, pos))
	effect:SetNormal(Vector(0, 0, 1))
	util.Effect("StunstickImpact", effect)
	if not IsValid(owner) then return end
	local effectdata = EffectData()
	local hitpos = owner:GetEyeTrace().HitPos
	effectdata:SetOrigin(hitpos)
	effectdata:SetStart(owner:GetShootPos())
	util.Effect("ToolTracer", effectdata)
end)

function SWEP:TrySpawn(ent, ply)
	net.Start("shockEffect")
	net.WriteEntity(ent)
	net.WriteEntity(self.Owner)
	net.Broadcast()
	ent.RespawnCounter = ent.RespawnCounter + 1
	local times = ent.DieTime
	local count = ent.RespawnCounter
	local needCount = 2 + math.floor((CurTime() - times) / 100) - count

	if count >= needCount then
		timer.Simple(0.3, function()
			if IsValid(ply) then
				ply:Spawn()
				ply:SetPos(ent:GetPos())
				ply:SetHealth(self.RespawnHealth)
			end
		end)
	end
end

function SWEP:PrimaryAttack()
	self:SetWeaponHoldType("knife")
	if CurTime() >= self.Indicator then return end
	self:SetNextPrimaryFire(CurTime() + 1.5)
	local ent = self.Owner:GetEyeTrace().Entity
	local dist = self.Owner:GetPos():Distance(ent:GetPos())
	local chance = math.random(1, 10)

	if IsValid(ent) and ent:IsRagdoll() and dist < 60 then
		ent:EmitSound("weapons/physcannon/superphys_small_zap" .. math.random(1, 4) .. ".wav")
		self.Indicator = CurTime() - 1
		self:SetIndicator(self.Indicator)
		self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)

		if not chance then
			self.Owner:SetAnimation(PLAYER_ATTACK1)

			--self.Owner:PrintMessage(HUD_PRINTTALK, "Defibrillation failed!")
			if CLIENT then
				chat.AddText(Color(255, 25, 25), "DEFIBRILLATION FAILED!")
			end

			return
		end

		if SERVER then
			local targ = ent.Owner
			if not IsValid(targ) then return end

			if ent ~= nil and ent:IsValid() and ent.SleepRagdoll == nil then
				self:TrySpawn(ent, targ)
			end
		end
	end

	--self:GetTargets()

	self.Owner:SetAnimation(PLAYER_ATTACK1)
end

function SWEP:GetTargets()
	for k,v in pairs(player.GetAll()) do
		if v:GetPos():Distance(self.Owner:GetPos()) < 80 and v:WaterLevel() >= 1 then
			self:Shock(v)
		end
	end
end

function Electrocute(v)
	local victim = v

	if SERVER then
		print(victim)
		local dmginfo = DamageInfo()
		dmginfo:SetDamage(500)
		--dmginfo:SetAttacker(self:GetOwner())
		--dmginfo:SetInflictor(self)

		if (dmginfo.SetDamageType) then
			dmginfo:SetDamagePosition(victim:GetPos())
			dmginfo:SetDamageType(DMG_DISSOLVE)
		end
		victim:TakeDamageInfo(dmginfo)

		victim:SetName("disTarg")
		local dis = ents.Create("env_entity_dissolver")
		dis:SetKeyValue("magnitude", "5")
		dis:SetKeyValue("dissolvetype", "1")
		dis:SetKeyValue("target", "disTarg")
		dis:Spawn()
		dis:Fire("Dissolve", "disTarg", 0)
		dis:Fire("kill", "", 0.1)
	end
end

function SWEP:SecondaryAttack()
	if (CurTime() > self.Indicator) and (self.PrintDelay < CurTime()) then
		local ent = self.Owner:GetEyeTrace().Entity
		local dist = self.Owner:GetPos():Distance(ent:GetPos())
		self:SetNextSecondaryFire(CurTime() + 3)
		self.PrintDelay = CurTime() + 3

		if IsValid(ent) and dist < 80 then
			if CLIENT then
				--self.Owner:PrintMessage(HUD_PRINTTALK, "ANALYZING HEART RHYTHM...")
				chat.AddText(Color(255, 166, 0), "ANALYZING HEART RHYTHM...")
			end

			timer.Simple(1, function()
				if ent:IsPlayer() then
					if CLIENT then
						--self.Owner:PrintMessage(HUD_PRINTTALK, "SHOCK NOT ADVISED...")
						chat.AddText(Color(255, 25, 25), "SHOCK NOT ADVISED...")
					end

					return
				end

				if ent:IsRagdoll() then
					if CLIENT then
						--self.Owner:PrintMessage(HUD_PRINTTALK, "SHOCK ADVISED...")
						chat.AddText(Color(25, 255, 25), "SHOCK ADVISED...")
					end

					timer.Simple(0.5, function()
						if CLIENT then
							--self.Owner:PrintMessage(HUD_PRINTTALK, "CHARGING...")
							chat.AddText(Color(255, 166, 0), "CHARGING...")
						end

						self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)

						timer.Simple(0.75, function()
							if IsValid(self) then
								self.Indicator = CurTime() + 5
								self:SetIndicator(self.Indicator)
								self:EmitSound("buttons/button1.wav", 50)
							end

							if CLIENT then
								--self.Owner:PrintMessage(HUD_PRINTTALK, "DELIVER SHOCK NOW...")
								chat.AddText(Color(25, 255, 25), "DELIVER SHOCK NOW...")
							end
						end)
					end)
				else
					return
				end
			end)
		else
			if CLIENT then
				--self.Owner:PrintMessage(HUD_PRINTTALK, "NO PATIENT FOUND...")
				chat.AddText(Color(255, 25, 25), "NO PATIENT FOUND...")
			end
		end
	end
end

SWEP.OnceReload = false

function SWEP:Reload()
	--self.Owner:PrintMessage(3, "Water Level: " .. self.Owner:WaterLevel())
	--self:Shock(self.Owner)
	--local class = self.Owner:GetClass()
	--print(class)
end

if CLIENT then
	function SWEP:ViewModelDrawn()
		local vm = self.Owner:GetViewModel()
		if not IsValid(vm) then return end
		local bone = vm:LookupBone("defib_right")
		if (not bone) then return end
		pos, ang = Vector(0, 0, 0), Angle(0, 0, 0)
		local m = vm:GetBoneMatrix(bone)

		if (m) then
			pos, ang = m:GetTranslation(), m:GetAngles()
		else
			return
		end

		ang:RotateAroundAxis(ang:Forward(), -90)
		ang:RotateAroundAxis(ang:Right(), 0)
		ang:RotateAroundAxis(ang:Up(), 0)
		cam.Start3D2D(pos + ang:Right() * -1.72 + ang:Up() * -1 + ang:Forward() * -2.1, ang, 0.1)
		self:DrawScreen(0, 0, 65, 123)
		cam.End3D2D()
	end

	function SWEP:DrawScreen(x, y, w, h)
		local power = self:GetIndicator()
		local color = Color(255, 25, 25)

		if (power > CurTime()) then
			color = Color(25, 255, 25)
		end

		--draw.RoundedBox( 0,0,0,6,10,Color(25,25,25,255))
		draw.RoundedBox(0, 1, 0, 2, 6, color)
	end
end

function SWEP:SetupDataTables()
	self:NetworkVar("Float", 0, "Indicator")
end