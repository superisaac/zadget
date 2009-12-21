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
    import me.zadget.common.Label;
    import me.zadget.common.Util;
    import flash.text.TextFormat;
    import flash.display.Graphics;
    import flash.display.Sprite;

    public class Plot2D extends Widget {
	private const LOGIC_WIDTH:Number = 500;
	private const LOGIC_HEIGHT:Number = 500;
	private const MARGIN_WIDTH:Number = 60;
	private const MARGIN_HEIGHT:Number = 60;
	private const GRID_WIDTH:Number = (LOGIC_WIDTH - MARGIN_WIDTH * 2);
	private const GRID_HEIGHT:Number = (LOGIC_HEIGHT - MARGIN_HEIGHT * 2);

	public var xmin:Number = NaN;
	public var xmax:Number = NaN;

	public var ymin:Number = NaN;
	public var ymax:Number = NaN;
	private var y_labels:Array = new Array();
	private var x_labels:Array = new Array();
	private var titleLabels:Array = new Array();
	private var grid:Sprite;

	override public function get className():String {
	    return 'plot2d';
	}

        public override function get logicWidth():Number {
	    return LOGIC_WIDTH;
	}
	public override function get logicHeight():Number {
	    return LOGIC_HEIGHT;
	}

	private function get xBound():Object {
	    return Util.getBound(xmax, xmin);
	}

	private function get yBound():Object {
	    return Util.getBound(ymax, ymin);
	}

	public function Plot2D() {
	    grid = new Sprite();
	    addChild(grid);
	    grid.x = MARGIN_WIDTH;
	    grid.y = MARGIN_HEIGHT;
	    Util.installShadow(grid);
	    createLabels();
	}

	public function drawGrids():void {
	    var g:Graphics = grid.graphics;
	    g.beginFill(0xffffff, 1);
	    g.lineStyle(2, 0);
	    g.moveTo(0, 0);
	    g.lineTo(0, GRID_HEIGHT);
	    g.lineTo(GRID_WIDTH, GRID_HEIGHT);
	    g.lineTo(GRID_WIDTH, 0);
	    g.lineTo(0, 0);
	    g.endFill();
	}
	private  function createLabels():void {
	    var i:int ;
	    var text:Label;
	    for(i = 0; i<=2; i++) {
		text = new Label();
		text.y = logicHeight - MARGIN_HEIGHT - i * GRID_HEIGHT / 2 - 18;
		addChild(text);
		y_labels.push(text);
	    }

	    for(i = 0; i<=2; i++) {
		text = new Label();
		text.x = logicWidth - MARGIN_WIDTH - i * GRID_WIDTH / 2;
		text.y = logicHeight - MARGIN_HEIGHT + 2;
		addChild(text);
		x_labels.push(text);
	    }
	}

	private function updateLabels():void {
	    var i:int;
	    var text:Label;
	    var tcolor:Number = main.instance.getOption('labelColor', 0x000000) as Number;
	    var textFormat: TextFormat = Label.getTextFormat(tcolor);
	    var xbound:Object = xBound;
	    var ybound:Object = yBound;

	    for(i = 0; i<= 2; i++) {
		text = y_labels[i] as Label;
		text.text = '' + (ybound.high * i + ybound.low * (2 - i)) / 2;
		text.setTextFormat(textFormat);
		text.x = MARGIN_WIDTH - text.width - 3;
	    }
	    for(i = 0; i<= 2; i++) {
		text = x_labels[i] as Label;
		text.text = '' + (xbound.low * i + xbound.high * (2 - i)) / 2;
		text.setTextFormat(textFormat);
		//text.x = MARGIN_WIDTH - text.width - 3;
		text.x = logicWidth - MARGIN_WIDTH - i * GRID_WIDTH / 2 - text.width / 2;
	    }
	}

	public static function handlePlot2D(xdata:Array, ydata:Array, option:Object=null):void {
	    var plot:Plot2D;
	    if(main.instance.currentWidget is Plot2D) {
		plot = main.instance.currentWidget as Plot2D;
	    } else {
		plot = new Plot2D();
		main.instance.addWidget(plot);
		plot.drawGrids();
	    }
	    plot.draw2D(xdata, ydata, option);
	}

	public function draw2D(xdata:Array, ydata:Array, option:Object):void {
	    var clip:Plot2DClip = new Plot2DClip(xdata, ydata, option);
	    addChild(clip);
	    clip.x = MARGIN_WIDTH;
	    clip.y = MARGIN_HEIGHT;

	    if(isNaN(xmax) || clip.xmax > xmax) {
		xmax = clip.xmax;
	    } 
	    if(isNaN(xmin) || clip.xmin < xmin) {
		xmin = clip.xmin;
	    }

	    if(isNaN(ymax) || clip.ymax > ymax) {
		ymax = clip.ymax;
	    } 
	    if(isNaN(ymin) || clip.ymin < ymin) {
		ymin = clip.ymin;
	    }

	    updateLabels();
	    if(option.hasOwnProperty('title')) {
		var titleLabel:Label = new Label('-' + option.title, clip.color);
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

	    var xbound:Object = xBound;
	    var ybound:Object = yBound;

	    for(var i:int = 0; i< numChildren; i++) {
		clip = getChildAt(i) as Plot2DClip;
		if(clip) {
		    clip.scaleToGrid(GRID_WIDTH, GRID_HEIGHT,
				     xbound.high, xbound.low, ybound.high, ybound.low);
		}
	    }
	}
    }
}

