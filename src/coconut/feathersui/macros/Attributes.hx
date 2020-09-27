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
					final constant = meta.params[0];
					final type = meta.params[1];
					final eventName = ExprTools.getValue(constant);
					final typeName = ExprTools.toString(type);
					final fieldName = 'on${eventName.charAt(0).toUpperCase()}${eventName.substr(1)}';
					switch(callback) {
						case TAbstract(a, _):
							addField(fieldName, Context.currentPos(), TAbstract(a,[Context.typeof(type)]));
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
