Scriptname DeclarativeMCMHelper extends SKI_ConfigBase Hidden

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

; Called every time a variable is changed through the UI. Return true if the
; current state is valid, and return false to reject the change. If rejecting,
; you should also display an error message with ShowMessage().
; Validation is skipped when variables are first initialized.
; You can also do other things in Validate(), such as setting option flags or
; changing other values.
Bool Function Validate(String variable)
	return True
EndFunction

; Called after the player activates a load or reset button, and all variables
; have been loaded or reset. You can't reject these operations, but you can do
; other things in response to them.
Function ValidateAll()
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
	DeclarativeMCM_PushExtraInt(index, default)
	DeclarativeMCM_PushExtraInt(index, size)
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
	DeclarativeMCM_PushExtraInt(index, default)
	DeclarativeMCM_PushExtraInt(index, registerForKey as Int)
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
; the GlobalVariable dest when the config page is closed. Also initializes dest
; with the current value of variable. Syncing is strictly one-way; changes to
; dest will not be reflected in StorageUtil.
Function SyncToGlobal(String variable, GlobalVariable dest)
	Int index = DeclarativeMCM_ValidateSyncToGlobal(variable, dest)
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
	StorageUtil.IntListSet(self, DeclarativeMCM_IsSynced, index, 1)
	Int typecode = StorageUtil.IntListGet(self, DeclarativeMCM_TypeList, index)
	If typecode == TYPECODE_FLOAT
		dest.SetValue(StorageUtil.GetFloatValue(None, variable))
	Else
		dest.SetValue(StorageUtil.GetIntValue(None, variable) as Float)
	EndIf
EndFunction

; Declare that the variable left depends on the variable right in some way.
; Pass one of the integers listed below as verb.
;
; Indicates that the controls for left should be disabled whenever right is
; falsey. This will not prevent left from being truthy when right is falsey, it
; just disables the UI element(s). For input validaiton, override Validate().
Int Property REQUIRES = 0 autoreadonly
; Indicates that the controls for left should be disabled whenever right is
; truthy. This will not prevent left from being truthy when right is truthy.
Int Property CONFLICTS_WITH = 1 autoreadonly
Function DeclareDependency(String left, Int verb, String right)
	Int leftIndex = DeclarativeMCM_ValidateVariableExists(left)
	If leftIndex == -1
		return
	EndIf
	Int rightIndex = DeclarativeMCM_ValidateVariableExists(right)
	If rightIndex == -1
		return
	EndIf
	If !DeclarativeMCM_ValidateDependency(leftIndex, verb, rightIndex)
		return
	EndIf
	StorageUtil.IntListAdd(self, DeclarativeMCM_DependencyLHS, leftIndex)
	StorageUtil.IntListAdd(self, DeclarativeMCM_DependencyRHS, rightIndex)
	StorageUtil.IntListAdd(self, DeclarativeMCM_DependencyType, verb)
	StorageUtil.IntListSet(self, DeclarativeMCM_IsDependent, leftIndex, 1)
	StorageUtil.IntListSet(self, DeclarativeMCM_HasDependent, rightIndex, 1)
EndFunction


; Functions to call from MakeUserInterface():
; All of these functions return an option ID, but you don't need to bother with
; it unless you want to fiddle with the option's flags later. If -1 is returned,
; it means something went wrong.

; As a general rule: Do not create multiple controls for the same variable on
; the same page, except for radio buttons and mask bits. Even then, each radio
; button or mask bit should control a different choice or bit.

; Makes a checkbox for a boolean variable. label is shown inline, and
; extraInfo is shown on hover.
Int Function MakeCheckbox(String variable, String label, String extraInfo, Int flags = 0)
	DeclareBool(variable)
	Int index = DeclarativeMCM_ValidateUI(variable, TYPECODE_BOOL)
	If index == -1
		return -1
	EndIf
	flags = DeclarativeMCM_AdjustFlags(index, flags)
	Int oid = AddToggleOption(label, StorageUtil.GetIntValue(None, variable), flags)
	DeclarativeMCM_MakeOID(index, oid, OID_TYPE_CHECKBOX, extraInfo, flags)
	return oid
EndFunction

; Makes a slider for an integer variable. label is shown inline, and
; extraInfo is shown on hover.
Int Function MakeIntSlider(String variable, String label, Int min, Int max, Int step, String extraInfo, String formatString = "{0}", Int flags = 0)
	DeclareInt(variable)
	Int index = DeclarativeMCM_ValidateUI(variable, TYPECODE_INT)
	If index == -1
		return -1
	EndIf
	flags = DeclarativeMCM_AdjustFlags(index, flags)
	Int oid = AddSliderOption(label, StorageUtil.GetIntValue(None, variable), formatString, flags)
	Int oidIndex = DeclarativeMCM_MakeOID(index, oid, OID_TYPE_INT_SLIDER, extraInfo, flags)
	DeclarativeMCM_PushExtraInt(oidIndex, min, true)
	DeclarativeMCM_PushExtraInt(oidIndex, max, true)
	DeclarativeMCM_PushExtraInt(oidIndex, step, true)
	DeclarativeMCM_PushExtraString(oidIndex, formatString, true)
	return oid
EndFunction

; Makes a slider for a float variable. label is shown inline, and
; extraInfo is shown on hover.
Int Function MakeFloatSlider(String variable, String label, Float min, Float max, Float step, String extraInfo, String formatString = "{0}", Int flags = 0)
	DeclareFloat(variable)
	Int index = DeclarativeMCM_ValidateUI(variable, TYPECODE_FLOAT)
	If index == -1
		return -1
	EndIf
	flags = DeclarativeMCM_AdjustFlags(index, flags)
	Int oid = AddSliderOption(label, StorageUtil.GetFloatValue(None, variable), formatString, flags)
	Int oidIndex = DeclarativeMCM_MakeOID(index, oid, OID_TYPE_FLOAT_SLIDER, extraInfo, flags)
	DeclarativeMCM_PushExtraFloat(oidIndex, min, true)
	DeclarativeMCM_PushExtraFloat(oidIndex, max, true)
	DeclarativeMCM_PushExtraFloat(oidIndex, step, true)
	DeclarativeMCM_PushExtraString(oidIndex, formatString, true)
	return oid
EndFunction

; Makes a text box for a string variable. label is shown inline, and
; extraInfo is shown on hover.
Int Function MakeTextBox(String variable, String label, String extraInfo, Int flags = 0)
	DeclareString(variable)
	Int index = DeclarativeMCM_ValidateUI(variable, TYPECODE_STRING)
	If index == -1
		return -1
	EndIf
	flags = DeclarativeMCM_AdjustFlags(index, flags)
	Int oid = AddInputOption(label, StorageUtil.GetStringValue(None, variable), flags)
	DeclarativeMCM_MakeOID(index, oid, OID_TYPE_TEXTBOX, extraInfo, flags)
	return oid
EndFunction

; Make a drop-down selector for an enum variable. label is shown inline,
; each element of choices is used for the corresponding value of variable, and
; extraInfo is shown on hover.
Int Function MakeDropdown(String variable, String label, String[] choices, String extraInfo, Int flags = 0)
	DeclareEnum(variable, choices.length)
	Int index = DeclarativeMCM_ValidateUI(variable, TYPECODE_ENUM)
	If index == -1
		return -1
	EndIf
	Int size = DeclarativeMCM_GetExtraInt(index, 1)
	If choices.length != size
		DeclarativeMCM_WarnEnumMismatchedSize(variable)
		return -1
	EndIf
	Int value = StorageUtil.GetIntValue(None, variable)
	flags = DeclarativeMCM_AdjustFlags(index, flags)
	Int oid = AddMenuOption(label, choices[value], flags)
	Int oidIndex = DeclarativeMCM_MakeOID(index, oid, OID_TYPE_DROPDOWN, extraInfo, flags)
	Int i = 0
	While i < size
		DeclarativeMCM_PushExtraString(oidIndex, choices[i], true)
		i += 1
	EndWhile
	return oid
EndFunction

