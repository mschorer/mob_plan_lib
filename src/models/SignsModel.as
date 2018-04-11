package models {
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.net.Responder;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.AbstractOperation;
	import mx.rpc.AsyncToken;

	[RemoteClass(alias="models.SignsModel")]

	public class SignsModel extends Model {

		public static var STATE_NEW:int = -1;
		public static var STATE_LOCAL:int = 0;
		public static var STATE_REMOTE:int = 5;
		public static var STATE_SYNCED:int = 10;
		
		public var forceUpdate:Boolean = false;
		
		protected var _cache_id:int = -1;
		protected var _cache_modified:Date;
		
		protected var _id:int = -1;
		
		protected var _state:int;
		protected var _modified:Date;
		
		protected var listParms:RetrievalParameters = null;
		protected var listResponder:Responder = null;
		
		public function SignsModel( p:Object=null) {
			super( p);
		}
		
		override public function getInstance( p:Object):Model {
			return new SignsModel( p);
		}
		
		override public function validate():Boolean {
			var rc:Boolean = super.validate();
			
			return ( rc && cache_id >= 0);
		}

		override protected function preset( p:Object):void {
			_cache_id = ( p != null && p.cache_id != null) ? p.cache_id : -1;
			cache_modified = ( p != null && p.cache_modified != null) ? p.cache_modified : null;
			
			_id = ( p != null && p.id != null) ? p.id : -1;
			modified = ( p != null && p.modified != null) ? p.modified : null;
		}

		public function set id( i:int):void {
			if ( _id != id) preset( null);
			_id = i;
			
//			if ( state == STATE_REMOTE || state == STATE_SYNCED) _remote_id = i;
//			if ( state == STATE_NEW || state == STATE_LOCAL || state == STATE_SYNCED) _local_id = i;
		}
		
		public function get id():int {
			return _id;	//( state == STATE_NEW || state == STATE_LOCAL || state == STATE_SYNCED) ? _cache_id : _id;
		}
		
		public function get cache_id():int {
			return _cache_id;
		}

		public function set cache_id( id:int):void {
			if ( _cache_id > 0 && _cache_id != id) preset( null);
			
			_cache_id = id;
		}
		
		public function get state():int {
			if ( _cache_id != -1 && _id != -1) return STATE_SYNCED;
			if ( _cache_id != -1 && _id == -1) return STATE_LOCAL;
			if ( _cache_id == -1 && _id != -1) return STATE_REMOTE;
			
			return STATE_NEW;
		}
		
		public function set modified( d:Object):void {
			if ( d != null) _modified = ( d is Date) ? ( d as Date) : dateFromTimestamp( d);
		}
		
		public function get modified():Object {
			return _modified;
		}
		
		public function set cache_modified( d:Object):void {
			if ( d != null) _cache_modified = ( d is Date) ? ( d as Date) : dateFromTimestamp( d);
		}
		
		public function get cache_modified():Object {
			return _cache_modified;
		}
		
		//----------------------------------------------------------------------------------
		
		override protected function execServiceCall( ao:AbstractOperation, method:String, token:Object):AsyncToken {
			var at:AsyncToken = null;
			
			switch( method) {
				case 'sync':
					at = ao.send( this, cache_modified);
					break;
				
				case 'save':
					at = ao.send( this);
					break;
				
				case 'loadById':
					at = ao.send( tableName, id);
					break;
			}
			
			if ( at == null) at = super.execServiceCall( ao, method, token);
			
			return at;
		}
		
		override protected function existsInDB():Boolean {
			return ( state == STATE_LOCAL || state == STATE_SYNCED);
		}
		
		protected function updateCond():String {
			return forceUpdate ? "" : " AND ( datetime( cache_modified) < datetime( :CACHE_MODIFIED_TIME, 'unixepoch', 'localtime'))";
		}
		
		override protected function getSql( tag:String, parms:RetrievalParameters=null):String {
			var sql:String;
			
			var conds:String = RetrievalParameters.getCondition( parms);
			
			switch( tag) {
				case 'create':
					
				case 'insert':
				case 'update':
					break;
					
				case 'delete':
					sql = "DELETE FROM "+tableName+" WHERE cache_id=:CACHE_ID";
					break;
				case 'select':
					sql = "SELECT * FROM "+tableName+" WHERE cache_id=:CACHE_ID";
					break;
					
				case 'selectById':
					sql = "SELECT * FROM "+tableName+" WHERE id=:ID";
					break;
				
				case 'list':
					/*
					if ( conds.length == 0) sql = "SELECT * FROM "+tableName+" where 1 ORDER BY cache_modified DESC";
					else sql = "SELECT * FROM "+tableName+" where "+conds+" ORDER BY cache_modified DESC";
					break;
					*/
					sql = "SELECT ";
					
					var flds:String = RetrievalParameters.getFields(parms);
					sql += ( flds.length) ? flds : '*';
					
					var tbls:String = RetrievalParameters.getTables(parms);
					sql += " FROM "+(( tbls.length) ? tbls : tableName);
					
					if ( conds.length > 0) sql += " WHERE "+conds;
					
					var grp:String = RetrievalParameters.getGroup( parms);
					if ( grp.length) sql += " GROUP BY "+grp;
					
					var ord:String = RetrievalParameters.getOrder( parms);
					if ( ord.length) sql += " ORDER BY "+ord;
					
					var lim:String = RetrievalParameters.getLimit( parms);
					if ( lim.length && parseInt( lim) > 0) sql += " LIMIT "+lim;
					
					break;

				case 'getMaxModified':
					sql = "SELECT datetime( max( modified)) AS modified FROM "+tableName+" WHERE TRUE";
					break;
				
				case 'count':
					if ( conds.length == 0) sql = "SELECT count( *) AS count FROM "+tableName+" WHERE 1 ORDER BY cache_id ASC";
					else sql = "SELECT count( *) AS count FROM "+tableName+" WHERE "+conds+" ORDER BY cache_id ASC";
					break;
					
				case 'clear':
					sql = "DELETE FROM "+tableName+"";
					break;
				case 'drop':
					sql = "DROP TABLE "+tableName+"";
					break;
			}
			
//			trace( "sql ["+sql+"]");
			
			return sql;
		}
		
		override protected function addSqlParameters( stmt:SQLStatement, tag:String, parms:RetrievalParameters=null):void {
			switch( tag) {
				case 'create':
					break;
				
				case 'update':
					stmt.parameters[':CACHE_ID'] = _cache_id;
					if ( ! forceUpdate) stmt.parameters[':CACHE_MODIFIED_TIME'] = Math.ceil( _cache_modified.time / 1000);
				case 'insert':
					stmt.parameters[':ID'] = _id;
					stmt.parameters[':MODIFIED'] = _modified;
					stmt.parameters[':CACHE_MODIFIED'] = _cache_modified;
					break;
				
				case 'delete':
				case 'select':
					stmt.parameters[':CACHE_ID'] = _cache_id;
					break;
				
				case 'selectById':
					stmt.parameters[':ID'] = _id;
					break;
				
				case 'getMaxModified':
				case 'list':
				case 'count':
					setStmtParams( stmt, parms);
					break;
				
				case 'clear':
				case 'drop':
					break;
			}
		}
		
		//----------------------------------------------------------------------------------

		public function load( resp:Responder=null):Boolean {
			if ( asyncMode) {
				if ( resp == null) resp = new Responder( loadResult, defaultSqlErrorResponder);
				executeOperation( 'select', null, resp);	//loadDB();
				
				return false;
			} else {
				return loadResult( executeOperation( 'select' ));
			}
		}
		
		public function loadResult( sqe:SQLResult):Boolean {
			var rc:Boolean = false;
			
			if ( sqe.data != null && sqe.data.length == 1) {
				preset( sqe.data[0]);
				
				//				debug( "read "+toString());
				
				rc = true;
			}
			
			return rc;
		}
		
		public function loadById( resp:Responder=null):Boolean {
			debug( "loadById "+toString());
			
			if ( asyncMode) {
				if ( resp == null) resp = new Responder( loadByIdResult, defaultSqlErrorResponder);
				executeOperation( 'selectById', null, resp);
				
				return false;
			} else {
				return loadByIdResult( executeOperation( 'selectById' ));
			}
		}
		
		public function loadByIdResult( sqe:SQLResult):Boolean {
			var rc:Boolean = false;
			
			if ( sqe.data != null && sqe.data.length == 1) {
				preset( sqe.data[0]);
				
				debug( "loadById post "+toString());
				
				rc = true;
			}
			
			return rc;
		}
		
		public function save( resp:Responder=null):Boolean {
			debug( "save ["+( existsInDB() ? 'update' : 'insert')+"] "+toString());
			
			if ( asyncMode) {
				if ( resp == null) resp = new Responder( saveResult, defaultSqlErrorResponder);
				executeOperation( existsInDB() ? 'update' : 'insert', null, resp);
				
				return false;
			} else {
				return saveResult( executeOperation( existsInDB() ? 'update' : 'insert' ));				
			}
		}
		
		public function saveResult( sqe:SQLResult):Boolean {
			if ( sqe.lastInsertRowID != 0) {
				_cache_id = sqe.lastInsertRowID;
				
//				error( "  save insert #["+sqe.rowsAffected+"] ["+_cache_id+"]");
				return true;
			} else {
				if ( sqe.rowsAffected == 0) error( "  skip update #["+sqe.rowsAffected+"] ["+_cache_id+"]");
			}
			return false;
		}

		public function list( parms:RetrievalParameters=null, resp:Responder=null):ArrayCollection {
			if ( asyncMode) {
				if ( resp == null) resp = new Responder( addResult, defaultSqlErrorResponder);
				listResponder = resp;
				listParms = parms;
				executeOperation( 'list', parms, resp);
				return null;
			} else {
				listParms = parms;
				return addResult( executeOperation( 'list', parms));	//listDB( parms);
			}
		}

		public function addResult( sqe:SQLResult, dest:ArrayCollection=null):ArrayCollection {
			if ( dest == null) dest = new ArrayCollection();
			
			if ( sqe.data != null /* && sqe.data.length > 0 */) {
//				var temp:ArrayCollection = new ArrayCollection();
				
				for( var i:int = 0; i < sqe.data.length; i++) {
					dest.addItem( this.getInstance( sqe.data[i]));
				}
//				dest.addAll( temp);
				
				var pgs:int = this._pageSizeLocal;
				
				if ( asyncMode && ! sqe.complete && this._pageSizeLocal > 0) {
					getStatement( 'list', listParms).next( this._pageSizeLocal, listResponder);
					
					return null;
				}
			}
			listParms = null;
			listResponder = null;
			
			return dest;
		}

		public function getMaxModified( parms:RetrievalParameters=null, resp:Responder=null):Date {
			if ( asyncMode) {
				if ( resp == null) resp = new Responder( getMaxModifiedResult, defaultSqlErrorResponder);
				executeOperation( 'getMaxModified', parms, resp);
				return null;
			} else {
				return getMaxModifiedResult( executeOperation( 'getMaxModified', parms));
			}
		}
		
		public function getMaxModifiedResult( sqe:SQLResult):Date {
			var mod:Date = dateFromTimestamp( sqe.data[0].modified);
			
			return mod;
		}
		
		public function count( parms:RetrievalParameters=null, resp:Responder=null):int {
			if ( asyncMode) {
				if ( resp == null) resp = new Responder( countResult, defaultSqlErrorResponder);
				executeOperation( 'count', parms, resp);
				return null;
			} else {
				return countResult( executeOperation( 'count', parms));	//listDB( parms);
			}
		}
		
		public function countResult( sqe:SQLResult):int {
			
			return sqe.data[0].count as int;
		}
		
		public function del( resp:Responder=null):void {			
			if ( asyncMode) {
				if ( resp == null) resp = new Responder( delResult, defaultSqlErrorResponder);
				executeOperation( 'delete', null, resp);
			} else {
				delResult( executeOperation( 'delete'));
			}
		}
		
		public function delResult( sqe:SQLResult):void {
			debug( "delete ["+tableName+"] ["+sqe.rowsAffected+"]");
		}
		
		public function clear( resp:Responder=null):void {
			if ( asyncMode) {
				if ( resp == null) resp = new Responder( clearResult, defaultSqlErrorResponder);
				executeOperation( 'clear', null, resp);
			} else {
				clearResult( executeOperation( 'clear'));
			}
		}
		
		public function clearResult( sqe:SQLResult):void {
			debug( "clear ["+tableName+"] ["+sqe.rowsAffected+"]");
		}
		
		public function drop( resp:Responder=null):void {
			if ( asyncMode) {
				if ( resp == null) resp = new Responder( dropResult, defaultSqlErrorResponder);
				executeOperation( 'drop', null, resp);
			} else {
				dropResult( executeOperation( 'drop'));
			}
		}
		
		public function dropResult( sqe:SQLResult):void {

			this.markTableDeleted( tableName);
			debug( "drop ["+tableName+"]");
		}
		
		//----------------------------------------------------------------------------------
		
		protected function dateFromTimestamp( d:Object):Date {
			var date:Date;
			
			if ( d == null) return null;
			
			if ( d is Date) date = d as Date;
			else {
				if ( String( d).indexOf(":") >= 0) date = new Date( String( d ).split("-").join("/"));
				else {
					var ds:Number = parseFloat( String( d)) * 1000;
					date = new Date( ds);
				}
			}
			
			return date;
		}
		
		override public function toString():String {
			return "MODEL state["+state+"] cacheId["+_cache_id+"] serverId["+_id+"] mod@["+ ((_modified != null) ? _modified : '---')+"]";
		}
	}
}