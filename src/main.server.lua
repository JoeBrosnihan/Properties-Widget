
print("Launching Lua Properties Widget...")

local src = script.Parent

local Roact = require(src.Roact)
local Reflection = require(src.Reflection)
local CategoryComponent = require(src.Components.CategoryComponent)



local widgetInfo = DockWidgetPluginGuiInfo.new(
	Enum.InitialDockState.Right,
	true,
	true
)
local widget = plugin:CreateDockWidgetPluginGui("CustomPropertiesWidget", widgetInfo)
widget.Name = "Properties"
widget.Title = "Properties Lua"

local selectionService = game:GetService("Selection")
local rootHandle

--selection changed
	--disconnect old connections
	--setup new connections
		--connection fired
			--reconcile
			
			
--need to store list of prop components keyed by prop name
	--[[
		should technically key by prop desc to avoid unnecessary invalidation in case of
		multiple props sharing same name, but that would probably yield worse perf.
	]]




local PropertiesComponent = Roact.PureComponent:extend("PropertiesComponent")


local function addClassPropDescriptors(classDesc, propCategories)
	while classDesc do
		for _,prop in pairs(classDesc._PropsByName) do
			local cat = propCategories[prop.Category] or {}
			propCategories[prop.Category] = cat
			cat[prop] = true
		end
		classDesc = Reflection.classesByName[classDesc.Superclass]
	end
end

-- Leave cookies in the prop descriptors to know if they're readable from Lua
local function processPropDescriptors(propCategories, selection) --TODO: what's the point of this? Can we do this when we go to render instead?
	for _,catProps in pairs(propCategories) do
		for propDesc,_ in pairs(catProps) do
			if propDesc._LuaCanRead == nil then
				for _,v in pairs(selection) do
					if v:IsA(propDesc._Class.Name) then
						propDesc._LuaCanRead = false
						pcall(function()
							local readTest = v[propDesc.Name] -- This may throw.
							propDesc._LuaCanRead = true
						end)
						break;
					end
				end
			end
		end
	end
end

function PropertiesComponent:init()
	self.state = { --TODO: why can't I use setState here?
		connections = {},
		propChanged = false,
		heartbeatConnection = nil,
	}

	self.onHeartbeat = (function(step)
		if (self.state.propChanged) then
			self:setState({
				propChanged = false -- trigger a re-render
			})
		end
	end)
end

function PropertiesComponent:didMount()
	self.state.heartbeatConnection = game:GetService("RunService").Heartbeat:Connect(self.onHeartbeat)
end

local function disconnectAll(connections)
	for _,v in pairs(connections) do
		v:Disconnect()
	end
end

function PropertiesComponent:render()
	local selection = self.props.selection
	
	if not selection or #selection == 0 then
		return
	end
	
	local selectedClasses = {}
	local propCategories = {}
	for _,v in pairs(selection) do
		local classDesc = Reflection.classesByName[v.ClassName]
		if not selectedClasses[classDesc] then
			selectedClasses[classDesc] = true
			addClassPropDescriptors(classDesc, propCategories)
		end
	end

	processPropDescriptors(propCategories, selection)
	
	local roactChildren = {
		ListLayout = Roact.createElement("UIListLayout")
	}

	for catName,catProps in pairs(propCategories) do
		roactChildren["Category_" .. catName] = Roact.createElement(CategoryComponent, {
			selection = selection,
			catName = catName,
			catProps = catProps,
		})
	end
	
	-- update children upon property change
	
	local dirtyFunction = (function(propName)
		self:setState(function(prevState)
			if prevState.propChanged then
				return nil
			else
				return { propChanged = true } --TODO: don't trigger a re-render. In case of BoolProps, it can flash an intermediate value
			end
		end)
	end)

	disconnectAll(self.state.connections)
	local connections = {}
	self.state.connections = connections
	for _,v in pairs(selection) do -- Note that chaning one property on N instances causes N reconciles. Could be improved
		local con = v.Changed:Connect(dirtyFunction)
		table.insert(connections, con)
	end
	
	return Roact.createElement("ScrollingFrame", {
		Size = UDim2.new(1, 0, 1, 0),
	}, roactChildren)
end

function PropertiesComponent:willUnmount()
	disconnectAll(self.state.connections)
	self.state.connections = {}
	self.state.heartbeatConnection:Disconnect()
end

local root = Roact.createElement(PropertiesComponent, {
	selection = selectionService:Get()
})

rootHandle = Roact.mount(root, widget, "RoactGenerated")

selectionService.SelectionChanged:Connect(function()
	rootHandle = Roact.reconcile(rootHandle, Roact.createElement(PropertiesComponent, {
		selection = selectionService:Get()
	}))
end)

print("Lua Properties Widget running")









