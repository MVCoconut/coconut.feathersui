package coconut.feathersui.internal;

using tink.MacroApi;

class RNode {

  static function build() {
    return tink.macro.BuildCache.getType("coconut.feathersui.internal.RNode", null, null, function (ctx) {
      var name = ctx.name,
          target = ctx.type.toComplex();

      var ret =
        macro class $name extends coconut.diffing.internal.VNativeBase.RNativeBase<
          coconut.feathersui.internal.VNode<$target>,
          feathers.core.ValidatingSprite,
          $target
        > {
          final setters = new coconut.feathersui.internal.Setters<$target>();
          public function new(v, cls, parent, cursor, later) {
            super(v, cls, parent, cursor, later);
            setters.set(native, v.data, null, this);
          }
          override function updateNative(native:$target, next:coconut.feathersui.internal.VNode<$target>, prev:coconut.feathersui.internal.VNode<$target>) {
            setters.set(native, next.data, prev.data, this);
          }
        }

      return ret;
    });
  }
}