/*
 * Zadget - the all-in-one mini flash gadget http://zadget.me
 * Copyright (C) 2008-2009 Zeng Ke
 * 
 * Licensed under to term of GNU General Public License Version 2 or Later (the "GPL")
 *   http://www.gnu.org/licenses/gpl.html
 *
 */
package me.zadget.common {
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.text.TextFieldAutoSize;
    import me.zadget.common.Util;

    public class Label extends TextField {
	public function Label(text:String="", color:Number=0) {
	    //Util.installShadow(this, 2);
	    this.autoSize = TextFieldAutoSize.CENTER;
	    this.text = text;
            var format:TextFormat = Label.getTextFormat(color);
	    this.setTextFormat(format);
	}
	public static function getTextFormat(color:Object):TextFormat {
	    var format:TextFormat = new TextFormat();
            format.font = 'Arial';
	    format.color = color;
	    format.size = 20;
	    return format;
	}

	public function updateTextFormat():void {
	    var tf:TextFormat = this.getTextFormat();
	    this.setTextFormat(Label.getTextFormat(tf.color));
	}
    }
}
