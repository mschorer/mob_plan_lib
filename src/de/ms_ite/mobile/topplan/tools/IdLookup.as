package de.ms_ite.mobile.topplan.tools {
	import flash.utils.Dictionary;
	
	import models.Model;
	import models.RetrievalParameters;
	import models.SignsAction;
	import models.SignsContentModel;
	import models.SignsIcon;
	import models.SignsIconMap;
	import models.SignsItem;
	import models.SignsLocation;
	import models.SignsModel;
	import models.SignsOwner;
	import models.SignsProject;
	import models.SignsTag;
	import models.SignsTagMap;
	import models.SignsUser;
	import models.StatusModel;
	
	import mx.collections.ArrayCollection;

	public class IdLookup {
		
		protected var userModel:SignsUser;
		protected var userIdCache:Dictionary;

		protected var locationModel:SignsLocation;
		protected var locationIdCache:Dictionary;

		protected var itemModel:SignsItem;
		protected var itemIdCache:Dictionary;

		protected var actionModel:SignsAction;
		protected var actionIdCache:Dictionary;

		protected var iconModel:SignsIcon;
		protected var iconIdCache:Dictionary;
		
		protected var iconMapModel:SignsIconMap;
		protected var iconMapIdCache:Dictionary;
		
		protected var tagModel:SignsTag;
		protected var tagIdCache:Dictionary;
		
		protected var tagMapModel:SignsTagMap;
		protected var tagMapIdCache:Dictionary;
		
		protected var projectModel:SignsProject;
		protected var projectIdCache:Dictionary;
		
		protected var ownerModel:SignsOwner;
		protected var ownerIdCache:Dictionary;
		
		public function IdLookup() {
			userModel = new SignsUser();
			locationModel = new SignsLocation();
			itemModel  = new SignsItem();
			actionModel = new SignsAction();

			iconModel = new SignsIcon();
			iconMapModel = new SignsIconMap();

			tagModel = new SignsTag();
			tagMapModel = new SignsTagMap();

			projectModel = new SignsProject();
			ownerModel = new SignsOwner();
			
			clear();
		}
		
		public function clear():void {
			userIdCache = new Dictionary();
			locationIdCache = new Dictionary();
			itemIdCache = new Dictionary();
			actionIdCache = new Dictionary();

			iconIdCache = new Dictionary();
			iconMapIdCache = new Dictionary();
			
			tagIdCache = new Dictionary();
			tagMapIdCache = new Dictionary();
			
			ownerIdCache = new Dictionary();
			projectIdCache = new Dictionary();
		}
		
		protected function getDictionary( item:SignsModel):Dictionary {
			if ( item is SignsUser) {
				if ( userIdCache == null) userIdCache = new Dictionary();
				return userIdCache;
			}
			if ( item is SignsOwner) {
				if ( ownerIdCache == null) ownerIdCache = new Dictionary();
				return ownerIdCache;
			}
			if ( item is SignsProject) {
				if ( projectIdCache == null) projectIdCache = new Dictionary();
				return projectIdCache;
			}
			if ( item is SignsLocation) {
				if ( locationIdCache == null) locationIdCache = new Dictionary();
				return locationIdCache;
			}
			if ( item is SignsItem) {
				if ( itemIdCache == null) itemIdCache = new Dictionary();
				return itemIdCache;
			}
			if ( item is SignsAction) {
				if ( actionIdCache == null) actionIdCache = new Dictionary();
				return actionIdCache;
			}
			if ( item is SignsTag) {
				if ( tagIdCache == null) tagIdCache = new Dictionary();
				return tagIdCache;
			}
			if ( item is SignsTagMap) {
				if ( tagMapIdCache == null) tagMapIdCache = new Dictionary();
				return tagMapIdCache;
			}
			if ( item is SignsIcon) {
				if ( iconIdCache == null) iconIdCache = new Dictionary();
				return iconIdCache;
			}
			if ( item is SignsIconMap) {
				if ( iconMapIdCache == null) iconMapIdCache = new Dictionary();
				return iconMapIdCache;
			}
			
			return null;
		}
		
		protected function getTempModel( item:SignsModel):Model {
			return item.getInstance( null);
/*			
			if ( item is SignsUser) {
				if ( userModel == null) userModel = new SignsUser();
				return userModel;
			}
			if ( item is SignsLocation) {
				if ( locationModel == null) locationModel = new SignsLocation();
				return locationModel;
			}
			if ( item is SignsItem) {
				if ( itemModel == null) itemModel  = new SignsItem();
				return itemModel;
			}
			if ( item is SignsAction) {
				if ( actionModel == null) actionModel = new SignsAction();
				return actionModel;
			}
			if ( item is SignsIcon) {
				if ( iconModel == null) iconModel = new SignsIcon();
				return iconModel;
			}
			if ( item is SignsIconMap) {
				if ( iconMapModel == null) iconMapModel = new SignsIconMap();
				return iconMapModel;
			}
			if ( item is SignsTag) {
				if ( tagModel == null) tagModel = new SignsTag();
				return tagModel;
			}
			if ( item is SignsTagMap) {
				if ( tagMapModel == null) tagMapModel = new SignsTagMap();
				return tagMapModel;
			}
			if ( item is SignsProject) {
				if ( projectModel == null) projectModel = new SignsProject();
				return projectModel;
			}
			if ( item is SignsOwner) {
				if ( ownerModel == null) ownerModel = new SignsOwner();
				return ownerModel;
			}
			
			return null;
*/
		}
		
		public function cacheToGlobal( item:SignsModel, key:int):int {
			var map:Dictionary = getDictionary( item);
			var ido:Object = map[ 'c_'+key];
			var rid:int = -1;
			
			if ( ido != null) {
				rid = parseInt( ido.toString());
//				debug( "lookupC= ["+rid+"]");
			} else {
				
				var temp:SignsModel = SignsModel( getTempModel( item));
				temp.cache_id = key;
				
				//TODO	 make the load call async?
				
				if ( temp.load()) {				
					rid = temp.id;
					cache( temp);
				} else {
//					error( "cacheToGlobal failed ["+item.toString()+"]");
				}
//				debug( "lookupC+ ["+rid+"]");
			}
			
			return rid;
		}
		
		public function globalToCache( item:SignsModel, key:int):int {
			var map:Dictionary = getDictionary( item);
			var ido:Object = map[ 'r_'+key];
			var rid:int = -1;
			
			if ( ido != null) {
				rid = parseInt( ido.toString());
//				debug( "lookupG= ["+rid+"]");
			} else {
				var temp:SignsModel = SignsModel( getTempModel( item));

				temp.id = key;

				//TODO	 make the load call async?
				
				if ( temp.loadById()) {
					rid = temp.cache_id;		
					cache( temp);
				} else {
//					error( "globalToCache failed ["+item.toString()+"]");
				}
				
//				debug( "lookupG+ ["+rid+"]");
			}
			
			return rid;
		}
		
		public function cache( item:SignsModel):void {
			var map:Dictionary = getDictionary( item);
			
			if ( map == null || item == null) return;
			
			if ( item.id >= 0 && item.cache_id >= 0) {
				map[ 'r_'+item.id] = item.cache_id;
				map[ 'c_'+item.cache_id] = item.id;
			}
			
//			debug( "cache ["+item.id+":"+item.cache_id+"]");
		}
		
		protected function debug( s:String):void {
//			trace( "idcacheDBG: "+s);
		}
		protected function error( s:String):void {
			trace( "idcacheERR: "+s);
		}
	}
}