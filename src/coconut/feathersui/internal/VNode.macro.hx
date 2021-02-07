package coconut.feathersui.internal;

using tink.MacroApi;

class VNode {

  static function build() {
    return tink.macro.BuildCache.getType("coconut.feathersui.internal.VNode", null, null, function (ctx) {
      var name = ctx.name,
          target = ctx.type.toComplex();

      return macro class $name extends coconut.diffing.internal.VNativeBase<feathers.core.ValidatingSprite, $target> {

        static final TYPE = new coconut.diffing.TypeId();

        public function new(data:coconut.feathersui.internal.Attributes<$target>, ?key, ?ref, ?children) {
          super(TYPE, key, ref, children);
        }

        override public function render(parent, cursor, later):coconut.diffing.internal.RNode<feathers.core.ValidatingSprite>
          return new coconut.feathersui.internal.RNode<$target>(this, $i{name}, parent, cursor, later);

        override function create() {
          return ${ctx.type.getID().instantiate()};
        }
      };
    });
  }
}