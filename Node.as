package {
    
    public class Node {
        public var portal:Portal;
        public var neighbors:Vector.<Node>;
        public var distance:Number = Number.MAX_VALUE;

        public function Node(portal:Portal) {
            this.portal = portal;
            neighbors = new Vector.<Node>();
        }

        public function addNeighbor(node:Node) {
            if (neighbors.indexOf(node) == -1) {
                neighbors.push(node);
            }
        }
    }
}