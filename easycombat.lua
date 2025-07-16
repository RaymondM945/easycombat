local selectedOption = "Claw"
local raidLeaderUnitID = nil
local checkfollow = true
local WingclipEnabled = true
local selectedThreshold = 95
local myFrame = CreateFrame("Frame", "MySelectionFrame", UIParent, "BasicFrameTemplateWithInset")
myFrame:SetSize(220, 70)
myFrame:SetPoint("TOP", UIParent, "TOP", 0, 0)

myFrame.title = myFrame:CreateFontString(nil, "OVERLAY")
myFrame.title:SetFontObject("GameFontHighlight")
myFrame.title:SetPoint("LEFT", myFrame.TitleBg, "LEFT", 5, 0)
myFrame.title:SetText("Select an Option")

-- Create the dropdown
local dropdown = CreateFrame("Frame", "MyDropdown", myFrame, "UIDropDownMenuTemplate")
dropdown:SetPoint("TOPLEFT", myFrame, "TOPLEFT", 10, -30)

local function OnClick(self)
	UIDropDownMenu_SetSelectedID(dropdown, self:GetID())
	selectedOption = self.value
	print("You selected: " .. self:GetText())
	if self:GetText() == "Druid" then
		ChangeActionBarPage(1)
	elseif self:GetText() == "Hunter Melee (6)" then
		ChangeActionBarPage(6)
	elseif self:GetText() == "Hunter Range (1)" then
		ChangeActionBarPage(1)
	elseif self:GetText() == "Hunter Melee Raid (4)" then
		ChangeActionBarPage(4)
	elseif self:GetText() == "Hunter Range Raid (5)" then
		ChangeActionBarPage(5)
	elseif self:GetText() == "Moonkin (3)" then
		ChangeActionBarPage(3)
	end
end

local function Initialize(self, level)
	local info = UIDropDownMenu_CreateInfo()

	info.text = "Druid"
	info.value = "Claw"
	info.func = OnClick
	UIDropDownMenu_AddButton(info, level)

	info.text = "Hunter Melee (6)"
	info.value = "Raptor Strike"
	info.func = OnClick
	UIDropDownMenu_AddButton(info, level)

	info.text = "Hunter Range (1)"
	info.value = "Arcane Shot"
	info.func = OnClick
	UIDropDownMenu_AddButton(info, level)

	info.text = "Hunter Melee Raid (4)"
	info.value = "Raptor Strike"
	info.func = OnClick
	UIDropDownMenu_AddButton(info, level)
	info.text = "Hunter Range Raid (5)"
	info.value = "Arcane Shot"
	info.func = OnClick
	UIDropDownMenu_AddButton(info, level)

	info.text = "Moonkin (3)"
	info.value = "Wrath"
	info.func = OnClick
	UIDropDownMenu_AddButton(info, level)
end

UIDropDownMenu_Initialize(dropdown, Initialize)
UIDropDownMenu_SetWidth(dropdown, 150)
UIDropDownMenu_SetButtonWidth(dropdown, 124)
UIDropDownMenu_SetSelectedID(dropdown, 1)
UIDropDownMenu_JustifyText(dropdown, "LEFT")

local dropdown3 = CreateFrame("Frame", "MyDropdown3", myFrame, "UIDropDownMenuTemplate")
dropdown3:SetPoint("TOPLEFT", dropdown, "BOTTOMLEFT", 0, -50)

local function OnClickDropdown3(self)
	UIDropDownMenu_SetSelectedID(dropdown3, self:GetID())
	selectedThreshold = tonumber(self.value)
	print("Threshold selected: " .. selectedThreshold .. "%")
end

local function InitializeDropdown3(self, level)
	local thresholds = { 95, 90, 85, 80, 75, 70, 65, 60 }
	for i, value in ipairs(thresholds) do
		local info = UIDropDownMenu_CreateInfo()
		info.text = tostring(value)
		info.value = value
		info.func = OnClickDropdown3
		UIDropDownMenu_AddButton(info, level)
	end
end

UIDropDownMenu_Initialize(dropdown3, InitializeDropdown3)
UIDropDownMenu_SetWidth(dropdown3, 150)
UIDropDownMenu_SetButtonWidth(dropdown3, 124)
UIDropDownMenu_SetSelectedID(dropdown3, 1)
UIDropDownMenu_JustifyText(dropdown3, "LEFT")

