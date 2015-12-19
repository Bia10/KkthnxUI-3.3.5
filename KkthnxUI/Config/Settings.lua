local K, C, L = unpack(select(2, ...));

-- Main Media options
C["media"] = {
	["abtextures"] = [[Interface\Addons\KkthnxUI\Media\Actionbars\]],
	["auratextures"] = [[Interface\Addons\KkthnxUI\Media\Buffs\]],
	["backdrop_color"] = {0.05, 0.05, 0.05, .9},
	["blank"] = [[Interface\AddOns\KkthnxUI\Media\Textures\Blank.tga]],
	["blank_font"] = [[Interface\AddOns\KkthnxUI\Media\Fonts\Invisible.ttf]],
	["blizz"] = [[Interface\Tooltips\UI-Tooltip-Border]],
	["blizzborder"] = [[Interface\Buttons\UI-Quickslot2]],
	["border_color"] = {0.4, 0.4, 0.4, 1},
	["bordertextures"] = [[Interface\Addons\KkthnxUI\Media\Border\]],
	["combat_font"] = [[Interface\AddOns\KkthnxUI\Media\Fonts\Damage.ttf]],
	["empty"] = [[Interface\AddOns\KkthnxUI\Media\Textures\Empty.tga]],
	["glow"] = [[Interface\AddOns\KkthnxUI\Media\Textures\GlowTex.tga]],
	["normal_font"] = [[Interface\AddOns\KkthnxUI\Media\Fonts\Normal.ttf]],
	["overlay_color"] = {0, 0, 0, 0.7},
	["texture"] = [[Interface\TargetingFrame\UI-StatusBar]],
	--["unitframe_font"] = [[Interface\AddOns\KkthnxUI\Media\Fonts\Unitframe.ttf]],
	["unitframe_font"] = [[Interface\AddOns\KkthnxUI\Media\Fonts\Normal.ttf]],
	["warning_sound"] = [[Interface\AddOns\KkthnxUI\Media\Sounds\Warning.ogg]],
	["whisp_sound"] = [[Interface\AddOns\KkthnxUI\Media\Sounds\Whisper.ogg]],
}
-- ActionBar options
C["actionbar"] = {
	["oor"] = { 0.8, 0.1, 0.1 },
	["oom"] = { 0.5, 0.5, 1.0 },
	["enable"] = true,
	["scale"] = 1,
	["showgrid"] = true,
	["showhotkeys"] = true,
	["showmacroname"] = true,
	["skinbuttons"] = true,
	["removetextures"] = false,
}
C["cooldown"] = {
	["treshold"] = 3,
	["fontsize"] = 20,
}
-- Announcements options
C["announcements"] = {
	["sayinterrupt"] = true,
	["auraannounce"] = true,
	["saysapped"] = true,
}
-- Automation options
C["automation"] = {
	["autocollapse"] = true,
	["autoinvite"] = false,
	["declineduel"] = false,
	["resurrection"] = false,
	["repairnsell"] = false,
}
-- Blizzard options
C["blizzard"] = {
	["capturebar"] = true,
	["durability"] = true,
	["moveachievements"] = true,
	["questbuttonsize"] = 26,
	["repreward"] = true,
	["classcolor"] = true,
}
-- Buffs / Debuffs options
C["buffs"] = {
	["aurasperrow"] = 12,
	["buffsize"] = 34,
	["debuffsize"] = 40,
	["enable"] = true,
	["paddingx"] = 6,
	["paddingy"] = 6,
}
-- Chat options
C["chat"] = {
	["combatlog"] = true,
	["enable"] = true,
	["height"] = 112,
	["outline"] = false,
	["tabsoutline"] = false,
	["sticky"] = true,
	["tabmouseover"] = true,
	["time_color"] = {1, 1, 0},
	["whisp_sound"] = true,
	["width"] = 350,
}
-- Error options
C["error"] = {
	["black"] = true,
	["combat"] = false,
	["white"] = false,
}
-- General options
C["general"] = {
	["auto_scale"] = true,
	["uiscale"] = 0.71111111111111,
	["welcome_message"] = true,
}
-- Loot options
C["loot"] = {
	["auto_confirm_de"] = false,
	["auto_greed"] = false,
	["icon_size"] = 30,
	["lootframe"] = true,
	["rolllootframe"] = true,
	["width"] = 222,
}
-- Minimap options
C["minimap"] = {
	["collectbuttons"] = true,
	["enable"] = true,
	["size"] = 150,
	["nodeflash"] = true,
}
-- Miscellaneous options
C["misc"] = {
	["alreadyknown"] = false,
	["hattrick"] = true,
	["mail"] = true,
}
C["nameplate"] = {
	["enable"] = true,
	["height"] = 9,
	["width"] = 100,
	["cbheight"] = 5,
	["cbwidth"] = 120,
	["combat"] = false,
	["iconsize"] = 26,
	["healthvalue"] = false,
	["showcastbarname"] = false,
	["enhancethreat"] = true,
	["classicons"] = false,
	["nameabbrev"] = false,
	["goodcolor"] = {75/255, 175/255, 76/255},
	["badcolor"] = {0.78, 0.25, 0.25},
	["transitioncolor"] = {218/255, 197/255, 92/255},
	["hostilecolor"] = {0.78, 0.25, 0.25},
	["friendlyplayercolor"] = {75/255, 175/255, 76/255},
	["neutralcolor"] = {218/255, 197/255, 92/255},
	["friendlynpccolor"] = {0.31, 0.45, 0.63},
	["trackauras"] = true,
	["aurassize"] = 22,
}
-- Addonskin options
C["skins"] = {
	["chatbubble"] = true,
	["bigwigs"] = false,
	["dbm"] = false,
	["skada"] = false,
}
-- Tooltip options
C["tooltip"] = {
	["enable"] = true,
	["fontoutline"] = false,
	["itemicon"] = true,
	["qualitybordercolor"] = true,
	["spellid"] = true,
	["shiftmodifer"] = false,
	["hidebuttons"] = false,
	["healthinside"] = true,
	-- Plugins
	["talents"] = false,
	["achievements"] = true,
	["target"] = true,
	["title"] = false,
	["rank"] = true,
	["arenaexperience"] = false,
}
-- Unitframe options
C["unitframe"] = {
	["auraoffsety"] = 3,
	["cbscale"] = 1.193,
	["classhealth"] = false,
	["classicon"] = false,
	["combatfeedback"] = false,
	["enable"] = true,
	["groupnumber"] = false,
	["largeaura"] = 27,
	["partyscale"] = 1.193,
	["enhancedframes"] = true,
	["scale"] = 1.193,
	["smallaura"] = 22,
	["betterpowercolor"] = false,
}