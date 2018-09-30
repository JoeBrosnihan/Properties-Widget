
local src = script.Parent

local Roact = require(src.Roact)
local GenericProp = require(src.Components.GenericProp)
local StringProp = require(src.Components.StringProp)
local BoolProp = require(src.Components.BoolProp)


local PropComponentFactory = {}

local function arrayContains(array, value)
	for _,v in pairs(array) do
		if v == value then
			return true
		end
	end
	return false
end

local function shouldRender(propDesc)
	return propDesc.luaCanRead and not arrayContains(propDesc.tags, "deprecated") and not arrayContains(propDesc.tags, "notbrowsable")
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
		if v:IsA(propDesc.Class) then
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
	if propDesc.ValueType == "string" or propDesc.ValueType == "ProtectedString" then -- TODO: need separate ProtectedStringProp?
		return Roact.createElement(StringProp, roactProps)
	elseif propDesc.ValueType == "bool" then
		return Roact.createElement(BoolProp, roactProps)
	else
		return Roact.createElement(GenericProp, roactProps)
	end
end

return PropComponentFactory
