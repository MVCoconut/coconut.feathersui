package coconut.feathersui;

import coconut.diffing.Implicit;
import coconut.diffing.VNode.VNodeData.VWidget;
import coconut.feathersui.RenderResult;
import feathers.core.ValidatingSprite;

class Implicit extends Implicit<ValidatingSprite, RenderResult> {
	static final TYPE = Implicit.type();

	static public function fromHxx(attr):RenderResult {
		return VWidget(TYPE, null, null, attr);
	}
}
