package de.ms_ite.mobile.topplan.sync
{
	import flash.events.EventDispatcher;
	
	import models.SignsModel;

	public class SyncQueue extends EventDispatcher
	{
		protected var asyncOpsQueue:Array;
		protected var asyncOpsModel:SignsModel;
		
		protected static var PAGESIZE_ALL:int			= -1;
		protected static var PAGESIZE_DOWN:int			= 100;
		protected static var PAGESIZE_DOWN_SMALL:int	= 250;
		protected static var PAGESIZE_PASS2:int			= 50;
		
		public function SyncQueue()
		{
		}
	}
}