package models {
	import flash.data.SQLStatement;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.AbstractOperation;
	import mx.rpc.AsyncToken;
	
	import de.ms_ite.mobile.topplan.AppSettings;
	
	[RemoteClass(alias="models.SignsItem")]
	
	public class SignsItem extends SignsContentModel {

		protected static var _tableName:String = "items";

		public var _cache_parent_id:int = -1;
		public var _cache_location_id:int = -1;
		public var _cache_owner_id:int = -1;

		public var parent_id:int = -1;
		public var location_id:int = -1;
		public var owner_id:int = -1;

		public var sort:int = 0;
		public var type:int = -1;
		
		public var direction:int = -1;
		public var position:int = -1;
		public var connection:int = -1;
		public var size:int = -1;
		public var format:int = -1;
		
		public var value:String = null;
		
		public var status:int = AppSettings.STATUS_UNDEF;
		
		public var _icons:String;

		protected var _children:ArrayCollection;

		public function SignsItem( preset:Object=null) {
			super( preset);
		}

		override public function get tableName():String {
			return _tableName;
		}
		
		override public function getInstance( p:Object):Model {
			return new SignsItem( p);
		}
		
		override public function validate():Boolean {
			var rc:Boolean = super.validate();
			
			return ( rc && cache_location_id >= 0);	// && cache_owner_id >= 0);
		}
		
		override protected function preset( p:Object):void {
			super.preset( p);

			cache_parent_id = ( p != null && p.cache_parent_id != null) ? p.cache_parent_id : -1;
			cache_location_id = ( p != null && p.cache_location_id != null) ? p.cache_location_id : -1;
			cache_owner_id = ( p != null && p.cache_owner_id != null)  ? p.cache_owner_id : -1;

			parent_id = ( p != null && p.parent_id != null) ? p.parent_id : -1;
			location_id = ( p != null && p.location_id != null) ? p.location_id : -1;
			owner_id = ( p != null && p.owner_id != null) ? p.owner_id : -1;
			
			type = ( p != null && p.type != null) ? p.type : -1;
			sort = ( p != null && p.sort != null) ? p.sort : 0;
			
			position = ( p != null && p.position != null) ? p.position : -1;
			direction = ( p != null && p.direction != null) ? p.direction : -1;
			connection = ( p != null && p.connection != null) ? p.connection : -1;
			size = ( p != null && p.size != null) ? p.size : -1;
			format = ( p != null && p.format != null) ? p.format : -1;
			
			value = ( p != null && p.value != null) ? p.value : null;
			
			_icons = ( p != null && p.icons != null) ? p.icons : null;
			
			status = ( p != null && p.status != null) ? p.status : AppSettings.STATUS_UNDEF;
			
			if ( p != null && p.hasOwnProperty( "children")) children = p.children;
		}
		
		public function set cache_parent_id( id:int):void {
			_cache_parent_id = id;
		}
		public function get cache_parent_id():int {
			return _cache_parent_id;
		}
		
		public function set cache_location_id( id:int):void {
			_cache_location_id = id;
		}
		public function get cache_location_id():int {
			return _cache_location_id;
		}
		
		public function set cache_owner_id( id:int):void {
			_cache_owner_id = id;
		}
		public function get cache_owner_id():int {
			return _cache_owner_id;
		}
		
		public function get icons():String {
			return _icons;
		}
		
		public function set children( l:ArrayCollection):void {
			_children = l;
		}
		
		public function get children():ArrayCollection {
			return _children;
		}
		
		//----------------------------------------------------------------------------------
		
		override protected function execServiceCall( ao:AbstractOperation, method:String, token:Object):AsyncToken {
			var at:AsyncToken = null;
			
			switch( method) {
/*
				case 'sync':
					at = ao.send( this, cache_modified);
					break;
				
				case 'save':
					at = ao.send( this);
					break;
				
				case 'loadById':
					at = ao.send( tableName, id);
					break;
*/				
				case 'list':
					at = ao.send( location_id, _pageSizeRemote, _pageOffsetRemote, modified);
					break;
			}
			
			if ( at == null) at = super.execServiceCall( ao, method, token);
			
			return at;
		}
		
		override protected function getOperationName( method:String):String {
			var mthd:String = null;
			switch( method) {
				case 'sync':
				case 'save': mthd = 'saveItem'; break;
				case 'list': mthd = 'getItems'; break;
				
				default:
					mthd = method;
			}
			
			if ( mthd == null) mthd = super.getOperationName( method);
			
			return mthd;
		}
		
		//----------------------------------------------------------------------------------
		
		override protected function getSql( tag:String, parms:RetrievalParameters=null):String {
			var sql:String = null;

//			var conds:Array = RetrievalParameters.getCondition( parms);

			switch( tag) {
				case 'create':
					sql = "CREATE TABLE IF NOT EXISTS "+_tableName+" ( "+
					"cache_id int PRIMARY KEY AUTOINCREMENT,"+
					"cache_modified DATETIME DEFAULT current_timestamp,"+
					"cache_location_id int,"+
					"cache_parent_id int,"+
					"cache_owner_id int,"+
					"id int DEFAULT -1,"+
					"location_id int,"+
					"parent_id int,"+
					"owner_id varchar( 32),"+
					"sort int,"+
					"type int,"+
					"position int,"+
					"direction int,"+
					"connection int,"+
					"size int,"+
					"format int,"+
					"name varchar(256),"+
					"value varchar(256),"+
					"description varchar(1024),"+
					"created DATETIME,"+
					"modified DATETIME"+
					");" +
					"CREATE INDEX IF NOT EXISTS "+_tableName+"_id ON "+_tableName+" ( id);" +
					"CREATE INDEX IF NOT EXISTS "+_tableName+"_cl_id ON "+_tableName+" ( cache_location_id);" +
					"CREATE INDEX IF NOT EXISTS "+_tableName+"_cp_id ON "+_tableName+" ( cache_parent_id);" +
					"CREATE INDEX IF NOT EXISTS "+_tableName+"_co_id ON "+_tableName+" ( cache_owner_id)";
					break;
				//"CREATE INDEX IF NOT EXISTS loc_id_index ON items ( cache_location_id);";
				
				case 'insert':
					sql = "INSERT INTO "+_tableName+" ( cache_location_id, cache_parent_id, cache_owner_id, id, location_id, parent_id, owner_id, type, sort, direction, position, connection, size, format, name, value, description, created, modified, cache_modified) VALUES ( :CACHE_LOCATION_ID, :CACHE_PARENT_ID, :CACHE_OWNER_ID, :ID, :LOCATION_ID, :PARENT_ID, :OWNER_ID, :TYPE, :SORT, :DIRECTION, :POSITION, :CONNECTION, :SIZE, :FORMAT, :NAME, :VALUE, :DESCRIPTION, :CREATED, :MODIFIED, :CACHE_MODIFIED)";
					break;
				case 'update':
					sql = "UPDATE "+_tableName+" SET cache_location_id=:CACHE_LOCATION_ID, cache_parent_id=:CACHE_PARENT_ID, cache_owner_id=:CACHE_OWNER_ID, cache_modified=:CACHE_MODIFIED, id=:ID, location_id=:LOCATION_ID, parent_id=:PARENT_ID, owner_id=:OWNER_ID, type=:TYPE, sort=:SORT, direction=:DIRECTION, position=:POSITION, connection=:CONNECTION, size=:SIZE, format=:FORMAT, name=:NAME, value=:VALUE, description=:DESCRIPTION, created=:CREATED, modified=:MODIFIED WHERE cache_id=:CACHE_ID"+updateCond();
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
					stmt.parameters[':CACHE_LOCATION_ID'] = cache_location_id;
					stmt.parameters[':CACHE_PARENT_ID'] = cache_parent_id;
					stmt.parameters[':CACHE_OWNER_ID'] = cache_owner_id;
					stmt.parameters[':LOCATION_ID'] = location_id;
					stmt.parameters[':PARENT_ID'] = parent_id;
					stmt.parameters[':OWNER_ID'] = owner_id;
					stmt.parameters[':TYPE'] = type;
					stmt.parameters[':SORT'] = sort;
					stmt.parameters[':POSITION'] = position;
					stmt.parameters[':DIRECTION'] = direction;
					stmt.parameters[':CONNECTION'] = connection;
					stmt.parameters[':SIZE'] = size;
					stmt.parameters[':FORMAT'] = format;
					stmt.parameters[':VALUE'] = value;
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
			return "ITEM "+super.toString()+" + cLocId["+cache_location_id+"] cParent["+cache_parent_id+"] cOwner["+cache_owner_id+"] : locId["+location_id+"] parent["+parent_id+"] owner["+owner_id+"] #["+sort+"] t/d/p["+type+"/"+direction+"/"+position+"] value["+value+"]";
		}
	}
}