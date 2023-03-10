if game.PlaceId == 6516141723 then
    error("Do not execute this thing in doors lobby.")
end

local mainGui = Instance.new("ScreenGui")
local mainframe = Instance.new("ScrollingFrame", mainGui)
local TextBox = Instance.new("TextBox",mainGui)
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
local currentroom = 0
local comfirmedroom = false
local comfirmingroom = false
local stop = false

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

TextBox.BackgroundColor3 = Color3.fromRGB(255, 166, 103)
TextBox.BorderColor3 = Color3.fromRGB(255,227,187)
TextBox.BorderSizePixel = 5
--TextBox.AnchorPoint = Vector2.new(0.5,0.5)
TextBox.AnchorPoint = Vector2.new(0.5,0.5)
TextBox.Size = UDim2.new(0.093, 0,0.048, 0)
TextBox.Position = UDim2.new(0.5, 0,0.5, 0)
TextBox.Text = ""
TextBox.TextColor3 = Color3.fromRGB(255,255,255)
TextBox.FontFace = Font.fromEnum(Enum.Font.Nunito)
TextBox.FontFace.Bold = true
TextBox.TextScaled = true
TextBox.PlaceholderText = "Enter the current room you are in."
TextBox.PlaceholderColor3 = Color3.fromRGB(255,255,255)
TextBox.Visible = false
TextBox.TextEditable = false
TextBox.ClearTextOnFocus = false

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
	
	return path
end

local function walkto(destination)
	local walktoPart = Instance.new("Part",workspace)
	walktoPart.Size = Vector3.new(5,2,4)
	walktoPart.Position = destination.Position - Vector3.new(0,destination.Size.Y / 2,0)
	walktoPart.Anchored = true
	walktoPart.CanCollide = false
    	walktoPart.Color = Color3.fromRGB(0,255,0)
	walktoPart.Transparency = 0.7
    print(destination.Name)
	if destination.Name == "Door" then
		spawnText("TESTING TEXT \n walking to locker.")
	end
	local Path = findpath(walktoPart)
	if Path.Status == Enum.PathStatus.Success then
		for index, waypoint in pairs(Path:GetWaypoints()) do
            print("A")
			local part = Instance.new("Part",workspace)
			part.Size = Vector3.new(1,1,1)
			part.CanCollide = false
			part.Anchored = true
            		part.Transparency = .7
			part.Position = waypoint.Position
			Humanoid:MoveTo(waypoint.Position)
			Humanoid.MoveToFinished:Wait()
            		part:Destroy()
		end
        if destination.Name == "RoomExit" then
            spawnText("Door["..currentroom.."] finished walk. Walking to...[" .. currentroom + 1 .. "].")
            currentroom = currentroom + 1
        elseif destination.Name == "Door" then
            spawnText("TESTING TEXT \n Moved to locker.")
        end
		walktoPart:Destroy()
	else
		spawnText("Path finding not successful. Please contact me with media.",true)
		walktoPart:Destroy()
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
    Part.Transparency = .5

    Part.CFrame = HumanoidRootPart.CFrame + HumanoidRootPart.CFrame.LookVector * 10
    task.wait()
    character:SetPrimaryPartCFrame(Part.CFrame)
    task.wait(1)
    Part:Destroy()
end

local highlight = Instance.new("Highlight") 
highlight.OutlineColor = Color3.fromRGB(0,255,0) 
highlight.FillTransparency = 1
local function gotodoor()
    if not hide then
        if walkingtodoor == false then
            walkingtodoor = true
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
            walkingtodoor = false
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

spawnText("Please enter your current room number! If you don't know how to, look at the door number and - 1.")
TextBox.Visible = true
TextBox.TextEditable = true
spawnText("Enter at the textbox. Press Y after you are done.")
--spawnText("Press Shift + Y to begin AI passing, else press Shift + Y again.")

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
        unhide()
        hide = false
    end
end)

UIS.InputBegan:Connect(function(input, gameProcessedEvent)
    if not gameProcessedEvent then
        if input.KeyCode == Enum.KeyCode.Y then
            if not comfirmedroom and comfirmingroom then
                spawnText("Success! AI can be triggered once you press Shift + Y. Do not move with your keys during process!",0,true)
                comfirmedroom = true
                comfirmingroom = false
                TextBox.Visible = false
                TextBox.Text = ""
            elseif not comfirmedroom and not comfirmingroom then
                TextBox.TextEditable = false
                local s = TextBox.Text
                local res = string.match(s , "%d+")
                if rooms:FindFirstChild(res) then
                    spawnText("Are you sure [" .. res .. "] is the room you are willing to start? Press Y if yes, N if not.",0,true)
                    comfirmingroom = true
                    currentroom = res
                end
            end
        elseif input.KeyCode == Enum.KeyCode.N then
            if not comfirmedroom and comfirmingroom then
                spawnText("Room number declined. Enter the number again in the textbox.",true)
                comfirmingroom = false
                comfirmedroom = false
                TextBox.TextEditable = true
                TextBox.Text = ""
                TextBox.Visible = true
            end
        end
        if UIS:IsKeyDown(Enum.KeyCode.Y) and UIS:IsKeyDown(Enum.KeyCode.LeftShift) and comfirmedroom then
            if not processing and not stop then
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
            elseif processing and not stop then
                spawnText("AI passing paused.")
                processing = false
                started = false
            end
            if UIS:IsKeyDown(Enum.KeyCode.Q) and UIS:IsKeyDown(Enum.KeyCode.LeftShift) and comfirmedroom then
                stop = true
                started = false
            end
        end
    end
end)
