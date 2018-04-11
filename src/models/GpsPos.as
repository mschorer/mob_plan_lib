package models {
	import flash.events.GeolocationEvent;
	
	public class GpsPos {
		
		public var mx_internal_uid:String;
		
		public var title:String;
		
		public var latitude:Number;
		public var longitude:Number;
		public var altitude:Number = 0;
		public var horizontalAccuracy:Number = -1;
		public var verticalAccuracy:Number = -1;
		public var speed:Number = 0;
		public var heading:Number = 0;
		public var timestamp:Number = -1;
		
		public var scale:Number;
		
		public function GpsPos( obj:GeolocationEvent=null) {
			data = obj;
		}
		
		public function set data( obj:GeolocationEvent):void {
			if ( obj != null) {
				latitude = obj.latitude;
				longitude = obj.longitude;
				altitude = obj.altitude;
				horizontalAccuracy = obj.horizontalAccuracy;
				verticalAccuracy = obj.verticalAccuracy;
				speed = obj.speed;
				if ( ! isNaN( obj.heading)) heading = obj.heading;
				timestamp = obj.timestamp;
				
				scale = Math.max( horizontalAccuracy, verticalAccuracy) / 50;
			}
		}
		
		public function get location():String {
			return 'POINT( '+longitude+' '+latitude+')';
		}
		
		public function get accuracy():int {
			return horizontalAccuracy.toFixed() as int;
		}
		
		public function toString():String {
			var txt:String = ">" + heading.toFixed() + "° @"+ latitude.toPrecision(8) + 
				"," + longitude.toPrecision(8) +
				" #" + altitude.toFixed() +
				"m ["+ horizontalAccuracy.toFixed() + "m]";

/*			+
				"] @ " + speed +
				" > " + heading +
				" [" + timestamp+"]";
*/
			
			return txt;
		}
	}
}