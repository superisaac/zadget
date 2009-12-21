/*
 * Zadget - the all-in-one mini flash gadget http://zadget.me
 * Copyright (C) 2008-2009 Zeng Ke
 * 
 * Licensed under to term of GNU General Public License Version 2 or Later (the "GPL")
 *   http://www.gnu.org/licenses/gpl.html
 *
 */
package me.zadget.media {
    import me.zadget.common.Widget;
    import me.zadget.common.Util;
    import flash.display.Loader;
    import flash.display.Sprite;
    import flash.display.DisplayObject;
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    import flash.events.*;

    public class Image extends Widget{
	public static function handleImage(url:String, option:Object=null):void {
	    var image:Image = new Image(url);
	    image.option = option;
	    main.instance.addWidget(image);
	    image.load();
	}

	public var url:String;
	private var imageLoader:Loader;
	private var _container:Sprite;
	public var option:Object = null;

	public function Image(url:String) {
	    _container = new Sprite();
	    Util.installShadow(_container);
	    addChild(_container);
	    this.url = url;
	    load();
	}
	private function load():void {
	    imageLoader = new Loader();
	    imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
	    imageLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onProgress);
	    imageLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);

	    var request:URLRequest = new URLRequest(url);
	    try{
		imageLoader.load(request);
	    } catch(e:Error) {
		Log.error("Load image " + url +" failed");
	    }
	}
	private var _width:Number = 500;
	private var _height:Number = 500;

        public override function get logicWidth():Number {
	    return _width;
	}
	public override function get logicHeight():Number {
	    return _height;
	}

	private function onComplete(event:Event):void  {
	    _width = imageLoader.width + 6;
	    _height = imageLoader.height + 6;
	    _container.addChild(imageLoader);
	    scaleStage();
	}

	private function onProgress(event:Event):void  {
	}
	private function onError(event:Event):void  {
	}
    }
}