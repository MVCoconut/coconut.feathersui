package coconut.feathersui.internal;

using tink.MacroApi;

class VNode {

	static function build() {
		return tink.macro.BuildCache.getType("coconut.feathersui.internal.VNode", null, null, function (ctx) {
			var name = ctx.name,
					target = ctx.type.toComplex();

			return macro class $name extends coconut.diffing.internal.VNativeBase<feathers.core.ValidatingSprite, $target> {

				static final TYPE = new coconut.diffing.TypeId();

				public final data:coconut.feathersui.internal.Attributes<$target>;

				public function new(data, ?key, ?ref, ?children) {
					super(TYPE, key, ref, children);
					this.data = data;
				}

				override public function render(parent, cursor, later, hydrate):coconut.diffing.internal.RNode<feathers.core.ValidatingSprite>
					return new coconut.feathersui.internal.RNode<$target>(this, $i{name}, parent, cursor, later);

				override function create(?previous) {
					return @:privateAccess ${ctx.type.getID().instantiate()};//this is not good
				}
			};
		});
	}
}