if (SERVER) then
	AddCSLuaFile("shared.lua")
end

if (CLIENT) then
	SWEP.PrintName = "EMP Rifle"
	SWEP.Author = "Doctor Jew"
	SWEP.ViewModelFOV = 50
	SWEP.Slot = 2
	SWEP.SlotPos = 3
	SWEP.WepSelectIcon = surface.GetTextureID("HUD/killicons/emp_rifle")
	killicon.Add("weapon_jew_emp_rifle", "HUD/killicons/emp_rifle", Color(255, 80, 0, 255))
end

SWEP.HoldType = "ar2"
SWEP.Base = "weapon_jew_base"
SWEP.Category = "Star Wars (Updated)"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.ViewModel = "models/weapons/jew/c_emprifle.mdl"
SWEP.WorldModel = "models/weapons/jew/w_emprifle.mdl"
SWEP.ViewModelFOV = 55
SWEP.ViewModelFlip = false
SWEP.UseHands = true
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = true
SWEP.Weight = 8
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
local FireSound = Sound("weapons/ca88_fire.mp3")
local ReloadSound = Sound("weapons/synbf3/e11_reload.wav")
local EmptySound = Sound("weapons/sw_noammo.wav")
local DeploySound = Sound("weapons/sw_change.wav")
SWEP.Primary.Recoil = 0.6
SWEP.Primary.Damage = 30
SWEP.Primary.NumShots = 6
SWEP.Primary.Cone = 0.15
SWEP.Primary.ClipSize = 5
SWEP.Primary.Delay = 0.25
SWEP.Primary.DefaultClip = 25
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "ar2"
SWEP.Primary.Tracer = "tooltracer"
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.IronSightsPos = Vector(-2.175, -16.157, 2.559)
SWEP.IronSightsAng = Vector(-31.567, -4.079, 0)

function SWEP:Precache()
	util.PrecacheSound("weapons/ca88_fire.mp3")
	util.PrecacheSound("weapons/synbf3/e11_reload.wav")
	util.PrecacheSound("weapons/sw_noammo.wav")
end

function SWEP:Deploy()
	self:EmitSound(DeploySound)
end

function SWEP:PrimaryAttack()
	self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	if (not self:CanPrimaryAttack()) then return end

	if self:Clip1() < 1 then
		self:EmitSound(EmptyAmmo)

		return
	end

	self:EmitSound(FireSound)
	self:CSShootBullet(self.Primary.Damage, self.Primary.Recoil, self.Primary.NumShots, self.Primary.Cone)
	self:TakePrimaryAmmo(1)
	if (self.Owner:IsNPC()) then return end
	self.Owner:ViewPunch(Angle(math.Rand(-0.2, -0.1) * self.Primary.Recoil, math.Rand(-0.1, 0.1) * self.Primary.Recoil, 0))

	-- In singleplayer this function doesn't get called on the client, so we use a networked float
	-- to send the last shoot time. In multiplayer this is predicted clientside so we don't need to 
	-- send the float.
	if ((game.SinglePlayer() and SERVER) or CLIENT) then
		self:SetNetworkedFloat("LastShootTime", CurTime())
	end
end

function SWEP:SecondaryAttack()
	if self:GetNWBool("Ironsights") then
		self:SetNWBool("Ironsights", false)
		self.Owner:GetViewModel():SetNoDraw(false)
		self.Owner:SetFOV(0, 0.25)
		self:AdjustMouseSensitivity()
	elseif not self:GetNWBool("Ironsights") then
		self:SetNWBool("Ironsights", true)
		self.Owner:GetViewModel():SetNoDraw(true)
		self.Owner:SetFOV(10, 0.25)
		self:AdjustMouseSensitivity()
	end
end

function SWEP:CSShootBullet(dmg, recoil, numbul, cone)
	numbul = numbul or 1
	cone = cone or 0.01
	local bullet = {}
	bullet.Num = numbul
	bullet.Src = self.Owner:GetShootPos() -- Source
	bullet.Dir = self.Owner:GetAimVector() -- Dir of bullet
	bullet.Spread = Vector(cone, cone, 0) -- Aim Cone
	bullet.Tracer = 1 -- Show a tracer on every x bullets 
	bullet.TracerName = self.Primary.Tracer
	bullet.Force = 5 -- Amount of force to give to phys objects
	bullet.Damage = dmg
	self.Owner:FireBullets(bullet)
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK) -- View model animation
	self.Owner:MuzzleFlash() -- Crappy muzzle light
	self.Owner:SetAnimation(PLAYER_ATTACK1) -- 3rd Person Animation
	if (self.Owner:IsNPC()) then return end

	-- CUSTOM RECOIL !
	if ((game.SinglePlayer() and SERVER) or (not game.SinglePlayer() and CLIENT and IsFirstTimePredicted())) then
		local eyeang = self.Owner:EyeAngles()
		eyeang.pitch = eyeang.pitch - recoil
		self.Owner:SetEyeAngles(eyeang)
	end
