local ADDON_NAME, namespace = ... 	--localization
local L = namespace.L 				--localization
local version = GetAddOnMetadata(ADDON_NAME, "Version")
local addoninfo = 'v'..version

--{ dcsresetcheck Button Localization Widths }
local resetLocal = {
	["enUS"] = 125,
	["ptBR"] = 175,
	["frFR"] = 175,
	["deDE"] = 175,
	["ruRU"] = 175,
	["esES"] = 200,
}

local resetWidth = resetLocal[namespace.locale] or resetLocal["enUS"]

--{ DCSShowCharacterFrameButton Localization Widths }
local showCharLocal = {
	["enUS"] = 200,
	["deDE"] = 230,
}

local showCharWidth = showCharLocal[namespace.locale] or showCharLocal["enUS"]

--------------------------
-- SavedVariables Setup --
--------------------------
local _, addon = ...
local DejaClassicStats, gdbprivate = ...

gdbprivate.gdbdefaults = {
}
gdbprivate.gdbdefaults.gdbdefaults = {
}

----------------------------
-- Saved Variables Loader --
----------------------------
local loader = CreateFrame("Frame")
	loader:RegisterEvent("ADDON_LOADED")
	loader:SetScript("OnEvent", function(self, event, arg1)
		if event == "ADDON_LOADED" and arg1 == "DejaClassicStats" then
			local function initDB(gdb, gdbdefaults)
				if type(gdb) ~= "table" then gdb = {} end
				if type(gdbdefaults) ~= "table" then return gdb end
				for k, v in pairs(gdbdefaults) do
					if type(v) == "table" then
						gdb[k] = initDB(gdb[k], v)
					elseif type(v) ~= type(gdb[k]) then
						gdb[k] = v
					end
				end
				return gdb
			end

			DejaClassicStatsDBPC = initDB(DejaClassicStatsDBPC, gdbprivate.gdbdefaults) --the first per account saved variable. The second per-account variable DCS_ClassSpecDB is handled in DCS_Layouts.lua
			gdbprivate.gdb = DejaClassicStatsDBPC --fast access for checkbox states
			self:UnregisterEvent("ADDON_LOADED")
		end
	end)

local DejaClassicStats, private = ...

private.defaults = {
}
private.defaults.dcsdefaults = {
}

DejaClassicStats = {}

----------------------------
-- Saved Variables Loader --
----------------------------
local loader = CreateFrame("Frame")
	loader:RegisterEvent("ADDON_LOADED")
	loader:SetScript("OnEvent", function(self, event, arg1)
		if event == "ADDON_LOADED" and arg1 == "DejaClassicStats" then
			local function initDB(db, defaults)
				if type(db) ~= "table" then db = {} end
				if type(defaults) ~= "table" then return db end
				for k, v in pairs(defaults) do
					if type(v) == "table" then
						db[k] = initDB(db[k], v)
					elseif type(v) ~= type(db[k]) then
						db[k] = v
					end
				end
				return db
			end

			DejaClassicStatsDBPCPC = initDB(DejaClassicStatsDBPCPC, private.defaults) --saved variable per character, currently not used.
			private.db = DejaClassicStatsDBPCPC

			self:UnregisterEvent("ADDON_LOADED")
		end
	end)

-- Uncomment below the following three database saved variables setup lines for DejaView integration.
-- SavedVariables Setup
-- local DejaClassicStats, private = ...
-- private.defaults = {}
-- DejaClassicStats = {}

---------------------
-- DCS Slash Setup --
---------------------
local RegisteredEvents = {}
local dcsslash = CreateFrame("Frame", "DejaClassicStatsSlash", UIParent)

dcsslash:SetScript("OnEvent", function (self, event, ...)
	if (RegisteredEvents[event]) then
	return RegisteredEvents[event](self, event, ...)
	end
end)

function RegisteredEvents:ADDON_LOADED(event, addon, ...)
	if (addon == "DejaClassicStats") then
		SLASH_DejaClassicStats1 = "/dcstats"
		SLASH_DejaClassicStats2 = "/dcs"
		SlashCmdList["DejaClassicStats"] = function (msg, editbox)
			DejaClassicStats.SlashCmdHandler(msg, editbox)
	end
	--	DEFAULT_CHAT_FRAME:AddMessage("DejaClassicStats loaded successfully. For options: Esc>Interface>AddOns or type /dcs.",0,192,255)
	end
end

for k, v in pairs(RegisteredEvents) do
	dcsslash:RegisterEvent(k)
end

function DejaClassicStats.ShowHelp()
	print(addoninfo)
	print(L["DejaClassicStats Slash commands (/dcs):"])
	print(L["  /dcs config: Opens the DejaClassicStats addon config menu."])
	print(L["  /dcs reset:  Resets DejaClassicStats options to default."])
end

function DejaClassicStats.SlashCmdHandler(msg, editbox)
    msg = string.lower(msg)
	--if (string.lower(msg) == L["config"]) then --I think string.lowermight not work for Russian letters
	if (msg == "config") then
		Settings.OpenToCategory(DejaClassicStats.category:GetID());
	elseif (msg == "reset") then
		--DejaClassicStatsDBPCPC = private.defaults
		gdbprivate.gdb.gdbdefaults = gdbprivate.gdbdefaults.gdbdefaults
		ReloadUI()
	else
		DejaClassicStats.ShowHelp()
	end
end
	SlashCmdList["DejaClassicStats"] = DejaClassicStats.SlashCmdHandler

-----------------------
-- DCS Options Panel --
-----------------------
DejaClassicStats.panel = CreateFrame( "Frame", "DejaClassicStatsPanel", UIParent )
DejaClassicStats.panel.name = "DejaClassicStats"
DejaClassicStats.category = Settings.RegisterCanvasLayoutCategory(DejaClassicStats.panel, ADDON_NAME)
Settings.RegisterAddOnCategory( DejaClassicStats.category )

-- DCS, DejaView Child Panel
-- DejaViewPanel.DejaClassicStatsPanel = CreateFrame( "Frame", "DejaClassicStatsPanel", DejaViewPanel)
-- DejaViewPanel.DejaClassicStatsPanel.name = "DejaClassicStats"
-- Specify childness of this panel (this puts it under the little red [+], instead of giving it a normal AddOn category)
-- DejaViewPanel.DejaClassicStatsPanel.parent = DejaViewPanel.name
-- Add the child to the Interface Options
-- InterfaceOptions_AddCategory(DejaViewPanel.DejaClassicStatsPanel)

local dcstitle=CreateFrame("Frame", "DCSTitle", DejaClassicStatsPanel)
	dcstitle:SetPoint("TOPLEFT", 10, -10)
	--dcstitle:SetScale(2.0)
	dcstitle:SetWidth(300)
	dcstitle:SetHeight(100)
	dcstitle:Show()

local dcstitleFS = dcstitle:CreateFontString(nil, "OVERLAY")
	dcstitleFS:SetFontObject("GameFontNormal")
	dcstitleFS:SetText('|cff00c0ffDejaClassicStats|r')
	dcstitleFS:SetPoint("TOPLEFT", 0, 0)
	dcstitleFS:SetFont("Fonts\\FRIZQT__.TTF", 20)

local dcsversionFS = DejaClassicStatsPanel:CreateFontString(nil, "OVERLAY")
	dcsversionFS:SetFontObject("GameFontNormal")
	dcsversionFS:SetText('|cff00c0ff' .. addoninfo .. '|r')
	dcsversionFS:SetPoint("BOTTOMRIGHT", -10, 10)
	dcsversionFS:SetFont("Fonts\\FRIZQT__.TTF", 12)

local dcsresetcheck = CreateFrame("Button", "DCSResetButton", DejaClassicStatsPanel, "UIPanelButtonTemplate")
	dcsresetcheck:ClearAllPoints()
	dcsresetcheck:SetPoint("BOTTOMLEFT", 5, 5)
	dcsresetcheck:SetScale(1.25)

	dcsresetcheck:SetWidth(resetWidth)

	dcsresetcheck:SetHeight(30)
	_G[dcsresetcheck:GetName() .. "Text"]:SetText(L["Reset to Default"])
	dcsresetcheck:SetScript("OnClick", function(self, button, down)
 		gdbprivate.gdb.gdbdefaults = gdbprivate.gdbdefaults.gdbdefaults
		ReloadUI()
	end)

	----------------------
	-- Panel Categories --
	----------------------

	-- --Average Item Level
	-- local dcsILvlPanelCategoryFS = DejaClassicStatsPanel:CreateFontString("dcsILvlPanelCategoryFS", "OVERLAY")
	-- dcsILvlPanelCategoryFS:SetText('|cffffffff' .. L["Average Item Level:"] .. '|r') --wouldn't be more efficient through format?
	-- dcsILvlPanelCategoryFS:SetPoint("TOPLEFT", 25, -40)
	-- dcsILvlPanelCategoryFS:SetFontObject("GameFontNormalLarge") --Use instead of SetFont("Fonts\\FRIZQT__.TTF", 15) or Russian, Korean and Chinese characters won't work.

	-- --Character Stats
	-- local dcsStatsPanelcategoryFS = DejaClassicStatsPanel:CreateFontString("dcsStatsPanelcategoryFS", "OVERLAY")
	-- dcsStatsPanelcategoryFS:SetText('|cffffffff' .. L["Character Stats:"] .. '|r')
	-- dcsStatsPanelcategoryFS:SetPoint("TOPLEFT", 25, -150)
	-- dcsStatsPanelcategoryFS:SetFontObject("GameFontNormalLarge") --Use instead of SetFont("Fonts\\FRIZQT__.TTF", 15) or Russian, Korean and Chinese characters won't work.

	--Item Slots
	local dcsItemsPanelCategoryFS = DejaClassicStatsPanel:CreateFontString("dcsItemsPanelCategoryFS", "OVERLAY")
	dcsItemsPanelCategoryFS:SetFontObject("GameFontNormalLarge") --Use instead of SetFont("Fonts\\FRIZQT__.TTF", 15) or Russian, Korean and Chinese characters won't work.
	dcsItemsPanelCategoryFS:SetText('|cffffffff' .. L["Item Slots:"] .. '|r')
	dcsItemsPanelCategoryFS:SetPoint("TOPLEFT", 25, -40)

	--Runes
	local dcsRunesPanelCategoryFS = DejaClassicStatsPanel:CreateFontString("dcsRunesPanelCategoryFS", "OVERLAY")
	dcsRunesPanelCategoryFS:SetFontObject("GameFontNormalLarge") --Use instead of SetFont("Fonts\\FRIZQT__.TTF", 15) or Russian, Korean and Chinese characters won't work.
	dcsRunesPanelCategoryFS:SetText('|cffffffff' .. L["Runes:"] .. '|r')
	dcsRunesPanelCategoryFS:SetPoint("LEFT", 25, -50)

	--Miscellaneous
	local dcsMiscPanelCategoryFS = DejaClassicStatsPanel:CreateFontString("dcsMiscPanelCategoryFS", "OVERLAY")
	dcsMiscPanelCategoryFS:SetFontObject("GameFontNormalLarge") --Use instead of SetFont("Fonts\\FRIZQT__.TTF", 15) or Russian, Korean and Chinese characters won't work.
	dcsMiscPanelCategoryFS:SetText('|cffffffff' .. L["Miscellaneous:"] .. '|r')
	dcsMiscPanelCategoryFS:SetPoint("LEFT", 25, -125)

	--Show/Hide Headers
	local dcsItemsPanelHeadersFS = DejaClassicStatsPanel:CreateFontString("dcsItemsPanelHeadersFS", "OVERLAY")
	dcsItemsPanelHeadersFS:SetFontObject("GameFontNormalLarge") --Use instead of SetFont("Fonts\\FRIZQT__.TTF", 15) or Russian, Korean and Chinese characters won't work.
	dcsItemsPanelHeadersFS:SetText('|cffffffff' .. L["Categories:"] .. '|r')
	dcsItemsPanelHeadersFS:SetPoint("TOPLEFT", DejaClassicStatsPanel, "TOP", -25, -40)

----------------
-- Loval Vars --
----------------
local ShowDefaultStats
local DefaultResistances
local ShowModelRotation
local ShowPrimary
local ShowMelee
local ShowRanged
local ShowSpell
local ShowDefense

-------------------
-- Frame Offsets --
-------------------
local DCS_FrameWidth, DCS_FrameHeight = 192, 424
local DCS_HeaderWidth, DCS_HeaderHeight = 192, 28
local DCS_RframeInset = 25
local DCS_HeaderInsetX = 0
local DCS_StatScale = 1.25

