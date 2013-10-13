package {
    import flash.utils.Dictionary;

    public class Graph {
        private var nodes:Vector.<Node>;
        private var portalToNode:Dictionary;
        private var parent:Dictionary;
        private var points:Vector.<Vector2>;

        public function Graph(points:Vector.<Vector2>) {
            this.points = points;
            nodes = new Vector.<Node>();
            portalToNode = new Dictionary();
            parent = new Dictionary();
        }

        public function create(list:Vector.<Triangle>):void {
            var openlist:Vector.<Triangle> = list.slice();
            var visited:Dictionary = new Dictionary();

            for each (var t:Triangle in openlist) {
                visited[t] = true;
            }

            while (openlist.length > 0) {
                var t:Triangle = openlist.shift();
                trace("check triangle ", t.indices.join(","));

                for each (var triangle:Triangle in t.neighbors) {
                    if (! (triangle in visited) ) {
                        openlist.push(triangle);
                        visited[triangle] = true;
                    }
                }

                for each (var portal:Portal in t.portals) {
                    var node:Node;
                    if (portal in portalToNode) {
                        node = portalToNode[portal];
                    }
                    else {
                        node = new Node(portal);
                        portalToNode[portal] = node;
                    }

                }

                for each (var p1:Portal in t.portals) {
                    for each (var p2:Portal in t.portals) {
                        if (p1 != p2) {
                            trace("add neighbor ", p1.print(points), p2.print(points));
                            var n1:Node = portalToNode[p1];
                            var n2:Node = portalToNode[p2];
                            n1.addNeighbor(n2);
                            n2.addNeighbor(n1);
                        }
                    }
                }

            }


            dijkstra(list);
            
        }

        public function dijkstra(list:Vector.<Triangle>):void {
            trace("DIJKSTRA");
            var cmp:Function = function(lhs:Object, rhs:Object):int { return lhs.distance - rhs.distance; };
            var openlist:BinaryHeap = new BinaryHeap(cmp);
            var visited:Dictionary = new Dictionary();

            for each (var t:Triangle in list) {
                for each (var p:Portal in t.portals) {
                    if ( ! (p in visited) ) {
                        var node:Node = portalToNode[p];
                        visited[node] = true;
                        node.distance = 0;
                        openlist.put(node);

                        if (t.aligned(p)) {
                            p.reverse();
                        }
                    }
                }
            }

            while (openlist.size > 0) {
                var node:Node = openlist.pop() as Node;
                trace("check ", node.portal.print(points));
                visited[node] = true;
                
                trace("neighbors count ", node.neighbors.length);
                for each (var neighbor:Node in node.neighbors) {
                    trace("neighbor", neighbor.portal.print(points));
                    if (! (neighbor in visited) ) {
                        var d:Number = node.distance + dist(node.portal, neighbor.portal);
                        if (d < neighbor.distance) {
                            var index:int = openlist.indexOf(neighbor);
                            if (index >= 0) {
                                openlist.pop(index);
                            }
                            neighbor.distance = d;
                            openlist.put(neighbor);
                            parent[neighbor.portal] = node.portal;
                            var common:Triangle = node.portal.common(neighbor.portal);
                            if (common.aligned(neighbor.portal)) {
                                neighbor.portal.reverse();
                            }
                            trace("parent of ", neighbor.portal.print(points), " is ", node.portal.print(points));
                        }
                    }
                }
                
            }

        }

        public function dist(p1:Portal, p2:Portal):Number {
            var m1:Vector2 = p1.left.add(p1.right).mul(0.5);
            var m2:Vector2 = p2.left.add(p2.right).mul(0.5);

            var distance:Number = m2.sub(m1).len();
            return distance;
        }

        public function findPath(from:Portal):Vector.<Portal> {
            var result:Vector.<Portal> = new Vector.<Portal>();
            var p:Portal = from;

            while (p in parent) {
                result.push(p);

                p = parent[p];
            }

            result.push(p);

            /*
            trace("PATH");
            for each (var p:Portal in result) {
                trace(p.print(points));
            }
            */

            return result;
        }
        
    }
}