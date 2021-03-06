/*

(c) by ms@ms-ite.org

v0.1

todo:
- rework to be a true v2 component

v0.1: startet v2 development			(20060215)
*/

package de.ms_ite.maptech.cache {
	
	import com.adobe.crypto.MD5;
	
	import de.ms_ite.maptech.ILoadQueue;
	import de.ms_ite.maptech.TileInfo;
	import de.ms_ite.maptech.cache.TileInfoPreloading;
	import de.ms_ite.maptech.mapinfo.MapInfo;
	import de.ms_ite.mobile.topplan.AppSettings;
	
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.*;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.SecurityErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.*;
	
	import spark.components.Image;
	import spark.core.ContentRequest;
	import spark.core.IContentLoader;
	
	public class LoadQueueCaching extends EventDispatcher implements ILoadQueue {
		
		protected var _fileCache:Dictionary;
		protected var _loaderCache:Dictionary;
		
		protected var waitqueues:Array;
		
		public var bytesTotal:int = 0;		
		public var bytesLoaded:int = 0;
		protected var tilesLoading:int = 0;
		protected var tilesRatio:Number = 0;
		
		public var PARLOADS:Number = 2;
		
		public function LoadQueueCaching() {
			super();
			
			_fileCache = new Dictionary();
			_loaderCache = new Dictionary();
			
			waitqueues = new Array();
			
			debug( "createPreloadComponent");
		};
		
		// return the queue status
		public function isEmpty():Boolean {
			for( var i:int=0; i < waitqueues.length; i++) {
				if (( waitqueues[i] != null) ? (waitqueues[ i].length > 0) : false) return false;
			}
			return true;
		}
		
		public function queue( tile:TileInfo, prio:int=0, sort:int=0):Boolean {

			var tileUrl:String = tile.url;
			
			var cUrl:Object = _fileCache[ tileUrl];
			
			if ( cUrl == null && ! tile.isCached()) {
//				debug( "queue[post]"+tile.key());
				
				queueWaiting( tile, prio);
				fillLoadQueue();
				
				_fileCache[ tileUrl] = tile;
				
				bytesTotal++;
				
				return true;
			} else {
				debug( "queue[now] "+tile.key());
				tile.load();
				
				return false;
			}
			
//			postComplete();
		}
		
		protected function postComplete():void {
			dispatchEvent( new Event( Event.COMPLETE));
		}
		
		// add to the load queue
		protected function queueLoading( tile:TileInfo, prio:int=0, tag:String=null):void {
			
			var tileUrl:String = tile.url as String;
			
			if ( tile.isCached()) {
				tile.load();
				debug( "  load[cached] "+tile.key());
			} else {
				debug( "  load[xfer] "+tile.key());
				var loader:URLLoader = new URLLoader();
				loader.dataFormat = URLLoaderDataFormat.BINARY;
				
				loader.addEventListener( Event.COMPLETE, tileDone);
				loader.addEventListener( ProgressEvent.PROGRESS, tileProgress);
				loader.addEventListener( IOErrorEvent.IO_ERROR, tileError);
				loader.addEventListener( SecurityErrorEvent.SECURITY_ERROR, tileError);
				
				loader.load( new URLRequest( tileUrl));
	
				_loaderCache[ loader] = tileUrl;
				
				tilesLoading++;
			}
		}
		
		// add to the wait queue
		protected function queueWaiting( tile:TileInfo, prio:int=0):void {
//			debug( "w "+tile.key()+" / "+tilesLoading);
			if ( waitqueues[ prio] == null) waitqueues[ prio] = new Array();
			waitqueues[ prio].push( tile);
		}
		
		public function unqueue( tile:TileInfo, prio:int=0):void {
			var j:Number = 0;
			
			if ( waitqueues[ prio] == null) return;
			
			var i:int = waitqueues[ prio].indexOf( tile);
			
			if ( i >= 0) {
				debug( "cancel "+tile.key());
				waitqueues[ prio].splice( i, 1);
				bytesTotal--;
			}
		}
		
		// clear the wait-queue, loading tiles are untouched
		public function clear():void {
			for( var i:int=0; i < waitqueues.length; i++) {
				waitqueues[i] = null;
			}
			
			bytesTotal = 0;
			bytesLoaded = 0;
			tileDone( null);
			debug( "clearQueue");
		};
		
		public function getTileInfo( img:Image, mi:MapInfo, lay:int, x:int, y:int):TileInfo {
			return new TileInfoCaching( AppSettings.persistantStorage, img, mi, lay, x, y);
		}
		
		public function clearCache():void {
			var tic:TileInfoCaching = TileInfoCaching( getTileInfo( null, null, -1, -1, -1));
			tic.removeDB();
			
			_fileCache = new Dictionary();
		}
		
		public function clearCacheLayer( mi:MapInfo):void {
			
			var tic:TileInfoCaching = TileInfoCaching( getTileInfo( null, mi, -1, -1, -1));
			tic.clearLayerDB();
			
			// remove 
			for ( var key:Object in _fileCache) {
				var ti:TileInfoCaching = TileInfoCaching( _fileCache[ key]);
				if ( ti.layerName == mi.name) {
					delete _fileCache[ key];
				}
			}
		}
		
		//-----------------------------------------------------------------
		
		protected function tileDone( evt:Event):void {
			var ld:URLLoader = URLLoader( evt.target);
			loadDone( ld);
		}
		
		protected function tileFinished( evt:Event):void {
			var ld:URLLoader = URLLoader( evt.target);
			loadDone( ld);
		}

		protected function tileProgress( evt:ProgressEvent):void {
			var ld:URLLoader = URLLoader( evt.target);
			
			tilesRatio = (evt.bytesTotal != 1) ? ( evt.bytesLoaded / evt.bytesTotal) : 1;
//			debug( "  % "+tilesRatio);
		}
		
		protected function tileError( evt:Event):void {
			var ld:URLLoader = URLLoader( evt.target);
			error( "  err: "+_loaderCache[ ld]+" : "+evt.toString());
			loadDone( ld);
		}
		
		protected function loadDone( ld:URLLoader):void {
			
			tilesLoading--;			
			bytesLoaded++;
			
			ld.removeEventListener( Event.COMPLETE, tileDone);
			ld.removeEventListener( ProgressEvent.PROGRESS, tileProgress);
			ld.removeEventListener( IOErrorEvent.IO_ERROR, tileError);
			ld.removeEventListener( SecurityErrorEvent.SECURITY_ERROR, tileError);
			
			var url:String = _loaderCache[ ld];
			
			delete _loaderCache[ ld];
			
			var tile:TileInfoCaching = _fileCache[ url];
			if ( tile != null) {
				tile.save( ld.data);
				debug( "cached "+tile.key());
			}
			
//			debug( "= "+tile.key()+" : "+tile.localUrl);
						
			fillLoadQueue();
		}
		
		protected function fillLoadQueue():Boolean {
			
			var rc:Boolean = false;
			
			if ( tilesLoading >= PARLOADS) return rc;
			
			// fill queue
			for( var i:int=0; i < waitqueues.length; i++) {
				if (((waitqueues[i] != null) ? ( waitqueues[i].length > 0) : false)) {
					
					Array( waitqueues[i]).sortOn( ['sort']);
					
					while( tilesLoading < PARLOADS && waitqueues[i].length > 0) {
						var tile:TileInfo = TileInfo( waitqueues[i].shift());
						//						error( "next("+i+"): "+tile.source);
						queueLoading( tile, i);
						
						rc = true;
					}
				}
			}
			var pe:ProgressEvent = new ProgressEvent( ProgressEvent.PROGRESS);
			pe.bytesLoaded = bytesLoaded;
			pe.bytesTotal = bytesTotal;
			dispatchEvent( pe);
			
			if ( bytesLoaded == bytesTotal) {
				bytesLoaded = bytesTotal = 0;
				
				dispatchEvent( new Event( Event.COMPLETE));
			}
			
			return rc;
		}
		
		// print debug messages
		protected function debug( txt:String):void {
//			trace( "LQC: "+txt);
		};
		protected function error( txt:String):void {
			//			trace( "ERR LQC: "+txt);
		};
	}			
}
//==================================================