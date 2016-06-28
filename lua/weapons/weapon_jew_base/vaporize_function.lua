if ( SERVER ) then

	AddCSLuaFile()
	
end

function SWEP:Vaporize()

	if weaponVaporize:GetBool() then

	self.Primary.Damage = 1000
	self.Primary.Recoil			= 0.75
	self.Primary.NumShots		= 1
	self.Primary.Cone			= 0.0125
	self.Primary.ClipSize		= 50
	self.Primary.Delay			= 1
	self.Primary.DefaultClip	= 50
	self.Primary.Automatic		= false
	self.Primary.Ammo			= "ar2"
	self.Primary.Tracer 		= "effect_sw_laser_red"

	self.Weapon:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
	self.Weapon:SetNextPrimaryFire( CurTime() + 1.5 )

	if ( !self:CanPrimaryAttack() ) then return end

	self.Weapon:EmitSound("weapons/phaser/tng_weapons_clean.wav", 150)
	-- Emit the gun sound when you fire

	self.Owner:ViewPunch( Angle( math.Rand(-20,-0.1) * self.Primary.Recoil, math.Rand(-0.1,0.1) *self.Primary.Recoil, 0 ) )

	if SERVER then
	
		local trace = {}
			trace.start = self.Owner:GetShootPos()
			trace.endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 10^14
			trace.filter = self.Owner 
		local tr = util.TraceLine(trace)
		
		local vAng = (tr.HitPos-self.Owner:GetShootPos()):GetNormal():Angle()
		
		local dmginfo = DamageInfo();
		dmginfo:SetDamage( 500 );
		dmginfo:SetAttacker( self:GetOwner() );
		dmginfo:SetInflictor( self );
		
		if( dmginfo.SetDamageType ) then
			dmginfo:SetDamagePosition( tr.HitPos );
			dmginfo:SetDamageType( DMG_ENERGYBEAM  );
		end
		
		tr.Entity:DispatchTraceAttack( dmginfo, tr.HitPos, tr.HitPos - vAng:Forward() * 20 );
		
		tr.Entity:SetKeyValue("targetname", "disTarg")
		local dis = ents.Create("env_entity_dissolver")
		dis:SetKeyValue("magnitude", "5")
		dis:SetKeyValue("dissolvetype", "0")
		dis:SetKeyValue("target", "disTarg")
		dis:Spawn()
		dis:Fire("Dissolve", "disTarg", 0)
		dis:Fire("kill", "", 0)

	end
	
	self:TakePrimaryAmmo(50)

	self:CSShootBullet( self.Primary.Damage, self.Primary.Recoil, self.Primary.NumShots, self.Primary.Cone )
	
	if ((game.SinglePlayer() and SERVER) or CLIENT) then
		self.Weapon:SetNetworkedFloat("LastShootTime", CurTime())
	end

	else
		self.Owner:PrintMessage(HUD_PRINTTALK,"This server has disabled the vaporize mode!")
	end
end