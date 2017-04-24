include("shared.lua")

hook.Add("PostDrawOpaqueRenderables", "DrawReviveHeart", function()
	if LocalPlayer():GetActiveWeapon() == NULL or LocalPlayer():GetActiveWeapon():GetClass() ~= "weapon_defibrilator" then return end

	for k, v in pairs(ents.FindByClass("prop_ragdoll")) do
		if SERVER and not v:Visible(LocalPlayer()) then return end
		cam.Start3D2D(v:GetPos() + Vector(0, 0, 30) - LocalPlayer():GetForward() * 20, Angle(0, LocalPlayer():GetAngles().y - 90, 90), 0.05)
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(Material("vgui/revive.png"))
		surface.DrawTexturedRect(-150, 0, 300, 300)
		cam.End3D2D()
	end
end)

hook.Add("PostPlayerDraw", "DrawDefibModel", function(ply)
	if not ply:Alive() then return end

	if ply:GetActiveWeapon() == NULL or ply:GetActiveWeapon():GetClass() ~= "weapon_defibrilator" then
		if ply.Defib ~= nil then
			ply.Defib:Remove()
			ply.Defib = nil
		end

		return
	end

	local pos = Vector(0, 0, 0)
	local ang = Angle(0, 0, 0)
	local attach_id = ply:LookupAttachment("anim_attachment_LH")
	if not attach_id then return end
	local attach = ply:GetAttachment(attach_id)
	if not attach then return end
	ang = attach.Ang
	ang:RotateAroundAxis(ang:Forward(), -20)
	ang:RotateAroundAxis(ang:Right(), 0)
	ang:RotateAroundAxis(ang:Up(), 90)
	local mdl = "models/weapons/custom/defib2.mdl"
	pos = attach.Pos + ang:Forward() * 0 + ang:Right() * 2 + ang:Up() * 0

	if ply.Defib == nil then
		ply.Defib = ClientsideModel(mdl, RENDERGROUP_OPAQUE)
	end

	local model2 = ply.Defib
	if model2 == nil or model2 == NULL then return end
	model2:SetRenderOrigin(pos)
	model2:SetRenderAngles(ang)
	model2:SetupBones()
	model2:DrawModel()
	model2:SetRenderOrigin()
	model2:SetRenderAngles()
end)