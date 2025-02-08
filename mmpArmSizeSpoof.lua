local success = pcall(function()
    local catchBallHook;
    catchBallHook = hookmetamethod(game, "__namecall", function(self,...)
        local args = {...};
        if tostring(self) == "CatchBall" and  getnamecallmethod() == "FireServer" then
            args[2][4] = Vector3.new(1,2,1);
        end
        return catchBallHook(self, unpack(args));
    end)
end)

if success then
    local player = game.Players.LocalPlayer
    player.Character["Left Arm"].Size = Vector3.new(4,4,2)
    player.Character["Right Arm"].Size = Vector3.new(4,4,2)
    player.Character["Left Arm"].Transparency = 0.5
    player.Character["Right Arm"].Transparency  = 0.5
    player.Character["Left Arm"].Massless = true
    player.Character["Right Arm"].Massless = true
else
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Can't enable big arms",
        Text = "Warning! Your executor does not support the bypass for the anti cheat.",
        Duration = 5
    })
end
