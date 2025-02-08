loadstring(game:HttpGet("https://raw.githubusercontent.com/Pixeluted/adoniscries/main/Source.lua",true))()


local uis = game:GetService("UserInputService")
local hook = nil;
hook = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    if (tostring(self) == "part") then return nil; end
    return hook(self, unpack(args));
end)

game:GetService("Players").LocalPlayer.PlayerGui.TopbarStandard.Holders.Left.ChildAdded:Connect(function(child) 
    local a = 0
    local children = game:GetService("Players").LocalPlayer.PlayerGui.TopbarStandard.Holders.Left:GetChildren();
    for _,v in children do
        if v.Name == "Widget" then
            if v.IconButton.Menu.IconSpot.Contents.IconImage and v.IconButton.Menu.IconSpot.Contents.IconImage.Image == "http://www.roblox.com/asset/?id=100789637461200" then
                v:Destroy();
            end
        end
    end
end)
