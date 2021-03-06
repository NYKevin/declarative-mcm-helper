Scriptname ExampleDeclarativeMCM extends DeclarativeMCMHelper
; This file is an example of a simple MCM. It's meant to demonstrate most of the
; available functionality, but it can't cover everything. Read
; DeclarativeMCMHelper.psc if you want an API reference.

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
	; While we're at it, let's create the strings that will be used to describe
	; those enum constants:
	If !EnumLabels
		EnumLabels = new String[4]
		EnumLabels[0] = "Iron"
		EnumLabels[1] = "Steel"
		EnumLabels[2] = "Dwarven"
		EnumLabels[3] = "Ebony"
	EndIf

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

	; This logo will appear automatically when the user opens the menu.
	DeclareLogo("MyExampleMod/logo.dds")
	; Can also pass x and y arguments as offsets.

	; A is binary 1010, so this is alternating ones and zeros.
	DeclareInt("MyExampleMod:SlotMask", 0xAAAAAAAA)
	; When executing other startup code, we need to be careful, because
	; DeclareVariables() may be called more than once.
	If !MaskLabels
		MaskLabels = new String[32]
		Int i
		While i < 32
			; Slot numbers start at 30.
			; Horses don't use all 32 slots, but let's ignore that for now.
			MaskLabels[i] = (i+30) as String
			; Creating lots of strings can take an unreasonable amount of time,
			; so it's usually a good idea to put that logic here instead of
			; in MakeUserInterface().
			i += 1
		EndWhile
	EndIf
EndFunction

; Enum constants for MyExampleMod:HorseArmorType:
Int Property HORSE_ARMOR_IRON = 0 autoreadonly
Int Property HORSE_ARMOR_STEEL = 1 autoreadonly
Int Property HORSE_ARMOR_DWARVEN = 2 autoreadonly
Int Property HORSE_ARMOR_EBONY = 3 autoreadonly

String[] EnumLabels
String[] MaskLabels

; Now, it's time to build our UI.
Function MakeUserInterface(String page)
	; Since we called DeclareLogo(), the default page is handled for us, so we
	; need not check page != ""

	; You can still call all of the usual MCM functions from here.
	AddHeaderOption("My Example Mod")
	AddEmptyOption()
	SetCursorFillMode(TOP_TO_BOTTOM)

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
	MakeDropdown("MyExampleMod:HorseArmorType", "Horse armor type", EnumLabels, "What type of horse armor you want.")
	; You could also use MakeCycler(), which takes the same arguments. It makes
	; a text option that cycles through the choices one at a time when the user
	; selects it.

	MakeKeyMap("MyExampleMod:HorseArmorHotkey", "Horse armor hotkey", "Hotkey to apply or remove horse armor.")
	MakeTextBox("MyExampleMod:HorseName", "Horse's name", "The name of your horse.")
	MakeColor("MyExampleMod:HorseColor", "Horse color", "Color of your horse.")

	; You can easily create save and load buttons for all declared variables.
	MakeSaveButton("../MyExampleMod/profile", "Save settings", "Save", "Save your settings to an external file.", "Your settings have been saved.", "Something went wrong.")
	MakeLoadButton("../MyExampleMod/profile", "Load settings", "Load", "Load your settings from an external file.", "Your settings have been loaded.", "Something went wrong.")
	; And a reset button, too.
	MakeResetButton("Reset all to default", "Reset", "Resets all settings to their default values.", "Are you sure you want to reset everything?")

	; Go to the other column...
	SetCursorPosition(3)

	; Create 32 checkboxes, one for each bit in SlotMask. Toggling a checkbox
	; will toggle the corresponding bit. This could be useful for armor slot
	; masks, or any situation where you want to pack a lot of boolean values
	; into a small amount of space.
	MakeMask("MyExampleMod:SlotMask", MaskLabels, "Slot mask for your horse's armor.")
	; This version starts with the least significant bit (little-endian bit
	; order). If you want to start with the most significant bit (big-endian bit
	; order), pass true as the optional fourth argument. You may also need to
	; reverse the order of your labels if you do so.
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
