package de.ms_ite.mobile.topplan.events {
	import de.ms_ite.mobile.topplan.components.ProgressBar;
	import de.ms_ite.mobile.topplan.editors.ItemEditor;
	
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	
	import models.SignsItem;
	import models.SignsLocation;
	
	public class TopEvent extends Event {

		public static var LOGIN_USER:String				= 'msite_login_user';

		public static var ITEM_NEW:String				= 'msite_item_new';
		public static var ITEM_ADD:String				= 'msite_item_add';
		public static var ITEM_EDIT:String				= 'msite_item_edit';
		public static var ITEM_SAVED:String				= 'msite_item_saved';
		public static var ITEM_SAVE_ERROR:String		= 'msite_item_save_error';
		
		public static var ITEM_ACTION:String			= 'msite_item_action';		
		public static var ITEM_ACTION_DELETE:String		= 'msite_item_action_delete';		
		public static var ITEM_ACTION_OK:String			= 'msite_item_action_ok';
		public static var ITEM_ACTION_ERROR:String		= 'msite_item_action_error';
		public static var ITEM_ACTION_DOCUMENT:String	= 'msite_item_action_document';
		
		public static var ITEM_OPTIONS:String			= 'msite_item_options';
		
		public static var ITEM_HISTORY:String			= 'msite_item_history';
		
		public static var ITEM_SNAPSHOT_PREF:String		= 'msite_item_snapshot_pref';
		public static var ITEM_SNAPSHOT:String			= 'msite_item_snapshot';
		public static var ITEM_CAMERAROLL:String		= 'msite_item_camroll';
		public static var ITEM_BROWSE:String			= 'msite_item_browse';

		public static var ITEM_ATTACHED:String			= 'msite_item_attached';

		public static var ITEM_EDITOR_COMPLETE:String	= 'msite_item_editor_complete';

		public static var LOCATION_ADD:String			= 'msite_loc_add';
		public static var LOCATION_EDIT:String			= 'msite_loc_edit';
		public static var LOCATION_SAVED:String			= 'msite_loc_saved';
		public static var LOCATION_CHANGED:String		= 'msite_loc_changed';
		
		public static var LOCATION_SAVE_ERROR:String	= 'msite_loc_save_error';
		
		public static var SYNC_DATA:String				= 'msite_sync_data';
		public static var SYNC_RESET:String				= 'msite_sync_reset';

		public static var SYNC_UP_COMPLETE:String		= 'msite_sync_up_done';
		public static var SYNC_DOWN_COMPLETE:String		= 'msite_sync_down_done';

		public static var UPLOAD_COMPLETE:String		= 'msite_upload_complete';
		public static var UPLOAD_ERROR:String			= 'msite_upload_error';
		
		public static var FORCE_RESTART:String			= 'msite_force_restart';
		
		public static var FILTER_OPEN:String			= 'msite_filter_open';
		public static var FILTER_APPLY:String			= 'msite_filter_apply';

		public static var EXPAND_LIST:String			= 'msite_expand_list';
		public static var IMAGE_ZOOM:String				= 'msite_image_zoom';

		public static var VALIDATION_OK:String			= 'msite_validation_ok';
		public static var VALIDATION_FAIL:String		= 'msite_validation_fail';

		public static var EDITOR_UPDATED:String			= 'msite_editor_updated';

		public static var SETTINGS_LOADED:String		= 'msite_settings_loaded';

		public static var QUEUE_DONE:String				= 'msite_sync_queue_empty';
		public static var QUEUE_PROGRESS:String			= 'msite_sync_queue_progress';
		public static var QUEUE_LOADING:String			= 'msite_sync_queue_loading';

		public var item_id:int		= -1;
		public var location_id:int	= -1;
		public var user_id:int		= -1;
		
		public var cache_url:String;
		public var url:String;
		
		public var item:SignsItem;
		public var location:SignsLocation;
		
		public var parent:DisplayObjectContainer;
		public var editor:ItemEditor;
		
		public var pageSize:int;
		public var total:int;
		public var done:int;
		
		public var filterName:String;
		public var filterTagIDs:Array;
		
		public var source:Object;
		
		public var uploadResult:XML;
		
		public var description:String;

		public function TopEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
		}
		
		override public function toString():String {
			return "TopEvt ["+type+"] [ "+location_id+":"+item_id+":"+user_id+"] ["+description+"]";
		}
	}
}