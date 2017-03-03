# RPG-Maker-MV-Plugins
Some open source plugins for RPG Maker MV. Written in CoffeeScript.
Pre-builded version are not aviliable now. ('Cause I don't have time~ :p)

You may also ask for a requirement of plugin in "Issues" section.

## Released plugins
* [Battery System](/src/HRM_BatterySystem.coffee)
  * [Auto recharge addon](/src/HRM_BS_AutoRecharge.coffee)
* [Note System](/src/HRM_NoteSystem.coffee)
* [Core System](/src/HRM_Core.coffee)
* [Custom Key Input](/src/HRM_CustomKeyInput.coffee)

## How to build?
### With `Cakefile`
#### Requirement
  1. [Nodejs](https://nodejs.org/en/) (`npm` is included)
  2. [CoffeeScript](http://coffeescript.org/) (`cake` is included)

Just simply run the `cake build` command on the repo root.

Then you will get a auto-generated folder call `dist` and this is the place of the Javascript files living in~

Or you can run `cake -o /path/to/target/location build` to output in the target location.

### With online compiler (Not Recommand)
  1. Download all the source code
  2. Go to the online compiler website (e.g [JS2Coffee](http://js2.coffee))
  3. Paste the source code and compile in `bare` mode
  4. Copy the compiled code to a new Javascript file in THE SAME NAME.

## Release notes
* 2017-03-01 New scripts
  1. Released "Auto recharge addon" v0.1
  2. Released "Custom Key Input" v0.1

* 2017-02-0? New script and Bug fixed
  1. Released "Core System" v0.1
  2. Fixed the plugin command bug of "Battery System" and "Note System"

* 2017-01-27 Bug fixed
  1. Fixed the plugin command bug of "Battery System"

* 2017-01-26 New features
  1. Added the multi-pages support for "Note System"

* 2017-01-21 Bug fixed
  1. Fixed window location error of "Note System"
  2. Fixed the "New line" error of "Note System"

* 2016-10-14 First release
  1. Released "Battery System" v0.1
  2. Released "Note System" v0.1

## Known bugs
* Cannot be loaded after the "Orange - Time System" By [Hudell](http://www.hudell.com) (Error will cause)
