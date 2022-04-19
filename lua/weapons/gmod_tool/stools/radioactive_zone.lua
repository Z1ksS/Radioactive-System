TOOL.Name = "Radioactive zone"
TOOL.Category = "DEV"
TOOL.Command = nil
TOOL.ConfigName = ""

TOOL.ClientConVar[ "dmg" ] = "10"

TOOL.Information = {
	{ name = "left" },
	{ name = "right" }, 
	{ name = "reload"},
}


if (CLIENT) then  
	language.Add( "tool.radioactive_zone.left", "Select first point(LMB)" )
	language.Add( "tool.radioactive_zone.right", "Select second point(RMB)" )
	language.Add( "tool.radioactive_zone.reload", "Press R to reset points" )
end


local p1 = nil 
local p2 = nil
	
local stage = 0

function TOOL:LeftClick()
	local tr = util.TraceLine( {
		start = self:GetOwner():EyePos(),
		endpos = self:GetOwner():EyePos() + self:GetOwner():EyeAngles():Forward() * 150,
		filter = function( ent ) end
	} )

	if stage == 0 and !IsValid(p1) then 
		p1 = tr.HitPos
		stage = 1
	end 
end

function TOOL:RightClick()
	local tr = util.TraceLine( {
		start = self:GetOwner():EyePos(),
		endpos = self:GetOwner():EyePos() + self:GetOwner():EyeAngles():Forward() * 150,
		filter = function( ent ) end
	} )

	if stage == 1 && !IsValid(p2) then 
		p2 = tr.HitPos
		stage = 2
	end 
end 	

function TOOL:Reload()
	if stage >= 1 then 
		p1 = nil 
		p2 = nil 
		stage = 0
	end 
end 

local ConVarsDefault = TOOL:BuildConVarList()

