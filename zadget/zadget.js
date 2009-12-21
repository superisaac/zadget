/*
 * Zadget - the all-in-one mini flash gadget http://zadget.me
 * Copyright (C) 2008-2009 Zeng Ke
 * 
 * Licensed under to term of GNU General Public License Version 2 or Later (the "GPL")
 *   http://www.gnu.org/licenses/gpl.html
 *
 */

function dispatchEvent(event) {
    if(window.eventHub == undefined) {
	window.eventHub = {};
    }
    var queue = window.eventHub[event.source][event.sort];
    if(queue != undefined) {
	for(var i=0; i<queue.length; i++) {
	    var callback = queue[i];
	    callback(event);
	}
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
    this.ack = null;
    this.swfId = '';
    this.backgroundColor = '#ffffff';
    this.swfUrl = '/zadget/zadget.swf';
}

Zadget.prototype.connect = function(msg_sort, callback) {
    if(window.eventHub ==  undefined) {
	window.eventHub = {};
    }
    var eventHub = window.eventHub;
    if(!eventHub.hasOwnProperty(this.divId)) {
	eventHub[this.divId] = {};
    }
    var queue = eventHub[this.divId][msg_sort];
    if(queue != undefined) {
	queue.push(callback);
    } else {
	eventHub[this.divId][msg_sort] = [callback];
    }    
}

Zadget.prototype.disconnect = function(msg_sort, callback) {
    var queue = eventHub[event.source][event.sort];
    if(queue != undefined) {
	var yaqueue = [];
	for(var i = 0; i< queue.length; i++) {
	    if(queue[i] != callback) {
		yaqueue.push(callback);
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
    var params = '';
    var str;
    if(_isIE()) {
	str = '<object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" ';
	str += '    id="' + this.swfId + '" width="' + this.width +'" height="' + this.height + ' "';
	str += '        codebase="http://fpdownload.macromedia.com/get/flashplayer/current/swflash.cab">';
	str += '     <param name="movie" value="' + this.swfUrl + '" />';
	str += '     <param name="quality" value="high"/>';
	str += '     <param name="wmode" value="opaque"/>';
	str += '     <param name="bgcolor" value="' + this.backgroundColor + '"/>';
	str += '     <param name="allowScriptAccess" value="alwayw"/>';
	str += ' </object>';
    } else {
	str = '<embed id="'  + this.swfId + '" ' +
	    '" height="' + this.height + '" width="' + this.width + 
	    '" wmode="opaque" ' +
	    'quality="high" ' + bgcolor + 
	    'name="' + name + '" ' +
	    'allowScriptAccess="always"' +
	    'src="' + this.swfUrl +
	    '" type="application/x-shockwave-flash"/>';
    }
    div.innerHTML = str;
}

Zadget.prototype._getSWFObject = function() {
    return document.getElementById(this.swfId);
}

Zadget.prototype.touch = function(callback) {
    var swfobj = this._getSWFObject();
    var success = true;
    try {    
	if(!this.ack) {
	    var ack = swfobj.checkin(this.divId);
	    success = ack == 'ok';
	    if(success) {
		this.ack = ack;
	    }
	}
    }catch(e) {
	success = false;
    }
    if(success){
	callback(swfobj);
    } else {
	var w = this;
	// wait 300 seconds and check again
	setTimeout(function(){ w.touch(callback); }, 300); 
    }
}

Zadget.prototype.setOption = function(options) {
    this.touch(function(swfobj){ swfobj.setOption(options); });
}

Zadget.prototype.clear = function() {
    this.touch(function(swfobj) { swfobj.clear(); });
}
Zadget.prototype.post = function(type, data) {
    return this.touch(function(swfobj) { swfobj.post(type, data); });
}

Zadget.prototype.lines = function(data, option) {
    this.touch(function(swfobj) { swfobj.lines(data, option); });
}

Zadget.prototype.plot2d = function(datax, datay, option) {
    this.touch(function(swfobj) { swfobj.plot2d(datax, datay, option); });
}

Zadget.prototype.pie = function(data, option) {
    this.touch(function(swfobj) { swfobj.pie(data, option); });
}

Zadget.prototype.serial = function(interval, capacity, streams) {
    return this.touch(function(swfobj) { swfobj.serial(interval, capacity, streams); });
}

Zadget.prototype.playMusic = function(url, option) {
    return this.touch(function(swfobj) { swfobj.playMusic(url, option); });
}

Zadget.prototype.image = function(url) {
    return this.touch(function(swfobj) { swfobj.image(url); });
}

Zadget.prototype.doodle = function(option) {
    return this.touch(function(swfobj) { swfobj.doodle(option); });
}

Zadget.prototype.playFLV = function(url, option) {
    return this.touch(function(swfobj) { swfobj.playFLV(url, option); });
}
