package {

    import flash.display.Sprite;
    import flash.geom.Point;

    public class Triangle extends Sprite {

        private var points:Vector.<Sprite>;
        public var indices:Vector.<int>;

        public var neighbors:Vector.<Triangle>;

        public var color:uint = 0xffff00;

        public function Triangle(points:Vector.<Sprite>, indices:Vector.<int>) {
            this.points = points;
            this.indices = indices;
            
            neighbors = new Vector.<Triangle>();


            var p1:Vector2 = new Vector2(points[indices[1]].x - points[indices[0]].x, points[indices[1]].y - points[indices[0]].y);

            var p2:Vector2 = new Vector2(points[indices[2]].x - points[indices[1]].x, points[indices[2]].y - points[indices[1]].y);

            if (p1.cross(p2) < 0) {
                indices.reverse();
            }
        }

        public function commonVertices(triangle:Triangle):int {
            var count:int = 0;

            for (var i:int = 0; i < indices.length; ++i) {
                if (triangle.indices.indexOf(indices[i]) >= 0) {
                    count++;
                }
            }

            return count;
        }

        public function addNeighbor(triangle:Triangle):void {
            neighbors.push(triangle);
        }

        public function inside(px:Number, py:Number):Boolean {
            var result:Number = 0;

            for (var i:int = 0; i < indices.length; ++i) {
                var p1:Sprite = points[indices[i]];
                var p2:Sprite = points[ indices[ ( i + 1 ) % indices.length ] ];
                
                var v1:Point = new Point( p2.x - p1.x, p2.y - p1.y );
                var v2:Point = new Point( px - p1.x, py - p1.y );


               
                var cross:Number =  v1.x * v2.y - v1.y * v2.x;

                if (cross == 0) {
                    return false;
                }


                if (cross > 0) {
                    result += 1;
                }
                else {
                    result -= 1;
                }
                
            }


            if (result == indices.length || result == -indices.length) {
                return true;
            }

            return false;
        }


        public function getPortal(t:Triangle):Portal {
            var portal:Portal = new Portal();

            for (var i:int = 0; i < indices.length; ++i) {
                if (t.indices.indexOf(indices[i]) == -1) {
                    var i1:int = indices[ ( i + 1 ) % indices.length ];
                    var i2:int = indices[ ( i + 2 ) % indices.length ];

                    portal.left = new Vector2(points[i1].x, points[i1].y);
                    portal.right = new Vector2(points[i2].x, points[i2].y);
                }
            }

            return portal;
            
        }
    }
}