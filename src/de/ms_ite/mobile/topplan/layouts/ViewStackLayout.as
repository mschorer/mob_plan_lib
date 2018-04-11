package de.ms_ite.mobile.topplan.layouts
{
	import mx.core.IVisualElement;
	import spark.layouts.supportClasses.LayoutBase;
	
	public class ViewStackLayout extends LayoutBase {
		public function ViewStackLayout() {
			super();
		}
		
		protected var _index:uint;
		
		public function get index():Number {
			return _index;
		}
		
		public function set index(value:Number):void {
			if (_index != value && target != null && value >= 0 && value < target.numElements) {
				_index = value;
				target.invalidateSize();
				target.invalidateDisplayList();
			}
		}
		
		override public function updateDisplayList(width:Number, height:Number):void {
			var element:IVisualElement = useVirtualLayout ? target.getVirtualElementAt(index) : target.getElementAt(index);
			
			if (element) {
				element.setLayoutBoundsSize(element.getPreferredBoundsWidth(), element.getPreferredBoundsHeight());
				target.setActualSize(element.getPreferredBoundsWidth(), element.getPreferredBoundsHeight());
				target.setContentSize(element.getPreferredBoundsWidth(), element.getPreferredBoundsHeight());
			}
		}
		
		override public function measure():void {
			var count:int = target.numElements;
			
			for (var i:uint = 0; i < count; i++) {
				var element:IVisualElement = useVirtualLayout ? target.getVirtualElementAt(i) : target.getElementAt(i);
				
				if (i == index) {
					element.visible = true;
					element.includeInLayout = true;
					target.measuredWidth = element.getPreferredBoundsWidth();
					target.measuredHeight = element.getPreferredBoundsHeight();
				} else {
					element.visible = false;
					element.includeInLayout = false;
				}
			}
		}
	}
}