package {

    import flash.geom.Point;

    public class Portal {
        public var triangle1:Triangle;
        public var triangle2:Triangle;

        public var left:Vector2;
        public var right:Vector2;

        public function print(points:Vector.<Vector2>):String {
            return "(" + points.indexOf(left).toString() + ", " + points.indexOf(right).toString() + ")";
        }

        public function reverse():void {
            var tmp:Vector2 = left;
            left = right;
            right = tmp;
        }

        public function common(p:Portal):Triangle {
            
            if (triangle1 == p.triangle1 || triangle1 == p.triangle2) {
                return triangle1;
            }
            if (triangle2 == p.triangle1 || triangle2 == p.triangle2) {
                return triangle2;
            }

            return null;
        }

    }

}