package feathers.controls;

import feathers.core.FeathersControl;
import openfl.events.Event;
import openfl.events.EventType;

@:event(feathers.controls.TestControl.MY_EVENT)
@:event(feathers.controls.TestControl.MY_EVENT2)
@:event(feathers.controls.CustomeEvent.MY_EVENT3)
@:event(feathers.controls.CustomeEvent.MY_EVENT4)
@:event(feathers.controls.CustomeEvent.MY_EVENT5)
class TestControl extends FeathersControl {
    public static inline var MY_EVENT = "myEvent";
    public static final MY_EVENT2 = "myEvent2";
    public function new() {
        super();
        final timer = new haxe.Timer(1000);
        timer.run = () -> {
            dispatchEvent(new Event(TestControl.MY_EVENT));
            dispatchEvent(new Event(TestControl.MY_EVENT2));
            dispatchEvent(new CustomeEvent(CustomeEvent.MY_EVENT3));
            dispatchEvent(new CustomeEvent(CustomeEvent.MY_EVENT4));
        };
    }
}

class CustomeEvent extends Event {
    public static final MY_EVENT3: EventType<CustomeEvent> = "myEvent3";
    public static inline var MY_EVENT4: EventType<CustomeEvent> = "myEvent4";
    public static inline var MY_EVENT5 = "myEvent5";
}