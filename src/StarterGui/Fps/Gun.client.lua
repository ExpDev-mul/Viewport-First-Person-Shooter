local players = (game:GetService("Players"));
local runService = (game:GetService("RunService"));
local tweenService = (game:GetService("TweenService"));
local userInputService = (game:GetService("UserInputService"));
local replicatedStorage = (game:GetService("ReplicatedStorage"));
userInputService.MouseIconEnabled = false

local contextActionService = (game:GetService("ContextActionService"));

local viewportFrame = (script.Parent:WaitForChild("ViewportFrame"));
local VIEWPORT_FRAME_ORIGINAL_POSITION = (viewportFrame.Position);

local infoFrame = (script.Parent:WaitForChild("Info"));

local worldModel = (viewportFrame:WaitForChild("WorldModel"));

local ammo = (script.Parent:WaitForChild("Ammo"));
local crosshair = (script.Parent:WaitForChild("Crosshair"));
local DEFAULT_CROSSHAIR_SIZE = (crosshair.Size);

local fps = (worldModel:WaitForChild("Fps"));
local localPlayer = (players.LocalPlayer);
local localMouse = (localPlayer:GetMouse());
local localCharacter = (localPlayer.Character or localPlayer.CharacterAdded:Wait());

local recoil = require(script.Parent:WaitForChild("Recoil"));
local gunSettings = require(script.Parent:WaitForChild("GunSettings"));
ammo.Value = gunSettings.maxammo

local shooting = (false);
function ActionBinded(action, inputState, inputObject)
	if (inputState == Enum.UserInputState.Begin) then
		shooting = true
	else
		shooting = false
	end;
end;

contextActionService:BindAction("GunInputDetection", ActionBinded, false, Enum.UserInputType.MouseButton1)

local debrisService = (game:GetService("Debris"));
local soundService = (game:GetService("SoundService"));

-- // Sounds
function CreateShootSound()
	replicatedStorage.FpsRemoteEvents.ReplicateSounds:FireServer(localCharacter:FindFirstChildOfClass("Tool").Handle, gunSettings.shootsound, 1.5)
	local sound = Instance.new("Sound", soundService)
	sound.SoundId = gunSettings.shootsound
	sound.Volume = 1
	sound:Play()
	debrisService:AddItem(sound, 2)
end;

function CreateReloadSound()
	replicatedStorage.FpsRemoteEvents.ReplicateSounds:FireServer(localCharacter:FindFirstChildOfClass("Tool").Handle, gunSettings.reloadsound, 1.5)
	replicatedStorage.FpsRemoteEvents.ReplicateAnimation:FireServer(gunSettings.reloadanimationid)
	local sound = Instance.new("Sound", soundService)
	sound.SoundId = gunSettings.reloadsound
	sound.Volume = 1
	sound:Play()
	debrisService:AddItem(sound, 2)
end;

function CreateHeadshotSound()
	local shootSound = Instance.new("Sound", soundService);
	shootSound.SoundId = gunSettings.headshotsound
	shootSound:Play()
	debrisService:AddItem(shootSound, 1)
end;

function CreateHitSound()
	local shootSound = Instance.new("Sound", soundService);
	shootSound.SoundId = gunSettings.hitsound
	shootSound:Play()
	debrisService:AddItem(shootSound, 1)
end;

local FIRE_FLASH_SPEED = (25);

local lastTime = tick()
local transparencyGoal = (1);
function CreateFireEffect()
	replicatedStorage.FpsRemoteEvents.ReplicateShot:FireServer(localCharacter:FindFirstChildOfClass("Tool"))
	local startTime = tick()
	lastTime = startTime
	transparencyGoal = 0.2
	delay(0.3, function()
		if (lastTime == startTime) then
			transparencyGoal = 1
		end;
	end)
end;

local BULLET_SPEED = (600);
local bulletHole = (script:WaitForChild("Hole"));
function CreateBulletHole(instance, position, surfaceNormal)
	if (surfaceNormal) then
		local bulletHoleClone = bulletHole:Clone();
		bulletHoleClone.Parent = workspace:WaitForChild("GunTraces");
		bulletHoleClone.Impact:Emit(150)
		bulletHoleClone.CFrame = CFrame.new(position, position + surfaceNormal)
		local weldConstraint = Instance.new("WeldConstraint", bulletHoleClone)
		weldConstraint.Part0 = bulletHoleClone
		weldConstraint.Part1 = instance
		delay(5, function()
			tweenService:Create(bulletHoleClone.SurfaceGui.Vector, TweenInfo.new(0.4, Enum.EasingStyle.Sine), {ImageTransparency = 1}):Play()
			debrisService:AddItem(bulletHoleClone, 1)
		end)
	end;
