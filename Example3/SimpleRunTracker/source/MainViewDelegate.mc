import Toybox.Lang;
import Toybox.WatchUi;

class MainViewDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenu() as Boolean {
        return true;
    }

    function onSelect()as Boolean {
        var v = new TrackerView();
        WatchUi.pushView(v, new TrackerViewDelegate(v), WatchUi.SLIDE_UP);
        System.println("Start tracking");
    }

}