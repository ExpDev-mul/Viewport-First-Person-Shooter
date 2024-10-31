local runService = (game:GetService("RunService"));

local camera = (workspace.CurrentCamera);
local degreesText = (script.Parent:WaitForChild("Degrees"));
local directionText = (script.Parent:WaitForChild("Direction"));

function WithinRange(x, min, max)
	if (x >= min) and (x < max) then
		return (true)
	end;
end;

local directions = {};
directions[0] = "North"
directions[45] = "North West"
directions[90] = "West"
directions[135] = "South West"
directions[180] = "South"
directions[225] = "South East"
directions[270] = "East"
directions[315] = "North East"
directions[360] = "North East"
function RenderStep(dt)
	local x, y, z = camera.CFrame:ToEulerAnglesYXZ()
	local deg = math.ceil(math.deg(y));
	deg = (deg < 0) and (180 + math.abs(math.abs(deg) - 181)) or (deg)
	degreesText.Text = string.format("%d°", math.round(deg / 5) * 5)
	local direction = ("North");
	for i = 0, 360, 45 do
		if (WithinRange(deg, i, i + 45)) then
			directionText.Text = directions[i]
		end;
	end;
end;

runService.RenderStepped:Connect(RenderStep)