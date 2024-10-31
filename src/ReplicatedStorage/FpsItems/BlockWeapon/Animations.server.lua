local equipAnimation = (script:WaitForChild("Equip"));

local weapon = (script.Parent);
local existingTrack = (nil);
function OnEquip()
	local character = (weapon.Parent);
	if (character:IsA("Model")) and (character:FindFirstChildOfClass("Humanoid")) then
		local humanoid = (character:FindFirstChildOfClass("Humanoid"));
		existingTrack = humanoid:LoadAnimation(equipAnimation)
		existingTrack:Play()
	end;
end;

weapon.Equipped:Connect(OnEquip)

function OnUnequip()
	if (existingTrack) then
		existingTrack:Stop()
		existingTrack = nil
	end;
end;

weapon.Unequipped:Connect(OnUnequip)