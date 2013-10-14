package {
    import flash.display.*;
    import flash.utils.*;

    public class Unit extends Sprite {

        public var path:Vector.<Portal>;
        public var target:Vector2;
        public var funnel:Funnel;
        public var triangle:Triangle;
        public var here:Vector2 = new Vector2(0, 0);
        public var force:Vector2 = new Vector2(0, 0);

        public static var partition:Dictionary = new Dictionary();
        
        public function Unit() {
            funnel = new Funnel();
        }


        public function setTriangle(t:Triangle):void {
            if (t != triangle) {
                if (triangle && triangle in partition) {
                    var index:int = partition[triangle].indexOf(this);
                    partition[triangle].splice(index, 1);
                }

                if ( ! (t in partition) ) {
                    partition[t] = new Vector.<Unit>();
                }
                partition[t].push(this);

                triangle = t;
            }
        }

        public function tick(to:Triangle, graph:Graph, target:Vector2):void {
            if (graph != null) {
                here.x = this.x;
                here.y = this.y;
                var p:Portal = new Portal();
                p.left = here;
                p.right = here;

                if (!triangle.inside(here.x, here.y)) {
                    for each (var t:Triangle in triangle.neighbors) {
                        if (t.inside(here.x, here.y)) {
                            setTriangle(t);
                        }
                    }
                }
                
                var min_dist:Number = Number.MAX_VALUE;
                var min_portal:Portal = null
                for each (var portal:Portal in triangle.portals) {
                    var d:Number = graph.dist(p, portal);
                    if (d < min_dist) {
                        min_dist = d;
                        min_portal = portal;
                    }
                }


                var diff:Vector2;
                if (triangle != to) {
                    var path:Vector.<Portal> = graph.findPath(min_portal);
                    var road:Vector.<Vector2> = funnel.find(path, here, target);
                    diff = road[1].sub(here);
                }
                else {
                    diff = target.sub(here);
                }
                
                var len:Number = diff.len();
                var vel:Vector2 = diff.mul ( 1 / len).mul(0.5);
                
                
                if (target.sub(here).len() > 15) {
                    this.x += vel.x;
                    this.y += vel.y;
                }

                here.x = this.x;
                here.y = this.y;

                var temp:Vector2 = here.add(force.mul(5 / force.len()));
                var canAddForce:Boolean = false;
                if (triangle.inside(temp.x, temp.y)) {
                    canAddForce = true;
                }
                else {
                    for each (var t:Triangle in triangle.neighbors) {
                        if (t.inside(temp.x, temp.y)) {
                            canAddForce = true;
                        }
                    }
                }

                if (canAddForce) {
                    this.x += force.x;
                    this.y += force.y;
                }
                force = force.mul(0.97);
            }
        }
    }
}