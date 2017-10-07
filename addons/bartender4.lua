------------------------------------------------------
-- / SETUP AND LOCALS / --
------------------------------------------------------
local addonname, LUI = ...
local module = LUI:GetModule("Addons")
local element = module:NewElement("Bartender4")
local L = LUI.L
local db

--Defaults
element.defaults = {   
	profile = {
		Enable = true, -- Placeholder
	},
}

------------------------------------------------------
-- / MODULE FUNCTIONS / --
------------------------------------------------------

function element:DisableMod(name)
	local Bartender4 = LibStub("AceAddon-3.0"):GetAddon("Bartender4")
	Bartender4.db:GetNamespace(name).profile.enabled = false
	Bartender4:GetModule(name):Disable()
end

function element:CenterBarTemplate(id, yOffset)
	local configBar = Bartender4.db:GetNamespace("ActionBars").profile.actionbars
	configBar[id].enabled = true
	configBar[id].scale = 1
	configBar[id].padding = 4
	configBar[id].position.x = -243
	configBar[id].position.y = yOffset
	configBar[id].position.point = "BOTTOM"
end

function element:Install()
	local Bartender4 = LibStub("AceAddon-3.0"):GetAddon("Bartender4")
	-- Make sure Bartender4 is using the same profile name as LUI.
	Bartender4.db:SetProfile(LUI.db:GetCurrentProfile())
	
	-- Change bar settings
	local configBar = Bartender4.db:GetNamespace("ActionBars").profile.actionbars
	
	-- First, the three main bars in the middle, from bottom to top.
	element:CenterBarTemplate(1, 62)
	element:CenterBarTemplate(6, 102)
	element:CenterBarTemplate(5, 142)
	
	-- If I do Sidebars, these two will be used
	configBar[3].enabled = false
	configBar[4].enabled = false
	
	-- Disable other bars we don't need.
	configBar[2].enabled = false
	configBar[7].enabled = false
	configBar[8].enabled = false
	configBar[9].enabled = false
	configBar[10].enabled = false
	
	-- Move the Pet bar and Extra Action to the side.
	local config = Bartender4.db:GetNamespace("PetBar").profile
	config.position.point = "BOTTOMRIGHT"
	config.position.x = -195
	config.position.y = 295
	config.scale = 1
	config.padding = 2
	config.rows = 2
	
	local config = Bartender4.db:GetNamespace("ExtraActionBar").profile
	config.position.point = "BOTTOMRIGHT"
	config.position.x = -285
	config.position.y = 295
	config.scale = 1
	
	local config = Bartender4.db:GetNamespace("Vehicle").profile
	config.position.point = "BOTTOMRIGHT"
	config.position.x = -355
	config.position.y = 295
	config.scale = 1
	
	-- Disable some modules
	element:DisableMod("BagBar")
	element:DisableMod("MicroMenu")
	element:DisableMod("StanceBar")
	element:DisableMod("BlizzardArt")
	element:DisableMod("RepBar")
	element:DisableMod("XPBar")
	
	--[[ Preset Example from Bartender4 
	config = Bartender4.db:GetNamespace("ActionBars").profile
	config.actionbars[1].padding = 6
	SetBarLocation( config.actionbars[1], "BOTTOM", -256, 41.75 )
	config.actionbars[2].enabled = false
	config.actionbars[3].padding = 5 --]]
	
	Bartender4:UpdateModuleConfigs()
	module:GetDB().installed.Bartender4 = true
end

------------------------------------------------------
-- / FRAMEWORK FUNCTIONS / --
------------------------------------------------------
function element:OnInitialize()
end

function element:OnEnable()
end

function element:OnDisable()
end
