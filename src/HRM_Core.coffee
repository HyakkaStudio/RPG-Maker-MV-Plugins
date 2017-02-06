###
 # =============================================================================
 # Core System by Hyakka Studio
 # By Geoffrey Chueng <kahogeoff@gmail.com> [Hyakka Studio]
 # HRM_Core.js
 # Version: 0.1
 # Released under MIT
 # Keep this section when you are using this plugin without any editing
 # =============================================================================
###

###:
 # @plugindesc The core system for any script the created by Hyakka Studio.
 # @author Geoffrey Chueng [Hyakka Studio]
 #
 # @help
 # ----- Core System by Hyakka Studio -----
 #
 # REMINDER: This plugin must be loaded after any other HRM Script.
###

Imported = Imported or {}
Imported['HRM_Core'] = true

HRM = HRM or {}
HRM.Core = HRM.Core or {}

(($) ->
  _Note = HRM.NoteSystem
  _Battery = HRM.BatterySystem

  ###
  # Create the plugin command
  ###
  _Game_Interpreter_pluginCommand = Game_Interpreter::pluginCommand
  Game_Interpreter::pluginCommand = (command, args) ->
    _Game_Interpreter_pluginCommand.call this

    ###
    # Enable the plugin commands if "NoteSystem" has been loaded
    ###
    if Imported['HRM_NoteSystem'] and command == "Notebook"
      switch args[0]
        when 'open'
          _Note.EnterNoteScene()
          break
        when 'add'
          _Note.AddNote args[1], args[2]
          break
        else
          break

    ###
    # Enable the plugin commands if "BatterySystem" has been loaded
    ###
    if Imported['HRM_BatterySystem'] and command == "Battery"
      switch args[0]
        when 'drain'
          _value = Number args[1]
          _Battery.DrainBattery _value
          break
        when 'recharge'
          _value = Number args[1]
          _Battery.RechargeBattery _value
          break
        when 'start'
          _Battery.StartDrainBattery()
          break
        when 'stop'
          _Battery.StopDrainBattery()
          break
        else
          break
    return

  'use strict'
  return
) HRM.Core
