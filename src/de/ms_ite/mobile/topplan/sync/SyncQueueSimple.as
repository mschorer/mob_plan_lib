package de.ms_ite.mobile.topplan.sync
{
	import de.ms_ite.mobile.topplan.events.TopEvent;
	import de.ms_ite.mobile.topplan.tools.IdLookup;
	
	import models.SignsModel;
	
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;

	public class SyncQueueSimple extends SyncQueue {
		
		protected var idCache:IdLookup;
		
		public function SyncQueueSimple( idc:IdLookup) {
			idCache = idc;
		}
		
		protected function sync( modified:Date=null):void {
			if ( asyncOpsQueue.length <= 0) {
				dispatchEvent( new TopEvent( TopEvent.QUEUE_DONE));
				return;
			}
			
			asyncOpsModel = asyncOpsQueue.shift();
			
			if ( modified == null) {
				asyncOpsModel.clear();
				asyncOpsModel.modified = null;
			} else {
				asyncOpsModel.modified = modified;
			}
			
			var te:TopEvent = new TopEvent(TopEvent.QUEUE_LOADING);
			te.source = asyncOpsModel;
			dispatchEvent( te);
			
			asyncOpsModel.pageOffsetRemote = 0;
			asyncOpsModel.pageSizeRemote = PAGESIZE_DOWN;				
			
			debug( typeof( asyncOpsModel)+" ["+asyncOpsModel.modified+"]");
			asyncOpsModel.callService( 'list', processTlRemoteBlock, faultHandler);
		}
		
		protected function processTlRemoteBlock( evt:ResultEvent, token:Object=null):void {
			asyncOpsQueue = evt.result as Array;
			
			//				debug( "  - owners #["+ores.length+"/"+ownerModel.pageOffsetRemote+"]");
			processTlLocalQueue();
		}
		
		protected function processTlLocalQueue():void {
			if ( asyncOpsQueue.length <= 0) doneTlRemoteBlock();
			
			saveContent( asyncOpsQueue[0]);
		}
		
		protected function saveContent( si:SignsModel):void {
			
			//TODO insert async
			var cid:int = idCache.globalToCache( si, si.id);

			if ( cid >= 0) {
				si.cache_id = cid;
			}
			
			si.cache_modified = si.modified;
			
			//TODO insert async
			si.save();
		}
		
		protected function doneTlLocalItem():void {
			var res:SignsModel = asyncOpsQueue.shift();
			
			idCache.cache( res);
			
			processTlLocalQueue();
		}
		
		protected function doneTlRemoteBlock():void {
			
			asyncOpsModel.pageOffsetRemote += asyncOpsQueue.length;
			
			var te:TopEvent = new TopEvent(TopEvent.QUEUE_PROGRESS);
			te.source = asyncOpsModel;
			te.done = asyncOpsModel.pageOffsetRemote;
			dispatchEvent( te);
			
			if ( asyncOpsQueue.length == asyncOpsModel.pageSizeRemote) {
				
				asyncOpsModel.callService( 'list', processTlRemoteBlock, faultHandler);
				//					debug( "next ...");
			} else {
				te = new TopEvent(TopEvent.QUEUE_DONE);
				te.source = asyncOpsModel;
				dispatchEvent( te);
				
				debug( "done.");
				sync();
			}
		}
		
		private function faultHandler( fault:FaultEvent, token:Object=null):void {
			var emsg:String = "-------------------------------------------------\n";
			emsg += "token  : " + token + "\n";
			//				emsg += "err    : " + fault + "\n";
			emsg += "code   : " + fault.fault.faultCode + "\n";
			emsg += "message: " + fault.fault.faultString + "\n";
			emsg += "detail : " + fault.fault.faultDetail + "\n";
			emsg += "-------------------------------------------------\n";
			
			debug( emsg);
		}
		
		protected function debug( m:String):void {
			trace( "SyncQueueSimple: "+m);
		}
	}
}