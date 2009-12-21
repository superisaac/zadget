package me.zadget.common {
    import flash.display.Sprite;
    import flash.display.Graphics;
    import me.zadget.common.Util;

    public class ProgressBar extends Sprite {
	public var _progress:Number = 0;
	public var color:Number = 0x0000ff;
	public var backgroundColor:Number = 0xAAAAAA;
	public function ProgressBar() {
	    draw(0);
	}
	public function set progress(v:Number):void {
	    if(v > 1.0) v = 1.0;
	    else if(v < 0) v = 0;
	    var t:int = Math.round(v * 10);
	    if(t != Math.round(_progress * 10)) {
		draw(t);
	    }
	    _progress = t;
	}

	public function get progress():Number {
	    return _progress;
	}
	
	override public function get height():Number {
	    return 40;
	}

	override public function get width():Number {
	    return 290;
	}

	private function draw(t:int):void {
	    const HEIGHT:Number = height;
	    var i:int;
	    var g:Graphics = this.graphics;
	    g.clear();
	    g.beginFill(color);
	    for(i=0; i< t; i++) {
		g.drawRect(i * 30, 0, 20, HEIGHT);
	    }
	    g.endFill();

	    g.beginFill(backgroundColor, 0.5);
	    for(i=t; i< 10; i++) {
		g.drawRect(i * 30, 0, 20, HEIGHT);
	    }
	    g.endFill();
	    
	}
    }
}
