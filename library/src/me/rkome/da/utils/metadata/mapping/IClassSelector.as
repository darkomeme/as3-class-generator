package me.rkome.da.utils.metadata.mapping
{
	public interface IClassSelector
	{
		function selectClass(info:Object):Class;
		function set selectOption(value:String):void;
		function get selectOption():String;
	}
}