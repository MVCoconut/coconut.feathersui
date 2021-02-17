package coconut.feathersui;

import coconut.diffing.*;
import tink.state.Observable;
import feathers.core.*;
import openfl.display.*;

@:allow(coconut.feathersui)
class Renderer {
	static final BACKEND = new FeathersUIBackend();

	static public function mountInto(target:ValidatingSprite, virtual:RenderResult) {
		Root.fromNative(target, BACKEND).render(virtual);
	}

	static public function getNative(view:View):Null<ValidatingSprite> {
		return getAllNative(view)[0];
	}

	static public function getAllNative(view:View):Array<ValidatingSprite> {
		return Widget.getAllNative(view);
	}

	static public inline function updateAll() {
		Observable.updateAll();
	}

	static public macro function hxx(e);

	static public macro function mount(target, markup);
}

private class FeathersUICursor implements Cursor<ValidatingSprite> {
	var pos:Int;
	final container:DisplayObjectContainer;
	public final applicator:Applicator<ValidatingSprite>;

	public function new(applicator, container:DisplayObjectContainer, pos:Int) {
		this.applicator = applicator;
		this.container = container;
		this.pos = pos;
	}

	public function insert(real:ValidatingSprite) {
		container.addChildAt(real, pos++);
	}

	public function delete(count:Int) {
		for (i in 0...count)
			container.removeChildAt(pos);
	}
}

private class FeathersUIBackend implements Applicator<ValidatingSprite> {
	public function new() {}

	public function siblings(target:ValidatingSprite):Cursor<ValidatingSprite> {
		return new FeathersUICursor(this, target.parent, target.parent.getChildIndex(target));
	}
	public function children(target:ValidatingSprite):Cursor<ValidatingSprite> {
		return new FeathersUICursor(this, target, 0);
	}

	static final pool = [];

	public function createMarker():ValidatingSprite
		return switch pool.pop() {
			case null: new MeasureSprite();
			case v: v;
		}

	public function releaseMarker(m:ValidatingSprite)
		pool.push(m);
}