package {

    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.events.Event;
    import flash.text.*;

    public class Dragable extends Sprite {
        
        private var selected:Boolean = false;
        private var lastX:int;
        private var lastY:int;
        private var distance:int;
        public var point:Vector2;

        public function Dragable(stage:Object, point:Vector2, index:int = -1) {
            this.point = point;
            super();
            addEventListener(MouseEvent.MOUSE_DOWN, onStart);
            stage.addEventListener(MouseEvent.MOUSE_MOVE, onMove);
            stage.addEventListener(MouseEvent.MOUSE_UP, onEnd);
            addEventListener(MouseEvent.MOUSE_UP, onSelect);

        }


        private function onStart(e:MouseEvent):void {
            selected = true;
            lastX = this.x;
            lastY = this.y;
            distance = 0;
            e.stopPropagation();
            dispatchEvent(new Event("PICKED"));
        }

        private function onMove(e:MouseEvent):void {
            if (selected) {
                x = e.stageX;
                y = e.stageY;
                point.x = x;
                point.y = y;
                distance += Math.abs(x - lastX) + Math.abs(y - lastY);
                lastX = x;
                lastY = y;
            }
        }

        private function onSelect(e:MouseEvent):void {
            if (selected && distance <= 3) {
                dispatchEvent(new Event("SELECTED"));
            }
            if (selected) {
                dispatchEvent(new Event("DROPPED"));
            }

            selected = false;
            e.stopPropagation();

        }

        private function onEnd(e:MouseEvent):void {
            if (selected && distance <= 3) {
                dispatchEvent(new Event("SELECTED"));
            }
            if (selected) {
                dispatchEvent(new Event("DROPPED"));
            }


            if (selected) {
                e.stopImmediatePropagation();
            }
            selected = false;
        }
    }
}