; Make a text option that cycles through choices for an enum variable.
; Each time the user selects the option, it changes to the next choice. label is
; shown inline and extraInfo is shown on hover.
Int Function MakeCycler(String variable, String label, String[] choices, String extraInfo, Int flags = 0)
	DeclareEnum(variable, choices.length)
	Int index = DeclarativeMCM_ValidateUI(variable, TYPECODE_ENUM)
	If index == -1
		return -1
	EndIf
	Int size = DeclarativeMCM_GetExtraInt(index, 1)
	If choices.length != size
		DeclarativeMCM_WarnEnumMismatchedSize(variable)
		return -1
	EndIf
	Int value = StorageUtil.GetIntValue(None, variable)
	flags = DeclarativeMCM_AdjustFlags(index, flags)
	Int oid = AddTextOption(label, choices[value], flags)
	Int oidIndex = DeclarativeMCM_MakeOID(index, oid, OID_TYPE_CYCLER, extraInfo, flags)
	Int i = 0
	While i < size
		DeclarativeMCM_PushExtraString(oidIndex, choices[i], true)
		i += 1
	EndWhile
	return oid
EndFunction

; Make a color option for an integer variable. label is shown inline, and
; extraInfo is shown on hover. Colors are stored as 0xRRGGBB.
Int Function MakeColor(String variable, String label, String extraInfo, Int flags = 0)
	DeclareInt(variable)
	Int index = DeclarativeMCM_ValidateUI(variable, TYPECODE_INT)
	If index == -1
		return -1
	EndIf
	Int value = StorageUtil.GetIntValue(None, variable)
	flags = DeclarativeMCM_AdjustFlags(index, flags)
	Int oid = AddColorOption(label, value, flags)
	DeclarativeMCM_MakeOID(index, oid, OID_TYPE_COLOR, extraInfo, flags)
	return oid
EndFunction

; Make a key re-mapping control for an integer variable. The value will be
; a DXScanCode. label is shown inline and extraInfo is shown on hover.
; If the user selects a key which is already in use, ShowConflictWarning() is
; called. If the variable was not previously declared, this will also call
; RegisterForKey() when the user picks a new value.
Int Function MakeKeyMap(String variable, String label, String extraInfo, Int flags = 0)
	DeclareKeyCode(variable, label, True)
	Int index = DeclarativeMCM_ValidateUI(variable, TYPECODE_KEY)
	If index == -1
		return -1
	EndIf
	Int value = StorageUtil.GetIntValue(None, variable)
	flags = DeclarativeMCM_AdjustFlags(index, flags)
	Int oid = AddKeyMapOption(label, value, flags)
	DeclarativeMCM_MakeOID(index, oid, OID_TYPE_KEYMAP, extraInfo, flags)
	return oid
EndFunction

; Create a text option that will save all declared variables to an external
; file using JsonUtil. path is the path to the JSON file where we should save
; data. label is the text shown inline, buttonText is the value of the text
; option, extraInfo is shown on hover. successMessage and failureMessage are
; displayed with ShowMessage() on success or failure, unless you pass an
; empty string, in which case no message is displayed.
Int Function MakeSaveButton(String path, String label, String buttonText, String extraInfo, String successMessage, String failureMessage, Int flags = 0)
	Int oid = AddTextOption(label, buttonText, flags)
	Int oidIndex = DeclarativeMCM_MakeOID(-1, oid, OID_TYPE_SAVE, extraInfo, flags)
	DeclarativeMCM_PushExtraString(oidIndex, path, true)
	DeclarativeMCM_PushExtraString(oidIndex, successMessage, true)
	DeclarativeMCM_PushExtraString(oidIndex, failureMessage, true)
	return oid
EndFunction

; Create a text option that will load all declared variables from an external
; file using JsonUtil. path is the path to the JSON file where we should load
; data. label is the text shown inline, buttonText is the value of the text
; option, extraInfo is shown on hover. successMessage and failureMessage are
; displayed with ShowMessage() on success or failure, unless you pass an
; empty string, in which case no message is displayed.
Int Function MakeLoadButton(String path, String label, String buttonText, String extraInfo, String successMessage, String failureMessage, Int flags = 0)
	Int oid = AddTextOption(label, buttonText, flags)
	Int oidIndex = DeclarativeMCM_MakeOID(-1, oid, OID_TYPE_LOAD, extraInfo, flags)
	DeclarativeMCM_PushExtraString(oidIndex, path, true)
	DeclarativeMCM_PushExtraString(oidIndex, successMessage, true)
	DeclarativeMCM_PushExtraString(oidIndex, failureMessage, true)
	return oid
EndFunction

; Create a series of checkboxes to control the individual bits of an integer.
; Checkboxes are created from least to most significant, unless bigEndian is
; true (which will reverse the order). The variable should be an integer.
; Each label is shown inline; if a label is the empty string, the corresponding
; checkbox is skipped. If there are more than 32 labels, the extras are ignored.
; extraInfo is shown when any of the checkboxes is hovered.
; Return None if the variable is of the wrong type.
Int[] Function MakeMask(String variable, String[] labels, String extraInfo, Bool bigEndian = false, Int flags = 0)
	DeclareInt(variable)
	Int index = DeclarativeMCM_ValidateUI(variable, TYPECODE_INT)
	If index == -1
		return None
	EndIf
	Int value = StorageUtil.GetIntValue(None, variable)
	Int i = 0
	Int count = labels.length
	If count > 32
		count = 32
	EndIf
	Int mask
	If bigEndian
		mask = Math.LeftShift(1, count - 1)
	Else
		mask = 1
	EndIf
	flags = DeclarativeMCM_AdjustFlags(index, flags)
	StorageUtil.IntListClear(self, DeclarativeMCM_Scratch)
	While i < 32
		If labels[i]
			Int oid = DeclarativeMCM_MakeSingleBitMask(index, mask, value, labels[i], extraInfo, flags)
			StorageUtil.IntListAdd(self, DeclarativeMCM_Scratch, oid)
		EndIf
		i += 1
		If bigEndian
			; Nasty hack to deal with integer overflow being weird.
			If mask == 0x80000000
				mask = 0x40000000
			Else
				mask /= 2
			EndIf
		Else
			If mask == 0x40000000
				mask = 0x80000000
			Else
				mask *= 2
			EndIf
		EndIf
	EndWhile
	Int[] result = StorageUtil.IntListToArray(self, DeclarativeMCM_Scratch)
	StorageUtil.IntListClear(self, DeclarativeMCM_Scratch)
	return result
EndFunction

; Create a single checkbox to control an individual bit of an integer.
; bit should be a value from 0 to 31 inclusive. 0 means the least-significant
; bit, and 31 is the most-significant bit.
Int Function MakeSingleBitMask(String variable, Int bit, String label, String extraInfo, Int flags = 0)
	DeclareInt(variable)
	Int index = DeclarativeMCM_ValidateUI(variable, TYPECODE_INT)
	If index == -1
		return -1
	EndIf
	If bit < 0 || bit > 31
		DeclarativeMCM_WarnMaskOverflow(variable, bit)
	EndIf
	Int value = StorageUtil.GetIntValue(None, variable)
	Int mask = Math.LeftShift(1, bit)
	flags = DeclarativeMCM_AdjustFlags(index, flags)
	return DeclarativeMCM_MakeSingleBitMask(index, mask, value, label, extraInfo, flags)
EndFunction

; Create a text option that, when clicked, resets all variables to their default
; values. If confirmationMessage is non-empty, the user will be prompted with
; ShowMessage(confirmationMessage) before the reset happens.
; Validate() will not be called.
Int Function MakeResetButton(String label, String buttonText, String extraInfo, String confirmationMessage, Int flags = 0)
	Int oid = AddTextOption(label, buttonText, flags)
	Int oidIndex = DeclarativeMCM_MakeOID(-1, oid, OID_TYPE_RESET, extraInfo, flags)
	DeclarativeMCM_PushExtraString(oidIndex, confirmationMessage, true)
EndFunction

