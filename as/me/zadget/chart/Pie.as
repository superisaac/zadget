/*
 * Zadget - the all-in-one mini flash gadget http://zadget.me
 * Copyright (C) 2008-2009 Zeng Ke
 * 
 * Licensed under to term of GNU General Public License Version 2 or Later (the "GPL")
 *   http://www.gnu.org/licenses/gpl.html
 *
 */
package me.zadget.chart {
    import flash.text.TextFormat;
    import flash.display.Graphics;
    import flash.display.Sprite;

    import me.zadget.common.Widget;
    import me.zadget.common.Label;
    import me.zadget.common.Util;

    public class Pie extends Widget {
	private var data:Array = new Array();
	private var option:Object = new Object();
	private const PIE_SIZE:Number = 450;
	private var maxLabelRight:Number = PIE_SIZE;

	public function Pie() {

	}

	public static function handlePie(data:Array, option:Object=null):void {
	    var pie:Pie;
	    pie = new Pie();
	    main.instance.addWidget(pie);
	    pie.process(data, option);
	    pie.draw();
	}

        public override function get logicWidth():Number {
	    return maxLabelRight + 20;
	}

	public override function get logicHeight():Number {
	    return PIE_SIZE;
	}

	override public function stageSizeChanged():void {
	    scaleStage();
	}

	private function process(data:Array, option:Object):void {
	    this.option = option;
	    var sum:Number = 0;
	    var elem:Object;
	    var i:int;
	    for(i=0; i< data.length; i++) {
		elem = data[i];
		sum += elem.value;
	    }
	    this.data = new Array();
	    for(i=0; i< data.length; i++) {
		elem = data[i];
		this.data.push({value: elem.value,
			    percent: elem.value / sum,
			    label: elem.label});
	    }
	}

	private function drawLabelAndLink(i:Number,
					  color:Number,
					  label:String):void {

	    const labelY:Number = PIE_SIZE * (0.5 - 1/2.4) + i * 24;
	    var g:Graphics = this.graphics;
	    g.beginFill(color);
	    g.drawRect(PIE_SIZE, labelY + 8, 10, 10);
	    g.endFill();

	    var tf:Label = new Label(label, color);
	    tf.x = PIE_SIZE  + 16;
	    tf.y = labelY;
	    addChild(tf);

	    if(maxLabelRight < tf.x + tf.width) {
		maxLabelRight = tf.x + tf.width;
	    }
	}
	
	private function draw():void {
	    const radius:Number = PIE_SIZE / 2.4;
	    const centerX:Number = PIE_SIZE / 2;
	    const centerY:Number = PIE_SIZE / 2;
	    var start_angle:Number = 0;
	    var angle:Number;
	    var i:int = 0;
	    var pad:Sprite = new Sprite();
	    Util.installShadow(pad);
	    addChild(pad);
	    pad.x = centerX;
	    pad.y = centerY;
	    var g:Graphics = pad.graphics;
	    g.beginFill(0xffffff);
	    g.drawCircle(0, 0, radius);
	    g.endFill();

	    var use_3d:Boolean = Util.getOption(option, 'use_3d', false) as Boolean;
	    for(i = 0; i< data.length; i++) {
		var elem:Object = data[i];
		angle = Math.PI * 2 * elem.percent;
		var text:String = elem.label + ': ' + (Math.round(elem.percent * 10000) / 100) + '%';
		var fillColor:Number = Util.chooseColor;
		var fan:Fan = new Fan(radius, start_angle, angle, 
				      fillColor, text, use_3d);
		drawLabelAndLink(i, fillColor, elem.label);
		fan.x = centerX;
		fan.y = centerY;
		addChild(fan);
		start_angle += angle;
	    }
	}
    }
}

import flash.display.Graphics;
import flash.display.GradientType;
import flash.geom.Matrix;
import flash.events.*;

import me.zadget.common.Pin;
import me.zadget.common.Util;

class Fan extends Pin {
    private var estart_angle:Number;
    private var angle:Number;
    private var radius:Number;
    private var use_3d:Boolean;

    public function Fan(radius:Number, start_angle:Number, angle:Number, color:Number, tooltipText:String='', use_3d:Boolean=true) {
	this.estart_angle = start_angle;
	this.angle = angle;
	this.radius = radius;
	this.use_3d = use_3d;
	super(tooltipText, color);
    }

    override public function draw():void {
	var g:Graphics = this.graphics;
	if(use_3d) {
	    var colors:Array = [color, color + 0x010101];
	    var alphas:Array = [1, 1];
	    var ratios:Array = [0x0, 0xff];
	    var spreadMethod:String = 'reflect';
	    var fillType:String = GradientType.RADIAL;
	    var interpolationMethod:String = "linearRGB";
	    var focalPointRatio:Number = 0.0;
	    
	    var mat:Matrix = new Matrix();
	    mat.createGradientBox(radius + radius, radius + radius,
				  (45/180) * Math.PI,
				  -radius, -radius);
	    
	    g..beginGradientFill(fillType, colors, alphas, ratios, 
				 mat, spreadMethod, interpolationMethod, 
				 focalPointRatio);
	} else {
	    g.beginFill(color);
	}

	var start_angle:Number = this.estart_angle;

	g.moveTo(0, 0);
	g.lineTo(radius * Math.cos(start_angle), 
		 radius * Math.sin(start_angle));
	var araidus:Number;
	while(angle > Math.PI/4) {
	    var a:Number = Math.PI /4;
	    araidus = radius / Math.cos(a/2);
	    g.curveTo(araidus * Math.cos(start_angle + a/2),
		      araidus * Math.sin(start_angle + a/2),
		      radius * Math.cos(start_angle + a), 
		      radius * Math.sin(start_angle + a));
	    start_angle += a;
	    angle -= a;
	} 
	araidus = radius/ Math.cos(angle/2);
	g.curveTo(araidus * Math.cos(start_angle + angle/2),
		  araidus * Math.sin(start_angle + angle/2),
		  radius * Math.cos(start_angle + angle),
		  radius * Math.sin(start_angle + angle));
	
	g.lineTo(0, 0);
	g.endFill();
    }

    override protected function onMouseOut(event:MouseEvent):void {
	super.onMouseOut(event);
	this.alpha = 1;

    }

    override protected  function onMouseOver(event:MouseEvent):void {
	this.alpha = 0.7;
	super.onMouseOver(event);

    }
}
