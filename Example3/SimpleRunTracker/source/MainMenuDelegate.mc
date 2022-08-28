import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.System;

class MainMenuDelegate extends WatchUi.BehaviorDelegate {

    private var _view as TrackerView;

    function initialize(view as TrackerView) {
        _view = view;
        BehaviorDelegate.initialize();
    }


    function onMenuItem(item as Symbol) as Void {
        if(item == :item_continue){
          System.println("Continue");
          _view.Continue();
        } else if(item == :item_save){
          System.println("Save");
          _view.Save();
        } else if(item == :item_remove){
          System.println("Remove");
          _view.Remove();
        }
    }

}