local myCheckbox = CreateFrame("CheckButton", "MySelectionFrameCheckbox", myFrame, "ChatConfigCheckButtonTemplate")

myCheckbox:SetPoint("TOPLEFT", dropdown, "BOTTOMLEFT", 0, -10)

MySelectionFrameCheckboxText:SetText("Check for follow")

myCheckbox:SetChecked(checkfollow)

myCheckbox:SetScript("OnClick", function(self)
	if self:GetChecked() then
		print("Checkbox enabled!")
		checkfollow = true
	else
		print("Checkbox disabled!")
		checkfollow = false
	end
end)

local myCheckbox2 = CreateFrame("CheckButton", "MySelectionFrameCheckbox2", myFrame, "ChatConfigCheckButtonTemplate")

myCheckbox2:SetPoint("TOPLEFT", dropdown, "BOTTOMLEFT", 0, -25)

MySelectionFrameCheckbox2Text:SetText("Do Wing Clip")

myCheckbox2:SetChecked(WingclipEnabled)

myCheckbox2:SetScript("OnClick", function(self)
	if self:GetChecked() then
		print("wing clip enabled!")
		WingclipEnabled = true
	else
		print("wing clip disabled!")
		WingclipEnabled = false
	end
end)

local box1 = CreateFrame("Frame", "MyBox1", UIParent)
box1:SetSize(50, 50)
box1:SetPoint("CENTER", 25, 0)
box1.texture = box1:CreateTexture(nil, "BACKGROUND")
box1.texture:SetAllPoints()
box1.texture:SetColorTexture(0, 0, 0, 1)

local isFollowing = false

