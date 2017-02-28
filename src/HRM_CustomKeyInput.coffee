###
 # =============================================================================
 # Custom Key Input by Hyakka Studio
 # By Geoffrey Chueng <kahogeoff@gmail.com> [Hyakka Studio]
 # HRM_CustomKeyInput.js
 # Version: 0.1
 # Released under MIT
 # Keep this section when you are using this plugin without any editing
 # =============================================================================
###

###:
 # @plugindesc A simple plugin that help you custom your own keyboard input
 # @author Geoffrey Chueng [Hyakka Studio]
 #
 # @param Custom keys (Keyboard)
 # @desc Each key-action pair split with ';', key code and action split with ':'
 # @default 0:nothing
 #
 # @help
 #
 #
###

Imported = Imported or {}
Imported['HRM_CustomKeyInput'] = true

HRM = HRM or {}
HRM.CustomKeyInput = HRM.CustomKeyInput or {}

(($) ->
  ###
  # Initialize all private variable
  ###
  _parameters = PluginManager.parameters 'HRM_CustomKeyInput'

  _rawKeyActionPair = _parameters['Custom keys'] or ''
  _regexValue = /([^\D]+):([^;]+)/ig
  _match = _regexValue.exec _rawKeyActionPair
  # _customKeyList = {}
  while _match != null
    Input.keyMapper[_match[1]] = _match[2]
    _match = _regexValue.exec _rawKeyActionPair

  ###
  # Output the public function
  ###
  'use strict'
  return
) HRM.CustomKeyInput
