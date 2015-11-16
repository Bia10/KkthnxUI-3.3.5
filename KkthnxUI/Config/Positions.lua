local K, C, L = unpack(select(2, ...));

C["position"] = {
	["achievements"] = {"TOP", UIParent, "TOP", 0, -21},
	["bgscore"] = {"BOTTOMLEFT", ActionButton12, "BOTTOMRIGHT", 100, -2},
	["bn_popup"] = {"BOTTOMLEFT", UIParent, "BOTTOMLEFT", 21, 20},
	["capturebar"] = {"TOP", UIParent, "TOP", 0, -170},
	["chat"] = {"BOTTOMLEFT", UIParent, "BOTTOMLEFT", 3, 5},
	["expframe"] = {"TOP", Minimap, "BOTTOM", 0, -30},
	["group_loot"] = {"BOTTOM", UIParent, "BOTTOM", -238, 700},
	["locframe"] = {"TOP", Minimap, "BOTTOM", 0, 0},
	["loot"] = {"TOPLEFT", UIParent, "TOPLEFT", 245, -220},
	["minimap"] = {"TOPRIGHT", UIParent, "TOPRIGHT", -7, -7},
	["minimap_buttons"] = {"TOPRIGHT", Minimap, "TOPLEFT", -3, 2},
	["playercastbar"] = {"CENTER", UIParent, "CENTER", 0, -160},
	["playerframe"] = {"CENTER", UIParent, "CENTER", -210, -160},
	["pulsecooldown"] = {"CENTER", UIParent, "CENTER", -210, 20},
	["quest"] = {"RIGHT", UIParent, "RIGHT", -182.00, 193.00},
	["statsframe"] = {"TOP", Minimap, "BOTTOM", 0, -15},
	["targetframe"] = {"CENTER", UIParent, "CENTER", 210, -160},
	["actionbarextras"] = {"BOTTOM", MultiBarBottomRightButton1, "TOP", -3, 7},
	["tooltip"] = {"BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -3, 3},
	["uierror"] = {"TOP", UIParent, "TOP", 0, -30},
}