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

      function process(cls:ClassType, maxDepth:Int) {
        if (maxDepth < 1) return;
        for (f in getFields(cls)) {
          var name = f.field.name,
              type = attrType(f);
          var expr = if (f.isDisplayObject) macro null else macro nu;
          init.push(macro ret.set($v{name}, function (target:$target, nu:$type, old:$type) target.$name = $expr));
        }

        for (e in getEvents(cls)) {
          var type = e.type;
          type = macro : tink.core.Callback<$type>;
          init.push(macro ret.set($v{e.name}, function (target:$target, nu:$type, old:$type) {
            if (old != null) target.removeEventListener($v{e.id}, old);
            if (nu != null) target.addEventListener($v{e.id}, nu);
          }));
        }

        if (!isDisplayObject(cls))
          process(cls.superClass.t.get(), maxDepth - 1);
      }

      process(cls, switch cls {
        case { pack: ['feathers', 'core'], name: 'ValidatingSprite'}: 100000;
        default:
          var parent = cls.superClass.t.toString().asComplexType();
          init.push(macro for (k => v in new coconut.feathersui.internal.Setters<$parent>()) ret.set(k, v));
          1;
      });

      var ret = macro class $name {

        static final INST = {
          var ret = new Map<String, (target:Dynamic, next:Dynamic, prev:Dynamic)->Void>();
          $b{init};
          ret;
        }

        public inline function new()
          this = INST;

        public function set(target:$target, nu:coconut.feathersui.internal.Attributes<$target>, old:coconut.feathersui.internal.Attributes<$target>, rnode:coconut.feathersui.internal.RNode<$target>)
          coconut.diffing.Factory.Properties.set(target, cast nu, cast old, (target, name, nu, old) -> this[name](target, nu, old));
      }

      ret.kind = TDAbstract(macro : Map<String, (target:Dynamic, next:Dynamic, prev:Dynamic)->Void>);
      ret.meta.push({ name: ':forward', params: [macro keyValueIterator], pos: (macro null).pos });
      return ret;
    });
  }
}