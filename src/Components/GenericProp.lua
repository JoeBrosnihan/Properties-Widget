
local src = script.Parent.Parent

local Roact = require(src.Roact)
local Style = require(src.Style)

local GenericProp = Roact.Component:extend("GenericProp")



local function getUniqueValue(selection, propName) --TODO: every PropComponent uses this. Should move somewhere else
	local value = nil
	local hasBeenSet = false
	local unique = true
	for _,v in pairs(selection) do
		pcall(function() -- Prop may not be present. Also, reading can sometimes throw.
			local newValue = v[propName]
			
			if not hasBeenSet then
				value = newValue
				hasBeenSet = true
			elseif value ~= newValue then
				unique = false
				return false
			end
		end)
	end
	
	if hasBeenSet and unique then
		return true, value
	else
		return false
	end
end

function GenericProp:render()
	local selection = self.props.selection
	local name = self.props.name
	
	local unique, value = getUniqueValue(selection, name)
	
	local displayValue
	if unique then
		displayValue = tostring(value)
	else
		displayValue = ""
	end
	
	return Roact.createElement("Frame", {
		Size = UDim2.new(1, 0, 0, Style.rowHeight),
		BackgroundColor3 = Style.propColor,
		BorderColor3 = Style.borderColor,
	}, {
		PropName = Roact.createElement("TextLabel", {
			Text = name,
			Size = UDim2.new(0, Style.propNameWidth, 1, 0),
			BackgroundColor3 = Style.propColor,
			BorderColor3 = Style.borderColor,
			TextColor3 = Style.textColor,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			TextWrap = false,
		}),
		PropValue = Roact.createElement("TextLabel", {
			Text = displayValue,
			Size = UDim2.new(1, -Style.propNameWidth, 1, 0),
			Position = UDim2.new(0, Style.propNameWidth, 0, 0),
			BackgroundColor3 = Style.propColor,
			BorderColor3 = Style.borderColor,
			TextColor3 = Style.textColor,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			TextWrap = false,
		})
	})
end

return GenericProp
