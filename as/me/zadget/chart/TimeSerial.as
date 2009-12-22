/*
 * Zadget - the all-in-one mini flash gadget http://zadget.me
 * Copyright (C) 2008-2009 Zeng Ke
 * 
 * Licensed under to term of GNU General Public License Version 2 or Later (the "GPL")
 *   http://www.gnu.org/licenses/gpl.html
 *
 */
package me.zadget.chart {
    import me.zadget.common.Widget;
    import me.zadget.common.WidgetEvent;
    import me.zadget.common.Util;
    import me.zadget.common.Label;

    import flash.utils.Timer;
    import flash.events.*;

    public class TimeSerial extends Widget {
	private var repo:Object = new Object();
	private var capacity:int = 120;  
	private var _timer:Timer;
	public static const MARGIN_X:int = 45;
	public static const MARGIN_Y:int = 20;

	override public function get className():String {
	    return 'timeserial';
	}

	public var maxPer:Number = 0.01;
	public function get high():Number {
	    var degree:Number = Math.pow(10, Math.floor(Math.log(maxPer)/Math.log(10)));
	    return Math.ceil(maxPer / degree ) * degree;
	}

	public static function handleNew(interval:Number, capacity:int, streams:Array):void {
	    var ts:TimeSerial = new TimeSerial(interval);
	    ts.capacity = capacity;
	    main.instance.addWidget(ts);
	    ts.setStreams(streams);
	    ts.startSerial();
	}

	public function TimeSerial(interval:Number) {
	    _timer = new Timer(interval);
	    _timer.addEventListener('timer', onTimer);
	    drawGrid();
	    createLabels();
	    addEventListener('widget.value', setValue);
	}
	
	private var labelList:Array = new Array();
	public function createLabels():void {
	    var i:int = 0;
	    for(i= -2; i<= 2; i++) {
		var v:Label = new Label(" ");
		v.autoSize = 'right';
		addChild(v);
		labelList.push(v);
	    }
	}

	public function updateLabels():void {
	    var c:Number = high / 2;
	    var i:int;
	    var j:int = 0;
	    for(i= -2; i<=2; i++, j++) {
		var v:Label = labelList[j] as Label;
		var pv:Number = Math.round(-c*i*10000) / 100;
		v.text = '' + pv + '%';
		v.updateTextFormat();
		v.x = MARGIN_X - v.width - 2;
		v.y = (logicHeight - MARGIN_Y * 2) * (2 + i)/ 4 + MARGIN_Y - v.height/2 ;
	    }
	    
	}

	private function startSerial():void {
	    _timer.stop();
	    _timer.start();
	}

	override public function widgetRemoved():void {
	    _timer.stop();
	}

	private function setValue(event:WidgetEvent):void {
	    var label:String = event.data.label as String;
	    var value:Number = event.data.value as Number;
	    if(repo.hasOwnProperty(label)) {
		var serial:Serial = repo[label] as Serial;
		serial.value = value;
	    }
	}
	
	private function setStreams(streams:Array):void {
	    for each(var stream:Object in streams) {
		    var serial:Serial = new Serial(stream.label, stream.initial);
		    serial.timeSerial = this;
		    serial.color = Util.getOption(stream, 'color', 0x222222) as Number;

		    addChild(serial);
		    serial.y = logicHeight / 2;
		    serial.x = MARGIN_X;
		    repo[stream.label] = serial;

	    }
	}

	private function drawGrid():void {
	    graphics.lineStyle(1, 0x555555);
	    graphics.moveTo(MARGIN_X, MARGIN_Y);
	    graphics.lineTo(MARGIN_X, logicHeight - MARGIN_Y);

	    graphics.moveTo(MARGIN_X, logicHeight / 2);
	    graphics.lineTo(logicWidth - MARGIN_X, logicHeight / 2);

	}

	private function onTimer(event:TimerEvent):void {
	    for(var label:String in repo) {
		var serial:Serial = repo[label] as Serial;
		if(serial) {
		    serial.draw(capacity);
		}
	    }
	}
    }
}

import flash.display.Sprite;
import me.zadget.chart.TimeSerial;
import me.zadget.common.Util;

class Serial extends Sprite
{
    private var data:Array;
    private var initial:Number;
    private var _currentValue:Number;
    public var timeSerial:TimeSerial;
    public var color:Number = 0;
    public var label:String;

    public function Serial(label: String, initial:Number) {
	this.label = label;
	data = new Array();
	this.initial = initial;
	_currentValue = initial;
	Util.installShadow(this);
	data.push(0.0);
    }
    public function set value(v:Number):void {
	_currentValue = v;
    }

    public function draw(capacity:int):void {
	var maxChanged:Boolean = false;
	if(data.length >= capacity) {
	    var d:Number = data.shift() as Number;
	    if(Math.abs(d) >= timeSerial.maxPer) {
		maxChanged = true;
	    }
	}
	var rate:Number = (_currentValue / initial - 1);
	if(Math.abs(rate) >= timeSerial.maxPer) {
	    maxChanged = true;
	}
	data.push(rate);
	var tx:Number = timeSerial.logicWidth - TimeSerial.MARGIN_X * 2;
	const c:Number = tx / (capacity - 1);

	if(maxChanged) {
	    var upBound:Number = 0.05;
	    var i:int = 0;
	    var r:Number;
	    for(; i < data.length; i++) {
		r = data[i] as Number;
		if(Math.abs(r) > upBound) {
		    upBound = Math.abs(r);
		}
	    }
	    timeSerial.maxPer = upBound;
	    timeSerial.updateLabels();
	}
	const localHigh:Number = timeSerial.high;
	const h:Number = (timeSerial.logicHeight - 2 * TimeSerial.MARGIN_Y) / (2 * localHigh);
	
	graphics.clear();
	graphics.lineStyle(2, color);
	var firstData:Number = data[data.length - 1];
	graphics.moveTo(tx, -h * firstData);
	i = data.length - 2;
	for(; i>= 0; i--) {
	    tx -= c;
	    r = data[i] as Number;
	    graphics.lineTo(tx, -h * r);
	}
	tx -= c;
	main.trigger('timeserial.value', {label: label, 
		    initial: initial, 
		    value: _currentValue});
    }
}
