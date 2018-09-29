
print("Launching Lua Properties Widget...")

local src = script.Parent

local Roact = require(src.Roact)
local RBX = require(src.ParsedAPI)
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




local PropertiesComponent = Roact.Component:extend("PropertiesComponent")


local function addClassPropDescriptors(classDesc, propDescriptorList)
	while classDesc do
		for _,prop in pairs(classDesc.properties) do
			propDescriptorList[prop] = true
		end
		classDesc = RBX[classDesc.Superclass]
	end
end

-- Leave cookies in the prop desc's to know if they're readable from Lua
local function processPropDescSet(propDescSet, selection)
	for propDesc,_ in pairs(propDescSet) do
		if propDesc.luaCanRead == nil then
			for _,v in pairs(selection) do
				if v:IsA(propDesc.Class) then
					propDesc.luaCanRead = false
					pcall(function()
						local _ = v[propDesc.Name] -- This may throw.
						propDesc.luaCanRead = true
					end)
					break;
				end
			end
		end
	end
end

function PropertiesComponent:init()
	self.state = { --TODO: why can't I use setState here?
		connections = {}
	}
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
		local classDesc = RBX[v.ClassName]
		if not selectedClasses[classDesc] then
			selectedClasses[classDesc] = true
			addClassPropDescriptors(classDesc, propDescriptors)
		end
	end
	
	processPropDescSet(propDescriptors, selection)
	
	local roactChildren = {
		ListLayout = Roact.createElement("UIListLayout")
	}
	for prop,_ in pairs(propDescriptors) do
		local component = PropComponentFactory.createComponent(prop, selection)
		if component then --TODO: can I remove this conditional? Adding a nil value is the same as not adding the key?
			roactChildren["Prop_" .. prop.Name] = component
		end
	end
	
	-- update children upon property change
	
	disconnectAll(self.state.connections)
	local connections = {}
	self.state.connections = connections
	for _,v in pairs(selection) do -- Note that chaning one property on N instances causes N reconciles. Could be improved
		v.Changed:Connect(function(propName)
			--Just nuke everything and rebuild for now.
			rootHandle = Roact.reconcile(rootHandle, Roact.createElement(PropertiesComponent, {
				selection = selection
			}))
			--[[
			local prop
			for propDesc,_ in pairs(propDescriptors) do
				if propDesc.Name == propName then
					prop = propDesc
					break
				end
			end
			assert(prop)
			
			local oldComponent = roactChildren["Prop_" .. propName]
			local newComponent = PropComponentFactory.createComponent(prop, selection)
			if oldComponent and newComponent then
				print("reconciling")
				Roact.reconcile(oldComponent, newComponent) --This is not how Roact works
			end
			]]
		end)
	end
	
	return Roact.createElement("ScrollingFrame", {
		Size = UDim2.new(1, 0, 1, 0),
	}, roactChildren)
end

function PropertiesComponent:willUnmount()
	disconnectAll(self.state.connections)
	self.state.connections = {}
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









