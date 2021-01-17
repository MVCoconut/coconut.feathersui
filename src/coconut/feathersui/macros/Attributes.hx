package coconut.feathersui.macros;

#if macro
import haxe.macro.Type;
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type.Ref;

using haxe.macro.Tools;
using tink.MacroApi;
using Lambda;
#else
@:genericBuild(coconut.feathersui.macros.Attributes.build())
#end
class Attributes<T> {
	#if macro
	private static final OpenFLEvent = "openfl.events.Event";
	static function build()
		return tink.macro.BuildCache.getType("coconut.feathersui.macros.Attributes", function(ctx) {
			final fields:Array<Field> = [], added = new Map();
			final cl:ClassType = ctx.type.getClass();
			function addField(name, pos, type:Type, ?mandatory) {
				if (!added[name]) {
					added[name] = true;
					fields.push({
						name: name,
						pos: pos,
						kind: FProp('default', 'never', type.toComplex()),
						meta: if (mandatory) [] else [{name: ':optional', params: [], pos: pos}],
					});
				}
			}
			function getEventName(eventMeta:MetadataEntry):String {
				final typedExprDef = Context.typeExpr(eventMeta.params[0]).expr;
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
			function isOfEventType(target:ClassType): Bool {
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
			function getEventType(eventMeta:MetadataEntry) {
				final typeOfDef = Context.typeof(eventMeta.params[0]);
				final typeExprDef = Context.typeExpr(eventMeta.params[0]);
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
			function crawl(target:ClassType) {
				final fields = target.fields.get();
				for (f in fields)
					if (f.isPublic) {
						function add(?t) {
							if (t == null)
								add(f.type)
							else {
								addField(f.name, f.pos, f.type);
							}
						}
						switch f.kind {
							case FMethod(MethDynamic):
								f.meta.add(':keep', [], f.pos);
								add();
							case FVar(_, AccCall):
								fields.find(v -> v.name == 'set_' + f.name).meta.add(':keep', [], f.pos); // keep the setter
								add();
							case FVar(_, AccNormal):
								f.meta.add(':keep', [], f.pos);
								add();
							default:
						}
					}

				final eventMeta = target.meta.extract(":event");
				final callback = Context.getType("tink.core.Callback");
				// TODO: remove dublicate in Events
				for (meta in eventMeta) {
					final eventName = getEventName(meta);
					final type = getEventType(meta);
					final fieldName = 'on${eventName.charAt(0).toUpperCase()}${eventName.substr(1)}';
					switch(callback) {
						case TAbstract(a, _):
							addField(fieldName, Context.currentPos(), TAbstract(a,[Context.getType(type)]));
							default:	
					}
				}
				if (target.superClass != null) {
					crawl(target.superClass.t.get());
				}
					
			}
			switch cl.constructor.get().type.reduce() {
				case TFun(args, _):
					for (a in args) {
						if (!a.opt)
							addField(a.name, cl.pos, a.t, true);
					}	
				default:
					throw 'assert';
			}
			crawl(cl);
			return {
				name: ctx.name,
				pack: [],
				pos: ctx.pos,
				fields: fields,
				kind: TDAlias(TAnonymous(fields))
			};
		});
	#end
}