local function DCSHeaderYOffsets()
	local primaryYoffset = -7
	local meleeYoffset = -167
	local rangedYoffset = -297
	local spellYoffset = -403
	local defenseYoffset = -587
	ShowPrimary = gdbprivate.gdb.gdbdefaults.DejaClassicStatsShowPrimaryChecked.ShowPrimarySetChecked
	ShowMelee = gdbprivate.gdb.gdbdefaults.DejaClassicStatsShowMeleeChecked.ShowMeleeSetChecked
	ShowRanged = gdbprivate.gdb.gdbdefaults.DejaClassicStatsShowRangedChecked.ShowRangedSetChecked
	ShowSpell = gdbprivate.gdb.gdbdefaults.DejaClassicStatsShowSpellChecked.ShowSpellSetChecked
	ShowDefense = gdbprivate.gdb.gdbdefaults.DejaClassicStatsShowDefenseChecked.ShowDefenseSetChecked

	if ShowPrimary then
		primaryYoffset = primaryYoffset
		DCSPrimaryStatsHeader:Show()
	else
		defenseYoffset = defenseYoffset - meleeYoffset + primaryYoffset
		spellYoffset = spellYoffset - meleeYoffset + primaryYoffset
		rangedYoffset = rangedYoffset - meleeYoffset + primaryYoffset
		meleeYoffset = meleeYoffset - meleeYoffset + primaryYoffset
		DCSPrimaryStatsHeader:Hide()
	end
	if ShowMelee then
		meleeYoffset = meleeYoffset
		DCSMeleeEnhancementsStatsHeader:Show()
	else
		defenseYoffset = defenseYoffset - rangedYoffset + meleeYoffset
		spellYoffset = spellYoffset - rangedYoffset + meleeYoffset
		rangedYoffset = rangedYoffset - rangedYoffset + meleeYoffset
		meleeYoffset = meleeYoffset - rangedYoffset + meleeYoffset
		DCSMeleeEnhancementsStatsHeader:Hide()
	end
	if ShowRanged then
		rangedYoffset = rangedYoffset
		DCSRangedStatsHeader:Show()
	else
		defenseYoffset = defenseYoffset - spellYoffset + rangedYoffset
		spellYoffset = spellYoffset - spellYoffset + rangedYoffset
		rangedYoffset = rangedYoffset - spellYoffset + rangedYoffset
		meleeYoffset = meleeYoffset - spellYoffset + rangedYoffset
		DCSRangedStatsHeader:Hide()
	end
	if ShowSpell then
		spellYoffset = spellYoffset
		DCSSpellEnhancementsStatsHeader:Show()
	else
		defenseYoffset = defenseYoffset - defenseYoffset + spellYoffset
		spellYoffset = spellYoffset - defenseYoffset + spellYoffset
		rangedYoffset = rangedYoffset - defenseYoffset + spellYoffset
		meleeYoffset = meleeYoffset - defenseYoffset + spellYoffset
		DCSSpellEnhancementsStatsHeader:Hide()
	end
	if ShowDefense then
		defenseYoffset = defenseYoffset
		DCSDefenseStatsHeader:Show()
	else
		DCSDefenseStatsHeader:Hide()
	end

	-- primaryYoffset = primaryYoffset
	-- meleeYoffset = meleeYoffset + primaryYoffset
	-- rangedYoffset = rangedYoffset + meleeYoffset + primaryYoffset
	-- spellYoffset = spellYoffset + rangedYoffset + meleeYoffset + primaryYoffset
	-- defenseYoffset = defenseYoffset + spellYoffset + rangedYoffset + meleeYoffset + primaryYoffset

	DCSPrimaryStatsHeader:ClearAllPoints()
	DCSPrimaryStatsHeader:SetPoint("TOPLEFT", "DejaClassicStatsFrame", "TOPLEFT", DCS_HeaderInsetX, primaryYoffset)
	DCSMeleeEnhancementsStatsHeader:ClearAllPoints()
	DCSMeleeEnhancementsStatsHeader:SetPoint("TOPLEFT", "DejaClassicStatsFrame", "TOPLEFT", DCS_HeaderInsetX, meleeYoffset)
	DCSRangedStatsHeader:ClearAllPoints()
	DCSRangedStatsHeader:SetPoint("TOPLEFT", "DejaClassicStatsFrame", "TOPLEFT", DCS_HeaderInsetX, rangedYoffset)
	DCSSpellEnhancementsStatsHeader:ClearAllPoints()
	DCSSpellEnhancementsStatsHeader:SetPoint("TOPLEFT", "DejaClassicStatsFrame", "TOPLEFT", DCS_HeaderInsetX, spellYoffset)
	DCSDefenseStatsHeader:ClearAllPoints()
	DCSDefenseStatsHeader:SetPoint("TOPLEFT", "DejaClassicStatsFrame", "TOPLEFT", DCS_HeaderInsetX, defenseYoffset)
end

------------------
-- Scroll Frame --
------------------
local scrollbarchecked

gdbprivate.gdbdefaults.gdbdefaults.dejacharacterstatsScrollbarChecked = {
	ScrollbarSetChecked = false,
}

local DCS_StatScrollFrame = CreateFrame("ScrollFrame", "DCS_StatScrollFrame", CharacterFrame, "UIPanelScrollFrameTemplate")
	DCS_StatScrollFrame:ClearAllPoints()
	DCS_StatScrollFrame:SetSize( DCS_HeaderWidth, 400 )
	DCS_StatScrollFrame:SetPoint("TOPLEFT", "CharacterFrame", "TOPRIGHT", -34, -26) -- This is (-40, -14) for Classic, different for dry development
	DCS_StatScrollFrame:SetFrameStrata("BACKGROUND")
	DCS_StatScrollFrame.ScrollBar:ClearAllPoints()
	DCS_StatScrollFrame.ScrollBar:SetPoint("TOPLEFT", DCS_StatScrollFrame, "TOPRIGHT", 0, -16)
	DCS_StatScrollFrame.ScrollBar:SetPoint("BOTTOMLEFT", DCS_StatScrollFrame, "BOTTOMRIGHT", 0, 16)
	-- DCS_StatScrollFrame.ScrollBar:Hide() -- This will not hide the ScrollBar if the "OnScrollRangeChanged" script has a SetShown and is not hidden.

	local t=DCS_StatScrollFrame:CreateTexture(nil,"ARTWORK")
	t:SetAllPoints(DCS_StatScrollFrame)
	t:SetColorTexture(0, 0, 0, 1)

	local DCS_TopTexture=DCS_StatScrollFrame:CreateTexture(nil,"ARTWORK")
	local DCS_TopRightTexture=DCS_StatScrollFrame:CreateTexture(nil,"ARTWORK")
	local DCS_LeftTexture=DCS_StatScrollFrame:CreateTexture(nil,"ARTWORK")
	local DCS_RightTexture=DCS_StatScrollFrame:CreateTexture(nil,"ARTWORK")
	local DCS_BottomRightTexture=DCS_StatScrollFrame:CreateTexture(nil,"ARTWORK")
	local DCS_BottomTexture=DCS_StatScrollFrame:CreateTexture(nil,"ARTWORK")

local scrollFrameTextureXinsets

local function DCS_SetScrollTextures()
	if scrollbarchecked then
		scrollFrameTextureXinsets = 60
		-- DCS_StatScrollFrame.ScrollBar:SetShown(floor(yrange) ~= 0)
		DCS_StatScrollFrame.ScrollBar:Show()
	else
		scrollFrameTextureXinsets = 44
		DCS_StatScrollFrame.ScrollBar:Hide()
	end

	DCS_TopTexture:SetPoint("TOPLEFT", DCS_StatScrollFrame, "TOPLEFT", -4, 86)
	DCS_TopTexture:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-BottomRight")
	DCS_TopTexture:SetTexCoord(0.69, 0, 1, 0)

	DCS_TopRightTexture:SetPoint("TOPRIGHT", DCS_StatScrollFrame, "TOPRIGHT", scrollFrameTextureXinsets, 86)
	DCS_TopRightTexture:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-BottomRight")
	DCS_TopRightTexture:SetTexCoord(0, 1, 1, 0)

	DCS_LeftTexture:SetPoint("LEFT", DCS_StatScrollFrame, "LEFT", 0, -20)
	DCS_LeftTexture:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-BottomRight")
	DCS_LeftTexture:SetTexCoord(0, 0.6, 0.6, 0)

	DCS_RightTexture:SetPoint("RIGHT", DCS_StatScrollFrame, "RIGHT", scrollFrameTextureXinsets, 0)
	DCS_RightTexture:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-BottomRight")
	DCS_RightTexture:SetTexCoord(0, 1, 0.6, 0)

	DCS_BottomRightTexture:SetPoint("BOTTOMRIGHT", DCS_StatScrollFrame, "BOTTOMRIGHT", scrollFrameTextureXinsets, -86)
	DCS_BottomRightTexture:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-BottomRight")

	DCS_BottomTexture:SetPoint("BOTTOMLEFT", DCS_StatScrollFrame, "BOTTOMLEFT", -4, -86)
	DCS_BottomTexture:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-BottomRight")
	DCS_BottomTexture:SetTexCoord(0.69, 0, 0, 1)
end

	local t=DCS_StatScrollFrame.ScrollBar:CreateTexture(nil,"ARTWORK")
		t:SetAllPoints(DCS_StatScrollFrame.ScrollBar)
		t:SetColorTexture(0, 0, 0, 1)

	DCS_StatScrollFrame:HookScript("OnScrollRangeChanged", function(self, xrange, yrange)
		self.ScrollBar:SetShown(floor(yrange) ~= 0)
		-- self.ScrollBar:Hide() -- This is what will hide the ScrollBar
		if scrollbarchecked then
			self.ScrollBar:SetShown(floor(yrange) ~= 0)
			self.ScrollBar:Show()
		else
			self.ScrollBar:Hide()
		end
	end)

local DejaClassicStatsFrame = CreateFrame("Frame", "DejaClassicStatsFrame", CharacterFrame)
	DejaClassicStatsFrame:RegisterEvent("PLAYER_LOGIN")
	DejaClassicStatsFrame:SetFrameStrata("BACKGROUND")

	DejaClassicStatsFrame:SetScript("OnEvent", function(self, event, ...)
		DejaClassicStatsFrame:SetSize( DCS_FrameWidth, 650 )
		DejaClassicStatsFrame:ClearAllPoints()
		DejaClassicStatsFrame:SetAllPoints("DCS_StatScrollFrame") -- This is (-40, -14) for Classic, different for dry development
		-- DejaClassicStatsFrame:SetFrameStrata("BACKGROUND")
		DejaClassicStatsFrame:Show()

		DCS_StatScrollFrame:SetScrollChild(DejaClassicStatsFrame)
	end)

----------------------------
-- Scrollbar Check Button --
----------------------------
local HideScrollBar

local DCS_ScrollbarCheck = CreateFrame("CheckButton", "DCS_ScrollbarCheck", DejaClassicStatsPanel, "InterfaceOptionsCheckButtonTemplate")
	DCS_ScrollbarCheck:RegisterEvent("PLAYER_LOGIN")
	DCS_ScrollbarCheck:ClearAllPoints()
	--DCS_ScrollbarCheck:SetPoint("LEFT", 30, -225)
	DCS_ScrollbarCheck:SetPoint("TOPLEFT", "dcsMiscPanelCategoryFS", 7, -95)
	DCS_ScrollbarCheck:SetScale(1)
	DCS_ScrollbarCheck.tooltipText = L["Displays the DCS scrollbar."] --Creates a tooltip on mouseover.
	_G[DCS_ScrollbarCheck:GetName() .. "Text"]:SetText(L["Scrollbar"])

	DCS_ScrollbarCheck:SetScript("OnEvent", function(self, event)
		scrollbarchecked = gdbprivate.gdb.gdbdefaults.dejacharacterstatsScrollbarChecked.ScrollbarSetChecked
		self:SetChecked(scrollbarchecked)
		DCS_SetScrollTextures()
	end)

	DCS_ScrollbarCheck:SetScript("OnClick", function(self)
		scrollbarchecked = not scrollbarchecked
		gdbprivate.gdb.gdbdefaults.dejacharacterstatsScrollbarChecked.ScrollbarSetChecked = scrollbarchecked
		DCS_SetScrollTextures()
	end)

------------------
-- Class Colors --
------------------
local className, classFilename, classID = UnitClass("player") --Players Class Color (In case I want to use it)
local rPerc, gPerc, bPerc, argbHex = GetClassColor(classFilename)

--------------------
-- Primary Header --
--------------------
local DCSPrimaryStatsHeader = CreateFrame("Frame", "DCSPrimaryStatsHeader", DejaClassicStatsFrame)
	DCSPrimaryStatsHeader:SetSize( DCS_HeaderWidth, DCS_HeaderHeight )
	DCSPrimaryStatsHeader:SetPoint("TOPLEFT", "DejaClassicStatsFrame", "TOPLEFT", DCS_HeaderInsetX, primaryYoffset)
	-- DCSPrimaryStatsHeader:SetFrameStrata("BACKGROUND")
	-- DCSPrimaryStatsHeader:Hide()

local DCSPrimaryStatsFS = DCSPrimaryStatsHeader:CreateFontString(nil, "OVERLAY")
	DCSPrimaryStatsFS:SetFontObject("GameFontNormal")
	DCSPrimaryStatsFS:SetText(L["Primary"])
	DCSPrimaryStatsFS:SetTextColor(1, 1, 1)
	DCSPrimaryStatsFS:SetPoint("CENTER", 0, 0)
	-- DCSPrimaryStatsFS:SetFont("Fonts\\FRIZQT__.TTF", 12, "THINOUTLINE")
	DCSPrimaryStatsFS:SetJustifyH("CENTER")

local t=DCSPrimaryStatsHeader:CreateTexture(nil,"ARTWORK")
		t:SetAllPoints(DCSPrimaryStatsHeader)
		-- t:SetColorTexture(1, 1, 1, 0)
		t:SetTexture("Interface\\PaperDollInfoFrame\\PaperDollInfoPart1")
		t:SetTexCoord(0, 0.193359375, 0.69921875, 0.736328125)

-----------
--Offense--
-----------
-- local DCSOffenseStatsHeader = CreateFrame("Frame", "DCSOffenseStatsHeader", DejaClassicStatsFrame)
-- 	DCSOffenseStatsHeader:SetSize( DCS_HeaderWidth, DCS_HeaderHeight )
-- 	DCSOffenseStatsHeader:SetPoint("TOPLEFT", "DejaClassicStatsFrame", "TOPLEFT", DCS_HeaderInsetX, rangedYoffset)
-- 	-- DCSOffenseStatsHeader:SetFrameStrata("BACKGROUND")
-- 	-- DCSOffenseStatsHeader:Hide()

-- local DCSOffenseStatsFS = DCSOffenseStatsHeader:CreateFontString(nil, "OVERLAY")
-- 	DCSOffenseStatsFS:SetFontObject("GameFontNormal")
-- 	DCSOffenseStatsFS:SetText(L["Offense"])
-- 	DCSOffenseStatsFS:SetTextColor(1, 1, 1)
-- 	DCSOffenseStatsFS:SetPoint("CENTER", 0, 0) --This is -2 to center the header "Offense" better.
-- 	-- DCSOffenseStatsFS:SetFont("Fonts\\FRIZQT__.TTF", 12, "THINOUTLINE")
-- 	DCSOffenseStatsFS:SetJustifyH("CENTER")

