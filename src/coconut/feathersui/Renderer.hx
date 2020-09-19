package coconut.feathersui;

import feathers.controls.Label;
import coconut.diffing.Cursor;
import coconut.diffing.Applicator;
import coconut.diffing.NodeType;
import coconut.diffing.Rendered;
import coconut.diffing.Differ;
import coconut.diffing.VNode;
import coconut.diffing.Widget;
import tink.state.Observable;
import feathers.core.ValidatingSprite;
import feathers.core.MeasureSprite;
import openfl.display.DisplayObjectContainer;

class Renderer {
	static var DIFFER = new Differ(new FeathersUIBackend());

	static public function mountInto(target:DisplayObjectContainer, virtual:RenderResult) {
		DIFFER.render([virtual], cast(target, ValidatingSprite));
	}

	static public function getNative(view:View):Null<ValidatingSprite> {
		return getAllNative(view)[0];
	}

	static public function getAllNative(view:View):Array<ValidatingSprite> {
		return switch @:privateAccess view._coco_lastRender {
			case null: [];
			case r: r.flatten(null);
		}
	}
	
	static public inline function updateAll() {
		Observable.updateAll();
	}

	static public macro function hxx(e);

	static public macro function mount(target, markup);
}

private class FeathersUICursor implements Cursor<ValidatingSprite> {
	var pos:Int;
	var container:DisplayObjectContainer;

	public function new(container:DisplayObjectContainer, pos:Int) {
		this.container = container;
		this.pos = pos;
	}

	public function insert(real:ValidatingSprite):Bool {
		final inserted = real.parent != container;
		container.addChildAt(real, pos);
		pos++;
		return inserted;
	}

	public function delete():Bool {
		return if (pos <= container.numChildren) {
			container.removeChild(current());
			true;
		} else false;
	}

	public function step():Bool {
		return if (pos >= container.numChildren) false; else ++pos == container.numChildren;
	}
	public function current():ValidatingSprite {
		return cast(container.getChildAt(pos), ValidatingSprite);
	}	
}

private class FeathersUIBackend implements Applicator<ValidatingSprite> {
	public function new() {}

	final registry:Map<ValidatingSprite, Rendered<ValidatingSprite>> = new Map();

	public function unsetLastRender(target:ValidatingSprite):Rendered<ValidatingSprite> {
		var ret = registry[target];
		registry.remove(target);
		return ret;
	}
	public function setLastRender(target:ValidatingSprite, r:Rendered<ValidatingSprite>):Void {
		registry[target] = r;
	}
	public function getLastRender(target:ValidatingSprite):Null<Rendered<ValidatingSprite>> {
		return registry[target];
	}
	public function traverseSiblings(target:ValidatingSprite):Cursor<ValidatingSprite> {
		return new FeathersUICursor(target.parent, target.parent.getChildIndex(target));
	}
	public function traverseChildren(target:ValidatingSprite):Cursor<ValidatingSprite> {
		return new FeathersUICursor(target, 0);
	}
	public function placeholder(target):RenderResult {
		return PLACEHOLDER;
	}

	static final PLACEHOLDER: RenderResult = new MeasureSprite();
}

class FeathersUINodeType<Attr:{}, Real:ValidatingSprite> implements NodeType<Attr, Real> {
	final factory:Attr->Real;
	public function new(factory) {
		this.factory = factory;
	}
	inline function set(target:Real, prop:String, val:Dynamic, old:Dynamic) {
		// TODO: find better way
		if (prop.indexOf("on") == 0) {
			final eventName = prop.substr(2);
			final event = '${eventName.substr(0, 1).toLowerCase()}${eventName.substr(1)}';
			if (old != val) {
				if (old != null)  {
					target.removeEventListener(event, old);
				}
				if (val != null) {
					target.addEventListener(event, val);
				}
			}
		} else {
			Reflect.setProperty(target, prop, val);
		}
	}
	public function create(a:Attr):Real {
		final ret = factory(a);
		// TODO: should not be necessary
		Differ.updateObject(ret, a, null, set);
		return ret;
	}
	public function update(r:Real, old:Attr, nu:Attr):Void {
		Differ.updateObject(r, nu, old, set);
	}	
}
