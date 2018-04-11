package de.ms_ite.mobile.topplan {
	import models.SignsContentModel;
	import models.SignsMapModel;
	import models.SignsTagMap;
	
	public class TagWrapper {
		
		protected var _item:SignsContentModel;
		
		protected var _selected:Boolean;
		protected var _dbSelected:Boolean=false;
		
		protected var _mapItem:SignsMapModel;
		
		public function TagWrapper( i:SignsContentModel=null) {
			if ( i != null) _item = i;
		}
		
		public function set item( i:SignsContentModel):void {
			_item = i;
		}
		public function get item():SignsContentModel {
			return _item;
		}
		
		public function set mapItem( m:SignsMapModel):void {
			_mapItem = m;
			_selected = _dbSelected = ( m != null && ! m.deleted);
		}
		public function get mapItem():SignsMapModel {
			return _mapItem;
		}

		public function get label():String {
			return (_item != null) ? _item.name : '';
		}
		
		public function get type():int {
			return (_item != null) ? Object( _item).type : 0;
		}
		
		public function get parent_id():int {
			return (_item != null) ? Object( _item).parent_id : 0;
		}
		
		public function get url():String {
			return (_item != null && _item.hasOwnProperty('cache_preview_url')) ? Object( _item).cache_preview_url : '';
		}
		
		public function set selected( b:Boolean):void {
			_selected = b;
		}
		public function get selected():Boolean {
			return _selected;
		}		

		public function get changed():Boolean {
			return (_selected != _dbSelected);
		}
		
		public function toString():String {
			return "TagWrapper ["+changed+"] ["+_dbSelected+"/"+_selected+"/"+(( _mapItem != null && ! _mapItem.deleted)? '+' : '-')+"] "+_item.toString();
		}
	}
}