-- local t=DCSOffenseStatsHeader:CreateTexture(nil,"ARTWORK")
-- 	t:SetAllPoints(DCSOffenseStatsHeader)
-- 	t:SetColorTexture(1, 1, 1, 0)
-- 	t:SetTexture("Interface\\PaperDollInfoFrame\\PaperDollInfoPart1")
-- 	t:SetTexCoord(0, 0.193359375, 0.69921875, 0.736328125)

-------------------------------
-- Melee Enhancements Header --
-------------------------------
local DCSMeleeEnhancementsStatsHeader = CreateFrame("Frame", "DCSMeleeEnhancementsStatsHeader", DejaClassicStatsFrame)
	DCSMeleeEnhancementsStatsHeader:SetSize( DCS_HeaderWidth, DCS_HeaderHeight )
	DCSMeleeEnhancementsStatsHeader:SetPoint("TOPLEFT", "DejaClassicStatsFrame", "TOPLEFT", DCS_HeaderInsetX, meleeYoffset)
	-- DCSMeleeEnhancementsStatsHeader:SetFrameStrata("BACKGROUND")
	-- DCSMeleeEnhancementsStatsHeader:Hide()

local DCSMeleeEnhancementsStatsFS = DCSMeleeEnhancementsStatsHeader:CreateFontString(nil, "OVERLAY")
	DCSMeleeEnhancementsStatsFS:SetFontObject("GameFontNormal")
	DCSMeleeEnhancementsStatsFS:SetText(L["Melee Enhancements"])
	DCSMeleeEnhancementsStatsFS:SetTextColor(1, 1, 1)
	DCSMeleeEnhancementsStatsFS:SetPoint("CENTER", 0, 0)
	-- DCSMeleeEnhancementsStatsFS:SetFont("Fonts\\FRIZQT__.TTF", 12, "THINOUTLINE")
	DCSMeleeEnhancementsStatsFS:SetJustifyH("CENTER")

local t=DCSMeleeEnhancementsStatsHeader:CreateTexture(nil,"ARTWORK")
		t:SetAllPoints(DCSMeleeEnhancementsStatsHeader)
		-- t:SetColorTexture(1, 1, 1, 0)
		t:SetTexture("Interface\\PaperDollInfoFrame\\PaperDollInfoPart1")
		t:SetTexCoord(0, 0.193359375, 0.69921875, 0.736328125)

-------------------------------
-- Ranged Header --
-------------------------------
local DCSRangedStatsHeader = CreateFrame("Frame", "DCSRangedStatsHeader", DejaClassicStatsFrame)
	DCSRangedStatsHeader:SetSize( DCS_HeaderWidth, DCS_HeaderHeight )
	DCSRangedStatsHeader:SetPoint("TOPLEFT", "DejaClassicStatsFrame", "TOPLEFT", DCS_HeaderInsetX, rangedYoffset)
	-- DCSRangedStatsHeader:SetFrameStrata("BACKGROUND")
	-- DCSRangedStatsHeader:Hide()

local DCSRangedStatsFS = DCSRangedStatsHeader:CreateFontString(nil, "OVERLAY", "GameTooltipText")
	DCSRangedStatsFS:SetText(L["Ranged"])
	DCSRangedStatsFS:SetTextColor(1, 1, 1)
	DCSRangedStatsFS:SetPoint("CENTER", 0, 0)
	-- DCSRangedStatsFS:SetFont("Fonts\\FRIZQT__.TTF", 12, "THINOUTLINE")
	DCSRangedStatsFS:SetJustifyH("CENTER")

local t=DCSRangedStatsHeader:CreateTexture(nil,"ARTWORK")
		t:SetAllPoints(DCSRangedStatsHeader)
		-- t:SetColorTexture(1, 1, 1, 0)
		t:SetTexture("Interface\\PaperDollInfoFrame\\PaperDollInfoPart1")
		t:SetTexCoord(0, 0.193359375, 0.69921875, 0.736328125)

-------------------------------
-- Spell Enhancements Header --
-------------------------------
local DCSSpellEnhancementsStatsHeader = CreateFrame("Frame", "DCSSpellEnhancementsStatsHeader", DejaClassicStatsFrame)
	DCSSpellEnhancementsStatsHeader:SetSize( DCS_HeaderWidth, DCS_HeaderHeight )
	DCSSpellEnhancementsStatsHeader:SetPoint("TOPLEFT", "DCSMeleeEnhancementsStatsHeader", "TOPLEFT", DCS_HeaderInsetX, spellYoffset)
	-- DCSSpellEnhancementsStatsHeader:SetFrameStrata("BACKGROUND")
	-- DCSSpellEnhancementsStatsHeader:Hide()

local DCSSpellEnhancementsStatsFS = DCSSpellEnhancementsStatsHeader:CreateFontString(nil, "OVERLAY")
	DCSSpellEnhancementsStatsFS:SetFontObject("GameFontNormal")
	DCSSpellEnhancementsStatsFS:SetText(L["Spell Enhancements"])
	DCSSpellEnhancementsStatsFS:SetTextColor(1, 1, 1)
	DCSSpellEnhancementsStatsFS:SetPoint("CENTER", 0, 0)
	-- DCSSpellEnhancementsStatsFS:SetFont("Fonts\\FRIZQT__.TTF", 12, "THINOUTLINE")
	DCSSpellEnhancementsStatsFS:SetJustifyH("CENTER")

local t=DCSSpellEnhancementsStatsHeader:CreateTexture(nil,"ARTWORK")
		t:SetAllPoints(DCSSpellEnhancementsStatsHeader)
		-- t:SetColorTexture(1, 1, 1, 0)
		t:SetTexture("Interface\\PaperDollInfoFrame\\PaperDollInfoPart1")
		t:SetTexCoord(0, 0.193359375, 0.69921875, 0.736328125)

-----------
--Defense--
-----------
local DCSDefenseStatsHeader = CreateFrame("Frame", "DCSDefenseStatsHeader", DejaClassicStatsFrame)
	DCSDefenseStatsHeader:SetSize( DCS_HeaderWidth, DCS_HeaderHeight )
	DCSDefenseStatsHeader:SetPoint("TOPLEFT", "DCSSpellEnhancementsStatsHeader", "TOPLEFT", DCS_HeaderInsetX, defenseYoffset)
	-- DCSDefenseStatsHeader:SetFrameStrata("BACKGROUND")
	-- DCSDefenseStatsHeader:Hide()

local DCSDefenseStatsFS = DCSDefenseStatsHeader:CreateFontString(nil, "OVERLAY")
	DCSDefenseStatsFS:SetFontObject("GameFontNormal")
	DCSDefenseStatsFS:SetText(L["Defense"])
	DCSDefenseStatsFS:SetTextColor(1, 1, 1)
	DCSDefenseStatsFS:SetPoint("CENTER", 0, 0) --This is -2 to center the header "Offense" better.
	-- DCSDefenseStatsFS:SetFont("Fonts\\FRIZQT__.TTF", 12, "THINOUTLINE")
	DCSDefenseStatsFS:SetJustifyH("CENTER")

local t=DCSDefenseStatsHeader:CreateTexture(nil,"ARTWORK")
	t:SetAllPoints(DCSDefenseStatsHeader)
	t:SetColorTexture(1, 1, 1, 0)
	t:SetTexture("Interface\\PaperDollInfoFrame\\PaperDollInfoPart1")
	t:SetTexCoord(0, 0.193359375, 0.69921875, 0.736328125)

---------------------
-- Primary/General --
---------------------
local function DCS_SetBlizzPrimaryStats(statindex)
	local text = _G["CharacterStatFrame"..statindex.."StatText"];
	local frame = _G["CharacterStatFrame"..statindex];
	local stat, effectiveStat, posBuff, negBuff = UnitStat("player", statindex);
	-- Set the tooltip text
	local tooltipText = HIGHLIGHT_FONT_COLOR_CODE.._G["SPELL_STAT"..statindex.."_NAME"].." ";
	-- Get class specific tooltip for that stat
	local temp, classFileName = UnitClass("player");
	local classStatText = _G[strupper(classFileName).."_"..frame.stat.."_".."TOOLTIP"];
	-- If can't find one use the default
	if ( not classStatText ) then
		classStatText = _G["DEFAULT".."_"..frame.stat.."_".."TOOLTIP"];
	end

	if ( ( posBuff == 0 ) and ( negBuff == 0 ) ) then
		text:SetText(effectiveStat);
		frame.tooltip = tooltipText..effectiveStat..FONT_COLOR_CODE_CLOSE;
		frame.tooltip2 = classStatText;
	else
		tooltipText = tooltipText..effectiveStat;
		if ( posBuff > 0 or negBuff < 0 ) then
			tooltipText = tooltipText.." ("..(stat - posBuff - negBuff)..FONT_COLOR_CODE_CLOSE;
		end
		if ( posBuff > 0 ) then
			tooltipText = tooltipText..FONT_COLOR_CODE_CLOSE..GREEN_FONT_COLOR_CODE.."+"..posBuff..FONT_COLOR_CODE_CLOSE;
		end
		if ( negBuff < 0 ) then
			tooltipText = tooltipText..RED_FONT_COLOR_CODE.." "..negBuff..FONT_COLOR_CODE_CLOSE;
		end
		if ( posBuff > 0 or negBuff < 0 ) then
			tooltipText = tooltipText..HIGHLIGHT_FONT_COLOR_CODE..")"..FONT_COLOR_CODE_CLOSE;
		end
		frame.tooltip = tooltipText;
		frame.tooltip2= classStatText;

		-- If there are any negative buffs then show the main number in red even if there are
		-- positive buffs. Otherwise show in green.
		if ( negBuff < 0 ) then
			text:SetText(RED_FONT_COLOR_CODE..effectiveStat..FONT_COLOR_CODE_CLOSE);
		else
			text:SetText(GREEN_FONT_COLOR_CODE..effectiveStat..FONT_COLOR_CODE_CLOSE);
		end
	end
	return tooltipText, effectiveStat, classStatText, "", "", ""
end
-- Strength
local function DCS_Strength()
	local statindex = 1
	return DCS_SetBlizzPrimaryStats(statindex)
end
-- Agility
local function DCS_Agility()
	local statindex = 2
	return DCS_SetBlizzPrimaryStats(statindex)
end
-- Stamina
local function DCS_Stamina()
	local statindex = 3
	return DCS_SetBlizzPrimaryStats(statindex)
end
-- Intellect
local function DCS_Intellect()
	local statindex = 4
	return DCS_SetBlizzPrimaryStats(statindex)
end
-- Spirit
local function DCS_Spirit()
	local statindex = 5
	return DCS_SetBlizzPrimaryStats(statindex)
end
-- Armor
local function DCS_Armor()
	local _ , effectiveArmor = UnitArmor("player");
	local playerLevel = UnitLevel("player");
	local armorReduction = effectiveArmor/((85 * playerLevel) + 400);
	armorReduction = 100 * (armorReduction/(armorReduction + 1));
return "", format(" %.0f", effectiveArmor), format(ARMOR_TOOLTIP, playerLevel, armorReduction), "", "", ""
end
-- Player Movement Speed
local function MovementSpeed()
	local currentSpeed, runSpeed, flightSpeed, swimSpeed = GetUnitSpeed("player")
	local playerSpeed
	if IsSwimming() then
		playerSpeed = (swimSpeed)
	else
		playerSpeed = runSpeed
	end
	local TooltipLine1 = L["Your current movement speed including items, buffs, enchants, forms, and mounts."]
    return "", format("%.0f%%", ((playerSpeed/7)*100)), TooltipLine1, "", "", ""
end
local function DCS_Durability()
	local displayDura
	if (addon.duraMean == 100) then
		displayDura = format("%.0f%%", addon.duraMean);
	else
		displayDura = format("%.2f%%", addon.duraMean);
	end
	local TooltipLine1 = L["The average durability of all equipped items."]
	return "", displayDura, TooltipLine1, "", "", ""
end
local function DCS_RepairTotal()
	if (not DejaClassicStatsFrame.scanTooltip) then
		DejaClassicStatsFrame.scanTooltip = CreateFrame("GameTooltip", "StatRepairCostTooltip", DejaClassicStatsFrame, "GameTooltipTemplate")
		DejaClassicStatsFrame.scanTooltip:SetOwner(DejaClassicStatsFrame, "ANCHOR_NONE")
	end
	local totalCost = 0
	local _, repairCost
	for _, index in ipairs({1,3,5,6,7,8,9,10,16,17}) do
		_, _, repairCost = DejaClassicStatsFrame.scanTooltip:SetInventoryItem("player", index)
		if (repairCost and repairCost > 0) then
			totalCost = totalCost + repairCost
		end
	end
	-- totalCost = 7890 -- Debugging
	local totalRepairCost = GetCoinTextureString(totalCost)
	local TooltipLine1 = L["The total repair cost of all equipped items."]
	return "", totalRepairCost, TooltipLine1, "", "", ""
end
---------------------------
-- Melee/Ranged/Physical --
---------------------------
-- Main Hand Attack(Weapon Skill)
local function MHWeaponSkill()
	local mainBase, mainMod, offBase, offMod = UnitAttackBothHands("player");
	local effective = mainBase + mainMod;
	-- local TooltipLine1 = L["Your attack rating affects your chance to hit a target, and is based on the weapon skill of the weapon you are currently wielding in your main hand."]
	return "", format("%.0f", effective), ATTACK_TOOLTIP_SUBTEXT, "", "", ""
end
-- Main Hand Attack Power
local function MeleeAP()
	local base, posBuff, negBuff = UnitAttackPower("player");
	local effective = base + posBuff + negBuff;
	return L["Power: "]..format("%.0f", effective), format("%.0f", effective), format(MELEE_ATTACK_POWER_TOOLTIP, max((base+posBuff+negBuff), 0)/ATTACK_POWER_MAGIC_NUMBER), "", "", ""