end;

local RAY_CAST_PARAMS = RaycastParams.new();
RAY_CAST_PARAMS.FilterType = Enum.RaycastFilterType.Blacklist

local isRunning = (false);
local isReloading = (false);
local isCrouching = (false);
local isAimKeyPressed = (false);
local isRunKeyPressed = (false);
local isCrouchKeyPressed = (false);

local camera = (workspace.CurrentCamera);
function Shoot()
	RAY_CAST_PARAMS.FilterDescendantsInstances = {localCharacter, workspace:WaitForChild("GunTraces")}
	recoil.Recoil(gunSettings.recoil)
	CreateShootSound()
	CreateFireEffect()
	local mousePosition = (localMouse.Hit.Position);
	local raycastResult
	if (localCharacter.HumanoidRootPart.Velocity.Magnitude > 10) then
		raycastResult = workspace:Raycast(camera.CFrame.Position, ((CFrame.new(mousePosition) * CFrame.new(math.random(-3, 3), math.random(-3, 3), 0)).Position - camera.CFrame.Position).Unit * 500,  RAY_CAST_PARAMS);
	else
		raycastResult = workspace:Raycast(camera.CFrame.Position, (mousePosition - camera.CFrame.Position).Unit * 500,  RAY_CAST_PARAMS);
	end;
	
	if (raycastResult) then
		local hitPart = (raycastResult.Instance);
		local possibleCharacter = (hitPart.Parent:IsA("Model") and hitPart.Parent or hitPart.Parent.Parent:IsA("Model") and hitPart.Parent.Parent);
		if (possibleCharacter) then
			local possibleHumanoid = (possibleCharacter:FindFirstChildOfClass("Humanoid"));
			if (possibleHumanoid) then
				local damage = (0);
				local selectionBox = Instance.new("SelectionBox", hitPart)
				selectionBox.Color3 = Color3.fromRGB(255, 0, 0)
				selectionBox.LineThickness = 0.05
				selectionBox.Transparency = 1
				selectionBox.Adornee = hitPart
				tweenService:Create(selectionBox, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, true, 0), {Transparency = 0}):Play()
				debrisService:AddItem(selectionBox, 2)
				
				-- // Legs shot
				if (string.match(hitPart.Name, "Leg")) then
					damage = gunSettings.legdamage
				end;
				
				-- // Body Shot
				if (hitPart.Name == "HumanoidRootPart") or string.match(hitPart.Name, "Torso") or string.match(hitPart.Name, "Arm") or string.match(hitPart.Name, "Hand") then
					damage = gunSettings.legdamage
					CreateHitSound()
				end;

				-- // Head shot
				if (hitPart.Name == "Head") then
					damage = gunSettings.headshotdamage
					CreateHeadshotSound()
				end;
				
				replicatedStorage.FpsRemoteEvents.DealDamage:FireServer(possibleHumanoid, damage, "%!#*~!#%")
			else
				CreateBulletHole(raycastResult.Instance, raycastResult.Position, raycastResult.Normal)
			end;
		end;
	end;
end;

function Lerp(a, b, m)
	return a + (b - a) * m
end;


local offsetY = (0);
local lastShot = (tick());

if not (viewportFrame.WorldModel.Fps.PrimaryPart) then
	viewportFrame.WorldModel.Fps:GetPropertyChangedSignal("PrimaryPart"):Wait()	
end;

local RELOAD_CURRENT
local AIM_CFRAME = CFrame.new(0.498437107, -1.04976201, -0.0107922703, -0.143182933, 0.00625152839, 0.989672124, 0.0436191931, 0.999048233, -1.61267e-09, -0.988730192, 0.0431690849, -0.143319368);
local DEFAULT_ARMS_ROTATION_SPEED = (10);
local DEFAULT_ARMS_CFRAME = (viewportFrame.WorldModel.Fps:GetPrimaryPartCFrame());
local DEFAULT_RECOIL = (gunSettings.recoil);
local DEFAULT_FIRERATE = (gunSettings.firerate);

function Reload()
	isReloading = true
	CreateReloadSound()
	delay(2.5, function()
		isReloading = false
		ammo.Value = gunSettings.maxammo
		fps:SetPrimaryPartCFrame(DEFAULT_ARMS_CFRAME)
	end)

	pcall(function()
		RELOAD_CURRENT = DEFAULT_ARMS_CFRAME * CFrame.Angles(0, 0, math.pi / 2.5)
		wait(0.2)
		RELOAD_CURRENT = DEFAULT_ARMS_CFRAME * CFrame.new(0, -1, 0) * CFrame.Angles(0, 0, -math.pi / 2.5)
		wait(1.7)
		RELOAD_CURRENT = DEFAULT_ARMS_CFRAME
	end)