; Create a series of checkboxes that act like radio buttons. Each checkbox
; corresonds to one possible value of variable (which should be an enum). When
; the user selects a checkbox, all of the other checkboxes de-select themselves.
; If a label is the empty string, the corresponding radio button is skipped.
Int[] Function MakeRadioButtons(String variable, String[] labels, String extraInfo, Int flags = 0)
	DeclareEnum(variable, labels.length)
	Int index = DeclarativeMCM_ValidateUI(variable, TYPECODE_ENUM)
	If index == -1
		return None
	EndIf
	Int size = DeclarativeMCM_GetExtraInt(index, 1)
	If labels.length != size
		DeclarativeMCM_WarnEnumMismatchedSize(variable)
		return None
	EndIf
	flags = DeclarativeMCM_AdjustFlags(index, flags)
	Int i = 0
	Int value = StorageUtil.GetIntValue(None, variable)
	StorageUtil.IntListClear(self, DeclarativeMCM_Scratch)
	While i < labels.length
		If labels[i]
			Int oid = DeclarativeMCM_MakeSingleRadioButton(index, i, i == value, labels[i], extraInfo, flags)
		EndIf
		i += 1
	EndWhile
	Int[] result = StorageUtil.IntListToArray(self, DeclarativeMCM_Scratch)
	StorageUtil.IntListClear(self, DeclarativeMCM_Scratch)
	return result
EndFunction

; Create a single radio button checkbox. choice is the value it will set when it
; is checked.
Int Function MakeSingleRadioButton(String variable, Int choice, String label, String extraInfo, Int flags = 0)
	Int index = DeclarativeMCM_ValidateUI(variable, TYPECODE_ENUM, true)
	If index == -1
		return -1
	EndIf
	If choice < 0
		DeclarativeMCM_WarnChoiceNegative(variable, choice)
		return -1
	EndIf
	Int size = DeclarativeMCM_GetExtraInt(index, 1)
	If size <= choice
		DeclarativeMCM_WarnEnumTooSmall(variable, choice)
	EndIf
	Int value = StorageUtil.GetIntValue(None, variable)
	flags = DeclarativeMCM_AdjustFlags(index, flags)
	return DeclarativeMCM_MakeSingleRadioButton(index, choice, choice == value, label, extraInfo, flags)
EndFunction

; Attach hover text to a custom control. Intended for cases where you create a
; UI control directly with MCM functions; doesn't work if the control was
; created with one of the MakeFoo() methods above, or if you call
; MakeHoverText() multiple times on the same control.
Function MakeHoverText(Int oid, String extraInfo)
	If StorageUtil.IntListFind(self, DeclarativeMCM_OIDList, oid) != -1
		DeclarativeMCM_WarnMultipleHoverText()
		return
	EndIf
	DeclarativeMCM_MakeOID(-1, oid, OID_TYPE_EXTERNAL, extraInfo, 0)
EndFunction

; MCM overrides:
; WARNING: If you are going to override any of these functions, you should call
; Parent.Function() (e.g. Parent.OnConfigInit(), Parent.OnVersionUpdate(), etc.)
; or else bad things may happen.

Event OnConfigInit()
	If DeclarativeMCM_InDeclareVariables
		return
	EndIf
	DeclarativeMCM_InDeclareVariables = True
	DeclarativeMCM_ClearVariables()
	DeclareVariables()
	If StorageUtil.StringListCount(self, DeclarativeMCM_PageList)
		Pages = StorageUtil.StringListToArray(self, DeclarativeMCM_PageList)
	EndIf
	DeclarativeMCM_InDeclareVariables = False
EndEvent

Event OnVersionUpdate(Int version)
	If DeclarativeMCM_InDeclareVariables
		return
	EndIf
	DeclarativeMCM_InDeclareVariables = True
	DeclarativeMCM_ClearVariables()
	DeclareVariables()
	If StorageUtil.StringListCount(self, DeclarativeMCM_PageList)
		Pages = StorageUtil.StringListToArray(self, DeclarativeMCM_PageList)
	EndIf
	DeclarativeMCM_InDeclareVariables = False
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
		If DeclarativeMCM_InDeclareVariables
			Debug.Notification("DeclarativeMCM: Can't declare any new variables right now.")
			Debug.Notification("Try waiting a couple of seconds, saving, and loading again.")
			return
		EndIf
		DeclarativeMCM_InDeclareVariables = True
		DeclarativeMCM_ClearVariables()
		DeclareVariables()
		If StorageUtil.StringListCount(self, DeclarativeMCM_PageList)
			Pages = StorageUtil.StringListToArray(self, DeclarativeMCM_PageList)
		EndIf
		DeclarativeMCM_InDeclareVariables = False
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
EndEvent

Event OnOptionSelect(Int oid)
	Int oidIndex = StorageUtil.IntListFind(self, DeclarativeMCM_OIDList, oid)
	If oidIndex == -1
		return
	EndIf
	Int oidType = StorageUtil.IntListGet(self, DeclarativeMCM_OIDTypes, oidIndex)
	If oidType == OID_TYPE_EXTERNAL
		return
	EndIf
	Int index = StorageUtil.IntListGet(self, DeclarativeMCM_OIDIndices, oidIndex)
	String variable
	If index != -1
		variable = StorageUtil.StringListGet(self, DeclarativeMCM_VariableList, index)
	EndIf
	If oidType == OID_TYPE_CHECKBOX
		Bool value = StorageUtil.GetIntValue(None, variable)
		value = !value
		StorageUtil.SetIntValue(None, variable, value as Int)
		If !Validate(variable)
			StorageUtil.SetIntValue(None, variable, (!value) as Int)
			return
		EndIf
		DeclarativeMCM_ProcessTriggers(index, true)
		SetToggleOptionValue(oid, value)
	ElseIf oidType == OID_TYPE_CYCLER
		Int value = StorageUtil.GetIntValue(None, variable)
		Int size = DeclarativeMCM_GetExtraInt(index, 1)
		value += 1
		value %= size
		StorageUtil.SetIntValue(None, variable, value)
		If !Validate(variable)
			value += size - 1
			value %= size
			StorageUtil.SetIntValue(None, variable, value)
			return
		EndIf
		DeclarativeMCM_ProcessTriggers(index, value == 0 || value == 1)
		SetTextOptionValue(oid, DeclarativeMCM_GetExtraString(oidIndex, value, true))
	ElseIf oidType == OID_TYPE_SAVE
		String path = DeclarativeMCM_GetExtraString(oidIndex, 0, true)
		Int i = 0
		Int count = StorageUtil.StringListCount(self, DeclarativeMCM_VariableList)
		While i < count
			DeclarativeMCM_SaveVariable(path, i)
			i += 1
		EndWhile
		If JsonUtil.Save(path)
			String successMessage = DeclarativeMCM_GetExtraString(oidIndex, 1, true)
			If successMessage
				ShowMessage(successMessage, false)
			EndIf
		Else
			String failureMessage = DeclarativeMCM_GetExtraString(oidIndex, 2, true)
			If failureMessage
				ShowMessage(failureMessage, false)
			EndIf
		EndIf
	ElseIf oidType == OID_TYPE_LOAD
		String path = DeclarativeMCM_GetExtraString(oidIndex, 0, true)
		If !JsonUtil.Load(path) || !JsonUtil.IsGood(path)
			String failureMessage = DeclarativeMCM_GetExtraString(oidIndex, 2, true)
			If failureMessage
				ShowMessage(failureMessage, false)
			EndIf
			return
		EndIf
		Int i = 0
		Int count = StorageUtil.StringListCount(self, DeclarativeMCM_VariableList)
		While i < count
			DeclarativeMCM_LoadVariable(path, i)
			i += 1
		EndWhile
		String successMessage = DeclarativeMCM_GetExtraString(oidIndex, 1, true)
		If successMessage
			ShowMessage(successMessage, false)
		EndIf
		DeclarativeMCM_ProcessAllTriggers()
		ForcePageReset()
	ElseIf oidType == OID_TYPE_MASK
		Int oldValue = StorageUtil.GetIntValue(None, variable)
		Int mask = DeclarativeMCM_GetExtraInt(oidIndex, 0, true)
		Int value = Math.LogicalXor(oldValue, mask)
		StorageUtil.SetIntValue(None, variable, value)
		If !Validate(variable)
			StorageUtil.SetIntValue(None, variable, oldValue)
			return
		EndIf
		DeclarativeMCM_ProcessTriggers(index, (value as Bool) != (oldValue as Bool))
		SetToggleOptionValue(oid, Math.LogicalAnd(value, mask))
	ElseIf oidType == OID_TYPE_RESET
		String confirmationMessage = DeclarativeMCM_GetExtraString(oidIndex, 0, true)
		If confirmationMessage && !ShowMessage(confirmationMessage)
			return
		EndIf
		Int i = 0
		Int count = StorageUtil.StringListCount(self, DeclarativeMCM_VariableList)
		While i < count
			Int typecode = StorageUtil.IntListGet(self, DeclarativeMCM_TypeList, i)
			variable = StorageUtil.StringListGet(self, DeclarativeMCM_VariableList, i)
			If typecode == TYPECODE_STRING
				DeclarativeMCM_ResetStringVariable(i, variable)
			ElseIf typecode == TYPECODE_FLOAT
				DeclarativeMCM_ResetFloatVariable(i, variable)
			Else
				DeclarativeMCM_ResetIntVariable(i, variable)
			EndIf
			i += 1
		EndWhile
		DeclarativeMCM_ProcessAllTriggers()
		ForcePageReset()
	ElseIf oidType == OID_TYPE_RADIO
		Int oldValue = StorageUtil.GetIntValue(None, variable)
		Int size = DeclarativeMCM_GetExtraInt(index, 1)
		Int value = DeclarativeMCM_GetExtraInt(oidIndex, 0, true)
		If value == oldValue
			return
		EndIf
		StorageUtil.SetIntValue(None, variable, value)
		If !Validate(variable)
			StorageUtil.SetIntValue(None, variable, oldValue)
			return
		EndIf
		DeclarativeMCM_ProcessTriggers(index, (value as Bool) != (oldValue as Bool))
		SetToggleOptionValue(oid, true)
		Int i = 0
		Int count = StorageUtil.IntListCount(self, DeclarativeMCM_OIDList)
		While i < count
			If StorageUtil.IntListGet(self, DeclarativeMCM_OIDTypes, i) == OID_TYPE_RADIO && StorageUtil.IntListGet(self, DeclarativeMCM_OIDIndices, i) == index && DeclarativeMCM_GetExtraInt(i, 0, true) == oldValue
				SetToggleOptionValue(StorageUtil.IntListGet(self, DeclarativeMCM_OIDList, i), false)
				return
			EndIf
			i += 1
		EndWhile
	EndIf
