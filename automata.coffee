class Conrand
  nodeArray: null
  canvasheight: 400
  canvaswidth: 400
  initialnodes: 500
  adjacentDistance: 20
  tickLength: 100
  canvas: null
  drawingContext: null

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

  drawCircle: (circle) ->

    @drawingContext.lineWidth = 2
    @drawingContext.strokeStyle = 'rgba(242, 198, 65, 0.1)'
    @drawingContext.fillStyle = 'white'
    @drawingContext.beginPath()
    @drawingContext.arc(circle.xPos, circle.yPos, circle.radius, 0, 2 * Math.PI, false)
    @drawingContext.fill()
    @drawingContext.stroke()

  drawConnections: (node, array, distance) ->

    neighbors = getNeighbors(node, array, distance)
    context = @drawingContext
    context.lineWidth = 2
    context.strokeStyle = 'rgb(242, 198, 65)'

    for x in neighbors
      context.beginPath()
      context.moveTo(node.xPos, node.yPos)
      context.lineTo(x.xPos, x.yPos)
      context.stroke()

  createCircle: (x, y, r) ->
    xPos: x
    yPos: y
    radius: r
    alive: true
  
  createSeedCircle: ->
    @createCircle(this.canvas.width * Math.random(), this.canvas.height * Math.random(), 2)

  seed: ->
    @nodeArray = []

    for node in [0...@initialnodes]
      @nodeArray[node] =
      @createSeedCircle()

  draw: ->
    for node in @nodeArray
      if node.alive is true
        @drawConnections(node, @nodeArray, @adjacentDistance)

    for node in @nodeArray
      if node.alive is true
        @drawCircle node

  getDistance = (a, b) ->

    xdiff = b.xPos - a.xPos
    ydiff = b.yPos - a.yPos
    sumOfSquares = Math.pow(xdiff, 2) + Math.pow(ydiff, 2)

    return Math.sqrt(sumOfSquares)

  getNeighbors = (node, array, distance) ->

    neighbors = []

    for x in array

        d = getDistance(node, x)

        if d < distance
            neighbors.push x

    return neighbors


  countNeighbors = (node, array, distance) ->
    
    count = 0

    for x in array

        d = getDistance(node, x)

        if d < distance
            count++

    return count

  tick: =>

    @drawingContext.clearRect(0, 0, this.canvas.width, this.canvas.height)

    @draw()
    @evolve()
    @cull()

    setTimeout @tick, @tickLength

  evolve: ->

    newArray = @nodeArray

    for node in @nodeArray

      neighborCount = countNeighbors(node, @nodeArray, @adjacentDistance)

      if neighborCount is 2
        @reproduce(node, newArray)
    
    @nodeArray = newArray

  cull: ->

    newArray = @nodeArray

    for node in newArray

      neighborCount = countNeighbors(node, newArray, @adjacentDistance)

      if neighborCount is 1
        if Math.random() < 0.50
          node.alive = false

      if neighborCount > 3
        if Math.random() < 0.50
          node.alive = false

    index = newArray.length - 1

    while (index >= 0)
      if newArray[index].alive is false
        newArray.splice(index, 1)
        index--
      index--

    @nodeArray = newArray

  reproduce: (node, array) ->

    newX = node.xPos + (Math.random() - 0.5) * @adjacentDistance * 10
    newY = node.yPos + (Math.random() - 0.5) * @adjacentDistance * 10

    if newX > this.canvas.width
      newX = this.canvas.width

    if newY > this.canvas.height
      newY = this.canvas.height

    if newX < 0
      newX = 0

    if newY < 0
      newY = 0

    newCircle = @createCircle(newX, newY, node.radius)
    array.push newCircle

window.Conrand = Conrand