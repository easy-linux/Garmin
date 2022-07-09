import Toybox.Lang;
import Toybox.WatchUi;

class SimpleRunTrackerDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenu() as Boolean {
        WatchUi.pushView(new Rez.Menus.MainMenu(), new SimpleRunTrackerMenuDelegate(), WatchUi.SLIDE_UP);
        return true;
    }

}