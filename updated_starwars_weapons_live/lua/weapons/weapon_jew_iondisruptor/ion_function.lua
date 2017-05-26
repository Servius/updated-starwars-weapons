if SERVER then
	AddCSLuaFile("ion_function.lua")
end

function SWEP:Disruptor()
	self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
	self:SetNextPrimaryFire(CurTime() + 1.5)
	if (not self:CanPrimaryAttack()) then return end
	self:EmitSound("weapons/iondisruptor_fire.mp3")
	-- Emit the gun sound when you fire
	self.Owner:ViewPunch(Angle(math.Rand(-20, -0.1) * self.Primary.Recoil, math.Rand(-0.1, 0.1) * self.Primary.Recoil, 0))

	if SERVER then
		local trace = {}
		trace.start = self.Owner:GetShootPos()
		trace.endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 10 ^ 14

		trace.filter = function(ent)
			if (ent:GetClass() == "prop_physics") or self.Owner then return false end
		end

		local tr = util.TraceLine(trace)
		local vAng = (tr.HitPos - self.Owner:GetShootPos()):GetNormal():Angle()
		local dmginfo = DamageInfo()
		dmginfo:SetDamage(500)
		dmginfo:SetAttacker(self:GetOwner())
		dmginfo:SetInflictor(self)

		if (dmginfo.SetDamageType) then
			dmginfo:SetDamagePosition(tr.HitPos)
			dmginfo:SetDamageType(DMG_ENERGYBEAM)
		end

		if not tr.Entity:IsWorld() then
			tr.Entity:DispatchTraceAttack(dmginfo, tr.HitPos, tr.HitPos - vAng:Forward() * 20)
		end

		print(tr.Entity)
		tr.Entity:SetKeyValue("targetname", "disTarg")
		local dis = ents.Create("env_entity_dissolver")
		dis:SetKeyValue("magnitude", "5")
		dis:SetKeyValue("dissolvetype", "1")
		dis:SetKeyValue("target", "disTarg")
		dis:Spawn()
		dis:Fire("Dissolve", "disTarg", 0)
		dis:Fire("kill", "", 0)
	end

	self:TakePrimaryAmmo(1)
	self:CSShootBullet(self.Primary.Damage, self.Primary.Recoil, self.Primary.NumShots, self.Primary.Cone)

	if ((game.SinglePlayer() and SERVER) or CLIENT) then
		self:SetNetworkedFloat("LastShootTime", CurTime())
	end
end