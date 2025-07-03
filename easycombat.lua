local selectedOption = "Claw"

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
end

local function Initialize(self, level)
	local info = UIDropDownMenu_CreateInfo()

	info.text = "Druid"
	info.value = "Claw"
	info.func = OnClick
	UIDropDownMenu_AddButton(info, level)

	info.text = "Hunter Melee"
	info.value = "Raptor Strike"
	info.func = OnClick
	UIDropDownMenu_AddButton(info, level)

	info.text = "Hunter Range"
	info.value = "Arcane Shot"
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
	if IsInGroup() then
		if UnitAffectingCombat("party1") and UnitHealth("party1target") ~= UnitHealthMax("party1target") then
			box1.texture:SetColorTexture(1, 1, 0, 1)
			if not isFollowing and selectedOption ~= "Arcane Shot" then
				box1.texture:SetColorTexture(1, 1, 1, 1)
			elseif not IsCurrentSpell("Attack") then
				box1.texture:SetColorTexture(0, 1, 0, 1)
			elseif not UnitIsUnit("target", "party1target") then
				box1.texture:SetColorTexture(0, 0, 1, 1)
			end
		else
		end
	end
end)

f:RegisterEvent("AUTOFOLLOW_BEGIN")
f:RegisterEvent("AUTOFOLLOW_END")

f:SetScript("OnEvent", function(self, event, ...)
	if event == "AUTOFOLLOW_BEGIN" then
		local name = ...
		isFollowing = true
		print("Now following: " .. (name or "unknown"))
	elseif event == "AUTOFOLLOW_END" then
		isFollowing = false
		print("Stopped following")
	end
end)
