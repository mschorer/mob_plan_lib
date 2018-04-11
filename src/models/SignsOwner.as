package models {
	
	import flash.data.SQLStatement;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.AbstractOperation;
	import mx.rpc.AsyncToken;

	[RemoteClass(alias="models.SignsOwner")]
	
	public class SignsOwner extends SignsContentModel {

		protected static var _tableName:String = "owners";
		
		public var ags:String;
		public var geometry:String;

		public function SignsOwner( preset:Object=null) {
			super( preset);
		}

		override public function getInstance( p:Object):Model {
			return new SignsOwner( p);
		}
		
		override public function get tableName():String {
			return _tableName;
		}
		
		override protected function preset( p:Object):void {
			super.preset( p);
			
			ags = ( p != null && p.ags != null) ? p.ags : null;
			geometry = ( p != null && p.geometry != null) ? p.geometry : null;
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
				case 'getTagsForGeom':
					at = ao.send( token.point);
					break;
				
				case 'list':
					at = ao.send( null, _pageSizeRemote, _pageOffsetRemote, modified);
					break;
			}
			
			if ( at == null) at = super.execServiceCall( ao, method, token);
			
			return at;
		}
		
		override protected function getOperationName( method:String):String {
			var mthd:String = '';
			switch( method) {
				case 'sync':
				case 'save': mthd = 'saveOwner'; break;
				case 'list': mthd = 'getOwners'; break;
				
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
					"id int DEFAULT -1,"+
					"name varchar(256),"+
					"description varchar(1024),"+
					"ags varchar(20),"+
					"geometry varchar,"+
					"created DATETIME,"+
					"modified DATETIME"+
					");" +
					"CREATE INDEX IF NOT EXISTS "+_tableName+"_id ON "+_tableName+" ( id);" +
					"CREATE INDEX IF NOT EXISTS "+_tableName+"_cid ON "+_tableName+" ( cache_id)";
					break;
				
				case 'insert':
					sql = "INSERT INTO "+_tableName+" ( cache_modified, id, name, description, ags, geometry, created, modified) VALUES ( :CACHE_MODIFIED, :ID, :NAME, :DESCRIPTION, :AGS, :GEOMETRY, :CREATED, :MODIFIED)";
					break;
				case 'update':
					sql = "UPDATE "+_tableName+" SET cache_id=:CACHE_ID, cache_modified=:CACHE_MODIFIED, id=:ID, name=:NAME, description=:DESCRIPTION, ags=:AGS, geometry=:GEOMETRY, created=:CREATED, modified=:MODIFIED WHERE cache_id=:CACHE_ID"+updateCond();
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
					stmt.parameters[':AGS'] = ags;
					stmt.parameters[':GEOMETRY'] = geometry;
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
			return "owner "+super.toString()+" ags["+ags+"] geom["+geometry+"]";
		}
	}
}