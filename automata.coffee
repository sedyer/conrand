class Conrand

  nodeArray: null
  canvas: null
  drawingContext: null

  #graphics parameters

  canvasheight: 900
  canvaswidth: 900

  #game parameters
  
  tickLength: 100
  initialnodes: 100
  adjacentDistance: 64
  vibration: 4

  constructor: ->
    @createCanvas()
    @seed()
    @tick()

  createCanvas: ->
    @canvas = document.createElement 'canvas'
    document.body.appendChild @canvas
    @canvas.height = @canvasheight
    @canvas.width = @canvaswidth
    @drawingContext = @canvas.getContext '2d'

  seed: ->
    @nodeArray = []

    for node in [0...@initialnodes]
      @nodeArray[node] =
      @createSeedCircle()

  createSeedCircle: ->
    @createCircle(this.canvas.width * Math.random(), this.canvas.height * Math.random(), 2)

  createCircle: (x, y, r) ->
    {
    xPos: x
    yPos: y
    radius: r
    alive: true
    }

  tick: =>

    @evolve()
    @cull()
    @draw()

    setTimeout @tick, @tickLength

  evolve: ->

    newArray = @nodeArray

    for node in @nodeArray

      @vibrate(node, @vibration)
      
      neighbors = @getNeighbors(node, @nodeArray, @adjacentDistance)

      if neighbors.length > 3

          node.alive = false

      else if neighbors.length == 2

        a = @getNeighbors(neighbors[0], @nodeArray, @adjacentDistance).length == 2
        b = @getNeighbors(neighbors[1], @nodeArray, @adjacentDistance).length == 2

        if a and b
          newNode = @thirdNode(node, neighbors[0], (Math.PI / 3))
          newArray.push(newNode)
          newNode = @thirdNode(neighbors[0], neighbors[1], (Math.PI / 3))
          newArray.push(newNode)
          newNode = @thirdNode(neighbors[1], node, (Math.PI / 3))
          newArray.push(newNode)

          # adist = @getDistance(node, neighbors[0])
          # bdist = @getDistance(node, neighbors[1])

          # if adist > bdist
          #   newNode = @thirdNode(node, neighbors[0], Math.PI / 3)
          #   newArray.push(newNode)
          #   node.alive = false
          #   neighbors[1].alive = false
          # else
          #   newNode = @thirdNode(node, neighbors[1], -Math.PI / 3)
          #   newArray.push(newNode)
          #   node.alive = false
          #   neighbors[0].alive = false

      else if neighbors.length == 1

        # newNode = @thirdNode(node, neighbors[0], (Math.random() - 0.5) * 4 * Math.PI)
        # newArray.push(newNode)
      
        a = @getNeighbors(neighbors[0], @nodeArray, @adjacentDistance).length == 1

        if a
          newNode = @thirdNode(node, neighbors[0], (Math.PI / 3))
          newArray.push(newNode)

      else if neighbors.length == 0
        node.alive = false

    @nodeArray.concat(newArray)

  cull: ->

    index = @nodeArray.length - 1

    while (index >= 0)
      if @nodeArray[index].alive is false
        @nodeArray.splice(index, 1)
        index--
      index--

  getDistance: (a, b) ->

    xdiff = b.xPos - a.xPos
    ydiff = b.yPos - a.yPos
    sumOfSquares = Math.pow(xdiff, 2) + Math.pow(ydiff, 2)

    return Math.sqrt(sumOfSquares)

  getNeighbors: (node, array, distance) ->

    neighbors = []

    for x in array
      
        d = @getDistance(node, x)

        if d < distance and d > 1
            neighbors.push x

    return neighbors

  vibrate: (node, factor) ->

    node.xPos = node.xPos + ((Math.random() - 0.5) * 2 * factor)
    node.yPos = node.yPos + ((Math.random() - 0.5) * 2 * factor)

    @rectifyNode node

  rectifyNode: (node) ->

    if node.xPos > @canvas.width
      node.xPos = @canvas.width

    if node.yPos > @canvas.height
      node.yPos = @canvas.height

    if node.xPos < 0
      node.xPos = 0

    if node.yPos < 0
      node.yPos = 0

  thirdNode: (node, pivot, theta) ->

    s = Math.sin(theta)
    c = Math.cos(theta)

    tX = node.xPos - pivot.xPos
    tY = node.yPos - pivot.yPos

    newX = (tX * c) - (tY * s)
    newY = (tX * s) + (tY * c)

    newX = newX + pivot.xPos
    newY = newY + pivot.yPos

    newCircle = @createCircle(newX, newY, node.radius)
    @rectifyNode newCircle

    return newCircle

  draw: ->
    
    @drawingContext.clearRect(0, 0, @canvas.width, @canvas.height)

    for node in @nodeArray
      @drawConnections(node, @nodeArray, @adjacentDistance)

    for node in @nodeArray
      @drawCircle node

  drawConnections: (node, array, distance) ->

    neighbors = @getNeighbors(node, array, distance)
    context = @drawingContext
    context.lineWidth = 1
    context.strokeStyle = 'rgb(242, 198, 65)'

    for x in neighbors
      if x.alive is true
        context.strokeStyle = 'rgb(242, 198, 65)'
      else
        context.strokeStyle = 'grey'

      context.beginPath()
      context.moveTo(node.xPos, node.yPos)
      context.lineTo(x.xPos, x.yPos)
      context.stroke()

  drawCircle: (circle) ->
    if circle.alive is true
      @drawingContext.fillStyle = 'white'
    else
      @drawingContext.fillStyle = 'grey'

    @drawingContext.lineWidth = 2
    @drawingContext.strokeStyle = 'rgba(242, 198, 65, 0.1)'
    @drawingContext.beginPath()
    @drawingContext.arc(circle.xPos, circle.yPos, circle.radius, 0, 2 * Math.PI, false)
    @drawingContext.fill()
    @drawingContext.stroke()

window.Conrand = Conrand