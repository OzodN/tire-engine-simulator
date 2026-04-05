local UserInputService = game:GetService("UserInputService")

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then
		return
	end

	if input.KeyCode == Enum.KeyCode.E then
		print("Interact")
	end
end)
