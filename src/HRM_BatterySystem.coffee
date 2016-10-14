###
 # =============================================================================
 # Battery System by Hyakka Studio
 # By Geoffrey Chueng <kahogeoff@gmail.com> [Hyakka Studio]
 # HRM_BatterySystem.js
 # Version: 0.1
 # Released under MIT
 # Keep this section when you're using this plugin without any editting
 # =============================================================================
###

###:
 # @plugindesc A simple plugin that allow you to add some control on player movement, or the player action.
 # @author Geoffrey Chueng [Hyakka Studio]
 #
 # @param Icon ID
 # @desc Set the icon ID
 # @default 313
 #
 # @param Maximum capacity
 # @desc The maximum value of battery capacity
 # @default 1000
 #
 # @param Consumption per step
 # @desc The energy value that the player use to walk.
 # @default 1
 #
 # @param Dashing addition
 # @desc The addition value that the player use to dash.
 # @default 2
 #
 # @help
 # ----- Battery System by Hyakka Studio -----
 # Plugin command:
 # 1. Battery drain <number>    => Drain player battery in <number> value
 # 2. Battery recharge <number> => Recharge player battery in <number> value
 # 3. Battery start             => Start draining player battery
 # 4. Battery stop              => Stop draining player battery
 #
 # Functions:
 # 1. GetCurrentBattery()                => Return current remain battery
 # 2. GetCurrentBatteryInPercent()       => Return current remain battery (%)
 #
###

Imported = Imported or {}
Imported['HRM_BatterySystem'] = true

HRM = HRM or {}
HRM.BatterySystem = HRM.BatterySystem or {}

(($) ->

  ###
  # Initialize all private variable
  ###
  _parameters = PluginManager.parameters 'HRM_BatterySystem'

  _iconID = Number _parameters['Icon ID'] or 313

  _maxBattery = Number _parameters['Maximum capacity'] or 1000
  _currentBattery = _maxBattery

  _ePerStep = Number _parameters['Consumption per step'] or 1
  _dashAdd = Number _parameters['Dashing addition'] or 2
  _ePerDash = _ePerStep * _dashAdd

  _willDrainBattery = true

  ###
  # Handle the map scene enter event
  ###
  _Scene_Map_start = Scene_Map::start
  Scene_Map::start = ->
    _Scene_Map_start.call this
    @_windowBattery.show()
    return

  ###
  # Handle the map scene stop event
  ###
  _Scene_Map_stop = Scene_Map::stop
  Scene_Map::stop = ->
    _Scene_Map_stop.call this
    @_windowBattery.hide()
    return
    #console.log 'Map scene stopped'

  ###
  # Handle the map scene update effect
  ###
  _Scene_Map_update = Scene_Map::update
  Scene_Map::update = ->
    _Scene_Map_update.call this
    @_windowBattery.refresh()
    return

  ###
  # Create all HUD window on map scene
  ###
  _Scene_Map_createAllWindows = Scene_Map::createAllWindows
  Scene_Map::createAllWindows = ->
    _Scene_Map_createAllWindows.call this
    @createBatteryWindow()
    return

  ###
  # Create the battery window on map scene
  ###
  Scene_Map::createBatteryWindow = ->
    @_windowBattery = new Window_Battery(0, 0)
    @addWindow @_windowBattery
    return

  ###
  # Handle the player movement event
  ###
  _Game_Player_executeMove = Game_Player::executeMove
  Game_Player::executeMove = (direction) ->
    @moveStraight direction
    if !$gamePlayer.isStopping() and _willDrainBattery
      if $gamePlayer.isDashing()
        DrainBattery _ePerDash
      else
        DrainBattery _ePerStep

    return

  ###
  # The window class that show the battery counter
  ###
  class Window_Battery extends Window_Base

    constructor: (x, y) ->
      @initialize x, y
      return

    initialize: (x, y) ->
      Window_Base::initialize.call this, x, y, @windowWidth(), @windowHeight()
      @_contentsWidth = @contentsWidth()
      @_value = -1
      @refresh()
      return

    refresh: ->
      if @_value != _currentBattery # $gameParty.gold()
        @_value = _currentBattery # $gameParty.gold()
        @_outputText = @_value + "/" + _maxBattery
        @contents.clear()
        @drawIcon _iconID, 0, 0

        # Update the text color
        if GetCurrentBatteryInPercent() > 0.6
          @changeTextColor @textColor(29)
        else
        if (GetCurrentBatteryInPercent() <= 0.6 and
        GetCurrentBatteryInPercent() > 0.3)
          @changeTextColor @textColor(14)
        else if GetCurrentBatteryInPercent() <= 0.3
          @changeTextColor @textColor(10)

        # Draw the bar
        @drawGauge(
          Window_Base._iconWidth + 8,
          0,
          @_contentsWidth - (Window_Base._iconWidth + 8),
          GetCurrentBatteryInPercent(),
          @textColor(10),
          @textColor(29)
          )

        # Draw the text
        @drawText(
          @_outputText,
          Window_Base._iconWidth + 8,
          0,
          @_contentsWidth - (Window_Base._iconWidth + 8),
          'left'
          )
      return

    windowWidth: ->
      250

    windowHeight: ->
      @fittingHeight 1

  ###
  # Create the plugin command
  ###
  _Game_Interpreter_pluginCommand = Game_Interpreter::pluginCommand
  Game_Interpreter::pluginCommand = (command, args) ->
    _Game_Interpreter_pluginCommand.call this
    if command == "Battery"
      switch args[0]
        when "drain"
          _value = Number args[1]
          DrainBattery _value
          break
        when "recharge"
          _value = Number args[1]
          RechargeBattery _value
          break
        when "start"
          StartDrainBattery()
          break
        when "stop"
          StopDrainBattery()
          break
        else
          break
    return

  ###
  # Define the public function
  ###
  DrainBattery = (value) ->
    if _currentBattery - value > 0
      _currentBattery -= value
    else
      _currentBattery = 0

    return

  RechargeBattery = (value) ->
    if _currentBattery + value < _maxBattery
      _currentBattery += value
    else
      _currentBattery = _maxBattery

    return

  GetCurrentBattery = ->
    _currentBattery

  GetCurrentBatteryInPercent = ->
    _currentBattery/_maxBattery

  StartDrainBattery = ->
    _willDrainBattery = true
    return

  StopDrainBattery = ->
    _willDrainBattery = false
    return

  'use strict'

  ###
  # Output the public function
  ###
  $.DrainBattery = DrainBattery
  $.RechargeBattery = RechargeBattery
  $.GetCurrentBattery = GetCurrentBattery
  $.GetCurrentBatteryInPercent = GetCurrentBatteryInPercent
  $.StartDrainBattery = StartDrainBattery
  $.StopDrainBattery = StopDrainBattery
  return
) HRM.BatterySystem
