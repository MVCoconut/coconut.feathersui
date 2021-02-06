import openfl.events.Event;
import feathers.events.TriggerEvent;
import feathers.controls.Application;
import feathers.controls.Label;
import feathers.controls.Button;
import feathers.controls.TestControl;
import feathers.controls.LayoutGroup;
import feathers.layout.VerticalLayout;
import coconut.feathersui.View;
import coconut.feathersui.Renderer;
import feathers.layout.AnchorLayout;

class Playground extends Application {
	public function new() {
		super();
		layout = new AnchorLayout();
		Renderer.mount(this, <MyView/>);
	}

	static function main() {
		openfl.display.Stage.create(Playground.new, {
			element: js.Browser.document.getElementById("main"),
			background: 0xCCCCCC,
			allowHighDPI: true,
			resizable: true,
			depthBuffer: false,
			stencilBuffer: true
		});
	}
}

class MyView extends View {
	@:state var value:Int = 0;
	@:state var myEventValue:Int = 0;
	@:state var myEventValue2:Int = 0;
	@:state var myEventValue3:Int = 0;
	@:state var myEventValue4:Int = 0;
	function render() '
		<LayoutGroup layout=${new VerticalLayout()}>
			<Label text="Curretn value: ${value}" />
			<Label text="MyEvent value: ${myEventValue}" />
			<Label text="MyEvent2 value: ${myEventValue2}" />
			<Label text="MyEvent3 value: ${myEventValue3}" />
			<Label text="MyEvent4 value: ${myEventValue4}" />
			<Button text= "My own button" onTrigger=${onTriger} />
			<TestControl
				onMyEvent=${onMyEvent}
				onMyEvent2=${onMyEvent2}
				onMyEvent3=${onMyEvent3}
				onMyEvent4=${onMyEvent4}
			/>
		</LayoutGroup>
	';
	function onTriger(e: TriggerEvent) {
		value++;
	}
	function onMyEvent(e: Event) {
		myEventValue++;
	}
	function onMyEvent2(e: Event) {
		myEventValue2++;
	}
	function onMyEvent3(e: Event) {
		myEventValue3++;
	}
	function onMyEvent4(e: Event) {
		myEventValue4++;
	}
}