package coconut.feathersui.macros;

#if macro
import haxe.macro.Type;
import haxe.macro.Context;
import haxe.macro.Expr;

using haxe.macro.Tools;
using tink.MacroApi;
using sys.FileSystem;
using haxe.io.Path;

class Events {
  static function getEvents() {
	final cl =  Context.getLocalClass().get();
	final events = new Map<String, String>();
	function crawl(target: ClassType) {
		final eventMeta: Array<Dynamic> = target.meta.extract(":event");
		function getEventName(eventMeta:MetadataEntry):String {
			final typedExprDef = Context.typeExpr(eventMeta.params[0]).expr;
			return switch (typedExprDef) {
				case TCast({expr: TConst(TString(s))}, _): s;
				case TConst(TString(s)): s;
				case TField(_, FStatic(_, _.get() => f)):
					switch (f.expr().expr) {
						case TConst(TString(s)): s;
						case TCast({expr: TConst(TString(s))}, _): s;
						case _: null;	
					}
				  case _: null;
			};
		}
		// TODO: remove dublicate in Attributes
		for (meta in eventMeta) {
			final eventName = getEventName(meta);
			final fieldName: String = 'on${eventName.charAt(0).toUpperCase()}${eventName.substr(1)}';
			events.set(fieldName, eventName);
		}
		if (target.superClass != null) {
			crawl(target.superClass.t.get());
		}
	}
	crawl(cl);
    // convert to expressions
    final exprs = [for(key => value in events) macro $v{key} => $v{value}];
    return macro $a{exprs};
  }
}
#else
class Events {
  macro static public function getEvents(a);
}
#end