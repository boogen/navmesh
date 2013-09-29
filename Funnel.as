package {
    
    public class Funnel {

        public var current:Vector2;
        public var left:Vector2;
        public var right:Vector2;
        public var index:int = 0;

        public function Funnel() {
        }

        public function find(path:Vector.<Triangle>, start:Object, finish:Object):Vector.<Vector2> {
            var portals:Vector.<Portal> = new Vector.<Portal>();

            for (var i:int = 1; i < path.length; ++i) {
                var portal:Portal = path[i - 1].getPortal(path[i]);
                portals.push(portal);
            }

            var last:Portal = new Portal();
            last.left = new Vector2(finish.x, finish.y);
            last.right = new Vector2(finish.x, finish.y);
            portals.push(last);

            index = 0;
            current = new Vector2(start.x, start.y);
            setLR(portals[0].left, portals[0].right);

            var road:Vector.<Vector2> = new Vector.<Vector2>();
            road.push(new Vector2(start.x, start.y));
            
            for (var i:int = 1; i < portals.length; ++i) {
                trace("check funnel ", i);
                if (insideFunnel(current, portals[i])) {
                    trace("inside");
                    setLR(portals[i].left, portals[i].right);
                    index = i;
                }
                else {
                    var newleft:Vector2 = portals[i].left;
                    var newright:Vector2 = portals[i].right;
                    
                    if (newleft.sub(current).cross(right.sub(current)) >= 0 && 
                        newright.sub(current).cross(right.sub(current)) >= 0) {
                        trace("on the left");
                        var t:Vector2 = right.sub(left);
                        t = t.mul(0.95);
                        current = left.add(t);
                        left = null;
                        right = null;
                        i = index;
                        road.push(current);
                        
                    }
                    else if (newleft.sub(current).cross(left.sub(current)) <= 0 && 
                        newright.sub(current).cross(left.sub(current)) <= 0) {
                        trace("on the right");
                        var t:Vector2 = left.sub(right);
                        t = t.mul(0.95);
                        current = right.add(t);
                        left = null;
                        right = null;
                        i = index;
                        road.push(current);

                    }
                    else {
                        trace("ignore");
                    }

                }
            }
            
            road.push(new Vector2(finish.x, finish.y));
            
            return road;
        }

        private function reset(portals:Vector.<Portal>, i:int, road:Vector.<Vector2>):void {
            var newx:Number = (portals[i - 1].left.x + portals[i - 1].right.x) / 2;
            var newy:Number = (portals[i - 1].left.y + portals[i - 1].right.y) / 2;
            current = new Vector2(newx, newy);
            setLR(portals[i].left, portals[i].right);
            road.push(current);

        }



        private function setLR(lhs:Vector2, rhs:Vector2):void {
            left = lhs;
            right = rhs;

            if ( left.sub(current).cross(right.sub(current)) > 0 ) {
                left = rhs;
                right = lhs;
            }
            
        }

        private function insideFunnel(current:Vector2,  portal:Portal):Boolean {
            if (left == null || right == null) {
                return true;
            }

            var p1:Vector2 = left.sub(current);
            var p2:Vector2 = right.sub(current);

            var v1:Vector2 = portal.left.sub(current);
            var v2:Vector2 = portal.right.sub(current);


            if (v1.cross(v2) > 0) {
                var t:Vector2 = v1;
                v1 = v2;
                v2 = t;
            }

            if (p1.cross(v1) <= 0 && p2.cross(v1) >= 0 && p1.cross(v2) <= 0 && p2.cross(v2) >= 0) {
                return true;
            }

            return false;
        }


    }
}