EndEvent

Event OnOptionSliderOpen(Int oid)
	Int oidIndex = StorageUtil.IntListFind(self, DeclarativeMCM_OIDList, oid)
	If oidIndex == -1
		return
	EndIf
	Int oidType = StorageUtil.IntListGet(self, DeclarativeMCM_OIDTypes, oidIndex)
	If oidType == OID_TYPE_EXTERNAL
		return
	EndIf
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
		Float fDefault = DeclarativeMCM_GetExtraFloat(index, 0)
		Float fMin = DeclarativeMCM_GetExtraFloat(oidIndex, 0, true)
		Float fMax = DeclarativeMCM_GetExtraFloat(oidIndex, 1, true)
		Float fStep = DeclarativeMCM_GetExtraFloat(oidIndex, 2, true)
		Float fCurrent = StorageUtil.GetFloatValue(None, variable)
		SetSliderDialogStartValue(fCurrent)
		SetSliderDialogDefaultValue(fDefault)
		SetSliderDialogRange(fMin, fMax)
		SetSliderDialogInterval(fStep)
	EndIf
EndEvent

Event OnOptionSliderAccept(Int oid, Float value)
	Int oidIndex = StorageUtil.IntListFind(self, DeclarativeMCM_OIDList, oid)
	If oidIndex == -1
		return
	EndIf
	Int oidType = StorageUtil.IntListGet(self, DeclarativeMCM_OIDTypes, oidIndex)
	If oidType == OID_TYPE_EXTERNAL
		return
	EndIf
	Int index = StorageUtil.IntListGet(self, DeclarativeMCM_OIDIndices, oidIndex)
	String variable = StorageUtil.StringListGet(self, DeclarativeMCM_VariableList, index)
	If oidType == OID_TYPE_INT_SLIDER
		Int oldValue = StorageUtil.GetIntValue(None, variable)
		StorageUtil.SetIntValue(None, variable, value as Int)
		If !validate(variable)
			StorageUtil.SetIntValue(None, variable, oldValue)
			return
		EndIf
		DeclarativeMCM_ProcessTriggers(index, (value as Bool) != (oldValue as Bool))
	ElseIf oidType == OID_TYPE_FLOAT_SLIDER
		Float oldValue = StorageUtil.GetFloatValue(None, variable)
		StorageUtil.SetFloatValue(None, variable, value)
		If !validate(variable)
			StorageUtil.SetFloatValue(None, variable, oldValue)
			return
		EndIf
		DeclarativeMCM_ProcessTriggers(index, (value as Bool) != (oldValue as Bool))
	EndIf
	String formatString = DeclarativeMCM_GetExtraString(oidIndex, 3, true)
	SetSliderOptionValue(oid, value, formatString)
EndEvent

Event OnOptionInputOpen(Int oid)
	Int oidIndex = StorageUtil.IntListFind(self, DeclarativeMCM_OIDList, oid)
	If oidIndex == -1
		return
	EndIf
	Int oidType = StorageUtil.IntListGet(self, DeclarativeMCM_OIDTypes, oidIndex)
	If oidType == OID_TYPE_EXTERNAL
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
	Int oidType = StorageUtil.IntListGet(self, DeclarativeMCM_OIDTypes, oidIndex)
	If oidType == OID_TYPE_EXTERNAL
		return
	EndIf
	Int index = StorageUtil.IntListGet(self, DeclarativeMCM_OIDIndices, oidIndex)
	String variable = StorageUtil.StringListGet(self, DeclarativeMCM_VariableList, index)
	String oldValue = StorageUtil.GetStringValue(None, variable)
	StorageUtil.SetStringValue(None, variable, value)
	If !Validate(variable)
		StorageUtil.SetStringValue(None, variable, oldValue)
		return
	EndIf
	DeclarativeMCM_ProcessTriggers(index, (value as Bool) != (oldValue as Bool))
	SetInputOptionValue(oid, value)
EndEvent

Event OnOptionMenuOpen(Int oid)
	Int oidIndex = StorageUtil.IntListFind(self, DeclarativeMCM_OIDList, oid)
	If oidIndex == -1
		return
	EndIf
	Int oidType = StorageUtil.IntListGet(self, DeclarativeMCM_OIDTypes, oidIndex)
	If oidType == OID_TYPE_EXTERNAL
		return
	EndIf
	Int index = StorageUtil.IntListGet(self, DeclarativeMCM_OIDIndices, oidIndex)
	String variable = StorageUtil.StringListGet(self, DeclarativeMCM_VariableList, index)
	Int value = StorageUtil.GetIntValue(None, variable)
	Int default = DeclarativeMCM_GetExtraInt(index, 0)
	Int size = DeclarativeMCM_GetExtraInt(index, 1)
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

Event OnOptionMenuAccept(Int oid, Int value)
	Int oidIndex = StorageUtil.IntListFind(self, DeclarativeMCM_OIDList, oid)
	If oidIndex == -1
		return
	EndIf
	Int oidType = StorageUtil.IntListGet(self, DeclarativeMCM_OIDTypes, oidIndex)
	If oidType == OID_TYPE_EXTERNAL
		return
	EndIf
	Int index = StorageUtil.IntListGet(self, DeclarativeMCM_OIDIndices, oidIndex)
	String variable = StorageUtil.StringListGet(self, DeclarativeMCM_VariableList, index)
	Int oldValue = StorageUtil.GetIntValue(None, variable)
	StorageUtil.SetIntValue(None, variable, value)
	If !Validate(variable)
		StorageUtil.SetIntValue(None, variable, oldValue)
		return
	EndIf
	DeclarativeMCM_ProcessTriggers(index, (value as Bool) != (oldValue as Bool))
	String choice = DeclarativeMCM_GetExtraString(oidIndex, value, true)
	SetMenuOptionValue(oid, choice)
EndEvent

