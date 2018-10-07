
local src = script.Parent

local Roact = require(src.Roact)
local GenericProp = require(src.Components.GenericProp)
local StringProp = require(src.Components.StringProp)
local BoolProp = require(src.Components.BoolProp)


local PropComponentFactory = {}


local function shouldRender(propDesc)
	if not propDesc._LuaCanRead then
		return false
	end

	local tags = propDesc.Tags
	if tags then
		return not (tags.Deprecated or tags.NotBrowsable)
	end

	return true
end

local function getUniqueValue(selection, propName) --TODO: handle prop name collisions
	local value = nil
	local hasBeenSet = false
	local unique = true
	for _,v in pairs(selection) do
		local newValue = v[propName]
		
		if not hasBeenSet then
			value = newValue
			hasBeenSet = true
		elseif value ~= newValue then
			unique = false
			return false
		end
	end
	
	if hasBeenSet and unique then
		return true, value
	else
		return false
	end
end

local function propSetter(selection, propDesc, value)
	for _,v in pairs(selection) do
		if v:IsA(propDesc._Class.Name) then
			pcall(function() -- TODO: better error handling. Possibly print the error.
				v[propDesc.Name] = value
			end)
		end
	end
end

function PropComponentFactory.createComponent(propDesc, selection)
	if not shouldRender(propDesc) then
		return nil
	end
	
	local unique, value = getUniqueValue(selection, propDesc.Name)
	local roactProps = {
		selection = selection,
		propDesc = propDesc,
		propSetter = propSetter,
		unique = unique,
		value = value,
	}

	local valueType = propDesc.ValueType.Name

	if valueType == "string" or valueType == "ProtectedString" then -- TODO: need separate ProtectedStringProp?
		return Roact.createElement(StringProp, roactProps)
	elseif valueType == "bool" then
		return Roact.createElement(BoolProp, roactProps)
	else
		return Roact.createElement(GenericProp, roactProps)
	end
end

return PropComponentFactory
