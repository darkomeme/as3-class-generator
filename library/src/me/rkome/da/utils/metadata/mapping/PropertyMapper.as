package me.rkome.da.utils.metadata.mapping
{
	import flash.utils.getDefinitionByName;
	
	import mx.messaging.AbstractConsumer;

	public class PropertyMapper
	{
		private var mappingTable:Object;
		public function PropertyMapper()
		{
			mappingTable = {};
		}
		
		public function loadMappingFromXML(xml:XML):void
		{
			for each (var accessor:XML in xml.accessor)
			{
				var xmlMappingTagList:XMLList = accessor.metadata.(@name == 'Mapping');
				if (xmlMappingTagList.length() > 0)
				{
					var accessorName:String = String(accessor.@name);
					
					for each (var metadata:XML in xmlMappingTagList)
					{
						var name:String = String(metadata.arg.(@key == 'name')[0].@value);
						var xmlList:XMLList;
						var info:PropertyInfo;
						if (mappingTable.hasOwnProperty(name))
						{
							info = mappingTable[name] as PropertyInfo;
						}
						else
						{
							info = new PropertyInfo();
						}
						info.propertyName = accessorName;

						
						if ((xmlList = metadata.arg.(@key == 'type')).length() > 0)
						{
							var typeName:String = String(xmlList[0].@value);
							var type:Class = getDefinitionByName(typeName) as Class;
							info.type = type;
						}
						else
						if ((xmlList = metadata.arg.(@key == 'selector')).length() > 0)
						{
							var selectorName:String = String(xmlList[0].@value);
							var SelectorClass:Class = getDefinitionByName(selectorName) as Class;
							var iSelector:IClassSelector = new SelectorClass();
							
							if ((xmlList = metadata.arg.(@key == 'option')).length() > 0)
							{
								iSelector.selectOption = String(xmlList[0].@value);
							}
							info.selector = iSelector;
						}
						else
						if ((xmlList = metadata.arg.(@key == 'builder')).length() > 0)
						{
							var builderName:String = String(xmlList[0].@value);
							var BuilderClass:Class = getDefinitionByName(builderName) as Class;
							var iBuilder:IClassBuilder = new BuilderClass();
							
							if ((xmlList = metadata.arg.(@key == 'option')).length() > 0)
							{
								iBuilder.buildOption = String(xmlList[0].@value);
							}
							info.builder = iBuilder;
						}
						
						var arrayValue:String = 'yes';
						if ((xmlList = metadata.arg.(@key == 'array')).length() > 0)
						{
							arrayValue = String(xmlList[0].@value);
						}
						info.isArray = (arrayValue == 'yes');

						
						var nullableValue:String = 'no';
						if ((xmlList = metadata.arg.(@key == 'nullable')).length() > 0)
						{
							nullableValue = String(xmlList[0].@value);
						}
						info.isNullable = (nullableValue == 'yes');
						
						mappingTable[name] = info;
					}
				}
			}
		}
		
		public function setInstance(instance:Object, name:String, properties:Object):void
		{
			if (mappingTable.hasOwnProperty(name))
			{
				var info:PropertyInfo = mappingTable[name] as PropertyInfo;
				info.setInstance(instance, name, properties);
			}
			else
			if (instance.hasOwnProperty(name))
			{
				instance[name] = properties[name];
			}
		}
	}
}
import me.rkome.da.utils.metadata.mapping.ClassGenerator;
import me.rkome.da.utils.metadata.mapping.IClassBuilder;
import me.rkome.da.utils.metadata.mapping.IClassSelector;

class PropertyInfo
{
	private var gen:ClassGenerator;
	public function PropertyInfo() 
	{
		gen = new ClassGenerator();
	}
	
	private var _propertyName:String;
	public function get propertyName():String { return _propertyName; }
	public function set propertyName(value:String):void
	{
		if (_propertyName == value)
			return;
		_propertyName = value;
	}

	private var _type:Class;
	public function get type():Class { return _type; }
	public function set type(value:Class):void
	{
		if (_type == value)
			return;
		_type = value;
	}

	private var _selector:IClassSelector;
	public function get selector():IClassSelector { return _selector; }
	public function set selector(value:IClassSelector):void
	{
		if (_selector == value)
			return;
		_selector = value;
	}

	private var _builder:IClassBuilder;
	public function get builder():IClassBuilder { return _builder; }
	public function set builder(value:IClassBuilder):void
	{
		if (_builder == value)
			return;
		_builder = value;
	}
	
	private var _isArray:Boolean;
	public function get isArray():Boolean { return _isArray; }
	public function set isArray(value:Boolean):void
	{
		if (_isArray == value)
			return;
		_isArray = value;
	}
	
	private var _isNullable:Boolean;
	public function get isNullable():Boolean { return _isNullable; }
	public function set isNullable(value:Boolean):void
	{
		if (_isNullable == value)
			return;
		_isNullable = value;
	}
	
	
	public function setInstance(instance:Object, name:String, properties:Object):void
	{
		if (properties[name] == null && isNullable) return;
		
		if (_builder)
		{
			if (properties[name] is Array && _isArray)
			{
				instance[_propertyName] = (properties[name] as Array).map(generateByBuilder);
			}
			else
			if (properties[name] != null)
			{
				instance[_propertyName] = _builder.build(properties[name]);
			}
		}
		else
		if (_selector)
		{
			if (properties[name] is Array && _isArray)
			{
				instance[_propertyName] = (properties[name] as Array).map(generateBySelector);
			}
			else
			if (properties[name] != null)
			{
				gen.generator = _selector.selectClass(properties[name]);
				gen.properties = properties[name];
				instance[_propertyName] = gen.newInstance();
			}
		}
		else
		if (_type)
		{
			if (properties[name] is Array && _isArray)
			{
				instance[_propertyName] = (properties[name] as Array).map(generateByClass);
			}
			else
			if (properties[name] != null)
			{
				gen.generator = _type;
				gen.properties = properties[name];
				instance[_propertyName] = gen.newInstance();
			}
		}
		else
		{
			instance[_propertyName] = properties[name];
		}
	}
	
	private function generateByBuilder(item:Object, i:int, arr:Array):Object
	{
		return _builder.build(item);
	}
	
	private function generateByClass(item:Object, i:int, arr:Array):Object
	{
		gen.generator = _type;
		gen.properties = item;
		return gen.newInstance();
	}
	
	private function generateBySelector(item:Object, i:int, arr:Array):Object
	{
		gen.generator = _selector.selectClass(item);
		gen.properties = item;
		return gen.newInstance();
	}
	
}