local f = CreateFrame("Frame")
f:SetScript("OnUpdate", function(self, elapsed)
	box1.texture:SetColorTexture(0, 0, 0, 1)

	if IsInRaid() then
		if
			UnitAffectingCombat(raidLeaderUnitID)
			and UnitHealth(raidLeaderUnitID .. "target") ~= UnitHealthMax(raidLeaderUnitID .. "target")
		then
			box1.texture:SetColorTexture(1, 1, 0, 1)

			if selectedOption == "Arcane Shot" then
				local serpentStingName = GetSpellInfo(1978)
				local huntersMarkName = GetSpellInfo(1130)
				local name, _, _, _, _, _, sourceUnit = AuraUtil.FindAuraByName(serpentStingName, "target", "HARMFUL")
				local name2, _, _, _, _, _, sourceUnit2 = AuraUtil.FindAuraByName(huntersMarkName, "target", "HARMFUL")
				local usable, noMana = IsUsableSpell(serpentStingName)
				local usable2, noMana2 = IsUsableSpell("Arcane Shot")
				local usable3, noMana3 = IsUsableSpell(huntersMarkName)
				local close = CheckInteractDistance("target", 3) or false
				local sametarget = UnitIsUnit("target", raidLeaderUnitID .. "target")

				if not isFollowing and checkfollow then
					box1.texture:SetColorTexture(1, 1, 1, 1)
				elseif not (IsAutoRepeatSpell("Auto Shot") or IsCurrentSpell("Attack")) then
					box1.texture:SetColorTexture(0, 1, 0, 1)
				elseif not sametarget then
					box1.texture:SetColorTexture(0, 0, 1, 1)
				elseif not (name2 and sourceUnit2 == "player") and usable3 and not noMana3 then
					box1.texture:SetColorTexture(1, 0, 1, 1)
				elseif not (name and sourceUnit == "player") and usable and not noMana and not close then
					box1.texture:SetColorTexture(1, 0, 0, 1)
				elseif usable2 and not noMana2 and not close then
					box1.texture:SetColorTexture(0, 1, 1, 1)
				end
			elseif selectedOption == "Claw" then
				local sametarget = UnitIsUnit("target", raidLeaderUnitID .. "target")

				local usable, noMana = IsUsableSpell("Claw")
				print(raidLeaderUnitID)
				print(IsUsableSpell("Claw"))
				local faerieFireFeralName = GetSpellInfo(16857)
				local usable2, noMana2 = IsUsableSpell(faerieFireFeralName)
				local hasfaerieFire = AuraUtil.FindAuraByName(faerieFireFeralName, "target", "HARMFUL|PLAYER") ~= nil
				local points = GetComboPoints("player", "target")
				if not isFollowing and checkfollow then
					box1.texture:SetColorTexture(1, 1, 1, 1)
				elseif not IsCurrentSpell("Attack") then
					box1.texture:SetColorTexture(0, 1, 0, 1)
				elseif not sametarget then
					box1.texture:SetColorTexture(0, 0, 1, 1)
				elseif not hasfaerieFire and usable2 and not noMana2 then
					box1.texture:SetColorTexture(1, 0, 1, 1)
				elseif points >= 3 then
					box1.texture:SetColorTexture(1, 0, 0, 1)
				elseif usable and not noMana then
					box1.texture:SetColorTexture(0, 1, 1, 1)
				end
			else
				local start, duration, enabled = GetSpellCooldown("Raptor Strike")

				local wingclipname = GetSpellInfo(2974)
				local name, _, _, _, _, _, sourceUnit = AuraUtil.FindAuraByName(wingclipname, "target", "HARMFUL")
				local usable, noMana = IsUsableSpell(wingclipname)
				local sametarget = UnitIsUnit("target", raidLeaderUnitID .. "target")

				if not isFollowing and checkfollow then
					box1.texture:SetColorTexture(1, 1, 1, 1)
				elseif not IsCurrentSpell("Attack") then
					box1.texture:SetColorTexture(0, 1, 0, 1)
				elseif not sametarget then
					box1.texture:SetColorTexture(0, 0, 1, 1)
				elseif IsUsableSpell("Raptor Strike") and start == 0 then
					box1.texture:SetColorTexture(0, 1, 1, 1)
				elseif not (name and sourceUnit == "player") and usable and not noMana and WingclipEnabled then
					box1.texture:SetColorTexture(1, 0, 0, 1)
				end
			end
		end
	elseif IsInGroup() then
		local targethealth = UnitHealth("party1target")
		local targetmaxHealth = UnitHealthMax("party1target")
		local hpPercent = (targethealth / targetmaxHealth) * 100
		if UnitAffectingCombat("party1") and hpPercent < selectedThreshold then
			box1.texture:SetColorTexture(1, 1, 0, 1)

			if selectedOption == "Arcane Shot" then
				local serpentStingName = GetSpellInfo(1978)
				local huntersMarkName = GetSpellInfo(1130)
				local name, _, _, _, _, _, sourceUnit = AuraUtil.FindAuraByName(serpentStingName, "target", "HARMFUL")
				local name2, _, _, _, _, _, sourceUnit2 = AuraUtil.FindAuraByName(huntersMarkName, "target", "HARMFUL")
				local usable, noMana = IsUsableSpell(serpentStingName)
				local usable2, noMana2 = IsUsableSpell("Arcane Shot")
				local usable3, noMana3 = IsUsableSpell(huntersMarkName)
				local close = CheckInteractDistance("target", 3) or false
				local sametarget = UnitIsUnit("target", "party1target")
				if not isFollowing and checkfollow then
					box1.texture:SetColorTexture(1, 1, 1, 1)
				elseif not (IsAutoRepeatSpell("Auto Shot") or IsCurrentSpell("Attack")) then
					box1.texture:SetColorTexture(0, 1, 0, 1)
				elseif not sametarget then
					box1.texture:SetColorTexture(0, 0, 1, 1)
				elseif not (name2 and sourceUnit2 == "player") and usable3 and not noMana3 then
					box1.texture:SetColorTexture(1, 0, 1, 1)
				elseif not (name and sourceUnit == "player") and usable and not noMana and not close then
					box1.texture:SetColorTexture(1, 0, 0, 1)
				elseif usable2 and not noMana2 and not close then
					box1.texture:SetColorTexture(0, 1, 1, 1)
				end
			elseif selectedOption == "Claw" then
				local points = GetComboPoints("player", "target")
				local usable, noMana = IsUsableSpell("Claw")
				local faerieFireFeralName = GetSpellInfo(16857)
				local usable2, noMana2 = IsUsableSpell(faerieFireFeralName)
				local name, _, _, _, _, _, sourceUnit =
					AuraUtil.FindAuraByName(faerieFireFeralName, "target", "HARMFUL")
				local sametarget = UnitIsUnit("target", "party1target")
				if not isFollowing and checkfollow then
					box1.texture:SetColorTexture(1, 1, 1, 1)
				elseif not IsCurrentSpell("Attack") then
					box1.texture:SetColorTexture(0, 1, 0, 1)
				elseif not sametarget then
					box1.texture:SetColorTexture(0, 0, 1, 1)
				elseif not (name and sourceUnit == "player") and usable2 and not noMana2 then
					box1.texture:SetColorTexture(1, 0, 1, 1)
				elseif points >= 3 then
					box1.texture:SetColorTexture(1, 0, 0, 1)
				elseif usable and not noMana then
					box1.texture:SetColorTexture(0, 1, 1, 1)
				end
			elseif selectedOption == "Wrath" then
				local starfire = GetSpellInfo(2912)
				local usable3, noMana3 = IsUsableSpell(starfire)
				local wrath = GetSpellInfo(5176)
				local usable, noMana = IsUsableSpell(wrath)

				local spellName, _, _, startTime, endTime, isTradeSkill = UnitCastingInfo("player")

				local moonfire = GetSpellInfo(8921)
				local usable2, noMana2 = IsUsableSpell(moonfire)
				local hasMoonfire = AuraUtil.FindAuraByName(moonfire, "target", "HARMFUL|PLAYER") ~= nil

				local faerieFire = GetSpellInfo(770)
				local usable3, noMana3 = IsUsableSpell(faerieFire)
				local hasfaerieFire = AuraUtil.FindAuraByName(faerieFire, "target", "HARMFUL|PLAYER") ~= nil
				local sametarget = UnitIsUnit("target", "party1target")

				if not isFollowing and checkfollow then
					box1.texture:SetColorTexture(1, 1, 1, 1)
				elseif not IsCurrentSpell("Attack") then
					box1.texture:SetColorTexture(0, 1, 0, 1)
				elseif not sametarget then
					box1.texture:SetColorTexture(0, 0, 1, 1)
				elseif usable3 and not UnitPower("player", 0) and not hasfaerieFire then
					box1.texture:SetColorTexture(1, 0, 1, 1)
				elseif usable2 and not noMana2 and not hasMoonfire then
					box1.texture:SetColorTexture(1, 0, 0, 1)
				elseif usable3 and UnitPower("player", 0) > 250 and spellName ~= starfire then
					box1.texture:SetColorTexture(0, 1, 1, 1)
					-- elseif usable and not noMana and spellName ~= wrath then
					-- 	box1.texture:SetColorTexture(0, 1, 1, 1)
				end
			else
				local start, duration, enabled = GetSpellCooldown("Raptor Strike")

				local wingclipname = GetSpellInfo(2974)
				local name, _, _, _, _, _, sourceUnit = AuraUtil.FindAuraByName(wingclipname, "target", "HARMFUL")
				local usable, noMana = IsUsableSpell(wingclipname)
				local sametarget = UnitIsUnit("target", "party1target")
				local usable2, noMana2 = IsUsableSpell("Raptor Strike")
				if not isFollowing and checkfollow then
					box1.texture:SetColorTexture(1, 1, 1, 1)
				elseif not IsCurrentSpell("Attack") then
					box1.texture:SetColorTexture(0, 1, 0, 1)
				elseif not sametarget then
					box1.texture:SetColorTexture(0, 0, 1, 1)
				elseif usable2 and not noMana2 and start == 0 then
					box1.texture:SetColorTexture(0, 1, 1, 1)
				elseif not (name and sourceUnit == "player") and usable and not noMana and WingclipEnabled then
					box1.texture:SetColorTexture(1, 0, 0, 1)
				end
			end
		else
		end
	else
	end
end)

f:RegisterEvent("AUTOFOLLOW_BEGIN")
f:RegisterEvent("AUTOFOLLOW_END")
f:RegisterEvent("GROUP_ROSTER_UPDATE")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("MERCHANT_SHOW")
f:SetScript("OnEvent", function(self, event, ...)
	if IsInRaid() then
		print("You are in a raid!")
		for i = 1, GetNumGroupMembers() do
			local name, rank = GetRaidRosterInfo(i)
			if rank == 2 then
				raidLeaderName = name
				raidLeaderUnitID = "raid" .. i
				print("Raid leader is: " .. raidLeaderName .. " (" .. raidLeaderUnitID .. ")")
				break
			end
		end
	elseif IsInGroup() then
		print("You are in a party!")
	else
		print("You are solo!")
	end

	if event == "AUTOFOLLOW_BEGIN" then
		local name = ...
		isFollowing = true
		print("Now following: " .. (name or "unknown"))
	elseif event == "AUTOFOLLOW_END" then
		isFollowing = false
		print("Stopped following")
	end
end)
