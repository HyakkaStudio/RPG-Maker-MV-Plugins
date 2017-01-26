###
 # =============================================================================
 # Note System by Hyakka Studio
 # By Geoffrey Chueng <kahogeoff@gmail.com> [Hyakka Studio]
 # HRM_NoteSystem.js
 # Version: 0.2
 # Released under MIT
 # Keep this section when you're using this plugin without any editing
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
 # @param Font size
 # @desc Size of the font
 # @default 36
 #
 # @help
 # ----- Note System by Hyakka Studio -----
 #
 # REMINDER: This plugin support some note ONLY.
 #
 # How to switch the pages:
 # By default you can switch the pages by 'Page Down(W)' and 'Page Up(Q)' key.
 #
 # Plugin command:
 # 1. Notebook open
 #    => Open the notebook window
 # 2. Notebook add <title> <content>
 #    => Add a note to notebook
 #
 # Functions:
 # 1. EnterNoteScene()                => Enter the notebook scene
 # 2. AddNote(title, content)         => Add note to notebook (For mulitple lines content)
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
  _fontSize = Number _parameters['Font size'] or 36

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
  class SceneNotes extends Scene_MenuBase

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
        - (@_windowNoteDetail.width
        - @_windowNoteList.width)) / 2
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
      @_windowNoteList = new WindowNoteList()
      @_windowNoteList.setHandler 'noteDetail', @showNoteDetail.bind(this)
      @_windowNoteList.setHandler 'cancel', @popScene.bind(this)
      @addWindow @_windowNoteList
      return

    createNoteDetailWindow: ->
      @_windowNoteDetail = new WindowNoteDetail()
      @_windowNoteDetail.setHandler 'pagedown', @nextPageOfNote.bind(this)
      @_windowNoteDetail.setHandler 'pageup', @previousPageOfNote.bind(this)
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
      @_windowNoteDetail.contents.clear()
      @_windowNoteList.activate()
      return

    nextPageOfNote: ->
      @_windowNoteDetail.processPagedown()
      return

    previousPageOfNote: ->
      @_windowNoteDetail.processPageup()
      return

  ###
  # The window class for the note list
  ###
  class WindowNoteList extends Window_Command
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
  class WindowNoteDetail extends Window_Base
    _displayText: ''
    _handlers: {}
    _currentPage: 0
    _textState: {totalPages: 0, content: []}

    constructor: ->
      @initialize()
      return

    initialize: ->
      Window_Base::initialize.call this, 0, 0, @windowWidth(), @windowHeight()
      @updatePlacement()
      @refresh() if $gameNotes.length > 0 and @_textState['content'].length > 0
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
      console.log @x
      @y = (Graphics.boxHeight - @height) / 2
      return

    setDisplayText: (text) ->
      # @_displayText = text
      @_textState['content'] = []
      @_textState['totalPages'] = 0
      tmp_line = ''
      tmp_page = {lines: 0, text: ''}
      font_height = _fontSize

      for c in text.split('')
        tmp_line += c
        if c == '\n'
          if (tmp_page['lines']+1) * font_height > @contentsHeight()
            @_textState['content'].push tmp_page
            @_textState['totalPages'] += 1

            tmp_page = {lines: 0, text: ''}
            tmp_page['lines'] += 1
          else
            tmp_page['text'] += tmp_line
            tmp_page['lines'] += 1
          tmp_line = ''
        else if @textWidth(tmp_line) > @contentsWidth()
          tmp_line = tmp_line.slice(0, -1) + '\n'
          if (tmp_page['lines']+1) * font_height > @contentsHeight()
            @_textState['content'].push tmp_page
            @_textState['totalPages'] += 1

            tmp_page = {lines: 0, text: ''}
            tmp_page['text'] += tmp_line
            tmp_page['lines'] += 1
          else
            tmp_page['text'] += tmp_line
            tmp_page['lines'] += 1
          tmp_line = ''

      tmp_page['text'] += tmp_line
      tmp_page['lines'] += 1
      @_textState['content'].push tmp_page
      @_textState['totalPages'] += 1

      return

    displayText: (text) ->
      @drawTextEx text, 0, 0
      return

    refresh: ->
      @contents.clear()
      if @_textState['totalPages'] > 1
        @downArrowVisible = @_currentPage < @_textState['totalPages'] - 1
        @upArrowVisible = @_currentPage > 0

      _tmpData = @_textState['content']
      @displayText _tmpData[@_currentPage]['text']
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
        else if @isHandled('pagedown') and Input.isTriggered('pagedown')
          @processPagedown()
        else if @isHandled('pageup') and Input.isTriggered('pageup')
          @processPageup()
      return

    processCancel: ->
      SoundManager.playCancel()
      @updateInputData()
      @deactivate()
      @callHandler('cancel')
      return

    processPagedown: ->
      if @_currentPage + 1 < @_textState['totalPages']
        SoundManager.playCursor()
        @_currentPage += 1
        @refresh()
      else
        SoundManager.playBuzzer()
      return

    processPageup: ->
      if @_currentPage - 1 > -1
        SoundManager.playCancel()
        @_currentPage -= 1
        @refresh()
      else
        SoundManager.playBuzzer()
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
    SceneManager.push SceneNotes
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
