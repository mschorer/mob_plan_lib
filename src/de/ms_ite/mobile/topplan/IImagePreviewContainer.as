package de.ms_ite.mobile.topplan {
	import flash.display.DisplayObjectContainer;
	
	import spark.components.SkinnableContainer;

	public interface IImagePreviewContainer {
		
		function set title( s:String):void;
		function set image( dest:Object):void;
		function set busy( b:Boolean):void;
		function set progress( p:int):void;
		function show(owner:DisplayObjectContainer, modal:Boolean = false):void;
	}
}