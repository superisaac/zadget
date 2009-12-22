package me.zadget.common {
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import me.zadget.common.Util;

    public class Pin extends Sprite {
	public var tooltipText:String;
	public var color:Number;
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
	    //graphics.lineStyle(2, 0xffffff);
	    //graphics.drawRect(-4, -4, 8, 8);
	    graphics.drawCircle(0, 0, 6);
	    graphics.endFill();
	}

	protected function onMouseOut(event:MouseEvent):void {
	    main.instance.hideTooltip();
	}
	
	protected function onMouseOver(event:MouseEvent):void {
	    main.instance.showTooltip(tooltipText);
	}
    }
}
