###
 # =============================================================================
 # Note System by Hyakka Studio
 # By Geoffrey Chueng <kahogeoff@gmail.com> [Hyakka Studio]
 # HRM_NoteSystem.js
 # Version: 0.1
 # Released under MIT
 # =============================================================================
###

###:
 # @plugindesc A simple note system.
 # @author Geoffrey Chueng [Hyakka Studio]
 #
 # @param Window height
 # @desc Height of the note window
 # @default 380
 #
 # @param List width
 # @desc Width of the note list panel
 # @default 240
 #
 # @param Detail width
 # @desc Width of the note Detail panel
 # @default 320
 #
 # @help
 # ----- Note System by Hyakka Studio -----
 #
 # REMINDER: This plugin support some short note ONLY.
 #
 # Plugin command:
 # 1. Notebook open
 #    => Open the notebook window
 # 2. Notebook add <title> <content>
 #    => Add a note to notebook
 #
###

Imported = Imported or {}
Imported['HRM_NoteSystem'] = true

HRM = HRM or {}
HRM.NoteSystem = HRM.NoteSystem or {}

$gameNotes = []
(($) ->
  ###
  # Initialize all private variable
  ###
  _parameters = PluginManager.parameters 'HRM_NoteSystem'

  _windowHeight = Number _parameters['Window height'] or 380

  _listWidth = Number _parameters['List width'] or 240
  _detailWidth = Number _parameters['Detail width'] or 320

  ###
  # Create the plugin command
  ###
  _Game_Interpreter_pluginCommand = Game_Interpreter::pluginCommand
  Game_Interpreter::pluginCommand = (command, args) ->
    _Game_Interpreter_pluginCommand.call this
    if command == "Notebook"
      switch args[0]
        when 'open'
          EnterScene()
          break
        when 'add'
          AddNote args[1], args[2]
          break
        else
          break
    return

  ###
  # The scene class of the notebook
  ###
  class Scene_Notes extends Scene_MenuBase

    constructor: ->
      @initialize()
      return

    initialize: ->
      Scene_MenuBase::initialize.call this
      return

    start: ->
      Scene_MenuBase::start.call this
      @_windowNoteList.x = (
        Graphics.boxWidth
        - @_windowNoteDetail.width
        - @_windowNoteList.width) / 2
      @_windowNoteDetail.x = @_windowNoteList.x + @_windowNoteList.width
      return

    create: ->
      Scene_MenuBase::create.call this
      @createNoteListWindow()
      @createNoteDetailWindow()
      return

    update: ->
      Scene_MenuBase::update.call this
      return

    createNoteListWindow: ->
      @_windowNoteList = new Window_NoteList()
      @_windowNoteList.setHandler 'noteDetail', @showNoteDetail.bind(this)
      @_windowNoteList.setHandler 'cancel', @popScene.bind(this)
      @addWindow @_windowNoteList
      return

    createNoteDetailWindow: ->
      @_windowNoteDetail = new Window_NoteDetail()
      @_windowNoteDetail.setHandler 'cancel', @deactivateNoteDetail.bind(this)
      @addWindow @_windowNoteDetail
      return

    showNoteDetail: ->
      currentId = @_windowNoteList._lastIndex
      @_windowNoteDetail.setDisplayText($gameNotes[currentId].content)
      @_windowNoteDetail.refresh()
      @_windowNoteDetail.activate()
      return

    deactivateNoteDetail: ->
      @_windowNoteDetail.setDisplayText('')
      @_windowNoteDetail.refresh()
      @_windowNoteList.activate()
      return

  ###
  # The window class for the note list
  ###
  class Window_NoteList extends Window_Command
    _lastIndex: 0

    constructor: ->
      @initialize()
      return

    initialize: ->
      Window_Command::initialize.call this, 0, 0
      @select @_lastIndex
      @updatePlacement()
      @openness = 0
      @open()
      return

    windowWidth: ->
      _listWidth

    windowHeight: ->
      _windowHeight

    updatePlacement: ->
      @x = (Graphics.boxWidth - @width) / 2
      @y = (Graphics.boxHeight - @height) / 2
      return

    makeCommandList: ->
      for n in $gameNotes
        @addCommand n.title, 'noteDetail'
      return

    updateCursor: ->
      Window_Command::updateCursor.call this
      @_lastIndex = @index()
      return

  ###
  # The window class for the detail of note
  ###
  class Window_NoteDetail extends Window_Base
    _displayText: ''
    _handlers: {}
    _textState: {lines: 0, text: ''}
    # _canScroll: false

    constructor: ->
      @initialize()
      return

    initialize: ->
      Window_Base::initialize.call this, 0, 0, @windowWidth(), @windowHeight()
      @updatePlacement()
      @refresh() if $gameNotes.length > 0
      # @downArrowVisible = true
      @openness = 0
      @open()
      return

    windowWidth: ->
      _detailWidth

    windowHeight: ->
      _windowHeight

    updatePlacement: ->
      @x = (Graphics.boxWidth - @width) / 2
      @y = (Graphics.boxHeight - @height) / 2
      return

    setDisplayText: (text) ->
      # @_displayText = text
      @_textState['text'] = ''
      @_textState['lines'] = 1
      tmp_line = ''
      for c in text.split('')
        if @textWidth(tmp_line + c) > @contentsWidth()
          tmp_line += '\n'
          @_textState['text'] += tmp_line
          tmp_line = c
          @_textState['lines'] += 1
        else
          tmp_line += c

      @_textState['text'] += tmp_line
      return

    displayText: (text) ->
      @drawTextEx text, 0, 0
      return

    refresh: ->
      @contents.clear()
      @displayText @_textState['text']
      return

    update: ->
      Window_Base::update.call this
      @processHandling()
      return

    ###
    # Copy from Window_Selectable
    ###
    processHandling: ->
      if @isOpenAndActive()
        if @isHandled('cancel') and Input.isTriggered('cancel')
          @processCancel()
        # else if @isHandled('pagedown') and Input.isTriggered('pagedown')
        #   @processPagedown()
        # else if @isHandled('pageup') and Input.isTriggered('pageup')
        #   @processPageup()
      return

    processCancel: ->
      SoundManager.playCancel()
      @updateInputData()
      @deactivate()
      @callHandler('cancel')
      return

    updateInputData: ->
      Input.update()
      TouchInput.update()
      return

    isOpenAndActive: ->
      return @isOpen() && @active

    setHandler: (symbol, method) ->
      @_handlers[symbol] = method
      return

    isHandled: (symbol) ->
      return !!this._handlers[symbol]

    callHandler: (symbol) ->
      if (@isHandled(symbol))
        @_handlers[symbol]()
      return

  EnterScene = ->
    SceneManager.push Scene_Notes
    return

  AddNote = (title, content) ->
    _tmpNote = {}
    _tmpNote["title"] = String title
    _tmpNote["content"] = String content
    $gameNotes.push _tmpNote
    return

  'use strict'
  $.EnterNoteScene = EnterScene
  $.AddNote = AddNote

  return
) HRM.NoteSystem
