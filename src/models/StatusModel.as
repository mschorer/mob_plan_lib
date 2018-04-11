package models {
	public class StatusModel {

		public var action:String;
		public var id:int;
		public var _modified:Date;

		public function StatusModel( p:Object=null) {

			id = ( p != null && p.id != null) ? parseInt( p.id) : -1;
			action = ( p != null && p.action != null) ? p.action : null;
			modified = ( p != null && p.modified != null) ? dateFromTimestamp( p.modified) : null;
		}
		
		public function set modified( d:Object):void {
			_modified = dateFromTimestamp( d);
		}
		
		public function get modified():Object {
			return _modified;
		}
		
		protected function dateFromTimestamp( d:Object):Date {
			var date:Date;
			if ( d is Date) date = d as Date;
			else {
				var ds:Number = parseFloat( String( d)) * 1000;
				date = new Date( ds);
			}
			
			return date;
		}
		
		public function toString():String {
			return "status["+action+"]";
		}
	}
}