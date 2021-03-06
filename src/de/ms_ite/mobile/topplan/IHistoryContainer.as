package de.ms_ite.mobile.topplan {
	import flash.display.DisplayObjectContainer;
	
	import models.SignsLocation;
	
	import spark.components.SkinnableContainer;

	public interface IHistoryContainer {
/*		
		function set title( s:String):void;
		function set image( dest:Object):void;
		function set busy( b:Boolean):void;
		function set progress( p:int):void;
		function show(owner:DisplayObjectContainer, modal:Boolean = false):void;
*/
		function set settings( s:XML):void;
		function show(owner:DisplayObjectContainer, modal:Boolean = false):void;
		function set location( sl:SignsLocation):void;
		function loadSettings():void;
		function saveSettings():void;
	}
}