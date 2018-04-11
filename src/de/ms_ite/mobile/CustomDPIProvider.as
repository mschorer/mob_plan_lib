package de.ms_ite.mobile {
	
	import flash.system.Capabilities;
	import mx.core.DPIClassification;
	import mx.core.RuntimeDPIProvider;
	
	public class CustomDPIProvider extends RuntimeDPIProvider {
		public function CustomDPIProvider() {
			super();
		}
		
		override public function get runtimeDPI():Number {
			var dpi:Number = super.runtimeDPI;

			if ( Capabilities.screenDPI >= 280) {
				if (Capabilities.screenResolutionX > 1000 || Capabilities.screenResolutionY > 1000) dpi = DPIClassification.DPI_240;
				else dpi = DPIClassification.DPI_320;
			} else {
				if (Capabilities.screenDPI >= 200) dpi = DPIClassification.DPI_240;
				else dpi = DPIClassification.DPI_160;
			}

			trace( "DPI ["+Capabilities.screenDPI+" : "+dpi+"]");
			
			return dpi;
		}
	}
}