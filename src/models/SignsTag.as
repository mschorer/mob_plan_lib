package models {
	import flash.data.SQLStatement;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.AbstractOperation;
	import mx.rpc.AsyncToken;
	
	[RemoteClass(alias="models.SignsTag")]
	
	public class SignsTag extends SignsContentModel {

		protected static var _tableName:String = "tags";

		protected var _cache_parent_id:int;
		public var parent_id:int;

		public var sort:int;
		
		protected var _children:ArrayCollection;

		public function SignsTag( preset:Object=null) {
			super( preset);
		}

		override public function get tableName():String {
			return _tableName;
		}
		
		override public function getInstance( p:Object):Model {
			return new SignsTag( p);
		}
		
		override protected function preset( p:Object):void {
			super.preset( p);

			cache_parent_id = ( p != null && p.cache_parent_id != null) ? p.cache_parent_id : -1;
			parent_id = ( p != null && p.parent_id != null) ? p.parent_id : -1;

			sort = ( p != null && p.sort != null) ? p.sort : null;
			
			setChildren( ( p != null && p.subItems != null) ? p.subItems : null);
		}
		
		public function set cache_parent_id( id:int):void {
			_cache_parent_id = id;
		}
		public function get cache_parent_id():int {
			return _cache_parent_id;
		}
		
		public function setChildren( l:ArrayCollection):void {
			_children = l;
		}
		
		public function getChildren():ArrayCollection {
			return _children;
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
*/				
				case 'list':
					at = ao.send( _pageSizeRemote, _pageOffsetRemote, modified);
					break;
			}
			
			if ( at == null) at = super.execServiceCall( ao, method, token);
			
			return at;			
		}
		
		override protected function getOperationName( method:String):String {
			var mthd:String = '';
			switch( method) {
				case 'sync':
				case 'save': mthd = 'saveTag'; break;
				case 'list': mthd = 'getTags'; break;
				
				default:
					mthd = method;
			}
			
			return mthd;
		}
		
		//----------------------------------------------------------------------------------
		
		override protected function getSql( tag:String, parms:RetrievalParameters=null):String {
			var sql:String;
			
//			var conds:String = SqlParameters.getCondition( parms);
			
			switch( tag) {
				case 'create':
					sql = "CREATE TABLE IF NOT EXISTS "+_tableName+" ( "+
					"cache_id int PRIMARY KEY AUTOINCREMENT,"+
					"cache_modified DATETIME DEFAULT current_timestamp,"+
					"cache_parent_id int,"+
					"id int DEFAULT -1,"+
					"parent_id int,"+
					"sort int,"+
					"name varchar(256),"+
					"description varchar(1024),"+
					"created DATETIME,"+
					"modified DATETIME"+
					");" +
					"CREATE INDEX IF NOT EXISTS "+_tableName+"_id ON "+_tableName+" ( id);" +
					"CREATE INDEX IF NOT EXISTS "+_tableName+"_cp_id ON "+_tableName+" ( cache_parent_id)";
					break;
				
				case 'insert':
					sql = "INSERT INTO "+_tableName+" ( cache_parent_id, id, parent_id, sort, name, description, created, modified, cache_modified) VALUES ( :CACHE_PARENT_ID, :ID, :PARENT_ID, :SORT, :NAME, :DESCRIPTION, :CREATED, :MODIFIED, :CACHE_MODIFIED)";
					break;
				case 'update':
					sql = "UPDATE "+_tableName+" SET cache_parent_id=:CACHE_PARENT_ID, cache_modified=:CACHE_MODIFIED, id=:ID, parent_id=:PARENT_ID, sort=:SORT, name=:NAME, description=:DESCRIPTION, created=:CREATED, modified=:MODIFIED WHERE cache_id=:CACHE_ID"+updateCond();
					break;
				
				case 'delete':
					break;
				case 'select':
					sql = "SELECT * FROM "+_tableName+" WHERE cache_id=:CACHE_ID";
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
					stmt.parameters[':CACHE_PARENT_ID'] = cache_parent_id;
					stmt.parameters[':PARENT_ID'] = parent_id;
					stmt.parameters[':SORT'] = sort;
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
		}

		override public function toString():String {
			return "TAG "+super.toString()+" parent["+parent_id+"] #["+sort+"]";
		}
	}
}