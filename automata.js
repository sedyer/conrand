// Generated by CoffeeScript 2.0.2
(function() {
  var Conrand;

  Conrand = (function() {
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

      seed() {
        var i, node, ref, results;
        this.nodeArray = [];
        results = [];
        for (node = i = 0, ref = this.initialnodes; 0 <= ref ? i < ref : i > ref; node = 0 <= ref ? ++i : --i) {
          results.push(this.nodeArray[node] = this.createSeedCircle());
        }
        return results;
      }

      createSeedCircle() {
        return this.createCircle(this.canvas.width * Math.random(), this.canvas.height * Math.random(), 2);
      }

      createCircle(x, y, r) {
        return {
          xPos: x,
          yPos: y,
          radius: r,
          alive: true
        };
      }

      tick() {
        this.evolve();
        this.cull();
        this.draw();
        return setTimeout(this.tick, this.tickLength);
      }

      evolve() {
        var a, b, i, len, neighbors, newArray, newNode, node, ref;
        newArray = this.nodeArray;
        ref = this.nodeArray;
        for (i = 0, len = ref.length; i < len; i++) {
          node = ref[i];
          this.vibrate(node, this.vibration);
          neighbors = this.getNeighbors(node, this.nodeArray, this.adjacentDistance);
          if (neighbors.length > 3) {
            node.alive = false;
          } else if (neighbors.length === 2) {
            a = this.getNeighbors(neighbors[0], this.nodeArray, this.adjacentDistance).length === 2;
            b = this.getNeighbors(neighbors[1], this.nodeArray, this.adjacentDistance).length === 2;
            if (a && b) {
              newNode = this.thirdNode(node, neighbors[0], Math.PI / 3);
              newArray.push(newNode);
              newNode = this.thirdNode(neighbors[0], neighbors[1], Math.PI / 3);
              newArray.push(newNode);
              newNode = this.thirdNode(neighbors[1], node, Math.PI / 3);
              newArray.push(newNode);
            }
          // adist = @getDistance(node, neighbors[0])
          // bdist = @getDistance(node, neighbors[1])

          // if adist > bdist
          //   newNode = @thirdNode(node, neighbors[0], Math.PI / 3)
          //   newArray.push(newNode)
          //   node.alive = false
          //   neighbors[1].alive = false
          // else
          //   newNode = @thirdNode(node, neighbors[1], -Math.PI / 3)
          //   newArray.push(newNode)
          //   node.alive = false
          //   neighbors[0].alive = false
          } else if (neighbors.length === 1) {
            // newNode = @thirdNode(node, neighbors[0], (Math.random() - 0.5) * 4 * Math.PI)
            // newArray.push(newNode)
            a = this.getNeighbors(neighbors[0], this.nodeArray, this.adjacentDistance).length === 1;
            if (a) {
              newNode = this.thirdNode(node, neighbors[0], Math.PI / 3);
              newArray.push(newNode);
            }
          } else if (neighbors.length === 0) {
            node.alive = false;
          }
        }
        return this.nodeArray.concat(newArray);
      }

      cull() {
        var index, results;
        index = this.nodeArray.length - 1;
        results = [];
        while (index >= 0) {
          if (this.nodeArray[index].alive === false) {
            this.nodeArray.splice(index, 1);
            index--;
          }
          results.push(index--);
        }
        return results;
      }

      getDistance(a, b) {
        var sumOfSquares, xdiff, ydiff;
        xdiff = b.xPos - a.xPos;
        ydiff = b.yPos - a.yPos;
        sumOfSquares = Math.pow(xdiff, 2) + Math.pow(ydiff, 2);
        return Math.sqrt(sumOfSquares);
      }

      getNeighbors(node, array, distance) {
        var d, i, len, neighbors, x;
        neighbors = [];
        for (i = 0, len = array.length; i < len; i++) {
          x = array[i];
          d = this.getDistance(node, x);
          if (d < distance && d > 1) {
            neighbors.push(x);
          }
        }
        return neighbors;
      }

      vibrate(node, factor) {
        node.xPos = node.xPos + ((Math.random() - 0.5) * 2 * factor);
        node.yPos = node.yPos + ((Math.random() - 0.5) * 2 * factor);
        return this.rectifyNode(node);
      }

      rectifyNode(node) {
        if (node.xPos > this.canvas.width) {
          node.xPos = this.canvas.width;
        }
        if (node.yPos > this.canvas.height) {
          node.yPos = this.canvas.height;
        }
        if (node.xPos < 0) {
          node.xPos = 0;
        }
        if (node.yPos < 0) {
          return node.yPos = 0;
        }
      }

      thirdNode(node, pivot, theta) {
        var c, newCircle, newX, newY, s, tX, tY;
        s = Math.sin(theta);
        c = Math.cos(theta);
        tX = node.xPos - pivot.xPos;
        tY = node.yPos - pivot.yPos;
        newX = (tX * c) - (tY * s);
        newY = (tX * s) + (tY * c);
        newX = newX + pivot.xPos;
        newY = newY + pivot.yPos;
        newCircle = this.createCircle(newX, newY, node.radius);
        this.rectifyNode(newCircle);
        return newCircle;
      }

      draw() {
        var i, j, len, len1, node, ref, ref1, results;
        this.drawingContext.clearRect(0, 0, this.canvas.width, this.canvas.height);
        ref = this.nodeArray;
        for (i = 0, len = ref.length; i < len; i++) {
          node = ref[i];
          this.drawConnections(node, this.nodeArray, this.adjacentDistance);
        }
        ref1 = this.nodeArray;
        results = [];
        for (j = 0, len1 = ref1.length; j < len1; j++) {
          node = ref1[j];
          results.push(this.drawCircle(node));
        }
        return results;
      }

      drawConnections(node, array, distance) {
        var context, i, len, neighbors, results, x;
        neighbors = this.getNeighbors(node, array, distance);
        context = this.drawingContext;
        context.lineWidth = 1;
        context.strokeStyle = 'rgb(242, 198, 65)';
        results = [];
        for (i = 0, len = neighbors.length; i < len; i++) {
          x = neighbors[i];
          if (x.alive === true) {
            context.strokeStyle = 'rgb(242, 198, 65)';
          } else {
            context.strokeStyle = 'grey';
          }
          context.beginPath();
          context.moveTo(node.xPos, node.yPos);
          context.lineTo(x.xPos, x.yPos);
          results.push(context.stroke());
        }
        return results;
      }

      drawCircle(circle) {
        if (circle.alive === true) {
          this.drawingContext.fillStyle = 'white';
        } else {
          this.drawingContext.fillStyle = 'grey';
        }
        this.drawingContext.lineWidth = 2;
        this.drawingContext.strokeStyle = 'rgba(242, 198, 65, 0.1)';
        this.drawingContext.beginPath();
        this.drawingContext.arc(circle.xPos, circle.yPos, circle.radius, 0, 2 * Math.PI, false);
        this.drawingContext.fill();
        return this.drawingContext.stroke();
      }

    };

    Conrand.prototype.nodeArray = null;

    Conrand.prototype.canvas = null;

    Conrand.prototype.drawingContext = null;

    //graphics parameters
    Conrand.prototype.canvasheight = 900;

    Conrand.prototype.canvaswidth = 900;

    //game parameters
    Conrand.prototype.tickLength = 100;

    Conrand.prototype.initialnodes = 100;

    Conrand.prototype.adjacentDistance = 64;

    Conrand.prototype.vibration = 4;

    return Conrand;

  })();

  window.Conrand = Conrand;

}).call(this);
