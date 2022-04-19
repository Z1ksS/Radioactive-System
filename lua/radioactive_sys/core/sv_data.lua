local file = file 
local util = util 

util.AddNetworkString("radAreaSys.SyncWithClient")
util.AddNetworkString("radAreaSys.SendSync")
util.AddNetworkString("radAreaSys.ZoneEnter")
util.AddNetworkString("radAreaSys.AddNewZoneNet")
util.AddNetworkString("radAreaSys.EditZone")

function radAreaSys:AddNewZone(dmg, v1, v2, ply)
    radAreaSys.Zones = radAreaSys.Zones or {}

    table.insert(radAreaSys.Zones, {dmg = dmg, vec1 = v1, vec2 = v2})

    radAreaSys:SaveZones(ply)
end 

function radAreaSys:EditZone(tbl, ply)
    radAreaSys.Zones = radAreaSys.Zones or {}

    radAreaSys.Zones[tbl.index].dmg = tbl.dmg 
	radAreaSys.Zones[tbl.index].vec1 = tbl.vec1 
	radAreaSys.Zones[tbl.index].vec2 = tbl.vec2 

    radAreaSys:SaveZones(ply)
end 

function radAreaSys:PlayerMoveInZone(ply, mv)
	radAreaSys.Zones = radAreaSys.Zones or {}
	ply.CurrentZone = ply.CurrentZone or {}
    
	for index, zone in pairs(radAreaSys.Zones) do
		if ply:GetPos():WithinAABox(zone.vec1, zone.vec2) then 
			if not ply.CurrentZone[index] then
				ply:SetNWBool("IsInZone", true)
				ply.CurrentZone[index] = true 
				--[[if zone.dmg then 
					ply:SetHealth(ply:Health() - zone.dmg)
				end--]]
				timer.Create("radAreaSys.TakeDamageTimer", 2, 0, function()
					if ply:GetNWBool("HazmatSuitEquiped") and ply:GetNWInt("HazmatSuitHealth") > 0 then 
						ply:SetNWInt("HazmatSuitHealth", ply:GetNWInt("HazmatSuitHealth") - zone.dmg) 
						if ply:GetNWInt("HazmatSuitHealth") <= 0 then 
							ply:SetNWBool("HazmatSuitEquiped", false)
							ply:SetModel(ply.SavedModel)
						end
						return 
					end
					ply:SetHealth(ply:Health() - zone.dmg)

					if ply:Health() < 0 then 
						ply:Kill()
					end
				end )
			end 
		else 
			if ply.CurrentZone[index] then
				ply.CurrentZone[index] = nil
				ply:SetNWBool("IsInZone", false)
				if timer.Exists("radAreaSys.TakeDamageTimer") then 
					timer.Remove("radAreaSys.TakeDamageTimer")
				end
			end 
		end 
		
	end
end

net.Receive("radAreaSys.AddNewZoneNet", function(len, ply)
	if not ply:IsAdmin() then return end 

	--radAreaSys:AddNewZone(10, Vector(0, 0, 0), Vector(0, 0, 0), ply)
	local size = net.ReadInt(12)
    local compressedData = net.ReadData(size)
    local data = util.Decompress(compressedData)

	local tbl = util.JSONToTable(data)

	radAreaSys:AddNewZone(tbl.dmg, tbl.vec1, tbl.vec2, ply)
end )

net.Receive("radAreaSys.EditZone", function(len, ply)
	if not ply:IsAdmin() then return end 

	local size = net.ReadInt(12)
    local compressedData = net.ReadData(size)
    local data = util.Decompress(compressedData)

	local tbl = util.JSONToTable(data)
	radAreaSys:EditZone(tbl, ply)
end )

hook.Add("Move", "radAreaSys.Move", function(ply, mv) 
	radAreaSys:PlayerMoveInZone(ply, mv)
end)

function radAreaSys:LoadZones()
    local json = file.Read("radioactive_system/saved_zones.json")

	if json then
		radAreaSys.Zones = util.JSONToTable(json)
	else
        file.CreateDir("radioactive_system")
        file.Write("radioactive_system/saved_zones.json", util.TableToJSON({}))
		radAreaSys.Zones = {}
	end
end 

function radAreaSys:SyncWithClient(ply)
	net.Start("radAreaSys.SyncWithClient")
		net.WriteTable(radAreaSys.Zones)
	net.Send(ply)
end 

function radAreaSys:SaveZones(ply)
    radAreaSys.Zones = radAreaSys.Zones or {}

    local json = util.TableToJSON(radAreaSys.Zones, true)

    file.Write("radioactive_system/saved_zones.json", json)

	radAreaSys:SyncWithClient(ply)
end 

net.Receive("radAreaSys.SendSync", function(len, ply)
	radAreaSys:SyncWithClient(ply)
end )

hook.Add("Initialize", "radAreaSys.Init", function()
    radAreaSys:LoadZones()

end )