Scriptname DeclarativeMCMHelper extends SKI_ConfigBase

; Functions which you should override:

; If true, DeclareVariables() is called on every game load. If false, it is
; only called in OnConfigInit() and OnVersionUpdate(). It is also used to decide
; whether to show error messages for programming mistakes, or silently ignore
; them. Set this to false before publishing your mod.
Bool Function LocalDevelopment()
	return True
EndFunction

; Call DeclareFoo() once for each variable you want to control with
; DeclarativeMCMHelper. If you don't declare a variable, it will be
; automatically declared when you create a UI element for it, but you won't be
; able to specify a default value, and the variable won't get initialized until
; the user opens your MCM for the first time.
; Also call DeclarePage() once for each page you want. If you do not declare any
; pages, then it's assumed you set the pages up in the Creation Kit.
Function DeclareVariables()
	DeclarativeMCM_WarnNoDeclaration()
EndFunction

; Call MakeFoo() once for each user interface element you want to display. You
; can also call MCM functions such as AddEmptyOption, SetCursorPosition, etc. to
; style the page appropriately.
Function MakeUserInterface(String page)
	DeclarativeMCM_WarnNoMakeUI()
EndFunction

; Called when a key remapping conflicts with an existing key mapping.
; Return true if the key should be remapped anyway. Override if your users don't
; speak English.
Bool Function HandleKeyConflict(String variable, String conflictControl, String conflictMod)
	return ShowMessage("This key is already in use by " + conflictControl + " from " + conflictMod + ". Use it anyway?")
EndFunction

; Functions to call from DeclareVariables():

; Note: Multiple calls to these functions with the same variable names are
; ignored. It's always safe to re-declare a variable that already exists.
; However, if the types don't match, you will get an error.

; Declare a new boolean value.
; It can later be accessed with StorageUtil.GetIntValue(None, variable).
; It is strongly recommended to prefix variable with the name of your mod.
Function DeclareBool(String variable, Bool default = false)
	If !DeclarativeMCM_ValidateDeclaration(variable, TYPECODE_BOOL)
		return
	EndIf
	Int index = DeclarativeMCM_MakeVariable(variable, TYPECODE_BOOL)
	DeclarativeMCM_PushExtraInt(index, default as Int)
	If !StorageUtil.HasIntValue(None, variable)
		StorageUtil.SetIntValue(None, variable, default as Int)
	EndIf
EndFunction

; Declare a new integer.
; It can later be accessed with StorageUtil.GetIntValue(None, variable).
; It is strongly recommended to prefix variable with the name of your mod.
Function DeclareInt(String variable, Int default = 0)
	If !DeclarativeMCM_ValidateDeclaration(variable, TYPECODE_INT)
		return
	EndIf
	Int index = DeclarativeMCM_MakeVariable(variable, TYPECODE_INT)
	DeclarativeMCM_PushExtraInt(index, default)
	If !StorageUtil.HasIntValue(None, variable)
		StorageUtil.SetIntValue(None, variable, default)
	EndIf
EndFunction

; Declare a new floating-point value.
; It can later be accessed with StorageUtil.GetFloatValue(None, variable).
; It is strongly recommended to prefix variable with the name of your mod.
Function DeclareFloat(String variable, Float default = 0.0)
	If !DeclarativeMCM_ValidateDeclaration(variable, TYPECODE_FLOAT)
		return
	EndIf
	Int index = DeclarativeMCM_MakeVariable(variable, TYPECODE_FLOAT)
	DeclarativeMCM_PushExtraFloat(index, default)
	If !StorageUtil.HasFloatValue(None, variable)
		StorageUtil.SetFloatValue(None, variable, default)
	EndIf
EndFunction

; Declare a new string.
; It can later be accessed with StorageUtil.GetStringValue(None, variable).
; It is strongly recommended to prefix variable with the name of your mod.
Function DeclareString(String variable, String default = "")
	If !DeclarativeMCM_ValidateDeclaration(variable, TYPECODE_STRING)
		return
	EndIf
	Int index = DeclarativeMCM_MakeVariable(variable, TYPECODE_STRING)
	DeclarativeMCM_PushExtraString(index, default)
	If !StorageUtil.HasStringValue(None, variable)
		StorageUtil.SetStringValue(None, variable, default)
	EndIf
EndFunction

; Declare a new enumerated value.
; It's an integer which can take on a value from zero (inclusive) to size
; (exclusive). Used for drop-down options and that sort of thing.
; It can later be accessed with StorageUtil.GetIntValue(None, variable).
; It is strongly recommended to prefix variable with the name of your mod.
Function DeclareEnum(String variable, Int size, Int default = 0)
	If !DeclarativeMCM_ValidateDeclaration(variable, TYPECODE_ENUM)
		return
	EndIf
	If size <= 0
		DeclarativeMCM_WarnBadEnumSize(variable)
		return
	EndIf
	If default >= size || default < 0
		DeclarativeMCM_WarnBadEnumDefault(variable)
		default = 0
	EndIf
	Int index = DeclarativeMCM_MakeVariable(variable, TYPECODE_ENUM)
	DeclarativeMCM_PushExtraInt(index, size)
	DeclarativeMCM_PushExtraInt(index, default)
	If !StorageUtil.HasIntValue(None, variable)
		StorageUtil.SetIntValue(None, variable, default)
	EndIf
EndFunction

