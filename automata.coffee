class Conrand

  nodeArray: null
  canvas: null
  drawingContext: null

  #graphics parameters

  canvasheight: 400
  canvaswidth: 400

  #game parameters
  
  tickLength: 100
  initialnodes: 300
  isolationThreshold: 2
  isolationDeadliness: 0.5
  reproductionCount: 3
  overcrowdingThreshold: 10
  overcrowdingDeadliness: 0.5
  adjacentDistance: 40

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
    context.lineWidth = 1
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

    @evolve()
    @cull()

    @drawingContext.clearRect(0, 0, this.canvas.width, this.canvas.height)
    @draw()

    setTimeout @tick, @tickLength

  evolve: ->

    newArray = @nodeArray

    for node in @nodeArray
      if node.alive is true

        neighbors = getNeighbors(node, newArray, @adjacentDistance)

        neighbors = neighbors.filter((x) -> getDistance(x, node) > 0)

        if neighbors.length > 3

          @migrate(node, newArray)

        if neighbors.length == 2

          @reflectTriangle(node, newArray, neighbors)

        if neighbors.length == 1

          @buildTriangle(node, newArray, neighbors[0])
    
    @nodeArray = newArray

  cull: ->

    newArray = @nodeArray

    for node in newArray

      neighborCount = countNeighbors(node, newArray, @adjacentDistance)

      if neighborCount < @isolationThreshold
        if Math.random() < @isolationDeadliness
          node.alive = false

      if neighborCount > @overcrowdingThreshold
        if Math.random() < @overcrowdingThreshold
          node.alive = false

    index = newArray.length - 1

    while (index >= 0)
      if newArray[index].alive is false
        newArray.splice(index, 1)
        index--
      index--

    @nodeArray = newArray

  migrate: (node, array) ->

    newX = node.xPos + ((Math.random() - 0.5) * 2 * (@adjacentDistance / 2))
    newY = node.yPos + ((Math.random() - 0.5) * 2 * (@adjacentDistance / 2))

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

    node.alive = false

  buildTriangle: (node, array, neighbor) ->

    newX = neighbor.xPos + ((Math.random() - 0.5) * 2 * (@adjacentDistance / 2))
    newY = neighbor.yPos + ((Math.random() - 0.5) * 2 * (@adjacentDistance / 2))

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

  reflectTriangle: (node, array, neighbors) ->

      xDiffs = ((x.xPos - node.xPos) for x in neighbors)
      yDiffs = ((x.yPos - node.yPos) for x in neighbors)

      newX = 0
      newY = 0

      if Math.abs(xDiffs[0]) > Math.abs(xDiffs[1])
        newX = node.xPos + xDiffs[0] + ((Math.random() - 0.5) * 2 * (@adjacentDistance / 2))
      else
        newX = node.xPos + xDiffs[1] + ((Math.random() - 0.5) * 2 * (@adjacentDistance / 2))

      if Math.abs(yDiffs[0]) > Math.abs(yDiffs[1])
        newY = node.yPos + yDiffs[0] + ((Math.random() - 0.5) * 2 * (@adjacentDistance / 2))
      else
        newY = node.yPos + yDiffs[1] + ((Math.random() - 0.5) * 2 * (@adjacentDistance / 2))

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

      node.alive = false

window.Conrand = Conrand