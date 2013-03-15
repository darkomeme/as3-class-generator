package sample.models
{
	import sample.builders.DateBuilder;

	[Bindable]
	public class TwitterUser
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

		private var _name:String;
		[Mapping(name="name")]
		public function get name():String { return _name; }
		public function set name(value:String):void
		{
			if (_name == value)
				return;
			_name = value;
		}

		private var _screenName:String;
		[Mapping(name="screen_name")]
		public function get screenName():String { return _screenName; }
		public function set screenName(value:String):void
		{
			if (_screenName == value)
				return;
			_screenName = value;
		}

		private var _location:String;
		[Mapping(name="location")]
		public function get location():String { return _location; }
		public function set location(value:String):void
		{
			if (_location == value)
				return;
			_location = value;
		}

		private var _homePageUrl:String;
		[Mapping(name="url")]
		public function get homePageUrl():String { return _homePageUrl; }
		public function set homePageUrl(value:String):void
		{
			if (_homePageUrl == value)
				return;
			_homePageUrl = value;
		}
		
		private var _description:String;
		[Mapping(name="description")]
		public function get description():String { return _description; }
		public function set description(value:String):void
		{
			if (_description == value)
				return;
			_description = value;
		}

		private var _followersCount:int;
		[Mapping(name="followers_count")]
		public function get followersCount():int { return _followersCount; }
		public function set followersCount(value:int):void
		{
			if (_followersCount == value)
				return;
			_followersCount = value;
		}

		private var _friendsCount:int;
		[Mapping(name="friends_count")]
		public function get friendsCount():int { return _friendsCount; }
		public function set friendsCount(value:int):void
		{
			if (_friendsCount == value)
				return;
			_friendsCount = value;
		}
		
		private var _listedCount:int;
		[Mapping(name="listed_count")]
		public function get listedCount():int { return _listedCount; }
		public function set listedCount(value:int):void
		{
			if (_listedCount == value)
				return;
			_listedCount = value;
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
		
		private var _latestTweet:Tweet;
		[Mapping(name="status", type="sample.models.Tweet")]
		public function get latestTweet():Tweet { return _latestTweet; }
		public function set latestTweet(value:Tweet):void
		{
			if (_latestTweet == value)
				return;
			_latestTweet = value;
		}
		
		private var _profileImageUrl:String;
		[Mapping(name="profile_image_url")]
		public function get profileImageUrl():String { return _profileImageUrl; }
		public function set profileImageUrl(value:String):void
		{
			if (_profileImageUrl == value)
				return;
			_profileImageUrl = value;
		}
	}
}