end
-- Main Hand Damage
local function MHDamage()
	local speed, offhandSpeed = UnitAttackSpeed("player");
	local minDamage, maxDamage, minOffHandDamage, maxOffHandDamage, physicalBonusPos, physicalBonusNeg, percent = UnitDamage("player");
	local damageSpread = max(floor(minDamage),1).." - "..max(ceil(maxDamage),1);

	local baseDamage = (minDamage + maxDamage) * 0.5;
	local fullDamage = (baseDamage + physicalBonusPos + physicalBonusNeg) * percent;
	local totalBonus = (fullDamage - baseDamage);
	local damagePerSecond = (max(fullDamage,1) / speed);

	local TooltipLine1 = L["Attack Speed (seconds): "]..format("%.2f", speed)
	local TooltipLine2 = L["Damage per Second: "]..format("%.2f", damagePerSecond)

	return L["Main Hand Damage: "]..damageSpread, damageSpread, TooltipLine1, TooltipLine2, "", ""
end
-- Off Hand Attack(Weapon Skill)
local function OHWeaponSkill()
	local _, offhandSpeed = UnitAttackSpeed("player");
	if ( offhandSpeed) then
		local mainBase, mainMod, offBase, offMod = UnitAttackBothHands("player");
		local effective = offBase + offMod;
		-- local TooltipLine1 = L["Your attack rating affects your chance to hit a target, and is based on the weapon skill of the weapon you are currently wielding in your off hand."]
		return "", format("%.0f", effective), ATTACK_TOOLTIP_SUBTEXT, "", "", ""
	else
		return L["Off Hand: "].."N/A", "N/A", "", "", "", ""
	end
end
-- Off Hand Damage
local function OHDamage()
	local _, offhandSpeed = UnitAttackSpeed("player");
	if ( offhandSpeed) then
		local minDamage, maxDamage, minOffHandDamage, maxOffHandDamage, physicalBonusPos, physicalBonusNeg, percent = UnitDamage("player");
		local damageSpread = max(floor(minOffHandDamage),1).." - "..max(ceil(maxOffHandDamage),1);
		local offhandBaseDamage = (minOffHandDamage + maxOffHandDamage) * 0.5;
		local offhandFullDamage = (offhandBaseDamage + physicalBonusPos + physicalBonusNeg) * percent;
		local totalBonus = (offhandFullDamage - offhandBaseDamage);
		local offhandDamagePerSecond = (max(offhandFullDamage,1) / offhandSpeed);
		local TooltipLine1 = L["Attack Speed (seconds): "]..format("%.2f", offhandSpeed)
		local TooltipLine2 = L["Damage per Second: "]..format("%.2f", offhandDamagePerSecond)
		return L["Off Hand Damage: "]..damageSpread, damageSpread, TooltipLine1, TooltipLine2, "", ""
	else
		return L["Off Hand Damage: "].."N/A", "N/A", "", "", "", ""
	end
end
-- Melee Critical Strike Chance
local function MeleeCrit()
	local TooltipLine1 = L["Gives a chance to critically strike with melee attacks, increasing the damage dealt by 100%."]
	return "", format("%.2f%%", GetCritChance()), TooltipLine1, "", "", ""
end
-- Ranged Attack(Weapon Skill)
local function RangedWeaponSkill()
	local rangedAttackBase, rangedAttackMod = UnitRangedAttack("player");
	local effective = rangedAttackBase + rangedAttackMod;
	-- local TooltipLine1 = L["Your attack rating affects your chance to hit a target, and is based on the weapon skill of the weapon you are currently wielding in your main hand."]
	return "", format("%.0f", effective), ATTACK_TOOLTIP_SUBTEXT, "", "", ""
end
-- Ranged Attack Power
local function RangedAP()
	local base, posBuff, negBuff = UnitRangedAttackPower("player");
	local effective = base + posBuff + negBuff;
	return L["Power: "]..format("%.0f", effective), format("%.0f", effective), format(RANGED_ATTACK_POWER_TOOLTIP, base/ATTACK_POWER_MAGIC_NUMBER), "", "", ""
end
-- Ranged Damage
local function RangedDamage()
	local rangedAttackSpeed, minDamage, maxDamage, physicalBonusPos, physicalBonusNeg, percent = UnitRangedDamage("player");
		local TooltipLine1 = "N/A"
		local TooltipLine2 = "N/A"
		local damageSpread = "N/A"
	if (rangedAttackSpeed == 0) or (not rangedAttackSpeed) then
		return L["Ranged Damage: "]..damageSpread, damageSpread, TooltipLine1, TooltipLine2, "", ""
	else
		damageSpread = max(floor(minDamage),1).." - "..max(ceil(maxDamage),1);
		local baseDamage = (minDamage + maxDamage) * 0.5;
		local fullDamage = (baseDamage + physicalBonusPos + physicalBonusNeg) * percent;
		local totalBonus = (fullDamage - baseDamage);
		local damagePerSecond = (max(fullDamage,1) / rangedAttackSpeed);
		TooltipLine1 = L["Attack Speed (seconds): "]..format("%.2f", rangedAttackSpeed)
		TooltipLine2 = L["Damage per Second: "]..format("%.2f", damagePerSecond)
		return L["Ranged Damage: "]..damageSpread, damageSpread, TooltipLine1, TooltipLine2, "", ""
	end
end
-- Ranged Critical Strike Chance
local function RangedCrit()
	return "", format("%.2f%%", GetRangedCritChance()), "", "", "", ""
end
-- Bonus Melee Hit Chance Modifier
local function HitModifier()
	local hit = GetHitModifier()
	if hit == nil then hit = 0 end
	return "", format("%.2f%%", hit), "", "", "", ""
end
-- Bonus Ranged Hit Chance Modifier
local function RangedHitModifier()
	hasBiznicks = addon.hasBiznicks
	local hit = GetHitModifier()
	if hit == nil then hit = 0 end
	if hasBiznicks then
		hit = hit + 3
	end
	return "", format("%.2f%%", hit), "", "", "", ""
end
-------------
-- Defense --
-------------
-- Dodge Chance
local function Dodge()
	local TooltipLine1 = L["Gives a chance to dodge enemy melee attacks."]
	return "", format("%.2f%%", GetDodgeChance()), TooltipLine1, "", "", ""
end
-- Parry Chance
local function Parry()
	local TooltipLine1 = L["Gives a chance to parry enemy melee attacks."]
	return "", format("%.2f%%", GetParryChance()), TooltipLine1, "", "", ""
end
-- Block Chance
local function BlockChance()
	local TooltipLine1 = L["Gives a chance to block enemy melee and ranged attacks."]
	return "", format("%.2f%%", GetBlockChance()), TooltipLine1, "", "", ""
end
-- Block Value
local function BlockValue()
	local BlockValue = GetShieldBlock()
	local TooltipLine1 = L["Your blocks mitigate "]..BlockValue..L[" melee and ranged damage."]
	return "", format("%.0f", BlockValue), TooltipLine1, "", "", ""
end
-- Defense
local function Defense()
	local baseDefense, bonusDefense, posBuff, negBuff = 0,0,0,0
	local numSkills = GetNumSkillLines()
	local skillIndex = 0
	for i = 1, numSkills do
		local skillName = select(1, GetSkillLineInfo(i))
		if (skillName == DEFENSE) then
			skillIndex = i
			break
		end
	end
	if (skillIndex > 0) then
		baseDefense = select(4, GetSkillLineInfo(skillIndex))
		bonusDefense = select(6, GetSkillLineInfo(skillIndex))
	else
		baseDefense, bonusDefense = UnitDefense("player")
	end
	if ( bonusDefense > 0 ) then
		posBuff = bonusDefense
	elseif ( bonusDefense < 0 ) then
		negBuff = bonusDefense
	end
	local TooltipLine1 = L["Base Defense including talents such as Warrior's Anticipation is "]..baseDefense.."."
	local TooltipLine2 = L["Bonus Defense from items and enhancements is "]..bonusDefense.."."
	local TooltipLine3 = L["Total Defense is "]..(baseDefense + bonusDefense)..L[". Critical Hit immunity for a level 60 player against a raid boss occurs at 440 Defense and requires a defense skill of 140 from items and enhancements to achieve."]
	local total = "("..baseDefense.." |cff00c0ff+ "..bonusDefense.."|r)"
	return "", format("%.0f", (baseDefense + bonusDefense)), TooltipLine1, TooltipLine2, TooltipLine3, total
end
------------------
-- Spellcasting --
------------------
-- Current Mana Regen
-- local function ManaRegenCurrent() --This appears to be power regen like rage, energy, runes, focus, etc.
-- return "", format("%.0f", GetPowerRegen()), TooltipLine1, "", "", ""
-- end
local MP5Modifier = 0
-- MP5
local function MP5()
	local mp5 = 0
	for i=1,18 do
		local itemLink = GetInventoryItemLink("player", i)
		if itemLink then
			local stats = GetItemStats(itemLink)
			if stats then
				local statMP5 = stats["ITEM_MOD_POWER_REGEN0_SHORT"]
				if (statMP5) then
					mp5 = mp5 + statMP5 + 1
				end
			end
		end
	end
	MP5Modifier = mp5
	local TooltipLine1 = mp5.." "..L["Mana points regenerated every five seconds while casting and inside the five second rule."]
	local TooltipLine2 = format("%.2f", (mp5 * 0.4)).." "..L["Mana points regenerated every tick while casting and inside the five second rule."]
	return "", format("%.0f", mp5), TooltipLine1, TooltipLine2, "", ""
end
-- Mana Regen while not casting
local function ManaRegenNotCasting()
	MP5()
	local base, casting = GetManaRegen()
	local effectiveManaRegen = MP5Modifier * 0.4 -- Ticks are every 2 seconds, or 2/5 of MP5 stat per tick.
	local TooltipLine1 = L["Total Mana points regenerated per tick while not casting and outside the five second rule."]
	return "", format("%.2f", (base * 2) + effectiveManaRegen), TooltipLine1, "", "", ""
end
-- Spell Critical Strike Chance
local function SpellCrit()
	MAX_SPELL_SCHOOLS = 7;
	local holySchool = 2;
	local spellCrit;
	for i=(holySchool+1), MAX_SPELL_SCHOOLS do
		spellCrit = GetSpellCritChance(i);
	end
	local TooltipLine1 = L["Gives a chance to critically strike with spells, increasing the damage dealt by 50%."]
	return "", format("%.2f%%", spellCrit), TooltipLine1, "", "", ""
end
-- Bonus Spell Hit Chance Modifier
local function SpellHitModifier()
	local spellhit = GetSpellHitModifier()
	if spellhit == nil then spellhit = 0 end
	-- Blizzard fixed spellhit with SoD Phase 4 or 5 to no longer need to be divided by 7. Keeping here for posterity.
	-- spellhit = spellhit/7 -- Dunno why "/7", same as runspeed; some "magic number" like ATTACK_POWER_MAGIC_NUMBER, perhaps.
	spellhit = spellhit -- Dunno why "/7", same as runspeed; some "magic number" like ATTACK_POWER_MAGIC_NUMBER, perhaps.
	return "", format("%.2f%%", spellhit), "", "", "", ""
end
-- Bonus Healing
local function PlusHealing()
	return "", format("%.0f", GetSpellBonusHealing()), "", "", "", ""
end
-- Holy Plus Damage Bonus
local function HolyPlusDamage()
	return "", format("%.0f", GetSpellBonusDamage(2)), "", "", "", ""
end
-- Arcane Plus Damage Bonus
local function ArcanePlusDamage()
	return "", format("%.0f", GetSpellBonusDamage(7)), "", "", "", ""
end
-- Fire Plus Damage Bonus
local function FirePlusDamage()
	return "", format("%.0f", GetSpellBonusDamage(3)), "", "", "", ""
end
-- Nature Plus Damage Bonus
local function NaturePlusDamage()
	return "", format("%.0f", GetSpellBonusDamage(4)), "", "", "", ""
end
-- Frost Plus Damage Bonus
local function FrostPlusDamage()
	return "", format("%.0f", GetSpellBonusDamage(5)), "", "", "", ""
end
-- Shadow Plus Damage Bonus
local function ShadowPlusDamage()
	return "", format("%.0f", GetSpellBonusDamage(6)), "", "", "", ""
end

