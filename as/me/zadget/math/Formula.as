package me.zadget.math {
    import me.zadget.common.Widget;
    import flash.display.Sprite;

    public class Formula extends Widget {
	public static function handleForumla(expr:Object):void {
	    var formula:Formula = new Formula(expr);
	    main.instance.addWidget(formula);
	}

	private var expr:Object;
	private var baseSize:Number;

	override public function get logicHeight():Number {
	    return this.height;
	}
	override public function get logicWidth():Number {
	    return this.width;
	}
	override public function stageSizeChanged():void {
	    //scaleStage();
	}
	public function Formula(expr:Object) {
	    this.expr = expr;
	    var root:Glyph = new Glyph();
	    root.baseSize = 100;
	    addChild(root);
	    root.drawExpr(expr);
	}
    }
}

import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFormat;
import me.zadget.common.Util;

class Glyph extends Sprite
{
    public var baseSize:Number = 100;

    public function get textFormat():TextFormat {
	var format:TextFormat = new TextFormat();
	format.font = Util.labelFont;
	format.size = baseSize;
	return format;
    }

    public function newText(text:String):TextField {
	var tf:TextField = new TextField();
	tf.text = text;
	tf.setTextFormat(textFormat);
	addChild(tf);
	tf.autoSize = 'center';
	tf.setTextFormat(textFormat);

	return tf;
    }

    public function drawExpr(expr:Object):Sprite {
	if(expr is Number || expr is String) {
	    newText(String(expr));
	    return this;
	} else if(expr.opcode == '+' ||
		  expr.opcode == '-') {
	    return drawBinOp(expr.opcode, expr.left, expr.right);
	}
	return null;
    }
    
    public function drawBinOp(opcode:String, left:Object, right:Object):Sprite {
	var maxHeight:Number = 0;

	var leftObj:Glyph = new Glyph();
	leftObj.baseSize = baseSize;
	addChild(leftObj);
	leftObj.drawExpr(left);
	if(maxHeight < leftObj.height) {
	    maxHeight = leftObj.height;
	}

	var tf:TextField = newText(opcode);
	if(maxHeight < tf.height) {
	    maxHeight = tf.height;
	}
	tf.x = leftObj.x + leftObj.width + 2;

	var rightObj:Glyph = new Glyph();
	rightObj.baseSize = baseSize;
	addChild(rightObj);
	rightObj.drawExpr(right);
	if(maxHeight < rightObj.height) {
	    maxHeight = rightObj.height;
	}
	rightObj.x = tf.x + tf.width + 2;

	leftObj.y = (maxHeight - leftObj.height)/2;
	tf.y = (maxHeight - tf.height)/2;
	rightObj.y = (maxHeight - rightObj.height)/2;
	return this;
    }
}