Event OnOptionColorOpen(Int oid)
	Int oidIndex = StorageUtil.IntListFind(self, DeclarativeMCM_OIDList, oid)
	If oidIndex == -1
		return
	EndIf
	Int oidType = StorageUtil.IntListGet(self, DeclarativeMCM_OIDTypes, oidIndex)
	If oidType == OID_TYPE_EXTERNAL
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
	Int oidType = StorageUtil.IntListGet(self, DeclarativeMCM_OIDTypes, oidIndex)
	If oidType == OID_TYPE_EXTERNAL
		return
	EndIf
	Int index = StorageUtil.IntListGet(self, DeclarativeMCM_OIDIndices, oidIndex)
	String variable = StorageUtil.StringListGet(self, DeclarativeMCM_VariableList, index)
	Int oldValue = StorageUtil.GetIntValue(None, variable)
	StorageUtil.SetIntValue(None, variable, value)
	If !Validate(variable)
		StorageUtil.SetIntValue(None, variable, oldValue)
		return
	EndIf
	DeclarativeMCM_ProcessTriggers(index, (value as Bool) != (oldValue as Bool))
	SetColorOptionValue(oid, value)
EndEvent

Event OnOptionKeyMapChange(Int oid, Int value, String conflictControl, String conflictMod)
	Int oidIndex = StorageUtil.IntListFind(self, DeclarativeMCM_OIDList, oid)
	If oidIndex == -1
		return
	EndIf
	Int oidType = StorageUtil.IntListGet(self, DeclarativeMCM_OIDTypes, oidIndex)
	If oidType == OID_TYPE_EXTERNAL
		return
	EndIf
	Int index = StorageUtil.IntListGet(self, DeclarativeMCM_OIDIndices, oidIndex)
	String variable = StorageUtil.StringListGet(self, DeclarativeMCM_VariableList, index)
	If (conflictControl || conflictMod) && !HandleKeyConflict(variable, conflictControl, conflictMod)
		return
	EndIf
	Int oldValue = StorageUtil.GetIntValue(None, variable)
	StorageUtil.SetIntValue(None, variable, value)
	If !Validate(variable)
		StorageUtil.SetIntValue(None, variable, oldValue)
		return
	EndIf
	Bool registerForKey = DeclarativeMCM_GetExtraInt(index, 1)
	If registerForKey
		If oldValue
			UnregisterForKey(oldValue)
		EndIf
		If value
			RegisterForKey(value)
		EndIf
	EndIf
	DeclarativeMCM_ProcessTriggers(index, (value as Bool) != (oldValue as Bool))
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
	; Defaulting a variable is probably one of the most complex things we have
	; to support. We start by finding the underlying variable that owns this
	; OID.
	Int oidIndex = StorageUtil.IntListFind(self, DeclarativeMCM_OIDList, oid)
	If oidIndex == -1
		return
	EndIf
	Int oidType = StorageUtil.IntListGet(self, DeclarativeMCM_OIDTypes, oidIndex)
	If oidType == OID_TYPE_EXTERNAL
		return
	EndIf
	Int index = StorageUtil.IntListGet(self, DeclarativeMCM_OIDIndices, oidIndex)
	If index == -1
		; Save/load/reset buttons, and other controls with no variable.
		return
	EndIf
	String variable = StorageUtil.StringListGet(self, DeclarativeMCM_VariableList, index)
	Int typecode = StorageUtil.IntListGet(self, DeclarativeMCM_TypeList, index)
	Float fDefault
	Float fOldValue
	String sDefault
	String sOldValue
	Int iDefault
	Int iOldValue
	; In *most* cases, we want to default the entire variable, but there's one
	; exception to that rule. For masks, just default the one checkbox.
	If oidType == OID_TYPE_MASK
		iOldValue = StorageUtil.GetIntValue(None, variable)
		Int newValue = iOldValue
		iDefault = DeclarativeMCM_GetExtraInt(index, 0)
		Int mask = DeclarativeMCM_GetExtraInt(oidIndex, 0, true)
		Int maskedDefault = Math.LogicalAnd(mask, iDefault)
		newValue = Math.LogicalAnd(Math.LogicalNot(mask), newValue)
		newValue = Math.LogicalOr(maskedDefault, newValue)
		StorageUtil.SetIntValue(None, variable, newValue)
		If !Validate(variable)
			StorageUtil.SetIntValue(None, variable, iOldValue)
			return
		EndIf
		DeclarativeMCM_ProcessTriggers(index, (newValue as Bool) != (iOldValue as Bool))
		SetToggleOptionValue(oid, maskedDefault)
		return
	; For all other cases, retrieve the default and the current (old) value,
	; set the variable to the default, call Validate(), and if it accepts the
	; default, then fall through to the next part.
	ElseIf typecode == TYPECODE_FLOAT
		fOldValue = StorageUtil.GetFloatValue(None, variable)
		fDefault = DeclarativeMCM_ResetIntVariable(index, variable)
		If fOldValue == fDefault
			return
		EndIf
		If !Validate(variable)
			StorageUtil.SetFloatValue(None, variable, fOldValue)
			return
		EndIf
		DeclarativeMCM_ProcessTriggers(index, (fOldValue as Bool) != (fDefault as Bool))
	ElseIf typecode == TYPECODE_STRING
		sOldValue = StorageUtil.GetStringValue(None, variable)
		sDefault = DeclarativeMCM_ResetStringVariable(index, variable)
		If sOldValue == sDefault
			return
		EndIf
		If !Validate(variable)
			StorageUtil.SetStringValue(None, variable, sOldValue)
			return
		EndIf
		DeclarativeMCM_ProcessTriggers(index, (sOldValue as Bool) != (sDefault as Bool))
	Else
		iOldValue = StorageUtil.GetIntValue(None, variable)
		iDefault = DeclarativeMCM_ResetIntVariable(index, variable)
		If iOldValue == iDefault
			return
		EndIf
		If !Validate(variable)
			StorageUtil.SetIntValue(None, variable, iOldValue)
			return
		EndIf
		DeclarativeMCM_ProcessTriggers(index, (iOldValue as Bool) != (iDefault as Bool))
	EndIf
	; Finally, now that we know we've definitely changed the value, it's time to
	; make the UI match.
	If oidType == OID_TYPE_CHECKBOX
		SetToggleOptionValue(oid, iDefault)
	ElseIf oidType == OID_TYPE_INT_SLIDER
		String formatString = DeclarativeMCM_GetExtraString(oidIndex, 3, true)
		SetSliderOptionValue(oid, iDefault, formatString)
	ElseIf oidType == OID_TYPE_FLOAT_SLIDER
		String formatString = DeclarativeMCM_GetExtraString(oidIndex, 3, true)
		SetSliderOptionValue(oid, fDefault, formatString)
	ElseIf oidType == OID_TYPE_TEXTBOX
		SetInputOptionValue(oid, sDefault)
	ElseIf oidType == OID_TYPE_DROPDOWN || oidType == OID_TYPE_CYCLER
		String displayValue = DeclarativeMCM_GetExtraString(oidIndex, iDefault, true)
		If oidType == OID_TYPE_DROPDOWN
			SetMenuOptionValue(oid, displayValue)
		Else
			SetTextOptionValue(oid, displayValue)
		EndIf
	ElseIf oidType == OID_TYPE_COLOR
		SetColorOptionValue(oid, iDefault)
	ElseIf oidType == OID_TYPE_KEYMAP
		Bool registerForKey = DeclarativeMCM_GetExtraInt(index, 1)
		If registerForKey
			If iOldValue
				UnregisterForKey(iOldValue)
			EndIf
			If iDefault
				RegisterForKey(iDefault)
			EndIf
		EndIf
		SetKeyMapOptionValue(oid, iDefault)
	ElseIf oidType == OID_TYPE_RADIO
		Int i = 0
		Int count = StorageUtil.IntListCount(self, DeclarativeMCM_OIDList)
		Bool foundOldValue = false
		Bool foundDefault = false
		While i < count && (!foundOldValue || !foundDefault)
			If StorageUtil.IntListGet(self, DeclarativeMCM_OIDTypes, i) == OID_TYPE_RADIO && StorageUtil.IntListGet(self, DeclarativeMCM_OIDIndices, i) == index
				Int myValue = DeclarativeMCM_GetExtraInt(i, 0, true)
				If myValue == iOldValue
					SetToggleOptionValue(StorageUtil.IntListGet(self, DeclarativeMCM_OIDList, i), false)
					foundOldValue = true
				ElseIf myValue == iDefault
					SetToggleOptionValue(StorageUtil.IntListGet(self, DeclarativeMCM_OIDList, i), true)
					foundDefault = true
				EndIf
			EndIf
			i += 1
		EndWhile
	EndIf
