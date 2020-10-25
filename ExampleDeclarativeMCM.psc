Scriptname ExampleDeclarativeMCM extends DeclarativeMCMHelper

; Start by declaring all of the variables we want to use, and their default
; values. This code runs once on startup, and again when the mod is updated.
; If you don't override LocalDevelopment(), it will also run once on every game
; load, so that you can easily declare new variables on the development version
; of your mod.
; Right before this function is called, all variables are un-declared so that
; you can re-declare them with different arguments. This won't erase any of the
; actual values, however, so the user's settings are preserved.
Function DeclareVariables()
	; Variable names should be prefixed with the mod name to avoid collisions.
	DeclareBool("MyExampleMod:ModEnabled")

	; Default values are given as an additional argument.
	DeclareInt("MyExampleMod:HorseArmorPrice", 500)
	DeclareFloat("MyExampleMod:HorseArmorWeight", 100.0)
	DeclareString("MyExampleMod:HorseName", "Frost")

	; For enumerated types, you must indicate how many values there are.
	; The values always start at zero.
	DeclareEnum("MyExampleMod:HorseArmorType", 4, HORSE_ARMOR_STEEL)

	; For key codes, we need to give a short description so that key conflicts
	; can be reported to other mods which try to use the same key.
	; The true means "Call RegisterForKey() when the key is mapped." If you want
	; to deal with registering for keys yourself, set it to false.
	; The default value of zero is interpreted as "no key" and RegisterForKey()
	; will not be called until the user changes it to something else.
	DeclareKeyCode("MyExampleMod:HorseArmorHotkey", "Apply Horse Armor", true)

	; For colors, use an integer. It's stored as 0xRRGGBB, so 0xFFFFFF is white.
	DeclareInt("MyExampleMod:HorseColor", 0xFFFFFF)

	; You can do this in the Creation Kit instead, if you prefer.
	DeclarePage("Main")

	; Can also pass x and y arguments as offsets.
	DeclareLogo("MyExampleMod/logo.dds")
EndFunction

; Enum constants for MyExampleMod:HorseArmorType:
Int Property HORSE_ARMOR_IRON = 0 autoreadonly
Int Property HORSE_ARMOR_STEEL = 1 autoreadonly
Int Property HORSE_ARMOR_DWARVEN = 2 autoreadonly
Int Property HORSE_ARMOR_EBONY = 3 autoreadonly

; Now, it's time to build our UI.
Function MakeUserInterface(String page)
	; Since we called DeclareLogo(), the default page is handled for us, so we
	; need not check page != ""

	; You can still call all of the usual MCM functions from here.
	AddHeaderOption("My Example Mod")
	AddEmptyOption()

	; The variable should have already been declared earlier, but if we forget,
	; it is declared automatically. The second argument is the label, and the
	; third is the text that shows at the bottom of the screen on hover.
	MakeCheckbox("MyExampleMod:ModEnabled", "Enable mod", "Enables or disables horse armor.")

	; Sliders have a lot of additional options. This one goes from zero to 2000,
	; in 10-step increments. The result is always an exact integer.
	MakeIntSlider("MyExampleMod:HorseArmorPrice", "Horse armor price", 0, 2000, 10, "How much horse armor should cost, in septims.", "{0} septims")
	; This one goes from 0 to 200, in 0.5-step increments.
	MakeFloatSlider("MyExampleMod:HorseArmorWeight", "Horse armor weight", 0.0, 200.0, 0.5, "How much horse armor should weigh.", "{1}")

	; A simple drop-down menu.
	String[] choices = new String[4]
	choices[0] = "Iron"
	choices[1] = "Steel"
	choices[2] = "Dwarven"
	choices[3] = "Ebony"
	MakeDropdown("MyExampleMod:HorseArmorType", "Horse armor type", choices, "What type of horse armor you want.")
	; You could also use MakeCycler(), which takes the same arguments. It makes
	; a text option that cycles through the choices one at a time when the user
	; selects it.

	MakeKeyMap("MyExampleMod:HorseArmorHotkey", "Apply horse armor", "Hotkey to apply or remove horse armor.")
	MakeColor("MyExampleMod:HorseColor", "Horse color", "Color of your horse.")

	; You can easily create save and load buttons for all declared variables.
	MakeSaveButton("../MyExampleMod/profile", "Save settings", "Save", "Save your settings to an external file.", "Your settings have been saved.", "Something went wrong.")
	MakeLoadButton("../MyExampleMod/profile", "Load settings", "Load", "Load your settings from an external file.", "Your settings have been loaded.", "Something went wrong.")
EndFunction

; We do not need to implement any of the OnOptionSelect etc. events. They're
; done for us!

Event OnKeyDown(Int KeyCode)
	If KeyCode == StorageUtil.GetIntValue(None, "MyExampleMod:HorseArmorHotkey") && StorageUtil.GetIntValue(None, "MyExampleMod:ModEnabled")
		Debug.Notification("Applying your " + StorageUtil.GetIntValue(None, "MyExampleMod:HorseArmorPrice") + " septim armor to " + StorageUtil.GetStringValue(None, "MyExampleMod:HorseName"))
		Debug.Notification("It weighs " + StorageUtil.GetFloatValue(None, "MyExampleMod:HorseArmorWeight"))
		; and so on...
		return
	EndIf
	; Handle other hotkeys...
EndEvent
