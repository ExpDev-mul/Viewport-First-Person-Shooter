local runService = (game:GetService("RunService"));
local players = (game:GetService("Players"));

local localPlayer = (players.LocalPlayer);
local localCharacter = (localPlayer.Character or localPlayer.CharacterAdded:Wait());
local localHumanoid = (localCharacter:WaitForChild("Humanoid"));

local camera = (workspace.CurrentCamera);

function RenderStep(dt)
	if not (localCharacter.HumanoidRootPart.Velocity.Magnitude < 10) and (localHumanoid.WalkSpeed > 16) then
		local speed = (localHumanoid.WalkSpeed); -- // How strong will the shake be.
		local sine = math.sin(tick() * speed);
		sine = sine / 4 -- // By default, math.sin(x) ranges from -1 to 1. By diving it by 4 the range is now -0.25 to 0.25.
		camera.CFrame = camera.CFrame * CFrame.Angles(math.rad(sine), math.rad(sine), 0)
	end;
end;

runService.RenderStepped:Connect(RenderStep)