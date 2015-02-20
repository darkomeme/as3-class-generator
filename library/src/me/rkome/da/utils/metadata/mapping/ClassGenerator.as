package me.rkome.da.utils.metadata.mapping
{
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	
	import mx.core.IFactory;
	
	public class ClassGenerator implements IFactory
	{
		private static var xmlCacheTable:Dictionary = new Dictionary();
		private static var generatorCacheTable:Dictionary = new Dictionary();
		
		/**
		 * 生成するクラスの登録を行う関数
		 * 
		 * （生成する時にパフォーマンスが落ちないように、事前にクラスを登録したい人のために）
		 * 
		 * @param classInstance 登録したいクラス
		 * 
		 */		
		public static function registerClass(ClassReference:Class):void
		{
			var mapper:PropertyMapper = new PropertyMapper();
			mapper.loadMappingFromXML(describeType(new ClassReference()));
			xmlCacheTable[ClassReference] = mapper;
		}
		
		/**
		 * 指定されたクラスのインスタンスを[Mapping]情報に従って生成する
		 * 
		 * @param ClassReference 生成したいクラス
		 * @param properties クラスの初期値を格納しているオブジェクト
		 * @return 指定されたクラスのインスタンス
		 * 
		 */		
		public static function generate(ClassReference:Class, properties:Object):*
		{
			var gen:ClassGenerator;
			if (generatorCacheTable[ClassReference] == undefined)
			{
				gen = new ClassGenerator(ClassReference);
				generatorCacheTable[ClassReference] = gen;
			}
			else
			{
				gen = generatorCacheTable[ClassReference];
			}
			gen.properties = properties;
			return gen.newInstance();
		}
		
		/**
		 * 指定されたクラスのインスタンス配列を[Mapping]情報に従って生成する
		 * @param ClassReference 生成したいクラス
		 * @param propertiesArray クラスの初期値を格納しているオブジェクトの配列
		 * @return 指定されたクラスのインスタンス配列
		 * 
		 */		
		public static function generateAll(ClassReference:Class, propertiesArray:Array):Array
		{
			var array:Array = [];
			for each (var properties:* in propertiesArray)
			{
				array.push(generate(ClassReference, properties));
			}
			return array;
		}
		
		/**
		 * 指定されたクラスセレクタを使ってインスタンス配列を生成する
		 * @param selector クラスセレクタ
		 * @param propertiesArray クラスの初期値を格納しているオブジェクトの配列
		 * @return 指定されたクラスのインスタンス配列
		 * 
		 */		
		public static function generateAllBySelector(selector:IClassSelector, propertiesArray:Array):Array
		{
			var array:Array = [];
			for each (var properties:* in propertiesArray)
			{
				var ClassReference:Class = selector.selectClass(properties);
				array.push(generate(ClassReference, properties));
			}
			return array;
		}
		
		/**
		 * 指定されたクラスビルダーを使ってインスタンス配列を生成する
		 * @param builder クラスビルダー
		 * @param propertiesArray クラスの初期値を格納しているオブジェクトの配列
		 * @return 指定されたクラスのインスタンス配列 
		 * 
		 */		
		public static function generateAllByBuilder(builder:IClassBuilder, propertiesArray:Array):Array
		{
			var array:Array = [];
			for each (var properties:* in propertiesArray)
			{
				array.push(builder.build(properties));
			}
			return array;
		}
		
		/**
		 * 生成関数を指定してJSONオブジェクトからインスタンス配列を生成する
		 * @param func
		 *   function (obj:Object):* {} というフォーマットの関数を指定
		 * @param propertiesArray
		 *   JSONオブジェクトの配列
		 * @return 
		 *   指定した関数によって生成されたインスタンスの配列
		 */		
		public static function generateAllByFunction(func:Function, propertiesArray:Array):Array
		{
			var array:Array = [];
			for each (var properties:* in propertiesArray)
			{
				array.push(func(properties));
			}
			return array;
		}
		
		/**
		 * 指定されたクラスインスタンスに[Mapping]情報に従って値を設定する
		 * @param instace クラスインスタンス
		 * @param properties 設定したい値を格納しているオブジェクト
		 * @return 処理後のクラスインスタンス（第一引数で渡したものと同じ）
		 * 
		 */		
		public static function apply(instace:Object, properties:Object):*
		{
			var gen:ClassGenerator = new ClassGenerator();
			gen.properties = properties;
			return gen.setInstanceMapper(instace);
		}
		
		public var generator:Class;
		public var properties:Object = null;

		/**
		 * コンストラクタ
		 * 
		 * @param generator 生成したいクラス
		 * 
		 */		
		public function ClassGenerator(generator:Class=null)
		{
			this.generator = generator;
		}
		
		/**
		 * generatorプロパティに指定されたインスタンスを生成し、propertiesプロパティに設定した値を設定する
		 * @return 
		 * 
		 */		
		public function newInstance():*
		{
			var instance:Object = new generator();
			return setInstanceMapper(instance);
		}

		/**
		 * [Mapping]情報を元に指定されたクラスインスタンスに、propertiesに格納した値を設定する
		 * @param instance 値を設定したいクラスインスタンス
		 * @return 
		 * 
		 */		
		public function setInstanceMapper(instance:*):*
		{
			var mapper:PropertyMapper;
			if (xmlCacheTable[generator] == undefined)
			{
				mapper = new PropertyMapper();
				mapper.loadMappingFromXML(describeType(instance));
				xmlCacheTable[generator] = mapper;
			}
			else
			{
				mapper = xmlCacheTable[generator] as PropertyMapper;
			}
			
			for (var p:String in properties)
			{
				mapper.setInstance(instance, p, properties);
			}
			return instance;
		}
	}
}