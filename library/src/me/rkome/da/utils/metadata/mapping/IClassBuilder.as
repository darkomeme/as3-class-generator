package me.rkome.da.utils.metadata.mapping
{
	public interface IClassBuilder
	{
		function build(info:Object):Object;
		function set buildOption(value:String):void;
		function get buildOption():String;
	}
}