EndEvent

Function SetOptionFlags(int option, int flags, bool noUpdate = false)
	Parent.SetOptionFlags(option, flags, noUpdate)
	Int oidIndex = StorageUtil.IntListFind(self, DeclarativeMCM_OIDList, option)
	StorageUtil.IntListSet(self, DeclarativeMCM_OIDFlags, oidIndex, flags)
EndFunction

; Private members, do not use directly:

Int Property TYPECODE_BOOL = 0 autoreadonly
Int Property TYPECODE_INT = 1 autoreadonly
Int Property TYPECODE_FLOAT = 2 autoreadonly
Int Property TYPECODE_STRING = 3 autoreadonly
Int Property TYPECODE_ENUM = 4 autoreadonly
Int Property TYPECODE_KEY = 5 autoreadonly

Int Property OID_TYPE_CHECKBOX = 0 autoreadonly
Int Property OID_TYPE_INT_SLIDER = 1 autoreadonly
Int Property OID_TYPE_FLOAT_SLIDER = 2 autoreadonly
Int Property OID_TYPE_TEXTBOX = 3 autoreadonly
Int Property OID_TYPE_DROPDOWN = 4 autoreadonly
Int Property OID_TYPE_CYCLER = 5 autoreadonly
Int Property OID_TYPE_COLOR = 6 autoreadonly
Int Property OID_TYPE_KEYMAP = 7 autoreadonly
Int Property OID_TYPE_SAVE = 8 autoreadonly
Int Property OID_TYPE_LOAD = 9 autoreadonly
Int Property OID_TYPE_MASK = 10 autoreadonly
Int Property OID_TYPE_RESET = 11 autoreadonly
Int Property OID_TYPE_RADIO = 12 autoreadonly
Int Property OID_TYPE_EXTERNAL = 13 autoreadonly

; The internal variable table. Cleared by OnVersionUpdate(), and
; OnGameReload() if LocalDevelopment() is true.
; The variable name
String Property DeclarativeMCM_VariableList = "DeclarativeMCM:VariableList" autoreadonly
; The variable type code (see above)
String Property DeclarativeMCM_TypeList = "DeclarativeMCM:TypeList" autoreadonly
; Offset into the integer version of ExtraList
String Property DeclarativeMCM_OffsetList = "DeclarativeMCM:OffsetList" autoreadonly
; Three lists of "extra data" associated with a variable.
String Property DeclarativeMCM_ExtraList = "DeclarativeMCM:ExtraList" autoreadonly
; Truthy if this variable is the LHS of a dependency
String Property DeclarativeMCM_IsDependent = "DeclarativeMCM:IsDependent" autoreadonly
; Truthy if this variable is the RHS of a dependency
String Property DeclarativeMCM_HasDependent = "DeclarativeMCM:HasDependent" autoreadonly
; Truthy if this variable will be sync'd to a GlobalVariable
String Property DeclarativeMCM_IsSynced = "DeclarativeMCM:IsSynced" autoreadonly

; Other stuff that also gets set up by DeclareVariables()
; The list of pages that we will create.
String Property DeclarativeMCM_PageList = "DeclarativeMCM:PageList" autoreadonly
; The logo data.
String Property DeclarativeMCM_LogoPath = "DeclarativeMCM:LogoPath" autoreadonly
String Property DeclarativeMCM_LogoX = "DeclarativeMCM:LogoX" autoreadonly
String Property DeclarativeMCM_LogoY = "DeclarativeMCM:LogoY" autoreadonly
; The list of variables to sync to globals, and the list of globals to sync to.
String Property DeclarativeMCM_GlobalSyncList = "DeclarativeMCM:GlobalSyncList" autoreadonly
; LHS and RHS for dependencies
String Property DeclarativeMCM_DependencyLHS = "DeclarativeMCM:DependencyLHS" autoreadonly
String Property DeclarativeMCM_DependencyRHS = "DeclarativeMCM:DependencyRHS" autoreadonly
String Property DeclarativeMCM_DependencyType = "DeclarativeMCM:DependencyType" autoreadonly

; The internal OID table. Cleared by OnPageReset() and OnConfigClose().
; The OID.
String Property DeclarativeMCM_OIDList = "DeclarativeMCM:OIDList" autoreadonly
; The index into the variable table.
String Property DeclarativeMCM_OIDIndices = "DeclarativeMCM:OIDIndices" autoreadonly
; The OID type (see above)
String Property DeclarativeMCM_OIDTypes = "DeclarativeMCM:OIDTypes" autoreadonly
; Offset into the integer version of OIDExtras
String Property DeclarativeMCM_OIDOffsets = "DeclarativeMCM:OIDOffsets" autoreadonly
; The string to show on hover.
String Property DeclarativeMCM_OIDInfos = "DeclarativeMCM:OIDInfos" autoreadonly
; The current set of flags.
String Property DeclarativeMCM_OIDFlags = "DeclarativeMCM:OIDFlags" autoreadonly
; Three lists of "extra data" associated with an OID.
String Property DeclarativeMCM_OIDExtras = "DeclarativeMCM:OIDExtras" autoreadonly
; OIDs that are the LHS of a dependency
String Property DeclarativeMCM_OIDsWithDependencies = "DeclarativeMCM:OIDsWithDependencies" autoreadonly

; Temporary variable for building arrays.
String Property DeclarativeMCM_Scratch = "DeclarativeMCM:Scratch" autoreadonly

; Lock to protect DeclareVariables() from being re-entered.
Bool DeclarativeMCM_InDeclareVariables

; Add a new variable to the internal variable table. Returns the index into the
; table where the variable was created.
Int Function DeclarativeMCM_MakeVariable(String variable, Int typecode)
	Int result = StorageUtil.StringListAdd(self, DeclarativeMCM_VariableList, variable)
	StorageUtil.IntListAdd(self, DeclarativeMCM_TypeList, typecode)
	StorageUtil.IntListAdd(self, DeclarativeMCM_OffsetList, -1)
	StorageUtil.IntListAdd(self, DeclarativeMCM_IsDependent, 0)
	StorageUtil.IntListAdd(self, DeclarativeMCM_HasDependent, 0)
	StorageUtil.IntListAdd(self, DeclarativeMCM_IsSynced, 0)
	return result
EndFunction

; Save a variable directly to path.
Function DeclarativeMCM_SaveVariable(String path, Int index)
	Int typecode = StorageUtil.IntListGet(self, DeclarativeMCM_TypeList, index)
	String variable = StorageUtil.StringListGet(self, DeclarativeMCM_VariableList, index)
	If typecode == TYPECODE_FLOAT
		JsonUtil.SetFloatValue(path, variable, StorageUtil.GetFloatValue(None, variable))
	ElseIf typecode == TYPECODE_STRING
		JsonUtil.SetStringValue(path, variable, StorageUtil.GetStringValue(None, variable))
	Else
		JsonUtil.SetIntValue(path, variable, StorageUtil.GetIntValue(None, variable))
	EndIf
EndFunction

; Load a variable directly from path, or use its default value if JsonUtil
; has no value to give us.
Function DeclarativeMCM_LoadVariable(String path, Int index)
	Int typecode = StorageUtil.IntListGet(self, DeclarativeMCM_TypeList, index)
	String variable = StorageUtil.StringListGet(self, DeclarativeMCM_VariableList, index)
	If typecode == TYPECODE_FLOAT
		Float fDefault = DeclarativeMCM_GetExtraFloat(index, 0)
		StorageUtil.SetFloatValue(None, variable, JsonUtil.GetFloatValue(path, variable, fDefault))
		return
	EndIf
	If typecode == TYPECODE_STRING
		String sDefault = DeclarativeMCM_GetExtraString(index, 0)
		StorageUtil.SetStringValue(None, variable, JsonUtil.GetStringValue(path, variable, sDefault))
		return
	EndIf
	Int iDefault = DeclarativeMCM_GetExtraInt(index, 0)
	StorageUtil.SetIntValue(None, variable, JsonUtil.GetIntValue(path, variable, iDefault))
