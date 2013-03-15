package sample.builders
{
	import me.rkome.da.utils.metadata.mapping.IClassBuilder;
	
	public class DateBuilder implements IClassBuilder
	{
		public function DateBuilder()
		{
		}
		
		public function build(info:Object):Object
		{
			return new Date(String(info));
		}
		
		public function set buildOption(value:String):void {}
		public function get buildOption():String { return null; }
	}
}