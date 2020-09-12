package coconut.feathersui;

import coconut.diffing.Widget;

@:build(coconut.ui.macros.ViewBuilder.build((_ : coconut.feathersui.RenderResult)))
@:autoBuild(coconut.feathersui.View.autoBuild())
class View extends Widget<feathers.core.ValidatingSprite> {
	macro function hxx(e);
}
