package coconut.feathersui.internal;

import coconut.feathersui.internal.Attributes.*;
import haxe.macro.Type;
import haxe.macro.Expr;
using haxe.macro.Tools;
using tink.MacroApi;

class Setters {

  static function build() {
    return tink.macro.BuildCache.getType("coconut.feathersui.internal.Setters", null, null, function(ctx) {
      var name = ctx.name,
          target = ctx.type.toComplex(),
          cls = ctx.type.getClass(),
          init = [];

      if (!isDisplayObject(cls)) {
        var parent = cls.superClass.t.toString().asComplexType();
        init.push(macro for (k => v in new coconut.feathersui.internal.Setters<$parent>()) ret.set(k, v));
      }

      for (f in getFields(cls)) {
        var name = f.src.name,
            type = f.type;
        init.push(macro ret.set($v{name}, function (target:$target, nu:$type, old:$type) target.$name = nu));
      }

      for (e in getEvents(cls)) {
        var name = macro $v{e.name},
            type = e.type;
        type = macro : tink.core.Callback<$type>;
        init.push(macro ret.set($name, function (target:$target, nu:$type, old:$type) {
          if (old != null) target.removeEventListener($name, old);
          if (nu != null) target.addEventListener($name, nu);
        }));
      }

      var ret = macro class $name {

        static final INST = {
          var ret = new Map<String, (target:Dynamic, next:Dynamic, prev:Dynamic)->Void>();
          $b{init};
          ret;
        }

        public inline function new()
          this = INST;

        public function set(target:$target, nu:coconut.feathersui.internal.Attributes<$target>, old:coconut.feathersui.internal.Attributes<$target>)
          coconut.diffing.Factory.Properties.set(target, cast nu, cast old, (target, name, nu, old) -> this[name](target, nu, old));
      }

      ret.kind = TDAbstract(macro : Map<String, (target:Dynamic, next:Dynamic, prev:Dynamic)->Void>);
      ret.meta.push({ name: ':forward', params: [macro keyValueIterator], pos: (macro null).pos });
      return ret;
    });
  }
}