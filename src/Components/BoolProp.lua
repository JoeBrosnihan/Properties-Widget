
local src = script.Parent.Parent

local Roact = require(src.Roact)
local Style = require(src.Style)

local BoolProp = Roact.PureComponent:extend("BoolProp")


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
	local propDesc = self.props.propDesc
	local propSetter = self.props.propSetter
	local unique = self.props.unique
	local value = self.props.value

	local name = propDesc.Name

	
	local callback = (function(value)
		propSetter(selection, propDesc, value)
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
			Font = Style.font,
			TextSize = Style.textSize,
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