import flash.display.Sprite;
import me.zadget.common.Pin;
import me.zadget.common.Util;

class Plot2DClip extends Sprite {
    public var color:Number;
    public var xmin:Number;
    public var xmax:Number;

    public var ymin:Number;
    public var ymax:Number;

    private var xdata:Array;
    private var ydata:Array;
    private var pinList:Array;

    public function Plot2DClip(xdata:Array, ydata:Array, option:Object) {
	color = option.color;
	if(option.hasOwnProperty('color')) {
	    color = option.color;
	} else {
	    color = Util.chooseColor;
	}
	this.xdata = xdata;
	this.ydata = ydata;
	pinList = new Array;
	processData();
    }

    private function getMinDataLength():int {
	return Math.min(xdata.length, ydata.length);
    }

    private function processData():void {
	xmin = xmax = xdata[0] as Number;
	ymin = ymax = ydata[0] as Number;
	var xval:Number;
	var yval:Number;
	var i:int;
	var minLength:int = getMinDataLength();
	for(i = 0; i< minLength; i++) {
	    xval = xdata[i] as Number;
	    yval = ydata[i] as Number;
	    if(xval > xmax) xmax = xval;
	    else if(xval < xmin) xmin = xval;

	    if(yval > ymax) ymax = yval;
	    else if(yval < ymin) ymin = yval;
	    var dot:Dot = new Dot('' + xval + ', ' + yval, color);
	    addChild(dot);
	    pinList.push(dot);
	}
    }
    
    public function scaleToGrid(gridWidth:Number, gridHeight:Number,
				gridMaxX:Number, gridMinX:Number, 
				gridMaxY:Number, gridMinY:Number):void {
	var i:int = 0;
	const pinScaleX:Number = 1/ main.instance.currentWidget.scaleX;
	const pinScaleY:Number = 1/ main.instance.currentWidget.scaleY;

	var minLength:int = getMinDataLength();
	for(i = 0; i< minLength; i++) {
	    var xval:Number = xdata[i] as Number;
	    var yval:Number = ydata[i] as Number;
	    var dot:Pin = pinList[i] as Pin;
	    dot.x = gridWidth * (xval - gridMinX)/(gridMaxX - gridMinX) ;
	    dot.y = gridHeight * (gridMaxY - yval)/(gridMaxY - gridMinY);
	    dot.scaleX = pinScaleX;
	    dot.scaleY = pinScaleY;
	}
    }
}

class Dot extends Pin {
    public function Dot(tooltipText:String, color:Number=0) {
	super(tooltipText, color, true);
	Util.installShadow(this, 3);
    }

    override public function draw():void {
	graphics.beginFill(color, 1);
	graphics.drawRect(-4, -4, 8, 8);
	graphics.endFill();
    }
}