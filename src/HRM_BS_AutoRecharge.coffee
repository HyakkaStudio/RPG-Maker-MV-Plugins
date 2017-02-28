###
 # =============================================================================
 # Auto Recharge addon for Battery System by Hyakka Studio
 # By Geoffrey Chueng <kahogeoff@gmail.com> [Hyakka Studio]
 # HRM_BS_AutoRecharge.js
 # Version: 0.1
 # Released under MIT
 # Keep this section when you are using this plugin without any editing
 # =============================================================================
###

###:
 # @plugindesc The auto recharge addon for Battery System made by Hyakka Studio
 # @author Geoffrey Chueng [Hyakka Studio]
 #
 # @param Enable auto recharge
 # @desc Set 'true' to start the auto recharge
 # @default false
 #
 # @param Recharging speed
 # @desc How many frame to invoke a recharge action
 # @default 60
 #
 # @param Recharging offset
 # @desc How many frame to wait before recharge
 # @default 40
 #
 # @param Value of each recharge
 # @desc How many battery of every recharge
 # @default 1
 #
 # @help
 #
 #
###

Imported = Imported or {}
Imported['HRM_BS_AutoRecharge'] = true

HRM = HRM or {}
HRM.BatterySystem.AutoRecharge = HRM.BatterySystem.AutoRecharge or {}

if !Imported['HRM_BatterySystem']
  msg = 'Error: This plugin requires \"HRM Battery System\" to work.'
  alert msg
  throw new Error msg

(($) ->
  _Battery = HRM.BatterySystem

  ###
  # Initialize all private variable
  ###
  _parameters = PluginManager.parameters 'HRM_BS_AutoRecharge'

  _isAutoRechargeEnable = _parameters['Enable auto recharge'] == 'true'
  _rechargingSpeed = Number _parameters['Recharging speed'] or 60
  _rechargingOffset = Number _parameters['Recharging offset'] or 40
  _valueToRecharge = Number _parameters['Value of each recharge'] or 1

  _isRecharging = false
  _waitForRecharge = false

  _rechargeOffsetCounter = 0
  _rechargeCounter = 0

  # console.log _isAutoRechargeEnable

  ###
  # Handle the map scene enter event
  ###
  _Scene_Map_start = Scene_Map::start
  Scene_Map::start = ->
    _Scene_Map_start.call this
    EnableAutoRecharge()
    return

  ###
  # Handle the map scene stop event
  ###
  _Scene_Map_stop = Scene_Map::stop
  Scene_Map::stop = ->
    _Scene_Map_stop.call this
    DisableAutoRecharge()
    return

  ###
  # Handle the map scene update effect
  ###
  _Scene_Map_update = Scene_Map::update
  Scene_Map::update = ->
    _Scene_Map_update.call this
    if _isAutoRechargeEnable
      WaitForReacharge()
      if _isRecharging
        if _rechargeCounter < _rechargingSpeed
          _rechargeCounter += 1
        else
          _Battery.RechargeBattery _valueToRecharge
          _rechargeCounter = 0
    return

  ###
  # Handle the player movement event
  ###
  _Game_Player_executeMove = Game_Player::executeMove
  Game_Player::executeMove = (direction) ->
    @moveStraight direction
    _Battery.ExecuteMove()
    if $gamePlayer.isStopping()
      if !_isRecharging
        _waitForRecharge = true if !_waitForRecharge
    else
      _waitForRecharge = false if _waitForRecharge
      _isRecharging = false
      _rechargeOffsetCounter = 0
    return

  WaitForReacharge = ->
    if _rechargeOffsetCounter < _rechargingOffset
      _rechargeOffsetCounter += 1
    else if _rechargeOffsetCounter >= _rechargingOffset
      _isRecharging = true if !_isRecharging
    return

  EnableAutoRecharge = ->
    _isAutoRechargeEnable = true
    return

  DisableAutoRecharge = ->
    _isAutoRechargeEnable = false
    return

  ###
  # Output the public function
  ###
  'use strict'
  $.EnableAutoRecharge = EnableAutoRecharge
  $.DisableAutoRecharge = DisableAutoRecharge

  return
) HRM.BatterySystem.AutoRecharge
