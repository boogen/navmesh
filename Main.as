package {

    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    import flash.utils.Dictionary;

    public class Main extends Sprite {

        private var points:Vector.<Vector2> = new Vector.<Vector2>();
        private var pointSprites:Vector.<Sprite> = new Vector.<Sprite>();
        private var triangles:Vector.<Triangle> = new Vector.<Triangle>();
        private var portals:Vector.<Portal> = new Vector.<Portal>();

        private var bottom:Sprite;
        private var current:Vector.<Sprite>;
        private var finish:Dragable;
        private var path:Vector.<Portal>;
        private var road:Vector.<Vector2>;
        private var top:Sprite;

        private var graph:Graph;
        private var units:Vector.<Unit> = new Vector.<Unit>();

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

            finish = new Dragable(stage, new Vector2(900, 300));
            finish.x = 900;
            finish.y = 300;
            finish.graphics.beginFill(0x000000);
            finish.graphics.drawCircle(0, 0, 10);
            finish.graphics.endFill();
            top.addChild(finish);
            finish.addEventListener("PICKED", onPicked);
            finish.addEventListener("DROPPED", onDropped);
        }

        private function onPicked(e:Event):void {
            graph = null;
        }

        private function onDropped(e:Event):void {
            for each (var t:Triangle in triangles) {
                t.checkOrientation();
            }
            createGraph();
        }

        private function createGraph():void {
            var end_index:int = insideTriangle(finish.x, finish.y);
            if (end_index >= 0) {
                trace("in triangle", triangles[end_index].indices.join(","));

                var list:Vector.<Triangle> = new Vector.<Triangle>();
                list.push(triangles[end_index]);
                graph = new Graph(points);
                graph.create(list);

            }
            else {
                graph = null;
            }
        }


        private function onMouseUp(e:MouseEvent):void {
            var index:int = insideTriangle(e.stageX, e.stageY);
            if (index >= 0) {
                var unit:Unit = addUnit(e.stageX, e.stageY);
                unit.setTriangle(triangles[index]);
            }
            else {
                addPoint(e.stageX, e.stageY);
            }
        }

        private function addUnit(px:Number, py:Number):Unit {
            var unit:Unit = new Unit();
            unit.x = px;
            unit.y = py;
            unit.here.x = px;
            unit.here.y = py;
            units.push(unit);
            addChild(unit);
            
            return unit;
        }

        private function addPoint(px:Number, py:Number):void {
            var v:Vector2 = new Vector2(px, py);
            points.push(v);

            var p:Sprite = new Dragable(stage, v, points.length - 1);
            p.x = px;
            p.y = py;
            addChild(p);
            p.addEventListener("SELECTED", onSelect);
            p.addEventListener("DROPPED", onDropped);
            pointSprites.push(p);

            if (current.length >= 3) {
                current.shift();
            }

            current.push(p);
            addTriangle();

            createGraph();
        }


        private function addTriangle():void {
            if (current.length >= 3) {
                var indices:Vector.<int> = new Vector.<int>();
                
                for (var i:int = 0; i < current.length; ++i) {
                    indices.push(pointSprites.indexOf(current[i]));
                }

                var triangle:Triangle = new Triangle(points, indices);

                for (var i:int = 0; i < triangles.length; ++i) {
                    if (triangle.commonVertices(triangles[i]) == 2) {
                        var portal:Portal = createPortal(triangle, triangles[i]);
                        triangle.addNeighbor(triangles[i], portal);
                        triangles[i].addNeighbor(triangle, portal);
                    }
                }

                triangles.push(triangle);
            }

        }

        private function createPortal(t1:Triangle, t2:Triangle):Portal {
            var portal:Portal = new Portal();
            portal.triangle1 = t1;
            portal.triangle2 = t2;

            for (var i:int = 0; i < t1.indices.length; ++i) {
                if (t2.indices.indexOf(t1.indices[i]) == -1) {
                    var i1:int = t1.indices[ ( i + 1 ) % t1.indices.length ];
                    var i2:int = t1.indices[ ( i + 2 ) % t1.indices.length ];

                    portal.left = points[i1];
                    portal.right = points[i2];
                }
            }
            
            return portal;
            
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


            for (var i:int = 0; i < pointSprites.length; ++i) {
                var color:uint;
                var sprite:Sprite = pointSprites[i];
                if (current.indexOf(sprite) >= 0) {
                    color = 0xff0000;
                }
                else {
                    color = 0x999999;;
                }
                
                sprite.graphics.clear();
                sprite.graphics.beginFill(color);
                sprite.graphics.drawCircle(0, 0, 8);
                sprite.graphics.endFill();

            }

            addChild(top);
            top.graphics.clear();

            for each (var unit:Unit in units) {
                unit.graphics.clear();
                unit.graphics.beginFill(0x00aa00);
                unit.graphics.drawCircle(0, 0, 4);
                unit.graphics.endFill();

            }



            var end_index:int = insideTriangle(finish.x, finish.y);
            if (graph != null && end_index >= 0) {

                for each (var t:Triangle in triangles) {
                    if (t in Unit.partition) {
                        var droids:Vector.<Unit> = Unit.partition[t];
                        for each (var unit:Unit in droids) {
                            var force:Vector2 = new Vector2(0, 0);
                            for each (var u:Unit in droids) {
                                var f:Vector2 = unit.here.sub(u.here);
                                var len:Number = f.len();
                                if (len > 0 && len < 25) {
                                    var nrm:Vector2 = f.mul( 1 / len);
                                    f = f.mul(1 / 25);
                                    f = nrm.sub(f);
                                    force = force.add(f);
                                }
                            }
                            
                            force = force.mul( 0.001);
                            unit.force = unit.force.add(force);
                        }
                    }
                }


                var target:Triangle = triangles[end_index];
                for each (var unit:Unit in units) {
                    unit.tick(target, graph, finish.point);
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


    }
}