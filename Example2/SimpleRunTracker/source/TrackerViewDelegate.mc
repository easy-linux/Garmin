import Toybox.Lang;
import Toybox.WatchUi;

class TrackerViewDelegate extends WatchUi.BehaviorDelegate {

    private var _view as TrackerView;

    function initialize(view as TrackerView) {
        _view = view;
        BehaviorDelegate.initialize();
    }

    function onMenu() as Boolean {
        return true;
    }

    function onSelect() as Boolean {
        if(_view.isSessionRecording()){
            _view.Stop();
        }
        WatchUi.pushView(new Rez.Menus.MainMenu(), new MainMenuDelegate(_view), WatchUi.SLIDE_UP);
        return true;
    }

}