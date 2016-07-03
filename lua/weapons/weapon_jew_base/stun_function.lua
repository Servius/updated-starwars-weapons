
if ( SERVER ) then

	AddCSLuaFile()
	
end

local StunSound = Sound ("weapons/sw_stun.wav")
local EmptyAmmo		= Sound("weapons/sw_noammo.wav")
local Phaseredrags = {}
local Phaseruniquetimer1 = 0
local disablePrintTime = 0

function SWEP:Stun()
	if weaponStun:GetBool() then
	self.Primary.Damage 		= 0
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

	if ( self:Clip1() < 10 ) then
		self.Weapon:EmitSound( EmptyAmmo )
		return
	end

	self.Weapon:EmitSound( StunSound )

	self:TakePrimaryAmmo( 10 )
	
	if ( self.Owner:IsNPC() ) then return end
	
	self.Owner:ViewPunch( Angle( math.Rand(-0.2,-0.1) * self.Primary.Recoil, math.Rand(-0.1,0.1) *self.Primary.Recoil, 0 ) )

	self:CSShootBullet( self.Primary.Damage, self.Primary.Recoil, self.Primary.NumShots, self.Primary.Cone )
	
	// In singleplayer this function doesn't get called on the client, so we use a networked float
	// to send the last shoot time. In multiplayer this is predicted clientside so we don't need to 
	// send the float.
	if ( (game.SinglePlayer() && SERVER) || CLIENT ) then
		self.Weapon:SetNetworkedFloat( "LastShootTime", CurTime() )
	end
	
 	local eyetrace = self.Owner:GetEyeTrace() 
 	if !eyetrace.Entity:IsPlayer() then 
  		if !eyetrace.Entity:IsNPC() then return end       // Check to see if what the player is aiming at is an NPC or Player
  	end
   
 	if (!SERVER) then return end 
 
 	if eyetrace.Entity:IsPlayer() then
		self:PhasePlayer(eyetrace.Entity)    // If the it is a player then bring them down tranqPlayer()
 	end
 	if eyetrace.Entity:IsNPC() then
 		self:PhaseNPC(eyetrace.Entity, self.Owner)    // If the it is a NPC then bring them down with tranqNPC()
 	end
	
	if ((game.SinglePlayer() and SERVER) or CLIENT) then
		self.Weapon:SetNetworkedFloat("LastShootTime", CurTime())
	end

	else
		if not CLIENT then return end
		if disablePrintTime > CurTime() then return end
		self.Owner:PrintMessage(HUD_PRINTTALK,"This server has disabled the stun mode!")
		disablePrintTime = CurTime() + 5
	end
end

function SWEP:PhasePlayer(ply)
	-- create ragdoll
	local rag = ents.Create( "prop_ragdoll" )
    if not rag:IsValid() then return end

	-- build rag
	rag:SetModel( ply:GetModel() )
    rag:SetKeyValue( "origin", ply:GetPos().x .. " " .. ply:GetPos().y .. " " .. ply:GetPos().z )
	rag:SetAngles(ply:GetAngles())
			
	-- player vars
	rag.Phaseredply = ply
	table.insert(Phaseredrags, rag)
		
	-- "remove" player
	ply:StripWeapons()
	ply:DrawViewModel(false)
	ply:DrawWorldModel(false)
	ply:Spectate(OBS_MODE_CHASE)
	ply:SpectateEntity(rag)
	
	-- finalize ragdoll
    rag:Spawn()
    rag:Activate()
	
	-- make ragdoll fall
	rag:GetPhysicsObject():SetVelocity(4*ply:GetVelocity())
	
	-- bring the motherfucker back

     self:setrevivedelay(rag)
	
end