DCS_STAT_DATA = {
	---------------------
	-- Primary/General --
	---------------------
	DCS_Strength ={
		statName = "DCS_Strength",
		StatValue = 0,
		isShown = true,
		Label = L["Strength: "],
		statFunction = DCS_Strength,
		relativeTo = DCSPrimaryStatsHeader,
	},
	DCS_Agility ={
		statName = "DCS_Agility",
		StatValue = 0,
		isShown = true,
		Label = L["Agility: "],
		statFunction = DCS_Agility,
		relativeTo = DCSPrimaryStatsHeader,
	},
	DCS_Stamina ={
		statName = "DCS_Stamina",
		StatValue = 0,
		isShown = true,
		Label = L["Stamina: "],
		statFunction = DCS_Stamina,
		relativeTo = DCSPrimaryStatsHeader,
	},
	DCS_Intellect ={
		statName = "DCS_Intellect",
		StatValue = 0,
		isShown = true,
		Label = L["Intellect: "],
		statFunction = DCS_Intellect,
		relativeTo = DCSPrimaryStatsHeader,
	},
	DCS_Spirit ={
		statName = "DCS_Spirit",
		StatValue = 0,
		isShown = true,
		Label = L["Spirit: "],
		statFunction = DCS_Spirit,
		relativeTo = DCSPrimaryStatsHeader,
	},
	DCS_Armor ={
		statName = "DCS_Armor",
		StatValue = 0,
		isShown = true,
		Label = L["Armor: "],
		statFunction = DCS_Armor,
		relativeTo = DCSPrimaryStatsHeader,
	},
	MovementSpeed ={
		statName = "MovementSpeed",
		StatValue = 0,
		isShown = true,
		Label = L["Movement Speed: "],
		statFunction = MovementSpeed,
		relativeTo = DCSPrimaryStatsHeader,
	},
	DCS_Durability ={
		statName = "DCS_Durability",
		StatValue = 0,
		isShown = true,
		Label = L["Durability: "],
		statFunction = DCS_Durability,
		relativeTo = DCSPrimaryStatsHeader,
	},
	DCS_RepairTotal ={
		statName = "DCS_RepairTotal",
		StatValue = 0,
		isShown = true,
		Label = L["Repair Total: "],
		statFunction = DCS_RepairTotal,
		relativeTo = DCSPrimaryStatsHeader,
	},
	---------------------------
	-- Melee/Ranged/Physical --
	---------------------------
	MHWeaponSkill ={
		statName = "MHWeaponSkill",
		StatValue = 0,
		isShown = true,
		Label = L["Main Hand: "],
		statFunction = MHWeaponSkill,
		relativeTo = DCSMeleeEnhancementsStatsHeader,
	},
	MHDamage ={
		statName = "MHDamage",
		StatValue = 0,
		isShown = true,
		Label = "    "..L["Damage: "], --Indented to show as a sublisting under Main Hand
		statFunction = MHDamage,
		relativeTo = DCSMeleeEnhancementsStatsHeader,
	},
	MeleeAP ={
		statName = "MeleeAP",
		StatValue = 0,
		isShown = true,
		Label = "    "..L["Power: "], --Indented to show as a sublisting under Main Hand
		statFunction = MeleeAP,
		relativeTo = DCSMeleeEnhancementsStatsHeader,
	},
	OHWeaponSkill ={
		statName = "OHWeaponSkill",
		StatValue = 0,
		isShown = true,
		Label = L["Off Hand: "],
		statFunction = OHWeaponSkill,
		relativeTo = DCSMeleeEnhancementsStatsHeader,
	},
	OHDamage ={
		statName = "OHDamage",
		StatValue = 0,
		isShown = true,
		Label = "    "..L["Damage: "], --Indented to show as a sublisting under Off Hand
		statFunction = OHDamage,
		relativeTo = DCSMeleeEnhancementsStatsHeader,
	},
	MeleeCrit ={
		statName = "MeleeCrit",
		StatValue = 0,
		isShown = true,
		Label = L["Melee Crit: "],
		statFunction = MeleeCrit,
		relativeTo = DCSMeleeEnhancementsStatsHeader,
	},
	MeleeHitChance ={
		statName = "MeleeHitChance",
		StatValue = 0,
		isShown = true,
		Label = L["Melee Hit: "],
		statFunction = HitModifier,
		relativeTo = DCSMeleeEnhancementsStatsHeader,
	},
	RangedWeaponSkill ={
		statName = "RangedWeaponSkill",
		StatValue = 0,
		isShown = true,
		Label = L["Ranged: "],
		statFunction = RangedWeaponSkill,
		relativeTo = DCSRangedStatsHeader,
	},
	RangedAP ={
		statName = "RangedAP",
		StatValue = 0,
		isShown = true,
		Label = "    "..L["Power: "], --Indented to show as a sublisting under Ranged
		statFunction = RangedAP,
		relativeTo = DCSRangedStatsHeader,
	},
	RangedDamage ={
		statName = "RangedDamage",
		StatValue = 0,
		isShown = true,
		Label = "    "..L["Damage: "], --Indented to show as a sublisting under Ranged
		statFunction = RangedDamage,
		relativeTo = DCSRangedStatsHeader,
	},
	RangedCrit = {
		statName = "RangedCrit",
		StatValue = 0,
		isShown = true,
		Label = L["Ranged Crit: "],
		statFunction = RangedCrit,
		relativeTo = DCSRangedStatsHeader,
	},
	RangedHitChance ={
		statName = "RangedHitChance",
		StatValue = 0,
		isShown = true,
		Label = L["Ranged Hit: "],
		statFunction = RangedHitModifier,
		relativeTo = DCSRangedStatsHeader,
	},
	DodgeChance = {
		isShown = true,
		Label = L["Dodge: "],
		statFunction = Dodge,
		relativeTo = DCSDefenseStatsHeader,
	},
	Defense = {
		isShown = true,
		Label = L["Defense: "],
		statFunction = Defense,
		relativeTo = DCSDefenseStatsHeader,
		Description = "Defense, baby!",
	},
	ParryChance = {
		isShown = true,
		Label = L["Parry: "],
		statFunction = Parry,
		relativeTo = DCSDefenseStatsHeader,
	},
	BlockChance = {
		isShown = true,
		Label = L["Block: "],
		statFunction = BlockChance,
		relativeTo = DCSDefenseStatsHeader,
	},
	BlockValue = {
		isShown = true,
		Label = L["Block Value: "],
		statFunction = BlockValue,
		relativeTo = DCSDefenseStatsHeader,
	},
	-- ManaRegenCurrent = { --This appears to be power regen like rage, energy, runes, focus, etc.
	-- 	isShown = true,
	-- 	Label = L["Mana Regen Current: "],
	-- 	statFunction = ManaRegenCurrent,
	-- 	relativeTo = DCSSpellEnhancementsStatsHeader,
	-- },
	ManaRegenNotCasting = {
		isShown = true,
		Label = L["Mana Regen: "],
		statFunction = ManaRegenNotCasting,
		relativeTo = DCSSpellEnhancementsStatsHeader,
	},
	MP5 = {
		isShown = true,
		Label = L["MP5: "],
		statFunction = MP5,
		relativeTo = DCSSpellEnhancementsStatsHeader,
	},
	SpellCritChance = {
		isShown = true,
		Label = L["Spell Crit: "],
		statFunction = SpellCrit,
		relativeTo = DCSSpellEnhancementsStatsHeader,
	},
	SpellHitChance = {
		isShown = true,
		Label = L["Spell Hit: "],
		statFunction = SpellHitModifier,
		relativeTo = DCSSpellEnhancementsStatsHeader,
	},
	PlusHealing = {
		isShown = true,
		Label = L["+ Healing: "],
		statFunction = PlusHealing,
		relativeTo = DCSSpellEnhancementsStatsHeader,
	},
	HolyPlusDamage ={
		isShown = true,
		Label = L["+ Holy: "],
		statFunction = HolyPlusDamage,
		relativeTo = DCSSpellEnhancementsStatsHeader,
	},
	ArcanePlusDamage ={
		isShown = true,
		Label = L["+ Arcane: "],
		statFunction = ArcanePlusDamage,
		relativeTo = DCSSpellEnhancementsStatsHeader,
	},
	FirePlusDamage ={
		isShown = true,
		Label = L["+ Fire: "],
		statFunction = FirePlusDamage,
		relativeTo = DCSSpellEnhancementsStatsHeader,
	},
	NaturePlusDamage ={
		isShown = true,
		Label = L["+ Nature: "],
		statFunction = NaturePlusDamage,
		relativeTo = DCSSpellEnhancementsStatsHeader,
	},
	FrostPlusDamage ={
		isShown = true,
		Label = L["+ Frost: "],
		statFunction = FrostPlusDamage,
		relativeTo = DCSSpellEnhancementsStatsHeader,
	},
	ShadowPlusDamage ={
		isShown = true,
		Label = L["+ Shadow: "],
		statFunction = ShadowPlusDamage,
		relativeTo = DCSSpellEnhancementsStatsHeader,
	},
}

DCS_PRIMARY_STAT_LIST = {
	"DCS_Strength",
	"DCS_Agility",
	"DCS_Stamina",
	"DCS_Intellect",
	"DCS_Spirit",
	"DCS_Armor",
	"MovementSpeed",
	"DCS_Durability",
	"DCS_RepairTotal",
}

DCS_OFFENSE_STAT_LIST = {
	"MHWeaponSkill",
	"MeleeAP",
	"MHDamage",
	"OHWeaponSkill",
	"OHDamage",
	"MeleeCrit",
	"MeleeHitChance",
	-- "RangedWeaponSkill",
	-- "RangedAP",
	-- "RangedDamage",
	-- "RangedCrit",
	-- "RangedHitChance",
}

DCS_MELEE_STAT_LIST = {
}

DCS_RANGED_STAT_LIST = {
	"RangedWeaponSkill",
	"RangedAP",
	"RangedDamage",
	-- "RangedSpeed",
	-- "RangedDPS",
	"RangedCrit",
	"RangedHitChance",
	-- "RangedHaste",
}

DCS_DEFENSE_STAT_LIST = {
	"DodgeChance",
	"ParryChance",
	"BlockChance",
	"BlockValue",
	"Defense",
}

DCS_SPELL_STAT_LIST = {
	-- "ManaRegenCurrent", --This appears to be power regen like rage, energy, runes, focus, etc.
	"SpellHitChance",
	"SpellCritChance",
	"ManaRegenNotCasting",
	"MP5",
	"PlusHealing",
	"HolyPlusDamage",
	"ArcanePlusDamage",
	"FirePlusDamage",
	"NaturePlusDamage",
	"FrostPlusDamage",
	"ShadowPlusDamage",
}

local function DCS_CreateStatText(StatKey, StatValue, XoffSet, YoffSet, ShowHideStats)
	if (ShowHideStats == nil) then ShowHideStats = true end
	local isDCSFrameCreated = _G["DCS"..StatKey.."StatFrame"]
	if (isDCSFrameCreated == nil) then
		DejaClassicStatsFrame.statFrame = CreateFrame("Frame", "DCS"..StatKey.."StatFrame", DejaClassicStatsFrame)
		DejaClassicStatsFrame.statFrame:SetPoint("TOPLEFT", DCS_STAT_DATA[StatKey].relativeTo, "BOTTOMLEFT", (15 + XoffSet), ( (-14 * (YoffSet - 1)) -2) )
		DejaClassicStatsFrame.statFrame:SetSize(160, 16)

		DejaClassicStatsFrame.stat = DejaClassicStatsFrame.statFrame:CreateFontString(StatKey.."NameFS")
		DejaClassicStatsFrame.stat:SetPoint("LEFT", DejaClassicStatsFrame.statFrame, "LEFT")
		-- DejaClassicStatsFrame.stat:SetScale(0.9)

		if (namespace.locale == "zhCN") or (namespace.locale == "zhTW") or (namespace.locale == "koKR") then
			DejaClassicStatsFrame.stat:SetFontObject("GameFontNormalLarge")
		else
			DejaClassicStatsFrame.stat:SetFontObject("GameFontNormal")
		end
		DejaClassicStatsFrame.stat:SetJustifyH("LEFT")
		DejaClassicStatsFrame.stat:SetShadowOffset(1, -1)
		DejaClassicStatsFrame.stat:SetShadowColor(0, 0, 0)
		DejaClassicStatsFrame.stat:SetTextColor(1, 0.8, 0.1)
		DejaClassicStatsFrame.stat:SetText("")

		DejaClassicStatsFrame.value = DejaClassicStatsFrame.statFrame:CreateFontString(StatKey.."ValueFS")
		DejaClassicStatsFrame.value:SetPoint("RIGHT", DejaClassicStatsFrame.statFrame, "RIGHT")
		if (namespace.locale == "zhCN") or (namespace.locale == "zhTW") or (namespace.locale == "koKR") then
			DejaClassicStatsFrame.value:SetFontObject("GameFontNormalLarge")
		else
			DejaClassicStatsFrame.value:SetFontObject("GameFontNormal")
		end
		DejaClassicStatsFrame.value:SetJustifyH("RIGHT")
		DejaClassicStatsFrame.value:SetShadowOffset(1, -1)
		DejaClassicStatsFrame.value:SetShadowColor(0, 0, 0)
		DejaClassicStatsFrame.value:SetTextColor(1,1,1,1)
		DejaClassicStatsFrame.value:SetText("")
	end

	if ShowHideStats then
		_G["DCS"..StatKey.."StatFrame"]:Show()
	else
		_G["DCS"..StatKey.."StatFrame"]:Hide()
	end
end

local function DCS_SetStatText(StatKey, StatLabel, StatValue1, StatValue2, StatValue3, StatValue4, StatValue5, XoffSet, YoffSet)
	if (StatValue1 == "") then
		_G[StatKey.."NameFS"]:SetText("")
	else

		_G[StatKey.."NameFS"]:SetText(DCS_STAT_DATA[StatKey].Label)
	end
	_G[StatKey.."ValueFS"]:SetText(StatValue1)

	local tooltipheader

	if (StatLabel == "") then
		tooltipheader = DCS_STAT_DATA[StatKey].Label..StatValue1
	else
		tooltipheader = StatLabel
	end

	_G["DCS"..StatKey.."StatFrame"]:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(_G["DCS"..StatKey.."StatFrame"], "ANCHOR_RIGHT");
		GameTooltip:SetText(tooltipheader.." "..StatValue5, 1, 1, 1, 1, true)
		GameTooltip:AddLine(StatValue2, 1, 0.8, 0.1, true)
		GameTooltip:AddLine(StatValue3, 1, 0.8, 0.1, true)
		GameTooltip:AddLine(StatValue4, 1, 0.8, 0.1, true)
		GameTooltip:Show()
	end)

	_G["DCS"..StatKey.."StatFrame"]:SetScript("OnLeave", function(self)
		GameTooltip_Hide()
	end)
end

local function DCS_CREATE_STATS()

	for k, v in ipairs(DCS_PRIMARY_STAT_LIST) do
		local XoffSet = (0)
		local YoffSet = (0 + k)
		DCS_CreateStatText(v, 0, XoffSet, YoffSet, ShowPrimary)
	end
	for k, v in ipairs(DCS_OFFENSE_STAT_LIST) do
		DCS_CreateStatText(v, 0, 0, k, ShowMelee)
	end
	for k, v in ipairs(DCS_MELEE_STAT_LIST) do
		DCS_CreateStatText(v, 0, 0, k, ShowMelee)
	end
	for k, v in ipairs(DCS_RANGED_STAT_LIST) do
		DCS_CreateStatText(v, 0, 0, k, ShowRanged)
	end
	for k, v in ipairs(DCS_SPELL_STAT_LIST) do
		DCS_CreateStatText(v, 0, 0, k, ShowSpell)
	end
	for k, v in ipairs(DCS_DEFENSE_STAT_LIST) do
		local YoffSet = (2.2 + k)
		DCS_CreateStatText(v, 0, 0, YoffSet, ShowDefense)
	end
