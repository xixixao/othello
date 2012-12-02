setPositions = ->
  winwidth = $(window).width()
  if winwidth >= 750
    $(".content-secondary").css
      float: "left"
      width: "35%"

    $(".content-primary").css "margin-left": "36%"
  else
    $(".content-secondary").css
      float: "none"
      width: "100%"

    $(".content-primary").css "margin-left": "0px"


$ ->
  socket = io.connect 'http://localhost:3000'
  socket.on 'news', (data) ->
    console.log data
    socket.emit 'my other event', my: 'data'
  i = 0
  $('#send').click ->
    console.log $('#input').val()
    socket.emit 'message event', "Michal", $('#input').val()
    text = ++i
    $l = $("<li class=\"ui-state-default\">"+text+"</li>")
    $('#playerList').append($l)
    $("#draggable").draggable revert: true

    $("#playerList").sortable('refresh');

  $('#playerList').sortable()
  $("#droppable").droppable drop: (event, ui) ->
    $(this).addClass("ui-state-highlight").find("p").html "Dropped!"
    $(this).html "<canvas id=\"OthelloCanvas\" style=\"height:100%;width:100%\"\\>"
    canvas = document.getElementById("OthelloCanvas")
    p = new Processing(canvas, sketchProc)

# attaching the sketchProc function to the canvas


# Simple way to attach js code to the canvas is by using a function
sketchProc = (processing) ->
  # Override draw function, by default it will be called 60 times per second
  processing.size 500, 500 
  boardSize = 8
  o = new Othello boardSize
  o.initialState()
  processing.draw = ->
    # determine center and max clock arm length
    drawCircle = (x, y, color, size) ->
      processing.fill(0, 0, 0) if color == 1
      processing.fill(255, 255, 255) if color == 2
      processing.ellipse(x, y, size, size) unless color == 0 or color == -1
      processing.noFill()
      processing.rect(x-(size+1),y-(size+1),size*2,size*2)

    centerX = processing. width / 2
    centerY = processing.height / 2
    maxArmLength = Math.min(centerX, centerY)
    circleSize = processing.height / (boardSize * 2)
    # erase background
    processing.background 224
    now = new Date()
    for _, x in o.board
      for _, y in o.board[x]
        drawCircle circleSize + processing.width*x/boardSize, processing.height*y/boardSize + circleSize, o.board[x][y], circleSize


# p.exit(); to detach it


class Othello
  OUTSIDE = -1
  EMPTY = 0
  WHITE = 1
  BLACK = 2

  DIRECTIONS = [
    [1, 0]
    [1, 1]
    [0, 1]
    [-1, 1]
    [-1, 0]
    [-1, -1]
    [0, -1]
  ]

  constructor: (@size) ->
    if @size % 2 != 0 or @size < 2
      throw "Invalid size, size must be even and at least 2"
    @createBoard()

  createBoard: ->
    @board = new Array @size
    for _, x in @board
      @board[x] = column = new Array @size
      for _, y in column
        column[y] = EMPTY

  initialState: ->
    middle = @size / 2
    @board[middle - 1][middle - 1] = WHITE
    @board[middle][middle]         = WHITE
    @board[middle - 1][middle]     = BLACK
    @board[middle][middle - 1]     = BLACK
    @nextPlayer = BLACK

  setState: (@nextPlayer, @board) ->

  makeMove: (player, [x, y]) ->
    unless @isEmpty x, y
      return false
    unless @isNextPlayer player
      return false
    changes = []
    point = [x,y]
    for direction in DIRECTIONS
      changes.concat (@makeMoveInDirection direction, player, point, [])
    console.log (changes)


  makeMoveInDirection: (direction, player, pos, moves) ->
    newPos = @add pos direction
    cell = @boardAt newPos
    if cell is EMPTY or cell is OUTSIDE
      []
    else if cell isnt player
      @makeMoveInDirection direction, player, newPos, moves.concat newPos
    else
      moves



  add: ([x, y], [dx, dy]) ->
    [x + dx, y + dy]

  boardAt: ([x, y]) ->
    return OUTSIDE unless (x in [0..@size] and y in [0..@size])
    @board[x][y]

  isEmpty: (x, y) ->
    @board[x][y] == EMPTY

  isNextPlayer: (player) ->
    @nextPlayer == player

  printBoard: ->
    (column.join(" ") for column in @board).join "\n"

