include("shared.lua")

function ENT:Draw()
    self:DrawModel()

	if radAreaSys.config.NeedPhraseOnEntity then 
		local oang = self:GetAngles()
		local opos = self:GetPos()

		local ang = self:GetAngles()
		local pos = self:GetPos()

		ang:RotateAroundAxis( oang:Up(), 90 )
		ang:RotateAroundAxis( oang:Right(), -66 )

		pos = pos + oang:Forward() * 5 + oang:Up() * 5  + oang:Right() * 0

		cam.Start3D2D( pos, ang, 0.3 )
			draw.SimpleText( radAreaSys.config.PhraseOnEntity, "Default", 0, 0, Color(52, 147, 235, alpha), TEXT_ALIGN_CENTER )			
		cam.End3D2D()
	end 
end 