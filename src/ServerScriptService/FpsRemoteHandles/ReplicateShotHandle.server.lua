local players = (game:GetService("Players"));
local replicatedStorage = (game:GetService("ReplicatedStorage"));

function OnServerEvent(player, tool)
	local character = (player.Character or player.CharacterAdded:Wait());
	local humanoid = (character:FindFirstChildOfClass("Humanoid"));
	local muzzleEmitter = (tool.Muzzle.MuzzleEmitter);
	for _, notPlayer in next, players:GetChildren() do
		if (notPlayer == player) then continue end;
		replicatedStorage.FpsRemoteEvents.ReplicateShot:FireClient(notPlayer, muzzleEmitter)
	end;
end;

replicatedStorage.FpsRemoteEvents.ReplicateShot.OnServerEvent:Connect(OnServerEvent)