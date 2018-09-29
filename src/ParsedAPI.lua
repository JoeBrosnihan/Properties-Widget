

local httpService = game:GetService("HttpService")
local apiJson = httpService:GetAsync("https://raw.githubusercontent.com/ScriptGuider/First/master/Testing")
local apiTable = httpService:JSONDecode(apiJson)

local classes = {}

for k,v in pairs(apiTable) do
	if v.type == "Class" then
		classes[v.Name] = v
		v.properties = {}
	elseif v.type == "Property" then
		local class = classes[v.Class]
		class.properties[v.Name] = v
	end
end

return classes
