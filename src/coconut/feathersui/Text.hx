package coconut.feathersui;

abstract Text(String) from String to String {

  @:from static function ofInt(a:Int):Text
    return Std.string(a);

  @:from static function ofArray(a:Array<Text>):Text
    return switch a {
      case []: '';
      case [v]: v;
      default: a.join('');
    }
}