; Declare a new key code.
; It's an integer which represents a key on the keyboard. Used for hotkeys.
; nameForConflicts is the name that is displayed when another mod tries to map
; the same key. If registerForKey is true, we call RegisterForKey() every time
; this variable's value changes, and UnregisterForKey() on the previous value.
; The value can later be accessed with StorageUtil.GetIntValue(None, variable).
; It is strongly recommended to prefix variable with the name of your mod.
Function DeclareKeyCode(String variable, String nameForConflicts, Bool registerForKey, Int default = 0)
	If !DeclarativeMCM_ValidateDeclaration(variable, TYPECODE_KEY)
		return
	EndIf
	Int index = DeclarativeMCM_MakeVariable(variable, TYPECODE_KEY)
	DeclarativeMCM_PushExtraInt(index, registerForKey as Int)
	DeclarativeMCM_PushExtraInt(index, default)
	DeclarativeMCM_PushExtraString(index, nameForConflicts)
	If !StorageUtil.HasIntValue(None, variable)
		If default && registerForKey
			RegisterForKey(default)
		EndIf
		StorageUtil.SetIntValue(None, variable, default)
	EndIf
EndFunction

; Declare a new page. Pages will appear in the order they were declared.
; If you do not call this function, then the Pages variable will be left alone.
; Do this if you prefer to configure pages from the Creation Kit.
Function DeclarePage(String name)
	If StorageUtil.StringListFind(self, DeclarativeMCM_PageList, name) != -1
		return
	EndIf
	StorageUtil.StringListAdd(self, DeclarativeMCM_PageList, name)
EndFunction

; Declare a logo to display when the user first opens the MCM.
Function DeclareLogo(String path, Float x = 0.0, Float y = 0.0)
	StorageUtil.SetStringValue(self, DeclarativeMCM_LogoPath, path)
	StorageUtil.SetFloatValue(self, DeclarativeMCM_LogoX, x)
	StorageUtil.SetFloatValue(self, DeclarativeMCM_LogoY, y)
EndFunction

; Declare that variable (which must already be declared) should be copied into
; the GlobalVariable dest when the config page is closed.
Function SyncToGlobal(String variable, GlobalVariable dest)
	Int index = DeclarativeMCM_ValidateSyncToGlobal(variable)
	If index == -1
		return
	EndIf
	Int i = 0
	Int len = StorageUtil.IntListCount(self, DeclarativeMCM_GlobalSyncList)
	While i < len
		If StorageUtil.IntListGet(self, DeclarativeMCM_GlobalSyncList, i) == index && StorageUtil.FormListGet(self, DeclarativeMCM_GlobalSyncList, i) == dest
			return
		EndIf
		i += 1
	EndWhile
	StorageUtil.IntListAdd(self, DeclarativeMCM_GlobalSyncList, index)
	StorageUtil.FormListAdd(self, DeclarativeMCM_GlobalSyncList, dest)
EndFunction

; Functions to call from MakeUserInterface():

; Makes a checkbox for a boolean variable. label is shown inline, and
; extraInfo is shown on hover.
Function MakeCheckbox(String variable, String label, String extraInfo, Int flags = 0)
	DeclareBool(variable)
	Int index = DeclarativeMCM_ValidateUI(variable, TYPECODE_BOOL)
	If index == -1
		return
	EndIf
	Int oid = AddToggleOption(label, StorageUtil.GetIntValue(None, variable), flags)
	DeclarativeMCM_MakeOID(index, oid, OID_TYPE_CHECKBOX, extraInfo, flags)
EndFunction

; Makes a slider for an integer variable. label is shown inline, and
; extraInfo is shown on hover.
Function MakeIntSlider(String variable, String label, Int min, Int max, Int step, String extraInfo, String formatString = "{0}", Int flags = 0)
	DeclareInt(variable)
	Int index = DeclarativeMCM_ValidateUI(variable, TYPECODE_INT)
	If index == -1
		return
	EndIf
	Int oid = AddSliderOption(label, StorageUtil.GetIntValue(None, variable), formatString, flags)
	Int oidIndex = DeclarativeMCM_MakeOID(index, oid, OID_TYPE_INT_SLIDER, extraInfo, flags)
	DeclarativeMCM_PushExtraInt(oidIndex, min, true)
	DeclarativeMCM_PushExtraInt(oidIndex, max, true)
	DeclarativeMCM_PushExtraInt(oidIndex, step, true)
	DeclarativeMCM_PushExtraString(oidIndex, formatString, true)
EndFunction

; Makes a slider for a float variable. label is shown inline, and
; extraInfo is shown on hover.
Function MakeFloatSlider(String variable, String label, Float min, Float max, Float step, String extraInfo, String formatString = "{0}", Int flags = 0)
	DeclareFloat(variable)
	Int index = DeclarativeMCM_ValidateUI(variable, TYPECODE_FLOAT)
	If index == -1
		return
	EndIf
	Int oid = AddSliderOption(label, StorageUtil.GetFloatValue(None, variable), formatString, flags)
	Int oidIndex = DeclarativeMCM_MakeOID(index, oid, OID_TYPE_FLOAT_SLIDER, extraInfo, flags)
	DeclarativeMCM_PushExtraFloat(oidIndex, min, true)
	DeclarativeMCM_PushExtraFloat(oidIndex, max, true)
	DeclarativeMCM_PushExtraFloat(oidIndex, step, true)
	DeclarativeMCM_PushExtraString(oidIndex, formatString, true)
EndFunction