end

local function DCS_SET_STATS_TEXT()
	for k, v in ipairs(DCS_PRIMARY_STAT_LIST) do
		if ShowPrimary then
			local StatLabel, StatValue1, StatValue2, StatValue3, StatValue4, StatValue5 = DCS_STAT_DATA[v].statFunction()
			DCS_SetStatText(v, StatLabel, StatValue1, StatValue2, StatValue3, StatValue4, StatValue5, 0, 0)
		else
			DCS_SetStatText(v, "", "", "", "", "", "", 0, 0)
		end
	end
	for k, v in ipairs(DCS_OFFENSE_STAT_LIST) do
		if ShowMelee then
			local StatLabel, StatValue1, StatValue2, StatValue3, StatValue4, StatValue5 = DCS_STAT_DATA[v].statFunction()
			DCS_SetStatText(v, StatLabel, StatValue1, StatValue2, StatValue3, StatValue4, StatValue5, 0, 0)
		else
			DCS_SetStatText(v, "", "", "", "", "", "", 0, 0)
		end
	end
	for k, v in ipairs(DCS_MELEE_STAT_LIST) do
		if ShowMelee then
			local StatLabel, StatValue1, StatValue2, StatValue3, StatValue4, StatValue5 = DCS_STAT_DATA[v].statFunction()
			DCS_SetStatText(v, StatLabel, StatValue1, StatValue2, StatValue3, StatValue4, StatValue5, 0, 0)
		else
			DCS_SetStatText(v, "", "", "", "", "", "", 0, 0)
		end
	end
	for k, v in ipairs(DCS_RANGED_STAT_LIST) do
		if ShowRanged then
			local StatLabel, StatValue1, StatValue2, StatValue3, StatValue4, StatValue5 = DCS_STAT_DATA[v].statFunction()
			DCS_SetStatText(v, StatLabel, StatValue1, StatValue2, StatValue3, StatValue4, StatValue5, 0, 0)
		-- else
		-- 	DCS_SetStatText(v, "", "", "", "", "", "", 0, 0)
		end
	end
	for k, v in ipairs(DCS_SPELL_STAT_LIST) do
		if ShowSpell then
			local StatLabel, StatValue1, StatValue2, StatValue3, StatValue4, StatValue5 = DCS_STAT_DATA[v].statFunction()
			DCS_SetStatText(v, StatLabel, StatValue1, StatValue2, StatValue3, StatValue4, StatValue5, 0, 0)
		else
			DCS_SetStatText(v, "", "", "", "", "", "", 0, 0)
		end
	end
	for k, v in ipairs(DCS_DEFENSE_STAT_LIST) do
		if ShowDefense then
			local StatLabel, StatValue1, StatValue2, StatValue3, StatValue4, StatValue5 = DCS_STAT_DATA[v].statFunction()
			DCS_SetStatText(v, StatLabel, StatValue1, StatValue2, StatValue3, StatValue4, StatValue5, 0, 0)
		else
			DCS_SetStatText(v, "", "", "", "", "", "", 0, 0)
		end
	end
end

DCS_CLASSIC_SPECS = { -- These are not default UI/API positions organized to attatch specs to appropriate headings (Primary, Offense, Defense)
	DRUID = {
		spec = {
			tree1 = "DruidBalance",
			tree2 = "DruidFeralCombat",
			tree3 = "DruidRestoration",
		},
	},
	HUNTER = {
		spec = {
			tree1 = "HunterBeastMastery",
			tree2 = "HunterMarksmanship",
			tree3 = "HunterSurvival",
		},
	},
	MAGE = {
		spec = {
			tree1 = "MageArcane",
			tree2 = "MageFire",
			tree3 = "MageFrost",
		},
	},
	PALADIN = {
		spec = {
			tree1 = "PaladinHoly",
			tree2 = "PaladinProtection",
			tree3 = "PaladinCombat",
		},
	},
	PRIEST = {
		spec = {
			tree1 = "PriestDiscipline",
			tree2 = "PriestHoly",
			tree3 = "PriestShadow",
		},
	},
	ROGUE = {
		spec = {
			tree1 = "RogueAssassination",
			tree2 = "RogueCombat",
			tree3 = "RogueSubtlety",
		},
	},
	SHAMAN = {
		spec = {
			tree1 = "ShamanElementalCombat",
			tree2 = "ShamanEnhancement",
			tree3 = "ShamanRestoration",
		},
	},
	WARLOCK = {
		spec = {
			tree1 = "WarlockCurses",
			tree2 = "WarlockSummoning",
			tree3 = "WarlockDestruction",
		},
	},
	WARRIOR = {
		spec = {
			tree1 = "WarriorArms",
			tree2 = "WarriorFury",
			tree3 = "WarriorProtection",
		},
	},
}

DCS_CATEGORIES = {
	"Primary",
	"Offense",
	"Defense",
}

---------------------------------------------------
-- Get Talent Points Spent Set Top Art As Primary--
---------------------------------------------------
local DCS_PrimaryTalentSpec, DCS_OffenseTalentSpec, DCS_DefenseTalentSpec

local function DCS_GetTalents()
	local numTabs = GetNumTalentTabs();
	local primaryTalentTree = GetPrimaryTalentTree();
	local tab1, tab2, tab3
	for t=1, numTabs do
		local pointsSpent = select(5, GetTalentTabInfo(t))
		if t==1 then
			tab1 = pointsSpent
		elseif t==2 then
			tab2 = pointsSpent
		elseif t==3 then
			tab3 = pointsSpent
		end
	end
	local tbl = {tab1, tab2, tab3}
	local function indexsort(tbl)
		local idx = {}
		for i = 1, #tbl do idx[i] = i end -- build a table of indexes
		-- sort the indexes, but use the values as the sorting criteria
		table.sort(idx, function(a, b) return tbl[a] > tbl[b] end)
		-- return the sorted indexes
		return (table.unpack or unpack)(idx)
	end
	DCS_PrimaryTalentSpec, DCS_OffenseTalentSpec, DCS_DefenseTalentSpec = indexsort(tbl)
end

-----------------------
-- Talent Scroll Art --
-----------------------
gdbprivate.gdbdefaults.gdbdefaults.DejaClassicStatsShowHideScrollArtBackground = {
	ShowHideScrollArtBackgroundChecked = true,
}

local TalentArtScale = 0.55
local TalentArtoffsetX, TalentArtoffsetY = 25, 20
local ShowHideScrollArt
local DesaturateScrollArtBackground

local function DCS_TalentArtFrames(v, frameTL, frameTR, frameBL, frameBR, drawLayer, DCS_TalentSpec, TLAnchorframePoint, frameTLrelativeTo, relativePoint, xOffset, yOffset)
	ShowHideScrollArt = gdbprivate.gdb.gdbdefaults.DejaClassicStatsShowHideScrollArtBackground.ShowHideScrollArtBackgroundChecked
	DesaturateScrollArtBackground = gdbprivate.gdb.gdbdefaults.DejaClassicStatsDesaturateScrollArtBackground.DesaturateScrollArtBackgroundChecked
	local frameexists = _G[frameTL.."Frame"]
	if (frameexists) then --Check for first frame, assume others unless errors occur
		if (ShowHideScrollArt == false) then
			_G[frameTL.."Frame"]:Hide()
			_G[frameTR.."Frame"]:Hide()
			_G[frameBL.."Frame"]:Hide()
			_G[frameBR.."Frame"]:Hide()
			_G[frameTL.."Frame"]:SetDesaturated(DesaturateScrollArtBackground);
			_G[frameTR.."Frame"]:SetDesaturated(DesaturateScrollArtBackground);
			_G[frameBL.."Frame"]:SetDesaturated(DesaturateScrollArtBackground);
			_G[frameBR.."Frame"]:SetDesaturated(DesaturateScrollArtBackground);
		end
		if (ShowHideScrollArt == true) then
			_G[frameTL.."Frame"]:Show()
			_G[frameTR.."Frame"]:Show()
			_G[frameBL.."Frame"]:Show()
			_G[frameBR.."Frame"]:Show()
			_G[frameTL.."Frame"]:SetDesaturated(DesaturateScrollArtBackground);
			_G[frameTR.."Frame"]:SetDesaturated(DesaturateScrollArtBackground);
			_G[frameBL.."Frame"]:SetDesaturated(DesaturateScrollArtBackground);
			_G[frameBR.."Frame"]:SetDesaturated(DesaturateScrollArtBackground);
		end
	else
		local frameTL=DejaClassicStatsFrame:CreateTexture(frameTL.."Frame","ARTWORK", nil, drawLayer)
		frameTL:ClearAllPoints()
		frameTL:SetScale(TalentArtScale)
		frameTL:SetTexture("Interface\\TALENTFRAME\\"..DCS_CLASSIC_SPECS[classFilename].spec["tree"..DCS_TalentSpec].."-TopLeft")
		frameTL:SetDesaturated(DesaturateScrollArtBackground);
		frameTL:SetPoint(TLAnchorframePoint, frameTLrelativeTo, relativePoint, xOffset, yOffset)
		local frameTR=DejaClassicStatsFrame:CreateTexture(frameTR.."Frame","ARTWORK", nil, drawLayer)
		frameTR:ClearAllPoints()
		frameTR:SetScale(TalentArtScale)
		frameTR:SetTexture("Interface\\TALENTFRAME\\"..DCS_CLASSIC_SPECS[classFilename].spec["tree"..DCS_TalentSpec].."-TopRight")
		frameTR:SetDesaturated(DesaturateScrollArtBackground);
		frameTR:SetPoint("TOPLEFT", frameTL, "TOPRIGHT")
		local frameBL=DejaClassicStatsFrame:CreateTexture(frameBL.."Frame","ARTWORK", nil, drawLayer)
		frameBL:ClearAllPoints()
		frameBL:SetScale(TalentArtScale)
		frameBL:SetTexture("Interface\\TALENTFRAME\\"..DCS_CLASSIC_SPECS[classFilename].spec["tree"..DCS_TalentSpec].."-BottomLeft")
		frameBL:SetDesaturated(DesaturateScrollArtBackground);
		frameBL:SetPoint("TOPLEFT", frameTL, "BOTTOMLEFT")
		local frameBR=DejaClassicStatsFrame:CreateTexture(frameBR.."Frame","ARTWORK", nil, drawLayer)
		frameBR:ClearAllPoints()
		frameBR:SetScale(TalentArtScale)
		frameBR:SetTexture("Interface\\TALENTFRAME\\"..DCS_CLASSIC_SPECS[classFilename].spec["tree"..DCS_TalentSpec].."-BottomRight")
		frameBR:SetDesaturated(DesaturateScrollArtBackground);
		frameBR:SetPoint("TOPLEFT", frameTL, "BOTTOMRIGHT")
		if (ShowHideScrollArt == false) then
			frameTL:Hide()
			frameTR:Hide()
			frameBL:Hide()
			frameBR:Hide()
		end
	end
end

local function DCS_SetTalentArtFrames()
	DCS_GetTalents()
	for k, v in ipairs(DCS_CATEGORIES) do
		local DCS_TalentSpec
		local frameTLrelativeTo = DejaClassicStatsFrame
		local TLAnchorframePoint
		local frameTLrelativeTo
		local relativePoint
		local xOffset
		local yOffset
		if (v == "Primary") then
			DCS_TalentSpec = DCS_PrimaryTalentSpec
			TLAnchorframePoint = "TOPLEFT"
			frameTLrelativeTo = DejaClassicStatsFrame
			relativePoint = "TOPLEFT"
			xOffset = 25
			yOffset = -35
		elseif (v == "Offense") then
			DCS_TalentSpec = DCS_OffenseTalentSpec
			TLAnchorframePoint = "TOPLEFT"
			frameTLrelativeTo = "PrimaryBottomLeftTalentTextureFrame"
			relativePoint = "BOTTOMLEFT"
			xOffset = 0
			yOffset = 60
		elseif (v == "Defense") then
			DCS_TalentSpec = DCS_DefenseTalentSpec
			TLAnchorframePoint = "TOPLEFT"
			frameTLrelativeTo = "OffenseBottomLeftTalentTextureFrame"
			relativePoint = "BOTTOMLEFT"
			xOffset = 0
			yOffset = 60
		end
		-- Old relativeto is to attatch to the stat headers.
		-- DCS_TalentArtFrames(v, v.."TopLeftTalentTexture", v.."TopRightTalentTexture", v.."BottomLeftTalentTexture", v.."BottomRightTalentTexture", k, DCS_TalentSpec, "DCS"..v.."StatsHeader", "BOTTOMLEFT")
		--New is to attatch to the scroll pane top, center and bottom.
		DCS_TalentArtFrames(v, v.."TopLeftTalentTexture", v.."TopRightTalentTexture", v.."BottomLeftTalentTexture", v.."BottomRightTalentTexture", k, DCS_TalentSpec, TLAnchorframePoint, frameTLrelativeTo, relativePoint, xOffset, yOffset)
	end
end

------------------------------------------------
-- Mouseover Character Model Rotation Buttons --
------------------------------------------------
CHAR_ROTATE_BUTTONS = {
	"CharacterModelFrameRotateRightButton",
	"CharacterModelFrameRotateLeftButton",
	}

local ignoreDCSRBAlpha
local DCSRBAlphaTimer

local function SetAlpha(frame)
	if ignoreDCSRBAlpha then return end
	ignoreDCSRBAlpha = true
	if frame:IsMouseOver() then
		frame:SetAlpha(1)
	else
		frame:SetAlpha(0)
	end
	ignoreDCSRBAlpha = nil
end

