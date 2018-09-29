
local src = script.Parent.Parent

local Roact = require(src.Roact)
local Style = require(src.Style)

local BoolProp = Roact.Component:extend("BoolProp")


local function getUniqueValue(selection, propName)
	local value = nil
	local hasBeenSet = false
	local unique = true
	for _,v in pairs(selection) do
		pcall(function() -- Prop may not be present. Also, reading can sometimes throw.
			local newValue = v[propName]
			assert(typeof(newValue) == "boolean")
			
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

local CheckBoxComponent = Roact.Component:extend("CheckBox")

function CheckBoxComponent:render()
	local unique = self.props.unique
	local value = self.props.value
	local position = self.props.position
	local callback = self.props.callback
	
	
	return Roact.createElement("ImageButton", {
		Size = UDim2.new(0, Style.checkboxWidth, 0, Style.checkboxWidth),
		AnchorPoint = Vector2.new(.5, .5),
		Position = position,
		BorderSizePixel = 0,
		Image = "rbxasset://textures/TerrainTools/checkbox_square.png", --TODO: don't reference rbxassets
		AutoButtonColor = false,
		BorderColor3 = Style.checkBoxColor,
		BackgroundColor3 = Style.propColor,
		
		[Roact.Event.Activated] = (function(args)
			if unique then
				callback(not value)
			else
				callback(false)
			end
		end),
	}, {
		CheckImage = Roact.createElement("ImageLabel", {
			Size = UDim2.new(0, Style.checkImageSize, 0, Style.checkImageSize),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			BorderSizePixel = 0,
			Active = false,
			
			Image = value and "rbxasset://textures/TerrainTools/icon_tick.png" or "", --TODO: don't reference rbxassets
			BackgroundTransparency = unique and 1 or 0,
			BackgroundColor3 = Style.nonUniqueCheckColor,
		})
	})
end

function BoolProp:render()
	local selection = self.props.selection
	local name = self.props.name
	
	
	local unique, value = getUniqueValue(selection, name)
	local callback = (function(value)
		for _,v in pairs(selection) do
			pcall(function() --TODO: I can probably avoid pcall here by doing some checks?
				v[name] = value
			end)
		end
	end)
	
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
		PropValue = Roact.createElement(CheckBoxComponent, {
			unique = unique,
			value = value,
			position = UDim2.new(0, Style.propNameWidth + Style.rowHeight / 2, 0, Style.rowHeight / 2),
			callback = callback,
		})
	})
end

return BoolProp