if ( CLIENT ) then
	CreateClientConVar("radioactive_zone_debug", "0", false, false)
	
	local zMenu
	local function ZoneManage(parent, name, zone)
		local edit = false 

		parent.Menu = parent:Add("DFrame")
		parent.Menu:SetSize(400, 300)
		parent.Menu:SetTitle(name)
		parent.Menu:Center()
		parent.Menu:MakePopup()

		parent.DMG = parent.Menu:Add("DNumSlider")
		parent.DMG:Dock(TOP)
		parent.DMG:DockMargin(0, 0, 0, 4)
		parent.DMG:SetMin(0)
		parent.DMG:SetMax(100)
		parent.DMG:SetDecimals(0)
		parent.DMG:SetValue( zone.dmg )
		parent.DMG.OnValueChanged = function(self, value)
			if !parent.Save:IsVisible() then parent.Save:Show() end

			zone.dmg = math.Round(value)
		end 
		--parent.DMG:SetConVar( "radioactive_zone_dmg" )

		parent.Save = parent.Menu:Add("DButton")
		parent.Save:SetText( "Save edit" )
		parent.Save:Dock(BOTTOM)
		parent.Save:SetVisible(false)
		parent.Save.DoClick = function()
			radAreaSys.Zones[name] = zone 

			zone.index = name 

			local json = util.TableToJSON(zone)
            local data = util.Compress(json)
            local size = #data

			net.Start("radAreaSys.EditZone")
				net.WriteInt(size, 12)
            	net.WriteData(data, size)
			net.SendToServer()
		end 
	end 

	local function ZoneManageMenu()
		if not IsValid(LocalPlayer()) or not LocalPlayer():IsAdmin() then return end 

		local bTable = {}

		local zMenu = vgui.Create("DFrame")
		zMenu:SetSize(400, 300)
		zMenu:Center()
		zMenu:MakePopup()

		zMenu.scroll = zMenu:Add("DScrollPanel") 
		zMenu.scroll:Dock(FILL)
		zMenu.scroll:DockMargin(0, 8, 0, 8)

		local sum = 0
		for index, zone in pairs(radAreaSys.Zones) do 
			bTable[index] = zMenu.scroll:Add("DButton")
			bTable[index]:SetWide(zMenu:GetWide())
			bTable[index]:SetPos(0, (index - 1) * 25)
			bTable[index]:SetText(index)
			bTable[index].DoClick = function()
				ZoneManage(zMenu, index, zone)
			end 
			sum = sum + 1
		end 

		bTable[sum + 1] = zMenu.scroll:Add("DButton")
		bTable[sum + 1]:SetWide(zMenu:GetWide())
		bTable[sum + 1]:SetPos(0, (sum + 1) * 24)
		bTable[sum + 1]:SetText("+")
		bTable[sum + 1].DoClick = function()
			net.Start("radAreaSys.AddNewZoneNet")
			net.SendToServer(LocalPlayer())

			zMenu:Remove()
		end 
	end 

	concommand.Add("open_zone_menu_manage", ZoneManageMenu)

	local function CreateZone()
		if p1 and p2 then 
			local tbl = {dmg = GetConVar("radioactive_zone_dmg"):GetString(), vec1 = p1, vec2 = p2}
			
			local json = util.TableToJSON(tbl)
            local data = util.Compress(json)
            local size = #data

			net.Start("radAreaSys.AddNewZoneNet")
				net.WriteInt(size, 12)
            	net.WriteData(data, size)
			net.SendToServer()

			p1 = nil 
			p2 = nil 
			stage = 0
		else 
			LocalPlayer():ChatPrint("You haven't select points!")
		end 
	end 

	concommand.Add("create_zone", CreateZone)
	function TOOL.BuildCPanel( CPanel )
		CPanel:Clear()
		
		CPanel:Help( "Radioactive system set up" )
		
        CPanel:NumSlider( "Damage per second", "radioactive_zone_dmg", 1, 100, 1 )
		
		CPanel:Button( "Create zone" , "create_zone")
		CPanel:Button( "Open zone manage menu" , "open_zone_menu_manage")

		CPanel:CheckBox( "Debug zones", "radioactive_zone_debug")

	end

	hook.Add("PostDrawTranslucentRenderables", "DrawZone", function()
		if !LocalPlayer():IsAdmin() then return end 
		
		local ply = LocalPlayer()

		if !IsValid(ply) or !ply:Alive() then return end 

		local weapon = ply:GetActiveWeapon()
		local tooltbl = ply:GetTool("radioactive_zone")
		if not IsValid(weapon) or weapon:GetClass() != "gmod_tool" then return end 

		local tr = util.TraceLine( {
			start = ply:EyePos(),
			endpos = ply:EyePos() + EyeAngles():Forward() * 150,
			filter = function( ent ) end
		} )

		render.SetColorMaterial()
		if stage == 0 then 
			render.DrawWireframeSphere(tr.HitPos, 5, 15, 15, Color(255, 255, 255), true)
		elseif stage == 1 then 
			render.DrawWireframeSphere(p1, 5, 15, 15, Color(255, 255, 255), true)
			render.DrawWireframeSphere(tr.HitPos, 5, 15, 15, Color(255, 255, 255), true)
			render.DrawWireframeBox(Vector(0, 0, 0), Angle(0, 0, 0), p1, tr.HitPos, Color(255, 255, 255))
		elseif stage == 2 then 
			render.DrawWireframeSphere(p1, 5, 15, 15, Color(255, 255, 255), true)
			render.DrawWireframeSphere(p2, 5, 15, 15, Color(255, 255, 255), true)
			render.DrawWireframeBox(Vector(0, 0, 0), Angle(0, 0, 0), p1, p2, Color(255, 255, 255))
		end

		if GetConVar("radioactive_zone_debug"):GetString() == "1" then 
			for index, area in pairs(radAreaSys.Zones) do 
				render.DrawWireframeSphere(area.vec1, 5, 15, 15, Color(255, 255, 255), true)
				render.DrawWireframeSphere(area.vec2, 5, 15, 15, Color(255, 255, 255), true)
				render.DrawWireframeBox(Vector(0, 0, 0), Angle(0, 0, 0), area.vec1, area.vec2, Color(255, 255, 255))
			end 
		end 
	end)
end
