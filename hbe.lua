--m to toggle notifications

_G.Reach = 5  -- Default reach value (can be increased/decreased)
_G.KeyBindHigher = Enum.KeyCode.R  -- Keybind to increase reach
_G.KeyBindLower = Enum.KeyCode.E  -- Keybind to decrease reach
_G.KeyBindTransparencyToggle = Enum.KeyCode.N  -- Keybind to toggle hitbox transparency between 0.5 and 1
_G.ReachOff = false  -- Set to true to disable the feature
_G.ShowOwnTeam = true  -- Set to true to show hitboxes for your team, false for enemy team
_G.HitboxTransparency = 0.8  -- Transparency level for the hitboxes
_G.HitboxColor = BrickColor.new("Bright blue")  -- Color for the hitboxes
_G.WhiteListEnabled = true
local notif = false;

local player = game.Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Object pool for hitboxes to optimize creation/destruction
local hitboxPool = {}
local whitelisted = {}

-- Helper function to create and reuse hitbox visualizer
local function getHitboxVisualizer()
    local hitbox = table.remove(hitboxPool) or Instance.new("Part")
    hitbox.Shape = Enum.PartType.Ball
    hitbox.Anchored = true
    hitbox.CanCollide = false
    hitbox.Transparency = _G.HitboxTransparency
    hitbox.BrickColor = _G.HitboxColor
    hitbox.Size = Vector3.new(2 * _G.Reach, 2 * _G.Reach, 2 * _G.Reach)  -- Initial size
    hitbox.Parent = workspace  -- Parent the hitbox to the workspace initially
    return hitbox
end

-- Function to update hitbox visualizer based on team
local function updateHitboxVisualizerForPlayer(targetPlayer)

    if _G.WhiteListEnabled and table.find(whitelisted, targetPlayer) == nil then return end;

    local targetCharacter = targetPlayer.Character
    if not targetCharacter then return end

    local humanoidRootPart = targetCharacter:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end

    -- Find or create the hitbox visualizer
    local hitboxVisualizer = targetCharacter:FindFirstChild("HitboxVisualizer")
    if not hitboxVisualizer then
        hitboxVisualizer = getHitboxVisualizer()
        hitboxVisualizer.Name = "HitboxVisualizer"
        hitboxVisualizer.Parent = targetCharacter
    end

    -- Update visibility based on team selection
    hitboxVisualizer.Size = Vector3.new(2 * _G.Reach, 2 * _G.Reach, 2 * _G.Reach)
    hitboxVisualizer.CFrame = humanoidRootPart.CFrame
    hitboxVisualizer.Transparency = _G.HitboxTransparency
        -- Pool the hitbox if not needed
        --hitboxVisualizer.Parent = nil
        --table.insert(hitboxPool, hitboxVisualizer)
end


-- Function to handle key input for changing reach, toggling visualizer, and transparency toggle
local function onInputBegan(input, gameProcessedEvent)
    if gameProcessedEvent then return end

    if input.KeyCode == Enum.KeyCode.M then
        notif = not notif;
    end

    if _G.WhiteListEnabled == true then
        if (input.KeyCode == Enum.KeyCode.F) then
            local mouseTarget = player:GetMouse().Target
            local humanoid = mouseTarget.Parent:FindFirstChild("Humanoid")
            local playerr = game.Players:GetPlayerFromCharacter(mouseTarget.Parent)
            if humanoid and playerr then
                if table.find(whitelisted, playerr) then
                    table.remove(whitelisted, table.find(whitelisted, playerr))
                    if notif then
                        
                    game.StarterGui:SetCore("SendNotification", {
                        Title = "Reach",
                        Text = "Reach disabled on "..playerr.Name,
                        Duration = 1
                    })
                    end 
                    playerr.Character:FindFirstChild("HitboxVisualizer"):Destroy()
                else
                    table.insert(whitelisted, playerr)
                    if notif then
                    game.StarterGui:SetCore("SendNotification", {
                        Title = "Reach",
                        Text = "Reach enabled on "..playerr.Name,
                        Duration = 1
                    })
                    end
                end
            end
        end
    else
        if input.KeyCode == Enum.KeyCode.F then 
            _G.ReachOff = not _G.ReachOff; 
            local abc = "Enabled"
            if _G.ReachOff then abc = "Disabled"; end
            if notif then
                game.StarterGui:SetCore("SendNotification", {
                    Title = "Reach",
                    Text = "Reach is "..abc,
                    Duration = 1
                })
            end

        end
    end


    if input.UserInputType == Enum.UserInputType.Keyboard then
        if input.KeyCode == _G.KeyBindHigher then
            -- Increase reach by 0.5
            _G.Reach = math.min(_G.Reach + 0.5, 10)  -- Optional: cap reach at 10 (or any max value)
            if notif then
            game.StarterGui:SetCore("SendNotification", {
                Title = "Reach",
                Text = "Reach set to " .. _G.Reach,
                Duration = 1
            })
            end
        elseif input.KeyCode == _G.KeyBindLower then
            -- Decrease reach by 0.5, with a minimum of 0.5
            _G.Reach = math.max(_G.Reach - 0.5, 0.5)
            if notif then
                game.StarterGui:SetCore("SendNotification", {
                    Title = "Reach",
                    Text = "Reach set to " .. _G.Reach,
                    Duration = 1
                })
            end

        elseif input.KeyCode == _G.KeyBindTransparencyToggle then
            -- Toggle transparency between 0.5 and 1
            _G.HitboxTransparency = (_G.HitboxTransparency == 1) and 0.5 or 1
            if notif then
            game.StarterGui:SetCore("SendNotification", {
                Title = "Transparency",
                Text = "Hitbox transparency set to " .. _G.HitboxTransparency,
                Duration = 1
            })
            end 
        end
    end
end

-- Handle player joining and updating their hitbox visualizer
game.Players.PlayerAdded:Connect(function(v)
    v.CharacterAdded:Connect(function(character)
        updateHitboxVisualizerForPlayer(v)
    end)
end)

-- Update the reach and visualizer in each frame using RenderStepped for visuals
RunService.PreRender:Connect(function()
    if _G.ReachOff then return end  -- If Reach is off, stop the function

    -- Update hitboxes for all players except the local player
    for _, targetPlayer in pairs(game.Players:GetPlayers()) do
        if targetPlayer ~= player then
            updateHitboxVisualizerForPlayer(targetPlayer)
        end
    end
end)

UserInputService.InputBegan:Connect(onInputBegan)

player.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid").Died:Connect(function()
        for _,v in whitelisted do
            v.Character:FindFirstChild("HitboxVisualizer"):Destroy()
        end
        whitelisted = {}
        if notif then

        game.StarterGui:SetCore("SendNotification", {
            Title = "You died",
            Text = "Disabling hitbox for all players",
            Duration = 1
        })
        end 
    end)
end)
