
local src = script.Parent.Parent

local Roact = require(src.Roact)
local Style = require(src.Style)

local StringProp = Roact.Component:extend("StringProp")



local function getUniqueValue(selection, propName)
	local value = nil
	local hasBeenSet = false
	local unique = true
	for _,v in pairs(selection) do
		pcall(function() -- Prop may not be present. Also, reading can sometimes throw.
			local newValue = v[propName]
			assert(typeof(newValue) == "string")
			
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

--TODO: convert component to a function, since StringProp has no state

function StringProp:render()
	local selection = self.props.selection
	local name = self.props.name
	
	local unique, value = getUniqueValue(selection, name)
	
	local displayValue
	if unique then
		displayValue = tostring(value) -- TODO: shouldn't need to do this in case of StringProp!
			
		if name == "Source" then -- Special case for Scripts, just for fun. TODO: remove this
			displayValue = "📝..."
		end
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
		PropValue = Roact.createElement("TextBox", {
			Text = displayValue,
			Size = UDim2.new(1, -Style.propNameWidth, 1, 0),
			Position = UDim2.new(0, Style.propNameWidth, 0, 0),
			BackgroundColor3 = Style.propColor,
			BorderColor3 = Style.borderColor,
			TextColor3 = Style.textColor,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			TextWrap = false,
			
			[Roact.Event.FocusLost] = (function(inst, enterPressed)
				if enterPressed then
					for _,v in pairs(selection) do
						pcall(function() --TODO: I can probably avoid pcall here by doing some checks?
							v[name] = inst.Text
						end)
					end
				end
			end)
		})
	})
end

return StringProp
