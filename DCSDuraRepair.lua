local _, namespace = ... 	--localization
local L = namespace.L 				--localization

local _, addon = ...
addon.duraMean = 0

local _, gdbprivate = ...

local ipairs = ipairs
local DCS_CharacterShirtSlot = CharacterShirtSlot
local getItemQualityColor = GetItemQualityColor

-- ---------------------------
-- -- DCS Durability Frames --
-- ---------------------------

local DCSITEM_SLOT_FRAMES = {
	CharacterHeadSlot,CharacterNeckSlot,CharacterShoulderSlot,CharacterBackSlot,CharacterChestSlot,CharacterWristSlot,
	CharacterHandsSlot,CharacterWaistSlot,CharacterLegsSlot,CharacterFeetSlot,
	CharacterFinger0Slot,CharacterFinger1Slot,CharacterTrinket0Slot,CharacterTrinket1Slot,
	CharacterMainHandSlot,CharacterSecondaryHandSlot,CharacterRangedSlot,
}

local DCSITEM_SLOT_FRAMES_RIGHT = {
	[CharacterHeadSlot]={},[CharacterShoulderSlot]={},[CharacterBackSlot]={},[CharacterChestSlot]={},[CharacterWristSlot]={},
}

local DCSITEM_SLOT_NECK_BACK_SHIRT = {
	[CharacterNeckSlot]={},[CharacterBackSlot]={},[DCS_CharacterShirtSlot]={},
}

local DCSITEM_TWO_HANDED_WEAPONS = {
	"Bows","Crossbows","Guns","Fishing Poles","Polearms","Staves","Two-Handed Axes","Two-Handed Maces","Two-Handed Swords",
}

--local duraMean
local duraTotal
local duraMaxTotal
local duraFinite = 0

--------------------
-- Create Objects --
--------------------
local duraMeanFS = DCS_CharacterShirtSlot:CreateFontString("FontString","OVERLAY","GameTooltipText") --text for average durability on shirt
	duraMeanFS:SetPoint("CENTER",DCS_CharacterShirtSlot,"CENTER",1,-2) --poisiton will be influenced by DCS_Set_Dura_Item_Positions()
	duraMeanFS:SetFont("Fonts\\FRIZQT__.TTF", 15, "THINOUTLINE")
	duraMeanFS:SetFormattedText("")

local duraMeanTexture = DCS_CharacterShirtSlot:CreateTexture(nil,"ARTWORK") --bar for average durability on shirt

local duraDurabilityFrameFS = DurabilityFrame:CreateFontString("FontString","OVERLAY","GameTooltipText")
	duraDurabilityFrameFS:SetPoint("CENTER",DurabilityFrame,"CENTER",0,0)
	duraDurabilityFrameFS:SetFont("Fonts\\FRIZQT__.TTF", 16, "THINOUTLINE")
	duraDurabilityFrameFS:SetFormattedText("")

local function DCS_SetRunes()
	local ShowRunes = gdbprivate.gdb.gdbdefaults.DejaClassicStatsShowRunes.ShowRunesChecked
	for _, v in ipairs(DCSITEM_SLOT_FRAMES) do
		if ShowRunes then
			if v.subicon then
				v.subicon:SetSize(38,38)
				v.subicon:SetAlpha(0.77)
				if DCSITEM_SLOT_FRAMES_RIGHT[v] then

					v.subicon:ClearAllPoints()
					v.subicon:SetPoint("LEFT",v,"RIGHT",7, 0)
				else
					v.subicon:ClearAllPoints()
					v.subicon:SetPoint("RIGHT",v,"LEFT",-7, 0)
				end
			end
		else
			if v.subicon then
				v.subicon:SetSize(16,16)
				v.subicon:SetAlpha(1)
				v.subicon:ClearAllPoints()
				v.subicon:SetPoint("TOPRIGHT",v,"TOPRIGHT",0, 0)
			end
		end
	end
end

for _, v in ipairs(DCSITEM_SLOT_FRAMES) do
	v.duratexture = v:CreateTexture(nil,"ARTWORK")

	v.durability = v:CreateFontString("FontString","OVERLAY","GameTooltipText")
	v.durability:SetFormattedText("")

	v.itemrepair = v:CreateFontString("FontString","OVERLAY","GameTooltipText")
	v.itemrepair:SetFormattedText("")

	v.ilevel = v:CreateFontString("FontString","OVERLAY","GameTooltipText")
	v.ilevel:SetFormattedText("")

	v.enchant = v:CreateFontString("FontString","OVERLAY","GameTooltipText")
	v.enchant:SetFormattedText("")

	v.rune = v:CreateFontString("FontString","OVERLAY","GameTooltipText")
	v.rune:SetFormattedText("")

	v.itemcolor = v:CreateTexture(nil,"ARTWORK")
	v.itemcolor:SetAllPoints(v)

	v.ItemFrameOutlineTexture = v:CreateTexture(nil,"OVERLAY",nil)
	v.ItemFrameOutlineTexture:SetPoint("TOPLEFT", v, "TOPLEFT", -2, 2);
	v.ItemFrameOutlineTexture:SetPoint("BOTTOMRIGHT", v, "BOTTOMRIGHT", 2, -2);
	v.ItemFrameOutlineTexture:SetTexture("Interface\\Addons\\DejaClassicStats\\DCSArt\\WhiteIconFrame.blp")
	v.ItemFrameOutlineTexture:SetVertexColor(0, 0, 0, 0);

	v.ItemFramehighlightTexture = v:CreateTexture(nil, "HIGHLIGHT",nil)
	v.ItemFramehighlightTexture:SetPoint("TOPLEFT", v, "TOPLEFT", -2, 2);
	v.ItemFramehighlightTexture:SetPoint("BOTTOMRIGHT", v, "BOTTOMRIGHT", 2, -2);
	v.ItemFramehighlightTexture:SetTexture("Interface\\COMMON\\WhiteIconFrame.blp")
	v.ItemFramehighlightTexture:SetVertexColor(0, 0, 0, 0);
end

local function DCS_Set_Item_Quality_Color_Outlines()
	for _, v in ipairs(DCSITEM_SLOT_FRAMES) do
		local itemLink = GetInventoryItemLink("player", v:GetID())
		if itemLink then
			local qualityBordersChecked = gdbprivate.gdb.gdbdefaults.DejaClassicStatsItemQualityBorders.ItemQualityBordersChecked
			local qualityBordersAlpha
			if qualityBordersChecked then
				qualityBordersAlpha = gdbprivate.gdb.gdbdefaults.QCOA_SetSliderValue.QCOA_SliderValue
			else
				qualityBordersAlpha = 0
			end
			local item = Item:CreateFromEquipmentSlot(v:GetID())
			local itemName, itemLink, itemQuality = GetItemInfo(itemLink)
			local r, g, b, hex = getItemQualityColor(itemQuality)
			v.ItemFrameOutlineTexture:SetVertexColor(r, g, b, qualityBordersAlpha);
			v.ItemFramehighlightTexture:SetVertexColor(r, g, b, qualityBordersAlpha);
		else
			v.ItemFrameOutlineTexture:SetVertexColor(0, 0, 0, 0);
			v.ItemFramehighlightTexture:SetVertexColor(0, 0, 0, 0);
		end
	end
end

gdbprivate.gdbdefaults.gdbdefaults.QCOA_SetSliderValue = {
	QCOA_SliderValue = 0.75,
}

-- Quality Color Outlines Alpha Slider:
local QCOA_Slider = CreateFrame("Slider", "QCOA_Slider", DejaClassicStatsPanel, "DCS_UISliderTemplateWithLabels")
	QCOA_Slider:RegisterEvent("PLAYER_LOGIN")
	QCOA_Slider:SetPoint("TOPLEFT", DejaClassicStatsPanel, "TOP", -25, -265)
	QCOA_Slider:SetWidth(200)
	QCOA_Slider:SetHeight(10)
	QCOA_Slider:SetOrientation('HORIZONTAL')
	QCOA_Slider:SetMinMaxValues(0.25, 1.0)
	QCOA_Slider.minValue, QCOA_Slider.maxValue = QCOA_Slider:GetMinMaxValues()
	QCOA_Slider:SetValueStep(0.05)
	QCOA_Slider:SetObeyStepOnDrag(true)

	QCOA_Slider.tooltipText = "Set the intensity (alpha) of your equipped items' quality colored border glow in increments or decrements of 5. Default is 75." --Creates a tooltip on mouseover.

	QCOA_Slider.Low:SetText(QCOA_Slider.minValue); --Sets the left-side slider text (default is "Low").
	QCOA_Slider.High:SetText(QCOA_Slider.maxValue); --Sets the right-side slider text (default is "High").

	QCOA_Slider:Show()

	QCOA_Slider:SetScript("OnEvent", function(self, event, arg1)
		if event == "PLAYER_LOGIN" then
		local slideValue = gdbprivate.gdb.gdbdefaults.QCOA_SetSliderValue.QCOA_SliderValue
			self:SetValue(slideValue)
			getglobal(QCOA_Slider:GetName() .. 'Text'):SetFormattedText(L["Item Quality Glow"].." = (%.2f)", (slideValue)); --Sets the "title" text (top-centre of slider).
		end
	end)

	QCOA_Slider:SetScript("OnValueChanged", function(self, value)
	local slideValue = QCOA_Slider:GetValue()
		QCOA_Slider.Text:SetFormattedText(L["Item Quality Glow"].." = (%.2f)", (slideValue)); --Sets the "title" text (top-centre of slider).
		gdbprivate.gdb.gdbdefaults.QCOA_SetSliderValue.QCOA_SliderValue = slideValue
		if PaperDollFrame:IsVisible() then
			DCS_Set_Item_Quality_Color_Outlines() --Here to update on the events when PaperDoll is open.
		end
	end)


local showavgdur --display of average durability on shirt
local showtextures --display of durability textures
local showdura --display of durability percentage on items
local showrepair --display of item repair cost
local showitemlevel --display of item's item level
local showenchant --display of item's enchant
local simpleitemcolor -- blacking out of item textures for easier seeing of info
local darkeritemcolor -- darkening but not blacking out of item textures for easier seeing of info
local otherinfoplacement --alternate display position of item repair cost, durability, and ilvl

local function puttop(fontstring,slot,size)
	if otherinfoplacement then
		if DCSITEM_SLOT_FRAMES_RIGHT[slot] or DCSITEM_SLOT_NECK_BACK_SHIRT[slot] then
			fontstring:SetPoint("LEFT",slot,"RIGHT",6,0)
		else
			fontstring:SetPoint("TOPRIGHT",slot,"TOPLEFT",-6,-2)
		end
		if (slot == CharacterMainHandSlot) then
			fontstring:ClearAllPoints()
			fontstring:SetPoint("RIGHT",slot,"LEFT",-2,-2)
		end
		if (slot == CharacterSecondaryHandSlot) then
			fontstring:ClearAllPoints()
			fontstring:SetPoint("BOTTOMLEFT",slot,"TOPLEFT",-6,15)
		end
		if (slot == CharacterRangedSlot) then
			fontstring:ClearAllPoints()
			fontstring:SetPoint("BOTTOMLEFT",slot,"TOPRIGHT",4,-8)
		end
	else
		fontstring:SetPoint("TOP",slot,"TOP",3,-2)
	end
	fontstring:SetFont("Fonts\\FRIZQT__.TTF", size, "THINOUTLINE")
end

local function putcenter(fontstring,slot,size)
	if otherinfoplacement then
		if DCSITEM_SLOT_FRAMES_RIGHT[slot] or DCSITEM_SLOT_NECK_BACK_SHIRT[slot] then
			fontstring:SetPoint("LEFT",slot,"RIGHT",10,-2)
		else
			fontstring:SetPoint("RIGHT",slot,"LEFT",-10,-2)
		end
		if (slot == CharacterMainHandSlot) then
			fontstring:ClearAllPoints()
			fontstring:SetPoint("RIGHT",slot,"LEFT",-2,-6)
		end
		if (slot == CharacterSecondaryHandSlot) then
			fontstring:ClearAllPoints()
			fontstring:SetPoint("CENTER",slot,"CENTER",1,-2)
		end
		if (slot == CharacterRangedSlot) then
			fontstring:ClearAllPoints()
			fontstring:SetPoint("TOPLEFT",slot,"BOTTOMRIGHT",8,0)
		end
	else
		fontstring:SetPoint("CENTER",slot,"CENTER",1,-2)
	end
	fontstring:SetFont("Fonts\\FRIZQT__.TTF", size, "THINOUTLINE")
end

local function putbottom(fontstring,slot,size)
	if otherinfoplacement then
		if DCSITEM_SLOT_FRAMES_RIGHT[slot] or DCSITEM_SLOT_NECK_BACK_SHIRT[slot] then
			fontstring:SetPoint("BOTTOMLEFT",slot,"BOTTOMRIGHT",6,2)
		else
			fontstring:SetPoint("RIGHT",slot,"LEFT",-6,0)
		end
		if (slot == CharacterMainHandSlot) then
			fontstring:ClearAllPoints()
			fontstring:SetPoint("BOTTOMRIGHT",slot,"BOTTOMLEFT",-2,0)
		end
		if (slot == CharacterRangedSlot) then
			fontstring:ClearAllPoints()
			fontstring:SetPoint("BOTTOMLEFT",slot,"BOTTOMRIGHT",4,-2)
		end
		if (slot == CharacterSecondaryHandSlot) then
			fontstring:ClearAllPoints()
			fontstring:SetPoint("BOTTOMRIGHT",slot,"TOPRIGHT",20,15)
		end
	else
		fontstring:SetPoint("BOTTOM",slot,"BOTTOM",1,0)
	end
	fontstring:SetFont("Fonts\\FRIZQT__.TTF", size, "THINOUTLINE")
end

local function putothercenter(fontstring,slot,size)
	if otherinfoplacement then
		if DCSITEM_SLOT_FRAMES_RIGHT[slot] or DCSITEM_SLOT_NECK_BACK_SHIRT[slot] then
			fontstring:SetPoint("LEFT",slot,"RIGHT",6,-4)
		else
			fontstring:SetPoint("TOPRIGHT",slot,"TOPLEFT",-6,-9)
		end
		if (slot == CharacterMainHandSlot) then
			fontstring:ClearAllPoints()
			fontstring:SetPoint("TOPRIGHT",slot,"TOPRIGHT",8,16)
		end
		if (slot == CharacterSecondaryHandSlot) then
			fontstring:ClearAllPoints()
			fontstring:SetPoint("TOPRIGHT",slot,"TOPRIGHT",8,16)
		end
		if (slot == CharacterRangedSlot) then
			fontstring:ClearAllPoints()
			fontstring:SetPoint("TOPRIGHT",slot,"TOPRIGHT",8,16)
		end
	else
		fontstring:SetPoint("TOP",slot,"TOP",3,-2)
	end
	fontstring:SetFont("Fonts\\FRIZQT__.TTF", size, "THINOUTLINE")
end

function putenchant(fontstring,slot,size)
	if showenchant then
		ShowDefaultStats = gdbprivate.gdb.gdbdefaults.DejaClassicStatsShowDefaultStats.ShowDefaultStatsChecked
		if DCSITEM_SLOT_FRAMES_RIGHT[slot] or DCSITEM_SLOT_NECK_BACK_SHIRT[slot] then
			fontstring:SetPoint("TOPLEFT",slot,"TOPRIGHT",6,-2)
		else
			fontstring:SetPoint("BOTTOMRIGHT",slot,"BOTTOMLEFT",-6,2)
		end
		if (slot == CharacterMainHandSlot) then
			fontstring:ClearAllPoints()
			fontstring:SetPoint("TOPRIGHT",slot,"BOTTOMRIGHT",4,4)
		end
		if (slot == CharacterRangedSlot) then
			fontstring:ClearAllPoints()
			fontstring:SetPoint("TOPLEFT",slot,"BOTTOMLEFT",-4,4)
		end
		if ShowDefaultStats then
			if (slot == CharacterSecondaryHandSlot) then
				fontstring:ClearAllPoints()
				fontstring:SetPoint("BOTTOMLEFT",slot,"TOPLEFT",-6,2)
			end
			if (slot == CharacterWristSlot) then
				fontstring:SetPoint("TOPLEFT",slot,"TOPRIGHT",6,-10)
			end
		else
			if (slot == CharacterSecondaryHandSlot) then
				fontstring:ClearAllPoints()
				fontstring:SetPoint("BOTTOMLEFT",slot,"TOPLEFT",-6,6)
			end
		end
	end
	fontstring:SetFont("Fonts\\FRIZQT__.TTF", size, "THINOUTLINE")
end

local function putilevel(fontstring,slot,size)
	fontstring:SetPoint("CENTER",slot,"CENTER",1,-2)
	fontstring:SetFont("Fonts\\FRIZQT__.TTF", size, "THINOUTLINE")
end

local function DCS_Set_Dura_Item_Positions()
	--It encompasses item repair, durability and, indirectly, durability bars.
	--making it work with local to DCSDuraRepair.lua variable
	local showdura = gdbprivate.gdb.gdbdefaults.DejaClassicStatsShowDuraChecked.ShowDuraSetChecked
	local showrepair = gdbprivate.gdb.gdbdefaults.DejaClassicStatsShowItemRepairChecked.ShowItemRepairSetChecked
	local showenchant = gdbprivate.gdb.gdbdefaults.DejaClassicStatsShowEnchantChecked.ShowEnchantSetChecked
	local abbrevEnchants = gdbprivate.gdb.gdbdefaults.DejaClassicStatsAbbrevEnchantsChecked.AbbrevEnchantsSetChecked
	local otherinfoplacement = gdbprivate.gdb.gdbdefaults.DejaClassicStatsAlternateInfoPlacement.AlternateInfoPlacementChecked
	--print("called DCS_Set_Dura_Item_Positions") --debug for later
	duraMeanFS:ClearAllPoints()

	putcenter(duraMeanFS,DCS_CharacterShirtSlot,15)
	for _, v in ipairs(DCSITEM_SLOT_FRAMES) do
		v.durability:ClearAllPoints()
		v.itemrepair:ClearAllPoints()
		v.ilevel:ClearAllPoints()
		v.enchant:ClearAllPoints()
		if showitemlevel then
			if showdura then
				if showrepair then
					puttop(v.durability,v,11)
					putbottom(v.itemrepair,v,11)
				else --not showrepair
					if otherinfoplacement then
						putothercenter(v.durability,v,15)
					else
						puttop(v.durability,v,11)
					end
				end
			else --not showdura
				if showrepair then
					if otherinfoplacement then
						putothercenter(v.itemrepair,v,15)
					else
						putbottom(v.itemrepair,v,11)
					end
				end
			end
			if otherinfoplacement then
				putilevel(v.ilevel,v,16)
			else
				if not (showdura or showrepair) then
					putilevel(v.ilevel,v,16)
				else
					putilevel(v.ilevel,v,14)
				end
			end
		else
			if showdura then
				if showrepair then
					puttop(v.durability,v,11)
					putbottom(v.itemrepair,v,11)
				else --not showrepair
					if otherinfoplacement then
						putothercenter(v.durability,v,15)
					else
						putcenter(v.durability,v,15)
					end
				end
			else --not showdura
				if showrepair then
					if otherinfoplacement then
						putothercenter(v.itemrepair,v,15)
					else
						putcenter(v.itemrepair,v,15)
					end
				end
			end
		end
		if showenchant then
			putenchant(v.enchant,v,11)
		end
	end
end


---------------------------------
-- Durability Mean Calculation --
---------------------------------
function DCS_Mean_DurabilityCalc()
	addon.duraMean = 0
	duraTotal = 0
	duraMaxTotal = 0
	for _, v in ipairs(DCSITEM_SLOT_FRAMES) do
		local slotId = v:GetID()
		local durCur, durMax = GetInventoryItemDurability(slotId)
		-- --------------------------
		-- -- Mean Durability Calc --
		-- --------------------------
		if durCur == nil then durCur = 0 end
		if durMax == nil then durMax = 0 end

		duraTotal = duraTotal + durCur
		duraMaxTotal = duraMaxTotal + durMax
	end
	if duraMaxTotal == 0 then
		duraMaxTotal = 1
		duraTotal = 1 --if nothing to break then durability should be 100%
	end --puting outside of for loop
	addon.duraMean = ((duraTotal/duraMaxTotal)*100)
end

-----------------------------------
-- Durability Frame Mean Display --
-----------------------------------
local function DCS_Durability_Frame_Mean_Display()
	--DCS_Mean_DurabilityCalc() -- DCS_Mean_DurabilityCalc called already before
	duraDurabilityFrameFS:SetFormattedText("%.0f%%", addon.duraMean)
	duraDurabilityFrameFS:Show()
--	print(addon.duraMean)
	if addon.duraMean == 100 then --If mean is 100 hide text % display
		duraDurabilityFrameFS:Hide()
	elseif addon.duraMean >= 80 then --If mean is 80% or greater color the text off-white.
		duraDurabilityFrameFS:SetTextColor(0.753, 0.753, 0.753)
	elseif addon.duraMean > 66 then --If mean is 66% or greater then color the text green.
		duraDurabilityFrameFS:SetTextColor(0, 1, 0)
	elseif addon.duraMean > 33 then --If mean is 33% or greater then color the text yellow.
		duraDurabilityFrameFS:SetTextColor(1, 1, 0)
	elseif addon.duraMean >= 0 then --If mean is 0% or greater then color the text red. Is this check needed?
		duraDurabilityFrameFS:SetTextColor(1, 0, 0)
	end
end

-----------------------------------
-- Mean Durability Shirt Display --
-----------------------------------
local function DCS_Mean_Durability()
	DCS_Mean_DurabilityCalc()
    if addon.duraMean < 10 then
		duraMeanFS:SetTextColor(1, 0, 0)
	elseif addon.duraMean < 33 then
		duraMeanFS:SetTextColor(1, 0, 0)
	elseif addon.duraMean < 66 then
	    duraMeanFS:SetTextColor(1, 1, 0)
	elseif addon.duraMean < 80 then
		duraMeanFS:SetTextColor(0, 1, 0)
	elseif addon.duraMean < 100 then
		duraMeanFS:SetTextColor(0.753, 0.753, 0.753)
	end
	if DurabilityFrame:IsVisible() then
		DCS_Durability_Frame_Mean_Display()
	end
end

----------------------------
-- Item Durability Colors --
----------------------------
local function DCS_Item_DurabilityTop()
	for _, v in ipairs(DCSITEM_SLOT_FRAMES) do
		local slotId = v:GetID()
		local durCur, durMax = GetInventoryItemDurability(slotId)
		--if durCur == nil or durMax == nil then
		--	v.duratexture:SetColorTexture(0, 0, 0, 0)
		--	v.durability:SetFormattedText("")
		--elseif ( durCur == durMax ) then
		if ( durCur == durMax ) then
			--v.duratexture:SetColorTexture(0, 0, 0, 0) --moving texture stuff to textures
			v.durability:SetFormattedText("")
		else --if ( durCur ~= durMax ) then -- no need to check, can remain as comment for easier understanding
			duraFinite = ((durCur/durMax)*100)
			--print(duraFinite)
		    v.durability:SetFormattedText("%.0f%%", duraFinite)
			--if duraFinite == 100 then --this should be covered by durCur == durMax
			--	v.duratexture:SetColorTexture(0,  0, 0, 0)
			--	v.durability:SetTextColor(0, 0, 0, 0)
			--	print ("what is this")
			--elseif duraFinite > 66 then
			if duraFinite > 66 then
				--v.duratexture:SetColorTexture(0, 1, 0)
				v.durability:SetTextColor(0, 1, 0)
			elseif duraFinite > 33 then
				--v.duratexture:SetColorTexture(1, 1, 0)
				v.durability:SetTextColor(1, 1, 0)
			elseif duraFinite > 10 then
				--v.duratexture:SetColorTexture(1, 0, 0)
				v.durability:SetTextColor(1, 0, 0)
			else --if duraFinite <= 10 then -- no need to check, can remain as comment for easier understanding
				--v.duratexture:SetAllPoints(v) -Removed so green boxes do not appear when durability is at zero.
				--v.duratexture:SetColorTexture(1, 0, 0, 0.10)
				v.durability:SetTextColor(1, 0, 0)
			end
		end
		--DCS_Mean_DurabilityCalc() -- moving outside for loop
	end
	--DCS_Mean_DurabilityCalc() -- seems like it gets called even before this
end

gdbprivate.gdbdefaults.gdbdefaults.DejaClassicStatsShowDuraChecked = {
	ShowDuraSetChecked = true,
}

