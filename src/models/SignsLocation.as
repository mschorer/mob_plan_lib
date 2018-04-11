package models {
	import de.ms_ite.ogc.OGCGeometry;
	
	import flash.data.SQLStatement;
	import flash.geom.Point;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.AbstractOperation;
	import mx.rpc.AsyncToken;
	
	[RemoteClass(alias="models.SignsLocation")]

	public class SignsLocation extends SignsContentModel {

		protected static var _tableName:String = "locations";

		public var type:int = -1;

		public var tag_major:String; 	
		public var tag_minor:String; 	
		
		protected var _location:String;
		public var accuracy:int;
		
		protected var _cache_lon:Number;
		protected var _cache_lat:Number;
		
		protected var _dragMode:Boolean = false;
		
		protected var _status:int = -1;

		public function SignsLocation( preset:Object=null) {
			super( preset);
		}
		
		override public function get tableName():String {
			return _tableName;
		}
		
		override public function getInstance( p:Object):Model {
			return new SignsLocation( p);
		}
		
		override protected function preset( p:Object):void {
			super.preset( p);

			tag_major = ( p != null && p.tag_major != null) ? p.tag_major : null;
			tag_minor = ( p != null && p.tag_minor != null) ? p.tag_minor : null;

			type = ( p != null && p.type != null) ? p.type : -1;

			_location = ( p != null && p.location != null) ? p.location : null;
			_cache_lon = ( p != null && p.cache_lon) ? p.cache_lon : null;
			_cache_lat = ( p != null && p.cache_lat) ? p.cache_lat : null;
			
			accuracy = ( p != null && p.accuracy != null) ? p.accuracy : null;
			
			_status = ( p != null && p.status != null) ? p.status : -1;
		}
		
		public function set location( loc:String):void {
			_location = loc;
			
			var ogn:OGCGeometry = new OGCGeometry( _location);
			var orig:Point = ogn.getOrigin();

			_cache_lon = orig.x;
			_cache_lat = orig.y;
		}
		
		public function get location():String {
			return _location;
		}
		
		public function get status():int {
			return _status;
		}
		
		public function set status( s:int):void {
			_status = s;
		}
		
		//----------------------------------------------------------------------------------
		
		public function setDragMode( s:Boolean):void {
			_dragMode = s;
		}
		
		public function getDragMode():Boolean {
			return _dragMode;
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
*/					
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
				case 'save': mthd = 'saveLocation'; break;
				case 'list': mthd = 'getLocations'; break;
				
				default:
					mthd = method;
			}
			
			if ( mthd == null) mthd = super.getOperationName( method);
			
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
					"cache_lon REAL,"+
					"cache_lat REAL,"+
					"id int DEFAULT -1,"+
					"type int,"+
					"tag_major varchar(32),"+
					"tag_minor varchar(32),"+
					"name varchar(32),"+
					"description varchar(1024),"+
					"location varchar,"+
					"accuracy integer DEFAULT -1,"+
					"created DATETIME,"+
					"modified DATETIME"+
					");" +
					"CREATE INDEX IF NOT EXISTS "+_tableName+"_id ON "+_tableName+" ( id);" +
					"CREATE INDEX IF NOT EXISTS "+_tableName+"_geo ON "+_tableName+" ( cache_lat, cache_lon)";
					break;
				
				case 'insert':
					sql = "INSERT INTO "+_tableName+" ( id, type, tag_major, tag_minor, name, description, location, accuracy, created, modified, cache_lon, cache_lat, cache_modified) VALUES ( :ID, :TYPE, :TAG_MAJOR, :TAG_MINOR, :NAME, :DESCRIPTION, :LOCATION, :ACCURACY, :CREATED, :MODIFIED, :CACHE_LON, :CACHE_LAT, :CACHE_MODIFIED)";
					break;
				case 'update':
					sql = "UPDATE "+_tableName+" SET cache_lon=:CACHE_LON, cache_lat=:CACHE_LAT, cache_modified=:CACHE_MODIFIED, id=:ID, type=:TYPE, tag_major=:TAG_MAJOR, tag_minor=:TAG_MINOR, name=:NAME, description=:DESCRIPTION, location=:LOCATION, accuracy=:ACCURACY, created=:CREATED, modified=:MODIFIED WHERE cache_id=:CACHE_ID"+updateCond();
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
					stmt.parameters[':TAG_MAJOR'] = tag_major;
					stmt.parameters[':TAG_MINOR'] = tag_minor;
					stmt.parameters[':LOCATION'] = location;
					stmt.parameters[':ACCURACY'] = accuracy;

					stmt.parameters[':CACHE_LON'] = _cache_lon;
					stmt.parameters[':CACHE_LAT'] = _cache_lat;
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
			return "LOCATION "+super.toString()+" type["+type+"] geom["+location+"] tag["+tag_major+"."+tag_minor+"]";
		}
	}
}