function SWEP:PhaseNPC(npc, npcShooter)
	-- get info about npc
	local skin = npc:GetSkin()
	local wep = ""
	local possibleWep = ents.FindInSphere(npc:GetPos(),0.01) -- find anything in the center basically
	for k, v in pairs(possibleWep) do 
		if string.find(v:GetClass(),"weapon_") == 1 then 
			wep = v:GetClass()
		end
	end

	local citType = "" -- citizen type
	local citMed = 0 -- is it a medic? assume no
	if npc:GetClass() == "npc_citizen" then
		citType = string.sub(npc:GetModel(),21,21) -- get group number (e.g. models/humans/group0#/whatever)
		if string.sub(npc:GetModel(),22,22) == "m" then citMed = 1 end -- medic skins have an "m" after the number
	end

	-- make ragdoll now that all info is gathered	
	local rag = ents.Create( "prop_ragdoll" )
    if not rag:IsValid() then return end
	
	-- build rag
	rag:SetModel( npc:GetModel() )
    rag:SetKeyValue( "origin", npc:GetPos().x .. " " .. npc:GetPos().y .. " " .. npc:GetPos().z )
	rag:SetAngles(npc:GetAngles())
	
	-- npc vars
	rag.PhasewasNPC = true
	rag.PhasenpcType = npc:GetClass()
	rag.PhasenpcWep = wep
	rag.PhasenpcCitType = citType
	rag.PhasenpcCitMed = citMed
	rag.PhasenpcSkin = skin
	rag.PhasenpcShooter = npcShooter
	table.insert(Phaseredrags, rag)
	
	--finalize
	rag:Spawn()
    rag:Activate()
	
	-- make ragdoll fall
  rag:GetPhysicsObject():SetVelocity(8*npc:GetVelocity())
		
	--remove npc
	npc:Remove()

 self:setrevivedelay(rag)

	
end

function SWEP:setrevivedelay(rag)
if Phaseruniquetimer1 > 30 then
Phaseruniquetimer1 = 0
end
Phaseruniquetimer1 = Phaseruniquetimer1 + 1

timer.Create("revivedelay"..Phaseruniquetimer1, 25, 1, function() self:Phaserevive(rag) end)
end

function SWEP:Phaserevive(ent)
	-- revive player
	if !ent then return end
	
	if ent.Phaseredply then
   if ( !ent.Phaseredply:IsValid() ) then return end
   local phy = ent:GetPhysicsObject()
		phy:EnableMotion(false)
		ent:SetSolid(SOLID_NONE)
   	ent.Phaseredply:DrawViewModel(true)
	ent.Phaseredply:DrawWorldModel(true)
	ent.Phaseredply:Spawn()
	ent.Phaseredply:SetPos(ent:GetPos())
	ent.Phaseredply:SetVelocity(ent:GetPhysicsObject():GetVelocity())


	-- revive npc
	elseif ent.PhasewasNPC then
		local npc = ents.Create(ent.PhasenpcType) -- create the entity
		
		util.PrecacheModel(ent:GetModel()) -- precache the model
		npc:SetModel(ent:GetModel()) -- and set it
		local spawnPos = ent:GetPos()+Vector(0,0,0) -- position to spawn it
		
		npc:SetPos(spawnPos) -- position
		npc:SetSkin(ent.PhasenpcSkin)
		npc:SetAngles(Angle(0,ent:GetAngles().y,0))
		
		if ent.PhasenpcWep != "" then -- if it's an NPC and we found a weapon for it when it was spawned, then
			npc:SetKeyValue("additionalequipment",ent.PhasenpcWep) -- give it the weapon
		end
		
		if ent.PhaseentType == "npc_citizen" then
			npc:SetKeyValue("citizentype",ent.PhasenpcCitType) -- set the citizen type - rebel, refugee, etc.
			if ent.PhasenpcCitType == "3" && ent.PhasenpcCitMed==1 then -- if it's a rebel, then it might be a medic, so check that
				npc:SetKeyValue("spawnflags","131072") -- set medic spawn flag
			end
		end
				
		npc:Spawn()
		npc:Activate()
		
cleanup.Add (uplayer, "NPC", npc)

undo.Create ("Phasered NPC")
undo.AddEntity (npc)
undo.SetPlayer (ent.PhasenpcShooter)

undo.Finish()

		
	-- don't deal with other ents
	else 
		return
	end
	
		for k, v in pairs(Phaseredrags) do 
		if v == ent then 
			 table.remove( Phaseredrags, k ) 
		end
	end
	ent:Remove()

end