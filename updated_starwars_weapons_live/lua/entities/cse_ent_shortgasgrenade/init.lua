// this was a cse flashbang.

AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

local VirusTimer = Sound("weapons/bacta_bomb.wav")

function ENT:Initialize()

	self.Entity:SetModel("models/weapons/w_eq_flashbang.mdl")
	self.Entity:SetMaterial("models/weapons/v_models/grenades/virus_grenade")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Entity:DrawShadow( false )
	
	// Don't collide with the player
	// too bad this doesn't actually work.
	self.Entity:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	
	local phys = self.Entity:GetPhysicsObject()
	
	if (phys:IsValid()) then
		phys:Sleep()
	end
	
	self.timer = CurTime() + 3.5
	self.solidify = CurTime() + 1
	self.virusdelay = CurTime()
	self.Bastardgas = nil
	self.Spammed = false
end

function ENT:VirusCountdown()
	if self.virusdelay < CurTime() then
		self.virusdelay = CurTime() + 60
		self.Entity:EmitSound(VirusTimer)
	else return
	end
end

function ENT:Think()
	if (IsValid(self.Owner)==false) then
		self.Entity:Remove()
	end
	if (self.solidify<CurTime()) then
		self.SetOwner(self.Entity)
	end
	if self.timer < CurTime() then
		if !IsValid(self.Bastardgas) && !self.Spammed then
			self.Spammed = true
			self.Bastardgas = ents.Create("env_smoketrail")
			self.Bastardgas:SetOwner(self.Owner)
			self.Bastardgas:SetPos(self.Entity:GetPos())
			self.Bastardgas:SetKeyValue("spawnradius","256")
			self.Bastardgas:SetKeyValue("minspeed","0.5")
			self.Bastardgas:SetKeyValue("maxspeed","2")
			self.Bastardgas:SetKeyValue("startsize","16536")
			self.Bastardgas:SetKeyValue("endsize","256")
			self.Bastardgas:SetKeyValue("endcolor","0 0 255")
			self.Bastardgas:SetKeyValue("startcolor","0 0 255")
			self.Bastardgas:SetKeyValue("opacity","0.75")
			self.Bastardgas:SetKeyValue("spawnrate","20")
			self.Bastardgas:SetKeyValue("lifetime","6")
			self.Bastardgas:SetParent(self.Entity)
			self.Bastardgas:Spawn()
			self.Bastardgas:Activate()
			self.Bastardgas:Fire("turnon","", 0.1)
			local exp = ents.Create("env_explosion")
			exp:SetKeyValue("spawnflags",461)
			exp:SetPos(self.Entity:GetPos())
			exp:Spawn()
			exp:Fire("explode","",0)
			self.Entity:EmitSound(Sound("BaseSmokeEffect.Sound"))
		end

		local pos = self.Entity:GetPos()
		local maxrange = 256
		local maxstun = 10
		for k,v in pairs(ents.GetAll()) do
			local plpos = v:GetPos()
			local dist = -pos:Distance(plpos)+maxrange
			if (pos:Distance(plpos)<=maxrange) then
				local trace = {}
					trace.start = self.Entity:GetPos()
					trace.endpos = v:GetPos()+Vector(0,0,24)
					trace.filter = { v, self.Entity }
					trace.mask = COLLISION_GROUP_PLAYER
				tr = util.TraceLine(trace)
				
				function Poison(ent)
					if (ent:Health() >= 0) then
					ent:TakeDamage(5, self.Owner, "weapon_shadowvirus_grenade")
					end
				end
				
				if (tr.Fraction==1) and v:IsPlayer() then
					local stunamount = math.ceil(dist/(maxrange/maxstun))
					v:ViewPunch( Angle( stunamount*((math.random()*6)-2), stunamount*((math.random()*6)-2), stunamount*((math.random()*4)-1) ) )
					if not v.IsCoughing and math.random(1,6) == 2 then
					v:EmitSound("ambient/voices/cough"..(math.random(1,4))..".wav", 70)
					v.IsCoughing = true
					timer.Simple(3, function()
							if IsValid(v) then
								v.IsCoughing = nil
							end
						end)
					end
				end
				if (tr.Fraction==1) then
					Poison(v, self.Owner, "weapon_shadowvirus_grenade")
				end
			end
		end
		if (self.timer+60<CurTime()) then
			if IsValid(self.Bastardgas) then
				self.Bastardgas:Remove()
			end
		end
		if (self.timer+65<CurTime()) then
			self.Entity:Remove()
		end
		self.Entity:NextThink(CurTime()+0.5)
		return true
	else
		self.Entity:VirusCountdown()
	end
end

