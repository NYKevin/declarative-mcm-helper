Declarative MCM Helper is a library for writing SkyUI MCM menus with less
boilerplate than the official MCM API. You can see a code sample in the file
ExampleDeclarativeMCM.psc, which demos some, but not all, of the functionality
which this library supports. For more complete API documentation, consult the
comments in DeclarativeMCMHelper.psc.

## FAQ

### I'm a mod user, not a mod developer, and what is this?

It's a tool for mod developers to create MCM menus. If you're not a mod
developer, you don't need it.

### Should I actually use this?

Maybe. You should seriously consider using [MCM Helper][1] instead, since
there's actually a pretty good chance that it's a better fit for your needs.
Broadly speaking, here are the important differences:

* MCM Helper is a totally new way of implementing MCM menus. Declarative MCM
  Helper is designed to be similar to the "normal" way of writing an MCM menu,
  but with less typing.
* MCM Helper puts the user's settings into INI files. Declarative MCM Helper
  provides convenience functions for traditional "save/load settings" buttons,
  but settings otherwise live in the user's save.
* MCM Helper has its own SKSE extension for accessing settings from Papyrus.
  Declarative MCM Helper relies on PapyrusUtil for this functionality.
* There are slight differences in the UI elements which each library supports.

More importantly, you should be aware that **Declarative MCM Helper does not
have a stable release.** For my own (unreleased) mods, it seems to work just
fine, but I cannot promise that it will work for your mod.

### Is this a ripoff of MCM Helper?

No. [MCM Helper][1] is a fantastic mod, which you should seriously consider
using if it fits your needs. However, it works very differently to Declarative
MCM Helper. They are two totally unrelated mods, that happen to have similar
names.

### Why did you steal their name?

They don't own a monopoly on the phrase "MCM Helper." Jaxonz was using that name
[in 2015][2] for a very similar concept. The word "Helper" is simply too generic
to uniquely identify a mod.

Also, nobody is paying me enough to go through and rename all of my functions
etc. to avoid colliding with a *newer* mod that didn't even exist when I started
writing this code.

### But yours is less declarative than theirs!

This code is quite old, and at the time, I felt that my design was more
declarative than the standard MCM API.

### Anniversary Edition?

I haven't tested it, but because it only relies on PapyrusUtil, which is now
[available for AE][3], it should work just fine.

### Where's the .pex file?

You have to compile it yourself. While you're doing that, you should also vendor
the library. Follow the instructions in DeclarativeMCMHelper.psc.

### Vendoring is evil! Why are you encouraging people to do it?

Because:

* The person best equipped to decide whether to update to a newer version of
  DeclarativeMCMHelper is the mod developer, not the end user.
* DeclarativeMCMHelper does not implement a security boundary, and cannot
  plausibly have security vulnerabilities which would need to be patched.
* Papyrus does not support variable shadowing, and so it is nearly impossible
  to guarantee perfect backwards compatibility.
* Thanks to tools like [Champollion][4], more adventurous users can always get
  the source code and evaluate whether it is up-to-date on their own. So I'm not
  taking any signiciant amount of power away from the end user.
* Declarative MCM Helper is specifically designed to coexist with other
  instances of itself, as long as they're attached to different quests.

### What do I put in DeclareVariables()?

Initialization code, primarily calls to DeclareFoo() functions, but also any
logic which would normally go in OnConfigInit() or OnVersionUpdate().

You should assume that this function may be called multiple times, and make sure
you don't do anything that will break if it gets called twice. The DeclareFoo()
functions are all safe to call multiple times.

### What do I put in MakeUserInterface()?

Whatever you would normally put in OnPageReset(), but you can use the MakeFoo()
functions to add fully-interactive user interface elements with less hassle.

### Does this play well with the ST functions in the MCM API?

I have no idea. Test it and let me know. In general, DeclarativeMCMHelper
pretends that the ST API doesn't exist, and does not call GetState() or
GotoState() at all, so there is no obvious reason this should not work.

### Should I override OnOptionHighlight() to set custom hover text?

No, you shouldn't. Instead:

* For MakeFoo() UI elements from Declarative MCM Helper, there's an argument for
  hover text.
* For AddFooOption() UI elements from the MCM API, call SetHoverText().
* For AddFooOptionST() UI elements from the MCM's state-based API, you have to
  override OnOptionHighlightST() instead.

### What if I need to run extra code when the user clicks something?

Override Validate() and ValidateAll(). Make sure to return true, unless you
really want to deny the variable change!

If you really need finer-grained control than that, you can override the regular
MCM events, but you will usually need to call Parent.NameOfEvent() to make sure
that Declarative MCM Helper's logic does not break. You don't need to do this
for ST events, however.

### What do I put in SaveExtraData()/LoadExtraData()?

If the user has any preferences which are *not* stored in a declared variable (a 
variable which you declared with one of the DeclareFoo() functions), then you
can save and load those preferences here. If not, then you can ignore these
functions.

### What's a "generic button?"

A generic button is a button that does something when the user clicks it.
Specifically, it calls OnGenericButton() with the argument you pass. If you set
latent=true (the default), then it first waits for the user to unpause the game.

[1]: https://www.nexusmods.com/skyrimspecialedition/mods/53000
[2]: https://www.nexusmods.com/skyrim/mods/62613
[3]: https://www.nexusmods.com/skyrimspecialedition/mods/13048?tab=description
[4]: https://www.nexusmods.com/skyrim/mods/35307