local function showDCSRB(self)
	if DCSRBAlphaTimer then DCSRBAlphaTimer:Cancel() end
	for _, v in ipairs(CHAR_ROTATE_BUTTONS) do
		ignoreDCSRBAlpha = true
		_G[v]:SetAlpha(1)
		ignoreDCSRBAlpha = nil
	end
end

local function hideDCSRB(self)
	for _, v in ipairs(CHAR_ROTATE_BUTTONS) do
		if ShowModelRotation then
			showDCSRB(self)
		else
			ignoreDCSRBAlpha = true
			_G[v]:SetAlpha(0)
			ignoreDCSRBAlpha = nil
		end
	end
end

local function delayHideDCSRB(self)
	DCSRBAlphaTimer = C_Timer.NewTimer(0.75, hideDCSRB)
end

for _, v in ipairs(CHAR_ROTATE_BUTTONS) do
	v = _G[v]
	hooksecurefunc(v, "SetAlpha", SetAlpha)
	v:HookScript("OnShow", delayHideDCSRB)
	v:HookScript("OnEnter", showDCSRB)
	v:HookScript("OnLeave", delayHideDCSRB)
end

--------------------------------------
-- Show/Hide Talents Background Art --
--------------------------------------
local DCS_ShowHideScrollArtBackgroundCheckedCheck = CreateFrame("CheckButton", "DCS_ShowHideScrollArtBackgroundCheckedCheck", DejaClassicStatsPanel, "InterfaceOptionsCheckButtonTemplate")
	DCS_ShowHideScrollArtBackgroundCheckedCheck:RegisterEvent("PLAYER_LOGIN")
	DCS_ShowHideScrollArtBackgroundCheckedCheck:ClearAllPoints()
	--DCS_ShowHideScrollArtBackgroundCheckedCheck:SetPoint("TOPLEFT", 30, -255)
	DCS_ShowHideScrollArtBackgroundCheckedCheck:SetPoint("TOPLEFT", "dcsMiscPanelCategoryFS", 7, -15)
	DCS_ShowHideScrollArtBackgroundCheckedCheck:SetScale(1)
	_G[DCS_ShowHideScrollArtBackgroundCheckedCheck:GetName() .. "Text"]:SetText(L["Background Art"])
	DCS_ShowHideScrollArtBackgroundCheckedCheck.tooltipText = L["Displays the class talents background art."] --Creates a tooltip on mouseover.

DCS_ShowHideScrollArtBackgroundCheckedCheck:SetScript("OnEvent", function(self, event, ...)
	ShowHideScrollArt = gdbprivate.gdb.gdbdefaults.DejaClassicStatsShowHideScrollArtBackground.ShowHideScrollArtBackgroundChecked
	self:SetChecked(ShowHideScrollArt)
	DCS_SetTalentArtFrames()
end)

DCS_ShowHideScrollArtBackgroundCheckedCheck:SetScript("OnClick", function(self)
	ShowHideScrollArt = not ShowHideScrollArt
	gdbprivate.gdb.gdbdefaults.DejaClassicStatsShowHideScrollArtBackground.ShowHideScrollArtBackgroundChecked = ShowHideScrollArt
	DCS_SetTalentArtFrames()
end)

---------------------------------------
-- Desaturate Talents Background Art --
---------------------------------------
gdbprivate.gdbdefaults.gdbdefaults.DejaClassicStatsDesaturateScrollArtBackground = {
	DesaturateScrollArtBackgroundChecked = false,
}
local DesaturateScrollArtBackground --alternate display position of item repair cost, durability, and ilvl

local DCS_DesaturateScrollArtBackgroundCheckedCheck = CreateFrame("CheckButton", "DCS_DesaturateScrollArtBackgroundCheckedCheck", DejaClassicStatsPanel, "InterfaceOptionsCheckButtonTemplate")
	DCS_DesaturateScrollArtBackgroundCheckedCheck:RegisterEvent("PLAYER_LOGIN")
	DCS_DesaturateScrollArtBackgroundCheckedCheck:ClearAllPoints()
	--DCS_DesaturateScrollArtBackgroundCheckedCheck:SetPoint("TOPLEFT", 30, -255)
	DCS_DesaturateScrollArtBackgroundCheckedCheck:SetPoint("TOPLEFT", "dcsMiscPanelCategoryFS", 7, -35)
	DCS_DesaturateScrollArtBackgroundCheckedCheck:SetScale(1)
	_G[DCS_DesaturateScrollArtBackgroundCheckedCheck:GetName() .. "Text"]:SetText(L["Monochrome Background Art"])
	DCS_DesaturateScrollArtBackgroundCheckedCheck.tooltipText = L["Displays black and white class talents background art."] --Creates a tooltip on mouseover.

DCS_DesaturateScrollArtBackgroundCheckedCheck:SetScript("OnEvent", function(self, event, ...)
	DesaturateScrollArtBackground = gdbprivate.gdb.gdbdefaults.DejaClassicStatsDesaturateScrollArtBackground.DesaturateScrollArtBackgroundChecked
	self:SetChecked(DesaturateScrollArtBackground)
end)

DCS_DesaturateScrollArtBackgroundCheckedCheck:SetScript("OnClick", function(self)
	DesaturateScrollArtBackground = not DesaturateScrollArtBackground
	gdbprivate.gdb.gdbdefaults.DejaClassicStatsDesaturateScrollArtBackground.DesaturateScrollArtBackgroundChecked = DesaturateScrollArtBackground
	DCS_SetTalentArtFrames()
end)

----------------------------------------
-- Show/Hide/Move Default Stats Frame --
----------------------------------------

gdbprivate.gdbdefaults.gdbdefaults.DejaClassicStatsShowDefaultStats = {
	ShowDefaultStatsChecked = false,
}

local function Default_SetResistances()
	for i=1, 5, 1 do
		local frame = _G["MagicResFrame"..i]
		frame:SetParent(CharacterModelFrame)
		frame:ClearAllPoints()
		if ShowDefaultStats then
			if (i==1) then
				frame:SetPoint("TOPRIGHT", CharacterModelFrame, "TOPRIGHT", -1, 1)
			else
				frame:SetPoint("TOP", _G["MagicResFrame"..(i-1)], "BOTTOM", 0,0)
			end
		else
			if (i==1) then
				frame:SetPoint("TOPRIGHT", CharacterModelFrame, "TOPRIGHT", -9, -3)
			else
				frame:SetPoint("TOP", _G["MagicResFrame"..(i-1)], "BOTTOM", 0,0)
			end
		end
	end
end

local function DCS_SetResistances()
	if DefaultResistances then
		Default_SetResistances()
	else
		for i=1, 5, 1 do
			local frame = _G["MagicResFrame"..i]
			frame:SetParent(DejaClassicStatsFrame)
			frame:ClearAllPoints()
			frame:Show()
			if ShowDefense then
				if (i==1) then
					frame:SetPoint("TOPLEFT", DCSDefenseStatsHeader, "BOTTOMLEFT", 12, 0)
				else
					frame:SetPoint("TOPLEFT", _G["MagicResFrame"..(i-1)], "TOPRIGHT", 2,0)
				end
			else
				frame:Hide()
			end
		end
	end
end

local function DCS_SetAllStatFrames()
	if ShowDefaultStats then
		CharacterModelFrame:SetPoint("TOPLEFT", CharacterHeadSlot, "TOPRIGHT", 7, -4)
		CharacterModelFrame:SetPoint("BOTTOMRIGHT", CharacterTrinket1Slot, "BOTTOMLEFT", -8, 96)
		CharacterAttributesFrame:Show()
		DCS_SetResistances()
	else
		CharacterModelFrame:SetPoint("TOPLEFT", CharacterHeadSlot, "TOPRIGHT")
		CharacterModelFrame:SetPoint("BOTTOMRIGHT", CharacterTrinket1Slot, "BOTTOMLEFT")
		CharacterAttributesFrame:Hide()
		DCS_SetResistances()
	end
end

local DCS_ShowDefaultStatsCheckedCheck = CreateFrame("CheckButton", "DCS_ShowDefaultStatsCheckedCheck", DejaClassicStatsPanel, "InterfaceOptionsCheckButtonTemplate")
	DCS_ShowDefaultStatsCheckedCheck:RegisterEvent("PLAYER_LOGIN")
	DCS_ShowDefaultStatsCheckedCheck:ClearAllPoints()
	--DCS_ShowDefaultStatsCheckedCheck:SetPoint("TOPLEFT", 30, -255)
	DCS_ShowDefaultStatsCheckedCheck:SetPoint("TOPLEFT", "dcsItemsPanelCategoryFS", 7, -235)
	DCS_ShowDefaultStatsCheckedCheck:SetScale(1)
	_G[DCS_ShowDefaultStatsCheckedCheck:GetName() .. "Text"]:SetText(L["Default Stats"])
	DCS_ShowDefaultStatsCheckedCheck.tooltipText = L["Displays the default stat frames."] --Creates a tooltip on mouseover.

DCS_ShowDefaultStatsCheckedCheck:SetScript("OnEvent", function(self, event, ...)
	ShowDefaultStats = gdbprivate.gdb.gdbdefaults.DejaClassicStatsShowDefaultStats.ShowDefaultStatsChecked
	self:SetChecked(ShowDefaultStats)
	DCS_SetAllStatFrames()
end)

DCS_ShowDefaultStatsCheckedCheck:SetScript("OnClick", function(self)
	ShowDefaultStats = not ShowDefaultStats
	gdbprivate.gdb.gdbdefaults.DejaClassicStatsShowDefaultStats.ShowDefaultStatsChecked = ShowDefaultStats
	DCS_SetAllStatFrames()
	hideDCSRB()
end)

gdbprivate.gdbdefaults.gdbdefaults.DejaClassicStatsDefaultResistances = {
	DefaultResistancesChecked = false,
}

local DCS_DefaultResistancesCheck = CreateFrame("CheckButton", "DCS_DefaultResistancesCheck", DejaClassicStatsPanel, "InterfaceOptionsCheckButtonTemplate")
	DCS_DefaultResistancesCheck:RegisterEvent("PLAYER_LOGIN")
	DCS_DefaultResistancesCheck:ClearAllPoints()
	--DCS_DefaultResistancesCheck:SetPoint("TOPLEFT", 30, -255)
	DCS_DefaultResistancesCheck:SetPoint("TOPLEFT", "dcsItemsPanelCategoryFS", 7, -255)
	DCS_DefaultResistancesCheck:SetScale(1)
	_G[DCS_DefaultResistancesCheck:GetName() .. "Text"]:SetText(L["Default Resistances"])
	DCS_DefaultResistancesCheck.tooltipText = L["Displays the default resistance frames."] --Creates a tooltip on mouseover.

DCS_DefaultResistancesCheck:SetScript("OnEvent", function(self, event, ...)
	DefaultResistances = gdbprivate.gdb.gdbdefaults.DejaClassicStatsDefaultResistances.DefaultResistancesChecked
	self:SetChecked(DefaultResistances)
	DCS_SetResistances()
end)

DCS_DefaultResistancesCheck:SetScript("OnClick", function(self)
	DefaultResistances = not DefaultResistances
	gdbprivate.gdb.gdbdefaults.DejaClassicStatsDefaultResistances.DefaultResistancesChecked = DefaultResistances
	DCS_SetResistances()
end)

gdbprivate.gdbdefaults.gdbdefaults.DejaClassicStatsShowModelRotation = {
	ShowModelRotationChecked = false,
}

local DCS_ShowModelRotationCheck = CreateFrame("CheckButton", "DCS_ShowModelRotationCheck", DejaClassicStatsPanel, "InterfaceOptionsCheckButtonTemplate")
	DCS_ShowModelRotationCheck:RegisterEvent("PLAYER_LOGIN")
	DCS_ShowModelRotationCheck:ClearAllPoints()
	--DCS_ShowModelRotationCheck:SetPoint("TOPLEFT", 30, -295)
	DCS_ShowModelRotationCheck:SetPoint("TOPLEFT", "dcsItemsPanelCategoryFS", 7, -275)
	DCS_ShowModelRotationCheck:SetScale(1)
	_G[DCS_ShowModelRotationCheck:GetName() .. "Text"]:SetText(L["Rotation Buttons"])
	DCS_ShowModelRotationCheck.tooltipText = L["Displays the Character Model Rotation buttons."] --Creates a tooltip on mouseover.

DCS_ShowModelRotationCheck:SetScript("OnEvent", function(self, event, ...)
	ShowModelRotation = gdbprivate.gdb.gdbdefaults.DejaClassicStatsShowModelRotation.ShowModelRotationChecked
	self:SetChecked(ShowModelRotation)
	hideDCSRB()
end)

DCS_ShowModelRotationCheck:SetScript("OnClick", function(self)
	ShowModelRotation = not ShowModelRotation
	gdbprivate.gdb.gdbdefaults.DejaClassicStatsShowModelRotation.ShowModelRotationChecked = ShowModelRotation
	hideDCSRB()
end)

local DejaClassicStatsEventFrame = CreateFrame("Frame", "DejaClassicStatsEventFrame", UIParent)
-- DejaClassicStatsEventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
DejaClassicStatsEventFrame:RegisterEvent("ADDON_LOADED")
DejaClassicStatsEventFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")

	DejaClassicStatsEventFrame:SetScript("OnEvent", function(self, event, arg1)
		if event == "ADDON_LOADED" and arg1 == "DejaClassicStats" then
			DCS_SetAllStatFrames()
			DCS_CREATE_STATS()
			DCS_SET_STATS_TEXT()
			DCS_SetResistances()
			DCS_RepairTotal()
			self:UnregisterEvent("ADDON_LOADED")
		end
	end)

	hooksecurefunc("PaperDollFrame_UpdateStats", function()
		DCS_CREATE_STATS()
		DCS_SET_STATS_TEXT()
		DCS_RepairTotal()
	end)


gdbprivate.gdbdefaults.gdbdefaults.DejaClassicStatsShowPrimaryChecked = {
	ShowPrimarySetChecked = true,
}

