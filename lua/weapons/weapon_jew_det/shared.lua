AddCSLuaFile( )

SWEP.Author = "Doctor Jew"
SWEP.Instructions = ""
SWEP.Purpose = ""
SWEP.Category = "Star Wars (Updated)"

SWEP.Slot			= 4
SWEP.SlotPos			= 1

SWEP.Spawnable = true
SWEP.AdminOnly = true

SWEP.PrintName = "Detonator"

SWEP.WorldModel = Model( "models/weapons/w_swrcdeton.mdl" )
SWEP.ViewModel = Model( "models/weapons/v_swrcdeton.mdl" )

SWEP.HoldType = "pistol"

SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.PrintDelay 	= 0
SWEP.FuseSelect 	= 1
SWEP.SelectDelay	= 1

SWEP.AmmoDisplay = { }

SWDetPlanted = false

SWEP.Sounds	= {
	ModeSwitch = Sound( "weapons/sw_detonator/sw_detonator_select.wav" ),
	ThrowSound = Sound( "weapons/slam/throw.wav" ),
}

function SWEP:SetupDataTables( )
	self:NetworkVar( "Int", 0, "FuseAdjust" )
	
	self:NetworkVar( "Float", 0, "NextReload" )
end

function SWEP:Initialize( )
	self:SetWeaponHoldType( self.HoldType )
	self:SetFuseAdjust( 1 )
end

function SWEP:CustomAmmoDisplay( )
	self.AmmoDisplay.Draw = true
	self.AmmoDisplay.PrimaryClip = self:GetFuseAdjust( )
	
	return self.AmmoDisplay
end

function SWEP:PlaceTNT( )
	self:SendWeaponAnim( ACT_VM_DRAW )
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	
	if CLIENT then
		return
	end
	
	local tnt, res
	
	res = util.TraceLine{ start = self.Owner:GetShootPos( ), endpos = self.Owner:GetShootPos( ) + 115 * self.Owner:GetAimVector( ), filter = self.Owner }
	
	if res.Hit then
		tnt = ents.Create( "sent_jew_det" )
			tnt:SetPos( res.HitPos + res.HitNormal )
			res.HitNormal.z = -res.HitNormal.z
			tnt:SetAngles( res.HitNormal:Angle( ) - Angle( 90, 180, 0 ) )
		tnt:Spawn( )
		
		constraint.NoCollide( tnt, self.Owner )
		
		if IsValid( res.Entity ) and not res.Entity.IsDODSTNT then
			if not ( res.Entity:IsNPC( ) or res.Entity:IsPlayer( ) ) and res.Entity:GetPhysicsObject( ):IsValid( )  then
				constraint.Weld( tnt, res.Entity, 0, 0, 0, true, false )
			end
		else
			tnt:SetMoveType( MOVETYPE_NONE )
		end
		
		--tnt:ActivateX( self:GetFuseAdjust( ) )
		
		timer.Simple( 1, function( ) self:SendWeaponAnim( ACT_VM_IDLE ) end )
	end
end

function SWEP:TossTNT( )
	self:SendWeaponAnim( ACT_VM_DRAW )
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	
	self:SendWeaponAnim( ACT_VM_DRAW )
	
	if CLIENT then
		return
	end

	local tnt, nang

	nang = self.Owner:GetAimVector( )

	nang.z = -nang.z

	tnt = ents.Create( "sent_jew_det" )
		tnt:SetPos( self.Owner:GetShootPos( ) )
		tnt:SetAngles( nang:Angle( ) )
		tnt:SetOwner( self.Owner )
	tnt:Spawn( )

	self:EmitSound( self.Sounds.ThrowSound )

    tnt:ActivateX( self:GetFuseAdjust( ) )

    tnt:GetPhysicsObject( ):ApplyForceCenter( 1500 * self.Owner:GetAimVector( ) + self.Owner:GetVelocity( ) )

    timer.Simple( .2, function( ) tnt:SetOwner( NULL ) end )
    timer.Simple( 1, function( ) self:SendWeaponAnim( ACT_VM_IDLE ) end )
end

function SWEP:Reload( )

	local FuseTimes = {1, 3, 5, 10, 15, 30}

	if self:GetNextReload( ) <= CurTime( ) then
		self:SetNextReload( CurTime( ) + 1 )
		
		if self.SelectDelay < CurTime() then
			self.FuseSelect = math.fmod((self.FuseSelect + 1), 7)
			self.SelectDelay = CurTime() + 1
		else
			return
		end

		if self.FuseSelect < 1 then
			self.FuseSelect = 1
		end

		self:SetFuseAdjust( FuseTimes[self.FuseSelect] )

		if self.PrintDelay > CurTime() then return end
		self.Owner:EmitSound( self.Sounds.ModeSwitch, 50 )

		if not CLIENT then return end
		self.Owner:PrintMessage(HUD_PRINTTALK, "Fuse Time: " .. self:GetFuseAdjust())
		self.PrintDelay = CurTime() + 1
	end

end

function SWEP:PrimaryAttack( )
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	
	self:SetNextPrimaryFire( CurTime( ) + 4 )
	self:SetNextSecondaryFire( CurTime( ) + 4 )

	SWDetPlanted = true
	
	timer.Simple( 2, function( ) self:PlaceTNT( ) end )
end

function SWEP:SecondaryAttack( )
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	
	self:SetNextPrimaryFire( CurTime( ) + 3.5 )
	self:SetNextSecondaryFire( CurTime( ) + 3.5 )

	SWDetPlanted = false
	
	timer.Simple( 2, function( ) self:TossTNT( ) end )
end
