package models {
	
	import flash.data.SQLStatement;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.AbstractOperation;
	import mx.rpc.AsyncToken;

	[RemoteClass(alias="models.SignsVG250")]
	
	public class SignsVG250 extends Model {

		protected static var _tableName:String = "vg250";
		
		public var id:int;
		public var level:int;
		
		public var ags:String;
		public var name:String;
		public var orga:String;
		
		public var geometry:String;

		public var created:Date;

		public function SignsVG250( preset:Object=null) {
			super( preset);
		}

		override public function getInstance( p:Object):Model {
			return new SignsOwner( p);
		}
		
		override protected function preset( p:Object):void {
			super.preset( p);
			
			id = ( p != null && p.id != null) ? p.id : -1;
			level = ( p != null && p.level != null) ? p.level : null;
			
			ags = ( p != null && p.ags != null) ? p.ags : null;
			name = ( p != null && p.name != null) ? p.name : null;
			orga = ( p != null && p.orga != null) ? p.orga : null;
			
			geometry = ( p != null && p.geometry != null) ? p.geometry : null;
		}
		
		//----------------------------------------------------------------------------------
		
		override protected function execServiceCall( ao:AbstractOperation, method:String, token:Object):AsyncToken {
			switch( method) {
				case 'getTagsForIds':
					return ao.send( token.ids);
					break;
				
				case 'getTagsForLocation':
					return ao.send( token.location_id);
					break;
				
				case 'getTagsForGeom':
				default:
					return ao.send( token.point);
					break;
			}
		}
		
		override protected function getOperationName( method:String):String {
			var mthd:String = '';
			switch( method) {
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
			
//			var conds:String = SqlParameters.getCondition( parms);
			
			switch( tag) {
				case 'create':
					sql = "CREATE TABLE IF NOT EXISTS "+_tableName+" ( "+
					"id int DEFAULT -1,"+
					"level int,"+
					"ags varchar(20),"+
					"name varchar(256),"+
					"orga varchar(256),"+
					"geometry varchar"+
					")";
					break;
				
				case 'insert':
					sql = "INSERT INTO "+_tableName+" ( id, level, ags, name, orga, geometry) VALUES ( :ID, :LEVEL, :AGS, :NAME, :ORGA, :GEOMETRY)";
					break;
				case 'update':
					sql = "UPDATE "+_tableName+" SET id=:ID, level=:LEVEL, ags=:AGS, name=:NAME, orga=:ORGA, geometry=:GEOMETRY WHERE cache_id=:CACHE_ID";
					break;
				
				case 'delete':
					sql = "DELETE FROM "+_tableName+" WHERE cache_id=:CACHE_ID";
					break;
				case 'select':
					//					sql = "SELECT *, strftime( '%s', created) AS created, strftime( '%s', modified) AS modified FROM "+_tableName+" WHERE local_id=:LOCAL_ID";
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
					stmt.parameters[':ID'] = id;
					stmt.parameters[':LEVEL'] = level;
					stmt.parameters[':AGS'] = ags;
					stmt.parameters[':NAME'] = name;
					stmt.parameters[':ORGA'] = orga;
					stmt.parameters[':GEOMETRY'] = geometry;
					break;
				
				case 'delete':
				case 'select':
					stmt.parameters[':ID'] = id;
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
			return "vg250 "+super.toString()+" [ "+ags+"/"+level+" / "+name+" - "+orga+"] @["+geometry+"]";
		}
	}
}