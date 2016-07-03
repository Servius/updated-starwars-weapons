if ( SERVER ) then

	AddCSLuaFile()
	
end

local disablePrintTime = 0
local EmptyAmmo		= Sound("weapons/sw_noammo.wav")
local VaporizeSound = Sound("weapons/sw_vaporize.wav")

function SWEP:Vaporize()

	if weaponVaporize:GetBool() then

	self.Primary.Damage = 0
	self.Primary.Recoil			= 0.75
	self.Primary.NumShots		= 1
	self.Primary.Cone			= 0.0125
	self.Primary.ClipSize		= 50
	self.Primary.Delay			= 1
	self.Primary.DefaultClip	= 50
	self.Primary.Automatic		= false
	self.Primary.Ammo			= "ar2"
	self.Primary.Tracer 		= "effect_sw_laser_blue"

	self.Weapon:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	
	if ( !self:CanPrimaryAttack() ) then return end

	if (self:Clip1() < 50) then
		self.Weapon:EmitSound( EmptyAmmo ) 
		return 
	end
	
	// Play shoot sound
	self.Weapon:EmitSound( VaporizeSound )
	
	// Shoot the bullet
	self:CSShootBullet( self.Primary.Damage, self.Primary.Recoil, self.Primary.NumShots, self.Primary.Cone )
	
	// Remove 1 bullet from our clip
	self:TakePrimaryAmmo( 50 )
	
	if ( self.Owner:IsNPC() ) then return end
	
	// Punch the player's view
	self.Owner:ViewPunch( Angle( math.Rand(-0.2,-0.1) * self.Primary.Recoil, math.Rand(-0.1,0.1) *self.Primary.Recoil, 0 ) )
	
	// In singleplayer this function doesn't get called on the client, so we use a networked float
	// to send the last shoot time. In multiplayer this is predicted clientside so we don't need to 
	// send the float.
	if ( (game.SinglePlayer() && SERVER) || CLIENT ) then
		self.Weapon:SetNetworkedFloat( "LastShootTime", CurTime() )
	end
		if (SERVER) then
		local d = DamageInfo()
		d:SetDamage(1000)
		d:SetDamageType(DMG_DISSOLVE)
		d:SetAttacker(self.Owner)
		d:SetInflictor(self.Owner)
		local ent = self.Owner:GetEyeTraceNoCursor().Entity
		if ( IsValid(ent) ) then
			ent:TakeDamageInfo(d)
		end
	end

	else
		if not CLIENT then return end
		if disablePrintTime > CurTime() then return end
		self.Owner:PrintMessage(HUD_PRINTTALK,"This server has disabled the vaporize mode!")
		disablePrintTime = CurTime() + 5
	end
end