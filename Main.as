package {

    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    import flash.utils.Dictionary;

    public class Main extends Sprite {

        private var points:Vector.<Sprite> = new Vector.<Sprite>();
        private var triangles:Vector.<Triangle> = new Vector.<Triangle>();
        private var bottom:Sprite;
        private var current:Vector.<Sprite>;
        private var start:Sprite;
        private var finish:Sprite;
        private var path:Vector.<Triangle>;
        private var road:Vector.<Vector2>;
        private var top:Sprite;

        public function Main() {
            if (stage) {
                init();
            }
            else {
                addEventListener(Event.ADDED_TO_STAGE, init);
            }
        }

        private function init(e:Event = null):void {
            removeEventListener(Event.ADDED_TO_STAGE, init);

            current = new Vector.<Sprite>();

            stage.addEventListener(Event.ENTER_FRAME, tick);
            stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);

            bottom = new Sprite();
            addChild(bottom);


            top = new Sprite();
            addChild(top);


            start = new Dragable(stage);
            start.x = 100;
            start.y = 300;
            start.graphics.beginFill(0x000000);
            start.graphics.drawCircle(0, 0, 10);
            start.graphics.endFill();
            top.addChild(start);
            start.addEventListener("DROPPED", onDropped);

            finish = new Dragable(stage);
            finish.x = 900;
            finish.y = 300;
            finish.graphics.beginFill(0x000000);
            finish.graphics.drawCircle(0, 0, 10);
            finish.graphics.endFill();
            top.addChild(finish);
            finish.addEventListener("DROPPED", onDropped);

            
        }

        private function onDropped(e:Event):void {

        }


        private function onMouseUp(e:MouseEvent):void {
            addPoint(e.stageX, e.stageY);
        }

        private function addPoint(px:Number, py:Number):void {
            var p:Sprite = new Dragable(stage);
            p.x = px;
            p.y = py;
            addChild(p);
            p.addEventListener("SELECTED", onSelect);
            points.push(p);
            if (current.length >= 3) {
                current.shift();
            }

            current.push(p);



            addTriangle();

            
        }


        private function addTriangle():void {
            if (current.length >= 3) {
                var indices:Vector.<int> = new Vector.<int>();
                
                for (var i:int = 0; i < current.length; ++i) {
                    indices.push(points.indexOf(current[i]));
                }

                var triangle:Triangle = new Triangle(points, indices);

                for (var i:int = 0; i < triangles.length; ++i) {
                    if (triangle.commonVertices(triangles[i]) == 2) {
                        triangle.addNeighbor(triangles[i]);
                        triangles[i].addNeighbor(triangle);
                    }
                }

                triangles.push(triangle);
            }

        }

        private function onSelect(e:Event):void {
            var p:Sprite = e.currentTarget as Sprite;

            var index:int = current.indexOf(p);

            if (index == -1) {
                if (current.length >= 3) {
                    current.shift();
                }

                current.push(p);
                
                addTriangle();

            }
            else {
                current.splice(index, 1);
            }
                

            e.stopPropagation();
        }

        private function tick(e:Event):void {
            if (triangles.length > 0) {
                var indices:Vector.<int> = new Vector.<int>();
                var vertices:Vector.<Number> = new Vector.<Number>();


                for (var i:int = 0; i < points.length; ++i) {
                    vertices.push(points[i].x);
                    vertices.push(points[i].y);
                }


                bottom.graphics.clear();

                for (var i:int = 0; i < triangles.length; ++i) {
                    //indices = indices.concat(triangles[i].indices);
                    //}

                    bottom.graphics.lineStyle(1, 0x999999);
                    bottom.graphics.beginFill(0xeeeeee);
                    bottom.graphics.drawTriangles(vertices, triangles[i].indices);
                    bottom.graphics.endFill();
                }
            }


            for (var i:int = 0; i < points.length; ++i) {
                var color:uint;
                var p:Sprite = points[i];
                if (current.indexOf(p) >= 0) {
                    color = 0xff0000;
                }
                else {
                    color = 0x999999;;
                }
                
                p.graphics.clear();
                p.graphics.beginFill(color);
                p.graphics.drawCircle(0, 0, 6);
                p.graphics.endFill();

            }

            var i:int = insideTriangle(start.x, start.y);
            var j:int = insideTriangle(finish.x, finish.y);

            if (i >= 0 && j >= 0) {
                path = findPath(triangles[i], triangles[j]);
                var funnel:Funnel = new Funnel();
                road = funnel.find(path, start, finish);
                
            }
            else {
                road = null;
            }


            addChild(top);
            top.graphics.clear();

            if (road) {
                top.graphics.lineStyle(1, 0x000000);
                top.graphics.moveTo(road[0].x, road[0].y);
                for (var i:int = 1; i < road.length; ++i) {
                    top.graphics.lineTo(road[i].x, road[i].y);
                }


            }
        }

        private function insideTriangle(px:Number, py:Number):int {
            for (var i:int = 0; i < triangles.length; ++i) {
                if (triangles[i].inside(px, py)) {
                    return i;
                }
            }

            return -1;
            
        }

        private function findPath(from:Triangle, to:Triangle):Vector.<Triangle> {
            var openlist:Vector.<Triangle> = new Vector.<Triangle>();
            var visited:Dictionary = new Dictionary();
            var parent:Dictionary = new Dictionary();

            openlist.push(from);
            visited[from] = true;

            var result:Vector.<Triangle> = new Vector.<Triangle>();

            while (openlist.length > 0) {
                var t:Triangle = openlist.shift();

                if (t == to) {
                    while (t != null) {
                        result.push(t);
                        t = parent[t];
                    }
                    return result.reverse();
                }

                for (var i:int = 0; i < t.neighbors.length; ++i) {
                    var n:Triangle = t.neighbors[i];
                    if (! (n in visited) ) {
                        openlist.push(n);
                        visited[n] = true;
                        parent[n] = t;
                    }
                }
            }

            return result;
               
        }



    }
}