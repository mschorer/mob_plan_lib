package de.ms_ite.mobile.topplan {

	import models.GpsPos;

	public interface ILocationProvider {
		
		function get geoLocation():GpsPos;
	}
}