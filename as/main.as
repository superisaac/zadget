/*
 * Zadget - the all-in-one mini flash gadget http://zadget.me
 * Copyright (C) 2008-2009 Zeng Ke
 * 
 * Licensed under to term of GNU General Public License Version 2 or Later (the "GPL")
 *   http://www.gnu.org/licenses/gpl.html
 *
 */
package  {
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.display.StageScaleMode;
    import flash.display.Graphics;
    import flash.external.ExternalInterface;
    import flash.display.DisplayObject;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
    import flash.system.Security;

    import me.zadget.chart.Plot;
    import me.zadget.chart.Plot2D;
    import me.zadget.chart.Pie;
    import me.zadget.chart.TimeSerial;

    import me.zadget.media.MusicPlayer;
    import me.zadget.media.FlvPlayer;
    import me.zadget.media.Image;

    import me.zadget.doodle.Doodle;

    import me.zadget.common.Widget;
    import me.zadget.common.WidgetEvent;
    import me.zadget.common.Util;

    public class main extends MovieClip {
        private static var _instance:main;

	//private var backgroundPad:Sprite;
	private var _container:Sprite;
        public static function get instance():main {
            return _instance;
        }
        private var _currentWidget:Widget = null;
        public function get currentWidget():Widget {
            return _currentWidget;
        }

	private var _option:Object = {};
	public function getOption(key:String, value:Object):Object {
	    if(_option.hasOwnProperty(key)) {
		return _option[key];
	    }
	    return value;
	}
	private function setOption(option:Object):void {
	    _option = option;
	}
	
	private function createLogo():void {
	    var logoPad:Sprite = new Sprite();
	    var g:Graphics = logoPad.graphics;
	    g.beginFill(0xBBBBBB, 0.5);
	    g.drawRect(0, 0, 110, 32);
	    g.endFill();
	    addChild(logoPad);
	    logoPad.x = stage.stageWidth - logoPad.width;
	    logoPad.y = stage.stageHeight - logoPad.height;
	    
	    var tf:TextField = new TextField();
	    var format:TextFormat = new TextFormat();
	    format.font = 'Comic';
	    format.size = 16;
	    format.color = '0x002266';

	    tf.htmlText = '<a target="_blank" href="http://zadget.me">' +
		'<font color="blue">Z</font>' + 
		'ADGET' + '.ME</a>';
	    tf.autoSize = 'center';
	    logoPad.addChild(tf);
	    tf.setTextFormat(format);
	    tf.x = (logoPad.width - tf.width)/2;
	    tf.y = (logoPad.height - tf.height)/2;
	}

	private var _tooltip:TextField;
	private function createTooltip():void {
	    _tooltip = new TextField();
	    //Util.installShadow(_tooltip);
	    _tooltip.border = true;
	    _tooltip.autoSize =  TextFieldAutoSize.CENTER;
	    _tooltip.visible = false;
	    //_tooltip.text = 'AAA';
	    //_tooltip.setTextFormat(format);
	    addChild(_tooltip);
	}
	private var format:TextFormat = null;
	public function showTooltip(msg:String):void {
	    if(format == null) {
		format = new TextFormat();
		format.size = 20;
	    }
	    _tooltip.text = msg;
	    _tooltip.setTextFormat(format);
	    _tooltip.x = mouseX + 10;
	    _tooltip.background = true;
	    //_tooltip.backgroundColor = 0xffffff;
	    if(_tooltip.x + _tooltip.width >= stage.stageWidth) {
		_tooltip.x -= _tooltip.width - 20;
	    }

	    if(_tooltip.y + _tooltip.height >= stage.stageHeight) {
		_tooltip.y -= _tooltip.height - 20;
	    }
	    _tooltip.y = mouseY + 10;
	    _tooltip.visible = true;
	}

	public function hideTooltip():void {
	    _tooltip.text = ' ';
	    _tooltip.visible = false;
	}


	static public function dtrace(msg:Object): void {
	    ExternalInterface.call("flash_dtrace", String(msg));
	}
        
        public function registerCallbacks():void {
	    CONFIG::use_plot {
		ExternalInterface.addCallback('lines', Plot.handleLines);
		ExternalInterface.addCallback('plot2d', Plot2D.handlePlot2D);
		ExternalInterface.addCallback('pie', Pie.handlePie);
		ExternalInterface.addCallback('serial', TimeSerial.handleNew);
	    }

	    CONFIG::use_media {
		ExternalInterface.addCallback('playMusic', MusicPlayer.handlePlay);
		ExternalInterface.addCallback('playFLV', FlvPlayer.handlePlay);
		ExternalInterface.addCallback('image', Image.handleImage);
	    }

	    CONFIG::use_doodle {
		ExternalInterface.addCallback('doodle', Doodle.handleDoodle);
	    }

	    ExternalInterface.addCallback('post', postEvent);
            ExternalInterface.addCallback('setOption', setOption);
            ExternalInterface.addCallback('checkin', checkin);
	    ExternalInterface.addCallback('clear', clearWidget);
        }

	/*public function handleStop():void {
	    if(currentWidget) {
		currentWidget.stopPlay();
	    }
	    }*/

	public function postEvent(type:String, data:Object=null):void {
	    if(currentWidget) {
		var event:WidgetEvent = new WidgetEvent(type);
		event.data = data;
		currentWidget.dispatchEvent(event);
	    }	    
	}

	/*public function handleSetVolume(v:Number):void {
	    if(currentWidget) {
		currentWidget.setVolume(v);
	    }
	    }*/

	public function clearWidget():void {
	    if(_currentWidget) {
		_currentWidget.widgetRemoved();
		_container.removeChild(_currentWidget);
	    }
	    _currentWidget = null;
	}

        public function addWidget(widget:Widget):DisplayObject {
            if(_currentWidget) {
		main.trigger('quit');
		_currentWidget.widgetRemoved();
                _container.removeChild(_currentWidget);
            }

	    Util.resetColorIndex();
            _currentWidget = widget;
	    main.trigger('start');
	    widget.stageSizeChanged();
            return _container.addChild(widget);
        }

	private function stageSizeChanged(event:Event=null):void {
	    if(_currentWidget) {
		_currentWidget.stageSizeChanged();
		_tooltip.scaleX = _currentWidget.scaleX;
		_tooltip.scaleY = _currentWidget.scaleY;
	    }
	}

        private var _source:String = '';
        private function checkin(source:String=''):String {
            _source = source;
            return 'ok';
        }

	public static function trigger(sort:String, data:Object=null):void {
	    var event:Object = new Object();
	    event.source = Util.getOption(instance.loaderInfo.parameters, 
					  'source', main.instance._source);
	    event.sort = sort;
	    event.data = data;
	    if(instance.currentWidget) {
		event.widget = instance.currentWidget.className;
	    }
	    ExternalInterface.call('dispatchEvent', event);
	}
	
	public function main() {
	    Security.allowDomain('*');
	    stage.align = 'tl';
            stage.scaleMode = StageScaleMode.NO_SCALE;


	    stage.addEventListener('resize', stageSizeChanged);
            _instance = this;
	    _container = new Sprite();
	    addChild(_container);
	    createTooltip();
	    createLogo();
            registerCallbacks();
	}
    }
}