end;

local aimDepthOfField = Instance.new("DepthOfFieldEffect", camera)
aimDepthOfField.FarIntensity = 0
aimDepthOfField.FocusDistance = 20
aimDepthOfField.InFocusRadius = 10
aimDepthOfField.NearIntensity = 0.6
aimDepthOfField.Enabled = true
local DEFAULT_SENSITIVITY = (userInputService.MouseDeltaSensitivity);

local localMouse = (localPlayer:GetMouse());
function Heartbeat(dt)
	crosshair.Position = UDim2.fromOffset(localMouse.X, localMouse.Y)
	localCharacter:WaitForChild("Humanoid")
	local mouseDelta = (userInputService:GetMouseDelta());
	
	for _, possibleTool in next, localCharacter:GetChildren() do
		if (possibleTool:IsA("Tool")) then
			for _, basePart in next, possibleTool:GetDescendants() do
				if (basePart:IsA("BasePart")) then
					basePart.LocalTransparencyModifier = 1
				end;
			end;
		end;
	end;
	
	if (isRunKeyPressed) and not (isReloading) and not (shooting) and not (isAimKeyPressed) and not (isCrouching) then
		isRunning = true
		localCharacter.Humanoid.WalkSpeed = 21
	elseif not (isRunKeyPressed) or (isReloading) or (isAimKeyPressed) or (shooting) or (isCrouching) then
		isRunning = false
		localCharacter.Humanoid.WalkSpeed = (isCrouching) and 8 or 16
	end;
	
	if (isRunning) and not (isReloading) and not (isAimKeyPressed) then
		viewportFrame.WorldModel.Fps:SetPrimaryPartCFrame(viewportFrame.WorldModel.Fps:GetPrimaryPartCFrame():Lerp(DEFAULT_ARMS_CFRAME * CFrame.Angles(0, math.rad(45), 0) * CFrame.Angles(0, -math.rad(math.min(mouseDelta.X, 7)), -math.rad(math.min(mouseDelta.Y, 7))), dt * 10))
	elseif not (isReloading) and not (isAimKeyPressed) then
		viewportFrame.WorldModel.Fps:SetPrimaryPartCFrame(viewportFrame.WorldModel.Fps:GetPrimaryPartCFrame():Lerp(DEFAULT_ARMS_CFRAME * CFrame.Angles(0, -math.rad(math.min(mouseDelta.X, 7)), -math.rad(math.min(mouseDelta.Y, 7))), dt * DEFAULT_ARMS_ROTATION_SPEED))
	end;
	
	if (isReloading) then
		viewportFrame.WorldModel.Fps:SetPrimaryPartCFrame(viewportFrame.WorldModel.Fps:GetPrimaryPartCFrame():Lerp(RELOAD_CURRENT * CFrame.Angles(0, -math.rad(math.min(mouseDelta.X, 7)), -math.rad(mouseDelta.Y / 5)), dt * DEFAULT_ARMS_ROTATION_SPEED))
	end;
	
	if (isCrouching) then
		gunSettings.recoil = (isAimKeyPressed) and (gunSettings.crouch_aim_recoil) or (gunSettings.crouch_notaim_recoil)
		gunSettings.firerate = (isAimKeyPressed) and (gunSettings.crouch_aim_firerate) or (gunSettings.crouch_notaim_firerate)
		localCharacter.Humanoid.CameraOffset = Vector3.new(0, Lerp(localCharacter.Humanoid.CameraOffset.Y, -1.5, dt * 10), 0)
	else
		gunSettings.recoil = DEFAULT_RECOIL
		gunSettings.firerate = DEFAULT_FIRERATE
		localCharacter.Humanoid.CameraOffset = Vector3.new(0, Lerp(localCharacter.Humanoid.CameraOffset.Y, 0, dt * 10), 0)
	end;
	
	if (isAimKeyPressed) and not (isReloading) and not (isRunning) then
		crosshair.Visible = false
		viewportFrame.WorldModel.Fps:SetPrimaryPartCFrame(viewportFrame.WorldModel.Fps:GetPrimaryPartCFrame():Lerp(AIM_CFRAME * CFrame.Angles(0, -math.rad(math.min(mouseDelta.X, 7)), -math.rad(mouseDelta.Y / 5)), dt * 15))
		userInputService.MouseDeltaSensitivity = DEFAULT_SENSITIVITY / 3
		tweenService:Create(camera, TweenInfo.new(0.15, Enum.EasingStyle.Sine), {FieldOfView = 45}):Play()
		gunSettings.recoil = not (isCrouching) and (gunSettings.aim_notcrouch_recoil) or gunSettings.recoil
		gunSettings.firerate = not (isCrouching) and (gunSettings.aim_notcrouch_firerate) or gunSettings.firerate
		aimDepthOfField.Enabled = true
	else
		crosshair.Visible = true
		tweenService:Create(camera, TweenInfo.new(0.15, Enum.EasingStyle.Sine), {FieldOfView = 70}):Play()
		userInputService.MouseDeltaSensitivity = DEFAULT_SENSITIVITY
		gunSettings.recoil = not (isCrouching) and DEFAULT_RECOIL or gunSettings.recoil
		gunSettings.firerate = not (isCrouching) and DEFAULT_FIRERATE or gunSettings.firerate
		aimDepthOfField.Enabled = false
	end;
	
	if (localCharacter.HumanoidRootPart.Velocity.Magnitude < 10) then
		offsetY = 0
		crosshair.Size = crosshair.Size:Lerp(UDim2.fromOffset(16, 16), dt * 10)
	else
		crosshair.Size = crosshair.Size:Lerp(UDim2.fromOffset(50, 50), dt * 10)
		if (isRunning) then
			offsetY = math.abs(math.sin(tick() * 5) / (6))
		end;
			
		if not (isRunning) and not (isAimKeyPressed) then
			offsetY = math.abs(math.sin(tick() * 4) / (10))
		elseif not (isRunning) and (isAimKeyPressed) then
			offsetY = math.abs(math.sin(tick() * 4) / (20))
		end;
	end;
		
	fps.Fire.Transparency = Lerp(fps.Fire.Transparency, transparencyGoal, dt * FIRE_FLASH_SPEED)
	viewportFrame.Position = UDim2.fromScale(0.5, Lerp(viewportFrame.Position.Y.Scale, VIEWPORT_FRAME_ORIGINAL_POSITION.Y.Scale + offsetY, dt * 10))
	infoFrame.Ammo.Text = not (isReloading) and (string.format("%s/%s", ammo.Value, tostring(gunSettings.maxammo))) or ("Reloading...")
	
	if (shooting == true) and (lastShot) and (tick() - lastShot > gunSettings.firerate) and not (isRunning) and not (isReloading) then
		if (ammo.Value == 0) then
			Reload()
			return	
		end;
		
		ammo.Value = ammo.Value - 1
		lastShot = tick()
		Shoot()
	end
