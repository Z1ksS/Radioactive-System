hook.Add("PlayerSay", "radAreaSys.DropSuit", function( ply, text, team )
    local text = string.lower( text )
    
    if text == "/monsterspawnadd" then
        
        return ""
    end 
end )