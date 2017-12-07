// Generated by CoffeeScript 2.0.2
(function() {
  var Conrand;

  Conrand = (function() {
    var countNeighbors, getDistance, getNeighbors;

    class Conrand {
      constructor() {
        this.tick = this.tick.bind(this);
        this.createCanvas();
        this.seed();
        this.tick();
      }

      createCanvas() {
        this.canvas = document.createElement('canvas');
        document.body.appendChild(this.canvas);
        this.canvas.height = this.canvasheight;
        this.canvas.width = this.canvaswidth;
        return this.drawingContext = this.canvas.getContext('2d');
      }

      drawCircle(circle) {
        this.drawingContext.lineWidth = 2;
        this.drawingContext.strokeStyle = 'rgba(242, 198, 65, 0.1)';
        this.drawingContext.fillStyle = 'white';
        this.drawingContext.beginPath();
        this.drawingContext.arc(circle.xPos, circle.yPos, circle.radius, 0, 2 * Math.PI, false);
        this.drawingContext.fill();
        return this.drawingContext.stroke();
      }

      drawConnections(node, array, distance) {
        var context, i, len, neighbors, results, x;
        neighbors = getNeighbors(node, array, distance);
        context = this.drawingContext;
        context.lineWidth = 1;
        context.strokeStyle = 'rgb(242, 198, 65)';
        results = [];
        for (i = 0, len = neighbors.length; i < len; i++) {
          x = neighbors[i];
          context.beginPath();
          context.moveTo(node.xPos, node.yPos);
          context.lineTo(x.xPos, x.yPos);
          results.push(context.stroke());
        }
        return results;
      }

      createCircle(x, y, r) {
        return {
          xPos: x,
          yPos: y,
          radius: r,
          alive: true
        };
      }

      createSeedCircle() {
        return this.createCircle(this.canvas.width * Math.random(), this.canvas.height * Math.random(), 2);
      }

      seed() {
        var i, node, ref, results;
        this.nodeArray = [];
        results = [];
        for (node = i = 0, ref = this.initialnodes; 0 <= ref ? i < ref : i > ref; node = 0 <= ref ? ++i : --i) {
          results.push(this.nodeArray[node] = this.createSeedCircle());
        }
        return results;
      }

      draw() {
        var i, j, len, len1, node, ref, ref1, results;
        ref = this.nodeArray;
        for (i = 0, len = ref.length; i < len; i++) {
          node = ref[i];
          if (node.alive === true) {
            this.drawConnections(node, this.nodeArray, this.adjacentDistance);
          }
        }
        ref1 = this.nodeArray;
        results = [];
        for (j = 0, len1 = ref1.length; j < len1; j++) {
          node = ref1[j];
          if (node.alive === true) {
            results.push(this.drawCircle(node));
          } else {
            results.push(void 0);
          }
        }
        return results;
      }

      tick() {
        this.drawingContext.clearRect(0, 0, this.canvas.width, this.canvas.height);
        this.draw();
        this.evolve();
        this.cull();
        return setTimeout(this.tick, this.tickLength);
      }

      evolve() {
        var i, len, neighborCount, newArray, node, ref;
        newArray = this.nodeArray;
        ref = this.nodeArray;
        for (i = 0, len = ref.length; i < len; i++) {
          node = ref[i];
          neighborCount = countNeighbors(node, this.nodeArray, this.adjacentDistance);
          if (neighborCount === 3) {
            this.reproduce(node, newArray);
          }
        }
        return this.nodeArray = newArray;
      }

      cull() {
        var i, index, len, neighborCount, newArray, node;
        newArray = this.nodeArray;
        for (i = 0, len = newArray.length; i < len; i++) {
          node = newArray[i];
          neighborCount = countNeighbors(node, newArray, this.adjacentDistance);
          if (neighborCount < this.isolationThreshold) {
            if (Math.random() < this.isolationDeadliness) {
              node.alive = false;
            }
          }
          if (neighborCount > this.overcrowdingThreshold) {
            if (Math.random() < this.overcrowdingThreshold) {
              node.alive = false;
            }
          }
        }
        index = newArray.length - 1;
        while (index >= 0) {
          if (newArray[index].alive === false) {
            newArray.splice(index, 1);
            index--;
          }
          index--;
        }
        return this.nodeArray = newArray;
      }

      reproduce(node, array) {
        var neighbors, newCircle, newX, newY;
        // original non-direction algorithm
        // newX = node.xPos + (Math.random() - 0.5) * @adjacentDistance * 10
        // newY = node.yPos + (Math.random() - 0.5) * @adjacentDistance * 10
        neighbors = getNeighbors(node, array, this.adjacentDistance);
        //todo: need a better trigonometric solution to this
        //todo: also make it so new nodes are placed some minimum distance from parent node
        //can i do this in radians/degrees & if i can do i want to?
        newX = neighbors[1].xPos + (Math.random() - 0.5) * 2 * this.adjacentDistance;
        newY = neighbors[2].yPos + (Math.random() - 0.5) * 2 * this.adjacentDistance;
        if (newX > this.canvas.width) {
          newX = this.canvas.width;
        }
        if (newY > this.canvas.height) {
          newY = this.canvas.height;
        }
        if (newX < 0) {
          newX = 0;
        }
        if (newY < 0) {
          newY = 0;
        }
        newCircle = this.createCircle(newX, newY, node.radius);
        return array.push(newCircle);
      }

    };

    Conrand.prototype.nodeArray = null;

    Conrand.prototype.canvas = null;

    Conrand.prototype.drawingContext = null;

    //graphics parameters
    Conrand.prototype.canvasheight = 400;

    Conrand.prototype.canvaswidth = 400;

    //game parameters
    Conrand.prototype.tickLength = 100;

    Conrand.prototype.initialnodes = 200;

    Conrand.prototype.isolationThreshold = 3;

    Conrand.prototype.isolationDeadliness = 0.5;

    Conrand.prototype.overcrowdingThreshold = 5;

    Conrand.prototype.overcrowdingDeadliness = 0.5;

    Conrand.prototype.adjacentDistance = 20;

    getDistance = function(a, b) {
      var sumOfSquares, xdiff, ydiff;
      xdiff = b.xPos - a.xPos;
      ydiff = b.yPos - a.yPos;
      sumOfSquares = Math.pow(xdiff, 2) + Math.pow(ydiff, 2);
      return Math.sqrt(sumOfSquares);
    };

    getNeighbors = function(node, array, distance) {
      var d, i, len, neighbors, x;
      neighbors = [];
      for (i = 0, len = array.length; i < len; i++) {
        x = array[i];
        d = getDistance(node, x);
        if (d < distance) {
          neighbors.push(x);
        }
      }
      return neighbors;
    };

    countNeighbors = function(node, array, distance) {
      var count, d, i, len, x;
      count = 0;
      for (i = 0, len = array.length; i < len; i++) {
        x = array[i];
        d = getDistance(node, x);
        if (d < distance) {
          count++;
        }
      }
      return count;
    };

    return Conrand;

  })();

  window.Conrand = Conrand;

}).call(this);
