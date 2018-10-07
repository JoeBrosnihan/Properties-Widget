
local reflectionModule = require(2247441113)

local function getOptimizedClassesByName()
	local classesByName = {}

	local classTable = reflectionModule.ApiDump.Classes
	for _,class in pairs(classTable) do
		classesByName[class.Name] = class

		class._PropsByName = {}
		local propsByName = class._PropsByName

		for _,member in pairs(class.Members) do
			if member.MemberType == "Property" then
				propsByName[member.Name] = member
				member._Class = class
			end
		end
	end

	return classesByName
end


local Reflection = {
	classesByName = getOptimizedClassesByName()
}

return Reflection