end;

runService.Heartbeat:Connect(Heartbeat)

function ActionBindedRun(actionName, inputState, inputObject)
	if (inputState == Enum.UserInputState.Begin) then
		isRunKeyPressed = true
	elseif (inputState == Enum.UserInputState.End) then
		isRunKeyPressed = false
	end;
end;

contextActionService:BindAction("Run", ActionBindedRun, false, Enum.KeyCode.LeftShift)

function ActionBindedReload(actionName, inputState, inputObject)
	if (isReloading) then return end;
	if (inputState == Enum.UserInputState.Begin) and (ammo.Value < gunSettings.maxammo) then
		Reload()
	end;
end;

contextActionService:BindAction("Reload", ActionBindedReload, false, Enum.KeyCode.R)


function ActionBindedAim(actionName, inputState, inputObject)
	if (inputState == Enum.UserInputState.Begin) then
		isAimKeyPressed = true
	elseif (inputState == Enum.UserInputState.End) then
		isAimKeyPressed = false
	end;
end;

contextActionService:BindAction("Aim", ActionBindedAim, false, Enum.UserInputType.MouseButton2)

function ActionBindedCrouch(actionName, inputState, inputObject)
	if (inputState == Enum.UserInputState.Begin) then
		isCrouching = true
	elseif (inputState == Enum.UserInputState.End) then
		isCrouching = false
	end;
end;

contextActionService:BindAction("Crouch", ActionBindedCrouch, false, Enum.KeyCode.C, Enum.KeyCode.LeftControl)

function HumanoidDied()
	script.Parent:Destroy()
end;

localCharacter:WaitForChild("Humanoid")
localCharacter.Humanoid.Died:Connect(HumanoidDied)
local starterGui = (game:GetService("StarterGui"));
starterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)

replicatedStorage.FpsRemoteEvents.CreateWeapon:FireServer("BlockWeapon")
function RemoveMuzzle(tool)
	local muzzle = (tool:FindFirstChild("Muzzle"));
	if (muzzle) then
		muzzle.MuzzleEmitter:Destroy()
	end;
end;

repeat wait() until localCharacter:FindFirstChildOfClass("Tool")