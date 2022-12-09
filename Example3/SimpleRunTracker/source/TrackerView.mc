import Toybox.Graphics;
import Toybox.WatchUi;

import Toybox.System;
import Toybox.ActivityRecording;
import Toybox.Activity;
import Toybox.Position;
import Toybox.Timer;
import Toybox.Math;
import Toybox.Lang;

class TrackerView extends WatchUi.View {
  public var isRun as Boolean;
  private var _session as Session?;
  private var _info as Toybox.Activity.Info?;
  private var _distance as Float;
  private var _timer as Timer.Timer;
  private var _screenShape as ScreenShape;

  private var _averageSpeed as String;
  private var _currentSpeed as String;
  private var _maxSpeed as String;
  private var _elapsedDistance as String;
  private var _averageHeartRate as String;
  private var _currentHeartRate as String;
  private var _maxHeartRate as String;
  private var _elapsedTime as String;

  function initialize() {
    try {
      View.initialize();
      isRun = true;

      _averageSpeed = "0";
      _currentSpeed = "0";
      _maxSpeed = "0";
      _elapsedDistance = "0";
      _averageHeartRate = "0";
      _currentHeartRate = "0";
      _maxHeartRate = "0";
      _elapsedTime = "0.0";
      _screenShape = System.getDeviceSettings().screenShape;
      _session = ActivityRecording.createSession({
        :name => "Simple running",
        :sport => ActivityRecording.SPORT_RUNNING,
        :subSport => ActivityRecording.SUB_SPORT_STREET,
      });
      if (_session has :setTimerEventListener) {
        _session.setTimerEventListener(method(:onSessionTimer));
      }
      _session.start();
    } catch (e) {
      System.println("Error in Tracking init");
    }
  }

  function onSessionTimer(eventType as ActivityRecording.TimerEventType, eventData as Lang.Dictionary) as Void {
    try {
      switch (eventType) {
        case 0: {
          isRun = true;
          break;
        }
        case 1: {
          isRun = false;
          break;
        }
        case 2: {
          isRun = false;
          break;
        }
        case 3: {
          isRun = true;
          break;
        }
        case 4: {
          break;
        }
        case 5: {
          break;
        }
        case 6: {
          break;
        }
        case 7: {
          break;
        }
      }
    } catch (e) {
      System.println("Error in onSessionTimer");
    }
  }