EndFunction

Bool Function DeclarativeMCM_IsTruthy(Int index)
	String variable = StorageUtil.StringListGet(self, DeclarativeMCM_VariableList, index)
	Int typecode = StorageUtil.IntListGet(self, DeclarativeMCM_TypeList, index)
	If typecode == TYPECODE_STRING
		return StorageUtil.GetStringValue(None, variable)
	ElseIf typecode == TYPECODE_FLOAT
		return StorageUtil.GetFloatValue(None, variable)
	Else
		return StorageUtil.GetIntValue(None, variable)
	EndIf
EndFunction

; Return true if we want to enable the variable index.
Bool Function DeclarativeMCM_ShouldEnable(Int index)
	Int i = 0
	Int count = StorageUtil.IntListCount(self, DeclarativeMCM_DependencyLHS)
	While i < count
		If StorageUtil.IntListGet(self, DeclarativeMCM_DependencyLHS, i) == index
			Int otherIndex = StorageUtil.IntListGet(self, DeclarativeMCM_DependencyRHS, i)
			Int verb = StorageUtil.IntListGet(self, DeclarativeMCM_DependencyType, i)
			If verb == REQUIRES && !DeclarativeMCM_IsTruthy(otherIndex)
				return false
			ElseIf verb == CONFLICTS_WITH && DeclarativeMCM_IsTruthy(otherIndex)
				return false
			EndIf
		EndIf
		i += 1
	EndWhile
	return true
EndFunction

Int Function DeclarativeMCM_AdjustFlags(Int index, Int flags)
	If !StorageUtil.IntListGet(self, DeclarativeMCM_IsDependent, index)
		return flags
	EndIf
	If DeclarativeMCM_ShouldEnable(index)
		flags = Math.LogicalAnd(flags, Math.LogicalNot(OPTION_FLAG_DISABLED))
	Else
		flags = Math.LogicalOr(flags, OPTION_FLAG_DISABLED)
	EndIf
	return flags
EndFunction

Function DeclarativeMCM_SetEnabled(Int oidIndex, Bool enabled)
	Int oid = StorageUtil.IntListGet(self, DeclarativeMCM_OIDList, oidIndex)
	Int flags = StorageUtil.IntListGet(self, DeclarativeMCM_OIDFlags, oidIndex)
	Int oldFlags = flags
	If enabled
		flags = Math.LogicalAnd(flags, Math.LogicalNot(OPTION_FLAG_DISABLED))
	Else
		flags = Math.LogicalOr(flags, OPTION_FLAG_DISABLED)
	EndIf
	If flags == oldFlags
		return
	EndIf
	SetOptionFlags(oid, flags)
EndFunction

Function DeclarativeMCM_SetVariableEnabled(Int index, Bool enabled)
	Int i = 0
	Int count = StorageUtil.IntListCount(self, DeclarativeMCM_OIDsWithDependencies)
	While i < count
		Int oidIndex = StorageUtil.IntListGet(self, DeclarativeMCM_OIDsWithDependencies, i)
		If StorageUtil.GetIntValue(self, DeclarativeMCM_OIDIndices, oidIndex) == index
			DeclarativeMCM_SetEnabled(i, enabled)
		EndIf
		i += 1
	EndWhile
EndFunction

; Notify syncing and dependencies that the variable has changed.
; statusChanged: Whether the variable changed from falsey to truthy or vice-versa.
Function DeclarativeMCM_ProcessTriggers(Int index, Bool statusChanged)
	If StorageUtil.GetIntValue(self, DeclarativeMCM_IsSynced, index)
		DeclarativeMCM_SyncVariable(index)
	EndIf
	If !statusChanged || !StorageUtil.GetIntValue(self, DeclarativeMCM_HasDependent, index)
		return
	EndIf
	Int i = 0
	Int count = StorageUtil.IntListCount(self, DeclarativeMCM_DependencyRHS)
	While i < count
		If StorageUtil.IntListGet(self, DeclarativeMCM_DependencyRHS, i) == index
			Int otherIndex = StorageUtil.IntListGet(self, DeclarativeMCM_DependencyLHS, i)
			DeclarativeMCM_SetVariableEnabled(otherIndex, DeclarativeMCM_ShouldEnable(otherIndex))
		EndIf
		i += 1
	EndWhile
EndFunction

; Sync variable to its owning global.
Function DeclarativeMCM_SyncVariable(Int index)
	Int i = 0
	Int len = StorageUtil.IntListCount(self, DeclarativeMCM_GlobalSyncList)
	While i < len
		If index == StorageUtil.IntListGet(self, DeclarativeMCM_GlobalSyncList, i)
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
			return
		EndIf
		i += 1
	EndWhile
EndFunction

Function DeclarativeMCM_ProcessAllTriggers()
	Int i = 0
	Int count = StorageUtil.IntListCount(self, DeclarativeMCM_DependencyRHS)
	While i < count
		DeclarativeMCM_ProcessTriggers(StorageUtil.IntListGet(self, DeclarativeMCM_DependencyRHS, i), false)
		i += 1
	EndWhile
	ValidateAll()
EndFunction

; Resets a variable to its default value, which is then returned.
Int Function DeclarativeMCM_ResetIntVariable(Int index, String variable)
	Int default = DeclarativeMCM_GetExtraInt(index, 0)
	StorageUtil.SetIntValue(None, variable, default)
	return default
EndFunction

Float Function DeclarativeMCM_ResetFloatVariable(Int index, String variable)
	Float default = DeclarativeMCM_GetExtraFloat(index, 0)
	StorageUtil.SetFloatValue(None, variable, default)
	return default
EndFunction

String Function DeclarativeMCM_ResetStringVariable(Int index, String variable)
	String default = DeclarativeMCM_GetExtraString(index, 0)
	StorageUtil.SetStringValue(None, variable, default)
	return default
EndFunction

Int Function DeclarativeMCM_MakeSingleBitMask(Int index, Int mask, Int value, String label, String extraInfo, Int flags)
	Int oid = AddToggleOption(label, Math.LogicalAnd(value, mask), flags)
	Int oidIndex = DeclarativeMCM_MakeOID(index, oid, OID_TYPE_MASK, extraInfo, flags)
	DeclarativeMCM_PushExtraInt(oidIndex, mask, true)
	return oid
EndFunction

Int Function DeclarativeMCM_MakeSingleRadioButton(Int index, Int choice, Bool checked, String label, String extraInfo, Int flags)
	Int oid = AddToggleOption(label, checked, flags)
	Int oidIndex = DeclarativeMCM_MakeOID(index, oid, OID_TYPE_RADIO, extraInfo, flags)
	DeclarativeMCM_PushExtraInt(oidIndex, choice, true)
	StorageUtil.IntListAdd(self, DeclarativeMCM_Scratch, oid)
	return oid
EndFunction

; Save an OID. Returns the index into the OID table.
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
	If StorageUtil.IntListGet(self, DeclarativeMCM_IsDependent, index)
		StorageUtil.IntListadd(self, DeclarativeMCM_OIDsWithDependencies, oidIndex, false)
	EndIf
	return result
EndFunction

; Push an int of extra data, associated with index in either the variable table
; or the OID table. Appends the int to an extra list, and sets the value in the
; offset column to point to the first int pushed.
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

; Push a float of extra data. Appends the float to an extra list, and pushes the
; float's offset as an extra int (see above).
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

; Push a string of extra data. Appends the string to an extra list, and pushes
; the string's offset as an extra int (see above).
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

; Retrieval functions for the above push functions.
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
	Int offsetIndex = DeclarativeMCM_GetExtraInt(index, subIndex, oid)
	return StorageUtil.FloatListGet(self, extraList, offsetIndex)
EndFunction

String Function DeclarativeMCM_GetExtraString(Int index, Int subIndex, Bool oid = false)
	String extraList
	If oid
		extraList = DeclarativeMCM_OIDExtras
	Else
		extraList = DeclarativeMCM_ExtraList
	EndIf
	Int offsetIndex = DeclarativeMCM_GetExtraInt(index, subIndex, oid)
	return StorageUtil.StringListGet(self, extraList, offsetIndex)
