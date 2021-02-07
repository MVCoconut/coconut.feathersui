import openfl.events.Event;
import feathers.events.TriggerEvent;
import feathers.controls.*;
import coconut.feathersui.*;
import feathers.layout.*;

class Playground extends Application {
	public function new() {
		super();
		layout = new AnchorLayout();
		Renderer.mount(this, <MyView/>);
	}

	#if nadakofl
	static function main() {
		// var p:coconut.feathersui.internal.Attributes<Label> = {
		// };
		var s = new coconut.feathersui.internal.VNode<Label>({ doubleClickEnabled: true });
		openfl.display.Stage.create(Playground.new, {
			element: js.Browser.document.getElementById("main"),
			background: 0xCCCCCC,
			allowHighDPI: true,
			resizable: true,
			depthBuffer: false,
			stencilBuffer: true
		});
	}
	#end
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
			<FormItem text="User Name" content=${hxx('<TextInput prompt="hello@example.com"/>')}/>
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