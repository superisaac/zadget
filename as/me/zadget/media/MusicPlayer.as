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
    import me.zadget.common.WidgetEvent;
    import me.zadget.common.ProgressBar;

    import flash.display.Graphics;
    import flash.display.Sprite;
    import flash.media.Sound;
    import flash.media.SoundChannel;
    import flash.media.SoundTransform;
    import flash.media.SoundMixer;
    import flash.net.URLRequest;
    import flash.utils.ByteArray;
    import flash.utils.Timer;
    import flash.events.*;

    public class MusicPlayer extends Widget {
	public var spectrumTimer:Timer;
	private var option:Object;
	private var canvas:Sprite;
	private var progressBar:ProgressBar;
	private var song:SoundChannel = null;
	//private var musicLength:Number = 0;

	override public function get className():String {
	    return 'musicplayer';
	}

	public function MusicPlayer(option:Object=null) {
	    this.option = option;
	    spectrumTimer = new Timer(200);
	    spectrumTimer.addEventListener('timer', drawSpectrum);
	    canvas = new Sprite();
	    //Util.installGlow(this, 0xff0000);
	    addChild(canvas);

	    progressBar = new ProgressBar();
	    progressBar.x = (logicWidth - progressBar.width) / 2;
	    progressBar.y = (logicHeight - progressBar.height) - 24;
	    addChild(progressBar);
	    addEventListener('widget.stop', stopPlay);
	    addEventListener('widget.seek', seek);
	    addEventListener('widget.volume', setVolume);
	}

	public static function handlePlay(mp3url:String, option:Object=null):void {
	    var player:MusicPlayer = new MusicPlayer(option);
	    main.instance.addWidget(player);
	    player.playMusic(mp3url);
	}

	private function seek(event:WidgetEvent=null):void {
	    if(song) {
		song.stop();
		var sec:Number = event.data as Number;
		song = sound.play(sec * 1000);
	    }
	}

	public function stopPlay(event:Event=null):void {
	    spectrumTimer.stop();
	    canvas.graphics.clear();
	    progressBar.progress = 0;
	    if(song) {
		song.stop();
                main.trigger('musicplayer.stopped');
		song = null;
	    }
	}

	private function drawProgressBar():void {
	    if(song) {
		var musicLength:Number = sound.length;
		var progress:Number = 0;
		if(musicLength > 0) {
		    progress = song.position / musicLength;
		}
		progressBar.progress = progress;
	    }
	}

	private var sound:Sound;
	public function playMusic(url:String):void {
	    var request:URLRequest = new URLRequest(url);
	    sound = new Sound();
	    //musicLength = sound.length;
	    sound.addEventListener(Event.COMPLETE, onMusicComplete);
            sound.addEventListener(Event.ID3, onId3);
            sound.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
            //sound.addEventListener(ProgressEvent.PROGRESS, onProgress);
	    try {
		sound.load(request);
	    } catch (e:SecurityError) {
		Log.error('Security Error');
		return ;
	    }
	    song = sound.play();
	    song.addEventListener('soundComplete', onSoundComplete);
	    spectrumTimer.start();
	}

	public function setVolume(event:WidgetEvent):void {
	    var v:Number = event.data as Number;
	    if(song) {
		if(v > 1) v = 1;
		else if(v < 0) v = 0;
		var trans:SoundTransform = new SoundTransform();
		trans.volume = v;
		song.soundTransform = trans;
	    }
	}
        public override function get logicWidth():Number {
	    return 512;
	}

	public override function get logicHeight():Number {
	    return 512;
	}
	
	private function drawSpectrum(event:TimerEvent):void {
	    var bytes:ByteArray = new ByteArray();
            const channelLength:int = 256;
	    const centerX:int = logicWidth / 2;
            const centerY:int = logicHeight / 2;
	    const angle:Number = Math.PI/ channelLength;
	    const color:Number = Util.getOption(option, 'color',
						0x6600CC) as Number;
	    const radius:Number = logicWidth / 4;

	    const use_fft:Boolean = Util.getOption(option, 'fft', false);
	    if(SoundMixer.areSoundsInaccessible()) {
		Log.error("Sound are not accessable");
	    } else {
		SoundMixer.computeSpectrum(bytes, use_fft, 0);
		var g:Graphics = canvas.graphics;
		g.clear();
       
		g.lineStyle(0, color);
		g.beginFill(color);
		var fv:Number = (bytes.readFloat() + 1);
		//fv = (fv * fv  +  1)* radius;
		fv = fv * radius;
		g.moveTo(centerX + fv, centerY);
		const loopTime:int = channelLength * 2 - 1;
		for(var i:int = 0; i< loopTime; i++) {
		    var v:Number = (bytes.readFloat() + 1);
		    //v = (v * v + 1)* radius;
		    v = v * radius;
		    g.lineTo(centerX + Math.cos(i * angle) * v,
			     centerY + Math.sin(i* angle) * v);
		}
		g.lineTo(centerX + fv, centerY);
	    }
	    drawProgressBar();
	}

	private function onMusicComplete(event:Event):void {
            main.trigger('musicplayer.started');
	    var sound:Sound = event.currentTarget as Sound;
	    //musicLength = sound.length;
        }

        private function onId3(event:Event):void {
	    var sound:Sound = event.target as Sound;
	    var id3Info:Object = {album: sound.id3.album,
				   artist: sound.id3.artist,
				   comment: sound.id3.comment,
				   songName: sound.id3.songName,
				  year: sound.id3.year};
	    main.trigger('musicplayer.id3', id3Info);
        }

        private function onIOError(event:Event):void {
	    Log.error('I/O error, file not found?');
        }

	private function onSoundComplete(event:Event):void {
	    stopPlay();
	}
	
	override public function widgetRemoved():void {
	    stopPlay();
	}

	override public function stageSizeChanged():void {
	    scaleStage();
	}	
    }
}
