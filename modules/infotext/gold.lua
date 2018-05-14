-- Gold Infotext

------------------------------------------------------
-- / SETUP AND LOCALS / --
local _, LUI = ...
local module = LUI:GetModule("Infotext")
local element = module:NewElement("Gold", "AceEvent-3.0")
local L = LUI.L
local db, dbRealm, dbGlobal

-- local copies
local pairs, ipairs, mod = pairs, ipairs, mod
local format, floor, abs = format, floor, abs
local BreakUpLargeNumbers = BreakUpLargeNumbers
local GetMoneyString = GetMoneyString
local GetMoney = GetMoney

-- constants
local COPPER_AMOUNT_SYMBOL = COPPER_AMOUNT_SYMBOL
local SILVER_AMOUNT_SYMBOL = SILVER_AMOUNT_SYMBOL
local GOLD_AMOUNT_SYMBOL = GOLD_AMOUNT_SYMBOL
local COPPER_PER_SILVER = COPPER_PER_SILVER
local SILVER_PER_GOLD = SILVER_PER_GOLD
local COPPER_PER_GOLD = COPPER_PER_GOLD
local MONEY_COLON = MONEY_COLON

local SILVER_COLOR = "|cffc7c7cf"
local COPPER_COLOR = "|cffeda55f"
local GOLD_COLOR = "|cffffd700"

-- Prevent Neutral and any other minor faction Blizzard entering the global db. (ie: Scourge event)
local SUPPORTED_FACTION = {
	Alliance = true,
	Horde = true,
	Neutral = false,
}
local FACTION_ORDER_REALM = {
	LUI.playerFaction,
	LUI.otherFaction,
	"Neutral",
}
local FACTION_ORDER_GLOBAL = {
	LUI.playerFaction,
	LUI.otherFaction,
}

-- locals
local moneyProfit = 0
local moneySpent = 0
local previousMoney = 0

-- Defaults
element.defaults = {
	profile = {
		X = 15,
		showRealm = false,
		useBlizzard = false,
		showCopper = false,
		coloredSymbols = false,
	},
	--Keeps tracks of characters on current realm
	realm = {
		Alliance = {},
		Horde = {},
		Neutral = {},
	},
	--Keep tracks of server totals
	global = {
		Alliance = {},
		Horde = {},
	},
}

------------------------------------------------------
-- / MODULE FUNCTIONS / --
------------------------------------------------------
function element:FormatMoney(money, color)
	if db.useBlizzard then return GetMoneyString(money) end

	money = abs(money)
	local gold = floor(money / (COPPER_PER_GOLD))
	local silver = mod(floor(money / COPPER_PER_SILVER), SILVER_PER_GOLD)
	local copper = mod(money, COPPER_PER_SILVER)
	--BreakUpLargeNumber returns a string, not a number.
	local goldString = format("%s%s%s|r", BreakUpLargeNumbers(gold), (color) and GOLD_COLOR or "", GOLD_AMOUNT_SYMBOL)
	local silverString = format("%d%s%s|r", silver, (color) and SILVER_COLOR or "", SILVER_AMOUNT_SYMBOL)
	local copperString = format("%d%s%s|r", copper, (color) and COPPER_COLOR or "", COPPER_AMOUNT_SYMBOL)

	if gold > 0 and db.showCopper then
		return format("%s %s %s", goldString, silverString, copperString)
	elseif gold > 0 then
		return format("%s %s", goldString, silverString)
	elseif silver > 0 then
		return format("%s %s", silverString, copperString)
	else
		return format("%s", copperString)
	end

end

function element:UpdateGold()
	local newMoney = GetMoney()
	-- Change will be positive if we gain money
	local change = newMoney - previousMoney

	if previousMoney > newMoney then  -- Lost Money
		moneySpent = moneySpent - change
	else                              -- Gained Money
		moneyProfit = moneyProfit + change
	end

	--Update gold count
	previousMoney = newMoney
	dbRealm[LUI.playerName] = newMoney
	if SUPPORTED_FACTION[LUI.playerFaction] then
		dbGlobal[LUI.playerRealm] = dbGlobal[LUI.playerRealm] + change
	end

	local money = (db.showRealm) and dbGlobal[LUI.playerRealm] or newMoney
	element.text = element:FormatMoney(money)
	element:UpdateTooltip()
end

function element:UpdateRealmMoney()
	--Update for current character
	dbRealm[LUI.playerName] = GetMoney()
	--Update for realm list
	local realmGold = 0
	for _, money in pairs(dbRealm) do
		realmGold = realmGold + money
	end
	if SUPPORTED_FACTION[LUI.playerFaction] then
		dbGlobal[LUI.playerRealm] = realmGold
	end
end

function element.OnClick(frame_, button)
	if button == "RightButton" then
		moneySpent = 0
		moneyProfit = 0
		element:UpdateTooltip()
	else
		db.showRealm = not db.showRealm
		element:UpdateGold()
	end
end

function element.OnTooltipShow(GameTooltip)
	element:TooltipHeader(MONEY_COLON)

	GameTooltip:AddLine(L["InfoGold_Session"])
	GameTooltip:AddDoubleLine(L["InfoGold_Earned"], element:FormatMoney(moneyProfit, true), 1,1,1, 1,1,1)
	GameTooltip:AddDoubleLine(L["InfoGold_Spent"], element:FormatMoney(moneySpent, true), 1,1,1, 1,1,1)

	local change = moneyProfit - moneySpent
	if change > 0 then
		local r, g, b = LUI:PositiveColor()
		GameTooltip:AddDoubleLine(L["InfoGold_Profit"], element:FormatMoney(change, true), r, g, b, 1,1,1)
	elseif change < 0 then
		local r, g, b = LUI:NegativeColor()
		GameTooltip:AddDoubleLine(L["InfoGold_Deficit"], element:FormatMoney(change, true), r, g, b, 1,1,1)
	end

	GameTooltip:AddLine(" ")
	GameTooltip:AddLine(L["InfoGold_Characters"] )
	for i, faction in ipairs(FACTION_ORDER_REALM) do
		local dbRealm = element:GetDB("realm", faction)
		for name, money in pairs(dbRealm) do
			local r, g, b = LUI:GetFactionColor(faction)
			GameTooltip:AddDoubleLine(name, element:FormatMoney(money, true), r, g, b, 1,1,1)
		end
	end
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine(L["InfoGold_Realms"])
	for i, faction in ipairs(FACTION_ORDER_GLOBAL) do
		local dbGlobal = element:GetDB("global", faction)
		for realm, money in pairs(dbGlobal) do
			local r, g, b = LUI:GetFactionColor(faction)
			GameTooltip:AddDoubleLine(format("%s-%s", realm, faction), element:FormatMoney(money, true), r, g, b, 1,1,1)
		end
	end

	element:AddHint(L["InfoGold_Hint_Any"], L["InfoGold_Hint_Right"])
end

------------------------------------------------------
-- / FRAMEWORK FUNCTIONS / --
------------------------------------------------------
function element:OnCreate()
	db = element:GetDB()
	dbRealm = element:GetDB("realm", LUI.playerFaction)
	dbGlobal = element:GetDB("global", LUI.playerFaction)
	previousMoney = GetMoney()

	element:RegisterEvent("PLAYER_MONEY", "UpdateGold")
	element:UpdateRealmMoney()
	element:UpdateGold()
end