end

function SWEP:FireAnimationEvent(position, angles, event, options)
	-- Disables shell ejection
	if (event == 6001) then return true end
end

function SWEP:Reload()
	if (self:Clip1() < self.Primary.ClipSize) then
		if self.Owner:GetAmmoCount(self.Primary.Ammo) > 0 then
			self:EmitSound(ReloadSound)
		end

		self:DefaultReload(ACT_VM_RELOAD)
		self:SetIronsights(false)
	end
end

function SWEP:AdjustMouseSensitivity()
	if self:GetNWBool("Ironsights") then
		return 0.25
	else
		if not self:GetNWBool("Ironsights") then return -1 end
	end
end

function SWEP:DrawHUD()
	if (CLIENT) then
		if not self:GetNWBool("Ironsights") then
			local x, y

			if (self.Owner == LocalPlayer() and self.Owner:ShouldDrawLocalPlayer()) then
				local tr = util.GetPlayerTrace(self.Owner)
				--				tr.mask = ( CONTENTS_SOLID|CONTENTS_MOVEABLE|CONTENTS_MONSTER|CONTENTS_WINDOW|CONTENTS_DEBRIS|CONTENTS_GRATE|CONTENTS_AUX )
				local trace = util.TraceLine(tr)
				local coords = trace.HitPos:ToScreen()
				x, y = coords.x, coords.y
			else
				x, y = ScrW() / 2.0, ScrH() / 2.0
			end

			local scale = 10 * self.Primary.Cone
			local LastShootTime = self:GetNetworkedFloat("LastShootTime", 0)
			scale = scale * (2 - math.Clamp((CurTime() - LastShootTime) * 5, 0.0, 1.0))
			surface.SetDrawColor(255, 0, 0, 255)
			local gap = 40 * scale
			local length = gap + 20 * scale
			surface.DrawLine(x - length, y, x - gap, y)
			surface.DrawLine(x + length, y, x + gap, y)
			surface.DrawLine(x, y - length, x, y - gap)
			surface.DrawLine(x, y + length, x, y + gap)

			return
		end

		local Scale = ScrH() / 480
		local w, h = 320 * Scale, 240 * Scale
		local cx, cy = ScrW() / 2, ScrH() / 2
		local scope_sniper_lr = surface.GetTextureID("sprites/scopes/752/scope_synbf3_lr")
		local scope_sniper_ll = surface.GetTextureID("sprites/scopes/752/scope_synbf3_ll")
		local scope_sniper_ul = surface.GetTextureID("sprites/scopes/752/scope_synbf3_ul")
		local scope_sniper_ur = surface.GetTextureID("sprites/scopes/752/scope_synbf3_ur")
		local SNIPERSCOPE_MIN = -0.75
		local SNIPERSCOPE_MAX = -2.782
		local SNIPERSCOPE_SCALE = 0.4
		local x = ScrW() / 2.0
		local y = ScrH() / 2.0
		surface.SetDrawColor(0, 0, 0, 255)
		local gap = 0
		local length = gap + 9999
		surface.SetDrawColor(0, 0, 0, 255)
		surface.DrawLine(x - length, y, x - gap, y)
		surface.DrawLine(x + length, y, x + gap, y)
		surface.DrawLine(x, y - length, x, y - gap)
		surface.DrawLine(x, y + length, x, y + gap)
		render.UpdateRefractTexture()
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetTexture(scope_sniper_lr)
		surface.DrawTexturedRect(cx, cy, w, h)
		surface.SetTexture(scope_sniper_ll)
		surface.DrawTexturedRect(cx - w, cy, w, h)
		surface.SetTexture(scope_sniper_ul)
		surface.DrawTexturedRect(cx - w, cy - h, w, h)
		surface.SetTexture(scope_sniper_ur)
		surface.DrawTexturedRect(cx, cy - h, w, h)
		surface.SetDrawColor(0, 0, 0, 255)

		if cx - w > 0 then
			surface.DrawRect(0, 0, cx - w, ScrH())
			surface.DrawRect(cx + w, 0, cx - w, ScrH())
		end
	end
