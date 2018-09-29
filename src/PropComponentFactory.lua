
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

function PropComponentFactory.createComponent(propDesc, selection)
	if not shouldRender(propDesc) then
		return nil
	end
	
	local roactProps = {
		selection = selection,
		name = propDesc.Name --TODO: pass the propDesc instead?
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
