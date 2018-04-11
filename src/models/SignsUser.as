package models {
	
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.net.Responder;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.AsyncToken;
	import mx.rpc.AbstractOperation;

	[RemoteClass(alias="models.SignsUser")]
	
	public class SignsUser extends SignsContentModel {

		protected static var _tableName:String = "users";
		
		public var userlevel:int = -1;
		
		public var username:String;
		public var password:String;

		public var email:String;

		public function SignsUser( preset:Object=null) {
			super( preset);
		}
		
		override public function get tableName():String {
			return _tableName;
		}

		override public function getInstance( p:Object):Model {
			return new SignsUser( p);
		}
		
		override protected function preset( p:Object):void {
			super.preset( p);
			
			username = ( p != null && p.username != null) ? p.username : null;
			password = ( p != null && p.password != null) ? p.password : null;
			
			userlevel = ( p != null && p.userlevel != null) ? p.userlevel : 0;
		}
		
		//----------------------------------------------------------------------------------
		
		override protected function execServiceCall( ao:AbstractOperation, method:String, token:Object):AsyncToken {
			var at:AsyncToken = null;

			switch( method) {
				case 'authenticate':
					at = ao.send( this);
					break;
/*				
				case 'sync':
					return ao.send( this, cache_modified);
					break;
				
				case 'save':
					return ao.send( this);
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
				case 'save': mthd = 'saveUser'; break;
				case 'list': mthd = 'getUsers'; break;
				
				default:
					mthd = method;
			}
			
			if ( mthd == null) mthd = super.getOperationName( method);
			
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
					"id int DEFAULT -1,"+
					"userlevel int,"+
					"username varchar(20),"+
					"password varchar(80),"+
					"email varchar(256),"+
					"name varchar(256),"+
					"description varchar(1024),"+
					"created DATETIME,"+
					"modified DATETIME"+
					");" +
					"CREATE INDEX IF NOT EXISTS "+_tableName+"_id ON "+_tableName+" ( id)";
					break;
				
				case 'insert':
					sql = "INSERT INTO "+_tableName+" ( id, userlevel, username, password, email, name, description, created, modified, cache_modified) VALUES ( :ID, :USERLEVEL, :USERNAME, :PASSWORD, :EMAIL, :NAME, :DESCRIPTION, :CREATED, :MODIFIED, :CACHE_MODIFIED)";
					break;
				case 'update':
					sql = "UPDATE "+_tableName+" SET cache_modified=:CACHE_MODIFIED, id=:ID, userlevel=:USERLEVEL, username=:USERNAME, password=:PASSWORD, email=:EMAIL, name=:NAME, description=:DESCRIPTION, created=:CREATED, modified=:MODIFIED WHERE cache_id=:CACHE_ID"+updateCond();
					break;
				
				case 'delete':
					break;
				case 'select':
					sql = "SELECT * FROM "+_tableName+" WHERE username=:USERNAME";
					break;
				
				case 'authenticate':
					sql = "SELECT * FROM "+_tableName+" WHERE username=:USERNAME AND password=:PASSWORD";
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
			
			switch( tag) {
				case 'create':
					break;
				
				case 'update':
				case 'insert':
					super.addSqlParameters( stmt, tag, parms);

					stmt.parameters[':USERLEVEL'] = userlevel;
					stmt.parameters[':USERNAME'] = username;
					stmt.parameters[':PASSWORD'] = password;
					stmt.parameters[':EMAIL'] = email;
					break;
				
				case 'delete':
					break;
				
				case 'select':
					stmt.parameters[':USERNAME'] = username;
					break;
				
				case 'authenticate':
					stmt.parameters[':USERNAME'] = username;
					stmt.parameters[':PASSWORD'] = password;
					break;
				
				case 'list':
					super.addSqlParameters( stmt, tag, parms);
					setStmtParams( stmt, parms);
					break;
				case 'clear':
					break;
				
				default:
					super.addSqlParameters( stmt, tag, parms);
			}
		}
		
		public function authenticate( resp:Responder=null):Boolean {
			if ( asyncMode) {
				if ( resp == null) resp = new Responder( verifyAuth, defaultSqlErrorResponder);
				executeOperation( 'authenticate', null, resp);	//loadDB();
				
				return false;
			} else {
				return verifyAuth( executeOperation( 'authenticate' ));
			}
		}
		
		public function verifyAuth( sqe:SQLResult):Boolean {
			var rc:Boolean = false;
			
			if ( sqe.data != null && sqe.data.length == 1) {
				preset( sqe.data[0]);
				
				//				debug( "read "+toString());
				
				rc = true;
			}
			
			return rc;
		}
		
		override public function toString():String {
			return "USER "+super.toString()+" uname["+username+"] lvl["+userlevel+"]";
		}
	}
}