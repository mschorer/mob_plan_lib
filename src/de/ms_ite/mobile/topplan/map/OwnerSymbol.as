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
	import de.ms_ite.maptech.symbols.*;
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
	import mx.managers.*;

	public class OwnerSymbol extends GeomSymbol {
		
		public function OwnerSymbol( mg:MapGlue, st:SymbolStyle=null) {
			super( mg, st);
		}

		override public function update():void {
//			debug( "commit props!");
			super.update();
			if ( rowData == null) return;

			toolTip = getPropString( 'name')+" ["+getPropString( 'ags')+"]";

			var geom:String = mapGlue.getGeometry( rowData);
			geometry.parse( geom);
			drawGraphics();
//			toolTip = 'SHIFT and drag to move. Click (+CTRL) to select.';
		}
		
		protected function getPropString( p:String):String {
			return rowData.hasOwnProperty( p) ? rowData[ p] : '';
		}
	}
}