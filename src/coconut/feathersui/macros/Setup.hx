package coconut.feathersui.macros;

#if macro
import haxe.macro.*;
import haxe.macro.Type;
import haxe.macro.Expr;

using haxe.macro.Tools;
using tink.MacroApi;
using sys.FileSystem;
using haxe.io.Path;

class Setup {
	static function all() {
		var cl = Context.getType("feathers.core.ValidatingSprite").getClass();
		if (!cl.meta.has(':hxx.augmented')) {
			cl.meta.add(':hxx.augmented', [], (macro null).pos);
			cl.meta.add(':autoBuild', [macro @:pos(cl.pos) coconut.feathersui.macros.Setup.hxxAugment()], cl.pos);
		}
	}

	static function hxxAugment():Array<Field> {
		final cl = Context.getLocalClass().get();
		final fields = Context.getBuildFields();

		switch [for (f in fields) if (f.name == 'new') f] {
			case [v]:
				if (v.access == null || v.access.indexOf(APublic) == -1)
					return null;
			default:
				return null;
		}

		final self = Context.getLocalType().toComplex(); // TODO: type params

		final attr = macro : coconut.feathersui.internal.Attributes<$self>;
		final meta = macro : {
			@:optional var key(default, never):coconut.diffing.Key;
			@:optional var ref(default, never):coconut.ui.Ref<$self>;
		};

		return fields.concat((macro class {

			static public inline function fromHxx(
				hxxMeta: $meta,
				attr:$attr, ?children:coconut.feathersui.Children
			):coconut.feathersui.RenderResult {
				return new coconut.feathersui.internal.VNode<$self>(attr, hxxMeta.key, hxxMeta.ref, children);
			}
		}).fields);
	}
}
#end