  // Called when this View is brought to the foreground. Restore
  // the state of this View and prepare it to be shown. This includes
  // loading resources into memory.
  function onShow() as Void {
    Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:onPosition));
    _timer = new Timer.Timer();
    _timer.start(method(:onTimer), 1000, true);
  }

  public function isSessionRecording() as Boolean {
    if (_session != null) {
      return _session.isRecording();
    }
    return false;
  }

  function onTimer() {
    try {
      if (isSessionRecording() && isRun) {
        var localInfo = Activity.getActivityInfo();
        if (localInfo) {
          if (localInfo has :timerState) {
            if (localInfo.timerState == 3) {
              _info = localInfo;
              updateData(localInfo);
              WatchUi.requestUpdate();
            }
          } else {
            _info = localInfo;
            updateData(localInfo);
            WatchUi.requestUpdate();
          }
        }
      }
    } catch (e) {
      System.println("Error in onTimer");
    }
  }

  function updateData(info as Toybox.Activity.Info) as Void {
    if (info) {
      try {
        if (info has :averageSpeed) {
          _averageSpeed = (info.averageSpeed * 3.6).format("%2.1f");
        }
        if (info has :currentSpeed) {
          _currentSpeed = (info.currentSpeed * 3.6).format("%2.1f");
        }
        if (info has :maxSpeed) {
          _maxSpeed = (info.maxSpeed * 3.6).format("%2.1f");
        }
        if (info has :elapsedDistance) {
          _elapsedDistance = info.elapsedDistance.format("%2d");
        }
        if (info has :averageHeartRate) {
          _averageHeartRate = info.averageHeartRate;
        }
        if (info has :currentHeartRate) {
          _currentHeartRate = info.currentHeartRate;
        }
        if (info has :maxHeartRate) {
          _maxHeartRate = info.maxHeartRate;
        }
        if (info has :elapsedTime) {
            if(info.elapsedTime < 1000){
            //in msec
            _elapsedTime = "" + info.elapsedTime.format("%2.1f") + " ("+WatchUi.loadResource($.Rez.Strings.time_ms) + ")";
            } else if(info.elapsedTime < 60000){
                //in sec
                _elapsedTime = "" + (info.elapsedTime / 1000.0).format("%2.1f") + " ("+WatchUi.loadResource($.Rez.Strings.time_sec) + ")";
            } else if(info.elapsedTime < 60000 * 60){
                //in min
                _elapsedTime = "" + (info.elapsedTime / 60000.0).format("%2.1f") + " ("+WatchUi.loadResource($.Rez.Strings.time_min) + ")";
            } else {
                _elapsedTime = "" + (info.elapsedTime / 3600000.0).format("%2.1f") + " ("+WatchUi.loadResource($.Rez.Strings.time_hour) + ")";
            }
        }
      } catch (e) {
        System.println("Error updateData");
      }
    }
  }

  // Update the view
  function onUpdate(dc as Dc) as Void {
    // Call the parent onUpdate function to redraw the layout
    View.onUpdate(dc);
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_WHITE);
    dc.clear();
    dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);

    var x = dc.getWidth() / 2;
    var y = 0;

    var smallFontH = dc.getFontHeight(Graphics.FONT_XTINY);
    var bigFontH = dc.getFontHeight(Graphics.FONT_TINY);

    var myTime = System.getClockTime();

    dc.drawText(x, y, Graphics.FONT_TINY, myTime.hour.format("%02d") + ":" + myTime.min.format("%02d"), Graphics.TEXT_JUSTIFY_CENTER);

    y += bigFontH;

    dc.drawText(
      x,
      y,
      Graphics.FONT_XTINY,
      WatchUi.loadResource($.Rez.Strings.speed) + " (" + WatchUi.loadResource($.Rez.Strings.speed_label) + ")",
      Graphics.TEXT_JUSTIFY_CENTER
    );

    y += smallFontH;

    dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
    dc.drawText(x - 70, y, Graphics.FONT_XTINY, WatchUi.loadResource($.Rez.Strings.average), Graphics.TEXT_JUSTIFY_CENTER);

    dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
    dc.drawText(x, y, Graphics.FONT_XTINY, WatchUi.loadResource($.Rez.Strings.current), Graphics.TEXT_JUSTIFY_CENTER);

    dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
    dc.drawText(x + 70, y, Graphics.FONT_XTINY, WatchUi.loadResource($.Rez.Strings.max), Graphics.TEXT_JUSTIFY_CENTER);

    y += smallFontH;

    dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
    dc.drawText(x - 70, y, Graphics.FONT_TINY, _averageSpeed, Graphics.TEXT_JUSTIFY_CENTER);

    dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
    dc.drawText(x, y, Graphics.FONT_TINY, _currentSpeed, Graphics.TEXT_JUSTIFY_CENTER);

    dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
    dc.drawText(x + 70, y, Graphics.FONT_TINY, _maxSpeed, Graphics.TEXT_JUSTIFY_CENTER);

    y += bigFontH;

    dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);

    dc.drawText(
      x,
      y,
      Graphics.FONT_XTINY,
      WatchUi.loadResource($.Rez.Strings.distance) + " (" + WatchUi.loadResource($.Rez.Strings.distance_label) + ")",
      Graphics.TEXT_JUSTIFY_CENTER
    );

    y += smallFontH;
    dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
    dc.drawText(x, y, Graphics.FONT_TINY, _elapsedDistance, Graphics.TEXT_JUSTIFY_CENTER);

    y += bigFontH;

    dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
    dc.drawText(x - 70, y, Graphics.FONT_XTINY, WatchUi.loadResource($.Rez.Strings.average), Graphics.TEXT_JUSTIFY_CENTER);

    dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
    dc.drawText(x, y, Graphics.FONT_XTINY, WatchUi.loadResource($.Rez.Strings.pulse), Graphics.TEXT_JUSTIFY_CENTER);

    dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
    dc.drawText(x + 70, y, Graphics.FONT_XTINY, WatchUi.loadResource($.Rez.Strings.max), Graphics.TEXT_JUSTIFY_CENTER);

    y += smallFontH;

    dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
    dc.drawText(x - 70, y, Graphics.FONT_TINY, _averageHeartRate, Graphics.TEXT_JUSTIFY_CENTER);

    dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
    dc.drawText(x, y, Graphics.FONT_TINY, _currentHeartRate, Graphics.TEXT_JUSTIFY_CENTER);

    dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
    dc.drawText(x + 70, y, Graphics.FONT_TINY, _maxHeartRate, Graphics.TEXT_JUSTIFY_CENTER);

    y += bigFontH;

    dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
    dc.drawText(x , y, Graphics.FONT_TINY, _elapsedTime, Graphics.TEXT_JUSTIFY_CENTER);
  }

  // Called when this View is removed from the screen. Save the
  // state of this View here. This includes freeing resources from
  // memory.
  function onHide() as Void {
    Position.enableLocationEvents(Position.LOCATION_DISABLE, method(:onPosition));
    _timer.stop();
    _timer = null;
  }

  function onPosition(info as Toybox.Position.Info) {
    System.println("OnPosition");
  }

  function Stop() {
    isRun = false;
    if (Toybox has :ActivityRecording && isSessionRecording()) {
      if (_session != null) {
        _session.stop();
      }
    }
    WatchUi.requestUpdate();
  }

  function Continue() {
    isRun = true;
    if (Toybox has :ActivityRecording && !isSessionRecording()) {
      if (_session != null) {
        _session.start();
      }
    }
    WatchUi.requestUpdate();
  }

  function Save() {
    isRun = false;
    if (Toybox has :ActivityRecording && !isSessionRecording()) {
      if (_session != null) {
        _session.save();
        _session = null;
      }
    }
    WatchUi.popView(WatchUi.SLIDE_DOWN);
    WatchUi.requestUpdate();
  }

  function Remove() {
    isRun = false;
    if (Toybox has :ActivityRecording && !isSessionRecording()) {
      if (_session != null) {
        _session.discard();
        _session = null;
      }
    }
    WatchUi.popView(WatchUi.SLIDE_DOWN);
    WatchUi.requestUpdate();
  }
}
