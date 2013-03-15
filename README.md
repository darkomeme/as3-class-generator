as3-class-generator
===================

# 概要

このライブラリは、Objectからクラスインスタンスを生成することを目的に作られたものです。

例えば、サーバーからJSONを受信して、Objectのインスタンスへ変換し
それらを更に自分で作ったクラスのプロパティに一つ一つ代入していくコードを書くことを考えてみましょう。

    // loader は URLLoader という想定
    var json:Object       = JSON.parse( String(loader.data) );
    var userInfo:UserInfo = new UserInfo();
    userInfo.name         = json.name;
    userInfo.age          = json.age;
    userInfo.thumbnailUrl = json.thumbnail_url;
                     :
                     :
    userInfo.access       = new Access();
    userInfo.access.email = json.access.email;
    userInfo.access.phone = json.access.phone;
    userInfo.access.fax   = json.access.fax;
    userInfo.access.skype = json.access.skype;
                     :
                     :
    userInfo.tags         = [];
    for each (var tagObject:Object in json.tags)
    {
      var tag:Tag   = new Tag();
      tag.id        = tagObject.id;
      tag.name      = tagObject.name;
      tag.createdAt = new Date( tagObject.created_at );
      userInfo.tags.push( tag );
    }
                     :
                     :

こんなコードを延々と書く必要があります。
ただ、JSONを受信してクラスインスタンスに値を代入するだけでこんなにプログラムを書かなければならないのは
何だかバカバカしいものです。

そこへ、JSONフォーマットに仕様変更があって、要素名が変わったりなんかしたら、このプログラムのどこかに潜む
要素名を変更しないといけないわけです。

文章を書いているだけで、震えが止まりません。


そこで、私はこんな提案をしたいと思います。

    class UserInfo
    {
      private var _name:String;
      [Mapping(name="name")]
      public function get name():String
      {
        return _name;
      }
      public function set name(value:String):void
      {
        if (_name == value)
          return;
        _name = value;
      }
    }

クラス定義のプロパティに[Mapping]というメタデータタグを書いておく。
メタデータタグのname要素にJSONに対応する名前を書いておく。

    // loader は URLLoader という想定
    var json:Object       = JSON.parse( String(loader.data) );
    var userInfo:UserInfo = ClassGenerator.generate(UserInfo, json) as UserInfo;

あとは、ClassGenerator::generate()という関数を呼び出すだけ。

こんな風に書けたら楽だと思いませんか？

例えば、JSONフォーマットの仕様変更があったら・・・

    class UserInfo
    {
      private var _name:String;
      [Mapping(name="user_name")] // <- JSONの name という要素名が user_name に変わった場合
      public function get name():String
      {
        return _name;
      }
      public function set name(value:String):void
      {
        if (_name == value)
          return;
        _name = value;
      }
    }

[Mapping]タグのname要素を書き換えるだけ。

    // loader は URLLoader という想定
    var json:Object       = JSON.parse( String(loader.data) );
    var userInfo:UserInfo = ClassGenerator.generate(UserInfo, json) as UserInfo;

こっちのコードはそのまんま。


ただ、これだけだと、少し心配です。
例えば、こんな場合

    import com.sample.Access;
    
    class UserInfo
    {
      private var _access:Access;
      public function get access():Access
      {
        return _access;
      }
      public function set access(value:Access):void
      {
        if (_access == value)
          return;
        _access = value;
      }
    }

accessプロパティはAccessクラスなのに、JSONフォーマットはObjectなんて場合はどうなる？
なんて事があるかと思います。
もちろん、そのまま代入したんでは、TypeErrorが出てしまうでしょう。

そこで、更にこんな仕組みを用意。

    import com.sample.Access;
    
    class UserInfo
    {
      private var _access:Access;
      [Mapping(name="access", type="com.sample.Access")]
      public function get access():Access
      {
        return _access;
      }
      public function set access(value:Access):void
      {
        if (_access == value)
          return;
        _access = value;
      }
    }

[Mapping]タグにname要素を指定すると共に、クラス名をフルネームで指定してあげる。
Accessクラスはこんな感じ。

    class Access
    {
      private var _email:String;
      [Mapping(name="email")]
      public function get email():String
      {
        return _email;
      }
      public function set email(value:String):void
      {
        if (_email == value)
          return;
        _email = value;
      }
    }

こうするだけで、生成のコードは据え置き。

    // loader は URLLoader という想定
    var json:Object       = JSON.parse( String(loader.data) );
    var userInfo:UserInfo = ClassGenerator.generate(UserInfo, json) as UserInfo;

これだけ。これだけで

    {
      "name": "Unknown",
      "age": 14,
      "access": {
        "email": "hoge@fugapiyo.com"
      }
    }

こんなJSONでも大丈夫！

