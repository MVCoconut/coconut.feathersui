package coconut.feathersui.internal;

import haxe.macro.Context;
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
						setters.set(native, v.data, null, this, parent, later);
					}
					override function updateNative(native:$target, next:coconut.feathersui.internal.VNode<$target>, prev:coconut.feathersui.internal.VNode<$target>, parent, later) {
						setters.set(native, next.data, prev.data, this, parent, later);
					}
				}

			function add(td)
				ret.fields = ret.fields.concat(td.fields);

			switch Context.follow(Context.typeof(macro (null:coconut.feathersui.internal.Attributes<$target>))) {
				case TAnonymous(_.get().fields => fields):
					var rr = Context.getType('coconut.feathersui.RenderResult');
					for (f in fields) if (f.type.unifiesWith(rr)) {
						var name = f.name;

						var setter = 'set_$name';
						add(macro class {
							var $name:coconut.feathersui.internal.Inlay = Empty;
							public function $setter(param:coconut.feathersui.RenderResult, parent, later) {

								final singular = (cast param:coconut.diffing.internal.VNode<feathers.core.ValidatingSprite>).isSingular;
								final singular = false;

								final applicator = @:privateAccess coconut.feathersui.Renderer.BACKEND;

								function destroy() {
									switch ($i{name}) {
										case Plural(cell):
											cell.destroy(applicator);
											native.$name = null;
										case _:
									}
									$i{name} = Empty;
								}

								switch param {
									case null:
										destroy();
									default:
										switch ($i{name}) {
											case Singular(_):
												throw 'assert';
											case Plural(cell):
												if (singular) throw 'assert';
												cell.update(param, null, later);
											case _:
												if (singular) throw 'assert';
												var sprite:feathers.core.ValidatingSprite = new feathers.core.MeasureSprite();
												var cell = new coconut.diffing.internal.RCell(parent, param, applicator.children(sprite), later);
												$i{name} = Plural(cell);
												native.$name = sprite;
										}
								}


							}
						});
					}
				default:
			}

			return ret;
		});
	}
}