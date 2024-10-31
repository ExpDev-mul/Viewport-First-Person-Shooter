local debrisService = (game:GetService("Debris"));
local replicatedStorage = (game:GetService("ReplicatedStorage"));

function OnServerEvent(player, animationId)
	local character = (player.Character or player.CharacterAdded:Wait());
	local humanoid = (character:FindFirstChildOfClass("Humanoid"));
	if (humanoid.Health > 0) then
		local animation = Instance.new("Animation");
		animation.AnimationId = animationId
		humanoid:LoadAnimation(animation):Play()
		debrisService:AddItem(animation, 5)
	end;
end;

replicatedStorage.FpsRemoteEvents.ReplicateAnimation.OnServerEvent:Connect(OnServerEvent)