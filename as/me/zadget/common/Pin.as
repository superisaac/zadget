package me.zadget.common {
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import me.zadget.common.Util;

    public class Pin extends Sprite {
	public var tooltipText:String;
	public var color:Number;
	public var mouseOverScale:Number = 1.0;
	public function Pin(tooltipText:String, color:Number=0, shadow:Boolean=false) {
	    this.tooltipText = tooltipText;
	    this.color = color;
	    addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
	    addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
	    if(shadow) {
		Util.installShadow(this, 3);
	    }
	    draw();
	}
	public function draw():void {
	    graphics.beginFill(color, 1);
	    graphics.drawCircle(0, 0, 6);
	    graphics.endFill();
	}

	protected function onMouseOut(event:MouseEvent):void {
	    scaleX /= mouseOverScale;
	    scaleY /= mouseOverScale;
	    main.instance.hideTooltip();
	}
	
	protected function onMouseOver(event:MouseEvent):void {
	    scaleX *= mouseOverScale;
	    scaleY *= mouseOverScale;
	    main.instance.showTooltip(tooltipText);
	}
    }
}
