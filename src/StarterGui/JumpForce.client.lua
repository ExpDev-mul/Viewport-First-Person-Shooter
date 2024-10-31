local players = (game:GetService("Players"));

local localPlayer = (players.LocalPlayer);
local localCharacter = (localPlayer.Character or localPlayer.CharacterAdded:Wait());
localCharacter:WaitForChild("Humanoid")
local bodyForce = Instance.new("BodyForce", localCharacter)
local GRAVITY = workspace.Gravity
local mass = (0);
for _, basePart in next, localCharacter:GetDescendants() do
	if (basePart:IsA("BasePart")) then
		mass = mass + basePart:GetMass()
	end;
end;

bodyForce.Force = Vector3.new(0, (mass * GRAVITY) / 1.5)

local vectorForce = (nil);
function StateChanged(oldOne, newOne)
	if (newOne == Enum.HumanoidStateType.Jumping) then
		if (vectorForce) then return end;
		vectorForce = Instance.new("VectorForce", localCharacter.HumanoidRootPart)
		vectorForce.Force = Vector3.new(0, 0, -2500)
		vectorForce.Attachment0 = localCharacter.HumanoidRootPart:FindFirstChildOfClass("Attachment")
	elseif (newOne == Enum.HumanoidStateType.Landed) or (newOne == Enum.HumanoidStateType.Running) then
		if (vectorForce) then
			vectorForce:Destroy()
			vectorForce = nil
		end;
	end;
end;

localCharacter.Humanoid.StateChanged:Connect(StateChanged)