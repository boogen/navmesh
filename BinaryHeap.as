package  
{
	/**
	 * ...
	 * @author 
	 */
	public class BinaryHeap 
	{
		
		private var compare:Function;
		public var heap:Array = [null];
		private var count:int = 0;
		
		public function BinaryHeap(compare:Function) 
		{
			this.compare = compare;
		}
		
		public function isEmpty():Boolean
		{
			return count == 0;
		}

        public function get size():int {
            return count;
        }
		
		public function pop(i:int = 1):Object
		{
			var result:Object;
			if (count > 0) {
				result = heap[i];
				var tmp:Object = heap[count];
				heap[count--] = null;
				heap[i] = tmp;
				heapify(i);	
				
			}
			
			return result;
		}
		
		public function put(obj:*):void
		{
			var index:int = ++count;
			if (index == heap.length) {
				heap.push(obj);
			}
			else {
				heap[index] = obj;
			}
			
			var parent:int = index >> 1;
			
			while (parent > 0)
			{
				if (compare(heap[index], heap[parent]) < 0)
				{
					swap(index, parent)
					index = parent;
					parent >>= 1;
				}
				else  {
					break;
				}
			}			
		}

        public function indexOf(element:Object):int {
            return heap.indexOf(element);
        }

        public function element(index:int):Object {
            return heap[index + 1];
        }
		
		public function update(value:int):void 
		{
			for (var i:int = 1; i <= count; ++i) {
				if (heap[i] == value) {
					pop(i);
					put(value);
					return;
				}
			}
		}
		
		private function swap(lhs:int, rhs:int):void 
		{
			var tmp:Object = heap[lhs];
			heap[lhs] = heap[rhs];
			heap[rhs] = tmp;
		}
		
		private function heapify(index:int):void 
		{
			var left:int = 2 * index;
			var right:int = 2 * index + 1;
			var smallest:int = index;
			
			if (left <= count && compare(heap[left], heap[smallest]) < 0) {
				smallest = left;
			}
			if (right <= count && compare(heap[right], heap[smallest]) < 0) {
				smallest = right;
			}
			if (smallest != index) {
				swap(smallest, index);
				heapify(smallest);
			}
		}
		
	}

}