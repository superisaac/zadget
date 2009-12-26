/*
 * Zadget - the all-in-one mini flash gadget http://zadget.me
 * Copyright (C) 2008-2009 Zeng Ke
 * 
 * Licensed under to term of GNU General Public License Version 2 or Later (the "GPL")
 *   http://www.gnu.org/licenses/gpl.html
 *
 */
package me.zadget.chart
{
    import flash.text.TextFormat;

    import me.zadget.common.Widget;
    import me.zadget.common.Label;
    import me.zadget.common.Util;

    public class Plot extends Widget {
	public const MARGIN_WIDTH:Number = 40;
	public const MARGIN_HEIGHT:Number = 60;

	public function get gridWidth():Number  {
	    return logicWidth - MARGIN_WIDTH * 2;
	}

	override public function get className():String {
	    return 'plot';
	}

	public function get gridHeight():Number {
	    return logicHeight - MARGIN_HEIGHT * 2;
	}

	private var max:Number = NaN;
	private var min:Number = NaN;
	private var max_size:int = 0;
	private var y_labels:Array = new Array();
	
	private var titleLabels:Array = new Array();

	public function Plot() {
	    createLabels();
	    //Util.installShadow(this);
	}

        public override function get logicWidth():Number {
	    //return main.instance.stage.stageWidth;
	    return 500;
	}

	public override function get logicHeight():Number {
	    //return main.instance.stage.stageHeight;
	    return 400;
	}

        public static function handleLines():void {
	    if(arguments.length < 1) {
		Log.error("No argument given!( 1 argument required)");
		return;
	    }
	    var data:Array = arguments[0] as Array;
	    var option:Object = arguments.length == 1? {}:arguments[1];
	    var plot:Plot;
	    if(main.instance.currentWidget is Plot) {
		plot = main.instance.currentWidget as Plot;
	    } else {
		plot = new Plot();
		main.instance.addWidget(plot);
		plot.drawGrids();
	    }
	    plot.drawLines(data, option);
	}

	private function drawGrids():void {
	    var x_grid:int = 5;
	    graphics.lineStyle(2, 0, 1.0, true, "normal"); 
	    graphics.moveTo(MARGIN_WIDTH, MARGIN_HEIGHT - 10);
	    graphics.lineTo(MARGIN_WIDTH, logicHeight - MARGIN_HEIGHT);
	    graphics.lineTo(logicWidth + 10 - MARGIN_WIDTH, logicHeight - MARGIN_HEIGHT);

	    var i:int;
	    var text:Label;
	    for(i = 0; i<= 4; i++) {
		graphics.moveTo(MARGIN_WIDTH - 5, logicHeight - MARGIN_HEIGHT - i * gridHeight / 4);
		graphics.lineTo(MARGIN_WIDTH, logicHeight - MARGIN_HEIGHT - i * gridHeight / 4);
	    }
	}

	private function createLabels():void {
	    var i:int;
	    var text:Label;
	    for(i = 0; i<= 4; i++) {
		text = new Label();
		text.y = logicHeight - MARGIN_HEIGHT - i * gridHeight / 4 - 18;
		addChild(text);
		y_labels.push(text);
	    }
	}

	private function updateLabels():void {
	    var i:int;
	    var text:Label;
	    var tcolor:Number = main.instance.getOption('labelColor', 0x000000) as Number;
	    var textFormat: TextFormat = Label.getTextFormat(tcolor);
	    var high:Number = bound.high as Number;
	    var low:Number = bound.low as Number;

	    for(i = 0; i<=4; i++) {
		text  = y_labels[i] as Label;
		text.text = '' + (high * i + low * (4 - i)) / 4;
		text.setTextFormat(textFormat);
		text.updateTextFormat();
		text.x = MARGIN_WIDTH - text.width - 3;
	    }
	}

	private function get bound():Object {
	    return Util.getBound(max, min);
	}

	private function get maxSize():Number {
	    return (max_size % 2) == 1? max_size + 1: max_size;
	}

	private function drawLines(data:Array, option:Object):void {
	    var l:LineClip = new LineClip(data, option);
	    l.x = MARGIN_WIDTH;
	    l.y = MARGIN_HEIGHT;

	    addChild(l);
	    if(isNaN(max) || l.maxValue > max) {
		max = l.maxValue;
	    }
	    if(isNaN(min) || l.minValue < min) {
		min = l.minValue;
	    }
	    var old_max_size:int = max_size;

	    if(l.processedData.length > max_size) {
		max_size = l.processedData.length;
	    }
	    updateLabels();

	    if(option.hasOwnProperty('title')) {
		var titleLabel:Label = new Label('-' + option.title, l.color);
		titleLabel.y = 10;
		if(titleLabels.length > 0){
		    var lastTitle:Label = titleLabels[titleLabels.length - 1] as Label;
		    titleLabel.x = lastTitle.x + lastTitle.width + 10;
		} else {
		    titleLabel.x = MARGIN_WIDTH + 40;
		}
		addChild(titleLabel);
		titleLabels.push(titleLabel);
	    }

	    for each(var labelObj:Object in l.labels) {
		    var textField:Label = labelObj.label as Label;
		    addChild(textField);
	    }
	    updataLineClips();
	}

	private function updataLineClips():void {
	    var j:int = 0;
	    for(var i:int = 0; i< numChildren; i++) {
		var clip:LineClip = getChildAt(i) as LineClip;
		if(clip) {
		    clip.scaleToGrid(j, gridWidth, gridHeight, 
				     bound.high, bound.low, 
				     maxSize);
		    if(clip.labels.length > 0) {
			j++;
		    }
		}
	    }
	}

	override public function stageSizeChanged():void {
	    fillStage();
	    updataLineClips();
	}
    }
}

