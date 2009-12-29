package me.zadget.doodle {
    import me.zadget.common.Widget;
    import me.zadget.common.WidgetEvent;
    import flash.display.Sprite;

    public class Doodle extends Widget {
	private var palatte:Palatte;
	public var canvas:Canvas;
	public var option:Object = null;
	public function Doodle(option:Object=null) {
	    this.option = option;
	    palatte = new Palatte();
	    palatte.x = 5;
	    palatte.y = 0;
	    addChild(palatte);

	    canvas = new Canvas(option);
	    canvas.x = 80;
	    canvas.y = 10;
	    addChild(canvas);
	    palatte.addEventListener('chooseColor', canvas.onColorChoose);
	    addEventListener('widget.stroke', addStroke);
	    addEventListener('widget.popstroke', popStroke);
	}

	override public function get className():String {
	    return 'doodle';
	}

	override public function get logicHeight():Number {
	    return 380;
	}
	override public function get logicWidth():Number {
	    return 450;
	}

	public static function handleDoodle(option:Object=null):void {
	    var doodle:Doodle = new Doodle(option);
	    main.instance.addWidget(doodle);
	}

	public function popStroke(event:WidgetEvent):void {
	    canvas.popStroke();
	}

	public function addStroke(event:WidgetEvent):void {
	    var color:Number = event.data.color as Number;
	    var points:Array = event.data.points;
	    canvas.addStroke(color, points);
	}

	override public function stageSizeChanged():void {
	    scaleStage();
	}
    }
}

import flash.display.Sprite;
import flash.display.Graphics;
import flash.events.*;
import flash.geom.Point;
import me.zadget.common.Util;

class StrokeSprite extends Sprite
{
    public var points:Array;
    private var counter:int = 0;
    public var color:Number = 0;
    private var canvas:Canvas;

    public function StrokeSprite(canvas:Canvas){
	super();
	this.canvas = canvas;
	color = canvas.currentColor;
    }

    public function moveTo(x:Number, y:Number):void {
	graphics.lineStyle(2, color);
	graphics.moveTo(x, y);

	counter = 0;

	points = new Array();
	points.push(new Point(x, y));
    }

    public function draw(x:Number, y:Number):void {
	counter++;
	if(counter & 0x1 == 1){
	    graphics.lineTo(x, y);
	    points.push(new Point(x, y));
	}
    }

    public function redrawAll():void {
	var i:int;
	var p:Point = points[0] as Point;
	graphics.clear();
	graphics.lineStyle(2, color);
	graphics.moveTo(p.x, p.y);
	counter = 0;
	for(i=1; i< points.length; i++) {
	    p = points[i] as Point;
	    graphics.lineTo(p.x, p.y);
	}
    }

    public function sendEvent(sort:String='doodle.stroke'):void {
	var obj:Object = new Object();
	var newpoints:Array = new Array();
	for each(var point:Point in points) {
		newpoints.push({x: point.x, y: point.y});
	}
	obj.points = newpoints;
	obj.color = color;
	main.trigger(sort, obj);
    }
}

class Canvas extends Sprite
{
    public var currentColor:Number = 0;
    public static const size:Number = 360;
    private var strokes:Array;
    private var currentStroke: StrokeSprite;
    private var option:Object = null;

    public function Canvas(option:Object=null) {
	this.option = option;
	strokes = new Array();
	addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
	addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
	addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
	addEventListener(MouseEvent.ROLL_OUT, onRollout);

	graphics.beginFill(Util.getOption(option, 'canvasColor',
					  0xffffff) as Number);
	graphics.lineStyle(1, 0);
	graphics.drawRect(0, 0, size, size);
	graphics.endFill();
	Util.installShadow(this);
    }

    public function onColorChoose(event:ColorEvent):void {
	currentColor = event.color;
    }

    public function popStroke():void {
	var stroke:StrokeSprite = strokes.pop() as StrokeSprite;
	if(stroke) {
	    removeChild(stroke);
	    stroke.sendEvent('doodle.pop');
	}
    }

    public function addStroke(color:Number, points:Array):void {
	var newpoints:Array = new Array();
	for each(var p:Object in points) {
	    if(p.x > size || p.x < 0 || p.y > size || p.y < 0) {
		continue;
	    }
	    newpoints.push(new Point(p.x, p.y));
	}
	var stroke:StrokeSprite = new StrokeSprite(this);
	stroke.points = newpoints;
	stroke.color = color;
	addChild(stroke);
	strokes.push(stroke);
	stroke.redrawAll();
    }

    public function onMouseDown(ev:MouseEvent):void {
	currentStroke = new StrokeSprite(this);
	currentStroke.moveTo(ev.localX, ev.localY);
	addChild(currentStroke);
    }

    public function onMouseUp(ev:MouseEvent):void {
	if(currentStroke != null){
	    strokes.push(currentStroke);
	    currentStroke.sendEvent();
	    currentStroke = null;
	}
    }

    public function onRollout(ev:MouseEvent):void {
	onMouseUp(ev);
    }

    public function onMouseMove(ev:MouseEvent):void {
	if(currentStroke != null){
	    currentStroke.draw(ev.localX, ev.localY);
	}
    }
}


class Palatte extends Sprite
{
    private var currentColor:Sprite;
    public function Palatte() {
	var i:int;
	var row:int;
	var col:int;
	var colors:Array = Util.colorTable;
	for(i=0; i<colors.length; i++) {
	    row = Math.floor(i / 3);
	    col = i % 3;
	    var color:Number = colors[i] as Number;
	    var cell:ColorCell = new ColorCell();
	    cell.color = color;
	    cell.buttonMode = true;
	    cell.x = col * ColorCell.CELL_SZ;
	    cell.y = 10 + row * ColorCell.CELL_SZ;
	    addChild(cell);
	    cell.draw();
	    cell.addEventListener(MouseEvent.CLICK,  onColorChoose);
	}
	currentColor = new Sprite();
	currentColor.x = 0;
	currentColor.y = 44 + row * ColorCell.CELL_SZ;
	addChild(currentColor);
	drawCurrentColor(0);
	Util.installShadow(this);
    }
    private function drawCurrentColor(color:Number):void {
	var g:Graphics = currentColor.graphics;
	g.clear();
	g.beginFill(color);
	g.drawRect(0, 0, ColorCell.CELL_SZ * 2, ColorCell.CELL_SZ * 2);
	g.endFill();
    }

    private function onColorChoose(event:MouseEvent):void {
	var cell:ColorCell = event.currentTarget as ColorCell;
	var colorEvent:ColorEvent = new ColorEvent();
	colorEvent.color = cell.color;
	dispatchEvent(colorEvent);
	cell.draw();
	drawCurrentColor(cell.color);
    }
}

class ColorCell extends Sprite
{
    public static const CELL_SZ:Number = 20;
    public var color:Number;
    public function draw():void {
	var g:Graphics = graphics;
	g.clear();
	g.beginFill(color);
	g.drawRect(0, 0, CELL_SZ, CELL_SZ);
	g.endFill();
    }
}

class ColorEvent extends Event
{
    public var color:Number;
    public function ColorEvent() {
	super('chooseColor');
    }
}
