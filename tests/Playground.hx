import haxe.Timer;
import feathers.controls.Application;
import feathers.controls.Label;
import feathers.controls.Button;
import feathers.controls.ScrollContainer;
import coconut.feathersui.View;
import coconut.feathersui.Renderer;
import feathers.layout.AnchorLayout;

class Playground extends Application {
	public function new() {
		super();
		layout = new AnchorLayout();
		Renderer.mount(this, <MyView/>);
	}
}

class MyView extends View {
	@:state var value:Int = 0;
	function render() '
		<ScrollContainer>
			<Label text="Curretn value: ${value}" x={100} />
			<Button text= "My own button" x={100} y={100} onTrigger=${value++} />
		</ScrollContainer>
	';
}