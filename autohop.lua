getgenv().FoundAuraOrChest = getgenv().FoundAuraOrChest or false
getgenv().ServerHopEnabled = false

if getgenv().FoundAuraOrChest then
    return
end

if queue_on_teleport then
    local source = game:HttpGet("https://raw.githubusercontent.com/TheRealNeveN/roblox-serverhop/main/autohop.lua")
    queue_on_teleport(source)
end


local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local PlaceId = game.PlaceId


local guiName = "ServerHopUI"
if CoreGui:FindFirstChild(guiName) then
    CoreGui:FindFirstChild(guiName):Destroy()
end

local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = guiName
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 200, 0, 100)
Frame.Position = UDim2.new(0.5, -100, 0.2, 0)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BackgroundTransparency = 1
Frame.Active = true
Frame.Draggable = true

local UICorner = Instance.new("UICorner", Frame)
UICorner.CornerRadius = UDim.new(0, 12)

for i = 1, 10 do
    Frame.BackgroundTransparency = 1 - (i * 0.08)
    task.wait(0.02)
end


pcall(function()
    if readfile and isfile("serverhop_ui_pos.json") then
        local pos = readfile("serverhop_ui_pos.json")
        local data = HttpService:JSONDecode(pos)
        Frame.Position = UDim2.new(0, data.X, 0, data.Y)
    end
end)

Frame:GetPropertyChangedSignal("Position"):Connect(function()
    if writefile then
        local data = { X = Frame.Position.X.Offset, Y = Frame.Position.Y.Offset }
        writefile("serverhop_ui_pos.json", HttpService:JSONEncode(data))
    end
end)


local Toggle = Instance.new("TextButton", Frame)
Toggle.Size = UDim2.new(0.8, 0, 0.4, 0)
Toggle.Position = UDim2.new(0.1, 0, 0.3, 0)
Toggle.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
Toggle.Text = "Activer Server Hop"
Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
Toggle.Font = Enum.Font.GothamBold
Toggle.TextSize = 14

local ToggleCorner = Instance.new("UICorner", Toggle)
ToggleCorner.CornerRadius = UDim.new(0, 10)


local Close = Instance.new("TextButton", Frame)
Close.Size = UDim2.new(0, 24, 0, 24)
Close.Position = UDim2.new(1, -28, 0, 4)
Close.BackgroundColor3 = Color3.fromRGB(220, 70, 70)
Close.Text = "X"
Close.TextColor3 = Color3.fromRGB(255, 255, 255)
Close.Font = Enum.Font.GothamBold
Close.TextSize = 14

local CloseCorner = Instance.new("UICorner", Close)
CloseCorner.CornerRadius = UDim.new(1, 0)

Close.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)


local function containsKeyword(obj, keyword)
    return obj.Name:lower():find(keyword:lower()) ~= nil
end

local function searchForTargets()
    for _, obj in pairs(game:GetDescendants()) do
        if containsKeyword(obj, "Aura Egg") or containsKeyword(obj, "Royal Chest") then
            return true
        end
    end
    return false
end

local function getServerList()
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
    end)
    return success and result or nil
end

local function serverHop()
    local servers = getServerList()
    if servers and servers.data then
        for _, server in pairs(servers.data) do
            if server.playing < server.maxPlayers then
                TeleportService:TeleportToPlaceInstance(PlaceId, server.id, Players.LocalPlayer)
                return
            end
        end
    end
end

Toggle.MouseButton1Click:Connect(function()
    getgenv().ServerHopEnabled = not getgenv().ServerHopEnabled
    Toggle.Text = getgenv().ServerHopEnabled and "Désactiver Server Hop" or "Activer Server Hop"
    Toggle.BackgroundColor3 = getgenv().ServerHopEnabled and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(70, 130, 180)

    if getgenv().ServerHopEnabled then
        task.spawn(function()
            while getgenv().ServerHopEnabled and not getgenv().FoundAuraOrChest do
                if searchForTargets() then
                    getgenv().FoundAuraOrChest = true
                    getgenv().ServerHopEnabled = false
                    Toggle.Text = "Trouvé !"
                    Toggle.BackgroundColor3 = Color3.fromRGB(80, 200, 120)
                    break
                else
                    task.wait(5)
                    serverHop()
                    break
                end
            end
        end)
    end
end)