local DCS_ShowDuraCheck = CreateFrame("CheckButton", "DCS_ShowDuraCheck", DejaClassicStatsPanel, "InterfaceOptionsCheckButtonTemplate")
	DCS_ShowDuraCheck:RegisterEvent("PLAYER_LOGIN")
    DCS_ShowDuraCheck:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
	DCS_ShowDuraCheck:RegisterEvent("PLAYER_EQUIPMENT_CHANGED") --seems like UPDATE_INVENTORY_DURABILITY doesn't get triggered by equipping an item with the same name
	DCS_ShowDuraCheck:ClearAllPoints()
	DCS_ShowDuraCheck:SetPoint("TOPLEFT", "dcsItemsPanelCategoryFS", 7, -75)
	DCS_ShowDuraCheck:SetScale(1)
	DCS_ShowDuraCheck.tooltipText = L["Displays each equipped item's durability."] --Creates a tooltip on mouseover.
	_G[DCS_ShowDuraCheck:GetName() .. "Text"]:SetText(L["Item Durability"])

local event
DCS_ShowDuraCheck:SetScript("OnEvent", function(self, event, ...)
	if event == "PLAYER_LOGIN" then
		showdura = gdbprivate.gdb.gdbdefaults.DejaClassicStatsShowDuraChecked.ShowDuraSetChecked
		self:SetChecked(showdura)
		DCS_Set_Dura_Item_Positions()
	end
	if PaperDollFrame:IsVisible() then
		if showdura then
			DCS_Item_DurabilityTop()
		else
			for _, v in ipairs(DCSITEM_SLOT_FRAMES) do
				v.durability:SetFormattedText("")
			end
		end
		local checked = gdbprivate.gdb.gdbdefaults.DejaClassicStatsShowDuraChecked.ShowDuraSetChecked
		self:SetChecked(checked)
		DCS_Set_Dura_Item_Positions()
		if checked then
			DCS_Item_DurabilityTop()
		else
			for _, v in ipairs(DCSITEM_SLOT_FRAMES) do
				v.durability:SetFormattedText("")
			end
		end
	end
end)

DCS_ShowDuraCheck:SetScript("OnClick", function(self)
	showdura = not showdura
	gdbprivate.gdb.gdbdefaults.DejaClassicStatsShowDuraChecked.ShowDuraSetChecked = showdura
	DCS_Set_Dura_Item_Positions() --same line irrespectfully of the condtition
	if showdura then
		DCS_Item_DurabilityTop()
	else
		for _, v in ipairs(DCSITEM_SLOT_FRAMES) do
			v.durability:SetFormattedText("")
		end
	end
	local checked = self:GetChecked()
	gdbprivate.gdb.gdbdefaults.DejaClassicStatsShowDuraChecked.ShowDuraSetChecked = checked
	DCS_Set_Dura_Item_Positions() --same line irrespectfully of the condtition
	if checked then
		DCS_Item_DurabilityTop()
	else
		for _, v in ipairs(DCSITEM_SLOT_FRAMES) do
			v.durability:SetFormattedText("")
		end
	end
end)

--------------------------------------
-- Durability Bar Textures Creation --
--------------------------------------
local function DCS_Durability_Bar_Textures()
	-- I see really similar loop in DCS_Item_DurabilityTop(), can't they be merged (of course, need to check whether they get called within the same condition)
	duraTotal = 0 --calculation of average for shirt bar is also here
	duraMaxTotal = 0
	for _, v in ipairs(DCSITEM_SLOT_FRAMES) do
		local slotId = v:GetID()
		local durCur, durMax = GetInventoryItemDurability(slotId)
		if durCur == nil then durCur = 0 end
		if durMax == nil then durMax = 0 end
		duraTotal = duraTotal + durCur
		duraMaxTotal = duraMaxTotal + durMax
		if ( durCur == durMax ) then
			v.duratexture:SetColorTexture(0, 0, 0, 0)
		else --if ( durCur ~= durMax ) then -- no need to check, can remain as comment for easier understanding
			duraFinite = durCur/durMax
            if duraFinite > 0.66 then
	            v.duratexture:SetColorTexture(0, 1, 0)
		    elseif duraFinite > 0.33 then
				v.duratexture:SetColorTexture(1, 1, 0)
			elseif duraFinite > 0.10 then
				v.duratexture:SetColorTexture(1, 0, 0)
			else --if duraFinite <= 0.10 then -- no need to check, can remain as comment for easier understanding
				v.duratexture:SetColorTexture(1, 0, 0, 0.10)
			end
		    if DCSITEM_SLOT_FRAMES_RIGHT[v] then
		        v.duratexture:SetPoint("BOTTOMLEFT",v,"BOTTOMRIGHT",1,3)
			    v.duratexture:SetSize(4, (31*duraFinite))
			else
                v.duratexture:SetPoint("BOTTOMRIGHT",v,"BOTTOMLEFT",-2,3)
				v.duratexture:SetSize(3, (31*duraFinite))
			end
		    v.duratexture:Show()
		end
	end
	if duraMaxTotal == 0 then
		duraMaxTotal = 1
		duraTotal = 1 --if nothing to break then durability should be 100%
	end
	local duraMean = duraTotal/duraMaxTotal
	duraMeanTexture:SetSize(4, 31*duraMean)
	if duraMean == 1 then
		duraMeanTexture:SetColorTexture(0, 0, 0, 0)
	elseif duraMean < 0.10 then
		--duraMeanTexture:SetColorTexture(1, 0, 0)
		duraMeanTexture:SetColorTexture(1, 0, 0, 0.15)
	elseif duraMean < 0.33 then
		duraMeanTexture:SetColorTexture(1, 0, 0)
	elseif duraMean < 0.66 then
		duraMeanTexture:SetColorTexture(1, 1, 0)
	elseif duraMean < 0.80 then
		duraMeanTexture:SetColorTexture(0, 1, 0)
	else --if duraMean < 1 then -- no need to check, can remain as comment for easier understanding
		duraMeanTexture:SetColorTexture(0.753, 0.753, 0.753)
	end
	duraMeanTexture:ClearAllPoints()
	if duraMean > 0.10 then
		duraMeanTexture:SetPoint("BOTTOMLEFT",DCS_CharacterShirtSlot,"BOTTOMRIGHT",1,3)
	else --if duraMean <= 0.10 then -- no need to check, can remain as comment for easier understanding
		duraMeanTexture:SetAllPoints(DCS_CharacterShirtSlot)
	end
end

gdbprivate.gdbdefaults.gdbdefaults.DejaClassicStatsShowDuraTextureChecked = {
	ShowDuraTextureSetChecked = true,
}

local DCS_ShowDuraTextureCheck = CreateFrame("CheckButton", "DCS_ShowDuraTextureCheck", DejaClassicStatsPanel, "InterfaceOptionsCheckButtonTemplate")
	DCS_ShowDuraTextureCheck:RegisterEvent("PLAYER_LOGIN")
    DCS_ShowDuraTextureCheck:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
	DCS_ShowDuraTextureCheck:RegisterEvent("PLAYER_EQUIPMENT_CHANGED") --seems like UPDATE_INVENTORY_DURABILITY doesn't get triggered by equipping an item with the same name
	DCS_ShowDuraTextureCheck:ClearAllPoints()
	DCS_ShowDuraTextureCheck:SetPoint("TOPLEFT", "dcsItemsPanelCategoryFS", 7, -35)
	DCS_ShowDuraTextureCheck:SetScale(1)
	DCS_ShowDuraTextureCheck.tooltipText = L["Displays a durability bar next to each item."] --Creates a tooltip on mouseover.
	_G[DCS_ShowDuraTextureCheck:GetName() .. "Text"]:SetText(L["Durability Bars"])

DCS_ShowDuraTextureCheck:SetScript("OnEvent", function(self, event, ...)
	if event == "PLAYER_LOGIN" then
		showtextures = gdbprivate.gdb.gdbdefaults.DejaClassicStatsShowDuraTextureChecked.ShowDuraTextureSetChecked
		self:SetChecked(showtextures)
	end
	--print("DCS_ShowDuraTextureCheck:SetScript(OnEvent)")
	if PaperDollFrame:IsVisible() then
		--print("PaperDollFrame:IsVisible()")
		if showtextures then
			--print("showtextures")
			DCS_Durability_Bar_Textures()
			--DCS_Mean_Durability() --average durability for bar near shirt should be in DCS_Durability_Bar_Textures()
			--DCS_Item_DurabilityTop() --all single item durability stuff should be in DCS_Durability_Bar_Textures()
			duraMeanTexture:Show()
		else
			for _, v in ipairs(DCSITEM_SLOT_FRAMES) do
				v.duratexture:Hide()
			end
			duraMeanTexture:Hide()
		end
		local checked = gdbprivate.gdb.gdbdefaults.DejaClassicStatsShowDuraTextureChecked.ShowDuraTextureSetChecked
		self:SetChecked(checked)
		if checked then
			DCS_Durability_Bar_Textures()
			DCS_Mean_Durability()
			DCS_Item_DurabilityTop()
			duraMeanTexture:Show()
		else
			for _, v in ipairs(DCSITEM_SLOT_FRAMES) do
				v.duratexture:Hide()
			end
			duraMeanTexture:Hide()
		end
	end
end)

DCS_ShowDuraTextureCheck:SetScript("OnClick", function(self)
	showtextures = not showtextures
	gdbprivate.gdb.gdbdefaults.DejaClassicStatsShowDuraTextureChecked.ShowDuraTextureSetChecked = showtextures
	if showtextures then
		DCS_Durability_Bar_Textures()
		--DCS_Mean_Durability() --average durability for bar near shirt should be in DCS_Durability_Bar_Textures()
		--DCS_Item_DurabilityTop() --all single item durability stuff should be in DCS_Durability_Bar_Textures()
		duraMeanTexture:Show()
	else
		for _, v in ipairs(DCSITEM_SLOT_FRAMES) do
			v.duratexture:Hide()
		end
		duraMeanTexture:Hide()
	end
	local checked = self:GetChecked()
	gdbprivate.gdb.gdbdefaults.DejaClassicStatsShowDuraTextureChecked.ShowDuraTextureSetChecked = checked
	if checked then
		DCS_Durability_Bar_Textures()
		DCS_Mean_Durability()
		DCS_Item_DurabilityTop()
		duraMeanTexture:Show()
	else
		for _, v in ipairs(DCSITEM_SLOT_FRAMES) do
			v.duratexture:Hide()
		end
		duraMeanTexture:Hide()
	end
end)

------------------------
-- Average Durability --
------------------------

gdbprivate.gdbdefaults.gdbdefaults.DejaClassicStatsShowAverageRepairChecked = {
	ShowAverageRepairSetChecked = true,
}

local DCS_ShowAverageDuraCheck = CreateFrame("CheckButton", "DCS_ShowAverageDuraCheck", DejaClassicStatsPanel, "InterfaceOptionsCheckButtonTemplate")
	DCS_ShowAverageDuraCheck:RegisterEvent("PLAYER_LOGIN")
    DCS_ShowAverageDuraCheck:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
	DCS_ShowAverageDuraCheck:RegisterEvent("PLAYER_EQUIPMENT_CHANGED") --seems like UPDATE_INVENTORY_DURABILITY doesn't get triggered by equipping an item with the same name
	DCS_ShowAverageDuraCheck:ClearAllPoints()
	DCS_ShowAverageDuraCheck:SetPoint("TOPLEFT", "dcsItemsPanelCategoryFS", 7, -55)
	DCS_ShowAverageDuraCheck:SetScale(1)
	DCS_ShowAverageDuraCheck.tooltipText = L["Displays average item durability on the character shirt slot and durability frames."] --Creates a tooltip on mouseover.
	_G[DCS_ShowAverageDuraCheck:GetName() .. "Text"]:SetText(L["Average Durability"])

	DCS_ShowAverageDuraCheck:SetScript("OnEvent", function(self, event, ...)
		if event == "PLAYER_LOGIN" then
			showavgdur = gdbprivate.gdb.gdbdefaults.DejaClassicStatsShowAverageRepairChecked.ShowAverageRepairSetChecked
			self:SetChecked(showavgdur)
		end
		--print(..., DurabilityFrame:IsVisible(),DurabilityFrame:IsShown())
		if showavgdur and (DurabilityFrame:IsVisible() or PaperDollFrame:IsVisible()) then
			DCS_Mean_Durability()
			if addon.duraMean == 100 then --check after calculation
				duraMeanFS:SetFormattedText("")
			else
				duraMeanFS:SetFormattedText("%.0f%%", addon.duraMean)
			end
		else
			duraMeanFS:SetFormattedText("")
			duraDurabilityFrameFS:Hide()
		end
	end)

	DCS_ShowAverageDuraCheck:SetScript("OnClick", function(self)
		showavgdur = not showavgdur
		gdbprivate.gdb.gdbdefaults.DejaClassicStatsShowAverageRepairChecked.ShowAverageRepairSetChecked = showavgdur
		if showavgdur then
			DCS_Mean_Durability()
			if addon.duraMean == 100 then --check after calculation
				duraMeanFS:SetFormattedText("")
			else
				duraMeanFS:SetFormattedText("%.0f%%", addon.duraMean)
			end
		else
			duraMeanFS:SetFormattedText("")
			duraDurabilityFrameFS:Hide()
		end
	end)

----------------------
-- Item Repair Cost --
----------------------
local function DCS_Item_RepairCostBottom()
	for _, v in ipairs(DCSITEM_SLOT_FRAMES) do
		local slotId = v:GetID()
		local scanTool = CreateFrame("GameTooltip")
			scanTool:ClearLines()
		local repairitemCost = select(3, scanTool:SetInventoryItem("player", slotId))
		if (repairitemCost<=0) then
			v.itemrepair:SetFormattedText("")
		elseif (repairitemCost>999999) then -- 99G 99s 99c
			v.itemrepair:SetTextColor(1, 0.843, 0)
			v.itemrepair:SetFormattedText("%.0fg", (repairitemCost/10000))
		elseif (repairitemCost>9999) then -- 99s 99c
			v.itemrepair:SetTextColor(1, 0.843, 0)
			v.itemrepair:SetFormattedText("%.2fg", (repairitemCost/10000))
		elseif (repairitemCost>99) then -- 99c
			v.itemrepair:SetTextColor(0.753, 0.753, 0.753)
			v.itemrepair:SetFormattedText("%.2fs", (repairitemCost/100))
		else
			v.itemrepair:SetTextColor(0.722, 0.451, 0.200)
			v.itemrepair:SetFormattedText("%.0fc", repairitemCost)
		end
	end
end


gdbprivate.gdbdefaults.gdbdefaults.DejaClassicStatsShowItemRepairChecked = {
	ShowItemRepairSetChecked = true,
}

local DCS_ShowItemRepairCheck = CreateFrame("CheckButton", "DCS_ShowItemRepairCheck", DejaClassicStatsPanel, "InterfaceOptionsCheckButtonTemplate")
	DCS_ShowItemRepairCheck:RegisterEvent("PLAYER_LOGIN")
	DCS_ShowItemRepairCheck:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
	DCS_ShowItemRepairCheck:RegisterEvent("PLAYER_EQUIPMENT_CHANGED") --seems like UPDATE_INVENTORY_DURABILITY doesn't get triggered by equipping an item with the same name
	DCS_ShowItemRepairCheck:RegisterEvent("MERCHANT_SHOW")
	DCS_ShowItemRepairCheck:RegisterEvent("MERCHANT_CLOSED") --without this event repair cost should remain unchanged from the last vendor
	DCS_ShowItemRepairCheck:ClearAllPoints()
	DCS_ShowItemRepairCheck:SetPoint("TOPLEFT", "dcsItemsPanelCategoryFS", 7, -95)
	DCS_ShowItemRepairCheck:SetScale(1)
	DCS_ShowItemRepairCheck.tooltipText = L["Displays each equipped item's repair cost."] --Creates a tooltip on mouseover.
	_G[DCS_ShowItemRepairCheck:GetName() .. "Text"]:SetText(L["Item Repair Cost"])

DCS_ShowItemRepairCheck:SetScript("OnEvent", function(self, event, ...)
	if event == "PLAYER_LOGIN" then
		-- print(self:GetChecked())
		showrepair = gdbprivate.gdb.gdbdefaults.DejaClassicStatsShowItemRepairChecked.ShowItemRepairSetChecked
		self:SetChecked(showrepair)
		DCS_Set_Dura_Item_Positions()
	end
	--print("want to recalculate repairs")
	if PaperDollFrame:IsVisible() then
		--print("recalculating repairs")
		if showrepair then
			DCS_Item_RepairCostBottom()
		else
			for _, v in ipairs(DCSITEM_SLOT_FRAMES) do
				v.itemrepair:SetFormattedText("")
			end
		end
		local checked = gdbprivate.gdb.gdbdefaults.DejaClassicStatsShowItemRepairChecked.ShowItemRepairSetChecked
		self:SetChecked(checked)
		DCS_Set_Dura_Item_Positions()
		if checked then
			DCS_Item_RepairCostBottom()
		else
			for _, v in ipairs(DCSITEM_SLOT_FRAMES) do
				v.itemrepair:SetFormattedText("")
			end
		end
	end
end)

DCS_ShowItemRepairCheck:SetScript("OnClick", function(self)
	showrepair = not showrepair
	gdbprivate.gdb.gdbdefaults.DejaClassicStatsShowItemRepairChecked.ShowItemRepairSetChecked = showrepair
	DCS_Set_Dura_Item_Positions()
	if showrepair then
		DCS_Item_RepairCostBottom()
	else
		for _, v in ipairs(DCSITEM_SLOT_FRAMES) do
			v.itemrepair:SetFormattedText("")
		end
	end
	local checked = self:GetChecked()
	gdbprivate.gdb.gdbdefaults.DejaClassicStatsShowItemRepairChecked.ShowItemRepairSetChecked = checked
	DCS_Set_Dura_Item_Positions()
	if checked then
		DCS_Item_RepairCostBottom()
	else
		for _, v in ipairs(DCSITEM_SLOT_FRAMES) do
			v.itemrepair:SetFormattedText("")
		end
	end
end)

local function attempt_ilvl(v,attempts)
	if attempts > 0 then
		local item = Item:CreateFromEquipmentSlot(v:GetID())
		local value = item:GetCurrentItemLevel()
		if value then --ilvl of nil probably indicates that there's no tem in that slot
			if value > 0 then --ilvl of 0 probably indicates that item is not fully loaded
				local quality = item:GetItemQuality()
				local color = ITEM_QUALITY_COLORS[quality] --color.hex is an escape sequence string, not digits like r,g,b are; Example Return: "|cff00c0ffDejaClassicStats" with only the opening not the trailing close, "|r"
				v.ilevel:SetTextColor(color.r, color.g, color.b)
				v.ilevel:SetText(value)
			else
				C_Timer.After(0.2, function() attempt_ilvl(v,attempts-1) end)
			end
		else
			v.ilevel:SetText("")
		end
	end
end

local function DCS_Item_Level_Center()
	for _, v in ipairs(DCSITEM_SLOT_FRAMES) do
		attempt_ilvl(v,20)
	end
end

gdbprivate.gdbdefaults.gdbdefaults.DejaClassicStatsShowItemLevelChecked = {
	ShowItemLevelSetChecked = true,
}

local DCS_ShowItemLevelCheck = CreateFrame("CheckButton", "DCS_ShowItemLevelCheck", DejaClassicStatsPanel, "InterfaceOptionsCheckButtonTemplate")
	DCS_ShowItemLevelCheck:RegisterEvent("PLAYER_LOGIN")
	DCS_ShowItemLevelCheck:ClearAllPoints()
	DCS_ShowItemLevelCheck:SetPoint("TOPLEFT", "dcsItemsPanelCategoryFS", 7, -15)
	DCS_ShowItemLevelCheck:SetScale(1)
	DCS_ShowItemLevelCheck.tooltipText = L["Displays the item level of each equipped item. Caveat; Item level is relatively meaningless in Classic."] --Creates a tooltip on mouseover.
	_G[DCS_ShowItemLevelCheck:GetName() .. "Text"]:SetText(L["Item Level"])

DCS_ShowItemLevelCheck:SetScript("OnEvent", function(self, event, ...)
	showitemlevel = gdbprivate.gdb.gdbdefaults.DejaClassicStatsShowItemLevelChecked.ShowItemLevelSetChecked
	self:SetChecked(showitemlevel)
	DCS_Set_Dura_Item_Positions()
	DCS_Item_Level_Center() --why it is called
end)

DCS_ShowItemLevelCheck:SetScript("OnClick", function(self)
	showitemlevel = not showitemlevel
	gdbprivate.gdb.gdbdefaults.DejaClassicStatsShowItemLevelChecked.ShowItemLevelSetChecked = showitemlevel
	DCS_Set_Dura_Item_Positions()
	if showitemlevel then
		DCS_Item_Level_Center()
	else
		for _, v in ipairs(DCSITEM_SLOT_FRAMES) do
			v.ilevel:SetFormattedText("")
		end
	end
end)

local DCS_ShowItemLevelChange = CreateFrame("Frame", "DCS_ShowItemLevelChange", UIParent)
	DCS_ShowItemLevelChange:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")

DCS_ShowItemLevelChange:SetScript("OnEvent", function(self, event, ...)
	if PaperDollFrame:IsVisible() then
		--print("PaperDollFrame:IsVisible")
		if showitemlevel then
		--print("showitemlevel")
			C_Timer.After(0.25, DCS_Item_Level_Center) --Event fires before Artifact changes so we have to wait a fraction of a second.
		else
			for _, v in ipairs(DCSITEM_SLOT_FRAMES) do
				v.ilevel:SetFormattedText("")
			end
		end
	end
end)

gdbprivate.gdbdefaults.gdbdefaults.DejaClassicStatsSimpleItemColorChecked = {
	SimpleItemColorChecked = false,
	DarkerItemColorChecked = false,
}

local function paintblack()
	for _, v in ipairs(DCSITEM_SLOT_FRAMES) do
		if simpleitemcolor then
			v.itemcolor:SetColorTexture(0, 0, 0, 1)
			v.itemcolor:Show()
		elseif darkeritemcolor then
			v.itemcolor:SetColorTexture(0, 0, 0, 0.6)
			v.itemcolor:Show()
		else
			v.itemcolor:Hide()
		end
	end
end

local DCS_SimpleItemColorCheck = CreateFrame("CheckButton", "DCS_SimpleItemColorCheck", DejaClassicStatsPanel, "InterfaceOptionsCheckButtonTemplate")
	DCS_SimpleItemColorCheck:RegisterEvent("PLAYER_LOGIN")
	DCS_SimpleItemColorCheck:ClearAllPoints()
	DCS_SimpleItemColorCheck:SetPoint("TOPLEFT", "dcsItemsPanelCategoryFS", 7, -135)
	DCS_SimpleItemColorCheck:SetScale(1)
	DCS_SimpleItemColorCheck.tooltipText = L["Black item icons to make text more visible."] --Creates a tooltip on mouseover.
	_G[DCS_SimpleItemColorCheck:GetName() .. "Text"]:SetText(L["Black Item Icons"])

local DCS_DarkerItemColorCheck = CreateFrame("CheckButton", "DCS_DarkerItemColorCheck", DejaClassicStatsPanel, "InterfaceOptionsCheckButtonTemplate")
	DCS_DarkerItemColorCheck:ClearAllPoints()
	DCS_DarkerItemColorCheck:SetPoint("TOPLEFT", "dcsItemsPanelCategoryFS", 7, -115)
	DCS_DarkerItemColorCheck:SetScale(1)
	DCS_DarkerItemColorCheck.tooltipText = L["Darken item icons to make text more visible."] --Creates a tooltip on mouseover.
	_G[DCS_DarkerItemColorCheck:GetName() .. "Text"]:SetText(L["Darken Item Icons"])

DCS_SimpleItemColorCheck:SetScript("OnEvent", function(self, event, ...)
	simpleitemcolor = gdbprivate.gdb.gdbdefaults.DejaClassicStatsSimpleItemColorChecked.SimpleItemColorChecked
	darkeritemcolor = gdbprivate.gdb.gdbdefaults.DejaClassicStatsSimpleItemColorChecked.DarkerItemColorChecked
	self:SetChecked(simpleitemcolor)
	DCS_DarkerItemColorCheck:SetChecked(darkeritemcolor)
	paintblack()
end)

DCS_SimpleItemColorCheck:SetScript("OnClick", function(self)
	simpleitemcolor = not simpleitemcolor
	gdbprivate.gdb.gdbdefaults.DejaClassicStatsSimpleItemColorChecked.SimpleItemColorChecked = simpleitemcolor
	if simpleitemcolor then
		DCS_DarkerItemColorCheck:SetChecked(false)
		gdbprivate.gdb.gdbdefaults.DejaClassicStatsSimpleItemColorChecked.DarkerItemColorChecked = false
		darkeritemcolor = false
	end
	paintblack()
end)

