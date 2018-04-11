package models {
	import flash.data.SQLStatement;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.AbstractOperation;
	import mx.rpc.AsyncToken;
	
	[RemoteClass(alias="models.SignsIcon")]
	
	public class SignsIcon extends SignsContentModel {

		protected static var _tableName:String = "icons";

		public var type:int;
		
		public var url:String;
		public var preview_url:String;

		protected var _cache_preview_url:String;
		
		public function SignsIcon( preset:Object=null) {
			super( preset);
		}

		override public function get tableName():String {
			return _tableName;
		}
		
		override public function getInstance( p:Object):Model {
			return new SignsIcon( p);
		}
		
		override protected function preset( p:Object):void {
			super.preset( p);

			type = ( p != null && p.type != null) ? p.type : null;
			
			url = ( p != null && p.url != null) ? p.url : null;

			preview_url = ( p != null && p.preview_url != null) ? p.preview_url : null;
			cache_preview_url = ( p != null && p.cache_preview_url != null) ? p.cache_preview_url : null;
		}
		
		public function set cache_preview_url( url:String):void {
			_cache_preview_url = url;
		}
		
		public function get cache_preview_url():String {
			return _cache_preview_url;
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
				case 'save': mthd = 'saveIcon'; break;
				case 'list': mthd = 'getIcons'; break;
				
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
					"cache_preview_url varchar(256),"+
					"id int DEFAULT -1,"+
					"type int,"+
					"name varchar(256),"+
					"description varchar(1024),"+
					"url varchar(256),"+
					"preview_url varchar(256),"+
					"created DATETIME,"+
					"modified DATETIME"+
					");" +
					"CREATE INDEX IF NOT EXISTS "+_tableName+"_id ON "+_tableName+" ( id)";
					break;
				
				case 'insert':
					sql = "INSERT INTO "+_tableName+" ( cache_preview_url, id, type, name, description, url, preview_url, created, modified, cache_modified) VALUES ( :CACHE_PREVIEW_URL, :ID, :TYPE, :NAME, :DESCRIPTION, :URL, :PREVIEW_URL, :CREATED, :MODIFIED, :CACHE_MODIFIED)";
					break;
				case 'update':
					sql = "UPDATE "+_tableName+" SET cache_preview_url=:CACHE_PREVIEW_URL, cache_modified=:CACHE_MODIFIED, id=:ID, type=:TYPE, name=:NAME, description=:DESCRIPTION, url=:URL, preview_url=:PREVIEW_URL, created=:CREATED, modified=:MODIFIED WHERE cache_id=:CACHE_ID"+updateCond();
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
					stmt.parameters[':TYPE'] = type;
					stmt.parameters[':URL'] = url;
					stmt.parameters[':PREVIEW_URL'] = preview_url;
					stmt.parameters[':CACHE_PREVIEW_URL'] = cache_preview_url;
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
			return "ICON "+super.toString()+" + type["+type+"] urls["+url+":"+preview_url+":"+cache_preview_url+"]";
		}
	}
}