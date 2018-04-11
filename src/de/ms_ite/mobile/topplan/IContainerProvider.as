package de.ms_ite.mobile.topplan
{
	import spark.components.SkinnableContainer;

	public interface IContainerProvider
	{
		function getPreviewContainer():IImagePreviewContainer;
		function getHistoryContainer():IHistoryContainer;
	}
}