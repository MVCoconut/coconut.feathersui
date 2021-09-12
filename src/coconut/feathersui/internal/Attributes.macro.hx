package coconut.feathersui.internal;

import coconut.feathersui.macros.Setup;
import haxe.macro.Context;
import haxe.macro.Type;
import haxe.macro.Expr;
using haxe.macro.Tools;
using tink.MacroApi;

class Attributes {
	static public function isDisplayObject(c:ClassType)
		return switch c {
			case { pack: ['flash' | 'openfl', 'display'], name: 'DisplayObject' }: true;
			default: false;
		}

	static public function attrType(f)
		return
			if (f.isDisplayObject) macro : coconut.feathersui.RenderResult;
			else (f.field:ClassField).type.toComplex();

	static public function getEvents(cls:ClassType)
		return [
			for (m in cls.meta.extract(':event'))
				for (p in m.params) {
					var id = getEventName(p);
					var eventType = getEventType(p);
					// https://github.com/HaxeFoundation/haxe/issues/8356
					var event = Context.parse('var event: $eventType', Context.currentPos());
					{
						id: id,
						name: 'on${id.charAt(0).toUpperCase()}${id.substr(1)}',
						type: event.expr.getParameters()[0][0].type,
						pos: p.pos,
					}
				}
		];

	static public function getFields(cls:ClassType)
		return [
			for (f in cls.fields.get())
				if (f.isPublic) switch f.kind {
					case FMethod(MethDynamic):
						{
							field: f,
							isDisplayObject: false,
						};
					case FVar(AccCall | AccNormal, AccCall | AccNormal):
						{
							field: f,
							isDisplayObject: f.type.match(TInst(isDisplayObject(_.get()) => true, _)),
						};
					default:
						continue;
				}
		];

	static function build() {
		return tink.macro.BuildCache.getType("coconut.feathersui.internal.Attributes", null, null, function(ctx) {
			var name = ctx.name,
					cls = ctx.type.getClass(),
					attrs = [];

			var attr = TAnonymous(attrs);

			if (!isDisplayObject(cls)) {
				var parent = cls.superClass.t.toString().asComplexType();
				attr = TIntersection([macro : coconut.feathersui.internal.Attributes<$parent>, attr]);
			}

			var optional:Array<MetadataEntry> = [{
				name: ':optional',
				params: [],
				pos: (macro null).pos,
			}];


			var dFault = switch Setup.defaultXmlProperty(cls) {
				case Some('xmlContent'): null;
				case Some(v): v;
				case None: null;
			}

			function add(f, type:ComplexType)
				attrs.push({
					name: f.name,
					pos: f.pos,
					meta: if (f.name == dFault) optional.concat([{ name: ':child', params: [], pos: (macro null).pos }]) else optional,
					kind: FProp('default', 'never', if (f.name == dFault && type.match(macro : String)) macro : coconut.feathersui.Text else type),
					access: [AFinal],
				});

			for (f in getFields(cls))
				add(f.field, attrType(f));

			for (e in getEvents(cls))
				add(e, { var t = e.type; macro : tink.core.Callback<$t>; });

			var ret = macro class $name {}

			ret.kind = TDAlias(attr);

			return ret;
		});
	}

	static function getEventName(e:Expr):String {
		final typedExprDef = Context.typeExpr(e).expr;
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

	static private final OpenFLEvent = "openfl.events.Event";
	static function isOfEventType(target:ClassType): Bool {
		var currentTarget = target;
		var searching = true;
		var result = false;
		while (searching) {
			final type = currentTarget.pack.concat([currentTarget.name]).join('.');
			if (type == OpenFLEvent) {
				searching = false;
				result = true;
			} else if (currentTarget.superClass != null) {
				currentTarget = currentTarget.superClass.t.get();
			} else {
				searching = false;
			}
		}
		return result;
	}

	static function getEventType(e:Expr) {
		final typeExprDef = Context.typeExpr(e);
		final typeOfDef = typeExprDef.t;
		switch (typeExprDef.expr) {
			case TField(_, FStatic(_.get() => cl, _.get() => f)):
				final initialType = cl.pack.concat([cl.name]).join('.');
				if (isOfEventType(cl)) {
					return initialType;
				} else {
					return OpenFLEvent;
				}
			default:
		}
		switch (typeOfDef) {
			case TAbstract(_, p):
				return p[0].toString();
			case TInst(_,_):
				return OpenFLEvent;
				default:

		};
		return null;
	}
}