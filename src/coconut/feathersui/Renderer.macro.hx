package coconut.feathersui;

class Renderer {
	static public function hxx(e) {
		return coconut.feathersui.macros.HXX.parse(e);
	}

	static function mount(target, markup) {
		return coconut.ui.macros.Helpers.mount(macro coconut.feathersui.Renderer.mountInto, target, markup, hxx);
	}
}
