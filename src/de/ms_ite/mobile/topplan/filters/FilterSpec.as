package de.ms_ite.mobile.topplan.filters {
	
	[Event(name="change", type="Event")]
	
	public interface FilterSpec {
		
		function reset():void;
		function active():Boolean;
	}
}