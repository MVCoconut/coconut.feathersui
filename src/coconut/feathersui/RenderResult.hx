package coconut.feathersui;

import coconut.diffing.VNode;
import feathers.core.ValidatingSprite;

@:pure
abstract RenderResult(VNode<ValidatingSprite>) to VNode<ValidatingSprite> from VNode<ValidatingSprite> {
	inline function new(n) {
		this = n;
	}

	@:from static function ofNode(n:ValidatingSprite):RenderResult {
		return VNode.embed(n);
	}
}