local hmaterial = Material("rad_sys/nuc_icon.png", "smooth")

local scrw, scrh = ScrW(), ScrH()
local math = math

radAreaSys.Zones = radAreaSys.Zones or {}

local max_suithealth = 100

hook.Add("HUDPaint", "radAreaSys.HUD", function()
    local ply = LocalPlayer()
    
    if not IsValid(ply) or not ply:IsPlayer() then
		return
	end

    if ply:GetNWBool("HazmatSuitEquiped") then 
        --[[local suit_health = ( LocalPlayer():GetNWInt("HazmatSuitHealth") / max_suithealth ) * 100
        lerp_suithealth = Lerp(FrameTime() * 2, lerp_suithealth or 0, suit_health or 0)

        draw.RoundedBox(0, 35, ScrH() - 120, lerp_suithealth * 5, 10, Color(255, 204, 0, 255))--]]

        return 
    end 

    if ply:GetNWBool("IsInZone") then 

        local alpha = math.abs(math.sin(CurTime() * 2)) * 150

        surface.SetDrawColor( 255, 255, 255, alpha )
	    surface.SetMaterial( hmaterial )
	    surface.DrawTexturedRect( scrw - 210, scrh - 380, 200, 200 )
    end 

end )

net.Receive("radAreaSys.ZoneEnter", function(len, ply) radAreaSys:EnterZone(net.ReadBool()) end)

net.Receive("radAreaSys.SyncWithClient", function()
    radAreaSys.Zones = net.ReadTable()
end )

hook.Add("InitPostEntity", "radAreaSys.InitEntity", function()
    net.Start("radAreaSys.SendSync")
    net.SendToServer()
end )