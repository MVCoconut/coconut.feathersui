package coconut.feathersui;

import coconut.diffing.internal.VWidget;
import coconut.feathersui.RenderResult;
import feathers.core.ValidatingSprite;

class Implicit extends Implicit<ValidatingSprite, RenderResult> {
	static final TYPE = mplicit.type();

	static public function fromHxx(attr):RenderResult {
		return VWidget(TYPE, null, null, attr);
	}
}