end

--[[*******************************************************
	SWEP Construction Kit base code
		Created by Clavus
	Available for public use, thread at:
	   facepunch.com/threads/1032378

	DESCRIPTION:
		This script is meant for experienced scripters 
		that KNOW WHAT THEY ARE DOING. Don't come to me 
		with basic Lua questions.

		Just copy into your SWEP or SWEP base of choice
		and merge with your own code.

		The SWEP.VElements, SWEP.WElements and
		SWEP.ViewModelBoneMods tables are all optional
		and only have to be visible to the client.
*******************************************************]]
function SWEP:Initialize()
	self:SetWeaponHoldType(self.HoldType)

	if CLIENT then
		-- Create a new table for every weapon instance
		self.VElements = table.FullCopy(self.VElements)
		self.WElements = table.FullCopy(self.WElements)
		self.ViewModelBoneMods = table.FullCopy(self.ViewModelBoneMods)
		self:CreateModels(self.VElements) -- create viewmodels
		self:CreateModels(self.WElements) -- create worldmodels

		-- init view model bone build function
		if IsValid(self.Owner) then
			local vm = self.Owner:GetViewModel()

			if IsValid(vm) then
				self:ResetBonePositions(vm)

				-- Init viewmodel visibility
				if (self.ShowViewModel == nil or self.ShowViewModel) then
					vm:SetColor(Color(255, 255, 255, 255))
				else
					-- we set the alpha to 1 instead of 0 because else ViewModelDrawn stops being called
					vm:SetColor(Color(255, 255, 255, 1))
					-- ^ stopped working in GMod 13 because you have to do Entity:SetRenderMode(1) for translucency to kick in
					-- however for some reason the view model resets to render mode 0 every frame so we just apply a debug material to prevent it from drawing
					vm:SetMaterial("Debug/hsv")
				end
			end
		end
	end
end

function SWEP:Holster()
	if CLIENT and IsValid(self.Owner) then
		local vm = self.Owner:GetViewModel()

		if IsValid(vm) then
			self:ResetBonePositions(vm)
		end
	end

	return true
end

function SWEP:OnRemove()
	self:Holster()
end

