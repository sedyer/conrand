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
  isolationThreshold: 1
  isolationDeadliness: 0.5
  overcrowdingThreshold: 4
  overcrowdingDeadliness: 0.5
  adjacentDistance: 30
  minimumDistance: 15

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
    xPos: x
    yPos: y
    radius: r
    alive: true

  tick: =>

    @evolve()
    @cull()
    @draw()

    setTimeout @tick, @tickLength

  evolve: ->

    newArray = @nodeArray

    for node in newArray
      
      neighbors = @getNeighbors(node, newArray, @adjacentDistance)

      if neighbors.length == 2

        @reflectTriangle(node, newArray, neighbors)

      if neighbors.length == 1

        @buildTriangle(node, neighbors[0], newArray)

      @wiggle(node)

    @nodeArray = newArray

  cull: ->

    newArray = @nodeArray

    for node in newArray

      neighbors = @getNeighbors(node, newArray, @adjacentDistance)

      if neighbors.length < @isolationThreshold
        if Math.random() < @isolationDeadliness
          node.alive = false

      if neighbors.length > @overcrowdingThreshold
        if Math.random() < @overcrowdingThreshold
          node.alive = false

    index = newArray.length - 1

    while (index >= 0)
      if newArray[index].alive is false
        newArray.splice(index, 1)
        index--
      index--

    @nodeArray = newArray

  getDistance: (a, b) ->

    xdiff = b.xPos - a.xPos
    ydiff = b.yPos - a.yPos
    sumOfSquares = Math.pow(xdiff, 2) + Math.pow(ydiff, 2)

    return Math.sqrt(sumOfSquares)

  getNeighbors: (node, array, distance) ->

    neighbors = []

    for x in array

        d = @getDistance(node, x)

        if d < distance and d > 0
            neighbors.push x

    return neighbors

  wiggle: (node) ->

    node.xPos = node.xPos + ((Math.random() - 0.5) * 8)
    node.yPos = node.yPos + ((Math.random() - 0.5) * 8)

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

  buildTriangle: (a, b, array) ->

    theta = 60

    if Math.random() < 0.5
      theta = 300

    newX = Math.cos(theta) * (a.xPos - b.xPos) - Math.sin(theta) * (a.yPos - b.yPos) + b.xPos

    newY = Math.sin(theta) * (a.xPos - b.xPos) + Math.cos(theta) * (a.yPos - b.yPos) + b.yPos

    newCircle = @createCircle(newX, newY, a.radius)
    @rectifyNode newCircle
    array.push newCircle

  reflectTriangle: (node, array, neighbors) ->

      dist = @getDistance(neighbors[0], neighbors[1])

      theta = Math.atan(
        (neighbors[0].xPos - neighbors[0].yPos) / (neighbors[1].xPos - neighbors[1].yPos)
        ) * (180 / Math.PI)

      if neighbors[0].yPos < neighbors[1].yPos
        theta = theta + 30
      else
        theta = theta - 30

      node.xPos = neighbors[0].xPos + (dist * Math.cos(theta))
      node.yPos = neighbors[0].yPos + (dist * Math.sin(theta))

      @rectifyNode node

  draw: ->
    
    @drawingContext.clearRect(0, 0, @canvas.width, @canvas.height)

    for node in @nodeArray
      if node.alive is true
        @drawConnections(node, @nodeArray, @adjacentDistance)

    for node in @nodeArray
      if node.alive is true
        @drawCircle node

  drawConnections: (node, array, distance) ->

    neighbors = @getNeighbors(node, array, distance)
    context = @drawingContext
    context.lineWidth = 1
    context.strokeStyle = 'rgb(242, 198, 65)'

    for x in neighbors
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