package coconut.feathersui.internal;

import coconut.diffing.Cursor;
import feathers.core.*;
import openfl.display.DisplayObject;
import coconut.diffing.internal.*;

class Inlay {
	static final applicator = Renderer.BACKEND;

	var state = Empty;

	final parent:Parent;
	final assign:DisplayObject->Void;

	public function new(parent, assign) {
		this.parent = parent;
		this.assign = assign;
	}

	public function update(r:RenderResult, later) {
		final singular = (cast r:coconut.diffing.internal.VNode<ValidatingSprite>).isSingular;

		function createSingular() {
			state = Singular(new RCell(parent, r, new SingleCursor(assign), later, false));
		}

		function createPlural() {
			final sprite = new MeasureSprite();
			state = Plural(new RCell(parent, r, applicator.children(sprite), later, false));
			assign(sprite);
		}

		switch r {
			case null:
				destroy();
			default:
				switch state {
					case Singular(cell):
						if (singular)
							cell.update(r, new SingleCursor(assign), later);
						else {
							destroy();
							createPlural();
						}
					case Plural(cell):
						if (singular) {
							destroy();
							createSingular();
						}
						else cell.update(r, null, later);
					case Empty:
						if (singular) createSingular();
						else createPlural();
				}
		}
	}

	function destroy() {
		switch state {
			case Plural(cell):
				cell.destroy(applicator);
				assign(null);
			case _:
		}
		state = Empty;
	}
}

private enum InlayState {
	Empty;
	Singular(cell:RCell<ValidatingSprite>);
	Plural(p:RCell<ValidatingSprite>);
}

private class SingleCursor extends Cursor<ValidatingSprite> {
	final assign:DisplayObject->Void;

	public function new(assign) {
		super(Renderer.BACKEND);
		this.assign = assign;
	}

	public function insert(native:ValidatingSprite):Void {
		assign(native);
	}

	public function delete(count:Int):Void {
		if (count > 0)
			assign(null);
	}
}