; Makes a text box for a string variable. label is shown inline, and
; extraInfo is shown on hover.
Function MakeTextBox(String variable, String label, String extraInfo, Int flags = 0)
	DeclareString(variable)
	Int index = DeclarativeMCM_ValidateUI(variable, TYPECODE_STRING)
	If index == -1
		return
	EndIf
	Int oid = AddInputOption(label, StorageUtil.GetStringValue(None, variable), flags)
	DeclarativeMCM_MakeOID(index, oid, OID_TYPE_TEXTBOX, extraInfo, flags)
EndFunction

; Make a drop-down selector for an enum variable. label is shown inline,
; each element of choices is used for the corresponding value of variable, and
; extraInfo is shown on hover.
Function MakeDropdown(String variable, String label, String[] choices, String extraInfo, Int flags = 0)
	DeclareEnum(variable, choices.length)
	Int index = DeclarativeMCM_ValidateUI(variable, TYPECODE_ENUM)
	If index == -1
		return
	EndIf
	Int size = DeclarativeMCM_GetExtraInt(index, 0)
	If choices.length != size
		DeclarativeMCM_WarnEnumMismatchedSize(variable)
		return
	EndIf
	Int value = StorageUtil.GetIntValue(None, variable)
	Int oid = AddMenuOption(label, choices[value], flags)
	Int oidIndex = DeclarativeMCM_MakeOID(index, oid, OID_TYPE_DROPDOWN, extraInfo, flags)
	Int i = 0
	While i < size
		DeclarativeMCM_PushExtraString(oidIndex, choices[i], true)
		i += 1
	EndWhile
EndFunction

; Make a text option that cycles through choices for an enum variable.
; Each time the user selects the option, it changes to the next choice. label is
; shown inline and extraInfo is shown on hover.
Function MakeCycler(String variable, String label, String[] choices, String extraInfo, Int flags = 0)
	DeclareEnum(variable, choices.length)
	Int index = DeclarativeMCM_ValidateUI(variable, TYPECODE_ENUM)
	If index == -1
		return
	EndIf
	Int size = DeclarativeMCM_GetExtraInt(index, 0)
	If choices.length != size
		DeclarativeMCM_WarnEnumMismatchedSize(variable)
		return
	EndIf
	Int value = StorageUtil.GetIntValue(None, variable)
	Int oid = AddTextOption(label, choices[value], flags)
	Int oidIndex = DeclarativeMCM_MakeOID(index, oid, OID_TYPE_CYCLER, extraInfo, flags)
	Int i = 0
	While i < size
		DeclarativeMCM_PushExtraString(oidIndex, choices[i], true)
		i += 1
	EndWhile
EndFunction

; Make a color option for an integer variable. label is shown inline, and
; extraInfo is shown on hover. Colors are stored as 0xRRGGBB.
Function MakeColor(String variable, String label, String extraInfo, Int flags = 0)
	DeclareInt(variable)
	Int index = DeclarativeMCM_ValidateUI(variable, TYPECODE_INT)
	If index == -1
		return
	EndIf
	Int value = StorageUtil.GetIntValue(None, variable)
	Int oid = AddColorOption(label, value, flags)
	DeclarativeMCM_MakeOID(index, oid, OID_TYPE_COLOR, extraInfo, flags)
EndFunction

; Make a key re-mapping control for an integer variable. The value will be
; a DXScanCode. label is shown inline and extraInfo is shown on hover.
; If the user selects a key which is already in use, ShowConflictWarning() is
; called. If the variable was not previously declared, this will also call
; RegisterForKey() when the user picks a new value.
Function MakeKeyMap(String variable, String label, String extraInfo, Int flags = 0)
	DeclareKeyCode(variable, label, True)
	Int index = DeclarativeMCM_ValidateUI(variable, TYPECODE_KEY)
	If index == -1
		return
	EndIf
	Int value = StorageUtil.GetIntValue(None, variable)
	Int oid = AddKeyMapOption(label, value, flags)
	DeclarativeMCM_MakeOID(index, oid, OID_TYPE_KEYMAP, extraInfo, flags)
EndFunction

; MCM overrides:
; WARNING: If you are going to override any of these functions, you should call
; Parent.Function() (e.g. Parent.OnConfigInit(), Parent.OnVersionUpdate(), etc.)
; or else bad things may happen.

Event OnConfigInit()
	DeclarativeMCM_ClearVariables()
	DeclareVariables()
	If StorageUtil.StringListCount(self, DeclarativeMCM_PageList)
		Pages = StorageUtil.StringListToArray(self, DeclarativeMCM_PageList)
	EndIf
EndEvent

Event OnVersionUpdate(Int version)
	DeclarativeMCM_ClearVariables()
	DeclareVariables()
	If StorageUtil.StringListCount(self, DeclarativeMCM_PageList)
		Pages = StorageUtil.StringListToArray(self, DeclarativeMCM_PageList)
	EndIf
EndEvent

String Function GetCustomControl(Int value)
	If !value
		return ""
	EndIf
	Int i = 0
	Int len = StorageUtil.IntListCount(self, DeclarativeMCM_TypeList)
	While i < len
		Int typecode = StorageUtil.IntListGet(self, DeclarativeMCM_TypeList, i)
		If typecode == TYPECODE_KEY
			String variable = StorageUtil.StringListGet(self, DeclarativeMCM_VariableList, i)
			If value == StorageUtil.GetIntValue(None, variable)
				return DeclarativeMCM_GetExtraString(i, 2)
			EndIf
		EndIf
		i += 1
	EndWhile
	return ""
EndFunction

Event OnGameReload()
	Parent.OnGameReload()
	If LocalDevelopment()
		DeclarativeMCM_ClearVariables()
		DeclareVariables()
		If StorageUtil.StringListCount(self, DeclarativeMCM_PageList)
			Pages = StorageUtil.StringListToArray(self, DeclarativeMCM_PageList)
		EndIf
	EndIf
