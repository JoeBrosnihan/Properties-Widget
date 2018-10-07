
print("Launching Lua Properties Widget...")

local src = script.Parent

local Roact = require(src.Roact)
local Reflection = require(src.Reflection)
local PropComponentFactory = require(src.PropComponentFactory)



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


local function addClassPropDescriptors(classDesc, propDescriptorList)
	while classDesc do
		for _,prop in pairs(classDesc._PropsByName) do
			propDescriptorList[prop] = true
		end
		classDesc = Reflection.classesByName[classDesc.Superclass]
	end
end

-- Leave cookies in the prop desc's to know if they're readable from Lua
local function processPropDescSet(propDescSet, selection)
	for propDesc,_ in pairs(propDescSet) do
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
	local propDescriptors = {}
	for _,v in pairs(selection) do
		local classDesc = Reflection.classesByName[v.ClassName]
		if not selectedClasses[classDesc] then
			selectedClasses[classDesc] = true
			addClassPropDescriptors(classDesc, propDescriptors)
		end
	end
	
	processPropDescSet(propDescriptors, selection)
	
	local roactChildren = {
		ListLayout = Roact.createElement("UIListLayout")
	}
	for prop,_ in pairs(propDescriptors) do -- TODO: Move out of render. Reading every prop on every render is expensive (9+ ms) an unnecessary.
		local component = PropComponentFactory.createComponent(prop, selection)
		if component then
			roactChildren["Prop_" .. prop.Name] = component --TODO: handle name collisions
		end
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









