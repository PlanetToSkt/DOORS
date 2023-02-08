local mainGui = Instance.new("ScreenGui")
local mainframe = Instance.new("ScrollingFrame", mainGui)
local uilistlayout = Instance.new("UIListLayout", mainframe)
local TextLabel = Instance.new("TextLabel")
local UIS = game:GetService("UserInputService")
local PS = game:GetService("PathfindingService")
local rooms = game.Workspace.CurrentRooms
local character = game.Players.LocalPlayer.Character
local Humanoid = character:WaitForChild("Humanoid")
local HumanoidRootPart = character.HumanoidRootPart
--^Instances DO NOT TOUCH

--values DO NOT TOUCH
local processing = false
local walkingtodoor = false
local started = false
local hide = false
local currentroom = 0 --manual type the number on the room if you started this script middle of nowhere (typing wrong number crashes the whole script)

mainGui.IgnoreGuiInset = true


mainGui.Parent = game.Players.LocalPlayer.PlayerGui

--Instance Configure DO NOT TOUCH
mainframe.BackgroundColor3 = Color3.fromRGB(255, 166, 103) 
mainframe.BackgroundTransparency = 0.7 
mainframe.BorderColor3 = Color3.fromRGB(255, 227, 187) 
mainframe.BorderSizePixel = 5 
mainframe.Position = UDim2.new(0, 0,0.185, 0) 
mainframe.Size = UDim2.new(0.174, 0,0.625, 0) 
mainframe.AutomaticCanvasSize = Enum.AutomaticSize.Y 
mainframe.CanvasSize = UDim2.new(0,0,0,0)
TextLabel.Text = "" 
TextLabel.BackgroundTransparency = 1 
TextLabel.TextColor3 = Color3.fromRGB(255,255,255) 
TextLabel.FontFace = Font.fromEnum(Enum.Font.Nunito) 
TextLabel.FontFace.Bold = true 
TextLabel.Size = UDim2.new(0.917, 0,0.116, 0) 
TextLabel.TextScaled = true

local ConsoleText = TextLabel:Clone()
ConsoleText.BackgroundTransparency = 0 
ConsoleText.BackgroundColor3 = Color3.fromRGB(68, 68, 68) 
ConsoleText.Position = UDim2.new(0, 0,0.115, 0) 
ConsoleText.Size = UDim2.new(0.174, 0,0.047, 0) 
ConsoleText.Text = "Console" 
ConsoleText.Parent = mainGui

local function spawnText(text, R,G,B)
    local copytextlabel = TextLabel:Clone()
    copytextlabel.Text = "(" .. tostring(os.date("%X",os.time())) .. ") \n " .. text
    if R == true then
        copytextlabel.TextColor3 = Color3.fromRGB(255,0,0)
    elseif G == true then
        copytextlabel.TextColor3 = Color3.fromRGB(0,255,0)
    end
    copytextlabel.Parent = mainframe
    coroutine.resume(coroutine.create(function()
        task.wait(10)
        copytextlabel:Destroy()
    end))
end

local function fireproximityprompt(Obj, Amount, Skip)
    if Obj.ClassName == "ProximityPrompt" then 
        Amount = Amount or 1
        local PromptTime = Obj.HoldDuration
        if Skip then 
            Obj.HoldDuration = 0
        end
        for i = 1, Amount do 
            Obj:InputHoldBegin()
            if not Skip then 
                task.wait(Obj.HoldDuration)
            end
            Obj:InputHoldEnd()
        end
        Obj.HoldDuration = PromptTime
    else 
        error("userdata<ProximityPrompt> expected")
    end
end

local function findpath(destination)
	local PathfindingService = game:GetService("PathfindingService")

	local pathParams = {
		["AgentHeight"] = 1,
		["AgentRadius"] = 1,
		["AgentCanJump"] = false
	}

	local path = PathfindingService:CreatePath(pathParams)

	path:ComputeAsync(character.HumanoidRootPart.Position, destination.Position)
	
	print(character.HumanoidRootPart.Position, destination.Position)
	
	return path
end
task.wait(1)

local function walkto(destination)
	local walktoPart = Instance.new("Part",workspace)
	walktoPart.Size = Vector3.new(5,1,1)
	walktoPart.Position = destination.Position - Vector3.new(0,destination.Size.Y / 2,0)
	walktoPart.Anchored = true
	walktoPart.CanCollide = false
    walktoPart.Color3 = Color3.fromRGB(0,255,0)
    walktoPart.Transparency = 0.7

	local Path = findpath(walktoPart)
	print(Path)
	if Path.Status == Enum.PathStatus.Success then
		print("Success")
		for index, waypoint in pairs(Path:GetWaypoints()) do
			--[[local part = Instance.new("Part",workspace)
			part.Size = Vector3.new(1,1,1)
			part.CanCollide = false
			part.Anchored = true
            part.Transparency = 1
			part.Position = waypoint.Position
            --]]
			Humanoid:MoveTo(waypoint.Position)
			Humanoid.MoveToFinished:Wait()
		end
        if destination.Name == "RoomExit" then
            spawnText("Door["..currentroom.."] finished walk. Walking to...[" .. currentroom + 1 .. "].")
            currentroom = currentroom + 1
        elseif destination.Name == "Door" then
            
        end
		walktoPart:Destroy()
	else
		spawnText("Path finding not successful. Please contact me with media.",true)
		Humanoid:MoveTo(destination.Position - (character.HumanoidRootPart.CFrame.LookVector * 10))
	end