DCS_DarkerItemColorCheck:SetScript("OnClick", function(self)
	darkeritemcolor = not darkeritemcolor
	gdbprivate.gdb.gdbdefaults.DejaClassicStatsSimpleItemColorChecked.DarkerItemColorChecked = darkeritemcolor
	if darkeritemcolor then
		DCS_SimpleItemColorCheck:SetChecked(false)
		gdbprivate.gdb.gdbdefaults.DejaClassicStatsSimpleItemColorChecked.SimpleItemColorChecked = false
		simpleitemcolor = false
	end
	paintblack()
end)

-- local DCS_SimpleItemColor = CreateFrame("Frame", "DCS_SimpleItemColor", UIParent) --Needed? Doesn't seem so.
-- 	DCS_SimpleItemColor:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")

-- 	DCS_SimpleItemColor:SetScript("OnEvent", function(self, event, ...)
-- 		if PaperDollFrame:IsVisible() then
-- 			paintblack()
-- 		end
-- 	end)

local DCS_ENCHANT_IDS = {
	[1] = "Rockbiter 3",
	[2] = "Frostbrand 1",
	[3] = "Flametongue 3",
	[4] = "Flametongue 2",
	[5] = "Flametongue 1",
	[6] = "Rockbiter 2",
	[7] = "Deadly Poison",
	[8] = "Deadly Poison II",
	[9] = "Poison (15 Dmg)",
	[10] = "Poison (20 Dmg)",
	[11] = "Poison (25 Dmg)",
	[12] = "Frostbrand 2",
	[13] = "Sharpened +3",
	[14] = "Sharpened +4",
	[15] = "Reinforced Armor +8",
	[16] = "Reinforced Armor +16",
	[17] = "Reinforced Armor +24",
	[18] = "Reinforced Armor +32",
	[19] = "Weighted +2",
	[20] = "Weighted +3",
	[21] = "Weighted +4",
	[22] = "Crippling Poison",
	[23] = "Mind-numbing Poison II",
	[24] = "Mana +5",
	[25] = "Shadow Oil",
	[26] = "Frost Oil",
	[27] = "Sundered",
	[28] = "+4 All Resistances",
	[29] = "Rockbiter 1",
	[30] = "Scope (+1 Damage)",
	[31] = "Beastslaying +4",
	[32] = "Scope (+2 Damage)",
	[33] = "Scope (+3 Damage)",
	[34] = "Counterweight +3% Attack Speed",
	[35] = "Mind Numbing Poison",
	[36] = "Enchant: Fiery Blaze",
	[37] = "Weapon Chain - Immune Disarm",
	[38] = "Defense Skill +3",
	[39] = "Sharpened +1",
	[40] = "Sharpened +2",
	[41] = "Health +5",
	[42] = "Poison (Instant 20)",
	[43] = "Iron Spike (8-12)",
	[44] = "Absorption (10)",
	[63] = "Absorption (25)",
	[64] = "Spirit +3",
	[65] = "+1 All Resistances",
	[66] = "Stamina +1",
	[67] = "+1 Damage",
	[68] = "+1 Strength",
	[69] = "+2 Strength",
	[70] = "+3 Strength",
	[71] = "+1 Stamina",
	[72] = "+2 Stamina",
	[73] = "+3 Stamina",
	[74] = "+1 Agility",
	[75] = "+2 Agility",
	[76] = "+3 Agility",
	[77] = "+2 Damage",
	[78] = "+3 Damage",
	[79] = "+1 Intellect",
	[80] = "+2 Intellect",
	[81] = "+3 Intellect",
	[82] = "+1 Spirit",
	[83] = "+2 Spirit",
	[84] = "+3 Spirit",
	[85] = "+3 Armor",
	[86] = "+8 Armor",
	[87] = "+12 Armor",
	[89] = "+16 Armor",
	[90] = "+4 Agility",
	[91] = "+5 Agility",
	[92] = "+6 Agility",
	[93] = "+7 Agility",
	[94] = "+4 Intellect",
	[95] = "+5 Intellect",
	[96] = "+6 Intellect",
	[97] = "+7 Intellect",
	[98] = "+4 Spirit",
	[99] = "+5 Spirit",
	[100] = "+6 Spirit",
	[101] = "+7 Spirit",
	[102] = "+4 Stamina",
	[103] = "+5 Stamina",
	[104] = "+6 Stamina",
	[105] = "+7 Stamina",
	[106] = "+4 Strength",
	[107] = "+5 Strength",
	[108] = "+6 Strength",
	[109] = "+7 Strength",
	[110] = "+1 Defense",
	[111] = "+1 Defense",
	[112] = "+2 Defense",
	[113] = "+3 Defense",
	[114] = "+3 Defense",
	[115] = "+4 Defense",
	[116] = "+5 Defense",
	[117] = "+4 Damage",
	[118] = "+5 Damage",
	[119] = "+6 Damage",
	[120] = "+7 Damage",
	[121] = "+20 Armor",
	[122] = "+24 Armor",
	[123] = "+28 Armor",
	[124] = "Flametongue Totem 1",
	[125] = "Sword Skill +1",
	[126] = "Sword Skill +2",
	[127] = "Sword Skill +3",
	[128] = "Sword Skill +4",
	[129] = "Sword Skill +5",
	[130] = "Sword Skill +6",
	[131] = "Sword Skill +7",
	[132] = "Two-Handed Sword Skill +1",
	[133] = "Two-Handed Sword Skill +2",
	[134] = "Two-Handed Sword Skill +3",
	[135] = "Two-Handed Sword Skill +4",
	[136] = "Two-Handed Sword Skill +5",
	[137] = "Two-Handed Sword Skill +6",
	[138] = "Two-Handed Sword Skill +7",
	[139] = "Mace Skill +1",
	[140] = "Mace Skill +2",
	[141] = "Mace Skill +3",
	[142] = "Mace Skill +4",
	[143] = "Mace Skill +5",
	[144] = "Mace Skill +6",
	[145] = "Mace Skill +7",
	[146] = "Two-Handed Mace Skill +1",
	[147] = "Two-Handed Mace Skill +2",
	[148] = "Two-Handed Mace Skill +3",
	[149] = "Two-Handed Mace Skill +4",
	[150] = "Two-Handed Mace Skill +5",
	[151] = "Two-Handed Mace Skill +6",
	[152] = "Two-Handed Mace Skill +7",
	[153] = "Axe Skill +1",
	[154] = "Axe Skill +2",
	[155] = "Axe Skill +3",
	[156] = "Axe Skill +4",
	[157] = "Axe Skill +5",
	[158] = "Ase Skill +6",
	[159] = "Axe Skill +7",
	[160] = "Two-Handed Axe Skill +1",
	[161] = "Two-Handed Axe Skill +2",
	[162] = "Two-Handed Axe Skill +3",
	[163] = "Two-Handed Axe Skill +4",
	[164] = "Two-Handed Axe Skill +5",
	[165] = "Two-Handed Axe Skill +6",
	[166] = "Two-Handed Axe Skill +7",
	[167] = "Dagger Skill +1",
	[168] = "Dagger Skill +2",
	[169] = "Dagger Skill +3",
	[170] = "Dagger Skill +4",
	[171] = "Dagger Skill +5",
	[172] = "Dagger Skill +6",
	[173] = "Dagger Skill +7",
	[174] = "Gun Skill +1",
	[175] = "Gun Skill +2",
	[176] = "Gun Skill +3",
	[177] = "Gun Skill +4",
	[178] = "Gun Skill +5",
	[179] = "Gun Skill +6",
	[180] = "Gun Skill +7",
	[181] = "Bow Skill +1",
	[182] = "Bow Skill +2",
	[183] = "Bow Skill +3",
	[184] = "Bow Skill +4",
	[185] = "Bow Skill +5",
	[186] = "Bow Skill +6",
	[187] = "Bow Skill +7",
	[188] = "+2 Beast Slaying",
	[189] = "+4 Beast Slaying",
	[190] = "+6 Beast Slaying",
	[191] = "+8 Beast Slaying",
	[192] = "+10 Beast Slaying",
	[193] = "+12 Beast Slaying",
	[194] = "+14 Beast Slaying",
	[195] = "Critical Hit +1%",
	[196] = "Critical Hit +2%",
	[197] = "Critical Hit +3%",
	[198] = "Critical Hit +4%",
	[199] = "10% On Get Hit: Shadow Bolt (10 Damage)",
	[200] = "10% On Get Hit: Shadow Bolt (20 Damage)",
	[201] = "10% On Get Hit: Shadow Bolt (30 Damage)",
	[202] = "10% On Get Hit: Shadow Bolt (40 Damage)",
	[203] = "10% On Get Hit: Shadow Bolt (50 Damage)",
	[204] = "10% On Get Hit: Shadow Bolt (60 Damage)",
	[205] = "10% On Get Hit: Shadow Bolt (70 Damage)",
	[206] = "Increases Healing +2",
	[207] = "Increases Healing +4",
	[208] = "Increases Healing +7",
	[209] = "Increases Healing +9",
	[210] = "Increases Healing +11",
	[211] = "Increases Healing +13",
	[212] = "Increases Healing +15",
	[213] = "Increase Fire Effects +1",
	[214] = "Increases Fire Effects +3",
	[215] = "Increases Fire Effects +4",
	[216] = "Increases Fire Effects +6",
	[217] = "Increases Fire Effects +7",
	[218] = "Increases Fire Damage +9",
	[219] = "Increases Fire Damage +10",
	[220] = "Increases Nature Effects +1",
	[221] = "Increases Nature Effects +3",
	[222] = "Increases Nature Effects +4",
	[223] = "Increases Nature Effects +6",
	[224] = "Increases Nature Effects +7",
	[225] = "Increases Nature Effects +9",
	[226] = "Increases Nature Effects +10",
	[227] = "Increases Frost Effects +1",
	[228] = "Increases Frost Effects +3",
	[229] = "Increases Frost Effects +4",
	[230] = "Increases Frost Effects +6",
	[231] = "Increases Frost Effects +7",
	[232] = "Increases Frost Effects +9",
	[233] = "Increases Frost Effects +10",
	[234] = "Increases Shadow Effects +1",
	[235] = "Increases Shadow Effects +3",
	[236] = "Increases Shadow Effects +4",
	[237] = "Increases Shadow Effects +6",
	[238] = "Increases Shadow Effects +7",
	[239] = "Increases Shadow Effects +9",
	[240] = "Increases Shadow Effects +10",
	[241] = "Weapon Damage +2",
	[242] = "Health +15",
	[243] = "Spirit +1",
	[244] = "Intellect +4",
	[245] = "Armor +5",
	[246] = "Mana +20",
	[247] = "Agility +1",
	[248] = "Strength +1",
	[249] = "Beastslaying +2",
	[250] = "Weapon Damage +1 ",
	[251] = "Intellect +1",
	[252] = "Spirit +6",
	[253] = "Absorption (50)",
	[254] = "Health +25",
	[255] = "Spirit +3",
	[256] = "+5 Fire Resistance",
	[257] = "Armor +10",
	[263] = "Fishing Lure +25",
	[264] = "Fishing Lure +50",
	[265] = "Fishing Lure +75",
	[266] = "Fishing Lure +100",
	[283] = "Windfury 1",
	[284] = "Windfury 2",
	[285] = "Flametongue Totem 2",
	[286] = "+2 Weapon Fire Damage",
	[287] = "+4 Weapon Fire Damage",
	[288] = "+6 Weapon Fire Damage",
	[289] = "+8 Weapon Fire Damage",
	[290] = "+10 Weapon Fire Damage",
	[291] = "+12 Weapon Fire Damage",
	[292] = "+14 Weapon Fire Damage",
	[303] = "Orb of Fire",
	[323] = "Instant Poison",
	[324] = "Instant Poison II",
	[325] = "Instant Poison III",
	[343] = "+8 Agility",
	[344] = "+32 Armor",
	[345] = "+40 Armor",
	[346] = "+36 Armor",
	[347] = "+44 Armor",
	[348] = "+48 Armor",
	[349] = "+9 Agility",
	[350] = "+8 Intellect",
	[351] = "+8 Spirit",
	[352] = "+8 Strength",
	[353] = "+8 Stamina",
	[354] = "+9 Intellect",
	[355] = "+9 Spirit",
	[356] = "+9 Stamina",
	[357] = "+9 Strength",
	[358] = "+10 Agility",
	[359] = "+10 Intellect",
	[360] = "+10 Spirit",
	[361] = "+10 Stamina",
	[362] = "+10 Strength",
	[363] = "+11 Agility",
	[364] = "+11 Intellect",
	[365] = "+11 Spirit",
	[366] = "+11 Stamina",
	[367] = "+11 Strength",
	[368] = "+12 Agility",
	[369] = "+12 Intellect",
	[370] = "+12 Spirit",
	[371] = "+12 Stamina",
	[372] = "+12 Strength",
	[383] = "+52 Armor",
	[384] = "+56 Armor",
	[385] = "+60 Armor",
	[386] = "+16 Armor",
	[387] = "+17 Armor",
	[388] = "+18 Armor",
	[389] = "+19 Armor",
	[403] = "+13 Agility",
	[404] = "+14 Agility",
	[405] = "+13 Intellect",
	[406] = "+14 Intellect",
	[407] = "+13 Spirit",
	[408] = "+14 Spirit",
	[409] = "+13 Stamina",
	[410] = "+13 Strength",
	[411] = "+14 Stamina",
	[412] = "+14 Strength",
	[423] = "Increase Spell Damage +1",
	[424] = "Increase Spell Damage +2",
	[425] = "Increase Spell Damage +4",
	[426] = "Increase Spell Damage +5",
	[427] = "Increase Spell Damage +6",
	[428] = "Increase Spell Damage +7",
	[429] = "Increase Spell Damage +8",
	[430] = "Increase Spell Damage +9",
	[431] = "Increase Spell Damage +11",
	[432] = "Increase Spell Damage +12",
	[433] = "Increase Fire Damage +11",
	[434] = "Increase Fire Damage +13",
	[435] = "Increases Fire Damage +14",
	[436] = "Critical Hit +5%",
	[437] = "Increases Frost Effects +11",
	[438] = "Increases Frost Effects +13",
	[439] = "Increases Frost Effects +14",
	[440] = "Increases Healing +12",
	[441] = "Increases Healing +20",
	[442] = "Increases Healing +22",
	[443] = "Increases Nature Effects +11",
	[444] = "Increases Nature Effects +13",
	[445] = "Increases Nature Effects +14",
	[446] = "Increases Shadow Effects +11",
	[447] = "Increases Shadow Effects +13",
	[448] = "Increases Shadow Effects +14",
	[463] = "Mithril Spike (16-20)",
	[464] = "Mithril Spurs",
	[483] = "Sharpened +6",
	[484] = "Weighted +6",
	[503] = "Rockbiter 4",
	[504] = "Rockbiter +80",
	[523] = "Flametongue 4",
	[524] = "Frostbrand 3",
	[525] = "Windfury 3",
	[543] = "Flametongue Totem 3",
	[563] = "Windfury Totem 2",
	[564] = "Windfury Totem 3",
	[583] = "+1 Agility / +1 Spirit",
	[584] = "+1 Agility / +1 Intellect",
	[585] = "+1 Agility / +1 Stamina",
	[586] = "+1 Agility / +1 Strength",
	[587] = "+1 Intellect / +1 Spirit",
	[588] = "+1 Intellect / +1 Stamina",
	[589] = "+1 Intellect / +1 Strength",
	[590] = "+1 Spirit / +1 Stamina",
	[591] = "+1 Spirit / +1 Strength",
	[592] = "+1 Stamina / +1 Strength",
	[603] = "Crippling Poison II",
	[623] = "Instant Poison IV",
	[624] = "Instant Poison V",
	[625] = "Instant Poison VI",
	[626] = "Deadly Poison III",
	[627] = "Deadly Poison IV",
	[643] = "Mind-Numbing Poison III",
	[663] = "Scope (+5 Damage)",
	[664] = "Scope (+7 Damage)",
	[683] = "Rockbiter 6",
	[684] = "+15 Strength",
	[703] = "Wound Poison",
	[704] = "Wound Poison II",
	[705] = "Wound Poison III",
	[706] = "Wound Poison IV",
	[723] = "Intellect +3",
	[724] = "Stamina +3",
	[743] = "Stealth +2",
	[744] = "Armor +20",
	[763] = "Block +1%",
	[783] = "Armor +10",
	[803] = "Fiery Weapon",
	[804] = "+10 Shadow Resistance",
	[805] = "Weapon Damage +4",
	[823] = "Strength +3",
	[843] = "Mana +30",
	[844] = "Mining +2",
	[845] = "Herbalism +2",
	[846] = "Fishing +2",
	[847] = "All Stats +1",
	[848] = "Armor +30",
	[849] = "Agility +3",
	[850] = "Health +35",
	[851] = "Spirit +5",
	[852] = "Stamina +5",
	[853] = "Beastslaying +6",
	[854] = "Elemental Slayer +6",
	[855] = "+5 Fire Resistance",
	[856] = "Strength +5",
	[857] = "Mana +50",
	[863] = "Blocking +2%",
	[864] = "Weapon Damage +4",
	[865] = "Skinning +5",
	[866] = "All Stats +2",
	[883] = "+15 Agility",
	[884] = "Armor +50",
	[903] = "+3 All Resistances",
	[904] = "Agility +5",
	[905] = "Intellect +5",
	[906] = "Mining +5",
	[907] = "Spirit +7",
	[908] = "Health +50",
	[909] = "Herbalism +5",
	[910] = "Increased Stealth",
	[911] = "Minor Speed Increase",
	[912] = "Demonslaying",
	[913] = "Mana +65",
	[923] = "Defense +3",
	[924] = "Defense +1",
	[925] = "Defense +2",
	[926] = "+8 Frost Resistance",
	[927] = "Strength +7",
	[928] = "All Stats +3",
	[929] = "Stamina +7",
	[930] = "Minor Mount Speed Increase",
	[931] = "Attack Speed +1%",
	[943] = "Weapon Damage +3",
	[963] = "Weapon Damage +7",
	[983] = "+16 Agility",
	[1003] = "Venomhide Poison",
	[1023] = "Feedback 1",
	[1043] = "+16 Strength",
	[1044] = "+17 Strength",
	[1045] = "+18 Strength",
	[1046] = "+19 Strength",
	[1047] = "+20 Strength",
	[1048] = "+21 Strength",
	[1049] = "+22 Strength",
	[1050] = "+23 Strength",
	[1051] = "+24 Strength",
	[1052] = "+25 Strength",
	[1053] = "+26 Strength",
	[1054] = "+27 Strength",
	[1055] = "+28 Strength",
	[1056] = "+29 Strength",
	[1057] = "+30 Strength",
	[1058] = "+31 Strength",
	[1059] = "+32 Strength",
	[1060] = "+33 Strength",
	[1061] = "+34 Strength",
	[1062] = "+35 Strength",
	[1063] = "+36 Strength",
	[1064] = "+37 Strength",
	[1065] = "+38 Strength",
	[1066] = "+39 Strength",
	[1067] = "+40 Strength",
	[1068] = "+15 Stamina",
	[1069] = "+16 Stamina",
	[1070] = "+17 Stamina",
	[1071] = "+18 Stamina",
	[1072] = "+19 Stamina",
	[1073] = "+20 Stamina",
	[1074] = "+21 Stamina",
	[1075] = "+22 Stamina",
	[1076] = "+23 Stamina",
	[1077] = "+24 Stamina",
	[1078] = "+25 Stamina",
	[1079] = "+26 Stamina",
	[1080] = "+27 Stamina",
	[1081] = "+28 Stamina",
	[1082] = "+29 Stamina",
	[1083] = "+30 Stamina",
	[1084] = "+31 Stamina",
	[1085] = "+32 Stamina",
	[1086] = "+33 Stamina",
	[1087] = "+34 Stamina",
	[1088] = "+35 Stamina",
	[1089] = "+36 Stamina",
	[1090] = "+37 Stamina",
	[1091] = "+38 Stamina",
	[1092] = "+39 Stamina",
	[1093] = "+40 Stamina",
	[1094] = "+17 Agility",
	[1095] = "+18 Agility",
	[1096] = "+19 Agility",
	[1097] = "+20 Agility",
	[1098] = "+21 Agility",
	[1099] = "+22 Agility",
	[1100] = "+23 Agility",
	[1101] = "+24 Agility",
	[1102] = "+25 Agility",
	[1103] = "+26 Agility",
	[1104] = "+27 Agility",
	[1105] = "+28 Agility",
	[1106] = "+29 Agility",
	[1107] = "+30 Agility",
	[1108] = "+31 Agility",
	[1109] = "+32 Agility",
	[1110] = "+33 Agility",
	[1111] = "+34 Agility",
	[1112] = "+35 Agility",
	[1113] = "+36 Agility",
	[1114] = "+37 Agility",
	[1115] = "+38 Agility",
	[1116] = "+39 Agility",
	[1117] = "+40 Agility",
	[1118] = "+15 Intellect",
	[1119] = "+16 Intellect",
	[1120] = "+17 Intellect",
	[1121] = "+18 Intellect",
	[1122] = "+19 Intellect",
	[1123] = "+20 Intellect",
	[1124] = "+21 Intellect",
	[1125] = "+22 Intellect",
	[1126] = "+23 Intellect",
	[1127] = "+24 Intellect",
	[1128] = "+25 Intellect",
	[1129] = "+26 Intellect",
	[1130] = "+27 Intellect",
	[1131] = "+28 Intellect",
	[1132] = "+29 Intellect",
	[1133] = "+30 Intellect",
	[1134] = "+31 Intellect",
	[1135] = "+32 Intellect",
	[1136] = "+33 Intellect",
	[1137] = "+34 Intellect",
	[1138] = "+35 Intellect",
	[1139] = "+36 Intellect",
	[1140] = "+37 Intellect",
	[1141] = "+38 Intellect",
	[1142] = "+39 Intellect",
	[1143] = "+40 Intellect",
	[1144] = "+15 Spirit",
	[1145] = "+16 Spirit",
	[1146] = "+17 Spirit",
	[1147] = "+18 Spirit",
	[1148] = "+19 Spirit",
	[1149] = "+20 Spirit",
	[1150] = "+21 Spirit",
	[1151] = "+22 Spirit",
	[1152] = "+23 Spirit",
	[1153] = "+24 Spirit",
	[1154] = "+25 Spirit",
	[1155] = "+26 Spirit",
	[1156] = "+27 Spirit",
	[1157] = "+28 Spirit",
	[1158] = "+29 Spirit",
	[1159] = "+30 Spirit",
	[1160] = "+31 Spirit",
	[1161] = "+32 Spirit",
	[1162] = "+33 Spirit",
	[1163] = "+34 Spirit",
	[1164] = "+36 Spirit",
	[1165] = "+37 Spirit",
	[1166] = "+38 Spirit",
	[1167] = "+39 Spirit",
	[1168] = "+40 Spirit",
	[1183] = "+35 Spirit",
	[1203] = "+41 Strength",
	[1204] = "+42 Strength",
	[1205] = "+43 Strength",
	[1206] = "+44 Strength",
	[1207] = "+45 Strength",
	[1208] = "+46 Strength",
	[1209] = "+41 Stamina",
	[1210] = "+42 Stamina",
	[1211] = "+43 Stamina",
	[1212] = "+44 Stamina",
	[1213] = "+45 Stamina",
	[1214] = "+46 Stamina",
	[1215] = "+41 Agility",
	[1216] = "+42 Agility",
	[1217] = "+43 Agility",
	[1218] = "+44 Agility",
	[1219] = "+45 Agility",
	[1220] = "+46 Agility",
	[1221] = "+41 Intellect",
	[1222] = "+42 Intellect",
	[1223] = "+43 Intellect",
	[1224] = "+44 Intellect",
	[1225] = "+45 Intellect",
	[1226] = "+46 Intellect",
	[1227] = "+41 Spirit",
	[1228] = "+42 Spirit",
	[1229] = "+43 Spirit",
	[1230] = "+44 Spirit",
	[1231] = "+45 Spirit",
	[1232] = "+46 Spirit",
	[1243] = "+1 Arcane Resistance",
	[1244] = "+2 Arcane Resistance",
	[1245] = "+3 Arcane Resistance",
	[1246] = "+4 Arcane Resistance",
	[1247] = "+5 Arcane Resistance",
	[1248] = "+6 Arcane Resistance",
	[1249] = "+7 Arcane Resistance",
	[1250] = "+8 Arcane Resistance",
	[1251] = "+9 Arcane Resistance",
	[1252] = "+10 Arcane Resistance",
	[1253] = "+11 Arcane Resistance",
	[1254] = "+12 Arcane Resistance",
	[1255] = "+13 Arcane Resistance",
	[1256] = "+14 Arcane Resistance",
	[1257] = "+15 Arcane Resistance",
	[1258] = "+16 Arcane Resistance",
	[1259] = "+17 Arcane Resistance",
	[1260] = "+18 Arcane Resistance",
	[1261] = "+19 Arcane Resistance",
	[1262] = "+20 Arcane Resistance",
	[1263] = "+21 Arcane Resistance",
	[1264] = "+22 Arcane Resistance",
	[1265] = "+23 Arcane Resistance",
	[1266] = "+24 Arcane Resistance",
	[1267] = "+25 Arcane Resistance",
	[1268] = "+26 Arcane Resistance",
	[1269] = "+27 Arcane Resistance",
	[1270] = "+28 Arcane Resistance",
	[1271] = "+29 Arcane Resistance",
	[1272] = "+30 Arcane Resistance",
	[1273] = "+31 Arcane Resistance",
	[1274] = "+32 Arcane Resistance",
	[1275] = "+33 Arcane Resistance",
	[1276] = "+34 Arcane Resistance",
	[1277] = "+35 Arcane Resistance",
	[1278] = "+36 Arcane Resistance",
	[1279] = "+37 Arcane Resistance",
	[1280] = "+38 Arcane Resistance",
	[1281] = "+39 Arcane Resistance",
	[1282] = "+40 Arcane Resistance",
	[1283] = "+41 Arcane Resistance",
	[1284] = "+42 Arcane Resistance",
	[1285] = "+43 Arcane Resistance",
	[1286] = "+44 Arcane Resistance",
	[1287] = "+45 Arcane Resistance",
	[1288] = "+46 Arcane Resistance",
	[1289] = "+1 Frost Resistance",
	[1290] = "+2 Frost Resistance",
	[1291] = "+3 Frost Resistance",
	[1292] = "+4 Frost Resistance",
	[1293] = "+5 Frost Resistance",
	[1294] = "+6 Frost Resistance",
	[1295] = "+7 Frost Resistance",
	[1296] = "+8 Frost Resistance",
	[1297] = "+9 Frost Resistance",
	[1298] = "+10 Frost Resistance",
	[1299] = "+11 Frost Resistance",
	[1300] = "+12 Frost Resistance",
	[1301] = "+13 Frost Resistance",
	[1302] = "+14 Frost Resistance",
	[1303] = "+15 Frost Resistance",
	[1304] = "+16 Frost Resistance",
	[1305] = "+17 Frost Resistance",
	[1306] = "+18 Frost Resistance",
	[1307] = "+19 Frost Resistance",
	[1308] = "+20 Frost Resistance",
	[1309] = "+21 Frost Resistance",
	[1310] = "+22 Frost Resistance",
	[1311] = "+23 Frost Resistance",
	[1312] = "+24 Frost Resistance",
	[1313] = "+25 Frost Resistance",
	[1314] = "+26 Frost Resistance",
	[1315] = "+27 Frost Resistance",
	[1316] = "+28 Frost Resistance",
	[1317] = "+29 Frost Resistance",
	[1318] = "+30 Frost Resistance",
	[1319] = "+31 Frost Resistance",
	[1320] = "+32 Frost Resistance",
	[1321] = "+33 Frost Resistance",
	[1322] = "+34 Frost Resistance",
	[1323] = "+35 Frost Resistance",
	[1324] = "+36 Frost Resistance",
	[1325] = "+37 Frost Resistance",
	[1326] = "+38 Frost Resistance",
	[1327] = "+39 Frost Resistance",
	[1328] = "+40 Frost Resistance",
	[1329] = "+41 Frost Resistance",
	[1330] = "+42 Frost Resistance",
	[1331] = "+43 Frost Resistance",
	[1332] = "+44 Frost Resistance",
	[1333] = "+45 Frost Resistance",
	[1334] = "+46 Frost Resistance",
	[1335] = "+1 Fire Resistance",
	[1336] = "+2 Fire Resistance",
	[1337] = "+3 Fire Resistance",
	[1338] = "+4 Fire Resistance",
	[1339] = "+5 Fire Resistance",
	[1340] = "+6 Fire Resistance",
	[1341] = "+7 Fire Resistance",
	[1342] = "+8 Fire Resistance",
	[1343] = "+9 Fire Resistance",
	[1344] = "+10 Fire Resistance",
	[1345] = "+11 Fire Resistance",
	[1346] = "+12 Fire Resistance",
	[1347] = "+13 Fire Resistance",
	[1348] = "+14 Fire Resistance",
	[1349] = "+15 Fire Resistance",
	[1350] = "+16 Fire Resistance",
	[1351] = "+17 Fire Resistance",
	[1352] = "+18 Fire Resistance",
	[1353] = "+19 Fire Resistance",
	[1354] = "+20 Fire Resistance",
	[1355] = "+21 Fire Resistance",
	[1356] = "+22 Fire Resistance",
	[1357] = "+23 Fire Resistance",
	[1358] = "+24 Fire Resistance",
	[1359] = "+25 Fire Resistance",
	[1360] = "+26 Fire Resistance",
	[1361] = "+27 Fire Resistance",
	[1362] = "+28 Fire Resistance",
	[1363] = "+29 Fire Resistance",
	[1364] = "+30 Fire Resistance",
	[1365] = "+31 Fire Resistance",
	[1366] = "+32 Fire Resistance",
	[1367] = "+33 Fire Resistance",
	[1368] = "+34 Fire Resistance",
	[1369] = "+35 Fire Resistance",
	[1370] = "+36 Fire Resistance",
	[1371] = "+37 Fire Resistance",
	[1372] = "+38 Fire Resistance",
	[1373] = "+39 Fire Resistance",
	[1374] = "+40 Fire Resistance",
	[1375] = "+41 Fire Resistance",
	[1376] = "+42 Fire Resistance",
	[1377] = "+43 Fire Resistance",
	[1378] = "+44 Fire Resistance",
	[1379] = "+45 Fire Resistance",
	[1380] = "+46 Fire Resistance",
	[1381] = "+1 Nature Resistance",
	[1382] = "+2 Nature Resistance",
	[1383] = "+3 Nature Resistance",
	[1384] = "+4 Nature Resistance",
	[1385] = "+5 Nature Resistance",
	[1386] = "+6 Nature Resistance",
	[1387] = "+7 Nature Resistance",
	[1388] = "+8 Nature Resistance",
	[1389] = "+9 Nature Resistance",
	[1390] = "+10 Nature Resistance",
	[1391] = "+11 Nature Resistance",
	[1392] = "+12 Nature Resistance",
	[1393] = "+13 Nature Resistance",
	[1394] = "+14 Nature Resistance",
	[1395] = "+15 Nature Resistance",
	[1396] = "+16 Nature Resistance",
	[1397] = "+17 Nature Resistance",
	[1398] = "+18 Nature Resistance",
	[1399] = "+19 Nature Resistance",
	[1400] = "+20 Nature Resistance",
	[1401] = "+21 Nature Resistance",
	[1402] = "+22 Nature Resistance",
	[1403] = "+23 Nature Resistance",
	[1404] = "+24 Nature Resistance",
	[1405] = "+25 Nature Resistance",
	[1406] = "+26 Nature Resistance",
	[1407] = "+27 Nature Resistance",
	[1408] = "+28 Nature Resistance",
	[1409] = "+29 Nature Resistance",
	[1410] = "+30 Nature Resistance",
	[1411] = "+31 Nature Resistance",
	[1412] = "+32 Nature Resistance",
	[1413] = "+33 Nature Resistance",
	[1414] = "+34 Nature Resistance",
	[1415] = "+35 Nature Resistance",
	[1416] = "+36 Nature Resistance",
	[1417] = "+37 Nature Resistance",
	[1418] = "+38 Nature Resistance",
	[1419] = "+39 Nature Resistance",
	[1420] = "+40 Nature Resistance",
	[1421] = "+41 Nature Resistance",
	[1422] = "+42 Nature Resistance",
	[1423] = "+43 Nature Resistance",
	[1424] = "+44 Nature Resistance",
	[1425] = "+45 Nature Resistance",
	[1426] = "+46 Nature Resistance",
	[1427] = "+1 Shadow Resistance",
	[1428] = "+2 Shadow Resistance",
	[1429] = "+3 Shadow Resistance",
	[1430] = "+4 Shadow Resistance",
	[1431] = "+5 Shadow Resistance",
	[1432] = "+6 Shadow Resistance",
	[1433] = "+7 Shadow Resistance",
	[1434] = "+8 Shadow Resistance",
	[1435] = "+9 Shadow Resistance",
	[1436] = "+10 Shadow Resistance",
	[1437] = "+11 Shadow Resistance",
	[1438] = "+12 Shadow Resistance",
	[1439] = "+13 Shadow Resistance",
	[1440] = "+14 Shadow Resistance",
	[1441] = "+15 Shadow Resistance",
	[1442] = "+16 Shadow Resistance",
	[1443] = "+17 Shadow Resistance",
	[1444] = "+18 Shadow Resistance",
	[1445] = "+19 Shadow Resistance",
	[1446] = "+20 Shadow Resistance",
	[1447] = "+21 Shadow Resistance",
	[1448] = "+22 Shadow Resistance",
	[1449] = "+23 Shadow Resistance",
	[1450] = "+24 Shadow Resistance",
	[1451] = "+25 Shadow Resistance",
	[1452] = "+26 Resist Shadow",
	[1453] = "+27 Shadow Resistance",
	[1454] = "+28 Shadow Resistance",
	[1455] = "+29 Shadow Resistance",
	[1456] = "+30 Shadow Resistance",
	[1457] = "+31 Shadow Resistance",
	[1458] = "+32 Shadow Resistance",
	[1459] = "+33 Shadow Resistance",
	[1460] = "+34 Shadow Resistance",
	[1461] = "+35 Shadow Resistance",
	[1462] = "+36 Shadow Resistance",
	[1463] = "+37 Shadow Resistance",
	[1464] = "+38 Shadow Resistance",
	[1465] = "+39 Shadow Resistance",
	[1466] = "+40 Shadow Resistance",
	[1467] = "+41 Shadow Resistance",
	[1468] = "+42 Shadow Resistance",
	[1469] = "+43 Shadow Resistance",
	[1470] = "+44 Shadow Resistance",
	[1471] = "+45 Shadow Resistance",
	[1472] = "+46 Shadow Resistance",
	[1483] = "Mana +150",
	[1503] = "HP +100",
	[1504] = "Armor +125",
	[1505] = "+20 Fire Resistance",
	[1506] = "Strength +8",
	[1507] = "Stamina +8",
	[1508] = "Agility +8",
	[1509] = "Intellect +8",
	[1510] = "Spirit +8",
	[1523] = "MANA/FR +85/14",
	[1524] = "HP/FR +75/14",
	[1525] = "AC/FR +110/14",
	[1526] = "STR/FR +10/14",
	[1527] = "STA/FR +10/14",
	[1528] = "AGI/FR +10/14",
	[1529] = "INT/FR +10/14",
	[1530] = "SPI/FR +10/14",
	[1531] = "STR/STA +10/10",
	[1532] = "STR/STA/AC/FR +10/10/110/15",
	[1543] = "INT/SPI/MANA/FR +10/10/100/15",
	[1563] = "+2 Attack Power",
	[1583] = "+4 Attack Power",
	[1584] = "+6 Attack Power",
	[1585] = "+8 Attack Power",
	[1586] = "+10 Attack Power",
	[1587] = "+12 Attack Power",
	[1588] = "+14 Attack Power",
	[1589] = "+16 Attack Power",
	[1590] = "+18 Attack Power",
	[1591] = "+20 Attack Power",
	[1592] = "+22 Attack Power",
	[1593] = "+24 Attack Power",
	[1594] = "+26 Attack Power",
	[1595] = "+28 Attack Power",
	[1596] = "+30 Attack Power",
	[1597] = "+32 Attack Power",
	[1598] = "+34 Attack Power",
	[1599] = "+36 Attack Power",
	[1600] = "+38 Attack Power",
	[1601] = "+40 Attack Power",
	[1602] = "+42 Attack Power",
	[1603] = "+44 Attack Power",
	[1604] = "+46 Attack Power",
	[1605] = "+48 Attack Power",
	[1606] = "+50 Attack Power",
	[1607] = "+52 Attack Power",
	[1608] = "+54 Attack Power",
	[1609] = "+56 Attack Power",
	[1610] = "+58 Attack Power",
	[1611] = "+60 Attack Power",
	[1612] = "+62 Attack Power",
	[1613] = "+64 Attack Power",
	[1614] = "+66 Attack Power",
	[1615] = "+68 Attack Power",
	[1616] = "+70 Attack Power",
	[1617] = "+72 Attack Power",
	[1618] = "+74 Attack Power",
	[1619] = "+76 Attack Power",
	[1620] = "+78 Attack Power",
	[1621] = "+80 Attack Power",
	[1622] = "+82 Attack Power",
	[1623] = "+84 Attack Power",
	[1624] = "+86 Attack Power",
	[1625] = "+88 Attack Power",
	[1626] = "+90 Attack Power",
	[1627] = "+92 Attack Power",
	[1643] = "Sharpened +8",
	[1663] = "Rockbiter 5",
	[1664] = "Rockbiter 7",
	[1665] = "Flametongue 5",
	[1666] = "Flametongue 6",
	[1667] = "Frostbrand 4",
	[1668] = "Frostbrand 5",
	[1669] = "Windfury 4",
	[1683] = "Flametongue Totem 4",
	[1703] = "Weighted +8",
	[1704] = "Thorium Spike (20-30)",
	[1723] = "Omen of Clarity",
	[1743] = "MHTest02",
	[1763] = "Cold Blood",
	[1783] = "Windfury Totem 1",
	[1803] = "Firestone 1",
	[1823] = "Firestone 2",
	[1824] = "Firestone 3",
	[1825] = "Firestone 4",
	[1843] = "Reinforced Armor +40",
	[1863] = "Feedback 2",
	[1864] = "Feedback 3",
	[1865] = "Feedback 4",
	[1866] = "Feedback 5",
	[1883] = "Intellect +7",
	[1884] = "Spirit +9",
	[1885] = "Strength +9",
	[1886] = "Stamina +9",
	[1887] = "Agility +7",
	[1888] = "+5 All Resistances",
	[1889] = "Armor +70",
	[1890] = "Spirit +9",
	[1891] = "All Stats +4",
	[1892] = "Health +100",
	[1893] = "Mana +100",
	[1894] = "Icy Weapon",
	[1895] = "Damage +9",
	[1896] = "Weapon Damage +9",
	[1897] = "Weapon Damage +5",
	[1898] = "Lifestealing",
	[1899] = "Unholy Weapon",
	[1900] = "Crusader",
	[1901] = "Intellect +9",
	[1903] = "Spirit +9",
	[1904] = "Intellect +9",
	[1923] = "+3 Fire Resistance",
	[1943] = "+8 Defense",
	[1944] = "+5 Defense",
	[1945] = "+6 Defense",
	[1946] = "+7 Defense",
	[1947] = "+7 Defense",
	[1948] = "+9 Defense",
	[1949] = "+9 Defense",
	[1950] = "+10 Defense",
	[1951] = "+11 Defense",
	[1952] = "+13 Defense",
	[1953] = "+15 Defense",
	[1954] = "+17 Defense",
	[1955] = "+21 Defense",
	[1956] = "+11 Defense",
	[1957] = "+12 Defense",
	[1958] = "+13 Defense",
	[1959] = "+14 Defense",
	[1960] = "+15 Defense",
	[1961] = "+16 Defense",
	[1962] = "+17 Defense",
	[1963] = "+18 Defense",
	[1964] = "+19 Defense",
	[1965] = "+19 Defense",
	[1966] = "+20 Defense",
	[1967] = "+21 Defense",
	[1968] = "+22 Defense",
	[1969] = "+23 Defense",
	[1970] = "+23 Defense",
	[1971] = "+24 Defense",
	[1972] = "+25 Defense",
	[1973] = "+25 Defense",
	[1983] = "+1% Block",
	[1984] = "+2% Block",
	[1985] = "+3% Block",
	[1986] = "+4% Block",
	[1987] = "Block Level 14",
	[1988] = "Block Level 15",
	[1989] = "Block Level 16",
	[1990] = "Block Level 17",
	[1991] = "Block Level 18",
	[1992] = "Block Level 19",
	[1993] = "Block Level 20",
	[1994] = "Block Level 21",
	[1995] = "Block Level 22",
	[1996] = "Block Level 23",
	[1997] = "Block Level 24",
	[1998] = "Block Level 25",
	[1999] = "Block Level 26",
	[2000] = "Block Level 27",
	[2001] = "Block Level 28",
	[2002] = "Block Level 29",
	[2003] = "Block Level 30",
	[2004] = "Block Level 31",
	[2005] = "Block Level 32",
	[2006] = "Block Level 33",
	[2007] = "Block Level 34",
	[2008] = "Block Level 35",
	[2009] = "Block Level 36",
	[2010] = "Block Level 37",
	[2011] = "Block Level 38",
	[2012] = "Block Level 39",
	[2013] = "Block Level 40",
	[2014] = "Block Level 41",
	[2015] = "Block Level 42",
	[2016] = "Block Level 43",
	[2017] = "Block Level 44",
	[2018] = "Block Level 45",
	[2019] = "Block Level 46",
	[2020] = "Block Level 47",
	[2021] = "Block Level 48",
	[2022] = "Block Level 49",
	[2023] = "Block Level 50",
	[2024] = "Block Level 51",
	[2025] = "Block Level 52",
	[2026] = "Block Level 53",
	[2027] = "Block Level 54",
	[2028] = "Block Level 55",
	[2029] = "Block Level 56",
	[2030] = "Block Level 57",
	[2031] = "Block Level 58",
	[2032] = "Block Level 59",
	[2033] = "Block Level 60",
	[2034] = "Block Level 61",
	[2035] = "Block Level 62",
	[2036] = "Block Level 63",
	[2037] = "Block Level 64",
	[2038] = "Block Level 65",
	[2039] = "Block Level 66",
	[2040] = "+2 Ranged Attack Power",
	[2041] = "+5 Ranged Attack Power",
	[2042] = "+7 Ranged Attack Power",
	[2043] = "+10 Ranged Attack Power",
	[2044] = "+12 Ranged Attack Power",
	[2045] = "+14 Ranged Attack Power",
	[2046] = "+17 Ranged Attack Power",
	[2047] = "+19 Ranged Attack Power",
	[2048] = "+22 Ranged Attack Power",
	[2049] = "+24 Ranged Attack Power",
	[2050] = "+26 Ranged Attack Power",
	[2051] = "+29 Ranged Attack Power",
	[2052] = "+31 Ranged Attack Power",
	[2053] = "+34 Ranged Attack Power",
	[2054] = "+36 Ranged Attack Power",
	[2055] = "+38 Ranged Attack Power",
	[2056] = "+41 Ranged Attack Power",
	[2057] = "+43 Ranged Attack Power",
	[2058] = "+46 Ranged Attack Power",
	[2059] = "+48 Ranged Attack Power",
	[2060] = "+50 Ranged Attack Power",
	[2061] = "+53 Ranged Attack Power",
	[2062] = "+55 Ranged Attack Power",
	[2063] = "+58 Ranged Attack Power",
	[2064] = "+60 Ranged Attack Power",
	[2065] = "+62 Ranged Attack Power",
	[2066] = "+65 Ranged Attack Power",
	[2067] = "+67 Ranged Attack Power",
	[2068] = "+70 Ranged Attack Power",
	[2069] = "+72 Ranged Attack Power",
	[2070] = "+74 Ranged Attack Power",
	[2071] = "+77 Ranged Attack Power",
	[2072] = "+79 Ranged Attack Power",
	[2073] = "+82 Ranged Attack Power",
	[2074] = "+84 Ranged Attack Power",
	[2075] = "+86 Ranged Attack Power",
	[2076] = "+89 Ranged Attack Power",
	[2077] = "+91 Ranged Attack Power",
	[2078] = "+1% Dodge",
	[2079] = "+1 Arcane Spell Damage",
	[2080] = "+3 Arcane Spell Damage",
	[2081] = "+4 Arcane Spell Damage",
	[2082] = "+6 Arcane Spell Damage",
	[2083] = "+7 Arcane Spell Damage",
	[2084] = "+9 Arcane Spell Damage",
	[2085] = "+10 Arcane Spell Damage",
	[2086] = "+11 Arcane Spell Damage",
	[2087] = "+13 Arcane Spell Damage",
	[2088] = "+14 Arcane Spell Damage",
	[2089] = "+16 Arcane Spell Damage",
	[2090] = "+17 Arcane Spell Damage",
	[2091] = "+19 Arcane Spell Damage",
	[2092] = "+20 Arcane Spell Damage",
	[2093] = "+21 Arcane Spell Damage",
	[2094] = "+23 Arcane Spell Damage",
	[2095] = "+24 Arcane Spell Damage",
	[2096] = "+26 Arcane Spell Damage",
	[2097] = "+27 Arcane Spell Damage",
	[2098] = "+29 Arcane Spell Damage",
	[2099] = "+30 Arcane Spell Damage",
	[2100] = "+31 Arcane Spell Damage",
	[2101] = "+33 Arcane Spell Damage",
	[2102] = "+34 Arcane Spell Damage",
	[2103] = "+36 Arcane Spell Damage",
	[2104] = "+37 Arcane Spell Damage",
	[2105] = "+39 Arcane Spell Damage",
	[2106] = "+40 Arcane Spell Damage",
	[2107] = "+41 Arcane Spell Damage",
	[2108] = "+43 Arcane Spell Damage",
	[2109] = "+44 Arcane Spell Damage",
	[2110] = "+46 Arcane Spell Damage",
	[2111] = "+47 Arcane Spell Damage",
	[2112] = "+49 Arcane Spell Damage",
	[2113] = "+50 Arcane Spell Damage",
	[2114] = "+51 Arcane Spell Damage",
	[2115] = "+53 Arcane Spell Damage",
	[2116] = "+54 Arcane Spell Damage",
	[2117] = "+1 Shadow Spell Damage",
	[2118] = "+3 Shadow Spell Damage",
	[2119] = "+4 Shadow Spell Damage",
	[2120] = "+6 Shadow Spell Damage",
	[2121] = "+7 Shadow Spell Damage",
	[2122] = "+9 Shadow Spell Damage",
	[2123] = "+10 Shadow Spell Damage",
	[2124] = "+11 Shadow Spell Damage",
	[2125] = "+13 Shadow Spell Damage",
	[2126] = "+14 Shadow Spell Damage",
	[2127] = "+16 Shadow Spell Damage",
	[2128] = "+17 Shadow Spell Damage",
	[2129] = "+19 Shadow Spell Damage",
	[2130] = "+20 Shadow Spell Damage",
	[2131] = "+21 Shadow Spell Damage",
	[2132] = "+23 Shadow Spell Damage",
	[2133] = "+24 Shadow Spell Damage",
	[2134] = "+26 Shadow Spell Damage",
	[2135] = "+27 Shadow Spell Damage",
	[2136] = "+29 Shadow Spell Damage",
	[2137] = "+30 Shadow Spell Damage",
	[2138] = "+31 Shadow Spell Damage",
	[2139] = "+33 Shadow Spell Damage",
	[2140] = "+34 Shadow Spell Damage",
	[2141] = "+36 Shadow Spell Damage",
	[2142] = "+37 Shadow Spell Damage",
	[2143] = "+39 Shadow Spell Damage",
	[2144] = "+40 Shadow Spell Damage",
	[2145] = "+41 Shadow Spell Damage",
	[2146] = "+43 Shadow Spell Damage",
	[2147] = "+44 Shadow Spell Damage",
	[2148] = "+46 Shadow Spell Damage",
	[2149] = "+47 Shadow Spell Damage",
	[2150] = "+49 Shadow Spell Damage",
	[2151] = "+50 Shadow Spell Damage",
	[2152] = "+51 Shadow Spell Damage",
	[2153] = "+53 Shadow Spell Damage",
	[2154] = "+54 Shadow Spell Damage",
	[2155] = "+1 Fire Spell Damage",
	[2156] = "+3 Fire Spell Damage",
	[2157] = "+4 Fire Spell Damage",
	[2158] = "+6 Fire Spell Damage",
	[2159] = "+7 Fire Spell Damage",
	[2160] = "+9 Fire Spell Damage",
	[2161] = "+10 Fire Spell Damage",
	[2162] = "+11 Fire Spell Damage",
	[2163] = "+13 Fire Spell Damage",
	[2164] = "+14 Fire Spell Damage",
	[2165] = "+16 Fire Spell Damage",
	[2166] = "+17 Fire Spell Damage",
	[2167] = "+19 Fire Spell Damage",
	[2168] = "+20 Fire Spell Damage",
	[2169] = "+21 Fire Spell Damage",
	[2170] = "+23 Fire Spell Damage",
	[2171] = "+24 Fire Spell Damage",
	[2172] = "+26 Fire Spell Damage",
	[2173] = "+27 Fire Spell Damage",
	[2174] = "+29 Fire Spell Damage",
	[2175] = "+30 Fire Spell Damage",
	[2176] = "+31 Fire Spell Damage",
	[2177] = "+33 Fire Spell Damage",
	[2178] = "+34 Fire Spell Damage",
	[2179] = "+36 Fire Spell Damage",
	[2180] = "+37 Fire Spell Damage",
	[2181] = "+39 Fire Spell Damage",
	[2182] = "+40 Fire Spell Damage",
	[2183] = "+41 Fire Spell Damage",
	[2184] = "+43 Fire Spell Damage",
	[2185] = "+44 Fire Spell Damage",
	[2186] = "+46 Fire Spell Damage",
	[2187] = "+47 Fire Spell Damage",
	[2188] = "+49 Fire Spell Damage",
	[2189] = "+50 Fire Spell Damage",
	[2190] = "+51 Fire Spell Damage",
	[2191] = "+53 Fire Spell Damage",
	[2192] = "+54 Fire Spell Damage",
	[2193] = "+1 Holy Spell Damage",
	[2194] = "+3 Holy Spell Damage",
	[2195] = "+4 Holy Spell Damage",
	[2196] = "+6 Holy Spell Damage",
	[2197] = "+7 Holy Spell Damage",
	[2198] = "+9 Holy Spell Damage",
	[2199] = "+10 Holy Spell Damage",
	[2200] = "+11 Holy Spell Damage",
	[2201] = "+13 Holy Spell Damage",
	[2202] = "+14 Holy Spell Damage",
	[2203] = "+16 Holy Spell Damage",
	[2204] = "+17 Holy Spell Damage",
	[2205] = "+19 Holy Spell Damage",
	[2206] = "+20 Holy Spell Damage",
	[2207] = "+21 Holy Spell Damage",
	[2208] = "+23 Holy Spell Damage",
	[2209] = "+24 Holy Spell Damage",
	[2210] = "+26 Holy Spell Damage",
	[2211] = "+27 Holy Spell Damage",
	[2212] = "+29 Holy Spell Damage",
	[2213] = "+30 Holy Spell Damage",
	[2214] = "+31 Holy Spell Damage",
	[2215] = "+33 Holy Spell Damage",
	[2216] = "+34 Holy Spell Damage",
	[2217] = "+36 Holy Spell Damage",
	[2218] = "+37 Holy Spell Damage",
	[2219] = "+39 Holy Spell Damage",
	[2220] = "+40 Holy Spell Damage",
	[2221] = "+41 Holy Spell Damage",
	[2222] = "+43 Holy Spell Damage",
	[2223] = "+44 Holy Spell Damage",
	[2224] = "+46 Holy Spell Damage",
	[2225] = "+47 Holy Spell Damage",
	[2226] = "+49 Holy Spell Damage",
	[2227] = "+50 Holy Spell Damage",
	[2228] = "+51 Holy Spell Damage",
	[2229] = "+53 Holy Spell Damage",
	[2230] = "+54 Holy Spell Damage",
	[2231] = "+1 Frost Spell Damage",
	[2232] = "+3 Frost Spell Damage",
	[2233] = "+4 Frost Spell Damage",
	[2234] = "+6 Frost Spell Damage",
	[2235] = "+7 Frost Spell Damage",
	[2236] = "+9 Frost Spell Damage",
	[2237] = "+10 Frost Spell Damage",
	[2238] = "+11 Frost Spell Damage",
	[2239] = "+13 Frost Spell Damage",
	[2240] = "+14 Frost Spell Damage",
	[2241] = "+16 Frost Spell Damage",
	[2242] = "+17 Frost Spell Damage",
	[2243] = "+19 Frost Spell Damage",
	[2244] = "+20 Frost Spell Damage",
	[2245] = "+21 Frost Spell Damage",
	[2246] = "+23 Frost Spell Damage",
	[2247] = "+24 Frost Spell Damage",
	[2248] = "+26 Frost Spell Damage",
	[2249] = "+27 Frost Spell Damage",
	[2250] = "+29 Frost Spell Damage",
	[2251] = "+30 Frost Spell Damage",
	[2252] = "+31 Frost Spell Damage",
	[2253] = "+33 Frost Spell Damage",
	[2254] = "+34 Frost Spell Damage",
	[2255] = "+36 Frost Spell Damage",
	[2256] = "+37 Frost Spell Damage",
	[2257] = "+39 Frost Spell Damage",
	[2258] = "+40 Frost Spell Damage",
	[2259] = "+41 Frost Spell Damage",
	[2260] = "+43 Frost Spell Damage",
	[2261] = "+44 Frost Spell Damage",
	[2262] = "+46 Frost Spell Damage",
	[2263] = "+47 Frost Spell Damage",
	[2264] = "+49 Frost Spell Damage",
	[2265] = "+50 Frost Spell Damage",
	[2266] = "+51 Frost Spell Damage",
	[2267] = "+53 Frost Spell Damage",
	[2268] = "+54 Frost Spell Damage",
	[2269] = "+1 Nature Spell Damage",
	[2270] = "+3 Nature Spell Damage",
	[2271] = "+4 Nature Spell Damage",
	[2272] = "+6 Nature Spell Damage",
	[2273] = "+7 Nature Spell Damage",
	[2274] = "+9 Nature Spell Damage",
	[2275] = "+10 Nature Spell Damage",
	[2276] = "+11 Nature Spell Damage",
	[2277] = "+13 Nature Spell Damage",
	[2278] = "+14 Nature Spell Damage",
	[2279] = "+16 Nature Spell Damage",
	[2280] = "+17 Nature Spell Damage",
	[2281] = "+19 Nature Spell Damage",
	[2282] = "+20 Nature Spell Damage",
	[2283] = "+21 Nature Spell Damage",
	[2284] = "+23 Nature Spell Damage",
	[2285] = "+24 Nature Spell Damage",
	[2286] = "+26 Nature Spell Damage",
	[2287] = "+27 Nature Spell Damage",
	[2288] = "+29 Nature Spell Damage",
	[2289] = "+30 Nature Spell Damage",
	[2290] = "+31 Nature Spell Damage",
	[2291] = "+33 Nature Spell Damage",
	[2292] = "+34 Nature Spell Damage",
	[2293] = "+36 Nature Spell Damage",
	[2294] = "+37 Nature Spell Damage",
	[2295] = "+39 Nature Spell Damage",
	[2296] = "+40 Nature Spell Damage",
	[2297] = "+41 Nature Spell Damage",
	[2298] = "+43 Nature Spell Damage",
	[2299] = "+44 Nature Spell Damage",
	[2300] = "+46 Nature Spell Damage",
	[2301] = "+47 Nature Spell Damage",
	[2302] = "+49 Nature Spell Damage",
	[2303] = "+50 Nature Spell Damage",
	[2304] = "+51 Nature Spell Damage",
	[2305] = "+53 Nature Spell Damage",
	[2306] = "+54 Nature Spell Damage",
	[2307] = "+2 Healing Spells",
	[2308] = "+4 Healing Spells",
	[2309] = "+7 Healing Spells",
	[2310] = "+9 Healing Spells",
	[2311] = "+11 Healing Spells",
	[2312] = "+13 Healing Spells",
	[2313] = "+15 Healing Spells",
	[2314] = "+18 Healing Spells",
	[2315] = "+20 Healing Spells",
	[2316] = "+22 Healing Spells",
	[2317] = "+24 Healing Spells",
	[2318] = "+26 Healing Spells",
	[2319] = "+29 Healing Spells",
	[2320] = "+31 Healing Spells",
	[2321] = "+33 Healing Spells",
	[2322] = "+35 Healing Spells",
	[2323] = "+37 Healing Spells",
	[2324] = "+40 Healing Spells",
	[2325] = "+42 Healing Spells",
	[2326] = "+44 Healing Spells",
	[2327] = "+46 Healing Spells",
	[2328] = "+48 Healing Spells",
	[2329] = "+51 Healing Spells",
	[2330] = "+53 Healing Spells",
	[2331] = "+55 Healing Spells",
	[2332] = "+57 Healing Spells",
	[2333] = "+59 Healing Spells",
	[2334] = "+62 Healing Spells",
	[2335] = "+64 Healing Spells",
	[2336] = "+66 Healing Spells",
	[2337] = "+68 Healing Spells",
	[2338] = "+70 Healing Spells",
	[2339] = "+73 Healing Spells",
	[2340] = "+75 Healing Spells",
	[2341] = "+77 Healing Spells",
	[2342] = "+79 Healing Spells",
	[2343] = "+81 Healing Spells",
	[2344] = "+84 Healing Spells",
	[2363] = "+1 mana every 5 sec.",
	[2364] = "+1 mana every 5 sec.",
	[2365] = "+1 mana every 5 sec.",
	[2366] = "+2 mana every 5 sec.",
	[2367] = "+2 mana every 5 sec.",
	[2368] = "+2 mana every 5 sec.",
	[2369] = "+3 mana every 5 sec.",
	[2370] = "+3 mana every 5 sec.",
	[2371] = "+4 mana every 5 sec.",
	[2372] = "+4 mana every 5 sec.",
	[2373] = "+4 mana every 5 sec.",
	[2374] = "+5 mana every 5 sec.",
	[2375] = "+5 mana every 5 sec.",
	[2376] = "+6 mana every 5 sec.",
	[2377] = "+6 mana every 5 sec.",
	[2378] = "+6 mana every 5 sec.",
	[2379] = "+7 mana every 5 sec.",
	[2380] = "+7 mana every 5 sec.",
	[2381] = "+8 mana every 5 sec.",
	[2382] = "+8 mana every 5 sec.",
	[2383] = "+8 mana every 5 sec.",
	[2384] = "+9 mana every 5 sec.",
	[2385] = "+9 mana every 5 sec.",
	[2386] = "+10 mana every 5 sec.",
	[2387] = "+10 mana every 5 sec.",
	[2388] = "+10 mana every 5 sec.",
	[2389] = "+11 mana every 5 sec.",
	[2390] = "+11 mana every 5 sec.",
	[2391] = "+12 mana every 5 sec.",
	[2392] = "+12 mana every 5 sec.",
	[2393] = "+12 mana every 5 sec.",
	[2394] = "+13 mana every 5 sec.",
	[2395] = "+13 mana every 5 sec.",
	[2396] = "+14 mana every 5 sec.",
	[2397] = "+14 mana every 5 sec.",
	[2398] = "+14 mana every 5 sec.",
	[2399] = "+15 mana every 5 sec.",
	[2400] = "+15 mana every 5 sec.",
	[2401] = "+1 health every 5 sec.",
	[2402] = "+1 health every 5 sec.",
	[2403] = "+1 health every 5 sec.",
	[2404] = "+1 health every 5 sec.",
	[2405] = "+1 health every 5 sec.",
	[2406] = "+2 health every 5 sec.",
	[2407] = "+2 health every 5 sec.",
	[2408] = "+2 health every 5 sec.",
	[2409] = "+2 health every 5 sec.",
	[2410] = "+3 health every 5 sec.",
	[2411] = "+3 health every 5 sec.",
	[2412] = "+3 health every 5 sec.",
	[2413] = "+3 health every 5 sec.",
	[2414] = "+4 health every 5 sec.",
	[2415] = "+4 health every 5 sec.",
	[2416] = "+4 health every 5 sec.",
	[2417] = "+4 health every 5 sec.",
	[2418] = "+5 health every 5 sec.",
	[2419] = "+5 health every 5 sec.",
	[2420] = "+5 health every 5 sec.",
	[2421] = "+5 health every 5 sec.",
	[2422] = "+6 health every 5 sec.",
	[2423] = "+6 health every 5 sec.",
	[2424] = "+6 health every 5 sec.",
	[2425] = "+6 health every 5 sec.",
	[2426] = "+7 health every 5 sec.",
	[2427] = "+7 health every 5 sec.",
	[2428] = "+7 health every 5 sec.",
	[2429] = "+7 health every 5 sec.",
	[2430] = "+8 health every 5 sec.",
	[2431] = "+8 health every 5 sec.",
	[2432] = "+8 health every 5 sec.",
	[2433] = "+8 health every 5 sec.",
	[2434] = "+9 health every 5 sec.",
	[2435] = "+9 health every 5 sec.",
	[2436] = "+9 health every 5 sec.",
	[2437] = "+9 health every 5 sec.",
	[2438] = "+10 health every 5 sec.",
	[2443] = "Frost Spell Damage +7",
	[2463] = "+7 Fire Resistance",
	[2483] = "+5 Fire Resistance",
	[2484] = "+5 Frost Resistance",
	[2485] = "+5 Arcane Resistance",
	[2486] = "+5 Nature Resistance",
	[2487] = "+5 Shadow Resistance",
	[2488] = "+5 All Resistances",
	[2503] = "Defense +3",
	[2504] = "Spell Damage +30",
	[2505] = "Healing Spells +55",
	[2506] = "Critical +2%",
	[2523] = "+3% Hit",
	[2543] = "Attack Speed +1%",
	[2544] = "Healing and Spell Damage +8",
	[2545] = "Dodge +1%",
	[2563] = "Strength +15",
	[2564] = "Agility +15",
	[2565] = "Mana Regen 4 per 5 sec.",
	[2566] = "Healing Spells +24",
	[2567] = "Spirit +20",
	[2568] = "Intellect +22",
	[2583] = "Defense +7/Stamina +10/Block Value +15",
	[2584] = "Defense +7/Stamina +10/Healing Spells +24",
	[2585] = "Attack Power +28/Dodge +1%",
	[2586] = "Ranged Attack Power +24/Stamina +10/Hit +1%",
	[2587] = "Healing and Spell Damage +13/Intellect +15",
	[2588] = "Healing and Spell Damage +18/Spell Hit +1%",
	[2589] = "Healing and Spell Damage +18/Stamina +10",
	[2590] = "Mana Regen +4/Stamina +10/Healing Spells +24",
	[2591] = "Intellect +10/Stamina +10/Healing Spells +24",
	[2603] = "Eternium Line",
	[2604] = "+33 Healing Spells",
	[2605] = "+18 Spell Damage and Healing",
	[2606] = "+30 Attack Power",
	[2607] = "+12 Damage and Healing Spells",
	[2608] = "+13 Damage and Healing Spells",
	[2609] = "+15 Damage and Healing Spells",
	[2610] = "+14 Damage and Healing Spells",
	[2611] = "REUSE Random - 15 Spells All",
	[2612] = "+18 Damage and Healing Spells",
	[2613] = "Threat +2%",
	[2614] = "Shadow Damage +20",
	[2615] = "Frost Damage +20",
	[2616] = "Fire Damage +20",
	[2617] = "Healing Spells +30",
	[2618] = "Agility +15",
	[2619] = "+15 Fire Resistance",
	[2620] = "+15 Nature Resistance",
	[2621] = "Subtlety",
	[2622] = "Dodge +1%",
	[2623] = "Minor Wizard Oil",
	[2624] = "Minor Mana Oil",
	[2625] = "Lesser Mana Oil",
	[2626] = "Lesser Wizard Oil",
	[2627] = "Wizard Oil",
	[2628] = "Brilliant Wizard Oil",
	[2629] = "Brilliant Mana Oil",
	[2630] = "Deadly Poison V",
	[2646] = "Agility +25",
	[2681] = "+10 Nature Resistance",
	[2682] = "+10 Frost Resistance",
	[2683] = "+10 Shadow Resistance",
	[2684] = "+100 Attack Power vs Undead",
	[2685] = "+60 Spell Damage vs Undead",
	[2715] = "Healing +31 and 5 mana per 5 sec.",
	[2716] = "Stamina +16 and Armor +100",
	[2717] = "Attack Power +26 and +1% Critical Strike",
	[2721] = "Spell Damage +15 and +1% Spell Critical Strike",
	[2802] = "+$i Agility",
	[2803] = "+$i Stamina",
	[2804] = "+$i Intellect",
	[2805] = "+$i Strength",
	[2806] = "+$i Spirit",
	[2815] = "+$i Dodge",
	[2817] = "+$i Arcane Resistance",
	[2818] = "+$i Fire Resistance",
	[2819] = "+$i Frost Resistance",
	[2820] = "+$i Nature Resistance",
	[2821] = "+$i Shadow Resistance",
	[2823] = "+$i Critical Strike",
	[2825] = "+$i Attack Power",
	[2826] = "+$i Block",
	[3726] = "+$i Haste",
	--{ Atal'ai Signet shoulder enchants from SoD's Signets of the Lost Temple quest turn in of Flask of Nightmarish Mojo
	[7325] = "+9 Spell Damage and Healing", 							--{ Atal'ai Signet of Mojo
	[7326] = "+18 Healing Spells", 										--{ Atal'ai Signet of Serenity
	[7328] = "+15 Attack Power", 										--{ Atal'ai Signet of Might
	--{ Zul'Gurub Leg/Head enchants SoD
	[7613] = "Stamina +20/Intellect +10/Healing Spells +24", 			--{ Animist's Caress
	[7614] = "Stamina +20/Hit +1%/Healing and Spell Damage +12", 		--{ Animist's Balance
	[7615] = "Stamina +20/Strength +10/Agility +10", 					--{ Animist's Fury
	[7616] = "Stamina +20/Strength +10/Defense +7", 					--{ Animist's Roar
	[7617] = "Stamina +20/Agility +10/Hit +1%", 						--{ Falcon's Call
	[7618] = "Stamina +20/Defense +7/Healing and Spell Damage +12", 	--{ Syncretist's Seal
	[7619] = "Stamina +20/Strength +10/Healing and Spell Damage +12", 	--{ Syncretist's Sigil
	[7620] = "Stamina +20/Intellect +10/Healing Spells +22", 			--{ Syncretist's Crest
	[7621] = "Stamina +20/Intellect +10/Healing and Spell Damage +12", 	--{ Syncretist's Emblem
	[7622] = "Stamina +20/Intellect +10/Healing Spells +22", 			--{ Prophetic Aura
	[7623] = "Stamina +20/Intellect +10/Healing and Spell Damage +12", 	--{ Prophetic Curse
	[7624] = "Stamina +20/Agility +10/Defense +7", 						--{ Death's Embrace
	[7625] = "Stamina +20/Agility +10/Hit +1%", 						--{ Death's Advance
	[7626] = "Stamina +20/Strength +10/Healing and Spell Damage +12", 	--{ Vodouisant's Embrace
	[7627] = "Stamina +20/Hit +1%/Healing and Spell Damage +12", 		--{ Vodouisant's Shroud
	[7628] = "Stamina +20/Intellect +10/Healing Spells +22", 			--{ Vodouisant's Charm
	[7629] = "Stamina +20/Defense +7/Block Chance +2%", 				--{ Vodouisant's Vigilance
	[7630] = "Stamina +20/Hit +1%/Healing and Spell Damage +12", 		--{ Hoodoo Hex
	[7631] = "Stamina +20/Hit +1%/Defense +7", 							--{ Hoodoo Curse
	[7632] = "Stamina +20/Strength +10/Agility +10", 					--{ Presence of Might
	[7633] = "Stamina +20/Defense +7/Block Value +15", 					--{ Presence of Valor
	[7634] = "Stamina +20/Intellect +10/Healing and Spell Damage +12", 	--{ Presence of Sight
	[7635] = "Stamina +20/Agility +10/Strength +10", 					--{ Falcon's Fury
	--{ SoD Phase 6/7/8 Enchants
	[7645] = "Living Stats",									--{ Enchant Chest - Living Stats
	[7646] = "Holy Damage +20",									--{ Enchant Gloves - Holy Power
	[7647] = "Arcane Damage +20",								--{ Enchant Gloves - Arcane Power
	[7648] = "Spell Damage and Healing +10",					--{ Glowing Chitin Armor Kit
	[7649] = "Thorns +20",										--{ Sharpened Chitin Armor Kit
	[7655] = "+12 Spell Damage",								--{ Enchant Bracer - Spell Power
	[7656] = "Agility +9",										--{ Enchant Bracer - Agility
	[7657] = "Scope (+10 Damage)",								--{ Obsidian Scope
	[7659] = "+9 Intellect",									--{ Enchant Off-Hand - Superior Intellect
	[7660] = "+12 Spirit",										--{ Enchant Off-Hand - Excellent Spirit
	[7661] = "+6 Intellect and +5 Spirit",						--{ Enchant Off-Hand - Wisdom
	[7662] = "+65 Spell Power",									--{ Enchant 2H Weapon - Spellblasting
	[7663] = "+12 Stamina",										--{ Enchant Shield - Excellent Stamina
	[7664] = "+1% Critical Strike Chance",						--{ Enchant Shield - Critical Strike
	[7665] = "+16 Spell Power",									--{ Enchant Bracer - Greater Spellpower
	[7666] = "+15 Strength",									--{ Enchant Gloves - Superior Strength
	[7667] = "+5 Agility",										--{ Enchant Cloak - Agility
	[7882] = "Healing +31 and +5 mana per 5 sec",				--{ Resilience of the Scourge
	[7883] = "Spell Damage +15 and +1% Critical Strike",		--{ Power of the Scourge
	[7884] = "Attack Power +26 and +1% Critical Strike",		--{ Might of the Scourge
	[7885] = "Stamina +16/Defense +7",							--{ Fortitude of the Scourge
	[7940] = "Grand Crusader",									--{ Enchant Weapon - Grand Crusader
	[7941] = "Grand Arcanist",									--{ Enchant 2H Weapon - Grand Arcanist
	[7942] = "Grand Sorcerer",									--{ Enchant Weapon - Grand Sorcerer
	[7943] = "Grand Inquisitor",								--{ Enchant 2H Weapon - Grand Inquisitor
}

local DCS_ABBREV_ENCHANT_IDS = {
	[1] = "RB 3",
	[2] = "FB 1",
	[3] = "FT 3",
	[4] = "FT 2",
	[5] = "FT 1",
	[6] = "RB 2",
	[7] = "D Psn",
	[8] = "D Psn II",
	[9] = "Psn 15 Dmg",
	[10] = "Psn 20 Dmg",
	[11] = "Psn 25 Dmg",
	[12] = "FB 2",
	[13] = "Sharp +3",
	[14] = "Sharp +4",
	[15] = "AC +8",
	[16] = "AC +16",
	[17] = "AC +24",
	[18] = "AC +32",
	[19] = "Weight +2",
	[20] = "Weight +3",
	[21] = "Weight +4",
	[22] = "Crp Psn",
	[23] = "MN Psn II",
	[24] = "Mana +5",
	[25] = "Shdw Oil",
	[26] = "Frost Oil",
	[27] = "Sundered",
	[28] = "+4 All Res",
	[29] = "RB 1",
	[30] = "Scp +1 Dmg",
	[31] = "BS +4",
	[32] = "Scp +2 Dmg",
	[33] = "Scp +3 Dmg",
	[34] = "CW +3% A Spd",
	[35] = "MN Psn",
	[36] = "Fiery Blaze",
	[37] = "Chain",
	[38] = "Def Skill +3",
	[39] = "Sharp +1",
	[40] = "Sharp +2",
	[41] = "HP +5",
	[42] = "Psn Insta 20",
	[43] = "Spike 8-12",
	[44] = "Absorb 10",
	[63] = "Absorb 25",
	[64] = "Spi +3",
	[65] = "+1 All Res",
	[66] = "Stam +1",
	[67] = "+1 Dmg",
	[68] = "+1 Str",
	[69] = "+2 Str",
	[70] = "+3 Str",
	[71] = "+1 Stam",
	[72] = "+2 Stam",
	[73] = "+3 Stam",
	[74] = "+1 Agi",
	[75] = "+2 Agi",
	[76] = "+3 Agi",
	[77] = "+2 Dmg",
	[78] = "+3 Dmg",
	[79] = "+1 Int",
	[80] = "+2 Int",
	[81] = "+3 Int",
	[82] = "+1 Spi",
	[83] = "+2 Spi",
	[84] = "+3 Spi",
	[85] = "+3 AC",
	[86] = "+8 AC",
	[87] = "+12 AC",
	[89] = "+16 AC",
	[90] = "+4 Agi",
	[91] = "+5 Agi",
	[92] = "+6 Agi",
	[93] = "+7 Agi",
	[94] = "+4 Int",
	[95] = "+5 Int",
	[96] = "+6 Int",
	[97] = "+7 Int",
	[98] = "+4 Spi",
	[99] = "+5 Spi",
	[100] = "+6 Spi",
	[101] = "+7 Spi",
	[102] = "+4 Stam",
	[103] = "+5 Stam",
	[104] = "+6 Stam",
	[105] = "+7 Stam",
	[106] = "+4 Str",
	[107] = "+5 Str",
	[108] = "+6 Str",
	[109] = "+7 Str",
	[110] = "+1 Def",
	[111] = "+1 Def",
	[112] = "+2 Def",
	[113] = "+3 Def",
	[114] = "+3 Def",
	[115] = "+4 Def",
	[116] = "+5 Def",
	[117] = "+4 Dmg",
	[118] = "+5 Dmg",
	[119] = "+6 Dmg",
	[120] = "+7 Dmg",
	[121] = "+20 AC",
	[122] = "+24 AC",
	[123] = "+28 AC",
	[124] = "FT Tot 1",
	[125] = "Swords +1",
	[126] = "Swords +2",
	[127] = "Swords +3",
	[128] = "Swords +4",
	[129] = "Swords +5",
	[130] = "Swords +6",
	[131] = "Swords +7",
	[132] = "2H Swords +1",
	[133] = "2H Swords +2",
	[134] = "2H Swords +3",
	[135] = "2H Swords +4",
	[136] = "2H Swords +5",
	[137] = "2H Swords +6",
	[138] = "2H Swords +7",
	[139] = "Maces +1",
	[140] = "Maces +2",
	[141] = "Maces +3",
	[142] = "Maces +4",
	[143] = "Maces +5",
	[144] = "Maces +6",
	[145] = "Maces +7",
	[146] = "2H Maces +1",
	[147] = "2H Maces +2",
	[148] = "2H Maces +3",
	[149] = "2H Maces +4",
	[150] = "2H Maces +5",
	[151] = "2H Maces +6",
	[152] = "2H Maces +7",
	[153] = "Axes +1",
	[154] = "Axes +2",
	[155] = "Axes +3",
	[156] = "Axes +4",
	[157] = "Axes +5",
	[158] = "Axes +6",
	[159] = "Axes +7",
	[160] = "2H Axes +1",
	[161] = "2H Axes +2",
	[162] = "2H Axes +3",
	[163] = "2H Axes +4",
	[164] = "2H Axes +5",
	[165] = "2H Axes +6",
	[166] = "2H Axes +7",
	[167] = "Daggers +1",
	[168] = "Daggers +2",
	[169] = "Daggers +3",
	[170] = "Daggers +4",
	[171] = "Daggers +5",
	[172] = "Daggers +6",
	[173] = "Daggers +7",
	[174] = "Guns +1",
	[175] = "Guns +2",
	[176] = "Guns +3",
	[177] = "Guns +4",
	[178] = "Guns +5",
	[179] = "Guns +6",
	[180] = "Guns +7",
	[181] = "Bows +1",
	[182] = "Bows +2",
	[183] = "Bows +3",
	[184] = "Bows +4",
	[185] = "Bows +5",
	[186] = "Bows +6",
	[187] = "Bows +7",
	[188] = "+2 Bst Slay",
	[189] = "+4 Bst Slay",
	[190] = "+6 Bst Slay",
	[191] = "+8 Bst Slay",
	[192] = "+10 Bst Slay",
	[193] = "+12 Bst Slay",
	[194] = "+14 Bst Slay",
	[195] = "Crit +1%",
	[196] = "Crit +2%",
	[197] = "Crit +3%",
	[198] = "Crit +4%",
	[199] = "10% On Hit 10 SB Dmg",
	[200] = "10% On Hit 20 SB Dmg",
	[201] = "10% On Hit 30 SB Dmg",
	[202] = "10% On Hit 40 SB Dmg",
	[203] = "10% On Hit 50 SB Dmg",
	[204] = "10% On Hit 60 SB Dmg",
	[205] = "10% On Hit 70 SB Dmg",
	[206] = "Heals +2",
	[207] = "Heals +4",
	[208] = "Heals +7",
	[209] = "Heals +9",
	[210] = "Heals +11",
	[211] = "Heals +13",
	[212] = "Heals +15",
	[213] = "Fire +1",
	[214] = "Fire +3",
	[215] = "Fire +4",
	[216] = "Fire +6",
	[217] = "Fire +7",
	[218] = "Fire Dmg +9",
	[219] = "Fire Dmg +10",
	[220] = "Nat +1",
	[221] = "Nat +3",
	[222] = "Nat +4",
	[223] = "Nat +6",
	[224] = "Nat +7",
	[225] = "Nat +9",
	[226] = "Nat +10",
	[227] = "Frost +1",
	[228] = "Frost +3",
	[229] = "Frost +4",
	[230] = "Frost +6",
	[231] = "Frost +7",
	[232] = "Frost +9",
	[233] = "Frost +10",
	[234] = "Shdw +1",
	[235] = "Shdw +3",
	[236] = "Shdw +4",
	[237] = "Shdw +6",
	[238] = "Shdw +7",
	[239] = "Shdw +9",
	[240] = "Shdw +10",
	[241] = "Wpn Dmg +2",
	[242] = "HP +15",
	[243] = "Spi +1",
	[244] = "Int +4",
	[245] = "AC +5",
	[246] = "Mana +20",
	[247] = "Agi +1",
	[248] = "Str +1",
	[249] = "BS +2",
	[250] = "Wpn Dmg +1 ",
	[251] = "Int +1",
	[252] = "Spi +6",
	[253] = "Absorb 50",
	[254] = "HP +25",
	[255] = "Spi +3",
	[256] = "+5 Fire Res",
	[257] = "AC +10",
	[263] = "Fish +25",
	[264] = "Fish +50",
	[265] = "Fish +75",
	[266] = "Fish +100",
	[283] = "WF 1",
	[284] = "WF 2",
	[285] = "FT Tot 2",
	[286] = "+2 Fire Dmg",
	[287] = "+4 Fire Dmg",
	[288] = "+6 Fire Dmg",
	[289] = "+8 Fire Dmg",
	[290] = "+10 Fire Dmg",
	[291] = "+12 Fire Dmg",
	[292] = "+14 Fire Dmg",
	[303] = "Orb of Fire",
	[323] = "Insta Psn",
	[324] = "Insta Psn II",
	[325] = "Insta Psn III",
	[343] = "+8 Agi",
	[344] = "+32 AC",
	[345] = "+40 AC",
	[346] = "+36 AC",
	[347] = "+44 AC",
	[348] = "+48 AC",
	[349] = "+9 Agi",
	[350] = "+8 Int",
	[351] = "+8 Spi",
	[352] = "+8 Str",
	[353] = "+8 Stam",
	[354] = "+9 Int",
	[355] = "+9 Spi",
	[356] = "+9 Stam",
	[357] = "+9 Str",
	[358] = "+10 Agi",
	[359] = "+10 Int",
	[360] = "+10 Spi",
	[361] = "+10 Stam",
	[362] = "+10 Str",
	[363] = "+11 Agi",
	[364] = "+11 Int",
	[365] = "+11 Spi",
	[366] = "+11 Stam",
	[367] = "+11 Str",
	[368] = "+12 Agi",
	[369] = "+12 Int",
	[370] = "+12 Spi",
	[371] = "+12 Stam",
	[372] = "+12 Str",
	[383] = "+52 AC",
	[384] = "+56 AC",
	[385] = "+60 AC",
	[386] = "+16 AC",
	[387] = "+17 AC",
	[388] = "+18 AC",
	[389] = "+19 AC",
	[403] = "+13 Agi",
	[404] = "+14 Agi",
	[405] = "+13 Int",
	[406] = "+14 Int",
	[407] = "+13 Spi",
	[408] = "+14 Spi",
	[409] = "+13 Stam",
	[410] = "+13 Str",
	[411] = "+14 Stam",
	[412] = "+14 Str",
	[423] = "Dmg +1",
	[424] = "Dmg +2",
	[425] = "Dmg +4",
	[426] = "Dmg +5",
	[427] = "Dmg +6",
	[428] = "Dmg +7",
	[429] = "Dmg +8",
	[430] = "Dmg +9",
	[431] = "Dmg +11",
	[432] = "Dmg +12",
	[433] = "Fire Dmg +11",
	[434] = "Fire Dmg +13",
	[435] = "Fire Dmg +14",
	[436] = "Crit +5%",
	[437] = "Frost +11",
	[438] = "Frost +13",
	[439] = "Frost +14",
	[440] = "Heals +12",
	[441] = "Heals +20",
	[442] = "Heals +22",
	[443] = "Nat +11",
	[444] = "Nat +13",
	[445] = "Nat +14",
	[446] = "Shdw +11",
	[447] = "Shdw +13",
	[448] = "Shdw +14",
	[463] = "Spike 16-20",
	[464] = "4% Mnt Spd",
	[483] = "Sharp +6",
	[484] = "Weight +6",
	[503] = "RB 4",
	[504] = "RB +80",
	[523] = "FT 4",
	[524] = "FB 3",
	[525] = "WF 3",
	[543] = "FT Tot 3",
	[563] = "WF Tot 2",
	[564] = "WF Tot 3",
	[583] = "+1 Agi / +1 Spi",
	[584] = "+1 Agi / +1 Int",
	[585] = "+1 Agi / +1 Stam",
	[586] = "+1 Agi / +1 Str",
	[587] = "+1 Int / +1 Spi",
	[588] = "+1 Int / +1 Stam",
	[589] = "+1 Int / +1 Str",
	[590] = "+1 Spi / +1 Stam",
	[591] = "+1 Spi / +1 Str",
	[592] = "+1 Stam / +1 Str",
	[603] = "Crp Psn II",
	[623] = "Insta Psn IV",
	[624] = "Insta Psn V",
	[625] = "Insta Psn VI",
	[626] = "D Psn III",
	[627] = "D Psn IV",
	[643] = "MN Psn III",
	[663] = "Scp +5 Dmg",
	[664] = "Scp +7 Dmg",
	[683] = "RB 6",
	[684] = "+15 Str",
	[703] = "Wound Psn",
	[704] = "Wound Psn II",
	[705] = "Wound Psn III",
	[706] = "Wound Psn IV",
	[723] = "Int +3",
	[724] = "Stam +3",
	[743] = "Stealth +2",
	[744] = "AC +20",
	[763] = "Block +1%",
	[783] = "AC +10",
	[803] = "Fiery",
	[804] = "+10 Shdw Res",
	[805] = "Wpn Dmg +4",
	[823] = "Str +3",
	[843] = "Mana +30",
	[844] = "Mining +2",
	[845] = "Herbalism +2",
	[846] = "Fish +2",
	[847] = "Stats +1",
	[848] = "AC +30",
	[849] = "Agi +3",
	[850] = "HP +35",
	[851] = "Spi +5",
	[852] = "Stam +5",
	[853] = "BS +6",
	[854] = "Ele Slay +6",
	[855] = "+5 Fire Res",
	[856] = "Str +5",
	[857] = "Mana +50",
	[863] = "Block +2%",
	[864] = "Wpn Dmg +4",
	[865] = "Skinning +5",
	[866] = "Stats +2",
	[883] = "+15 Agi",
	[884] = "AC +50",
	[903] = "+3 All Res",
	[904] = "Agi +5",
	[905] = "Int +5",
	[906] = "Mining +5",
	[907] = "Spi +7",
	[908] = "HP +50",
	[909] = "Herbalism +5",
	[910] = "Increased Stealth",
	[911] = "8% Run Spd",
	[912] = "Demonslay",
	[913] = "Mana +65",
	[923] = "Def +3",
	[924] = "Def +1",
	[925] = "Def +2",
	[926] = "+8 Frost Res",
	[927] = "Str +7",
	[928] = "Stats +3",
	[929] = "Stam +7",
	[930] = "2% Mnt Spd",
	[931] = "A Spd +1%",
	[943] = "Wpn Dmg +3",
	[963] = "Wpn Dmg +7",
	[983] = "+16 Agi",
	[1003] = "VH Psn",
	[1023] = "Feedback 1",
	[1043] = "+16 Str",
	[1044] = "+17 Str",
	[1045] = "+18 Str",
	[1046] = "+19 Str",
	[1047] = "+20 Str",
	[1048] = "+21 Str",
	[1049] = "+22 Str",
	[1050] = "+23 Str",
	[1051] = "+24 Str",
	[1052] = "+25 Str",
	[1053] = "+26 Str",
	[1054] = "+27 Str",
	[1055] = "+28 Str",
	[1056] = "+29 Str",
	[1057] = "+30 Str",
	[1058] = "+31 Str",
	[1059] = "+32 Str",
	[1060] = "+33 Str",
	[1061] = "+34 Str",
	[1062] = "+35 Str",
	[1063] = "+36 Str",
	[1064] = "+37 Str",
	[1065] = "+38 Str",
	[1066] = "+39 Str",
	[1067] = "+40 Str",
	[1068] = "+15 Stam",
	[1069] = "+16 Stam",
	[1070] = "+17 Stam",
	[1071] = "+18 Stam",
	[1072] = "+19 Stam",
	[1073] = "+20 Stam",
	[1074] = "+21 Stam",
	[1075] = "+22 Stam",
	[1076] = "+23 Stam",
	[1077] = "+24 Stam",
	[1078] = "+25 Stam",
	[1079] = "+26 Stam",
	[1080] = "+27 Stam",
	[1081] = "+28 Stam",
	[1082] = "+29 Stam",
	[1083] = "+30 Stam",
	[1084] = "+31 Stam",
	[1085] = "+32 Stam",
	[1086] = "+33 Stam",
	[1087] = "+34 Stam",
	[1088] = "+35 Stam",
	[1089] = "+36 Stam",
	[1090] = "+37 Stam",
	[1091] = "+38 Stam",
	[1092] = "+39 Stam",
	[1093] = "+40 Stam",
	[1094] = "+17 Agi",
	[1095] = "+18 Agi",
	[1096] = "+19 Agi",
	[1097] = "+20 Agi",
	[1098] = "+21 Agi",
	[1099] = "+22 Agi",
	[1100] = "+23 Agi",
	[1101] = "+24 Agi",
	[1102] = "+25 Agi",
	[1103] = "+26 Agi",
	[1104] = "+27 Agi",
	[1105] = "+28 Agi",
	[1106] = "+29 Agi",
	[1107] = "+30 Agi",
	[1108] = "+31 Agi",
	[1109] = "+32 Agi",
	[1110] = "+33 Agi",
	[1111] = "+34 Agi",
	[1112] = "+35 Agi",
	[1113] = "+36 Agi",
	[1114] = "+37 Agi",
	[1115] = "+38 Agi",
	[1116] = "+39 Agi",
	[1117] = "+40 Agi",
	[1118] = "+15 Int",
	[1119] = "+16 Int",
	[1120] = "+17 Int",
	[1121] = "+18 Int",
	[1122] = "+19 Int",
	[1123] = "+20 Int",
	[1124] = "+21 Int",
	[1125] = "+22 Int",
	[1126] = "+23 Int",
	[1127] = "+24 Int",
	[1128] = "+25 Int",
	[1129] = "+26 Int",
	[1130] = "+27 Int",
	[1131] = "+28 Int",
	[1132] = "+29 Int",
	[1133] = "+30 Int",
	[1134] = "+31 Int",
	[1135] = "+32 Int",
	[1136] = "+33 Int",
	[1137] = "+34 Int",
	[1138] = "+35 Int",
	[1139] = "+36 Int",
	[1140] = "+37 Int",
	[1141] = "+38 Int",
	[1142] = "+39 Int",
	[1143] = "+40 Int",
	[1144] = "+15 Spi",
	[1145] = "+16 Spi",
	[1146] = "+17 Spi",
	[1147] = "+18 Spi",
	[1148] = "+19 Spi",
	[1149] = "+20 Spi",
	[1150] = "+21 Spi",
	[1151] = "+22 Spi",
	[1152] = "+23 Spi",
	[1153] = "+24 Spi",
	[1154] = "+25 Spi",
	[1155] = "+26 Spi",
	[1156] = "+27 Spi",
	[1157] = "+28 Spi",
	[1158] = "+29 Spi",
	[1159] = "+30 Spi",
	[1160] = "+31 Spi",
	[1161] = "+32 Spi",
	[1162] = "+33 Spi",
	[1163] = "+34 Spi",
	[1164] = "+36 Spi",
	[1165] = "+37 Spi",
	[1166] = "+38 Spi",
	[1167] = "+39 Spi",
	[1168] = "+40 Spi",
	[1183] = "+35 Spi",
	[1203] = "+41 Str",
	[1204] = "+42 Str",
	[1205] = "+43 Str",
	[1206] = "+44 Str",
	[1207] = "+45 Str",
	[1208] = "+46 Str",
	[1209] = "+41 Stam",
	[1210] = "+42 Stam",
	[1211] = "+43 Stam",
	[1212] = "+44 Stam",
	[1213] = "+45 Stam",
	[1214] = "+46 Stam",
	[1215] = "+41 Agi",
	[1216] = "+42 Agi",
	[1217] = "+43 Agi",
	[1218] = "+44 Agi",
	[1219] = "+45 Agi",
	[1220] = "+46 Agi",
	[1221] = "+41 Int",
	[1222] = "+42 Int",
	[1223] = "+43 Int",
	[1224] = "+44 Int",
	[1225] = "+45 Int",
	[1226] = "+46 Int",
	[1227] = "+41 Spi",
	[1228] = "+42 Spi",
	[1229] = "+43 Spi",
	[1230] = "+44 Spi",
	[1231] = "+45 Spi",
	[1232] = "+46 Spi",
	[1243] = "+1 Arc Res",
	[1244] = "+2 Arc Res",
	[1245] = "+3 Arc Res",
	[1246] = "+4 Arc Res",
	[1247] = "+5 Arc Res",
	[1248] = "+6 Arc Res",
	[1249] = "+7 Arc Res",
	[1250] = "+8 Arc Res",
	[1251] = "+9 Arc Res",
	[1252] = "+10 Arc Res",
	[1253] = "+11 Arc Res",
	[1254] = "+12 Arc Res",
	[1255] = "+13 Arc Res",
	[1256] = "+14 Arc Res",
	[1257] = "+15 Arc Res",
	[1258] = "+16 Arc Res",
	[1259] = "+17 Arc Res",
	[1260] = "+18 Arc Res",
	[1261] = "+19 Arc Res",
	[1262] = "+20 Arc Res",
	[1263] = "+21 Arc Res",
	[1264] = "+22 Arc Res",
	[1265] = "+23 Arc Res",
	[1266] = "+24 Arc Res",
	[1267] = "+25 Arc Res",
	[1268] = "+26 Arc Res",
	[1269] = "+27 Arc Res",
	[1270] = "+28 Arc Res",
	[1271] = "+29 Arc Res",
	[1272] = "+30 Arc Res",
	[1273] = "+31 Arc Res",
	[1274] = "+32 Arc Res",
	[1275] = "+33 Arc Res",
	[1276] = "+34 Arc Res",
	[1277] = "+35 Arc Res",
	[1278] = "+36 Arc Res",
	[1279] = "+37 Arc Res",
	[1280] = "+38 Arc Res",
	[1281] = "+39 Arc Res",
	[1282] = "+40 Arc Res",
	[1283] = "+41 Arc Res",
	[1284] = "+42 Arc Res",
	[1285] = "+43 Arc Res",
	[1286] = "+44 Arc Res",
	[1287] = "+45 Arc Res",
	[1288] = "+46 Arc Res",
	[1289] = "+1 Frost Res",
	[1290] = "+2 Frost Res",
	[1291] = "+3 Frost Res",
	[1292] = "+4 Frost Res",
	[1293] = "+5 Frost Res",
	[1294] = "+6 Frost Res",
	[1295] = "+7 Frost Res",
	[1296] = "+8 Frost Res",
	[1297] = "+9 Frost Res",
	[1298] = "+10 Frost Res",
	[1299] = "+11 Frost Res",
	[1300] = "+12 Frost Res",
	[1301] = "+13 Frost Res",
	[1302] = "+14 Frost Res",
	[1303] = "+15 Frost Res",
	[1304] = "+16 Frost Res",
	[1305] = "+17 Frost Res",
	[1306] = "+18 Frost Res",
	[1307] = "+19 Frost Res",
	[1308] = "+20 Frost Res",
	[1309] = "+21 Frost Res",
	[1310] = "+22 Frost Res",
	[1311] = "+23 Frost Res",
	[1312] = "+24 Frost Res",
	[1313] = "+25 Frost Res",
	[1314] = "+26 Frost Res",
	[1315] = "+27 Frost Res",
	[1316] = "+28 Frost Res",
	[1317] = "+29 Frost Res",
	[1318] = "+30 Frost Res",
	[1319] = "+31 Frost Res",
	[1320] = "+32 Frost Res",
	[1321] = "+33 Frost Res",
	[1322] = "+34 Frost Res",
	[1323] = "+35 Frost Res",
	[1324] = "+36 Frost Res",
	[1325] = "+37 Frost Res",
	[1326] = "+38 Frost Res",
	[1327] = "+39 Frost Res",
	[1328] = "+40 Frost Res",
	[1329] = "+41 Frost Res",
	[1330] = "+42 Frost Res",
	[1331] = "+43 Frost Res",
	[1332] = "+44 Frost Res",
	[1333] = "+45 Frost Res",
	[1334] = "+46 Frost Res",
	[1335] = "+1 Fire Res",
	[1336] = "+2 Fire Res",
	[1337] = "+3 Fire Res",
	[1338] = "+4 Fire Res",
	[1339] = "+5 Fire Res",
	[1340] = "+6 Fire Res",
	[1341] = "+7 Fire Res",
	[1342] = "+8 Fire Res",
	[1343] = "+9 Fire Res",
	[1344] = "+10 Fire Res",
	[1345] = "+11 Fire Res",
	[1346] = "+12 Fire Res",
	[1347] = "+13 Fire Res",
	[1348] = "+14 Fire Res",
	[1349] = "+15 Fire Res",
	[1350] = "+16 Fire Res",
	[1351] = "+17 Fire Res",
	[1352] = "+18 Fire Res",
	[1353] = "+19 Fire Res",
	[1354] = "+20 Fire Res",
	[1355] = "+21 Fire Res",
	[1356] = "+22 Fire Res",
	[1357] = "+23 Fire Res",
	[1358] = "+24 Fire Res",
	[1359] = "+25 Fire Res",
	[1360] = "+26 Fire Res",
	[1361] = "+27 Fire Res",
	[1362] = "+28 Fire Res",
	[1363] = "+29 Fire Res",
	[1364] = "+30 Fire Res",
	[1365] = "+31 Fire Res",
	[1366] = "+32 Fire Res",
	[1367] = "+33 Fire Res",
	[1368] = "+34 Fire Res",
	[1369] = "+35 Fire Res",
	[1370] = "+36 Fire Res",
	[1371] = "+37 Fire Res",
	[1372] = "+38 Fire Res",
	[1373] = "+39 Fire Res",
	[1374] = "+40 Fire Res",
	[1375] = "+41 Fire Res",
	[1376] = "+42 Fire Res",
	[1377] = "+43 Fire Res",
	[1378] = "+44 Fire Res",
	[1379] = "+45 Fire Res",
	[1380] = "+46 Fire Res",
	[1381] = "+1 Nat Res",
	[1382] = "+2 Nat Res",
	[1383] = "+3 Nat Res",
	[1384] = "+4 Nat Res",
	[1385] = "+5 Nat Res",
	[1386] = "+6 Nat Res",
	[1387] = "+7 Nat Res",
	[1388] = "+8 Nat Res",
	[1389] = "+9 Nat Res",
	[1390] = "+10 Nat Res",
	[1391] = "+11 Nat Res",
	[1392] = "+12 Nat Res",
	[1393] = "+13 Nat Res",
	[1394] = "+14 Nat Res",
	[1395] = "+15 Nat Res",
	[1396] = "+16 Nat Res",
	[1397] = "+17 Nat Res",
	[1398] = "+18 Nat Res",
	[1399] = "+19 Nat Res",
	[1400] = "+20 Nat Res",
	[1401] = "+21 Nat Res",
	[1402] = "+22 Nat Res",
	[1403] = "+23 Nat Res",
	[1404] = "+24 Nat Res",
	[1405] = "+25 Nat Res",
	[1406] = "+26 Nat Res",
	[1407] = "+27 Nat Res",
	[1408] = "+28 Nat Res",
	[1409] = "+29 Nat Res",
	[1410] = "+30 Nat Res",
	[1411] = "+31 Nat Res",
	[1412] = "+32 Nat Res",
	[1413] = "+33 Nat Res",
	[1414] = "+34 Nat Res",
	[1415] = "+35 Nat Res",
	[1416] = "+36 Nat Res",
	[1417] = "+37 Nat Res",
	[1418] = "+38 Nat Res",
	[1419] = "+39 Nat Res",
	[1420] = "+40 Nat Res",
	[1421] = "+41 Nat Res",
	[1422] = "+42 Nat Res",
	[1423] = "+43 Nat Res",
	[1424] = "+44 Nat Res",
	[1425] = "+45 Nat Res",
	[1426] = "+46 Nat Res",
	[1427] = "+1 Shdw Res",
	[1428] = "+2 Shdw Res",
	[1429] = "+3 Shdw Res",
	[1430] = "+4 Shdw Res",
	[1431] = "+5 Shdw Res",
	[1432] = "+6 Shdw Res",
	[1433] = "+7 Shdw Res",
	[1434] = "+8 Shdw Res",
	[1435] = "+9 Shdw Res",
	[1436] = "+10 Shdw Res",
	[1437] = "+11 Shdw Res",
	[1438] = "+12 Shdw Res",
	[1439] = "+13 Shdw Res",
	[1440] = "+14 Shdw Res",
	[1441] = "+15 Shdw Res",
	[1442] = "+16 Shdw Res",
	[1443] = "+17 Shdw Res",
	[1444] = "+18 Shdw Res",
	[1445] = "+19 Shdw Res",
	[1446] = "+20 Shdw Res",
	[1447] = "+21 Shdw Res",
	[1448] = "+22 Shdw Res",
	[1449] = "+23 Shdw Res",
	[1450] = "+24 Shdw Res",
	[1451] = "+25 Shdw Res",
	[1452] = "+26 Shdw Res",
	[1453] = "+27 Shdw Res",
	[1454] = "+28 Shdw Res",
	[1455] = "+29 Shdw Res",
	[1456] = "+30 Shdw Res",
	[1457] = "+31 Shdw Res",
	[1458] = "+32 Shdw Res",
	[1459] = "+33 Shdw Res",
	[1460] = "+34 Shdw Res",
	[1461] = "+35 Shdw Res",
	[1462] = "+36 Shdw Res",
	[1463] = "+37 Shdw Res",
	[1464] = "+38 Shdw Res",
	[1465] = "+39 Shdw Res",
	[1466] = "+40 Shdw Res",
	[1467] = "+41 Shdw Res",
	[1468] = "+42 Shdw Res",
	[1469] = "+43 Shdw Res",
	[1470] = "+44 Shdw Res",
	[1471] = "+45 Shdw Res",
	[1472] = "+46 Shdw Res",
	[1483] = "Mana +150",
	[1503] = "HP +100",
	[1504] = "AC +125",
	[1505] = "+20 Fire Res",
	[1506] = "Str +8",
	[1507] = "Stam +8",
	[1508] = "Agi +8",
	[1509] = "Int +8",
	[1510] = "Spi +8",
	[1523] = "MANA/FR +85/14",
	[1524] = "HP/FR +75/14",
	[1525] = "AC/FR +110/14",
	[1526] = "Str/FR +10/14",
	[1527] = "STA/FR +10/14",
	[1528] = "Agi/FR +10/14",
	[1529] = "Int/FR +10/14",
	[1530] = "Spi/FR +10/14",
	[1531] = "Str/STA +10/10",
	[1532] = "Str/STA/AC/FR +10/10/110/15",
	[1543] = "Int/Spi/MANA/FR +10/10/100/15",
	[1563] = "+2 AP",
	[1583] = "+4 AP",
	[1584] = "+6 AP",
	[1585] = "+8 AP",
	[1586] = "+10 AP",
	[1587] = "+12 AP",
	[1588] = "+14 AP",
	[1589] = "+16 AP",
	[1590] = "+18 AP",
	[1591] = "+20 AP",
	[1592] = "+22 AP",
	[1593] = "+24 AP",
	[1594] = "+26 AP",
	[1595] = "+28 AP",
	[1596] = "+30 AP",
	[1597] = "+32 AP",
	[1598] = "+34 AP",
	[1599] = "+36 AP",
	[1600] = "+38 AP",
	[1601] = "+40 AP",
	[1602] = "+42 AP",
	[1603] = "+44 AP",
	[1604] = "+46 AP",
	[1605] = "+48 AP",
	[1606] = "+50 AP",
	[1607] = "+52 AP",
	[1608] = "+54 AP",
	[1609] = "+56 AP",
	[1610] = "+58 AP",
	[1611] = "+60 AP",
	[1612] = "+62 AP",
	[1613] = "+64 AP",
	[1614] = "+66 AP",
	[1615] = "+68 AP",
	[1616] = "+70 AP",
	[1617] = "+72 AP",
	[1618] = "+74 AP",
	[1619] = "+76 AP",
	[1620] = "+78 AP",
	[1621] = "+80 AP",
	[1622] = "+82 AP",
	[1623] = "+84 AP",
	[1624] = "+86 AP",
	[1625] = "+88 AP",
	[1626] = "+90 AP",
	[1627] = "+92 AP",
	[1643] = "Sharp +8",
	[1663] = "RB 5",
	[1664] = "RB 7",
	[1665] = "FT 5",
	[1666] = "FT 6",
	[1667] = "FB 4",
	[1668] = "FB 5",
	[1669] = "WF 4",
	[1683] = "FT Tot 4",
	[1703] = "Weight +8",
	[1704] = "Spike 20-30",
	[1723] = "OOC",
	[1743] = "MHTest02",
	[1763] = "Cold Blood",
	[1783] = "WF Tot 1",
	[1803] = "Firestone 1",
	[1823] = "Firestone 2",
	[1824] = "Firestone 3",
	[1825] = "Firestone 4",
	[1843] = "AC +40",
	[1863] = "Feedback 2",
	[1864] = "Feedback 3",
	[1865] = "Feedback 4",
	[1866] = "Feedback 5",
	[1883] = "Int +7",
	[1884] = "Spi +9",
	[1885] = "Str +9",
	[1886] = "Stam +9",
	[1887] = "Agi +7",
	[1888] = "+5 All Res",
	[1889] = "AC +70",
	[1890] = "Spi +9",
	[1891] = "Stats +4",
	[1892] = "HP +100",
	[1893] = "Mana +100",
	[1894] = "Icy",
	[1895] = "Dmg +9",
	[1896] = "Wpn Dmg +9",
	[1897] = "Wpn Dmg +5",
	[1898] = "Lifesteal",
	[1899] = "Unholy",
	[1900] = "Crusader",
	[1901] = "Int +9",
	[1903] = "Spi +9",
	[1904] = "Int +9",
	[1923] = "+3 Fire Res",
	[1943] = "+8 Def",
	[1944] = "+5 Def",
	[1945] = "+6 Def",
	[1946] = "+7 Def",
	[1947] = "+7 Def",
	[1948] = "+9 Def",
	[1949] = "+9 Def",
	[1950] = "+10 Def",
	[1951] = "+11 Def",
	[1952] = "+13 Def",
	[1953] = "+15 Def",
	[1954] = "+17 Def",
	[1955] = "+21 Def",
	[1956] = "+11 Def",
	[1957] = "+12 Def",
	[1958] = "+13 Def",
	[1959] = "+14 Def",
	[1960] = "+15 Def",
	[1961] = "+16 Def",
	[1962] = "+17 Def",
	[1963] = "+18 Def",
	[1964] = "+19 Def",
	[1965] = "+19 Def",
	[1966] = "+20 Def",
	[1967] = "+21 Def",
	[1968] = "+22 Def",
	[1969] = "+23 Def",
	[1970] = "+23 Def",
	[1971] = "+24 Def",
	[1972] = "+25 Def",
	[1973] = "+25 Def",
	[1983] = "+1% Block",
	[1984] = "+2% Block",
	[1985] = "+3% Block",
	[1986] = "+4% Block",
	[1987] = "Block Lvl 14",
	[1988] = "Block Lvl 15",
	[1989] = "Block Lvl 16",
	[1990] = "Block Lvl 17",
	[1991] = "Block Lvl 18",
	[1992] = "Block Lvl 19",
	[1993] = "Block Lvl 20",
	[1994] = "Block Lvl 21",
	[1995] = "Block Lvl 22",
	[1996] = "Block Lvl 23",
	[1997] = "Block Lvl 24",
	[1998] = "Block Lvl 25",
	[1999] = "Block Lvl 26",
	[2000] = "Block Lvl 27",
	[2001] = "Block Lvl 28",
	[2002] = "Block Lvl 29",
	[2003] = "Block Lvl 30",
	[2004] = "Block Lvl 31",
	[2005] = "Block Lvl 32",
	[2006] = "Block Lvl 33",
	[2007] = "Block Lvl 34",
	[2008] = "Block Lvl 35",
	[2009] = "Block Lvl 36",
	[2010] = "Block Lvl 37",
	[2011] = "Block Lvl 38",
	[2012] = "Block Lvl 39",
	[2013] = "Block Lvl 40",
	[2014] = "Block Lvl 41",
	[2015] = "Block Lvl 42",
	[2016] = "Block Lvl 43",
	[2017] = "Block Lvl 44",
	[2018] = "Block Lvl 45",
	[2019] = "Block Lvl 46",
	[2020] = "Block Lvl 47",
	[2021] = "Block Lvl 48",
	[2022] = "Block Lvl 49",
	[2023] = "Block Lvl 50",
	[2024] = "Block Lvl 51",
	[2025] = "Block Lvl 52",
	[2026] = "Block Lvl 53",
	[2027] = "Block Lvl 54",
	[2028] = "Block Lvl 55",
	[2029] = "Block Lvl 56",
	[2030] = "Block Lvl 57",
	[2031] = "Block Lvl 58",
	[2032] = "Block Lvl 59",
	[2033] = "Block Lvl 60",
	[2034] = "Block Lvl 61",
	[2035] = "Block Lvl 62",
	[2036] = "Block Lvl 63",
	[2037] = "Block Lvl 64",
	[2038] = "Block Lvl 65",
	[2039] = "Block Lvl 66",
	[2040] = "+2 Rng AP",
	[2041] = "+5 Rng AP",
	[2042] = "+7 Rng AP",
	[2043] = "+10 Rng AP",
	[2044] = "+12 Rng AP",
	[2045] = "+14 Rng AP",
	[2046] = "+17 Rng AP",
	[2047] = "+19 Rng AP",
	[2048] = "+22 Rng AP",
	[2049] = "+24 Rng AP",
	[2050] = "+26 Rng AP",
	[2051] = "+29 Rng AP",
	[2052] = "+31 Rng AP",
	[2053] = "+34 Rng AP",
	[2054] = "+36 Rng AP",
	[2055] = "+38 Rng AP",
	[2056] = "+41 Rng AP",
	[2057] = "+43 Rng AP",
	[2058] = "+46 Rng AP",
	[2059] = "+48 Rng AP",
	[2060] = "+50 Rng AP",
	[2061] = "+53 Rng AP",
	[2062] = "+55 Rng AP",
	[2063] = "+58 Rng AP",
	[2064] = "+60 Rng AP",
	[2065] = "+62 Rng AP",
	[2066] = "+65 Rng AP",
	[2067] = "+67 Rng AP",
	[2068] = "+70 Rng AP",
	[2069] = "+72 Rng AP",
	[2070] = "+74 Rng AP",
	[2071] = "+77 Rng AP",
	[2072] = "+79 Rng AP",
	[2073] = "+82 Rng AP",
	[2074] = "+84 Rng AP",
	[2075] = "+86 Rng AP",
	[2076] = "+89 Rng AP",
	[2077] = "+91 Rng AP",
	[2078] = "+1% Dodge",
	[2079] = "+1 Arc Dmg",
	[2080] = "+3 Arc Dmg",
	[2081] = "+4 Arc Dmg",
	[2082] = "+6 Arc Dmg",
	[2083] = "+7 Arc Dmg",
	[2084] = "+9 Arc Dmg",
	[2085] = "+10 Arc Dmg",
	[2086] = "+11 Arc Dmg",
	[2087] = "+13 Arc Dmg",
	[2088] = "+14 Arc Dmg",
	[2089] = "+16 Arc Dmg",
	[2090] = "+17 Arc Dmg",
	[2091] = "+19 Arc Dmg",
	[2092] = "+20 Arc Dmg",
	[2093] = "+21 Arc Dmg",
	[2094] = "+23 Arc Dmg",
	[2095] = "+24 Arc Dmg",
	[2096] = "+26 Arc Dmg",
	[2097] = "+27 Arc Dmg",
	[2098] = "+29 Arc Dmg",
	[2099] = "+30 Arc Dmg",
	[2100] = "+31 Arc Dmg",
	[2101] = "+33 Arc Dmg",
	[2102] = "+34 Arc Dmg",
	[2103] = "+36 Arc Dmg",
	[2104] = "+37 Arc Dmg",
	[2105] = "+39 Arc Dmg",
	[2106] = "+40 Arc Dmg",
	[2107] = "+41 Arc Dmg",
	[2108] = "+43 Arc Dmg",
	[2109] = "+44 Arc Dmg",
	[2110] = "+46 Arc Dmg",
	[2111] = "+47 Arc Dmg",
	[2112] = "+49 Arc Dmg",
	[2113] = "+50 Arc Dmg",
	[2114] = "+51 Arc Dmg",
	[2115] = "+53 Arc Dmg",
	[2116] = "+54 Arc Dmg",
	[2117] = "+1 Shdw Dmg",
	[2118] = "+3 Shdw Dmg",
	[2119] = "+4 Shdw Dmg",
	[2120] = "+6 Shdw Dmg",
	[2121] = "+7 Shdw Dmg",
	[2122] = "+9 Shdw Dmg",
	[2123] = "+10 Shdw Dmg",
	[2124] = "+11 Shdw Dmg",
	[2125] = "+13 Shdw Dmg",
	[2126] = "+14 Shdw Dmg",
	[2127] = "+16 Shdw Dmg",
	[2128] = "+17 Shdw Dmg",
	[2129] = "+19 Shdw Dmg",
	[2130] = "+20 Shdw Dmg",
	[2131] = "+21 Shdw Dmg",
	[2132] = "+23 Shdw Dmg",
	[2133] = "+24 Shdw Dmg",
	[2134] = "+26 Shdw Dmg",
	[2135] = "+27 Shdw Dmg",
	[2136] = "+29 Shdw Dmg",
	[2137] = "+30 Shdw Dmg",
	[2138] = "+31 Shdw Dmg",
	[2139] = "+33 Shdw Dmg",
	[2140] = "+34 Shdw Dmg",
	[2141] = "+36 Shdw Dmg",
	[2142] = "+37 Shdw Dmg",
	[2143] = "+39 Shdw Dmg",
	[2144] = "+40 Shdw Dmg",
	[2145] = "+41 Shdw Dmg",
	[2146] = "+43 Shdw Dmg",
	[2147] = "+44 Shdw Dmg",
	[2148] = "+46 Shdw Dmg",
	[2149] = "+47 Shdw Dmg",
	[2150] = "+49 Shdw Dmg",
	[2151] = "+50 Shdw Dmg",
	[2152] = "+51 Shdw Dmg",
	[2153] = "+53 Shdw Dmg",
	[2154] = "+54 Shdw Dmg",
	[2155] = "+1 Fire Dmg",
	[2156] = "+3 Fire Dmg",
	[2157] = "+4 Fire Dmg",
	[2158] = "+6 Fire Dmg",
	[2159] = "+7 Fire Dmg",
	[2160] = "+9 Fire Dmg",
	[2161] = "+10 Fire Dmg",
	[2162] = "+11 Fire Dmg",
	[2163] = "+13 Fire Dmg",
	[2164] = "+14 Fire Dmg",
	[2165] = "+16 Fire Dmg",
	[2166] = "+17 Fire Dmg",
	[2167] = "+19 Fire Dmg",
	[2168] = "+20 Fire Dmg",
	[2169] = "+21 Fire Dmg",
	[2170] = "+23 Fire Dmg",
	[2171] = "+24 Fire Dmg",
	[2172] = "+26 Fire Dmg",
	[2173] = "+27 Fire Dmg",
	[2174] = "+29 Fire Dmg",
	[2175] = "+30 Fire Dmg",
	[2176] = "+31 Fire Dmg",
	[2177] = "+33 Fire Dmg",
	[2178] = "+34 Fire Dmg",
	[2179] = "+36 Fire Dmg",
	[2180] = "+37 Fire Dmg",
	[2181] = "+39 Fire Dmg",
	[2182] = "+40 Fire Dmg",
	[2183] = "+41 Fire Dmg",
	[2184] = "+43 Fire Dmg",
	[2185] = "+44 Fire Dmg",
	[2186] = "+46 Fire Dmg",
	[2187] = "+47 Fire Dmg",
	[2188] = "+49 Fire Dmg",
	[2189] = "+50 Fire Dmg",
	[2190] = "+51 Fire Dmg",
	[2191] = "+53 Fire Dmg",
	[2192] = "+54 Fire Dmg",
	[2193] = "+1 Holy Dmg",
	[2194] = "+3 Holy Dmg",
	[2195] = "+4 Holy Dmg",
	[2196] = "+6 Holy Dmg",
	[2197] = "+7 Holy Dmg",
	[2198] = "+9 Holy Dmg",
	[2199] = "+10 Holy Dmg",
	[2200] = "+11 Holy Dmg",
	[2201] = "+13 Holy Dmg",
	[2202] = "+14 Holy Dmg",
	[2203] = "+16 Holy Dmg",
	[2204] = "+17 Holy Dmg",
	[2205] = "+19 Holy Dmg",
	[2206] = "+20 Holy Dmg",
	[2207] = "+21 Holy Dmg",
	[2208] = "+23 Holy Dmg",
	[2209] = "+24 Holy Dmg",
	[2210] = "+26 Holy Dmg",
	[2211] = "+27 Holy Dmg",
	[2212] = "+29 Holy Dmg",
	[2213] = "+30 Holy Dmg",
	[2214] = "+31 Holy Dmg",
	[2215] = "+33 Holy Dmg",
	[2216] = "+34 Holy Dmg",
	[2217] = "+36 Holy Dmg",
	[2218] = "+37 Holy Dmg",
	[2219] = "+39 Holy Dmg",
	[2220] = "+40 Holy Dmg",
	[2221] = "+41 Holy Dmg",
	[2222] = "+43 Holy Dmg",
	[2223] = "+44 Holy Dmg",
	[2224] = "+46 Holy Dmg",
	[2225] = "+47 Holy Dmg",
	[2226] = "+49 Holy Dmg",
	[2227] = "+50 Holy Dmg",
	[2228] = "+51 Holy Dmg",
	[2229] = "+53 Holy Dmg",
	[2230] = "+54 Holy Dmg",
	[2231] = "+1 Frost Dmg",
	[2232] = "+3 Frost Dmg",
	[2233] = "+4 Frost Dmg",
	[2234] = "+6 Frost Dmg",
	[2235] = "+7 Frost Dmg",
	[2236] = "+9 Frost Dmg",
	[2237] = "+10 Frost Dmg",
	[2238] = "+11 Frost Dmg",
	[2239] = "+13 Frost Dmg",
	[2240] = "+14 Frost Dmg",
	[2241] = "+16 Frost Dmg",
	[2242] = "+17 Frost Dmg",
	[2243] = "+19 Frost Dmg",
	[2244] = "+20 Frost Dmg",
	[2245] = "+21 Frost Dmg",
	[2246] = "+23 Frost Dmg",
	[2247] = "+24 Frost Dmg",
	[2248] = "+26 Frost Dmg",
	[2249] = "+27 Frost Dmg",
	[2250] = "+29 Frost Dmg",
	[2251] = "+30 Frost Dmg",
	[2252] = "+31 Frost Dmg",
	[2253] = "+33 Frost Dmg",
	[2254] = "+34 Frost Dmg",
	[2255] = "+36 Frost Dmg",
	[2256] = "+37 Frost Dmg",
	[2257] = "+39 Frost Dmg",
	[2258] = "+40 Frost Dmg",
	[2259] = "+41 Frost Dmg",
	[2260] = "+43 Frost Dmg",
	[2261] = "+44 Frost Dmg",
	[2262] = "+46 Frost Dmg",
	[2263] = "+47 Frost Dmg",
	[2264] = "+49 Frost Dmg",
	[2265] = "+50 Frost Dmg",
	[2266] = "+51 Frost Dmg",
	[2267] = "+53 Frost Dmg",
	[2268] = "+54 Frost Dmg",
	[2269] = "+1 Nat Dmg",
	[2270] = "+3 Nat Dmg",
	[2271] = "+4 Nat Dmg",
	[2272] = "+6 Nat Dmg",
	[2273] = "+7 Nat Dmg",
	[2274] = "+9 Nat Dmg",
	[2275] = "+10 Nat Dmg",
	[2276] = "+11 Nat Dmg",
	[2277] = "+13 Nat Dmg",
	[2278] = "+14 Nat Dmg",
	[2279] = "+16 Nat Dmg",
	[2280] = "+17 Nat Dmg",
	[2281] = "+19 Nat Dmg",
	[2282] = "+20 Nat Dmg",
	[2283] = "+21 Nat Dmg",
	[2284] = "+23 Nat Dmg",
	[2285] = "+24 Nat Dmg",
	[2286] = "+26 Nat Dmg",
	[2287] = "+27 Nat Dmg",
	[2288] = "+29 Nat Dmg",
	[2289] = "+30 Nat Dmg",
	[2290] = "+31 Nat Dmg",
	[2291] = "+33 Nat Dmg",
	[2292] = "+34 Nat Dmg",
	[2293] = "+36 Nat Dmg",
	[2294] = "+37 Nat Dmg",
	[2295] = "+39 Nat Dmg",
	[2296] = "+40 Nat Dmg",
	[2297] = "+41 Nat Dmg",
	[2298] = "+43 Nat Dmg",
	[2299] = "+44 Nat Dmg",
	[2300] = "+46 Nat Dmg",
	[2301] = "+47 Nat Dmg",
	[2302] = "+49 Nat Dmg",
	[2303] = "+50 Nat Dmg",
	[2304] = "+51 Nat Dmg",
	[2305] = "+53 Nat Dmg",
	[2306] = "+54 Nat Dmg",
	[2307] = "+2 Heals",
	[2308] = "+4 Heals",
	[2309] = "+7 Heals",
	[2310] = "+9 Heals",
	[2311] = "+11 Heals",
	[2312] = "+13 Heals",
	[2313] = "+15 Heals",
	[2314] = "+18 Heals",
	[2315] = "+20 Heals",
	[2316] = "+22 Heals",
	[2317] = "+24 Heals",
	[2318] = "+26 Heals",
	[2319] = "+29 Heals",
	[2320] = "+31 Heals",
	[2321] = "+33 Heals",
	[2322] = "+35 Heals",
	[2323] = "+37 Heals",
	[2324] = "+40 Heals",
	[2325] = "+42 Heals",
	[2326] = "+44 Heals",
	[2327] = "+46 Heals",
	[2328] = "+48 Heals",
	[2329] = "+51 Heals",
	[2330] = "+53 Heals",
	[2331] = "+55 Heals",
	[2332] = "+57 Heals",
	[2333] = "+59 Heals",
	[2334] = "+62 Heals",
	[2335] = "+64 Heals",
	[2336] = "+66 Heals",
	[2337] = "+68 Heals",
	[2338] = "+70 Heals",
	[2339] = "+73 Heals",
	[2340] = "+75 Heals",
	[2341] = "+77 Heals",
	[2342] = "+79 Heals",
	[2343] = "+81 Heals",
	[2344] = "+84 Heals",
	[2363] = "+1 MP5",
	[2364] = "+1 MP5",
	[2365] = "+1 MP5",
	[2366] = "+2 MP5",
	[2367] = "+2 MP5",
	[2368] = "+2 MP5",
	[2369] = "+3 MP5",
	[2370] = "+3 MP5",
	[2371] = "+4 MP5",
	[2372] = "+4 MP5",
	[2373] = "+4 MP5",
	[2374] = "+5 MP5",
	[2375] = "+5 MP5",
	[2376] = "+6 MP5",
	[2377] = "+6 MP5",
	[2378] = "+6 MP5",
	[2379] = "+7 MP5",
	[2380] = "+7 MP5",
	[2381] = "+8 MP5",
	[2382] = "+8 MP5",
	[2383] = "+8 MP5",
	[2384] = "+9 MP5",
	[2385] = "+9 MP5",
	[2386] = "+10 MP5",
	[2387] = "+10 MP5",
	[2388] = "+10 MP5",
	[2389] = "+11 MP5",
	[2390] = "+11 MP5",
	[2391] = "+12 MP5",
	[2392] = "+12 MP5",
	[2393] = "+12 MP5",
	[2394] = "+13 MP5",
	[2395] = "+13 MP5",
	[2396] = "+14 MP5",
	[2397] = "+14 MP5",
	[2398] = "+14 MP5",
	[2399] = "+15 MP5",
	[2400] = "+15 MP5",
	[2401] = "+1 HP5",
	[2402] = "+1 HP5",
	[2403] = "+1 HP5",
	[2404] = "+1 HP5",
	[2405] = "+1 HP5",
	[2406] = "+2 HP5",
	[2407] = "+2 HP5",
	[2408] = "+2 HP5",
	[2409] = "+2 HP5",
	[2410] = "+3 HP5",
	[2411] = "+3 HP5",
	[2412] = "+3 HP5",
	[2413] = "+3 HP5",
	[2414] = "+4 HP5",
	[2415] = "+4 HP5",
	[2416] = "+4 HP5",
	[2417] = "+4 HP5",
	[2418] = "+5 HP5",
	[2419] = "+5 HP5",
	[2420] = "+5 HP5",
	[2421] = "+5 HP5",
	[2422] = "+6 HP5",
	[2423] = "+6 HP5",
	[2424] = "+6 HP5",
	[2425] = "+6 HP5",
	[2426] = "+7 HP5",
	[2427] = "+7 HP5",
	[2428] = "+7 HP5",
	[2429] = "+7 HP5",
	[2430] = "+8 HP5",
	[2431] = "+8 HP5",
	[2432] = "+8 HP5",
	[2433] = "+8 HP5",
	[2434] = "+9 HP5",
	[2435] = "+9 HP5",
	[2436] = "+9 HP5",
	[2437] = "+9 HP5",
	[2438] = "+10 HP5",
	[2443] = "Frost Dmg +7",
	[2463] = "+7 Fire Res",
	[2483] = "+5 Fire Res",
	[2484] = "+5 Frost Res",
	[2485] = "+5 Arc Res",
	[2486] = "+5 Nat Res",
	[2487] = "+5 Shdw Res",
	[2488] = "+5 All Res",
	[2503] = "Def +3",
	[2504] = "Dmg +30",
	[2505] = "Heals +55",
	[2506] = "Crit +2%",
	[2523] = "+3% Hit",
	[2543] = "A Spd +1%",
	[2544] = "Dmg & Heals +8",
	[2545] = "Dodge +1%",
	[2563] = "Str +15",
	[2564] = "Agi +15",
	[2565] = "Mana Regen 4 per 5 sec.",
	[2566] = "Heals +24",
	[2567] = "Spi +20",
	[2568] = "Int +22",
	[2583] = "Def +7/Stam +10/Block Value +15",
	[2584] = "Def +7/Stam +10/Heals +24",
	[2585] = "AP +28/Dodge +1%",
	[2586] = "Rng AP +24/Stam +10/Hit +1%",
	[2587] = "Dmg & Heals +13/Int +15",
	[2588] = "Dmg & Heals +18/Spell Hit +1%",
	[2589] = "Dmg & Heals +18/Stam +10",
	[2590] = "Mana Regen +4/Stam +10/Heals +24",
	[2591] = "Int +10/Stam +10/Heals +24",
	[2603] = "Eternium Line",
	[2604] = "+33 Heals",
	[2605] = "+18 Dmg & Heals",
	[2606] = "+30 AP",
	[2607] = "+12 Dmg & Heals",
	[2608] = "+13 Dmg & Heals",
	[2609] = "+15 Dmg & Heals",
	[2610] = "+14 Dmg & Heals",
	[2611] = "REUSE Random - 15 Spells All",
	[2612] = "+18 Dmg & Heals",
	[2613] = "Threat +2%",
	[2614] = "Shdw Dmg +20",
	[2615] = "Frost Dmg +20",
	[2616] = "Fire Dmg +20",
	[2617] = "Heals +30",
	[2618] = "Agi +15",
	[2619] = "+15 Fire Res",
	[2620] = "+15 Nat Res",
	[2621] = "Subtlety",
	[2622] = "Dodge +1%",
	[2623] = "Min Wiz Oil",
	[2624] = "Min Mana Oil",
	[2625] = "Less Mana Oil",
	[2626] = "Less Wiz Oil",
	[2627] = "Wiz Oil",
	[2628] = "Brill Wiz Oil",
	[2629] = "Brill Mana Oil",
	[2630] = "D Psn V",
	[2646] = "Agi +25",
	[2681] = "+10 Nat Res",
	[2682] = "+10 Frost Res",
	[2683] = "+10 Shdw Res",
	[2684] = "+100 AP vs UD",
	[2685] = "+60 Dmg vs UD",
	[2715] = "Heals +31 and 5 MP5",
	[2716] = "Stam +16 and AC +100",
	[2717] = "AP +26 and +1% Crit",
	[2721] = "Dmg +15 and +1% Spell Crit",
	[2802] = "+$i Agi",
	[2803] = "+$i Stam",
	[2804] = "+$i Int",
	[2805] = "+$i Str",
	[2806] = "+$i Spi",
	[2815] = "+$i Dodge",
	[2817] = "+$i Arc Res",
	[2818] = "+$i Fire Res",
	[2819] = "+$i Frost Res",
	[2820] = "+$i Nat Res",
	[2821] = "+$i Shdw Res",
	[2823] = "+$i Crit",
	[2825] = "+$i AP",
	[2826] = "+$i Block",
	[3726] = "+$i Haste",
	--{ Atal'ai Signet shoulder enchants from SoD's Signets of the Lost Temple quest turn in of Flask of Nightmarish Mojo
	[7325] = "+9 Dmg & Heals", 						--{ Atal'ai Signet of Mojo
	[7326] = "+18 Heals", 							--{ Atal'ai Signet of Serenity
	[7328] = "+15 AP", 								--{ Atal'ai Signet of Might
	--{ Zul'Gurub Leg/Head enchants SoD
	[7613] = "Stam +20/Int +10/Heals +24", 			--{ Animist's Caress
	[7614] = "Stam +20/Hit +1%/Dmg & Heals +12", 	--{ Animist's Balance
	[7615] = "Stam +20/Str +10/Agi +10", 			--{ Animist's Fury
	[7616] = "Stam +20/Str +10/Def +7", 			--{ Animist's Roar
	[7617] = "Stam +20/Agi +10/Hit +1%", 			--{ Falcon's Call
	[7618] = "Stam +20/Def +7/Dmg & Heals +12", 	--{ Syncretist's Seal
	[7619] = "Stam +20/Str +10/Dmg & Heals +12", 	--{ Syncretist's Sigil
	[7620] = "Stam +20/Int +10/Heals +22", 			--{ Syncretist's Crest
	[7621] = "Stam +20/Int +10/Dmg & Heals +12", 	--{ Syncretist's Emblem
	[7622] = "Stam +20/Int +10/Heals +22", 			--{ Prophetic Aura
	[7623] = "Stam +20/Int +10/Dmg & Heals +12", 	--{ Prophetic Curse
	[7624] = "Stam +20/Agi +10/Def +7", 			--{ Death's Embrace
	[7625] = "Stam +20/Agi +10/Hit +1%", 			--{ Death's Advance
	[7626] = "Stam +20/Str +10/Dmg & Heals +12", 	--{ Vodouisant's Embrace
	[7627] = "Stam +20/Hit +1%/Dmg & Heals +12", 	--{ Vodouisant's Shroud
	[7628] = "Stam +20/Int +10/Heals +22", 			--{ Vodouisant's Charm
	[7629] = "Stam +20/Def +7/Block Chance +2%", 	--{ Vodouisant's Vigilance
	[7630] = "Stam +20/Hit +1%/Dmg & Heals +12", 	--{ Hoodoo Hex
	[7631] = "Stam +20/Hit +1%/Def +7", 			--{ Hoodoo Curse
	[7632] = "Stam +20/Str +10/Agi +10", 			--{ Presence of Might
	[7633] = "Stam +20/Def +7/Block Value +15", 	--{ Presence of Valor
	[7634] = "Stam +20/Int +10/Dmg & Heals +12", 	--{ Presence of Sight
	[7635] = "Stam +20/Agi +10/Str +10", 			--{ Falcon's Fury
	--{ SoD Phase 6/7/8 Enchants
	[7645] = "Living Stats",					--{ Enchant Chest - Living Stats
	[7646] = "+20 Holy Dmg",					--{ Enchant Gloves - Holy Power
	[7647] = "+20 Arcane Dmg",					--{ Enchant Gloves - Arcane Power
	[7648] = "+10 Dmg & Heals",					--{ Glowing Chitin Armor Kit
	[7649] = "+20 Thorns",						--{ Sharpened Chitin Armor Kit
	[7655] = "+12 Spell Dmg",					--{ Enchant Bracer - Spell Power
	[7656] = "Agi +9",							--{ Enchant Bracer - Agility
	[7657] = "Scp +10 Dmg",						--{ Obsidian Scope
	[7659] = "Int +9",							--{ Enchant Off-Hand - Superior Intellect
	[7660] = "Spi +12",							--{ Enchant Off-Hand - Excellent Spirit
	[7661] = "Int +6/Spi +5",					--{ Enchant Off-Hand - Wisdom
	[7662] = "+65 Dmg",							--{ Enchant 2H Weapon - Spellblasting
	[7663] = "Stam +12",						--{ Enchant Shield - Excellent Stamina
	[7664] = "Crit +1%",						--{ Enchant Shield - Critical Strike
	[7665] = "+16 Spell Dmg",					--{ Enchant Bracer - Greater Spellpower
	[7666] = "Str +15",							--{ Enchant Gloves - Superior Strength
	[7667] = "Agi +5",							--{ Enchant Cloak - Agility
	[7882] = "Heals +31 and 5 MP5",				--{ Resilience of the Scourge
	[7883] = "Dmg +15 and +1% Spell Crit",		--{ Power of the Scourge
	[7884] = "AP +26 and +1% Crit",				--{ Might of the Scourge
	[7885] = "Stam +16 and Def +7",				--{ Fortitude of the Scourge
	[7940] = "Grand Crusader",					--{ Enchant Weapon - Grand Crusader
	[7941] = "Grand Arcanist",					--{ Enchant 2H Weapon - Grand Arcanist
	[7942] = "Grand Sorcerer",					--{ Enchant Weapon - Grand Sorcerer
	[7943] = "Grand Inquisitor",				--{ Enchant 2H Weapon - Grand Inquisitor
}

--------------------------
-- Item Enchant Display --
--------------------------
addon.hasBiznicks = false

local function DCS_Item_Enchant_GetText()
	local MATCH_ENCHANT = ENCHANTED_TOOLTIP_LINE:gsub('%%s', '(.+)')
	local ENCHANT_PATTERN = ENCHANTED_TOOLTIP_LINE:gsub('%%s', '(.+)') --moving outside of the function might not be warranted but moving outside of for loop is
	local tooltip = CreateFrame("GameTooltip", "DCSScanTooltip", nil, "GameTooltipTemplate")
	tooltip:SetOwner(UIParent, "ANCHOR_NONE")
	for _, v in ipairs(DCSITEM_SLOT_FRAMES) do
		v.enchant:SetText("")
		-- local slotId, textureName = GetInventorySlotInfo(v) --Call for string parsing instead of table lookup, bleh.
		local item = Item:CreateFromEquipmentSlot(v:GetID())
		local itemLink = GetInventoryItemLink("player", v:GetID())
		if itemLink then
			local itemName, itemStringLink = GetItemInfo(itemLink)
			if itemStringLink then
				local _, _, Color, Ltype, Id, Enchant, Gem1, Gem2, Gem3, Gem4, Suffix, Unique, LinkLvl, Name = string.find(itemStringLink,
				"|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*):?(%d*):?(%-?%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?")

				if (Enchant == "2523") then
					addon.hasBiznicks = true
				end
				if showenchant then
					local quality = item:GetItemQuality()
					local color = ITEM_QUALITY_COLORS[quality] --color.hex is an escape sequence string, not digits like r,g,b are; Example Return: "|cff00c0ffDejaClassicStats" with only the opening not the trailing close, "|r"
					v.enchant:SetTextColor(color.r, color.g, color.b)
					if abbrevEnchants then
						v.enchant:SetText(DCS_ABBREV_ENCHANT_IDS[tonumber(""..Enchant.."")])
					else
						v.enchant:SetText(DCS_ENCHANT_IDS[tonumber(""..Enchant.."")])
					end
				else
					v.enchant:SetText("")
				end
			end
			tooltip:ClearLines()
			tooltip:SetHyperlink(itemLink)
		end
	end
end

gdbprivate.gdbdefaults.gdbdefaults.DejaClassicStatsShowEnchantChecked = {
	ShowEnchantSetChecked = true,
}

local DCS_ShowEnchantCheck = CreateFrame("CheckButton", "DCS_ShowEnchantCheck", DejaClassicStatsPanel, "InterfaceOptionsCheckButtonTemplate")
DCS_ShowEnchantCheck:RegisterEvent("PLAYER_LOGIN")
DCS_ShowEnchantCheck:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
DCS_ShowEnchantCheck:RegisterEvent("UNIT_STATS")

DCS_ShowEnchantCheck:ClearAllPoints()
	DCS_ShowEnchantCheck:SetPoint("TOPLEFT", "dcsItemsPanelCategoryFS", 7, -175)
	DCS_ShowEnchantCheck:SetScale(1)
	DCS_ShowEnchantCheck.tooltipText = L["Displays each equipped item's enchantment."].."\n\n\"Enchantment? Enchantment!\" -Sandal Feddic" --Creates a tooltip on mouseover.
	_G[DCS_ShowEnchantCheck:GetName() .. "Text"]:SetText(L["Enchants"])

DCS_ShowEnchantCheck:SetScript("OnEvent", function(self, event, ...)
	if event == "PLAYER_LOGIN" then
		showenchant = gdbprivate.gdb.gdbdefaults.DejaClassicStatsShowEnchantChecked.ShowEnchantSetChecked
		self:SetChecked(showenchant)
	end
	if PaperDollFrame:IsVisible() then
		DCS_Set_Dura_Item_Positions()
		DCS_Item_Enchant_GetText() --Shouldn't be needed as there is never a time when the paperdoll wont have to be opened to display this.
		DCS_Set_Item_Quality_Color_Outlines() --Here to update on the events when PaperDoll is open.
	end
end)

DCS_ShowEnchantCheck:SetScript("OnClick", function(self)
	showenchant = not showenchant
	gdbprivate.gdb.gdbdefaults.DejaClassicStatsShowEnchantChecked.ShowEnchantSetChecked = showenchant
	DCS_Set_Dura_Item_Positions()
	DCS_Item_Enchant_GetText()
end)

gdbprivate.gdbdefaults.gdbdefaults.DejaClassicStatsAbbrevEnchantsChecked = {
	AbbrevEnchantsSetChecked = true,
}

local DCS_AbbrevEnchantsCheck = CreateFrame("CheckButton", "DCS_AbbrevEnchantsCheck", DejaClassicStatsPanel, "InterfaceOptionsCheckButtonTemplate")
DCS_AbbrevEnchantsCheck:RegisterEvent("PLAYER_LOGIN")
DCS_AbbrevEnchantsCheck:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
DCS_AbbrevEnchantsCheck:RegisterEvent("UNIT_STATS")

DCS_AbbrevEnchantsCheck:ClearAllPoints()
	DCS_AbbrevEnchantsCheck:SetPoint("TOPLEFT", "dcsItemsPanelCategoryFS", 7, -195)
	DCS_AbbrevEnchantsCheck:SetScale(1)
	DCS_AbbrevEnchantsCheck.tooltipText = L["Displays an abbreviated label of each equipped item's enchantment."] --Creates a tooltip on mouseover.
	_G[DCS_AbbrevEnchantsCheck:GetName() .. "Text"]:SetText(L["Abbreviated Enchant Labels"])

DCS_AbbrevEnchantsCheck:SetScript("OnEvent", function(self, event, ...)
	if event == "PLAYER_LOGIN" then
		abbrevEnchants = gdbprivate.gdb.gdbdefaults.DejaClassicStatsAbbrevEnchantsChecked.AbbrevEnchantsSetChecked
		self:SetChecked(abbrevEnchants)
	end
	if PaperDollFrame:IsVisible() then
		DCS_Set_Dura_Item_Positions()
		DCS_Item_Enchant_GetText() --Shouldn't be needed as there is never a time when the paperdoll wont have to be opened to display this.
		DCS_Set_Item_Quality_Color_Outlines() --Here to update on the events when PaperDoll is open.
	end
end)

DCS_AbbrevEnchantsCheck:SetScript("OnClick", function(self)
	abbrevEnchants = not abbrevEnchants
	gdbprivate.gdb.gdbdefaults.DejaClassicStatsAbbrevEnchantsChecked.AbbrevEnchantsSetChecked = abbrevEnchants
	DCS_Set_Dura_Item_Positions()
	DCS_Item_Enchant_GetText()
end)

gdbprivate.gdbdefaults.gdbdefaults.DejaClassicStatsAlternateInfoPlacement = {
	AlternateInfoPlacementChecked = false,
}

PaperDollFrame:HookScript("OnShow", function(self)
	if showitemlevel then
		DCS_Item_Level_Center()
	else
		for _, v in ipairs(DCSITEM_SLOT_FRAMES) do
			v.ilevel:SetFormattedText("")
		end
	end
	if showrepair then
		DCS_Item_RepairCostBottom()
		DCS_Set_Dura_Item_Positions()
	else
		for _, v in ipairs(DCSITEM_SLOT_FRAMES) do
			v.itemrepair:SetFormattedText("")
		end
	end
	if showavgdur then
		DCS_Mean_Durability()
		if addon.duraMean == 100 then --check after calculation
			duraMeanFS:SetFormattedText("")
		else
			duraMeanFS:SetFormattedText("%.0f%%", addon.duraMean)
		end
	else
		duraMeanFS:SetFormattedText("")
		duraDurabilityFrameFS:Hide()
	end
	if showdura then
		DCS_Item_DurabilityTop()
	else
		for _, v in ipairs(DCSITEM_SLOT_FRAMES) do
			v.durability:SetFormattedText("")
		end
	end
	if showtextures then
		DCS_Durability_Bar_Textures()
		duraMeanTexture:Show()
	else
		for _, v in ipairs(DCSITEM_SLOT_FRAMES) do
			v.duratexture:Hide()
		end
		duraMeanTexture:Hide()
	end
	if showenchant then
		DCS_Item_Enchant_GetText()
	end
	DCS_Set_Item_Quality_Color_Outlines()
end)


-- local tempEnchantID = {
-- 	[256] = 600, -- (+75)
-- 	[263] = 600, -- (+25)
-- 	[264] = 600, -- (+50)
-- 	[265] = 600, -- (+75)
-- 	[266] = 600, -- (+100)
-- 	[3868] = 3600, -- (+100)
-- 	[4225] = 900, -- (+150)
-- 	[4264] = 600, -- (+15)
-- 	[4919] = 600, -- (+150)
-- 	[5386] = 600, -- (+200)
-- }

-- itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType,
-- itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice =
-- 	GetItemInfo(itemID or "itemString" or "itemName" or "itemLink")

-- local hasMainHandEnchant, mainHandExpiration, mainHandCharges, mainHandEnchantID, hasOffHandEnchant, offHandExpiration, offHandCharges, offHandEnchantId = GetWeaponEnchantInfo()
-- print()
-- local duration = tempEnchantID[mainHandEnchantID] or 3600

local DCS_AlternateInfoPlacementCheck = CreateFrame("CheckButton", "DCS_AlternateInfoPlacementCheck", DejaClassicStatsPanel, "InterfaceOptionsCheckButtonTemplate")
	DCS_AlternateInfoPlacementCheck:RegisterEvent("PLAYER_LOGIN")
	DCS_AlternateInfoPlacementCheck:ClearAllPoints()
	--DCS_AlternateInfoPlacementCheck:SetPoint("TOPLEFT", 30, -255)
	DCS_AlternateInfoPlacementCheck:SetPoint("TOPLEFT", "dcsItemsPanelCategoryFS", 7, -155)
	DCS_AlternateInfoPlacementCheck:SetScale(1)
	DCS_AlternateInfoPlacementCheck.tooltipText = L["Displays the item's info beside each item's slot."] --Creates a tooltip on mouseover.
	_G[DCS_AlternateInfoPlacementCheck:GetName() .. "Text"]:SetText(L["Display Info Beside Items"])

DCS_AlternateInfoPlacementCheck:SetScript("OnEvent", function(self, event, ...)
	otherinfoplacement = gdbprivate.gdb.gdbdefaults.DejaClassicStatsAlternateInfoPlacement.AlternateInfoPlacementChecked
	self:SetChecked(otherinfoplacement)
	DCS_Set_Dura_Item_Positions()
	DCS_Item_Level_Center()
	DCS_Item_Enchant_GetText()
end)

DCS_AlternateInfoPlacementCheck:SetScript("OnClick", function(self)
	otherinfoplacement = not otherinfoplacement
	gdbprivate.gdb.gdbdefaults.DejaClassicStatsAlternateInfoPlacement.AlternateInfoPlacementChecked = otherinfoplacement
	DCS_Set_Dura_Item_Positions()
end)

gdbprivate.gdbdefaults.gdbdefaults.DejaClassicStatsItemQualityBorders = {
	ItemQualityBordersChecked = true,
}

local DCS_ItemQualityBordersCheck = CreateFrame("CheckButton", "DCS_ItemQualityBordersCheck", DejaClassicStatsPanel, "InterfaceOptionsCheckButtonTemplate")
	DCS_ItemQualityBordersCheck:RegisterEvent("PLAYER_LOGIN")
	DCS_ItemQualityBordersCheck:ClearAllPoints()
	--DCS_ItemQualityBordersCheck:SetPoint("TOPLEFT", 30, -255)
	DCS_ItemQualityBordersCheck:SetPoint("TOPLEFT", "dcsItemsPanelCategoryFS", 7, -215)
	DCS_ItemQualityBordersCheck:SetScale(1)
	DCS_ItemQualityBordersCheck.tooltipText = L["Displays a colored border around each item's slot indicating its quality."] --Creates a tooltip on mouseover.
	_G[DCS_ItemQualityBordersCheck:GetName() .. "Text"]:SetText(L["Item Quality Borders"])

DCS_ItemQualityBordersCheck:SetScript("OnEvent", function(self, event, ...)
	qualityBordersChecked = gdbprivate.gdb.gdbdefaults.DejaClassicStatsItemQualityBorders.ItemQualityBordersChecked
	self:SetChecked(qualityBordersChecked)
	-- DCS_Set_Item_Quality_Color_Outlines() -- Don't use at login (only set check) as items are not cached until paperdoll has been opened thus error occurs as all item info is nil
end)

DCS_ItemQualityBordersCheck:SetScript("OnClick", function(self)
	qualityBordersChecked = not qualityBordersChecked
	gdbprivate.gdb.gdbdefaults.DejaClassicStatsItemQualityBorders.ItemQualityBordersChecked = qualityBordersChecked
	DCS_Set_Item_Quality_Color_Outlines()
end)

gdbprivate.gdbdefaults.gdbdefaults.DejaClassicStatsShowRunes = {
	ShowRunesChecked = true,
}

local DCS_ShowRunesCheck = CreateFrame("CheckButton", "DCS_ShowRunesCheck", DejaClassicStatsPanel, "InterfaceOptionsCheckButtonTemplate")
	DCS_ShowRunesCheck:RegisterEvent("PLAYER_LOGIN")
	DCS_ShowRunesCheck:ClearAllPoints()
	--DCS_ShowRunesCheck:SetPoint("TOPLEFT", 30, -295)
	DCS_ShowRunesCheck:SetPoint("TOPLEFT", "dcsRunesPanelCategoryFS", 7, -15)
	DCS_ShowRunesCheck:SetScale(1)
	_G[DCS_ShowRunesCheck:GetName() .. "Text"]:SetText(L["Runes"])
	DCS_ShowRunesCheck.tooltipText = L["Displays an item's rune to the side for easy visibility."] --Creates a tooltip on mouseover.

DCS_ShowRunesCheck:SetScript("OnEvent", function(self, event, ...)
	ShowRunes = gdbprivate.gdb.gdbdefaults.DejaClassicStatsShowRunes.ShowRunesChecked
	self:SetChecked(ShowRunes)
	DCS_SetRunes()
end)

DCS_ShowRunesCheck:SetScript("OnClick", function(self)
	ShowRunes = not ShowRunes
	gdbprivate.gdb.gdbdefaults.DejaClassicStatsShowRunes.ShowRunesChecked = ShowRunes
	DCS_SetRunes()
end)
