package models {
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	
	import mx.collections.ArrayCollection;

	[RemoteClass(alias="models.SignsContentModel")]

	public class SignsContentModel extends SignsModel {

		protected var _created:Date;
		
		public var name:String;
		public var description:String;
		
		public function SignsContentModel( p:Object=null) {
			super( p);
		}
		
		override public function getInstance( p:Object):Model {
			return new SignsContentModel( p);
		}
		
		override protected function preset( p:Object):void {
			super.preset( p);
			
			created = ( p != null && p.created != null) ? p.created : null;
			
			name = ( p != null && p.name != null) ? p.name : null;
			description = ( p != null && p.description != null) ? p.description : null;
		}

		public function set created( d:Object):void {
			if ( d != null) _created = ( d is Date) ? ( d as Date) : dateFromTimestamp( d);
		}
		
		public function get created():Object {
			return _created;
		}
		
		//----------------------------------------------------------------------------------
		
		override protected function existsInDB():Boolean {
			return ( state == STATE_LOCAL || state == STATE_SYNCED);
		}
		
		override protected function getSql( tag:String, parms:RetrievalParameters=null):String {
			var sql:String;
			
			var conds:String = RetrievalParameters.getCondition( parms);
			
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
					stmt.parameters[':CREATED'] = _created;

					stmt.parameters[':NAME'] = name;
					stmt.parameters[':DESCRIPTION'] = description;
					break;
				
				case 'delete':
					break;
				
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
		
		//----------------------------------------------------------------------------------
		
		override public function toString():String {
			return super.toString()+" CONTENT name["+name+"] desc["+description+"] cre@["+((_created != null) ? _created : '---')+"]";
		}
	}
}