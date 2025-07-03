local selectedOption = "Claw"
local raidLeaderUnitID = nil

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

	if self:GetText() == "Hunter Melee (6)" then
		ChangeActionBarPage(6)
	elseif self:GetText() == "Hunter Range (1)" then
		ChangeActionBarPage(1)
	elseif self:GetText() == "Hunter Melee Raid (2)" then
		ChangeActionBarPage(2)
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

	info.text = "Hunter Melee Raid (2)"
	info.value = "Raptor Strike"
	info.func = OnClick
	UIDropDownMenu_AddButton(info, level)
end

UIDropDownMenu_Initialize(dropdown, Initialize)
UIDropDownMenu_SetWidth(dropdown, 150)
UIDropDownMenu_SetButtonWidth(dropdown, 124)
UIDropDownMenu_SetSelectedID(dropdown, 1)
UIDropDownMenu_JustifyText(dropdown, "LEFT")

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
				if not IsAutoRepeatSpell("Auto Shot") then
					box1.texture:SetColorTexture(0, 1, 0, 1)
				elseif not UnitIsUnit("target", raidLeaderUnitID .. "target") then
					box1.texture:SetColorTexture(0, 0, 1, 1)
				end
			elseif selectedOption == "Claw" then
				if not isFollowing then
					box1.texture:SetColorTexture(1, 1, 1, 1)
				elseif not IsCurrentSpell("Attack") then
					box1.texture:SetColorTexture(0, 1, 0, 1)
				elseif not UnitIsUnit("target", raidLeaderUnitID .. "target") then
					box1.texture:SetColorTexture(0, 0, 1, 1)
				end
			else
				local start, duration, enabled = GetSpellCooldown("Raptor Strike")
				if not isFollowing then
					box1.texture:SetColorTexture(1, 1, 1, 1)
				elseif not IsCurrentSpell("Attack") then
					box1.texture:SetColorTexture(0, 1, 0, 1)
				elseif not UnitIsUnit("target", raidLeaderUnitID .. "target") then
					box1.texture:SetColorTexture(0, 0, 1, 1)
				elseif IsUsableSpell("Raptor Strike") and start == 0 then
					box1.texture:SetColorTexture(0, 1, 1, 1)
				end
			end
		end
	elseif IsInGroup() then
		if UnitAffectingCombat("party1") and UnitHealth("party1target") ~= UnitHealthMax("party1target") then
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
				if not isFollowing then
					box1.texture:SetColorTexture(1, 1, 1, 1)
				elseif not (IsAutoRepeatSpell("Auto Shot") or IsCurrentSpell("Attack")) then
					box1.texture:SetColorTexture(0, 1, 0, 1)
				elseif not sametarget then
					box1.texture:SetColorTexture(0, 0, 1, 1)
				elseif not (name and sourceUnit == "player") and usable and not noMana and not close then
					box1.texture:SetColorTexture(1, 0, 0, 1)
				elseif not (name and sourceUnit2 == "player") and usable3 and not noMana3 then
					box1.texture:SetColorTexture(1, 0, 1, 1)
				elseif usable2 and not noMana2 and not close then
					box1.texture:SetColorTexture(0, 1, 1, 1)
				end
			elseif selectedOption == "Claw" then
				local points = GetComboPoints("player", "target")

				if not isFollowing then
					box1.texture:SetColorTexture(1, 1, 1, 1)
				elseif not IsCurrentSpell("Attack") then
					box1.texture:SetColorTexture(0, 1, 0, 1)
				elseif not UnitIsUnit("target", "party1target") then
					box1.texture:SetColorTexture(0, 0, 1, 1)
				elseif GetComboPoints >= 3 then
					box1.texture:SetColorTexture(1, 0, 0, 1)
				elseif IsUsableSpell("Claw") then
					box1.texture:SetColorTexture(0, 1, 1, 1)
				end
			else
				local start, duration, enabled = GetSpellCooldown("Raptor Strike")
				if not isFollowing then
					box1.texture:SetColorTexture(1, 1, 1, 1)
				elseif not IsCurrentSpell("Attack") then
					box1.texture:SetColorTexture(0, 1, 0, 1)
				elseif not UnitIsUnit("target", "party1target") then
					box1.texture:SetColorTexture(0, 0, 1, 1)
				elseif IsUsableSpell("Raptor Strike") and start == 0 then
					box1.texture:SetColorTexture(0, 1, 1, 1)
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

	if event == "MERCHANT_SHOW" then
		print("vendor opened!")

		for bag = 0, NUM_BAG_SLOTS do
			local numSlots = C_Container.GetContainerNumSlots(bag)
			for slot = 1, numSlots do
				local itemInfo = C_Container.GetContainerItemInfo(bag, slot)
				if itemInfo then
					local itemLink = C_Container.GetContainerItemLink(bag, slot)
					if itemLink then
						local _, _, itemRarity, _, _, _, _, _, _, _, itemPrice = GetItemInfo(itemLink)
						if (itemRarity == 0 or itemRarity == 1) and itemPrice > 0 then
							C_Container.UseContainerItem(bag, slot)
							print("Sold: " .. itemLink .. " x" .. itemInfo.stackCount)
						end
					end
				end
			end
		end
	end
end)
