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
    import me.zadget.common.WidgetEvent;
    import me.zadget.common.WidgetEvent;

    import flash.net.NetConnection;
    import flash.net.NetStream;
    import flash.media.Video;
    import flash.media.SoundTransform;
    import flash.utils.Timer;
    import flash.events.*;

    public class FlvPlayer extends Widget {
	private var option:Object = null;
	private var url:String;
	public function FlvPlayer(url:String, option:Object) {
	    this.option = option;
	    this.url = url;
	    addEventListener('widget.stop', stopPlay);
	    addEventListener('widget.seek', seek);
	    addEventListener('widget.volume', setVolume);
	}

	override public function get className():String {
	    return 'flvplayer';
	}

	public static function handlePlay(url:String, option:Object=null):void {
	    var player:FlvPlayer = new FlvPlayer(url, option);
	    main.instance.addWidget(player);
	    player.startPlay();
	}
	
	private var nc:NetConnection;
	private var ns:NetStream;
	private var video:Video;
	
	private var _videoWidth:Number = 512;
	private var _videoHeight:Number = 512;
	private var _duration:Number = NaN;
	
	override public function get logicWidth():Number {
	    return _videoWidth;
	}

	override public function get logicHeight():Number {
	    return _videoHeight;
	}

	private function startPlay():void {
	    nc = new NetConnection();
	    nc.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
	    nc.connect(null);
	}
	private function connectStream():void {
	    ns = new NetStream(nc);
	    video = new Video();
	    addChild(video);
	    var client:Object = new Object();
	    client.onMetaData = onNSMetaData;
	    client.onPlayStatus = onNSPlayStatus;
	    ns.client = client;
	    video.attachNetStream(ns);
	    ns.play(url);
	}

	private function onNetStatus(event:NetStatusEvent):void {
            switch (event.info.code) {
                case "NetConnection.Connect.Success":
		    connectStream();
		    break;
                case "NetStream.Play.StreamNotFound":
		    Log.error('FLV not found on server');
		    stopPlay();
                    break;
            }
        }

	private function onNSMetaData(meta:Object):void {
	    _duration = meta.duaration;
	    _videoWidth = video.videoWidth;
	    _videoHeight = video.videoHeight;
	    video.width = _videoWidth;
	    video.height = _videoHeight;
	    scaleStage();
	    meta.videoWidth = _videoWidth;
	    meta.videoHeight = _videoHeight;
	    main.trigger('flvplayer.meta', meta);
	}
	private function onNSPlayStatus(status:Object):void {
	    if(status.code == 'NetStream.Play.Complete') {
		main.trigger('flvplayer.stopped');
	    }
	}
	
	public function stopPlay(event:Event=null):void {
	    if(ns) {
		ns.close();
		main.trigger('flvplayer.stopped');
		ns = null;
	    }
	}

	private function seek(event:WidgetEvent=null):void {
	    if(ns) {
		ns.seek(event.data as Number);
	    }
	}

	private function setVolume(event:WidgetEvent):void {
	    var v:Number = event.data as Number;
	    if(ns) {
		if(v > 1) v = 1;
		else if(v < 0) v = 0;

		var trans:SoundTransform = new SoundTransform();
		trans.volume = v;
		ns.soundTransform = trans;
	    }
	}

	override public function widgetRemoved():void {
	    stopPlay();
	}
    }
}