local DCS_ShowPrimaryCheck = CreateFrame("CheckButton", "DCS_ShowPrimaryCheck", DejaClassicStatsPanel, "InterfaceOptionsCheckButtonTemplate")
DCS_ShowPrimaryCheck:RegisterEvent("PLAYER_LOGIN")

DCS_ShowPrimaryCheck:ClearAllPoints()
	DCS_ShowPrimaryCheck:SetPoint("TOPLEFT", "dcsItemsPanelHeadersFS", 7, -15)
	DCS_ShowPrimaryCheck:SetScale(1)
	DCS_ShowPrimaryCheck.tooltipText = L["Show primary stats."] --Creates a tooltip on mouseover.
	_G[DCS_ShowPrimaryCheck:GetName() .. "Text"]:SetText(L["Primary Stats"])

DCS_ShowPrimaryCheck:SetScript("OnEvent", function(self, event, ...)
	ShowPrimary = gdbprivate.gdb.gdbdefaults.DejaClassicStatsShowPrimaryChecked.ShowPrimarySetChecked
	self:SetChecked(ShowPrimary)
	if ShowPrimary then
		DCSPrimaryStatsHeader:Show()
		DCSMeleeEnhancementsStatsHeader:SetPoint("TOPLEFT", "DejaClassicStatsFrame", "TOPLEFT", DCS_HeaderInsetX, primaryYoffset)
	else
		DCSPrimaryStatsHeader:Hide()
		DCSMeleeEnhancementsStatsHeader:SetPoint("TOPLEFT", "DCSPrimaryStatsHeader", "TOPLEFT")
	end
	DCSHeaderYOffsets()
	DCS_CREATE_STATS()
	DCS_SET_STATS_TEXT()
end)

DCS_ShowPrimaryCheck:SetScript("OnClick", function(self)
	ShowPrimary = not ShowPrimary
	if ShowPrimary then
		DCSPrimaryStatsHeader:Show()
		DCSMeleeEnhancementsStatsHeader:SetPoint("TOPLEFT", "DejaClassicStatsFrame", "TOPLEFT", DCS_HeaderInsetX, primaryYoffset)
	else
		DCSPrimaryStatsHeader:Hide()
		DCSMeleeEnhancementsStatsHeader:SetPoint("TOPLEFT", "DCSPrimaryStatsHeader", "TOPLEFT")
	end
	DCS_CREATE_STATS()
	DCS_SET_STATS_TEXT()
	gdbprivate.gdb.gdbdefaults.DejaClassicStatsShowPrimaryChecked.ShowPrimarySetChecked = ShowPrimary
	DCSHeaderYOffsets()
end)

gdbprivate.gdbdefaults.gdbdefaults.DejaClassicStatsShowMeleeChecked = {
	ShowMeleeSetChecked = true,
}

local DCS_ShowMeleeCheck = CreateFrame("CheckButton", "DCS_ShowMeleeCheck", DejaClassicStatsPanel, "InterfaceOptionsCheckButtonTemplate")
DCS_ShowMeleeCheck:RegisterEvent("PLAYER_LOGIN")

DCS_ShowMeleeCheck:ClearAllPoints()
	DCS_ShowMeleeCheck:SetPoint("TOPLEFT", "dcsItemsPanelHeadersFS", 7, -35)
	DCS_ShowMeleeCheck:SetScale(1)
	DCS_ShowMeleeCheck.tooltipText = L["Show melee stats."] --Creates a tooltip on mouseover.
	_G[DCS_ShowMeleeCheck:GetName() .. "Text"]:SetText(L["Melee Stats"])

DCS_ShowMeleeCheck:SetScript("OnEvent", function(self, event, ...)
	-- ShowPrimary = gdbprivate.gdb.gdbdefaults.DejaClassicStatsShowPrimaryChecked.ShowPrimarySetChecked
	ShowMelee = gdbprivate.gdb.gdbdefaults.DejaClassicStatsShowMeleeChecked.ShowMeleeSetChecked
	self:SetChecked(ShowMelee)
	if ShowMelee then
		DCSMeleeEnhancementsStatsHeader:Show()
		DCSRangedStatsHeader:SetPoint("TOPLEFT", "DCSMeleeEnhancementsStatsHeader", "TOPLEFT", DCS_HeaderInsetX, meleeYoffset)
	else
		DCSMeleeEnhancementsStatsHeader:Hide()
		DCSRangedStatsHeader:SetPoint("TOPLEFT", "DCSMeleeEnhancementsStatsHeader", "TOPLEFT")
	end
	DCSHeaderYOffsets()
	DCS_CREATE_STATS()
	DCS_SET_STATS_TEXT()
end)

DCS_ShowMeleeCheck:SetScript("OnClick", function(self)
	ShowMelee = not ShowMelee
	if ShowMelee then
		DCSMeleeEnhancementsStatsHeader:Show()
		DCSRangedStatsHeader:SetPoint("TOPLEFT", "DCSMeleeEnhancementsStatsHeader", "TOPLEFT", DCS_HeaderInsetX, meleeYoffset)
	else
		DCSMeleeEnhancementsStatsHeader:Hide()
		DCSRangedStatsHeader:SetPoint("TOPLEFT", "DCSMeleeEnhancementsStatsHeader", "TOPLEFT")
	end
	DCS_CREATE_STATS()
	DCS_SET_STATS_TEXT()
	gdbprivate.gdb.gdbdefaults.DejaClassicStatsShowMeleeChecked.ShowMeleeSetChecked = ShowMelee
	DCSHeaderYOffsets()
end)

gdbprivate.gdbdefaults.gdbdefaults.DejaClassicStatsShowRangedChecked = {
	ShowRangedSetChecked = true,
}

local DCS_ShowRangedCheck = CreateFrame("CheckButton", "DCS_ShowRangedCheck", DejaClassicStatsPanel, "InterfaceOptionsCheckButtonTemplate")
DCS_ShowRangedCheck:RegisterEvent("PLAYER_LOGIN")

DCS_ShowRangedCheck:ClearAllPoints()
	DCS_ShowRangedCheck:SetPoint("TOPLEFT", "dcsItemsPanelHeadersFS", 7, -55)
	DCS_ShowRangedCheck:SetScale(1)
	DCS_ShowRangedCheck.tooltipText = L["Show ranged stats."] --Creates a tooltip on mouseover.
	_G[DCS_ShowRangedCheck:GetName() .. "Text"]:SetText(L["Ranged Stats"])

DCS_ShowRangedCheck:SetScript("OnEvent", function(self, event, ...)
	ShowRanged = gdbprivate.gdb.gdbdefaults.DejaClassicStatsShowRangedChecked.ShowRangedSetChecked
	self:SetChecked(ShowRanged)
	if ShowRanged then
		DCSRangedStatsHeader:Show()
		DCSSpellEnhancementsStatsHeader:SetPoint("TOPLEFT", "DCSRangedStatsHeader", "TOPLEFT", DCS_HeaderInsetX, rangedYoffset)
	else
		DCSRangedStatsHeader:Hide()
		DCSSpellEnhancementsStatsHeader:SetPoint("TOPLEFT", "DCSRangedStatsHeader", "TOPLEFT")
	end
	DCSHeaderYOffsets()
	DCS_CREATE_STATS()
	DCS_SET_STATS_TEXT()
end)

DCS_ShowRangedCheck:SetScript("OnClick", function(self)
	ShowRanged = not ShowRanged
	if ShowRanged then
		DCSRangedStatsHeader:Show()
		DCSSpellEnhancementsStatsHeader:SetPoint("TOPLEFT", "DCSRangedStatsHeader", "TOPLEFT", DCS_HeaderInsetX, rangedYoffset)
	else
		DCSRangedStatsHeader:Hide()
		DCSSpellEnhancementsStatsHeader:SetPoint("TOPLEFT", "DCSRangedStatsHeader", "TOPLEFT")
	end
	DCS_CREATE_STATS()
	DCS_SET_STATS_TEXT()
	gdbprivate.gdb.gdbdefaults.DejaClassicStatsShowRangedChecked.ShowRangedSetChecked = ShowRanged
	DCSHeaderYOffsets()
end)

gdbprivate.gdbdefaults.gdbdefaults.DejaClassicStatsShowSpellChecked = {
	ShowSpellSetChecked = true,
}

local DCS_ShowSpellCheck = CreateFrame("CheckButton", "DCS_ShowSpellCheck", DejaClassicStatsPanel, "InterfaceOptionsCheckButtonTemplate")
DCS_ShowSpellCheck:RegisterEvent("PLAYER_LOGIN")

DCS_ShowSpellCheck:ClearAllPoints()
	DCS_ShowSpellCheck:SetPoint("TOPLEFT", "dcsItemsPanelHeadersFS", 7, -75)
	DCS_ShowSpellCheck:SetScale(1)
	DCS_ShowSpellCheck.tooltipText = L["Show spell stats."] --Creates a tooltip on mouseover.
	_G[DCS_ShowSpellCheck:GetName() .. "Text"]:SetText(L["Spell Stats"])

DCS_ShowSpellCheck:SetScript("OnEvent", function(self, event, ...)
	ShowSpell = gdbprivate.gdb.gdbdefaults.DejaClassicStatsShowSpellChecked.ShowSpellSetChecked
	self:SetChecked(ShowSpell)
	if ShowSpell then
		DCSSpellEnhancementsStatsHeader:Show()
		DCSDefenseStatsHeader:SetPoint("TOPLEFT", "DCSSpellEnhancementsStatsHeader", "TOPLEFT", DCS_HeaderInsetX, spellYoffset)
	else
		DCSSpellEnhancementsStatsHeader:Hide()
		DCSDefenseStatsHeader:SetPoint("TOPLEFT", "DCSSpellEnhancementsStatsHeader", "TOPLEFT")
	end
	DCSHeaderYOffsets()
	DCS_CREATE_STATS()
	DCS_SET_STATS_TEXT()
end)

DCS_ShowSpellCheck:SetScript("OnClick", function(self)
	ShowSpell = not ShowSpell
	if ShowSpell then
		DCSSpellEnhancementsStatsHeader:Show()
		DCSDefenseStatsHeader:SetPoint("TOPLEFT", "DCSSpellEnhancementsStatsHeader", "TOPLEFT", DCS_HeaderInsetX, spellYoffset)
	else
		DCSSpellEnhancementsStatsHeader:Hide()
		DCSDefenseStatsHeader:SetPoint("TOPLEFT", "DCSSpellEnhancementsStatsHeader", "TOPLEFT")
	end
	DCS_CREATE_STATS()
	DCS_SET_STATS_TEXT()
	gdbprivate.gdb.gdbdefaults.DejaClassicStatsShowSpellChecked.ShowSpellSetChecked = ShowSpell
	DCSHeaderYOffsets()
end)

gdbprivate.gdbdefaults.gdbdefaults.DejaClassicStatsShowDefenseChecked = {
	ShowDefenseSetChecked = true,
}

local DCS_ShowDefenseCheck = CreateFrame("CheckButton", "DCS_ShowDefenseCheck", DejaClassicStatsPanel, "InterfaceOptionsCheckButtonTemplate")
DCS_ShowDefenseCheck:RegisterEvent("PLAYER_LOGIN")

DCS_ShowDefenseCheck:ClearAllPoints()
	DCS_ShowDefenseCheck:SetPoint("TOPLEFT", "dcsItemsPanelHeadersFS", 7, -95)
	DCS_ShowDefenseCheck:SetScale(1)
	DCS_ShowDefenseCheck.tooltipText = L["Show defense stats."] --Creates a tooltip on mouseover.
	_G[DCS_ShowDefenseCheck:GetName() .. "Text"]:SetText(L["Defense Stats"])

DCS_ShowDefenseCheck:SetScript("OnEvent", function(self, event, ...)
	ShowDefense = gdbprivate.gdb.gdbdefaults.DejaClassicStatsShowDefenseChecked.ShowDefenseSetChecked
	self:SetChecked(ShowDefense)
	if ShowDefense then
		DCSDefenseStatsHeader:Show()
	else
		DCSDefenseStatsHeader:Hide()
	end
	DCSHeaderYOffsets()
	DCS_CREATE_STATS()
	DCS_SET_STATS_TEXT()
	DCS_SetResistances()
end)

DCS_ShowDefenseCheck:SetScript("OnClick", function(self)
	ShowDefense = not ShowDefense
	if ShowDefense then
		DCSDefenseStatsHeader:Show()
	else
		DCSDefenseStatsHeader:Hide()
	end
	DCS_CREATE_STATS()
	DCS_SET_STATS_TEXT()
	DCS_SetResistances()
	gdbprivate.gdb.gdbdefaults.DejaClassicStatsShowDefenseChecked.ShowDefenseSetChecked = ShowDefense
	DCSHeaderYOffsets()
end)

--------------------------------
--Show Character Frame Button --
--------------------------------
local DCSShowCharacterFrameButton = CreateFrame("Button", "DCSShowCharacterFrameButton", DejaClassicStatsPanel, "UIPanelButtonTemplate")
DCSShowCharacterFrameButton:RegisterEvent("PLAYER_LOGIN")

DCSShowCharacterFrameButton:ClearAllPoints()
DCSShowCharacterFrameButton:SetPoint("TOP", 0, -15)
DCSShowCharacterFrameButton:SetScale(0.80)
DCSShowCharacterFrameButton:SetWidth(showCharWidth)
DCSShowCharacterFrameButton:SetHeight(30)
_G[DCSShowCharacterFrameButton:GetName() .. "Text"]:SetText(L["Show Character Frame"])

CharacterFrame:HookScript("OnShow", function(self)
	_G[DCSShowCharacterFrameButton:GetName() .. "Text"]:SetText(L["Hide Character Frame"])
end)

CharacterFrame:HookScript("OnHide", function(self)
	_G[DCSShowCharacterFrameButton:GetName() .. "Text"]:SetText(L["Show Character Frame"])
end)

DCSShowCharacterFrameButton:SetScript("OnClick", function(self, button, down)
	if CharacterFrame:IsShown() then
		CharacterFrame:Hide()
	else
		CharacterFrame:Show()
	end
end)