EndEvent

Event OnPageReset(String page)
	String logoPath = StorageUtil.GetStringValue(self, DeclarativeMCM_LogoPath)
	If logoPath
		If page
			UnloadCustomContent()
		Else
			LoadCustomContent(logoPath, StorageUtil.GetFloatValue(self, DeclarativeMCM_LogoX), StorageUtil.GetFloatValue(self, DeclarativeMCM_LogoY))
			return
		EndIf
	EndIf
	DeclarativeMCM_ClearOIDs()
	MakeUserInterface(page)
EndEvent

Event OnConfigClose()
	DeclarativeMCM_ClearOIDs()
	Int i = 0
	Int len = StorageUtil.IntListCount(self, DeclarativeMCM_GlobalSyncList)
	While i < len
		Int index = StorageUtil.IntListGet(self, DeclarativeMCM_GlobalSyncList, i)
		GlobalVariable dest = StorageUtil.FormListGet(self, DeclarativeMCM_GlobalSyncList, i) as GlobalVariable
		String variable = StorageUtil.StringListGet(self, DeclarativeMCM_VariableList, index)
		Int typecode = StorageUtil.IntListGet(self, DeclarativeMCM_TypeList, index)
		If dest
			If typecode == TYPECODE_FLOAT
				Float value = StorageUtil.GetFloatValue(None, variable)
				dest.SetValue(value)
			Else
				Int value = StorageUtil.GetIntValue(None, variable)
				dest.SetValue(value as Float)
			EndIf
		EndIf
		i += 1
	EndWhile
EndEvent

Event OnOptionSelect(Int oid)
	Int oidIndex = StorageUtil.IntListFind(self, DeclarativeMCM_OIDList, oid)
	If oidIndex == -1
		return
	EndIf
	Int oidType = StorageUtil.IntListGet(self, DeclarativeMCM_OIDTypes, oidIndex)
	Int index = StorageUtil.IntListGet(self, DeclarativeMCM_OIDIndices, oidIndex)
	String variable = StorageUtil.StringListGet(self, DeclarativeMCM_VariableList, index)
	If oidType == OID_TYPE_CHECKBOX
		Bool value = StorageUtil.GetIntValue(None, variable)
		value = !value
		StorageUtil.SetIntValue(None, variable, value as Int)
		SetToggleOptionValue(oid, value)
	ElseIf oidType == OID_TYPE_CYCLER
		Int value = StorageUtil.GetIntValue(None, variable)
		Int size = DeclarativeMCM_GetExtraInt(index, 0)
		value += 1
		value %= size
		StorageUtil.SetIntValue(None, variable, value)
		SetTextOptionValue(oid, DeclarativeMCM_GetExtraString(oidIndex, value, true))
	EndIf
EndEvent

Event OnOptionSliderOpen(Int oid)
	Int oidIndex = StorageUtil.IntListFind(self, DeclarativeMCM_OIDList, oid)
	If oidIndex == -1
		return
	EndIf
	Int oidType = StorageUtil.IntListGet(self, DeclarativeMCM_OIDTypes, oidIndex)
	Int index = StorageUtil.IntListGet(self, DeclarativeMCM_OIDIndices, oidIndex)
	String variable = StorageUtil.StringListGet(self, DeclarativeMCM_VariableList, index)
	If oidType == OID_TYPE_INT_SLIDER
		Int default = DeclarativeMCM_GetExtraInt(index, 0)
		Int min = DeclarativeMCM_GetExtraInt(oidIndex, 0, true)
		Int max = DeclarativeMCM_GetExtraInt(oidIndex, 1, true)
		Int step = DeclarativeMCM_GetExtraInt(oidIndex, 2, true)
		Int current = StorageUtil.GetIntValue(None, variable)
		SetSliderDialogStartValue(current)
		SetSliderDialogDefaultValue(default)
		SetSliderDialogRange(min, max)
		SetSliderDialogInterval(step)
	ElseIf oidType == OID_TYPE_FLOAT_SLIDER
		Float fdefault = DeclarativeMCM_GetExtraFloat(index, 0)
		Float fmin = DeclarativeMCM_GetExtraFloat(oidIndex, 0, true)
		Float fmax = DeclarativeMCM_GetExtraFloat(oidIndex, 1, true)
		Float fstep = DeclarativeMCM_GetExtraFloat(oidIndex, 2, true)
		Float fcurrent = StorageUtil.GetFloatValue(None, variable)
		SetSliderDialogStartValue(fcurrent)
		SetSliderDialogDefaultValue(fdefault)
		SetSliderDialogRange(fmin, fmax)
		SetSliderDialogInterval(fstep)
	EndIf
EndEvent

Event OnOptionSliderAccept(Int oid, Float value)
	Int oidIndex = StorageUtil.IntListFind(self, DeclarativeMCM_OIDList, oid)
	If oidIndex == -1
		return
	EndIf
	Int oidType = StorageUtil.IntListGet(self, DeclarativeMCM_OIDTypes, oidIndex)
	Int index = StorageUtil.IntListGet(self, DeclarativeMCM_OIDIndices, oidIndex)
	String variable = StorageUtil.StringListGet(self, DeclarativeMCM_VariableList, index)
	If oidType == OID_TYPE_INT_SLIDER
		StorageUtil.SetIntValue(None, variable, value as Int)
	ElseIf oidType == OID_TYPE_FLOAT_SLIDER
		StorageUtil.SetFloatValue(None, variable, value)
	EndIf
	String formatString = DeclarativeMCM_GetExtraString(oidIndex, 3, true)
	SetSliderOptionValue(oid, value, formatString)