end

local highlightcloset = Instance.new("Highlight") 
highlightcloset.OutlineColor = Color3.fromRGB(255,0,0) 
highlightcloset.FillTransparency = 1
local function findnearestcloset()
    local maxdistance = 300
    local nearestcloset
    for i,v in pairs(rooms:GetDescendants()) do
        if v.Name == "Rooms_Locker" then
            local target = v.Door
            local distance = (target.Position - character.HumanoidRootPart.Position).Magnitude
            
            if distance < maxdistance then
                nearestcloset = target
                maxdistance = distance
            end
        end
    end
    return nearestcloset
end

local function hidenow()
    local closet = findnearestcloset()
    if closet then
        print(closet.Position, true)
    end
    highlightcloset.Parent = closet.Parent
    Humanoid:MoveTo(HumanoidRootPart.Position)
    local Part = Instance.new("Part",workspace)
    Part.Anchored = true
    Part.CanCollide = false
    Part.Transparency = 1
    Part.Size = Vector3.new(1,1,1)
    Part.Position = closet.Parent.Base.Position
    walkto(closet)
    character:SetPrimaryPartCFrame(Part.CFrame)
    --[[
    local proximity = closet.Parent.HidePrompt
    proximity.RequiresLineOfSight = false
    proximity.Style = Enum.ProximityPromptStyle.Default
    fireproximityprompt(proximity, 1, true)
    --]]
end

local function unhide()
    local Part = Instance.new("Part")

    Part.Parent = game.Workspace

    Part.Anchored = true
    Part.CanCollide = false
    Part.Transparency = 1

    Part.CFrame = HumanoidRootPart.CFrame + HumanoidRootPart.CFrame.LookVector * 10
    task.wait()
    game.Players.LocalPlayer.Character:SetPrimaryPartCFrame(Part.CFrame)
    task.wait(1)
    Part:Destroy()
end

local highlight = Instance.new("Highlight") 
highlight.OutlineColor = Color3.fromRGB(0,255,0) 
highlight.FillTransparency = 1
local function gotodoor()
    if hide == true then
        return
    else
        if walkingtodoor == false then
            local room
            local door
            room = rooms:WaitForChild(currentroom)
            door = room.Door
            highlight.Parent = door
            for i,v in pairs(room:GetChildren()) do
                if v.Name == "Rooms_Desk" then
                    v:Destroy()
                end
            end
            walkto(room.RoomExit)
        end
    end
end

local function loopingprocess()
    while task.wait() do
        if started == false then
             break
        end
        Humanoid.WalkSpeed = 21
        gotodoor()
    end
end


--Starting tips (feel free to configure if you don't forget the starting keys.)

spawnText("Please make sure this is in Rooms of doors else this script will break your career.")
spawnText("Press Shift + Y to begin AI passing, else press Shift + Y again.")
print("A")

--DO NOT TOUCH AI STUFF

workspace.ChildAdded:Connect(function(Obj)
    if Obj.Name:sub(1, 1) == "A" and Obj.Name ~= "AmbushMoving" then
        spawnText(Obj.Name .. " Spawned, AI finding closet to hide...", true)
        hide = true
        hidenow()
    end
end)
workspace.ChildRemoved:Connect(function(Obj)
    if Obj.Name:sub(1, 1) == "A" and Obj.Name ~= "AmbushMoving" then
        spawnText(Obj.Name .. " Despawned, AI continuing journey...", 0, true)
        hide = false
        unhide()
    end
end)

UIS.InputBegan:Connect(function(input, gameProcessedEvent)
    if not gameProcessedEvent then
        if UIS:IsKeyDown(Enum.KeyCode.Y) and UIS:IsKeyDown(Enum.KeyCode.LeftShift) then
            if not processing then
                spawnText("AI passing begin. Please wait while configuring.")
                processing = true
                started = true
                task.wait(1)
                local Plr = game.Players.LocalPlayer
                local ModuleScripts = {
                MainGame = Plr.PlayerGui.MainUI.Initiator.Main_Game,
                }

                if ModuleScripts.MainGame.RemoteListener.Modules:FindFirstChild("A90") then
                    ModuleScripts.MainGame.RemoteListener.Modules["A90"].Name = "Baller"
                end
                spawnText("A90 removed from game.", 0, true)
                task.wait(1)
                loopingprocess()
            else
                spawnText("AI passing paused.")
                processing = false
                started = false
            end
        end
    end
end)
