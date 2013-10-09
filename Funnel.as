package {
    
    public class Funnel {

        public var current:Vector2;
        public var left:Vector2;
        public var right:Vector2;
        public var leftIndex:int;
        public var rightIndex:int;

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

            current = new Vector2(start.x, start.y);
            left = portals[0].left;
            right = portals[0].right;

            var road:Vector.<Vector2> = new Vector.<Vector2>();
            road.push(new Vector2(start.x, start.y));
            
            for (var i:int = 1; i < portals.length; ++i) {
                trace("check funnel ", i);
                if (insideFunnel(current, portals[i].left)) {
                    left = portals[i].left;
                    leftIndex = i;
                }
                if (insideFunnel(current, portals[i].right)) {
                    right = portals[i].right;
                    rightIndex = i;
                }
                
                if (right.sub(current).cross(portals[i].left.sub(current)) > 0) {
                    i = Math.min(leftIndex, rightIndex);
                    leftIndex = i;
                    rightIndex = i;
                    var t:Vector2 = right.sub(left);
                    t = t.mul(0.95);
                    current = left.add(t);
                    left = null;
                    right = null;
                    road.push(current);
                }
                else if (left.sub(current).cross(portals[i].right.sub(current)) < 0) {
                    i = Math.min(leftIndex, rightIndex);
                    leftIndex = i;
                    rightIndex = i;
                    var t:Vector2 = left.sub(right);
                    t = t.mul(0.95);
                    current = right.add(t);
                    left = null;
                    right = null;
                    road.push(current);
                }
            }
            
            road.push(new Vector2(finish.x, finish.y));
            
            return road;
        }

        private function reset(portals:Vector.<Portal>, i:int, road:Vector.<Vector2>):void {
            var newx:Number = (portals[i - 1].left.x + portals[i - 1].right.x) / 2;
            var newy:Number = (portals[i - 1].left.y + portals[i - 1].right.y) / 2;
            current = new Vector2(newx, newy);
            left = portals[i].left;
            right = portals[i].right;
            road.push(current);

        }


        private function insideFunnel(current:Vector2,  v:Vector2):Boolean {
            if (left == null || right == null) {
                return true;
            }

            var p1:Vector2 = left.sub(current);
            var p2:Vector2 = right.sub(current);

            var v1:Vector2 = v.sub(current);

            if (p1.cross(v1) >= 0 && p2.cross(v1) <= 0) {
                return true;
            }

            return false;
        }


    }
}