package de.ms_ite.mobile.topplan.components
{
	import de.ms_ite.mobile.topplan.AppSettings;
	import de.ms_ite.mobile.topplan.callouts.ImageCallout;
	import de.ms_ite.mobile.topplan.events.TopEvent;
	
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.MediaEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.media.CameraRoll;
	import flash.media.CameraUI;
	import flash.media.MediaPromise;
	import flash.media.MediaType;
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	
	import models.SignsAction;
	import models.SignsItem;
	
	import spark.formatters.DateTimeFormatter;
	

	public class ImageFileSelector2 extends EventDispatcher {
		

		private var dataSource:IDataInput;
		
		protected var cameraRoll:CameraRoll;
		protected var cameraUI:CameraUI;
		protected var imageCallout:ImageCallout;
		
		protected var imgPromise:MediaPromise;
		//				protected var upl:File;
		
		protected var attachToItem:SignsItem = null;
		protected var uploadItem:SignsItem = null;
		protected var calloutParent:DisplayObjectContainer;
		protected var openPreview:Boolean=true;
		
		protected var uploadProgress:int;
		
		protected var fmt:DateTimeFormatter;
		
		public function ImageFileSelector2(target:IEventDispatcher=null) {
			super(target);
			
			fmt = new DateTimeFormatter();
			fmt.dateTimePattern = "yyyyMMdd_HHmmss";
		}
		
		protected function uploadInProgress():void {
			debug( "upload already in progress");
		}
		
		public function itemBrowseForFile( ati:SignsItem, cbs:DisplayObjectContainer=null, prev:Boolean=true):void {
			var f:File = AppSettings.persistantStorage.resolvePath( AppSettings.localImagePath);
			
			if ( attachToItem != null) uploadInProgress();
			
			attachToItem = ati;
			calloutParent = cbs;
			openPreview = prev;
			
			debug("attach file to ["+attachToItem+"]");

			f.addEventListener( Event.SELECT, onFileSelected);
			f.browseForOpen( "Choose a file to attach ...");
		}
		
		public function itemSelectCameraRoll( ati:SignsItem, cbs:DisplayObjectContainer=null, prev:Boolean=true):void {
			if ( CameraRoll.supportsBrowseForImage) {
				
				if ( attachToItem != null) uploadInProgress();
				
				attachToItem = ati;
				calloutParent = cbs;
				openPreview = prev;
				
				debug("camera roll ["+attachToItem+"]");
				if (cameraRoll == null) {
					
					cameraRoll = new CameraRoll();
					cameraRoll.addEventListener( MediaEvent.SELECT, handleSnapshot);
				}
				
				cameraRoll.browseForImage();
			}
		}
		
		public function itemDoSnapshot( ati:SignsItem, cbs:DisplayObjectContainer=null, prev:Boolean=true):void {
			
			if ( attachToItem != null) uploadInProgress();
			
			attachToItem = ati;
			calloutParent = cbs;
			openPreview = prev;
			
			debug( "camera shot ["+attachToItem+"]");
			
			if ( cameraUI == null) {
				cameraUI = new CameraUI();
				
				cameraUI.addEventListener( MediaEvent.COMPLETE, handleSnapshot);
			}
			
			cameraUI.launch(MediaType.IMAGE);
		}
		
		protected function handleSnapshot(event:MediaEvent):void {
			imgPromise = event.data;
			debug( "img promise: "+imgPromise);
			
			dataSource = imgPromise.open();
			if( imgPromise.isAsync ) { 
				debug( "Asynchronous media promise." ); 
				(dataSource as IEventDispatcher).addEventListener( Event.COMPLETE, onMediaLoaded ); 
			} else { 
				debug( "Synchronous media promise ["+imgPromise.file.url+"]" ); 
				uploadFileForItem( imgPromise.file); 
			}
		}
		
		private function onMediaLoaded( event:Event ):void { 
			debug("Media available"); 
			(dataSource as IEventDispatcher).removeEventListener( Event.COMPLETE, onMediaLoaded ); 
			
			var file:File;
			
			if ( imgPromise.file == null) {
				var d:Date = new Date();
				var fname:String = AppSettings.localImagePath+"/"+"IMG_"+fmt.format( d)+".jpg";
				
				debug("  creating file ["+fname+"] #"+dataSource.bytesAvailable+"."); 
				
				file = AppSettings.persistantStorage.resolvePath( fname);
				
				var fileStream:FileStream = new FileStream();
				fileStream.open(file, FileMode.WRITE);
				
				var buffer:ByteArray = new ByteArray();
				
				dataSource.readBytes( buffer);
				fileStream.writeBytes( buffer);
				
				fileStream.close();
				
				debug( "copied #["+buffer.length+"]");
			} else {
				debug( "  using file.");
				
				file = imgPromise.file;
			}
			
			uploadFileForItem( file); 
		}
		
		private function onFileSelected( evt:Event):void {
			var f:File = File( evt.target);
			
			uploadFileForItem( f);
		}
		
		private function uploadFileForItem( imgFile:File):void {					
			// upload local file
			
			//					var imgFile:File = imgPromise.file;
			
			if ( imageCallout == null) {
				imageCallout = new ImageCallout();
			}
			
			imageCallout.image = imgFile.url;
			//				data.Fotopfad = imgFile.nativePath;
			
			var rc:String = null;
			if ( AppSettings.online) {
				imageCallout.busy = true;
				
				//						uploadFile( imgFile);
				uploadItem = attachToItem;
				
				uploadItem.addEventListener( ProgressEvent.PROGRESS, onUploadProgress);
				uploadItem.addEventListener( TopEvent.UPLOAD_COMPLETE, onUploadComplete);
				
				rc = uploadItem.uploadFile( AppSettings.uploadScriptUrl, AppSettings.imageRootPath, AppSettings.imageOffsetPath, imgFile);
			}
			
			if ( openPreview) imageCallout.open( calloutParent, false);
			
			debug( "file attached ["+imgFile.url+"]");
			
			var ae:TopEvent = new TopEvent( TopEvent.ITEM_ATTACHED, true);
			ae.item = attachToItem;
			ae.cache_url = imgFile.url;
			ae.url = rc;
			
			attachToItem = null;
			
			dispatchEvent( ae);
		}
		
		private function onUploadProgress(event:ProgressEvent):void {
			var pro:int = Math.round((Number(event.bytesLoaded) / Number(event.bytesTotal)) * 100);
			if ( pro != uploadProgress) {
				debug( "  upload: "+uploadProgress+"%");
				uploadProgress = pro;
				if ( imageCallout != null) imageCallout.progress = pro;
			}
		}
		
		// Called on upload complete
		private function onUploadComplete( event:TopEvent):void {
			if ( imageCallout) imageCallout.busy = false;
			
			uploadItem.removeEventListener( ProgressEvent.PROGRESS, onUploadProgress);
			uploadItem.removeEventListener( TopEvent.UPLOAD_COMPLETE, onUploadComplete);
			
			var rcXml:XMLList = event.uploadResult.file;
			
			if ( event.type == TopEvent.UPLOAD_COMPLETE && rcXml != null && rcXml.length() > 0) {
				
				var rcFile:XML = rcXml[0];
				var local:String = rcFile.@client;
				var remote:String = rcFile.@server;
				
				if ( rcFile.@status == "ok") {
					if ( local != remote) {
//						uploadItem.url = AppSettings.imageOffsetPath+"/"+remote;
					}
				} else {
//					uploadItem.url = null;
					debug( "upload error ["+rcFile.@msg+"]");
				}
			}
			
			uploadItem = null;
			
			debug( "upload done.");
		}
		
		//===========================================================================================================
		
		protected function debug( s:String):void {
			trace( "IFS: "+s);
		}				
	}
}