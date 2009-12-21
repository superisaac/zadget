/*
 * Zadget - the all-in-one mini flash gadget http://zadget.me
 * Copyright (C) 2008-2009 Zeng Ke
 * 
 * Licensed under to term of GNU General Public License Version 2 or Later (the "GPL")
 *   http://www.gnu.org/licenses/gpl.html
 *
 */

package me.zadget.common {
    import flash.display.MovieClip;
    public class Widget extends MovieClip {
	public function get className():String {
	    return 'widget';
	}

        public function get logicWidth():Number {
	    return 500;
	}
	public function get logicHeight():Number {
	    return 460;
	}
	public function fillStage():void {
	    scaleX = main.instance.stage.stageWidth / logicWidth;
	    scaleY = main.instance.stage.stageHeight / logicHeight;
	}
	
	public function scaleStage():void {
	    var kx:Number = main.instance.stage.stageWidth / logicWidth;
	    var ky:Number = main.instance.stage.stageHeight / logicHeight;
	    if(kx > ky) {
		scaleX = scaleY = ky;
		x = (main.instance.stage.stageWidth - logicWidth * scaleX) / 2;
	    } else {
		scaleX = scaleY = kx;
		y = (main.instance.stage.stageHeight - logicHeight* scaleY) / 2;
	    }
	}
	
	public function widgetRemoved():void {
	    
	}
	public function stageSizeChanged():void {
	    fillStage();
	}
	
    }
}
