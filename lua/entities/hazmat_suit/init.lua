AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include("shared.lua")

function ENT:Initialize()
    
    self:SetModel(radAreaSys.config.HazmatEntityModel or "models/props_c17/suitcase_passenger_physics.mdl")
    
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)

    local phys = self:GetPhysicsObject()

    if phys:IsValid() then 
        phys:Wake()
    end 
end 

function ENT:Use(ply)
    if not IsValid(ply) or not ply:IsPlayer() then
		return
	end

    if ply:GetNWBool("HazmatSuitEquiped") then ply:ChatPrint("You have hazmat suit!") return end 

    ply:SetNWBool("HazmatSuitEquiped", true)
    ply:SetNWInt("HazmatSuitHealth", 100)

    ply.SavedModel = ply:GetModel()
    ply:SetModel(radAreaSys.config.HazmatSuitModel or "models/player/vad36cccp/bohazmat2.mdl")

    self:Remove()
end 

hook.Add("PlayerSpawn", "HazmatSuit", function(ply)
    ply:SetNWBool("HazmatSuitEquiped", false)
end )