if ( SERVER ) then

	AddCSLuaFile()
	
end


local StealthFireSound		= Sound ("weapons/dc15a_supressed_by_st.wav")
function SWEP:StealthFire()
	self.Primary.Recoil			= 0.8
	self.Primary.Damage			= 40
	self.Primary.NumShots		= 1
	self.Primary.Cone			= 0.0125
	self.Primary.ClipSize		= 50
	self.Primary.Delay			= 0.3
	self.Primary.DefaultClip	= 50
	self.Primary.Automatic		= true
	self.Primary.Ammo			= "ar2"
	self.Primary.Tracer 		= "effect_sw_laser_white"

	self.Weapon:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	
	if ( !self:CanPrimaryAttack() ) then return end
	
	self.Weapon:EmitSound( StealthFireSound )
	
	self:CSShootBullet( self.Primary.Damage, self.Primary.Recoil, self.Primary.NumShots, self.Primary.Cone )
	
	self:TakePrimaryAmmo( 5 )
	
	if ( self.Owner:IsNPC() ) then return end
	
	self.Owner:ViewPunch( Angle( math.Rand(-0.2,-0.1) * self.Primary.Recoil, math.Rand(-0.1,0.1) *self.Primary.Recoil, 0 ) )
	
	// In singleplayer this function doesn't get called on the client, so we use a networked float
	// to send the last shoot time. In multiplayer this is predicted clientside so we don't need to 
	// send the float.
	if ( (game.SinglePlayer() && SERVER) || CLIENT ) then
		self.Weapon:SetNetworkedFloat( "LastShootTime", CurTime() )
	end
end