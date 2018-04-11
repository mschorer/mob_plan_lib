package models {
	
	import flash.data.SQLStatement;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.AsyncToken;
	import mx.rpc.AbstractOperation;

	[RemoteClass(alias="models.SignsMapModel")]
	
	public class SignsMapModel extends SignsModel {

		protected var _cache_item_id:int = -1;
		
		protected var _item_id:int = -1;
		
		public var sort:int = -1;
		protected var _deleted:int = 0;
		
		public function SignsMapModel( preset:Object=null) {
			super( preset);
		}
/*		
		override protected function get tableName():String {
			return _tableName;
		}
*/
		override public function getInstance( p:Object):Model {
			return new SignsTagMap( p);
		}
		
		override protected function preset( p:Object):void {
			super.preset( p);
			
			_cache_item_id = ( p != null && p.cache_item_id != null) ? p.cache_item_id : -1;
			
			_item_id = ( p != null && p.item_id != null) ? p.item_id : -1;

			sort = ( p != null && p.sort != null) ? p.sort : null;
			deleted = ( p != null && p.deleted != null) ? p.deleted : 0;
		}
		
		public function set item_id( i:int):void {
			_item_id = i;
		}
		
		public function get item_id():int {
			return _item_id;
		}
		
		public function set deleted( b:Object):void {
/*
			if ( b is Boolean) _deleted = ( b as Boolean) ? 1 : 0;
			else if ( b is String) _deleted = (( b as String).toLowerCase().charAt() == 't'? 1 : 0;
				else if ( b is int) _deleted = ( b as int) ? 1 : 0;
*/
			_deleted = b ? 1 : 0;
		}
		public function get deleted():Object {
			return (_deleted == 1);
		}
		
		public function set cache_item_id( i:int):void {
			_cache_item_id = i;
		}
		
		public function get cache_item_id():int {
			return _cache_item_id;
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

				case 'delete':
					return ao.send( tableName, id);
					break;
*/				
				case 'list':
					at = ao.send( item_id, _pageSizeRemote, _pageOffsetRemote, modified);
					break;
			}
			
			if ( at == null) at = super.execServiceCall( ao, method, token);
			
			return at;
		}
		
		override protected function getOperationName( method:String):String {
			var mthd:String = '';
			switch( method) {
				case 'delete': mthd = 'deleteById'; break;

				case 'sync':
				case 'save': mthd = 'saveMapTag'; break;
				case 'list': mthd = 'getMapTags'; break;
				
				default:
					mthd = method;
			}
			
			return mthd;
		}
		
		//----------------------------------------------------------------------------------
		
		override protected function getSql( tag:String, parms:RetrievalParameters=null):String {
			var sql:String = null;
			
//			var conds:Array = getStmtConditions( parms);

			switch( tag) {
				case 'create':
					break;
				
				case 'insert':
				case 'update':
					break;
				
				case 'delete':
					sql = "UPDATE "+tableName+" SET deleted=1, modified=:MODIFIED WHERE cache_id=:CACHE_ID";
					break;
				case 'select':
					sql = "SELECT * FROM "+tableName+" WHERE cache_id=:CACHE_ID";
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
					stmt.parameters[':CACHE_ITEM_ID'] = _cache_item_id;
					stmt.parameters[':ITEM_ID'] = _item_id;

					stmt.parameters[':SORT'] = sort;
					stmt.parameters[':DELETED'] = deleted;
					break;
				
				case 'delete':
					stmt.parameters[':MODIFIED'] = _modified;
					break;
				
				case 'select':
					stmt.parameters[':CACHE_ID'] = _cache_id;
					break;
				
				case 'list':
					setStmtParams( stmt, parms);
					break;
				case 'clear':
					break;
			}
		}
		
		override public function toString():String {
			return "itemMAP deleted["+((deleted == 1) ? 'Y' : 'N')+"] "+super.toString();
		}
	}
}