EndEvent

Event OnOptionInputOpen(Int oid)
	Int oidIndex = StorageUtil.IntListFind(self, DeclarativeMCM_OIDList, oid)
	If oidIndex == -1
		return
	EndIf
	Int index = StorageUtil.IntListGet(self, DeclarativeMCM_OIDIndices, oidIndex)
	String variable = StorageUtil.StringListGet(self, DeclarativeMCM_VariableList, index)
	SetInputDialogStartText(StorageUtil.GetStringValue(None, variable))
EndEvent

Event OnOptionInputAccept(Int oid, String value)
	Int oidIndex = StorageUtil.IntListFind(self, DeclarativeMCM_OIDList, oid)
	If oidIndex == -1
		return
	EndIf
	Int index = StorageUtil.IntListGet(self, DeclarativeMCM_OIDIndices, oidIndex)
	String variable = StorageUtil.StringListGet(self, DeclarativeMCM_VariableList, index)
	StorageUtil.SetStringValue(None, variable, value)
	SetInputOptionValue(oid, value)
EndEvent

Event OnMenuOptionOpen(Int oid)
	Int oidIndex = StorageUtil.IntListFind(self, DeclarativeMCM_OIDList, oid)
	If oidIndex == -1
		return
	EndIf
	Int index = StorageUtil.IntListGet(self, DeclarativeMCM_OIDIndices, oidIndex)
	String variable = StorageUtil.StringListGet(self, DeclarativeMCM_VariableList, index)
	Int value = StorageUtil.GetIntValue(None, variable)
	Int size = DeclarativeMCM_GetExtraInt(index, 0)
	Int default = DeclarativeMCM_GetExtraInt(index, 1)
	SetMenuDialogStartIndex(value)
	SetMenuDialogDefaultIndex(default)
	StorageUtil.StringListClear(self, DeclarativeMCM_Scratch)
	Int i = 0
	While i < size
		String choice = DeclarativeMCM_GetExtraString(oidIndex, i, true)
		StorageUtil.StringListAdd(self, DeclarativeMCM_Scratch, choice)
		i += 1
	EndWhile
	SetMenuDialogOptions(StorageUtil.StringListToArray(self, DeclarativeMCM_Scratch))
	StorageUtil.StringListClear(self, DeclarativeMCM_Scratch)
EndEvent

Event OnMenuOptionAccept(Int oid, Int value)
	Int oidIndex = StorageUtil.IntListFind(self, DeclarativeMCM_OIDList, oid)
	If oidIndex == -1
		return
	EndIf
	Int index = StorageUtil.IntListGet(self, DeclarativeMCM_OIDIndices, oidIndex)
	String variable = StorageUtil.StringListGet(self, DeclarativeMCM_VariableList, index)
	StorageUtil.SetIntValue(None, variable, value)
	SetMenuOptionValue(oid, value)
EndEvent

Event OnOptionColorOpen(Int oid)
	Int oidIndex = StorageUtil.IntListFind(self, DeclarativeMCM_OIDList, oid)
	If oidIndex == -1
		return
	EndIf
	Int index = StorageUtil.IntListGet(self, DeclarativeMCM_OIDIndices, oidIndex)
	String variable = StorageUtil.StringListGet(self, DeclarativeMCM_VariableList, index)
	Int value = StorageUtil.GetIntValue(None, variable)
	SetColorDialogStartColor(value)
	Int default = DeclarativeMCM_GetExtraInt(index, 0)
	SetColorDialogDefaultColor(default)
EndEvent

Event OnOptionColorAccept(Int oid, Int value)
	Int oidIndex = StorageUtil.IntListFind(self, DeclarativeMCM_OIDList, oid)
	If oidIndex == -1
		return
	EndIf
	Int index = StorageUtil.IntListGet(self, DeclarativeMCM_OIDIndices, oidIndex)
	String variable = StorageUtil.StringListGet(self, DeclarativeMCM_VariableList, index)
	StorageUtil.SetIntValue(None, variable, value)
	SetColorOptionValue(oid, value)
EndEvent

Event OnOptionKeyMapChange(Int oid, Int value, String conflictControl, String conflictMod)
	Int oidIndex = StorageUtil.IntListFind(self, DeclarativeMCM_OIDList, oid)
	If oidIndex == -1
		return
	EndIf
	Int index = StorageUtil.IntListGet(self, DeclarativeMCM_OIDIndices, oidIndex)
	String variable = StorageUtil.StringListGet(self, DeclarativeMCM_VariableList, index)
	If (conflictControl || conflictMod) && !HandleKeyConflict(variable, conflictControl, conflictMod)
		return
	EndIf
	Bool registerForKey = DeclarativeMCM_GetExtraInt(index, 0)
	If registerForKey
		Int oldValue = StorageUtil.GetIntValue(None, variable)
		If oldValue
			UnregisterForKey(oldValue)
		EndIf
		If value
			RegisterForKey(value)
		EndIf
	EndIf
	StorageUtil.SetIntValue(None, variable, value)
	SetKeyMapOptionValue(oid, value)
EndEvent

Event OnOptionHighlight(Int oid)
	Int oidIndex = StorageUtil.IntListFind(self, DeclarativeMCM_OIDList, oid)
	If oidIndex == -1
		SetInfoText("")
		return
	EndIf
	String info = StorageUtil.StringListGet(self, DeclarativeMCM_OIDInfos, oidIndex)
	SetInfoText(info)
