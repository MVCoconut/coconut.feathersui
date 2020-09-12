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
		cl.meta.add(':autoBuild', [macro @:pos(cl.pos) coconut.feathersui.macros.Setup.hxxAugment()], cl.pos);
	}

	static function hxxAugment():Array<Field> {
		var cl = Context.getLocalClass().get(),
			fields = Context.getBuildFields();

		switch [for (f in fields) if (f.name == 'new') f] {
			case [v]:
				if (v.access == null || v.access.indexOf(APublic) == -1)
					return null;
			default:
				return null;
		}

		var self = Context.getLocalType().toComplex(); // TODO: type params

		return fields.concat((macro class {
			static var COCONUT_NODE_TYPE = new coconut.feathersui.Renderer.FeathersUINodeType<coconut.feathersui.macros.Attributes<$self>,
				feathers.core.ValidatingSprite>(attr -> coconut.feathersui.macros.Instantiate.nativeView(attr));

			static public inline function fromHxx(hxxMeta:{
				@:optional var key(default, never):coconut.diffing.Key;
				@:optional var ref(default, never):coconut.ui.Ref<$self>;
			},
					attr:coconut.feathersui.macros.Attributes<$self>, ?children:coconut.feathersui.Children):coconut.feathersui.RenderResult {
				return coconut.diffing.VNode.native(COCONUT_NODE_TYPE, cast hxxMeta.ref, hxxMeta.key, attr, children);
			}
		}).fields);
	}
}
#end