if CLIENT then
	SWEP.vRenderOrder = nil

	function SWEP:ViewModelDrawn()
		local vm = self.Owner:GetViewModel()
		if not IsValid(vm) then return end
		if (not self.VElements) then return end
		self:UpdateBonePositions(vm)

		if (not self.vRenderOrder) then
			-- we build a render order because sprites need to be drawn after models
			self.vRenderOrder = {}

			for k, v in pairs(self.VElements) do
				if (v.type == "Model") then
					table.insert(self.vRenderOrder, 1, k)
				elseif (v.type == "Sprite" or v.type == "Quad") then
					table.insert(self.vRenderOrder, k)
				end
			end
		end

		for k, name in ipairs(self.vRenderOrder) do
			local v = self.VElements[name]

			if (not v) then
				self.vRenderOrder = nil
				break
			end

			if (v.hide) then continue end
			local model = v.modelEnt
			local sprite = v.spriteMaterial
			if (not v.bone) then continue end
			local pos, ang = self:GetBoneOrientation(self.VElements, v, vm)
			if (not pos) then continue end

			if (v.type == "Model" and IsValid(model)) then
				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z)
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				model:SetAngles(ang)
				--model:SetModelScale(v.size)
				local matrix = Matrix()
				matrix:Scale(v.size)
				model:EnableMatrix("RenderMultiply", matrix)

				if (v.material == "") then
					model:SetMaterial("")
				elseif (model:GetMaterial() ~= v.material) then
					model:SetMaterial(v.material)
				end

				if (v.skin and v.skin ~= model:GetSkin()) then
					model:SetSkin(v.skin)
				end

				if (v.bodygroup) then
					for k, v in pairs(v.bodygroup) do
						if (model:GetBodygroup(k) ~= v) then
							model:SetBodygroup(k, v)
						end
					end
				end

				if (v.surpresslightning) then
					render.SuppressEngineLighting(true)
				end

				render.SetColorModulation(v.color.r / 255, v.color.g / 255, v.color.b / 255)
				render.SetBlend(v.color.a / 255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)

				if (v.surpresslightning) then
					render.SuppressEngineLighting(false)
				end
			elseif (v.type == "Sprite" and sprite) then
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				render.SetMaterial(sprite)
				render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
			elseif (v.type == "Quad" and v.draw_func) then
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				cam.Start3D2D(drawpos, ang, v.size)
				v.draw_func(self)
				cam.End3D2D()
			end
		end
	end

	SWEP.wRenderOrder = nil

	function SWEP:DrawWorldModel()
		if (self.ShowWorldModel == nil or self.ShowWorldModel) then
			self:DrawModel()
		end

		if (not self.WElements) then return end

		if (not self.wRenderOrder) then
			self.wRenderOrder = {}

			for k, v in pairs(self.WElements) do
				if (v.type == "Model") then
					table.insert(self.wRenderOrder, 1, k)
				elseif (v.type == "Sprite" or v.type == "Quad") then
					table.insert(self.wRenderOrder, k)
				end
			end
		end

		if (IsValid(self.Owner)) then
			bone_ent = self.Owner
		else
			-- when the weapon is dropped
			bone_ent = self
		end

		for k, name in pairs(self.wRenderOrder) do
			local v = self.WElements[name]

			if (not v) then
				self.wRenderOrder = nil
				break
			end

			if (v.hide) then continue end
			local pos, ang

			if (v.bone) then
				pos, ang = self:GetBoneOrientation(self.WElements, v, bone_ent)
			else
				pos, ang = self:GetBoneOrientation(self.WElements, v, bone_ent, "ValveBiped.Bip01_R_Hand")
			end

			if (not pos) then continue end
			local model = v.modelEnt
			local sprite = v.spriteMaterial

			if (v.type == "Model" and IsValid(model)) then
				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z)
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				model:SetAngles(ang)
				--model:SetModelScale(v.size)
				local matrix = Matrix()
				matrix:Scale(v.size)
				model:EnableMatrix("RenderMultiply", matrix)

				if (v.material == "") then
					model:SetMaterial("")
				elseif (model:GetMaterial() ~= v.material) then
					model:SetMaterial(v.material)
				end

				if (v.skin and v.skin ~= model:GetSkin()) then
					model:SetSkin(v.skin)
				end

				if (v.bodygroup) then
					for k, v in pairs(v.bodygroup) do
						if (model:GetBodygroup(k) ~= v) then
							model:SetBodygroup(k, v)
						end
					end
				end

				if (v.surpresslightning) then
					render.SuppressEngineLighting(true)
				end

				render.SetColorModulation(v.color.r / 255, v.color.g / 255, v.color.b / 255)
				render.SetBlend(v.color.a / 255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)

				if (v.surpresslightning) then
					render.SuppressEngineLighting(false)
				end
			elseif (v.type == "Sprite" and sprite) then
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				render.SetMaterial(sprite)
				render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
			elseif (v.type == "Quad" and v.draw_func) then
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				cam.Start3D2D(drawpos, ang, v.size)
				v.draw_func(self)
				cam.End3D2D()
			end
		end
	end

	function SWEP:GetBoneOrientation(basetab, tab, ent, bone_override)
		local bone, pos, ang

		if (tab.rel and tab.rel ~= "") then
			local v = basetab[tab.rel]
			if (not v) then return end
			-- Technically, if there exists an element with the same name as a bone
			-- you can get in an infinite loop. Let's just hope nobody's that stupid.
			pos, ang = self:GetBoneOrientation(basetab, v, ent)
			if (not pos) then return end
			pos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
			ang:RotateAroundAxis(ang:Up(), v.angle.y)
			ang:RotateAroundAxis(ang:Right(), v.angle.p)
			ang:RotateAroundAxis(ang:Forward(), v.angle.r)
		else
			bone = ent:LookupBone(bone_override or tab.bone)
			if (not bone) then return end
			pos, ang = Vector(0, 0, 0), Angle(0, 0, 0)
			local m = ent:GetBoneMatrix(bone)

			if (m) then
				pos, ang = m:GetTranslation(), m:GetAngles()
			end

			if (IsValid(self.Owner) and self.Owner:IsPlayer() and ent == self.Owner:GetViewModel() and self.ViewModelFlip) then
				ang.r = -ang.r -- Fixes mirrored models
			end
		end

		return pos, ang
	end

	function SWEP:CreateModels(tab)
		if (not tab) then return end

		-- Create the clientside models here because Garry says we can't do it in the render hook
		for k, v in pairs(tab) do
			if (v.type == "Model" and v.model and v.model ~= "" and (not IsValid(v.modelEnt) or v.createdModel ~= v.model) and string.find(v.model, ".mdl") and file.Exists(v.model, "GAME")) then
				v.modelEnt = ClientsideModel(v.model, RENDER_GROUP_VIEW_MODEL_OPAQUE)

				if (IsValid(v.modelEnt)) then
					v.modelEnt:SetPos(self:GetPos())
					v.modelEnt:SetAngles(self:GetAngles())
					v.modelEnt:SetParent(self)
					v.modelEnt:SetNoDraw(true)
					v.createdModel = v.model
				else
					v.modelEnt = nil
				end
			elseif (v.type == "Sprite" and v.sprite and v.sprite ~= "" and (not v.spriteMaterial or v.createdSprite ~= v.sprite) and file.Exists("materials/" .. v.sprite .. ".vmt", "GAME")) then
				local name = v.sprite .. "-"

				local params = {
					["$basetexture"] = v.sprite
				}

				-- make sure we create a unique name based on the selected options
				local tocheck = {"nocull", "additive", "vertexalpha", "vertexcolor", "ignorez"}

				for i, j in pairs(tocheck) do
					if (v[j]) then
						params["$" .. j] = 1
						name = name .. "1"
					else
						name = name .. "0"
					end
				end

				v.createdSprite = v.sprite
				v.spriteMaterial = CreateMaterial(name, "UnlitGeneric", params)
			end
		end
	end

	local allbones
	local hasGarryFixedBoneScalingYet = false

	function SWEP:UpdateBonePositions(vm)
		if self.ViewModelBoneMods then
			if (not vm:GetBoneCount()) then return end
			-- !! WORKAROUND !! //
			-- We need to check all model names :/
			local loopthrough = self.ViewModelBoneMods

			if (not hasGarryFixedBoneScalingYet) then
				allbones = {}

				for i = 0, vm:GetBoneCount() do
					local bonename = vm:GetBoneName(i)

					if (self.ViewModelBoneMods[bonename]) then
						allbones[bonename] = self.ViewModelBoneMods[bonename]
					else
						allbones[bonename] = {
							scale = Vector(1, 1, 1),
							pos = Vector(0, 0, 0),
							angle = Angle(0, 0, 0)
						}
					end
				end

				loopthrough = allbones
			end

			-- !! ----------- !! //
			for k, v in pairs(loopthrough) do
				local bone = vm:LookupBone(k)
				if (not bone) then continue end
				-- !! WORKAROUND !! //
				local s = Vector(v.scale.x, v.scale.y, v.scale.z)
				local p = Vector(v.pos.x, v.pos.y, v.pos.z)
				local ms = Vector(1, 1, 1)

				if (not hasGarryFixedBoneScalingYet) then
					local cur = vm:GetBoneParent(bone)

					while (cur >= 0) do
						local pscale = loopthrough[vm:GetBoneName(cur)].scale
						ms = ms * pscale
						cur = vm:GetBoneParent(cur)
					end
				end

				s = s * ms

				-- !! ----------- !! //
				if vm:GetManipulateBoneScale(bone) ~= s then
					vm:ManipulateBoneScale(bone, s)
				end

				if vm:GetManipulateBoneAngles(bone) ~= v.angle then
					vm:ManipulateBoneAngles(bone, v.angle)
				end

				if vm:GetManipulateBonePosition(bone) ~= p then
					vm:ManipulateBonePosition(bone, p)
				end
			end
		else
			self:ResetBonePositions(vm)
		end
	end

	function SWEP:ResetBonePositions(vm)
		if (not vm:GetBoneCount()) then return end

		for i = 0, vm:GetBoneCount() do
			vm:ManipulateBoneScale(i, Vector(1, 1, 1))
			vm:ManipulateBoneAngles(i, Angle(0, 0, 0))
			vm:ManipulateBonePosition(i, Vector(0, 0, 0))
		end
	end

	--[[*************************
		Global utility code
	*************************]]
	-- Fully copies the table, meaning all tables inside this table are copied too and so on (normal table.Copy copies only their reference).
	-- Does not copy entities of course, only copies their reference.
	-- WARNING: do not use on tables that contain themselves somewhere down the line or you'll get an infinite loop
	function table.FullCopy(tab)
		if (not tab) then return nil end
		local res = {}

		for k, v in pairs(tab) do
			if (type(v) == "table") then
				res[k] = table.FullCopy(v) -- recursion ho!
			elseif (type(v) == "Vector") then
				res[k] = Vector(v.x, v.y, v.z)
			elseif (type(v) == "Angle") then
				res[k] = Angle(v.p, v.y, v.r)
			else
				res[k] = v
			end
		end

		return res
	end
end