EndEvent

Event OnOptionDefault(Int oid)
	Int oidIndex = StorageUtil.IntListFind(self, DeclarativeMCM_OIDList, oid)
	If oidIndex == -1
		return
	EndIf
	Int index = StorageUtil.IntListGet(self, DeclarativeMCM_OIDIndices, oidIndex)
	String variable = StorageUtil.StringListGet(self, DeclarativeMCM_VariableList, index)
	Int oidType = StorageUtil.IntListGet(self, DeclarativeMCM_OIDTypes, oidIndex)
	If oidType == OID_TYPE_CHECKBOX
		Bool default = DeclarativeMCM_GetExtraInt(index, 0)
		StorageUtil.SetIntValue(None, variable, default as Int)
		SetToggleOptionValue(oid, default)
	ElseIf oidType == OID_TYPE_INT_SLIDER 
		String formatString = DeclarativeMCM_GetExtraString(oidIndex, 3, true)
		Int default = DeclarativeMCM_GetExtraInt(index, 0)
		StorageUtil.SetIntValue(None, variable, default)
		SetSliderOptionValue(oid, default, formatString)
	ElseIf oidType == OID_TYPE_FLOAT_SLIDER
		String formatString = DeclarativeMCM_GetExtraString(oidIndex, 3, true)
		Float default = DeclarativeMCM_GetExtraFloat(index, 0)
		StorageUtil.SetFloatValue(None, variable, default)
		SetSliderOptionValue(oid, default, formatString)
	ElseIf oidType == OID_TYPE_TEXTBOX
		String default = DeclarativeMCM_GetExtraString(index, 0)
		StorageUtil.SetStringValue(None, variable, default)
		SetInputOptionValue(oid, default)
	ElseIf oidType == OID_TYPE_DROPDOWN || oidType == OID_TYPE_CYCLER
		Int default = DeclarativeMCM_GetExtraInt(index, 1)
		StorageUtil.SetIntValue(None, variable, default)
		String displayValue = DeclarativeMCM_GetExtraString(oidIndex, default, true)
		If oidType == OID_TYPE_DROPDOWN
			SetMenuOptionValue(oid, displayValue)
		Else
			SetTextOptionValue(oid, displayValue)
		EndIf
	ElseIf oidType == OID_TYPE_COLOR
		Int default = DeclarativeMCM_GetExtraInt(index, 0)
		StorageUtil.SetIntValue(None, variable, default)
		SetColorOptionValue(oid, default)
	ElseIf oidType == OID_TYPE_KEYMAP
		Bool registerForKey = DeclarativeMCM_GetExtraInt(index, 0)
		Int default = DeclarativeMCM_GetExtraInt(index, 1)
		If registerForKey
			Int oldValue = StorageUtil.GetIntValue(None, variable)
			If oldValue
				UnregisterForKey(oldValue)
			EndIf
			If default
				RegisterForKey(default)
			EndIf
		EndIf
		StorageUtil.SetIntValue(None, variable, default)
		SetKeyMapOptionValue(oid, default)
	EndIf
EndEvent

; Private members, do not use directly:

Int Property TYPECODE_BOOL = 1 autoreadonly
Int Property TYPECODE_INT = 2 autoreadonly
Int Property TYPECODE_FLOAT = 3 autoreadonly
Int Property TYPECODE_STRING = 4 autoreadonly
Int Property TYPECODE_ENUM = 5 autoreadonly
Int Property TYPECODE_KEY = 6 autoreadonly

Int Property OID_TYPE_CHECKBOX = 1 autoreadonly
Int Property OID_TYPE_INT_SLIDER = 2 autoreadonly
Int Property OID_TYPE_FLOAT_SLIDER = 3 autoreadonly
Int Property OID_TYPE_TEXTBOX = 4 autoreadonly
Int Property OID_TYPE_DROPDOWN = 5 autoreadonly
Int Property OID_TYPE_CYCLER = 6 autoreadonly
Int Property OID_TYPE_COLOR = 7 autoreadonly
Int Property OID_TYPE_KEYMAP = 8 autoreadonly

; Lists populated by DeclareFoo(). Cleared by OnVersionUpdate(), and
; OnGameReload() if LocalDevelopment() is true.
String Property DeclarativeMCM_VariableList = "DeclarativeMCM:VariableList" autoreadonly
String Property DeclarativeMCM_TypeList = "DeclarativeMCM:TypeList" autoreadonly
String Property DeclarativeMCM_OffsetList = "DeclarativeMCM:OffsetList" autoreadonly
String Property DeclarativeMCM_ExtraList = "DeclarativeMCM:ExtraList" autoreadonly

String Property DeclarativeMCM_PageList = "DeclarativeMCM:PageList" autoreadonly
String Property DeclarativeMCM_LogoPath = "DeclarativeMCM:LogoPath" autoreadonly
String Property DeclarativeMCM_LogoX = "DeclarativeMCM:LogoX" autoreadonly
String Property DeclarativeMCM_LogoY = "DeclarativeMCM:LogoY" autoreadonly

String Property DeclarativeMCM_GlobalSyncList = "DeclarativeMCM:GlobalSyncList" autoreadonly

