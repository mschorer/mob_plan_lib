package models {
	
	import flash.data.SQLStatement;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.AsyncToken;
	import mx.rpc.AbstractOperation;

	[RemoteClass(alias="models.SignsTagMap")]
	
	public class SignsTagMap extends SignsMapModel {

		protected static var _tableName:String = "items_tags";
		
		protected var _cache_tag_id:int = -1;		
		protected var _tag_id:int = -1;
		
		public function SignsTagMap( preset:Object=null) {
			super( preset);
		}
		
		override public function get tableName():String {
			return _tableName;
		}

		override public function getInstance( p:Object):Model {
			return new SignsTagMap( p);
		}
		
		override protected function preset( p:Object):void {
			super.preset( p);
			
			_cache_tag_id = ( p != null && p.cache_tag_id != null) ? p.cache_tag_id : -1;
			
			_tag_id = ( p != null && p.tag_id != null) ? p.tag_id : -1;
		}
		
		public function set tag_id( i:int):void {
			_tag_id = i;
		}
		
		public function get tag_id():int {
			return _tag_id;
		}
		
		public function set cache_tag_id( i:int):void {
			_cache_tag_id = i;
		}
		
		public function get cache_tag_id():int {
			return _cache_tag_id;
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
				case 'save': mthd = 'saveItemTag'; break;
				case 'list': mthd = 'getItemTags'; break;
				
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
					"cache_tag_id int,"+
					"id int DEFAULT -1,"+
					"item_id int,"+
					"tag_id int,"+
					"sort int,"+
					"deleted int DEFAULT 0,"+
					"modified DATETIME"+
					");" +
					"CREATE INDEX IF NOT EXISTS "+_tableName+"_id ON "+_tableName+" ( id);" +
					"CREATE INDEX IF NOT EXISTS "+_tableName+"_cid ON "+_tableName+" ( cache_id);" +
					"CREATE INDEX IF NOT EXISTS "+_tableName+"_ci_id ON "+_tableName+" ( cache_item_id);" +
					"CREATE INDEX IF NOT EXISTS "+_tableName+"_ct_id ON "+_tableName+" ( cache_tag_id)";
					break;
				
				case 'insert':
					sql = "INSERT INTO "+tableName+" ( cache_item_id, cache_tag_id, id, item_id, tag_id, sort, deleted, modified, cache_modified) VALUES ( :CACHE_ITEM_ID, :CACHE_TAG_ID, :ID, :ITEM_ID, :TAG_ID, :SORT, :DELETED, :MODIFIED, :CACHE_MODIFIED)";
					break;
				case 'update':
					sql = "UPDATE "+tableName+" SET cache_item_id=:CACHE_ITEM_ID, cache_tag_id=:CACHE_TAG_ID, cache_modified=:CACHE_MODIFIED, id=:ID, item_id=:ITEM_ID, tag_id=:TAG_ID, sort=:SORT, deleted=:DELETED, modified=:MODIFIED WHERE cache_id=:CACHE_ID"+updateCond();
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
					stmt.parameters[':CACHE_TAG_ID'] = _cache_tag_id;
					stmt.parameters[':TAG_ID'] = _tag_id;
					break;
				
				case 'delete':
					break;
				
				case 'select':
					break;
				
				case 'list':
					setStmtParams( stmt, parms);
					break;
				case 'clear':
					break;
			}
		}
		
		override public function toString():String {
			return "itemTAG "+super.toString()+" item["+_item_id+"] tag["+_tag_id+"] <["+sort+"]";
		}
	}
}