こんな事をやりたいが為に、このライブラリを作りました。
需要があればライセンス規約に抵触しない形でご利用下さい。

# 使い方

## 生成する

    // loader は URLLoader という想定
    var json:Object       = JSON.parse( String(loader.data) );
    var userInfo:UserInfo = ClassGenerator.generate(UserInfo, json) as UserInfo;

ClassGenerator::generate()を使って、指定したクラスインスタンスの生成を行います。

    // loader は URLLoader という想定
    var json:Object       = JSON.parse( String(loader.data) );
    var tags:Array        = ClassGenerator.generateAll(Tag, json.tags); // json.tagsはArrayとする

もし、クラスインスタンスの配列を取得したい場合はClassGenerator::generateAll()を使って下さい。

## [Mapping]タグを生成したいクラスのプロパティ定義へ付与する

### name要素を指定（必須）

    class UserInfo
    {
      private var _name:String;
      [Mapping(name="user_name")]
      public function get name():String
      {
        return _name;
      }
      public function set name(value:String):void
      {
        if (_name == value)
          return;
        _name = value;
      }
    }

name要素には、付与したプロパティと対応するJSONの要素名を記述してください。

### type要素を指定

    {
      "name": "Unknown",
      "age": 14,
      "access": {
        "email": "hoge@fugapiyo.com"
      }
    }

Objectの中に更にObjectがあるような場合、

    import com.sample.Access;
    
    class UserInfo
    {
      private var _access:Access;
      [Mapping(name="access", type="com.sample.Access")]
      public function get access():Access
      {
        return _access;
      }
      public function set access(value:Access):void
      {
        if (_access == value)
          return;
        _access = value;
      }
    }

type要素を一緒に指定すると、指定されたクラスインスタンスを生成して代入します。

### builder要素の指定

    {
      "user_name": "Unknown",
      "created_at": "Thu Mar 14 15:17:40 +0000 2013"
    }

こんなJSONだとして

    class UserInfo
    {
      private var _name:String;
      [Mapping(name="user_name")]
      public function get name():String
      {
        return _name;
      }
      public function set name(value:String):void
      {
        if (_name == value)
          return;
        _name = value;
      }

      private var _createdAt:Date;
      [Mapping(name="created_at")]
      public function get createdAt():Date
      {
        return _createdAt;
      }
      public function set createdAt(value:Date):void
      {
        if (_createdAt == value)
          return;
        _createdAt = value;
      }
    }

クラスではDate型で持ちたい時には、IClassBuilderを使って、Stringの値をDateに変換します。

    class DateBuilder implements IClassBuilder
    {
      public function DateBuilder() {}
      public function build(info:Object):Object
      {
        return new Date(String(info));
      }
      
      public function set buildOption(value:String):void {}
      public function get buildOption():String { return null; }      
    }

こんなビルダークラスを用意して、

    import com.sample.DateBuilder;
    class UserInfo
    {
      DateBuilder; // importする為に、名前だけ記述（動作には影響なし）
      
      private var _name:String;
      [Mapping(name="name")]
      public function get name():String
      {
        return _name;
      }
      public function set name(value:String):void
      {
        if (_name == value)
          return;
        _name = value;
      }

      private var _createdAt:Date;
      [Mapping(name="created_at", builder="com.sample.DateBuilder")]
      public function get createdAt():Date
      {
        return _createdAt;
      }
      public function set createdAt(value:Date):void
      {
        if (_createdAt == value)
          return;
        _createdAt = value;
      }
    }

[Mapping]タグにビルダークラスのフルネームを指定するとJSONのcreated_atの値をIClassBuilder::build()を使って変換します。

## JSONに配列要素がある場合

    {
      "name": "Unknown",
      "tags": [
        {
          "id": 1,
          "name": "プログラマ"
        },
        {
          "id": 2,
          "name": "中学生"
        },
        {
          "id": 3,
          "name": "女子校"
        }
      ]
    }

こんな風に、配列要素の中にオブジェクトがある場合

    import com.sample.Tag;
    class UserInfo
    {
      Tag; // importする為に、名前だけ記述（動作には影響なし）
      
      private var _name:String;
      [Mapping(name="name")]
      public function get name():String
      {
        return _name;
      }
      public function set name(value:String):void
      {
        if (_name == value)
          return;
        _name = value;
      }

      private var _tags:Array;
      [Mapping(name="tags", type="com.sample.Tag")]
      public function get tags():Array
      {
        return _tags;
      }
      public function set tags(value:Array):void
      {
        if (_tags == value)
          return;
        _tags = value;
      }
    }

プロパティをArrayで定義して、type要素に配列の中身の型を指定することで、指定した型のインスタンス配列を代入します。

# ライセンス

The MIT License

ソースコードと共にコミットしてありますので、詳しくはそちらを参照してください。