; Lists populated by MakeFoo(). Cleared by OnPageReset() and OnConfigClose().
String Property DeclarativeMCM_OIDList = "DeclarativeMCM:OIDList" autoreadonly
String Property DeclarativeMCM_OIDIndices = "DeclarativeMCM:OIDIndices" autoreadonly
String Property DeclarativeMCM_OIDTypes = "DeclarativeMCM:OIDTypes" autoreadonly
String Property DeclarativeMCM_OIDOffsets = "DeclarativeMCM:OIDOffsets" autoreadonly
String Property DeclarativeMCM_OIDInfos = "DeclarativeMCM:OIDInfos" autoreadonly
String Property DeclarativeMCM_OIDFlags = "DeclarativeMCM:OIDFlags" autoreadonly
String Property DeclarativeMCM_OIDExtras = "DeclarativeMCM:OIDExtras" autoreadonly

; Temporary variables for building arrays.
String Property DeclarativeMCM_Scratch = "DeclarativeMCM:Scratch" autoreadonly

Int Function DeclarativeMCM_MakeVariable(String variable, Int typecode)
	Int result = StorageUtil.StringListAdd(self, DeclarativeMCM_VariableList, variable)
	StorageUtil.IntListAdd(self, DeclarativeMCM_TypeList, typecode)
	StorageUtil.IntListAdd(self, DeclarativeMCM_OffsetList, -1)
	return result
EndFunction

Int Function DeclarativeMCM_MakeOID(Int index, Int oid, Int typecode, String info, Int flags)
	Int result
	Int oidIndex = StorageUtil.IntListFind(self, DeclarativeMCM_OIDList, oid)
	If oidIndex != -1
		result = oidIndex
		; OIDList already has the correct value.
		StorageUtil.IntListSet(self, DeclarativeMCM_OIDIndices, oidIndex, index)
		StorageUtil.IntListSet(self, DeclarativeMCM_OIDFlags, oidIndex, flags)
		StorageUtil.StringListSet(self, DeclarativeMCM_OIDInfos, oidIndex, info)
		StorageUtil.IntListSet(self, DeclarativeMCM_OIDTypes, oidIndex, typecode)
		; Leak(!) the existing extra values for correctness.
		; It won't leak all that much memory, and OnPageReset()/OnConfigClose()
		; cleans it up anyway, so no big deal.
		StorageUtil.IntListSet(self, DeclarativeMCM_OIDOffsets, oidIndex, -1)
	Else
		result = StorageUtil.IntListAdd(self, DeclarativeMCM_OIDList, oid)
		StorageUtil.IntListAdd(self, DeclarativeMCM_OIDIndices, index)
		StorageUtil.IntListAdd(self, DeclarativeMCM_OIDFlags, flags)
		StorageUtil.StringListAdd(self, DeclarativeMCM_OIDInfos, info)
		StorageUtil.IntListAdd(self, DeclarativeMCM_OIDTypes, typecode)
		StorageUtil.IntListAdd(self, DeclarativeMCM_OIDOffsets, -1)
	EndIf
	return result
EndFunction

Function DeclarativeMCM_PushExtraInt(Int index, Int extra, Bool oid = false)
	String extraList
	String offsetList
	If oid
		extraList = DeclarativeMCM_OIDExtras
		offsetList = DeclarativeMCM_OIDOffsets
	Else
		extraList = DeclarativeMCM_ExtraList
		offsetList = DeclarativeMCM_OffsetList
	EndIf
	Int offsetIndex = StorageUtil.IntListAdd(self, extraList, extra)
	If StorageUtil.IntListGet(self, offsetList, index) == -1
		StorageUtil.IntListSet(self, offsetList, index, offsetIndex)
	EndIf
EndFunction

Function DeclarativeMCM_PushExtraFloat(Int index, Float extra, Bool oid = false)
	String extraList
	String offsetList
	If oid
		extraList = DeclarativeMCM_OIDExtras
		offsetList = DeclarativeMCM_OIDOffsets
	Else
		extraList = DeclarativeMCM_ExtraList
		offsetList = DeclarativeMCM_OffsetList
	EndIf
	Int offsetIndex = StorageUtil.FloatListAdd(self, extraList, extra)
	DeclarativeMCM_PushExtraInt(index, offsetIndex, oid)
EndFunction

Function DeclarativeMCM_PushExtraString(Int index, String extra, Bool oid = false)
	String extraList
	String offsetList
	If oid
		extraList = DeclarativeMCM_OIDExtras
		offsetList = DeclarativeMCM_OIDOffsets
	Else
		extraList = DeclarativeMCM_ExtraList
		offsetList = DeclarativeMCM_OffsetList
	EndIf
	Int offsetIndex = StorageUtil.StringListAdd(self, extraList, extra)
	DeclarativeMCM_PushExtraInt(index, offsetIndex, oid)
EndFunction

Int Function DeclarativeMCM_GetExtraInt(Int index, int subIndex, Bool oid = false)
	String extraList
	String offsetList
	If oid
		extraList = DeclarativeMCM_OIDExtras
		offsetList = DeclarativeMCM_OIDOffsets
	Else
		extraList = DeclarativeMCM_ExtraList
		offsetList = DeclarativeMCM_OffsetList
	EndIf
	Int offsetIndex = StorageUtil.IntListGet(self, offsetList, index) + subIndex
	return StorageUtil.IntListGet(self, extraList, offsetIndex)
EndFunction

Float Function DeclarativeMCM_GetExtraFloat(Int index, Int subIndex, Bool oid = false)
	String extraList
	If oid
		extraList = DeclarativeMCM_OIDExtras
	Else
		extraList = DeclarativeMCM_ExtraList
	EndIf
	Int offsetIndex = DeclarativeMCM_GetExtraInt(index, subIndex)
	return StorageUtil.FloatListGet(self, extraList, offsetIndex)
EndFunction

