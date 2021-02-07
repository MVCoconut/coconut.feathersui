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

        }

      return ret;
    });
  }
}