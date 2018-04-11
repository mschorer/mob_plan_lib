package models {
	
	import de.ms_ite.mobile.topplan.AppSettings;
	import de.ms_ite.mobile.topplan.events.TopEvent;
	
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.data.SQLMode;
	import flash.errors.SQLError;
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SQLErrorEvent;
	import flash.events.SQLEvent;
	import flash.events.SecurityErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Point;
	import flash.net.Responder;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLStream;
	import flash.net.URLVariables;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	import mx.messaging.ChannelSet;
	import mx.messaging.channels.AMFChannel;
	import mx.rpc.AbstractOperation;
	import mx.rpc.AsyncResponder;
	import mx.rpc.AsyncToken;
	import mx.rpc.Responder;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.remoting.RemoteObject;
	import mx.utils.UIDUtil;
	
	public class Model extends EventDispatcher {
		
		public static var serviceURL:String = "http://app.topplan.de/amf/index.php";
		public static var serviceName:String = "Default";

		public static var dbFile:String = "default.sq3";

		public static var asyncMode:Boolean = false;
		
		public static var dumpSQL:Boolean = false;
		
		protected static var dbConn:SQLConnection;
		protected static var rObject:RemoteObject;
		protected static var initializedTables:Dictionary = new Dictionary();
		protected static var connected:Boolean = false;
		
		protected static var statementMap:Object = new Object();
		
		protected var upldFile:File;
		protected var fileStream:FileStream;
		
		protected var _pageSizeRemote:int = -1;
		protected var _pageOffsetRemote:int = 0;

		protected var _pageSizeLocal:int = -1;
		protected var _pageOffsetLocal:int = 0;
		
		public function Model( p:Object=null) {
			if ( p != null) preset( p);
		}		

		public function getInstance( p:Object):Model {
			return new Model( p);
		}
		
		protected function preset( p:Object):void {
		}
		
		public function clone():Model {			
			var cp:Model = getInstance( this);

			return cp;
		}
		
		public function validate():Boolean {
			return true;
		}
		
		//================================================================================================
		
		public function set pageSizeRemote( s:int):void {
			_pageSizeRemote = s;
		}
		public function get pageSizeRemote():int {
			return _pageSizeRemote;
		}

		public function set pageOffsetRemote( s:int):void {
			_pageOffsetRemote = s;
		}
		public function get pageOffsetRemote():int {
			return _pageOffsetRemote;
		}
		
		public function set pageSizeLocal( s:int):void {
			_pageSizeLocal = s;
		}
		public function get pageSizeLocal():int {
			return _pageSizeLocal;
		}
		
		public function set pageOffsetLocal( s:int):void {
			_pageOffsetLocal = s;
		}
		public function get pageOffsetLocal():int {
			return _pageOffsetLocal;
		}
		
		//================================================================================================

		public function initRemoting():void {
			if ( rObject == null) {
				rObject = new RemoteObject();
				
				var channelSet:ChannelSet = new ChannelSet();
				var amfChannel:AMFChannel = new AMFChannel( "amfphp", Model.serviceURL);
				channelSet.addChannel( amfChannel);
				
				rObject.channelSet = channelSet;
				rObject.destination = "amfphp";
				
				rObject.source = Model.serviceName;

				debug( "remoting intialized. ["+Model.serviceURL+"]["+Model.serviceName+"]");
			}
		}
		
		// general fault handler
		
		public function faultHandler( fault:FaultEvent, token:Object=null):void {
			error( "err: "+fault);
			error( "obj: "+this.toString());
			error( "code:\n" + fault.fault.faultCode + "\n\nMessage:\n" + fault.fault.faultString + "\n\nDetail:\n" + fault.fault.faultDetail);				
			error( "service error!");
		}
		
		//----------------------------------------------------------------------------------------
		
		public function callService( method:String, result:Function, fault:Function=null, token:Object=null):void {
//			debug( "callService ["+method+"]");
			initRemoting();
			
			if ( fault == null) fault = faultHandler;
			
//			method = getOperationName( method);
			
			var ro:AbstractOperation = rObject.getOperation( getOperationName( method));
			
			var rpcCall:AsyncToken = execServiceCall( ro, method, token);

			// attach the token-attributes
			if ( token != null) {
				for ( var tag:String in token) {
					rpcCall[ tag] = token[ tag];
				}
			}
			
			rpcCall.addResponder( new AsyncResponder( result, fault, rpcCall));
		}
		
		protected function execServiceCall( ao:AbstractOperation, method:String, token:Object):AsyncToken {
			return null;
		}

		protected function getOperationName( method:String):String {
			return null;
		}

		//================================================================================================
		
		public static function initLocalDB( resp:flash.net.Responder=null):Boolean {
			//error( "open db ["+asyncMode+"]");
			
			var freshlyOpened:Boolean = false;
			
			if ( dbConn == null) {
				dbConn = new SQLConnection();
				dbConn.addEventListener( SQLEvent.OPEN, openDBSuccess);
				dbConn.addEventListener( SQLErrorEvent.ERROR, openDBError);
				//			dbConn.addEventListener(SQLEvent.BEGIN, beginDBHandler);
				dbConn.addEventListener( SQLEvent.CLOSE, closeDBSuccess);

				var dbf:File = AppSettings.databaseStorage.resolvePath( Model.dbFile);

				if ( asyncMode) dbConn.openAsync( dbf, SQLMode.CREATE, resp);
				else dbConn.open( dbf);
				
				freshlyOpened = true;
				error( "db inited. ["+Model.dbFile+"] ["+(asyncMode ? "ASYNC" : "SYNC")+"]");
			}
			
//			error( "db open.");
			
			return freshlyOpened;
		}
		
		protected static function openDBSuccess(event:SQLEvent):void {
			error("openConn: the database opened successfully");
			
			connected = true;
		}
		
		protected static function closeDBSuccess(event:SQLEvent):void {
			error("closeConn: the database closed successfully");
			
			connected = false;
		}
		
		protected static function openDBError(event:SQLErrorEvent):void {
			error("connError msg:"+event.error.message);
			error("             :"+event.error.details);
		}
		
		public static function closeLocalDB( resp:flash.net.Responder=null):Boolean {
			error( "  db close ...");

			initializedTables = new Dictionary();
			
			for ( var sqlCmd:String in statementMap) {
				var stObj:SQLStatement = statementMap[ sqlCmd] as SQLStatement;
//				error( "  sqlCache clean ["+(stObj.executing ? "R" : '_')+"] ["+sqlCmd+"]");
				stObj.cancel();
			}
			statementMap = new Object();
						
			if ( dbConn != null) {
				dbConn.close( resp);
				
				error( ( resp == null) ? "close sync." : "close async.");
				dbConn = null;
				
				return ( resp == null);
			}
			error( "already closed.");
			
			return true;
		}
		
		public function get tableName():String {
			return null;
		}
		
		protected function createTableForModel( ):void {
			debug( "create table ["+tableName+"]");

			// mark created or else we'll loop back in here
			if ( tableName != null) initializedTables[ tableName] = true;
			
			executeOperation( 'create');
		}
		
		protected function markTableDeleted( tableName:String):void {
			delete initializedTables[ tableName];
		}
		
		public function defaultSqlErrorResponder( err:SQLError):void {
			error("stmtErrorResp msg:"+err.message);
			error("             :"+err.details);
		}

		protected function executeOperation( sqlTag:String, parms:RetrievalParameters=null, resp:flash.net.Responder=null):SQLResult {
			var rc:SQLResult;
			
			initLocalDB();
			
			if ( initializedTables[ tableName] == null) createTableForModel();
			
			var sqlCmd:String = getSql( sqlTag, parms);
			var sqlList:Array = sqlCmd.split(";");

			for( var i:int = 0; i < sqlList.length; i++) {
				var cmd:String = sqlList[i];
				if ( cmd.length > 0) rc = executeSingleOperation( sqlTag, cmd, parms, (i < sqlList.length-1) ? null : resp);
			}
			
			return rc;
		}
		
		protected function executeSingleOperation( sqlTag:String, sqlCmd:String, parms:RetrievalParameters=null, resp:flash.net.Responder=null):SQLResult {
			
			var stmt:SQLStatement;
			var stObj:Object = statementMap[ sqlCmd];
			
			if ( stObj == null) {
				stmt = new SQLStatement();
				stmt.sqlConnection = dbConn;
				
				stmt.text = sqlCmd;
				
				statementMap[ sqlCmd] = stmt;
			} else stmt = SQLStatement( stObj);
			
			addSqlParameters( stmt, sqlTag, parms);
			
			if ( dumpSQL) trace( "exec: ["+(( resp != null) ? 'X' : '-')+"] ["+stmt.text+"]");
			stmt.execute( _pageSizeLocal, resp);
//			if ( resp == null) debug( "    affected ["+stmt.getResult().rowsAffected+"]");
			
			return (resp == null) ? stmt.getResult() : null;			
		}

		protected function getStatement( sqlTag:String, parms:RetrievalParameters=null):SQLStatement {

			var sqlCmd:String = getSql( sqlTag, parms);			
			var stmt:SQLStatement = SQLStatement( statementMap[ sqlCmd]);

			return stmt;
		}
		
		protected function setStmtParams( stmt:SQLStatement, parms:RetrievalParameters=null):void {
			if ( parms != null && parms.conditions != null) {
				for ( var parm:String in parms.conditions) {
					// no explicit parameters
					if ( parm.indexOf( " ") < 0) {
						stmt.parameters[ ":"+parm.toUpperCase()] = parms.conditions[ parm];
					}
				}
			}			
		}
		
		protected function getSql( tag:String, parms:RetrievalParameters=null):String {
			var sql:String;
			
			switch( tag) {
				case 'create':

				case 'insert':
				case 'update':

				case 'delete':
				case 'select':

				case 'list':
				case 'count':
					
				case 'clear':
				case 'drop':
			}
			
			return sql;
		}
		
		protected function addSqlParameters( stmt:SQLStatement, tag:String, parms:RetrievalParameters=null):void {
			switch( tag) {
				case 'create':

				case 'insert':
				case 'update':

				case 'delete':
				case 'select':
				
				case 'list':
				case 'count':
					
				case 'clear':
				case 'drop':
			}
		}

		protected function existsInDB():Boolean {
			return false;
		}

		//----------------------------------------------------------------------------------------------
		
		public function downloadFile( remote:String, file:File):File {

			var urlStream:URLStream = new URLStream();
			var request:URLRequest = new URLRequest( remote);
			if ( fileStream == null) fileStream = new FileStream();
			
			urlStream.addEventListener( Event.COMPLETE, downloadDone);
			urlStream.addEventListener( ProgressEvent.PROGRESS, copyBytes);
			urlStream.addEventListener( IOErrorEvent.IO_ERROR, downloadFailed);
			
			var rc:File = file;
			try {
				fileStream.open( file, FileMode.WRITE);
			
				debug( "dl ["+file.url+" / "+request.url+"]");
			
				urlStream.load(request);
			} catch( e:Error) {
				debug( "cannot open ["+file.url+" for "+request.url+"] "+e.toString());

				urlStream.removeEventListener( Event.COMPLETE, downloadDone);
				urlStream.removeEventListener( ProgressEvent.PROGRESS, copyBytes);
				urlStream.removeEventListener( IOErrorEvent.IO_ERROR, downloadFailed);

				//urlStream.close();
				rc = null;
			}
			
			return rc;
		}
		
		protected function cancelDownload():void {
			dispatchEvent( new Event( Event.COMPLETE));
		}
		
		protected function copyBytes( evt:ProgressEvent):void {
			var inStream:URLStream = URLStream( evt.target);
			
//			debug( "  dl ["+inStream.bytesAvailable+" / "+evt.bytesLoaded+" / "+evt.bytesTotal+"]");
			
			var dataBuffer:ByteArray = new ByteArray();
			inStream.readBytes(dataBuffer, 0, inStream.bytesAvailable);
			fileStream.writeBytes(dataBuffer, 0, dataBuffer.length);
			
			dispatchEvent( new ProgressEvent( ProgressEvent.PROGRESS,true,false,evt.bytesLoaded,evt.bytesTotal));
		}
		
		protected function downloadDone( evt:Event):void {
			var inStream:URLStream = URLStream( evt.target);
			
			debug( "dl done.");
			
			inStream.removeEventListener( Event.COMPLETE, downloadDone);
			inStream.removeEventListener( ProgressEvent.PROGRESS, copyBytes);
			inStream.removeEventListener( IOErrorEvent.IO_ERROR, downloadFailed);			
			
			fileStream.close();
			inStream.close();
			
			dispatchEvent( new Event( Event.COMPLETE));
		}

		protected function downloadFailed( evt:Event):void {
			var inStream:URLStream = URLStream( evt.target);
			
			error( "ERROR: "+evt.toString());
			
			try {
				fileStream.close();
				inStream.close();
			} catch( e:Error) {
			}
			
			inStream.removeEventListener( Event.COMPLETE, downloadDone);
			inStream.removeEventListener( ProgressEvent.PROGRESS, copyBytes);
			inStream.removeEventListener( IOErrorEvent.IO_ERROR, downloadFailed);			

			dispatchEvent( new Event( Event.COMPLETE));
		}
		
		//================================================================================================

		public function uploadFile( remoteScript:String, remoteBasePath:String, remoteOffsetPath:String, up:File):String {
			var sendVars:URLVariables = new URLVariables();
			sendVars.action = "upload";
			sendVars.path = remoteBasePath+'/'+ remoteOffsetPath;		// AppSettings.imageRootPath+"/"+AppSettings.imageOffsetPath;
			
			var request:URLRequest = new URLRequest(); 
			request.data = sendVars;
			request.url = remoteScript;
			request.method = URLRequestMethod.POST;
			request.contentType = "application/octet-stream";
			
			if ( upldFile != null) {
				upldFile.removeEventListener(ProgressEvent.PROGRESS, onUploadProgress);
				upldFile.removeEventListener(Event.COMPLETE, onUploadComplete);
				upldFile.removeEventListener(DataEvent.UPLOAD_COMPLETE_DATA, onUploadDataComplete);
				upldFile.removeEventListener(IOErrorEvent.IO_ERROR, onUploadIoError);
				upldFile.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onUploadSecurityError);						
			}
			upldFile = up;

			upldFile.addEventListener(ProgressEvent.PROGRESS, onUploadProgress);
			upldFile.addEventListener(Event.COMPLETE, onUploadComplete);
			upldFile.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA, onUploadDataComplete);
			upldFile.addEventListener(IOErrorEvent.IO_ERROR, onUploadIoError);
			upldFile.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onUploadSecurityError);
			
			debug( "uploading: "+upldFile.nativePath+" / "+upldFile.size);
			
			upldFile.upload( request, "file", false);
			
			return remoteOffsetPath+'/'+up.name;
		}
		
		// Get upload progress
		private function onUploadProgress(event:ProgressEvent):void {
			dispatchEvent( event);
			debug( "  upload "+ Math.round((Number(event.bytesLoaded) / Number(event.bytesTotal)) * 100)+"%");
		}
		
		// Called on upload complete
		private function onUploadComplete(event:Event):void {
//			dispatchEvent( new Event( Event.COMPLETE));
			debug( "upload done.");
		}
		
		private function onUploadDataComplete(event:DataEvent):void {
			var res:XML;
			try {
				res = new XML( event.data);
			} catch( e:Error) {
				res = new XML( '<results><error status="error" error="result parsing error"/></results>');
			}
			var te:TopEvent = new TopEvent( TopEvent.UPLOAD_COMPLETE);
			te.uploadResult = new XML( event.data);
			debug( "upload data done ["+te.uploadResult.toString()+"]");
			
			dispatchEvent( te);
		}
		
		// Called on upload io error
		private function onUploadIoError(event:IOErrorEvent):void {
			error("IO Error in uploading file: "+event);
		}
		
		// Called on upload security error
		private function onUploadSecurityError(event:SecurityErrorEvent):void {
			error("Security Error in uploading file: "+event);
		}
		
		//===========================================================================================================
		
		override public function toString():String {
			return "mModel["+dbConn+"] ["+rObject+"]";
		}
		
		protected static function debug( txt:String):void {
//			trace( "mdlDBG: "+txt);
		}

		public static function error( txt:String):void {
			trace( "mdlERR: "+txt);
		}
	}
}