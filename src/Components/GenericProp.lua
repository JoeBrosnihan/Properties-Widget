
local src = script.Parent.Parent

local Roact = require(src.Roact)
local Style = require(src.Style)

local GenericProp = Roact.PureComponent:extend("GenericProp")



function GenericProp:render()
	local selection = self.props.selection
	local propDesc = self.props.propDesc
	local unique = self.props.unique
	local value = self.props.value

	local name = propDesc.Name
	
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
