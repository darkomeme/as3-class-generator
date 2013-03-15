package sample.models
{
	import sample.builders.DateBuilder;

	[Bindable]
	public class Tweet
	{
		DateBuilder;
		
		private var _id:Number;
		[Mapping(name="id")]
		public function get id():Number { return _id; }
		public function set id(value:Number):void
		{
			if (_id == value)
				return;
			_id = value;
		}
		
		private var _text:String;
		[Mapping(name="text")]
		public function get text():String { return _text; }
		public function set text(value:String):void
		{
			if (_text == value)
				return;
			_text = value;
		}
		
		private var _retweetedCount:int;
		[Mapping(name="retweeted_count")]
		public function get retweetedCount():int { return _retweetedCount; }
		public function set retweetedCount(value:int):void
		{
			if (_retweetedCount == value)
				return;
			_retweetedCount = value;
		}
		
		private var _isFavorited:Boolean;
		[Mapping(name="favorited")]
		public function get isFavorited():Boolean { return _isFavorited; }
		public function set isFavorited(value:Boolean):void
		{
			if (_isFavorited == value)
				return;
			_isFavorited = value;
		}
		
		private var _isRetweeted:Boolean;
		[Mapping(name="retweeted")]
		public function get isRetweeted():Boolean { return _isRetweeted; }
		public function set isRetweeted(value:Boolean):void
		{
			if (_isRetweeted == value)
				return;
			_isRetweeted = value;
		}
		
		private var _createdAt:Date;
		[Mapping(name="created_at", builder="sample.builders.DateBuilder")]
		public function get createdAt():Date { return _createdAt; }
		public function set createdAt(value:Date):void
		{
			if (_createdAt == value)
				return;
			_createdAt = value;
		}
	}
}
