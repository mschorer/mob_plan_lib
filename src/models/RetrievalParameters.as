package models {
	
	public class RetrievalParameters {
		
		public var fields:Array;
		
		public var tables:Array;
		
		public var conditions:Object;
		public var andMode:Boolean;
		
		public var limit:String;
		
		public var group:String;
		
		public var order:String;
		
		public var cachable:Boolean;
		
		public function RetrievalParameters( cond:Object=null, am:Boolean=true, ord:String=null, lim:String=null, grp:String=null) {
			conditions = cond;
			andMode = am;
			
			order=ord;
			limit=lim;
			group=grp;
		}
		
		public function toString():String {
			var s:String = "RetSpec[\n";
			s += "  tables[ "+getTables( this)+"]\n";
			s += "  fields[ "+getFields( this)+"]\n";
			s += "  conds[ "+getCondition( this)+"]\n";
			s += "  order[ "+getOrder( this)+"]\n";
			s += "  limit[ "+getLimit( this)+"]\n";
			s += "  group[ "+getGroup( this)+"]\n";
			s += "]";
			
			return s;
		}
		
		public static function getFields( parms:RetrievalParameters=null):String {
			if ( parms == null || parms.fields == null) return '';
			else {
				var fields:Array = new Array();
				for each ( var parm:Object in parms.fields) {
					
					fields.push( getAttributes( parm));
				}
				
				return fields.join( ", ");
			}
		}
		
		protected static function getAttributes( parms:Object=null):String {
			if ( parms == null) return '';
			else {
				var fields:Array = new Array();
				for ( var parm:String in parms) {
					
					fields.push( (( String( parms[parm]).length > 0) ? (parms[parm]+" AS ") : '')+parm);
				}
				
				return fields.join( ", ");
			}
		}
		
		protected static function getTList( parms:Object=null):String {
			if ( parms == null) return '';
			else {
				var fields:Array = new Array();
				for ( var parm:String in parms) {
					
					fields.push( parm+(( String( parms[parm]).length > 0) ? (' '+parms[parm]) : ''));
				}
				
				return fields.join( ", ");
			}
		}
		
		public static function getTables( parms:RetrievalParameters=null):String {
			if ( parms == null || parms.tables == null || parms.tables.length == 0) return '';
			else {
				var tables:Array = new Array();
				for each( var table:Object in parms.tables) {					
					tables.push( getTList( table));
				}
				
				return tables.join( ", ");
			}
		}
		
		public static function getCondition( parms:RetrievalParameters=null):String {
			if ( parms == null || parms.conditions == null) return '';
			else {
				var conds:Array = new Array();
				for ( var parm:String in parms.conditions) {
					
					// if we have operators in column name
					if ( parm.indexOf( " ") >= 0) {
						
						if ( parms.conditions[ parm] == null) {
							// no parameter, like "... IS NOT NULL"
							conds.push( parm);
						} else {
							// explicit parameter
							conds.push( parm+parms.conditions[ parm]);								
						}
					} else {
						conds.push( parm+"=:"+parm.toUpperCase());	
					}
				}
				
				return conds.join( parms.andMode ? " AND " : " OR ");
			}
		}

		public static function getLimit( parms:RetrievalParameters=null):String {
			if ( parms == null || parms.limit == null) return '';
			else {
				return parms.limit;
			}
		}

		public static function getOrder( parms:RetrievalParameters=null):String {
			if ( parms == null || parms.order == null) return '';
			else {
				return parms.order;
			}
		}
		
		public static function getGroup( parms:RetrievalParameters=null):String {
			if ( parms == null || parms.group == null) return '';
			else {
				return parms.group;
			}
		}
	}
}