
local src = script.Parent.Parent

local Roact = require(src.Roact)
local Style = require(src.Style)
local PropComponentFactory = require(src.PropComponentFactory)


local Category = Roact.PureComponent:extend("Category")


function Category:render()
	local selection = self.props.selection
	local name = self.props.catName
	local propDescSet = self.props.catProps
	

	local children = {
		ListLayout = Roact.createElement("UIListLayout"),
		CategoryName = Roact.createElement("TextLabel", {
			Text = name,
			Size = UDim2.new(1, 0, 0, Style.rowHeight),
			BackgroundColor3 = Style.borderColor,
			BorderColor3 = Style.borderColor,
			TextColor3 = Style.textColor,
			Font = Style.boldFont,
			TextSize = Style.textSize,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			TextWrap = false,
		})
	}

	local nProps = 0
	for prop,_ in pairs(propDescSet) do -- TODO: Move out of render. Reading every prop on every render is expensive (9+ ms) an unnecessary.
		local component = PropComponentFactory.createComponent(prop, selection)
		if component then
			children["Prop_" .. prop.Name] = component --TODO: handle name collisions
			nProps = nProps + 1
		end
	end

	return Roact.createElement("Frame", {
		Size = UDim2.new(1, 0, 0, Style.rowHeight * (1 + nProps)),
	}, children)
end

return Category