package models {
	
	import flash.data.SQLStatement;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.AsyncToken;
	import mx.rpc.AbstractOperation;

	[RemoteClass(alias="models.SignsIconMap")]
	
	public class SignsIconMap extends SignsMapModel {

		protected static var _tableName:String = "icons_items";
		
		protected var _cache_icon_id:int = -1;
		
		protected var _icon_id:int = -1;
		
		public function SignsIconMap( preset:Object=null) {
			super( preset);
		}
		
		override public function get tableName():String {
			return _tableName;
		}

		override public function getInstance( p:Object):Model {
			return new SignsIconMap( p);
		}
		
		override protected function preset( p:Object):void {
			super.preset( p);
			
			_cache_icon_id = ( p != null && p.cache_icon_id != null) ? p.cache_icon_id : -1;			
			_icon_id = ( p != null && p.icon_id != null) ? p.icon_id : -1;
		}
		
		public function set icon_id( i:int):void {
			_icon_id = i;
		}
		public function get icon_id():int {
			return _icon_id;
		}
		
		public function set cache_icon_id( i:int):void {
			_cache_icon_id = i;
		}
		public function get cache_icon_id():int {
			return _cache_icon_id;
		}
		
		//----------------------------------------------------------------------------------
		
		override protected function execServiceCall( ao:AbstractOperation, method:String, token:Object):AsyncToken {
			var at:AsyncToken = null;
			
			switch( method) {
/*
				case 'sync':
					return ao.send( this, cache_modified);
					break;
				
				case 'save':
					return ao.send( this);
					break;

				case 'delete':
					return ao.send( _tableName, id);
					break;
*/
				case 'list':
					at = ao.send( item_id, _pageSizeRemote, _pageOffsetRemote, modified);
					break;
			}
			
			if ( at == null) at = super.execServiceCall( ao, method, token);
			
			return at;
		}
		
		override protected function getOperationName( method:String):String {
			var mthd:String = '';
			switch( method) {
				case 'delete': mthd = 'deleteById'; break;
				
				case 'sync':
				case 'save': mthd = 'saveItemIcon'; break;
				case 'list': mthd = 'getItemIcons'; break;
				
				default:
					mthd = method;
			}
			
			return mthd;
		}
		
		//----------------------------------------------------------------------------------
		
		override protected function getSql( tag:String, parms:RetrievalParameters=null):String {
			var sql:String = null;
			
//			var conds:Array = getStmtConditions( parms);

			switch( tag) {
				case 'create':
					sql = "CREATE TABLE IF NOT EXISTS "+_tableName+" ( "+
					"cache_id int PRIMARY KEY AUTOINCREMENT,"+
					"cache_modified DATETIME DEFAULT current_timestamp,"+
					"cache_item_id int,"+
					"cache_icon_id int,"+
					"id int DEFAULT -1,"+
					"item_id int,"+
					"icon_id int,"+
					"sort int,"+
					"deleted int DEFAULT 0,"+
					"modified DATETIME"+
					");" +
					"CREATE INDEX IF NOT EXISTS "+_tableName+"_id ON "+_tableName+" ( id);" +
					"CREATE INDEX IF NOT EXISTS "+_tableName+"_ci_id ON "+_tableName+" ( cache_item_id);" +
					"CREATE INDEX IF NOT EXISTS "+_tableName+"_cc_id ON "+_tableName+" ( cache_icon_id)";
					break;
				
				case 'insert':
					sql = "INSERT INTO "+_tableName+" ( cache_item_id, cache_icon_id, id, item_id, icon_id, sort, deleted, modified, cache_modified) VALUES ( :CACHE_ITEM_ID, :CACHE_ICON_ID, :ID, :ITEM_ID, :ICON_ID, :SORT, :DELETED, :MODIFIED, :CACHE_MODIFIED)";
					break;
				case 'update':
					sql = "UPDATE "+_tableName+" SET cache_item_id=:CACHE_ITEM_ID, cache_icon_id=:CACHE_ICON_ID, cache_modified=:CACHE_MODIFIED, id=:ID, item_id=:ITEM_ID, icon_id=:ICON_ID, sort=:SORT, deleted=:DELETED, modified=:MODIFIED WHERE cache_id=:CACHE_ID"+updateCond();
					break;
				
				case 'delete':
				case 'select':
					break;
				
				case 'list':
				case 'count':
					break;
				
				case 'clear':
				case 'drop':
					break;
			}
			
			if ( sql == null) sql = super.getSql( tag, parms);
			
			return sql;
		}
		
		override protected function addSqlParameters( stmt:SQLStatement, tag:String, parms:RetrievalParameters=null):void {
			
			super.addSqlParameters( stmt, tag, parms);
			
			switch( tag) {
				case 'create':
					break;
				
				case 'update':
				case 'insert':
					stmt.parameters[':CACHE_ICON_ID'] = _cache_icon_id;
					stmt.parameters[':ICON_ID'] = _icon_id;
					break;
				
				case 'delete':
					stmt.parameters[':MODIFIED'] = _modified;
					break;
				
				case 'select':
					stmt.parameters[':CACHE_ID'] = _cache_id;
					break;
				
				case 'list':
					setStmtParams( stmt, parms);
					break;
				case 'clear':
					break;
			}
		}
		
		override public function toString():String {
			return "iconTAG "+super.toString()+" + item[ "+_item_id+"] icon["+_icon_id+"] <["+sort+"]";
		}
	}
}