import flash.display.Sprite;
import flash.display.LineScaleMode;
import me.zadget.common.Label;
import me.zadget.common.Pin;
import me.zadget.common.Util;
import me.zadget.chart.Plot;
import flash.events.*;

class LineClip extends Sprite {
    //    public var data:Array;
    public var minValue:Number = NaN;
    public var maxValue:Number = NaN;
    // private var option:Object;
    public var labels:Array = new Array();
    public var color:Number;
    public var processedData:Array = new Array();
    private var pinList:Array = new Array();
    public var use_dot:Boolean;

    private function processData(data:Array, option:Object):void {
	use_dot = Util.getOption(option, 'use_dot', true);
	var i:int;
	
	for(i=0; i< data.length; i++) {
	    var elem:Object = data[i];
	    var value:Number = NaN;
	    if(elem is Number) {
		value = elem as Number;
		processedData.push({value: elem});
	    } else if(elem.hasOwnProperty('value')) {
		processedData.push(elem);
		value = elem.value;
		if(elem.hasOwnProperty('label')) {
		    var subtitleColor:Number = option.subtitleColor;
		    if(isNaN(subtitleColor)) {
			subtitleColor = color;
		    }
		    var textField:Label = new Label(elem.label, subtitleColor);
		    labels.push({index: i, label: textField});
		}
	    }
	    if(isNaN(maxValue) || maxValue < value) {
		maxValue = value;
	    }
	    if(isNaN(minValue) || minValue > value) {
		minValue = value;
	    }

	    if(use_dot) {
		var dot:Pin = new Pin('[' + (i+1) + ']=' + value, color, true);
		dot.mouseOverScale = 1.5;
		addChild(dot);
		pinList.push(dot);
	    }
	}
    }

    public function LineClip(data:Array, option:Object) {
	color = option.color;
	if(option.hasOwnProperty('color')) {
	    color = option.color;
	} else {
	    color = Util.chooseColor;
	}
	processData(data, option);
	Util.installShadow(this, 3);
    }

    public function scaleToGrid(order:Number, gridWidth:Number, gridHeight:Number, 
				gridMax:Number, gridMin:Number, maxDataLen:int):void {
	var i:int;
	const cellWidth:Number = gridWidth / (maxDataLen - 1);
	const pinScaleX:Number = 1/ main.instance.currentWidget.scaleX;
	const pinScaleY:Number = 1/ main.instance.currentWidget.scaleY;

	graphics.clear();
	graphics.lineStyle(3, color);

	for(i =0; i< processedData.length; i++) {
	    var v:Number = processedData[i].value as Number;
	    var x:Number = i * cellWidth;
	    var y:Number = gridHeight * (gridMax - v)/(gridMax - gridMin);
	    if(i == 0) {
		graphics.moveTo(x, y);
	    } else {
		graphics.lineTo(x, y);
	    }
	    if(use_dot) {
		var pin:Pin = pinList[i] as Pin;
		pin.x = x;
		pin.y = y;
		pin.scaleX = pinScaleX;
		pin.scaleY = pinScaleY;
	    } 
	}

	for each(var labelObj:Object in labels) {
		var label:Label = labelObj.label as Label;
		label.x = cellWidth * labelObj.index + this.x - label.width/2;
		label.y = gridHeight + this.y + 6 + label.height * order;
	}
    }
}
