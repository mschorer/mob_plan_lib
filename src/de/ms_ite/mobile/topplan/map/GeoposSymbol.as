/*
 *
 * the base class for a symbol
 * started on 20050328
 *
 */

package de.ms_ite.mobile.topplan.map {

//	import de.msite.ZfGis;
	import de.ms_ite.*;
	import de.ms_ite.maptech.*;
	import de.ms_ite.maptech.layers.*;
	import de.ms_ite.maptech.symbols.Symbol;
	import de.ms_ite.maptech.symbols.styles.*;
	import de.ms_ite.ogc.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;
	import flash.geom.*;
	import flash.net.*;
	import flash.text.*;
	import flash.utils.*;
	
	import mx.controls.*;
	import mx.core.*;
	import mx.effects.*;
	import mx.events.*;
	import mx.graphics.RadialGradient;
	import mx.managers.*;
	import models.GpsPos;

	public class GeoposSymbol extends Symbol {

		protected var icon:Sprite;
		protected var acc:Sprite;

		protected var poi:GpsPos;

		protected var needRedraw:Boolean = true;

		public function GeoposSymbol( mg:MapGlue, st:SymbolStyle=null) {
			super( mg, st);
			
			addEventListener( Event.RENDER, doRender);

			acc = new Sprite();			
			updateAccuracy( 1, 1);
			addChild( acc);
			
			icon = new Sprite();			
			drawIcon( 30);
			
			addChild( icon);			
		}

		override public function destroy():void {
			super.destroy();
		
			if ( icon != null) {
//				removeChild( icon);
				icon = null;
			}
			removeEventListener( Event.RENDER, doRender);
		}
		
		override public function set resolution( r:Point):void {
			if ( _resolution== null || ! r.equals( _resolution)) needRedraw = true;
			super.resolution = r;
		}
		
		override public function update():void {
			super.update();

			poi = rowData as GpsPos;
			
			toolTip = poi.longitude + ","+ poi.latitude+" > "+poi.heading;
			icon.rotation = ( poi.heading as Number) - 180.0;
			
			needRedraw = true;
		}

		protected function doRender( evt:Event):void {
			if ( needRedraw) updateAccuracy( poi.horizontalAccuracy, poi.verticalAccuracy);;
		}

		override protected function rollOver( evt:MouseEvent):void {
			debug( "over");
		}
		
		override protected function rollOut( evt:MouseEvent):void {
			debug( "out");
		}

		override public function select( state:Boolean):void {	
			super.select( state);
			if ( state) rollOver( null);
			debug( "select: "+state);
		}

		protected function drawIcon( s:Number):void {
			
			debug( "draw("+( icon != null)+"): "+s);	
			//
			if ( icon == null) return;

			var g:Graphics = icon.graphics;
			g.clear();
						
			var phi:Number = Math.PI / 6;
			var offx:Number = s * Math.sin( phi);
			var offy:Number = s * Math.cos( Math.PI - phi);
			// pointer 
			g.lineStyle( 1, 0xa0a0ef, 1);
			g.beginFill( 0xc0c0ff, 0.8);
 			g.moveTo( 0, s);
			g.lineTo( offx, offy);
			g.lineTo( 0, offy*0.8);
			g.endFill();

			g.beginFill( 0x8080e0, 1);
			g.moveTo( 0, s);
			g.lineTo( -offx, offy);
			g.lineTo( 0, offy*0.8);
			g.endFill();
		}

		protected function updateAccuracy( ha:Number, va:Number):void {
			
			var fillType:String = GradientType.RADIAL;
			var colors:Array = [ 0xFF0000, 0xFF0000];
			var alphas:Array = [ 1, 0.1];
			var ratios:Array = [ 30, 255];
			var matr:Matrix = new Matrix();
			var spreadMethod:String = SpreadMethod.PAD;

			if ( geometry == null || resolution == null) return;
			
			var hdeg:Number = ha / 40000000 * 360;
			var hpix:Number = hdeg / resolution.x;

			debug( "pix: "+hpix+" : "+hdeg);

			matr.createGradientBox( 2*hpix, 2*hpix, 0, -hpix, -hpix);
			
			var w:Number = hpix;
			var h:Number = hpix;
			
			if ( acc == null) return;
			
			var g:Graphics = acc.graphics;
			g.clear();
/*			
			// hit area
			g.beginFill(0xFF0000, 0.2);
			g.drawEllipse( -w, -h, 2*w, 2*h);
*/
			g.beginGradientFill( fillType, colors, alphas, ratios, matr, spreadMethod);  
//			g.drawEllipse( -w, -h, 2*w, 2*h);

			g.drawCircle( 0, 0, h);
			g.endFill();

			needRedraw = false;
		}
		
	override protected function debug( txt:String):void {
//			trace( "DBG GPSym("+this.name+"): "+txt);
		}
	}
}