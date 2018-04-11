package de.ms_ite.maptech.cache {
	
	import de.ms_ite.maptech.TileInfo;
	import de.ms_ite.maptech.mapinfo.MapInfo;
	
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.display.Graphics;
	import flash.events.IOErrorEvent;
	import flash.events.SQLErrorEvent;
	import flash.events.SQLEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	
	import spark.components.Image;
	
	public class TileInfoPreloading extends TileInfo {
		
		public static var dbFile:String = "tileCache.db";
		public static var cacheRelPath:String = 'cache';
		protected static var _tableName:String = "cache";
		
		protected static var statementMap:Dictionary = new Dictionary();		
		protected static var dbConn:SQLConnection;
		
		protected static var _bytesTransferred:Number = 0;
		protected static var _bytesCached:Number = 0;
		
		protected var _id:int=-1;
		protected var _local_url:String;
		protected var _basePath:File;
		protected var _size:int=-1;
		
		protected var _last_access:Date;
		protected var _state:int;

		public function TileInfoPreloading( basePath:File=null, img:Image=null, mi:MapInfo=null, lay:int=-1, x:int=-1, y:int=-1) {
			super( img, mi, lay, x, y);

			_basePath = basePath;
//			_local_url = _mapInfo.name+"/"+_layer+"/"+_x+"/"+_y."."+_mapInfo.tileExt;

			state = 0;
		}
		
		protected function presetData( o:Object):void {
			_id = parseInt( o.id);
			
			_layer = parseInt( o.layer);
			_x = parseInt( o.x);
			_y = parseInt( o.y);
			
			_remote_url = o.url;
			_local_url = o.file;
			_size = parseInt( o.size);
			
			accessed = o.accessed;
		}
		
		override public function load():void {
//			debug( "load: "+key());
			
			if ( isCached()) {
				_bytesCached += _size;
				
//#				_tile.source = _local_url;
				
				// update cache access
				state = 2;
				saveDB();
			} else {
//#				_tile.source = _remote_url;
//				debug( "  remote: "+_remote_url);
				state = 1;
			}
		}
		
		public function get localUrl():String {
			return _local_url;
		}
		
		protected function getPath():File {
			return _basePath.resolvePath( cacheRelPath+'/'+_mapInfo.name+'/'+_layer+"/"+_x+'/'+_y+"."+_mapInfo.tileExt);
		}
		
		override public function isCached():Boolean {
			
//			if ( _local_url != null) return true;
			
			var file:File = getPath();
			if ( file.exists) {
				_local_url = file.url;
				
				loadDB();
				
				return true;
			}
			
			return false;
		}
		
		public function save( buffer:ByteArray):String {
			var file:File = getPath();
			
			if ( buffer.length == 0 || buffer.readUTFBytes( 5) == '<?xml') {
//				debug( "nothig to save.");
				return null;
			}
			
			_local_url = file.url;
			
			var fileStream:FileStream = new FileStream();
			fileStream.open( file, FileMode.WRITE);
			fileStream.writeBytes( buffer);			
			fileStream.close();
			
			_size = buffer.length;
			
			_bytesTransferred += _size;
			
			state = 2;
//			load();
			
//			debug( "caching: "+key());
			
			return _local_url;
		}
		
		public function set state( i:int):void {
			var col:int = 0xc0c0c0;
			
			_state = i;
			
			switch( i) {
				case 2: col = 0x00ff00; break;
				case 1: col = 0xffff00; break;
				default:
					col = 0xff0000;
			}
			
			if ( _tile != null) {
				var gr:Graphics = _tile.graphics;
				gr.clear();
				gr.lineStyle( 1, col, 0.4);
				gr.beginFill( col, 0.1);
	//			gr.beginBitmapFill(
				gr.drawRect(0,0,255,255);
				gr.endFill();
			}
		}

		public function set accessed( d:Object):void {
			_last_access = ( d is Date) ? ( d as Date) : dateFromTimestamp( d);
		}
		
		public function get accessed():Object {
			return _last_access;
		}
		
		protected function dateFromTimestamp( d:Object):Date {
			var date:Date;
			if ( d is Date) date = d as Date;
			else {
				var ds:Number = parseFloat( String( d)) * 1000;
				date = new Date( ds);
			}
			
			return date;
		}
		
		public function get transferred():Number {
			return _bytesTransferred;
		}
		
		public function get cached():Number {
			return _bytesCached;
		}
		
		//----------------------------------------------------------------------------------------------------------------

		protected function initLocalDB():Boolean {
			
			var freshlyOpened:Boolean = false;
			
			if ( dbConn == null) {
				dbConn = new SQLConnection();
				
				var dbf:File = _basePath.resolvePath( dbFile);
				dbConn.open( dbf);
				
				freshlyOpened = true;
				debug( "db inited. ["+dbFile+"]");
			}
			
			return freshlyOpened;
		}
		
		public function removeDB():void {
			if (( dbConn != null) ? dbConn.cacheSize : false) dbConn.close();
			
			dbConn = null;
			statementMap = new Dictionary();
			
			var dbf:File = _basePath.resolvePath( dbFile);
			dbf.deleteFile();
			
			var tileStore:File = _basePath.resolvePath( 'cache');
			tileStore.deleteDirectory( true);
		}
		
		protected function createDB( ):void {
			initLocalDB();
			
//			debug( "  create db.");
			
			var sRes:SQLResult = executeOperation( 'create');
		}
		
		protected function executeOperation( sqlTag:String, parms:Object=null):SQLResult {
			
			if ( initLocalDB()) createDB();
			
			var stmt:SQLStatement;
			var stObj:Object = statementMap[ sqlTag];
			
			if ( stObj == null) {
				stmt = new SQLStatement();
				stmt.sqlConnection = dbConn;
				
				stmt.text = getSql( sqlTag);
				
				statementMap[ sqlTag] = stmt;
			} else stmt = SQLStatement( stObj);
			
			addSqlParameters( stmt, sqlTag, parms);
			
			stmt.execute();
			
			return stmt.getResult();
		}
		
		protected function getSql( tag:String):String {
			var sql:String;
			
			switch( tag) {
				case 'create':
					sql = "CREATE TABLE IF NOT EXISTS "+_tableName+" ( "+
					"id int PRIMARY KEY AUTOINCREMENT,"+
					"accessed DATETIME DEFAULT current_timestamp,"+
					"map varchar(32),"+
					"layer int,"+
					"x int,"+
					"y int,"+
					"url varchar(256),"+
					"file varchar(256),"+
					"size int"+
					")";
					break;
				
				case 'insert':
					sql = "INSERT INTO "+_tableName+" ( map, layer, x, y, url, file, size) VALUES ( :MAP, :LAYER, :X, :Y, :URL, :FILE, :SIZE)";
					break;
				case 'update':
					sql = "UPDATE "+_tableName+" SET map=:MAP, layer=:LAYER, x=:X, y=:Y, url=:URL, file=:FILE, size=:SIZE, accessed=current_timestamp WHERE id=:ID";
					break;
				
				case 'delete':
					sql = "DELETE FROM "+_tableName+" WHERE id=:ID";
					break;
				case 'select':
					//					sql = "SELECT *, strftime( '%s', created) AS created, strftime( '%s', modified) AS modified FROM "+_tableName+" WHERE local_id=:LOCAL_ID";
					sql = "SELECT * FROM "+_tableName+" WHERE url=:URL";
					break;
				
				case 'list':
					//					sql = "SELECT *, strftime( '%s', created) AS created, strftime( '%s', modified) AS modified FROM "+_tableName+" where 1 ORDER BY local_id ASC";
					sql = "SELECT * FROM "+_tableName+" where 1 ORDER BY accessed DESC";
					break;
				case 'clear':
					sql = "DELETE FROM "+_tableName+"";
					break;

				case 'getSize':
					//					sql = "SELECT *, strftime( '%s', created) AS created, strftime( '%s', modified) AS modified FROM "+_tableName+" where 1 ORDER BY local_id ASC";
					sql = "SELECT sum( size) FROM "+_tableName+" where 1";
					break;
			}
			
			return sql;
		}
		
		protected function addSqlParameters( stmt:SQLStatement, tag:String, parms:Object=null):void {
			
			switch( tag) {
				case 'create':
					break;
				
				case 'update':				
					stmt.parameters[':ID'] = _id;
				case 'insert':
					stmt.parameters[':MAP'] = _mapInfo.name;
					stmt.parameters[':LAYER'] = _layer;
					stmt.parameters[':X'] = _x;
					stmt.parameters[':Y'] = _y;
					stmt.parameters[':URL'] = url;
					stmt.parameters[':FILE'] = _local_url;
					stmt.parameters[':SIZE'] = _size;
					break;
				
				case 'delete':
					stmt.parameters[':ID'] = _id;
					break;

				case 'select':
					stmt.parameters[':URL'] = _remote_url;
					break;
				
				case 'list':
					//					listStmt.parameters[':TS'] = ts;
					break;
				case 'clear':
					break;

				case 'getSize':
					break;
			}
		}
		
		public function initCache():Array {
			var sqe:SQLResult = executeOperation( 'list' /*, parms */);
			
			if ( sqe.data == null) return null;
			
			return sqe.data;
		}
		
		protected function existsInDB():Boolean {
			return (_id != -1);
		}
		
		public function loadDB():Boolean {
			var sqe:SQLResult = executeOperation( 'select' /*, parms */);
			
			if ( sqe.data == null) return false;
			
			presetData( sqe.data[0]);
			
			return true;
		}
		
		public function saveDB():SQLResult {			
			if ( existsInDB()) return updateDB();
			else return insertDB();
		}
		
		protected function insertDB():SQLResult {
			var sqe:SQLResult = executeOperation( 'insert');	
			_id = sqe.lastInsertRowID;
//			debug( "  DBinsert: "+toString());
			
			return sqe;
		}
		
		protected function updateDB():SQLResult {
			var sqe:SQLResult = executeOperation( 'update');
//			debug( "  DBupdate: "+toString());
			
			return sqe;
		}
		
		protected function deleteDB():SQLResult {
			var sqe:SQLResult = executeOperation( 'delete');			
//			debug( "  DBdelete: "+sqe);
			
			return sqe;
		}
		
		public function list():ArrayCollection {
			
			var sqe:SQLResult = executeOperation( 'list');
			
			var res:ArrayCollection = new ArrayCollection();
			if ( sqe.data != null) {
				for( var i:int = 0; i < sqe.data.length; i++) {
					var ti:TileInfoPreloading = new TileInfoPreloading();
					ti.presetData( sqe.data[i]);
					res.addItem( ti);
				}
			}
			
			return res;
		}
		
		protected function toString():String {
			return "#"+_id+" ["+_remote_url+"] ["+_local_url+"] ["+_mapInfo.name+"-"+_layer+"-"+_x+"-"+_y+"]";
		}
	}
}