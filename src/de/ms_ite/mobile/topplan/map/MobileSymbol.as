package de.ms_ite.mobile.topplan.map {
		
		//	import de.msite.ZfGis;
		import de.ms_ite.*;
		import de.ms_ite.maptech.*;
		import de.ms_ite.maptech.layers.*;
		import de.ms_ite.maptech.symbols.*;
		import de.ms_ite.maptech.symbols.styles.*;
		import de.ms_ite.mobile.topplan.AppSettings;
		import de.ms_ite.mobile.topplan.events.TopEvent;
		import de.ms_ite.ogc.*;
		
		import flash.display.*;
		import flash.events.*;
		import flash.filters.*;
		import flash.geom.*;
		import flash.net.*;
		import flash.system.Capabilities;
		import flash.text.*;
		import flash.utils.*;
		
		import models.SignsLocation;
		
		import mx.controls.*;
		import mx.core.*;
		import mx.effects.*;
		import mx.events.*;
		import mx.managers.*;
		
		public class MobileSymbol extends Symbol {

			protected var iconFrame:Sprite;
			protected var iconFocus:Sprite;
		
			protected var _visState:int = AppSettings.STATUS_FORCEINIT;
			
//			protected var label:TextField;
			protected var dragMode:Boolean = false;
			
			protected static var RADIUS:int = Capabilities.screenDPI / 9;
			protected static var BULLSEYE:int = 0;
			protected static var CROSSHAIR_INNER:int = RADIUS * 0.6;
			protected static var CROSSHAIR_OUTER:int = RADIUS * 1.25;
			
			protected var alphaOver:Number = 1.0;
			protected var alphaOut:Number = 0.8;
			
			protected var __selected:Boolean = false;
/*
			protected static var abbrevLen:int = 12;
			
			protected var defFormat:TextFormat;
			protected var highFormat:TextFormat;
*/			
			public function MobileSymbol( mg:MapGlue, st:SymbolStyle=null) {
				super( mg, st);
				
				addEventListener( MouseEvent.MOUSE_DOWN, mouseDown);
				addEventListener( MouseEvent.MOUSE_UP, mouseUp);
				
				iconFocus = new Sprite();
				addChild( iconFocus);

				iconFrame = new Sprite();
//				drawFrame( iconFrame, _symbolStyle.normal.line.color, _symbolStyle.normal.line.alpha, _symbolStyle.normal.line.width);
				addChild( iconFrame);
				
				filters = [ new DropShadowFilter( 3, 45, 0, 0.7) ];
/*				
				label = new TextField();
				label.selectable = false;
				label.x = 4;
				label.y = -20;
*/
//				label.width = 10;
//				label.height = 10;

/*				
				defFormat = new TextFormat();
				defFormat.font = "Verdana";
				defFormat.bold = false;
				defFormat.color = 0x000000;
				defFormat.size = 9;

				highFormat = new TextFormat();
				highFormat.font = "Verdana";
				highFormat.color = 0xFFFFFF;
				highFormat.bold = true;
				highFormat.size = 10;

				label.defaultTextFormat = defFormat;
*/
//				addChild( label);
				
				alpha = alphaOut;
			}
			
			override public function destroy():void {
				super.destroy();
				
				if ( iconFrame != null) {
					removeChild( iconFrame);
					iconFrame = null;
				}
				if ( iconFocus != null) {
					removeChild( iconFocus);
					iconFocus = null;
				}
				
				//			debug( "destroy");
				//			removeEventListener( MouseEvent.MOUSE_DOWN, mouseDown);
				//			removeEventListener( MouseEvent.MOUSE_UP, mouseUp);
			}

			override public function update():void {
				debug( "commit props!");
				
				super.update();
				
				var geom:String = mapGlue.getGeometry( rowData);
				geometry.parse( geom);
				
				alpha = _highlight ? 1 : 0.6;
				
				var nstate:int = rowData.status;
//				if ( _selected) nstate = AppSettings.STATUS_SELECTED;
				
				if ( nstate != _visState || _selected != __selected) {
					_symbolStyle = AppSettings.getStyleForState( nstate);

					if ( _selected) {
						drawFrame( iconFrame, _symbolStyle.selected.line.color, _symbolStyle.selected.line.alpha, _symbolStyle.selected.line.width);
						drawFocus( iconFocus, _symbolStyle.selected.surface.color, _symbolStyle.selected.surface.alpha);						
					} else {
						drawFrame( iconFrame, _symbolStyle.normal.line.color, _symbolStyle.normal.line.alpha, _symbolStyle.normal.line.width);
						drawFocus( iconFocus, _symbolStyle.normal.surface.color, _symbolStyle.normal.surface.alpha);
					}
//					label.text = '#'+nstate;
	
					__selected = _selected;
					_visState = nstate;
				}
/*
				label.defaultTextFormat = _selected ? highFormat : defFormat;

				var title:String = ( rowData['Standort'] == null) ? '' : rowData['Standort'];			
				label.htmlText = (_highlight || title.length < abbrevLen+3) ? title : ( title.substr( 0, abbrevLen)+'...');
*/				
//				alpha = Math.max( 0, 1 - (dif /100));
//				visible = ( alpha > 0.2);
				
				toolTip = rowData[ 'name'];				
			}
			
			protected function mouseDown( evt:MouseEvent):void {
				debug( "mdown ["+evt.ctrlKey+"/"+SignsLocation( rowData).getDragMode()+"]");

				if ( _selected && (evt.ctrlKey || SignsLocation( rowData).getDragMode())) {
					dragMode = true;
					startDrag();
					evt.stopPropagation();
				}
			}
			
			protected function mouseUp( evt:MouseEvent):void {
//				var me:MouseEvent = new MouseEvent( MouseEvent.CLICK, true);
//				dispatchEvent( me);
				
				if ( dragMode) {
					dragMode = false;
					SignsLocation( rowData).setDragMode( false);
					
					stopDrag();
					
					var newPos:Point = SymbolLayer( parent).screen2map( x, y);
					debug( "set point1: "+rowData['location']);

					var rc:Boolean = mapGlue.setPoint( rowData, newPos.x, newPos.y);	
					
					debug( "set point2: "+rowData['location']);			
					SymbolLayer( parent).updateRow( rowData);
					//				debug( "upd sym "+rc);

					var ce:TopEvent = new TopEvent( TopEvent.LOCATION_CHANGED, true);
					ce.location = rowData as SignsLocation;
					
					dispatchEvent( ce);
				}
			}
			
/*		
			override protected function rollOver( evt:MouseEvent):void {
				if ( ! visible) return;
//				debug( "over");
				highlight( true);

				var me:ToolTipEvent = new ToolTipEvent( ToolTipEvent.TOOL_TIP_SHOW, true);
				dispatchEvent( me);
			}

			override protected function rollOut( evt:MouseEvent):void {
				if ( ! visible) return;
//				debug( "out");
				highlight( false);
				
				var me:ToolTipEvent = new ToolTipEvent( ToolTipEvent.TOOL_TIP_HIDE, true);
				dispatchEvent( me);
			}
*/
/*			
			override public function select( state:Boolean):void {	
				super.select( state);
//				if ( state) rollOver( null);
				debug( "select: "+state);
			}
*/
/*
			override public function highlight( state:Boolean):void {	

//				debug( "highlight: "+_highlight+" > "+state);
				super.highlight( state);
				
				debug( "highlight: "+_selected);
				updateIcon( _selected);
			}
*/
/*			
			protected function drawMini( g:Graphics, w:Number, h:Number):void {
				
				//			debug( "draw: "+w+" x "+h);	
				//
				var rad:int = 20;
				var bullseye:int = 7;
				var crosshair_a:int = 15;
				var crosshair_b:int = 25;
				
				var fillType:String = GradientType.RADIAL;
				var colors:Array = _selected ? [ _symbolStyle.selected.surface.color, _symbolStyle.selected.surface.color] : [ _symbolStyle.normal.surface.color, _symbolStyle.normal.surface.color];
				//var colors:Array = _selected ? [ 0xE4FFCA, 0xCCFF99] : [ 0xCAFFE4, 0x99FFCC];
				var alphas:Array = _selected ? [ _symbolStyle.selected.surface.alpha, _symbolStyle.selected.surface.alpha*0.7] : [ _symbolStyle.normal.surface.alpha, _symbolStyle.normal.surface.alpha*0.7];
				var ratios:Array = [0x20, 0xff];
				var matr:Matrix = new Matrix();
				matr.createGradientBox( rad, rad, Math.PI/2, 0, 0);
				var spreadMethod:String = SpreadMethod.PAD;
				
				var dropShadowAlpha:Number = 0.7;
				var shadowAlpha:Number = 0.7;
				
				filters = [ new DropShadowFilter( 3, 45, 0, dropShadowAlpha) ];
				
				label.visible = false;
				
				g.beginGradientFill(fillType, colors, alphas, ratios, matr, spreadMethod);  
				g.drawCircle( 0, 0, rad);
				g.drawCircle( 0, 0, bullseye);
				g.endFill();
				
				g.lineStyle( _selected ? _symbolStyle.selected.line.width : _symbolStyle.normal.line.width, _selected ? _symbolStyle.selected.line.color : _symbolStyle.normal.line.color, _selected ? _symbolStyle.selected.line.alpha : _symbolStyle.normal.line.alpha);
				g.drawCircle( 0, 0, rad);
				
				g.moveTo( 0, -crosshair_a);
				g.lineTo( 0, -crosshair_b);
				
				g.moveTo( crosshair_a, 0);
				g.lineTo( crosshair_b, 0);

				g.moveTo( 0, crosshair_a);
				g.lineTo( 0, crosshair_b);

				g.moveTo( -crosshair_a, 0);
				g.lineTo( -crosshair_b, 0);
				
				debug( "graphics: "+icon.width+"x"+icon.height);

				icon.width = 2 * Math.max( rad, crosshair_b);
				icon.height = 2 * Math.max( rad, crosshair_b);
				icon.x = 0;
				icon.y = 0;
			}
*/
			protected function drawFrame( s:Sprite, color:int, alpha:Number, wid:int):void {
				
				//			debug( "draw: "+w+" x "+h);	
				//
				var g:Graphics = s.graphics;
				g.clear();

				g.lineStyle( wid, color, alpha);		//_symbolStyle.selected.line.width, _symbolStyle.selected.line.color, _symbolStyle.selected.line.alpha);
				g.drawCircle( 0, 0, RADIUS);
				
				g.lineStyle( wid, color, alpha);	//_symbolStyle.normal.line.width, _symbolStyle.normal.line.color, _symbolStyle.normal.line.alpha);
				g.moveTo( 0, -CROSSHAIR_INNER);
				g.lineTo( 0, -CROSSHAIR_OUTER);
				
				g.moveTo( CROSSHAIR_INNER, 0);
				g.lineTo( CROSSHAIR_OUTER, 0);
				
				g.moveTo( 0, CROSSHAIR_INNER);
				g.lineTo( 0, CROSSHAIR_OUTER);
				
				g.moveTo( -CROSSHAIR_INNER, 0);
				g.lineTo( -CROSSHAIR_OUTER, 0);

				s.width = s.height = 2 * Math.max( RADIUS, CROSSHAIR_OUTER);
			}
			
			protected function drawFocus( s:Sprite, color_a:int, alpha_a:Number, color_b:int=-1, alpha_b:Number=-1):void {
				
				//			debug( "draw: "+w+" x "+h);	
				//

				var fillType:String = GradientType.RADIAL;
				var colors:Array = [ color_a, ( color_b != -1) ? color_b : color_a];
				var alphas:Array = [ (alpha_b != -1) ? alpha_b : 0.2, alpha_a];	//[ alpha_a, alpha_b];
				var ratios:Array = [ 40, 255];
				
				var matr:Matrix = new Matrix();
				matr.createGradientBox( 2*RADIUS, 2*RADIUS, 0, -RADIUS, -RADIUS);
				
				var spreadMethod:String = SpreadMethod.PAD;
				
				var g:Graphics = s.graphics;
				g.clear();

				g.beginGradientFill( fillType, colors, alphas, ratios, matr, spreadMethod);  
				g.drawCircle( 0, 0, RADIUS);
				g.drawCircle( 0, 0, BULLSEYE);
				g.endFill();				

				s.width = s.height = 2 * RADIUS;
			}
			/*
			override public function highlight( state:Boolean):void {	
			super.highlight( state);
			
			var scale:Number = symbolStyle.icon.scale * dataScale * ( _highlight ? 1.4 : 1.0);
			
			icon.width = scale * 50;
			icon.height = scale * 30;
			icon.y = -icon.height;
			//			scaleX = scaleY = scale;
			}
			*/
			/*		override protected function debug( txt:String):void {
			trace( "DBG IDSymbol("+this.name+"): "+txt);
			}
		*/		
		override protected function debug( txt:String):void {
//			trace( "DBG Symbol("+this.name+"): "+txt);
		}
	}
}