String Function DeclarativeMCM_GetExtraString(Int index, Int subIndex, Bool oid = false)
	String extraList
	If oid
		extraList = DeclarativeMCM_OIDExtras
	Else
		extraList = DeclarativeMCM_ExtraList
	EndIf
	Int offsetIndex = DeclarativeMCM_GetExtraInt(index, subIndex)
	return StorageUtil.StringListGet(self, extraList, offsetIndex)
EndFunction

Function DeclarativeMCM_ClearVariables()
	StorageUtil.StringListClear(self, DeclarativeMCM_VariableList)
	StorageUtil.IntListClear(self, DeclarativeMCM_TypeList)
	StorageUtil.IntListClear(self, DeclarativeMCM_ExtraList)
	StorageUtil.FloatListClear(self, DeclarativeMCM_ExtraList)
	StorageUtil.StringListClear(self, DeclarativeMCM_ExtraList)
	StorageUtil.IntListClear(self, DeclarativeMCM_OffsetList)
	StorageUtil.StringListClear(self, DeclarativeMCM_PageList)
	StorageUtil.StringListClear(self, DeclarativeMCM_GlobalSyncList)
	StorageUtil.FormListClear(self, DeclarativeMCM_GlobalSyncList)
	StorageUtil.UnsetStringValue(self, DeclarativeMCM_LogoPath)
	StorageUtil.UnsetFloatValue(self, DeclarativeMCM_LogoX)
	StorageUtil.UnsetFloatValue(self, DeclarativeMCM_LogoY)
EndFunction

Function DeclarativeMCM_ClearOIDs()
	StorageUtil.StringListClear(self, DeclarativeMCM_OIDList)
	StorageUtil.IntListClear(self, DeclarativeMCM_OIDIndices)
	StorageUtil.IntListClear(self, DeclarativeMCM_OIDFlags)
	StorageUtil.StringListClear(self, DeclarativeMCM_OIDInfos)
	StorageUtil.IntListClear(self, DeclarativeMCM_OIDExtras)
	StorageUtil.FloatListClear(self, DeclarativeMCM_OIDExtras)
	StorageUtil.StringListClear(self, DeclarativeMCM_OIDExtras)
	StorageUtil.IntListClear(self, DeclarativeMCM_OIDOffsets)
EndFunction

Int Function DeclarativeMCM_FindVariable(String variable)
	return StorageUtil.StringListFind(self, DeclarativeMCM_VariableList, variable)
EndFunction

Bool Function DeclarativeMCM_ValidateDeclaration(String variable, Int typecode)
	Int index = DeclarativeMCM_FindVariable(variable)
	If index != -1 && StorageUtil.IntListGet(self, DeclarativeMCM_TypeList, index) != typecode
		DeclarativeMCM_WarnBadDeclaration(variable)
		return false
	EndIf
	If index != -1
		return false
	EndIf
	return true
EndFunction

Int Function DeclarativeMCM_ValidateUI(String variable, Int typecode)
	Int index = DeclarativeMCM_FindVariable(variable)
	If StorageUtil.IntListGet(self, DeclarativeMCM_TypeList, index) != typecode
		; Caller already tried to declare it, so fail silently.
		return -1
	EndIf
	return index
EndFunction

Int Function DeclarativeMCM_ValidateSyncToGlobal(String variable)
	Int index = DeclarativeMCM_FindVariable(variable)
	If index != -1 && StorageUtil.IntListGet(self, DeclarativeMCM_TypeList, index) == TYPECODE_STRING
		DeclarativeMCM_WarnCantSync(variable)
		return -1
	EndIf
	If index == -1
		DeclarativeMCM_WarnUndeclaredVariable(variable)
	EndIf
	return index
EndFunction

Function DeclarativeMCM_WarnBadDeclaration(String variable)
	If LocalDevelopment()
		Debug.MessageBox("Warning: Multiple incompatible declarations of variable: " + variable)
	EndIf
EndFunction

Function DeclarativeMCM_WarnBadEnumSize(String variable)
	If LocalDevelopment()
		Debug.MessageBox("Warning: " + variable + " has an invalid size (must be greater than zero).")
	EndIf
EndFunction

Function DeclarativeMCM_WarnEnumMismatchedSize(String variable)
	If LocalDevelopment()
		ShowMessage("Warning: Enum variable " + variable + " has a different size from the number of choices you specified.", false)
	EndIf
EndFunction

Function DeclarativeMCM_WarnBadEnumDefault(String variable)
	If LocalDevelopment()
		Debug.MessageBox("Warning: Default value of " + variable + " is invalid, using zero instead.")
	EndIf
EndFunction

Function DeclarativeMCM_WarnCantSync(String variable)
	If LocalDevelopment()
		Debug.MessageBox("Warning: Can't sync string variable " + variable + " to a global.")
	EndIf
EndFunction

Function DeclarativeMCM_WarnUndeclaredVariable(String variable)
	If LocalDevelopment()
		Debug.MessageBox("Warning: Can't sync undeclared variable: " + variable)
	EndIf
EndFunction

Function DeclarativeMCM_WarnNoDeclaration()
	If LocalDevelopment()
		Debug.MessageBox("Warning: You did not override DeclareVariables(). If you do not wish to declare any variables, override DeclareVariables() with an empty function.")
	EndIf
EndFunction

Function DeclarativeMCM_WarnNoMakeUI()
	If LocalDevelopment()
		ShowMessage("Warning: You did not override MakeUserInterface(). If you really want an empty UI, override MakeUserInterface() with an empty function.", false)
	EndIf
EndFunction
