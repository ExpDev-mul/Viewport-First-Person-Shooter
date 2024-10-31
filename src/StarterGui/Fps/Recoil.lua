local runService = (game:GetService("RunService"));
local players = (game:GetService("Players"));

local camera = (workspace.CurrentCamera);

local recoil = (0);
local recoilSign = (0);
local RECOIL_SPEED = (1.85);
local recoilModule = {}

function recoilModule.Recoil(m: multiply)
	recoil = recoil + m
	recoilSign = math.random(-1, 1)
	if (recoilSign == 0) then
		while (true) do
			recoilSign = math.random(-1, 1)
			if (recoilSign == 0) then
				recoilSign = math.random(-1, 1)
			else
				break
			end;
		end;
	end;
end;

function recoilModule.UpdateRecoil(dt)
	camera.CFrame = camera.CFrame:Lerp(camera.CFrame * CFrame.Angles(recoil, (recoil * (recoilSign * math.random(-100, 100) / 100) * math.random(1, 3)), 0), dt * RECOIL_SPEED)
	recoil = math.max(recoil - dt * RECOIL_SPEED, 0)
end;

runService.Heartbeat:Connect(recoilModule.UpdateRecoil)
return recoilModule