package {
    public class Vector2 {
        
        public var x:Number;
        public var y:Number;

        public function Vector2(x:Number = 0, y:Number = 0) {
            this.x = x;
            this.y = y;
        }


        public function cross(v:Vector2):Number {
            return this.x * v.y - this.y * v.x;
        }

        public function sub(v:Vector2):Vector2 {
            return new Vector2(x - v.x, y - v.y);
        }

        public function add(v:Vector2):Vector2 {
            return new Vector2(x + v.x, y + v.y);
        }

        public function mul(s:Number):Vector2 {
            return new Vector2(x * s, y * s);
        }

        public function len():Number {
            return Math.sqrt(Math.pow(x, 2) + Math.pow(y, 2));
        }
    }
}