EndFunction

; Clears the variable table. Doesn't touch the actual *values*, just our
; internal metadata about them. DeclareVariables() will re-populate the table.
Function DeclarativeMCM_ClearVariables()
	StorageUtil.StringListClear(self, DeclarativeMCM_VariableList)
	StorageUtil.IntListClear(self, DeclarativeMCM_TypeList)
	StorageUtil.IntListClear(self, DeclarativeMCM_ExtraList)
	StorageUtil.FloatListClear(self, DeclarativeMCM_ExtraList)
	StorageUtil.StringListClear(self, DeclarativeMCM_ExtraList)
	StorageUtil.IntListClear(self, DeclarativeMCM_OffsetList)
	StorageUtil.IntListClear(self, DeclarativeMCM_IsDependent)
	StorageUtil.IntListClear(self, DeclarativeMCM_HasDependent)
	StorageUtil.IntListClear(self, DeclarativeMCM_IsSynced)
	StorageUtil.StringListClear(self, DeclarativeMCM_PageList)
	StorageUtil.StringListClear(self, DeclarativeMCM_GlobalSyncList)
	StorageUtil.FormListClear(self, DeclarativeMCM_GlobalSyncList)
	StorageUtil.IntListClear(self, DeclarativeMCM_DependencyLHS)
	StorageUtil.IntListClear(self, DeclarativeMCM_DependencyRHS)
	StorageUtil.IntListClear(self, DeclarativeMCM_DependencyType)
	StorageUtil.UnsetStringValue(self, DeclarativeMCM_LogoPath)
	StorageUtil.UnsetFloatValue(self, DeclarativeMCM_LogoX)
	StorageUtil.UnsetFloatValue(self, DeclarativeMCM_LogoY)
EndFunction

; Clear the OID table. MakeUserInterface() will re-populate the table.
Function DeclarativeMCM_ClearOIDs()
	StorageUtil.IntListClear(self, DeclarativeMCM_OIDList)
	StorageUtil.IntListClear(self, DeclarativeMCM_OIDIndices)
	StorageUtil.IntListClear(self, DeclarativeMCM_OIDFlags)
	StorageUtil.StringListClear(self, DeclarativeMCM_OIDInfos)
	StorageUtil.IntListClear(self, DeclarativeMCM_OIDExtras)
	StorageUtil.FloatListClear(self, DeclarativeMCM_OIDExtras)
	StorageUtil.StringListClear(self, DeclarativeMCM_OIDExtras)
	StorageUtil.IntListClear(self, DeclarativeMCM_OIDOffsets)
	StorageUtil.IntListClear(self, DeclarativeMCM_OIDsWithDependencies)
EndFunction

; Turns a string into an index into the variable table.
Int Function DeclarativeMCM_FindVariable(String variable)
	return StorageUtil.StringListFind(self, DeclarativeMCM_VariableList, variable)
EndFunction

; Return false if a variable already exists. Displays an error if the types
; don't match.
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

; Return the index into the variable table for the named variable, or -1 if the
; variable is of the wrong type or doesn't exist.
Int Function DeclarativeMCM_ValidateUI(String variable, Int typecode, Bool warnUndeclared = false)
	Int index = DeclarativeMCM_FindVariable(variable)
	If index == -1
		If warnUndeclared
			DeclarativeMCM_WarnUndeclaredVariable(variable)
		EndIf
		return index
	EndIf
	If StorageUtil.IntListGet(self, DeclarativeMCM_TypeList, index) != typecode
		; Caller already tried to declare it, so fail silently.
		return -1
	EndIf
	return index
EndFunction

; Return the index into the variable table for the named variable, or -1 if the
; variable doesn't exist or is a string (you can't put a string in a global).
Int Function DeclarativeMCM_ValidateSyncToGlobal(String variable, GlobalVariable dest)
	Int index = DeclarativeMCM_ValidateVariableExists(variable)
	If index != -1
		If StorageUtil.IntListGet(self, DeclarativeMCM_TypeList, index) == TYPECODE_STRING
			DeclarativeMCM_WarnCantSync(variable)
			return -1
		ElseIf StorageUtil.IntListGet(self, DeclarativeMCM_IsSynced, index)
			Int syncIndex = StorageUtil.IntListFind(self, DeclarativeMCM_GlobalSyncList, index)
			GlobalVariable originalDest = StorageUtil.FormListGet(self, DeclarativeMCM_GlobalSyncList, syncIndex) as GlobalVariable
			If originalDest != dest
				DeclarativeMCM_WarnMultipleSync(variable)
			EndIf
			return -1
		EndIf
	EndIf
	return index
EndFunction

Int Function DeclarativeMCM_ValidateVariableExists(String variable)
	Int index = DeclarativeMCM_FindVariable(variable)
	If index == -1
		DeclarativeMCM_WarnUndeclaredVariable(variable)
	EndIf
	return index
EndFunction

Bool Function DeclarativeMCM_ValidateDependency(Int leftIndex, Int verb, Int rightIndex)
	If leftIndex == rightIndex
		DeclarativeMCM_WarnCircularDependency(leftIndex)
		return false
	EndIf
	Int i = 0
	Int count = StorageUtil.IntListCount(self, DeclarativeMCM_DependencyLHS)
	While i < count
		If leftIndex == StorageUtil.IntListGet(self, DeclarativeMCM_DependencyLHS, i) && rightIndex == StorageUtil.IntListGet(self, DeclarativeMCM_DependencyRHS, i)
			If StorageUtil.IntListGet(self, DeclarativeMCM_DependencyType, i) != verb
				DeclarativeMCM_WarnIncompatibleDependency(leftIndex, rightIndex)
			EndIf
			return false
		EndIf
		i += 1
	EndWhile
	return true
EndFunction

; Various error messages, which can be silenced by making LocalDevelopment()
; return false.

Function DeclarativeMCM_WarnBadDeclaration(String variable)
	If LocalDevelopment()
		Debug.MessageBox("Warning: Multiple incompatible declarations of variable: " + variable)
	EndIf
EndFunction

Function DeclarativeMCM_WarnIncompatibleDependency(Int leftIndex, Int rightIndex)
	If LocalDevelopment()
		String leftVariable = StorageUtil.GetStringValue(self, DeclarativeMCM_VariableList, leftIndex)
		String rightVariable = StorageUtil.GetStringValue(self, DeclarativeMCM_VariableList, rightIndex)
		Debug.MessageBox("Warning: Multiple incompatible dependencies between " + leftVariable + " and " + rightVariable)
	EndIf
EndFunction

Function DeclarativeMCM_WarnCircularDependency(Int index)
	If LocalDevelopment()
		String variable = StorageUtil.GetStringValue(self, DeclarativeMCM_VariableList, index)
		Debug.MessageBox("Warning: Variable " + variable + " cannot depend on itself.")
	EndIf
EndFunction

Function DeclarativeMCM_WarnMaskOverflow(String variable, Int bit)
	If LocalDevelopment()
		ShowMessage("Warning: Tried to make a mask for bit " + bit + " of " + variable + ", but it only has 32 bits (numbered from 0 to 31).")
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

Function DeclarativeMCM_WarnChoiceNegative(String variable, Int choice)
	If LocalDevelopment()
		ShowMessage("Warning: Tried to add a radio button for choice " + choice + " of enum variable " + variable + ", but negative numbers are not allowed.", false)
	EndIf
EndFunction

Function DeclarativeMCM_WarnEnumTooSmall(String variable, Int choice)
	If LocalDevelopment()
		ShowMessage("Warning: Tried to add a radio button for choice " + choice + " of enum variable " + variable + ", but it does not have that many options.", false)
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

Function DeclarativeMCM_WarnMultipleSync(String variable)
	If LocalDevelopment()
		Debug.MessageBox("Warning: Can't sync variable " + variable + " to more than one global.")
	EndIf
EndFunction

Function DeclarativeMCM_WarnMultipleHoverText()
	If LocalDevelopment()
		ShowMessage("Warning: Tried to attach hover text to option which already has it.")
	EndIf
EndFunction

Function DeclarativeMCM_WarnUndeclaredVariable(String variable)
	If LocalDevelopment()
		Debug.MessageBox("Warning: Variable not declared: " + variable)
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
