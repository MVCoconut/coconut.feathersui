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
  					case _: null;
				};
			}
			function getEventType(eventMeta:MetadataEntry) {
				final typedExprDef = Context.typeof(eventMeta.params[0]);
				switch (typedExprDef) {
					case TAbstract(a, b):
						return b[0].toString();
  					case _:
						  return null;
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
