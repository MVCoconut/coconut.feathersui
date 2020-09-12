package coconut.feathersui;

class View {
	static function hxx(_, e) {
		return coconut.feathersui.macros.HXX.parse(e);
	}

	static function autoBuild() {
		return coconut.diffing.macros.ViewBuilder.autoBuild(macro:coconut.feathersui.RenderResult);
	}
}
