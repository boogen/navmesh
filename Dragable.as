package {

    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.events.Event;

    public class Dragable extends Sprite {
        
        private var selected:Boolean = false;
        private var lastX:int;
        private var lastY:int;
        private var distance:int;

        public function Dragable(stage:Object) {
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
        }

        private function onMove(e:MouseEvent):void {
            if (selected) {
                x = e.stageX;
                y = e.stageY;
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