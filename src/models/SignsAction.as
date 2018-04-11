package models {
	
	import flash.data.SQLStatement;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.AbstractOperation;
	import mx.rpc.AsyncToken;

	[RemoteClass(alias="models.SignsAction")]
	
	public class SignsAction extends SignsContentModel {

		protected static var _tableName:String = "itemactions";

		protected var _cache_item_id:int;
		protected var _cache_user_id:int;
		protected var _cache_project_id:int;
		protected var _cache_url:String;
		
		public var item_id:int;
		public var user_id:int;
		public var project_id:int;

		public var type:int;
		public var status:int;
		public var estatus:int;
		
		public var _url:String;

		public function SignsAction( preset:Object=null) {
			super( preset);
		}
		
		override public function get tableName():String {
			return _tableName;
		}
		
		override public function getInstance( p:Object):Model {
			return new SignsAction( p);
		}

		override public function validate():Boolean {
			var rc:Boolean = super.validate();
			
			return ( rc && cache_item_id >= 0 && cache_user_id >= 0 && cache_project_id >= 0);
		}

		override protected function preset( p:Object):void {
			super.preset( p);
			
			cache_item_id = ( p != null && p.cache_item_id != null) ? p.cache_item_id : -1;
			cache_user_id = ( p != null && p.cache_user_id != null)  ? p.cache_user_id : -1;
			cache_project_id = ( p != null && p.cache_project_id != null) ? p.cache_project_id : -1;
			
			item_id = ( p != null && p.item_id != null) ? p.item_id : -1;
			user_id = ( p != null && p.user_id != null) ? p.user_id : -1;
			project_id = ( p != null && p.project_id != null) ? p.project_id : -1;
			
			type = ( p != null && p.type != null) ? p.type : -1;
			status = ( p != null && p.status != null) ? p.status : -1;
			estatus = ( p != null && p.estatus != null) ? p.estatus : -1;
			
			url = ( p != null && p.url != null) ? p.url : null;
			cache_url = ( p != null && p.cache_url != null) ? p.cache_url : null;
		}
		
		public function set url( url:String):void {
			_url = url;
		}
		public function get url():String {
			return _url;
		}
		
		public function set cache_url( url:String):void {
			_cache_url = url;
		}
		public function get cache_url():String {
			return _cache_url;
		}
		
		public function set cache_user_id( id:int):void {
			_cache_user_id = id;
		}
		public function get cache_user_id():int {
			return _cache_user_id;
		}
		
		public function set cache_item_id( id:int):void {
			_cache_item_id = id;
		}		
		public function get cache_item_id():int {
			return _cache_item_id;
		}
		
		public function set cache_project_id( id:int):void {
			_cache_project_id = id;
		}		
		public function get cache_project_id():int {
			return _cache_project_id;
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
					at = ao.send( item_id, null, null, _pageSizeRemote, _pageOffsetRemote, modified);
					break;
			}
			
			if ( at == null) at = super.execServiceCall( ao, method, token);
			
			return at;
		}
		
		override protected function getOperationName( method:String):String {
			var mthd:String = '';
			switch( method) {
				case 'sync':
				case 'save': mthd = 'saveAction'; break;
				case 'list': mthd = 'getActions'; break;
				
				default:
					mthd = method;
			}
			
			return mthd;
		}
		
		//----------------------------------------------------------------------------------
		
		override protected function getSql( tag:String, parms:RetrievalParameters=null):String {
			var sql:String;
			
			var conds:String = RetrievalParameters.getCondition( parms);
			
			switch( tag) {
				case 'create':
					sql = "CREATE TABLE IF NOT EXISTS "+_tableName+" ( "+
					"cache_id int PRIMARY KEY AUTOINCREMENT,"+
					"cache_modified DATETIME DEFAULT current_timestamp,"+
					"cache_url varchar(256),"+
					"cache_item_id int,"+
					"cache_user_id int,"+
					"cache_project_id int,"+
					"id int DEFAULT -1,"+
					"item_id int,"+
					"user_id int,"+
					"project_id int,"+
					"type int,"+
					"status int,"+
					"estatus int,"+
					"name varchar(256),"+
					"description varchar(1024),"+
					"url varchar(256),"+
					"created DATETIME,"+
					"modified DATETIME"+
					");" +
					"CREATE INDEX IF NOT EXISTS "+_tableName+"_id ON "+_tableName+" ( id);" +
					"CREATE INDEX IF NOT EXISTS "+_tableName+"_ci_id ON "+_tableName+" ( cache_item_id);" +
					"CREATE INDEX IF NOT EXISTS "+_tableName+"_cu_id ON "+_tableName+" ( cache_user_id);" +
					"CREATE INDEX IF NOT EXISTS "+_tableName+"_cp_id ON "+_tableName+" ( cache_project_id);" +
					"CREATE INDEX IF NOT EXISTS "+_tableName+"_mod ON "+_tableName+" ( cache_modified)";
					break;
				
				case 'insert':
					sql = "INSERT INTO "+_tableName+" ( cache_user_id, cache_item_id, cache_project_id, cache_modified, id, item_id, user_id, project_id, type, status, estatus, name, description, url, cache_url, created, modified) VALUES ( :CACHE_USER_ID, :CACHE_ITEM_ID, :CACHE_PROJECT_ID, :CACHE_MODIFIED, :ID, :ITEM_ID, :USER_ID, :PROJECT_ID, :TYPE, :STATUS, :ESTATUS, :NAME, :DESCRIPTION, :URL, :CACHE_URL, :CREATED, :MODIFIED)";
					break;
				case 'update':
					sql = "UPDATE "+_tableName+" SET cache_user_id=:CACHE_USER_ID, cache_item_id=:CACHE_ITEM_ID, cache_project_id=:CACHE_PROJECT_ID, cache_modified=:CACHE_MODIFIED, cache_url=:CACHE_URL, id=:ID, item_id=:ITEM_ID, user_id=:USER_ID, project_id=:PROJECT_ID, type=:TYPE, status=:STATUS, estatus=:ESTATUS, name=:NAME, description=:DESCRIPTION, url=:URL, created=:CREATED, modified=:MODIFIED WHERE cache_id=:CACHE_ID"+updateCond();
					break;
				
				case 'delete':
				case 'select':
					break;
				
				case 'list':
					/*
					sql = "SELECT *";
					
					var flds:String = RetrievalParameters.getFields(parms);
					if ( flds.length) sql += ","+flds;
					sql += " FROM "+tableName;
					
					if ( conds.length > 0) sql += " where "+conds;
					
					var ord:String = RetrievalParameters.getOrder( parms);
					if ( ord.length) sql += " ORDER BY "+ord;
					
					var lim:String = RetrievalParameters.getLimit( parms);
					if ( lim.length) sql += " LIMIT "+lim;
					*/
					break;
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
					stmt.parameters[':CACHE_ITEM_ID'] = cache_item_id;
					stmt.parameters[':CACHE_USER_ID'] = cache_user_id;
					stmt.parameters[':CACHE_PROJECT_ID'] = cache_project_id;
					stmt.parameters[':CACHE_URL'] = cache_url;

					stmt.parameters[':ITEM_ID'] = item_id;
					stmt.parameters[':USER_ID'] = user_id;
					stmt.parameters[':PROJECT_ID'] = project_id;

					stmt.parameters[':TYPE'] = type;
					stmt.parameters[':STATUS'] = status;
					stmt.parameters[':ESTATUS'] = estatus;
					stmt.parameters[':URL'] = url;
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
			return "ACTION "+super.toString()+" item["+item_id+"] user["+user_id+"] project["+project_id+"] type["+type+"] status["+status+"/"+estatus+"] urls["+url+"/"+cache_url+"]";
		}
	}
}