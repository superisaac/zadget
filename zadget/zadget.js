/*
 * Zadget - the all-in-one mini flash gadget http://zadget.me
 * Copyright (C) 2008-2009 Zeng Ke
 * 
 * Licensed under to term of GNU General Public License Version 2 or Later (the "GPL")
 *   http://www.gnu.org/licenses/gpl.html
 *
 */

// A simple string format function
// Usage: format('%s = %s x %s', 10, 5, 2);
function format(fmt) {
    for(var i=1; i< arguments.length; i++) {
	fmt = fmt.replace('%s', arguments[i]);
    }
    return fmt;
}

function dispatchEvent(event) {
    if(window.eventHub == undefined) {
	window.eventHub = {};
    }
    var queue = undefined;
    try{
	queue = window.eventHub[event.source][event.sort];
    }catch(TypeError) {
	// Pass
    }
    if(queue != undefined) {
	var newqueue = [];
	for(var i=0; i<queue.length; i++) {
	    var cb_obj = queue[i];
	    cb_obj.callback(event);
	    if(!cb_obj.once) {
		newqueue.push(cb_obj);
	    }
	}
	window.eventHub[event.source][event.sort] = newqueue;
    }
}

function _getOption(option, key, defaultValue) {
    if(option == undefined) {
	return defaultValue;
    }
    if(option.hasOwnProperty(key)) {
	return option[key];
    } else {
	return defaultValue;
    }
}

function _isIE() {
    return navigator.appName.indexOf("Microsoft Internet") >= 0;
}

function Zadget(div_id, option) {
    this.divId = div_id;
    this.option = option;
    this._ready = false;
    this.ack = null;
    this.swfId = '';
    this.backgroundColor = '#ffffff';
    this.swfUrl = '/zadget/zadget.swf';
}


Zadget.prototype.connect_once = function(msg_sort, callback) {
    return this.connect(msg_sort, callback, true);
}

Zadget.prototype.connect = function(msg_sort, callback, once) {
    if(window.eventHub ==  undefined) {
	window.eventHub = {};
    }
    if(once == undefined) {
	once = false;
    }
    var cb_obj = {once: once, callback: callback};
    var eventHub = window.eventHub;
    if(!eventHub.hasOwnProperty(this.divId)) {
	eventHub[this.divId] = {};
    }
    var queue = eventHub[this.divId][msg_sort];

    if(queue != undefined) {
	queue.push(cb_obj);
    } else {
	eventHub[this.divId][msg_sort] = [cb_obj];
    }    
}

Zadget.prototype.disconnect = function(msg_sort, callback) {
    var queue = eventHub[event.source][event.sort];
    if(queue != undefined) {
	var yaqueue = [];
	for(var i = 0; i< queue.length; i++) {
	    var cb_obj = queue[i];
	    if(cb_obj.callback != callback) {
		yaqueue.push(cb_obj);
	    }
	}
	eventHub[event.source] = yaqueue;
    }
}

Zadget.prototype.install = function() {
    this.swfId = 'zadget_' + this.divId;
    var name = 'name_' + this.divId;
    var div = document.getElementById(this.divId);
    this.width = parseInt(div.style.width);
    if(isNaN(this.width)){
	this.width = 500;
    } 

    this.height = parseInt(div.style.height);
    if(isNaN(this.height)){
	this.height = this.width;
    } 

    var bgcolor = '';
    if(this.backgroundColor != undefined) {
	bgcolor = 'bgcolor="' + this.backgroundColor + '" ';
    }
    var flashVars = 'source=' + this.divId;
    var str;
    if(_isIE()) {
	str = '<object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" ';
	str += '     id="' + this.swfId + '" width="' + this.width +'" height="' + this.height + ' "';
	str += '     codebase="http://fpdownload.macromedia.com/get/flashplayer/current/swflash.cab">';
	str += '   <param name="movie" value="' + this.swfUrl + '" />';
	str += '   <param name="quality" value="high"/>';
	str += '   <param name="wmode" value="opaque"/>';
	str += '   <param name="flashVars" value="' + flashVars + '"/>';
	str += '   <param name="bgcolor" value="' + this.backgroundColor + '"/>';
	str += '   <param name="allowScriptAccess" value="alwayw"/>';
	str += ' </object>';
    } else {
	str = format('<embed id="%s" ', this.swfId);
	str += format('   height="%s" width="%s" ', this.height, this.width);
	str += format('   wmode="opaque" quality="high" %s ', bgcolor);
	str += format('   name="%s" flashVars="%s" ', name, flashVars);
	str += format('   allowScriptAccess="always" ');
	str += format('   src="%s" ', this.swfUrl);
	str += format('   type="application/x-shockwave-flash"/>');
    }
    var zadget = this;
    this.connect_once('ready', function(evt) {
	zadget._ready = true;});
    div.innerHTML = str;
}

Zadget.prototype._getSWFObject = function() {
    return document.getElementById(this.swfId);
}

Zadget.prototype.ready = function(callback) {
    var swfobj = this._getSWFObject();
    if(this._ready) {
	callback(swfobj);
    } else {
	this.connect_once('ready', function(evt) {
	    callback(swfobj);
	});
    }
}

Zadget.prototype.setOption = function(options) {
    this.ready(function(swfobj){ swfobj.setOption(options); });
}

Zadget.prototype.clear = function() {
    this.ready(function(swfobj) { swfobj.clear(); });
}
Zadget.prototype.post = function(type, data) {
    return this.ready(function(swfobj) { swfobj.post(type, data); });
}

Zadget.prototype.lines = function(data, option) {
    this.ready(function(swfobj) { swfobj.lines(data, option); });
}

Zadget.prototype.plot2d = function(datax, datay, option) {
    this.ready(function(swfobj) { swfobj.plot2d(datax, datay, option); });
}

Zadget.prototype.pie = function(data, option) {
    this.ready(function(swfobj) { swfobj.pie(data, option); });
}

Zadget.prototype.serial = function(interval, capacity, streams) {
    return this.ready(function(swfobj) { swfobj.serial(interval, capacity, streams); });
}

Zadget.prototype.playMusic = function(url, option) {
    return this.ready(function(swfobj) { swfobj.playMusic(url, option); });
}

Zadget.prototype.image = function(url) {
    return this.ready(function(swfobj) { swfobj.image(url); });
}

Zadget.prototype.doodle = function(option) {
    return this.ready(function(swfobj) { swfobj.doodle(option); });
}

Zadget.prototype.playFLV = function(url, option) {
    return this.ready(function(swfobj) { swfobj.playFLV(url, option); });
}
