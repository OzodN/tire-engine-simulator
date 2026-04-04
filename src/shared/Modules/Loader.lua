local Loader = {}

function Loader.LoadFolder(folder)
	local modules = {}

	for _, module in ipairs(folder:GetChildren()) do
		if module:IsA("ModuleScript") then
			modules[module.Name] = require(module)
		end
	end

	return modules
end

return Loader
