if(window.console == undefined) {
    window.console = {
	info: function (){},
	error: function () {}
    }
}

var initCode = "var widget = new Zadget('container_1');\n";
initCode += "widget.backgroundColor = '#fdffce';\n";
initCode += "widget.install();\n\n";

var widget;
function pageLoaded() {
    widget = new Zadget('container_1');
    widget.swfUrl += '?rand=' + Math.random();
    widget.backgroundColor = '#fdffce';
    widget.connect('log.info', flash_info);
    widget.connect('log.error', flash_error);
    widget.connect('log.warn', flash_warn);
    widget.connect('musicplayer.id3', player_id3);
    widget.connect('musicplayer.stopped', function(evt) {console.info("stopped")});
    widget.connect('doodle.stroke', on_doodle_stroke);
    widget.connect('doodle.pop', on_doodle_pop);
    widget.install();
}

function on_doodle_stroke(evt) {
    console.info(evt.data.points);
}

function on_doodle_pop(evt) {
    setTimeout(function() {
	widget.post('stroke', evt.data);
    }, 2000);
}


function player_id3(evt) {
    console.info('song name', evt.data.songName);
    console.info('album', evt.data.album);
    console.info('artist', evt.data.artist);
}

function flash_info(evt) {
    var msg = evt.data;
    console.info(msg);
}

function flash_error(evt) {
    var msg = evt.data;
    console.error(msg);
}

function flash_warn(evt) {
    var msg = evt.data;
    console.warn(msg);
}

function flash_dtrace(msg) {
    console.info(msg);
}

function plot() {
    show();
    widget.lines([ 3.1, 3.2, 1.4, 9.8, 6.1, 3.45, {value: 8.4, label: 'last'}],
		 {title:'Trends of A' });
    widget.lines([{value: 2.1, label: 'week1'},
		  {value: -3.1, label: 'week2'}, 
		  {value: 6.7, label: 'week3'}, 
		  {value: 6.8, label: 'week4'}, 
		  {value: 4.3, label: 'week5'}, 
		  {value: -1.7, label: 'week6'},
		  {value: 1.5, label: 'week7'},
		  {value: 1.12, label: 'week8'}],
		 {use_dot: true, title:'Trends of B' });
    var s = "widget.lines([ 3.1, 3.2, 1.4, 9.8, 6.1, 3.45, {value: 8.4, label: 'last'}], \n";
    s += "      {title:'Trends of A' }); \n";
    s += "widget.lines([{value: 2.1, label: 'week1'}, \n";
    s += "      {value: -3.1, label: ' week2'}, \n";
    s += "      {value: 6.7, label: 'week3'}, \n";
    s += "      {value: 6.8, label: 'week4'}, \n";
    s += "      {value: 4.3, label: 'week5'}, \n";
    s += "      {value: -1.7, label: 'week6'},\n";
    s += "      {value: 1.5, label: 'week7'},\n";
    s += "      {value: 1.12, label: 'week8'}],\n";
    s += "      {use_dot: true, title:'Trends of B' });\n";
    setCode(s);

}

function plot2d() {
    show();
    widget.plot2d([-10, 20, 30, 111, 16], [-70, 30, 110, 30, 9], 
		  {title: 'Data of A'});
    widget.plot2d([-30, 19, 10, 211, 26], [-90, 40, 120, 20, 59],
		  {color: 0x00ff00, title: "Data of B"});
    var s = "";
    s += "widget.plot2d([-10, 20, 30, 111, 16], [-70, 30, 110, 30, 9], \n";
    s += "        {title: 'Data of A'}); \n";
    s += "widget.plot2d([-30, 19, 10, 211, 26], [-90, 40, 120, 20, 59],\n";
    s += "        {color: 0x00ff00, title: 'Data of B'});\n";
    setCode(s);
}

function pie2d() {
    show('pie');
    widget.pie([{label: 'New York',  value: 3099},
               {label: 'Shanghai', value: 1222.1},
		{label: "London", value: 2222},
		{label: 'Paris', value: 1563},
		{label: 'Tokyo', value: 1700}]);


    var s = "widget.pie([{label: 'New York',  value: 3099},\n";
    s += "          {label: 'Shanghai', value: 1222.1},\n";
    s += "          {label: 'London', value: 2222},\n";
    s += "          {label: 'Paris', value: 1563},\n";
    s += "          {label: 'Tokyo', value: 1700}]);\n";
    setCode(s);    
}

function pie3d() {
    show('pie');
    widget.pie([{label: 'New York',  value: 3099},
               {label: 'Shanghai', value: 1222.1},
		{label: "London", value: 2222},
		{label: 'Paris', value: 1563},
		{label: 'Tokyo', value: 1700}], {use_3d: true});

    var s = "widget.pie([{label: 'New York',  value: 3099},\n";
    s += "          {label: 'Shanghai', value: 1222.1},\n";
    s += "          {label: 'London', value: 2222},\n";
    s += "          {label: 'Paris', value: 1563},\n";
    s += "          {label: 'Tokyo', value: 1700}], {use_3d: true});\n";
    setCode(s);
}

function image() {
    show();
    widget.image('media/clownfish.jpg');
    setCode("widget.image('media/clownfish.jpg')\n");
}

function playMusic() {
    show('musicplayer');
    widget.playMusic("media/3inch.mp3", {color: 0x00ff00});
    var s = "widget.playMusic('media/3inch.mp3', {color: 0x00ff00});\n";
    setCode(s);
}

function stopPlay() {
    widget.post('stop');
}

function seek() {
    widget.post('seek', 20);
}

var _volume = 1.0;
function toggleVolume() {
    _volume = 1 - _volume;
    widget.post('volume', _volume);
}

function doodle() {
    show('doodle');
    widget.doodle();
    setCode("widget.doodle();\n");
}

function doodlePop() {
    widget.post('popstroke');
}

function playFLV() {
    show('flvplayer');
    //widget.playFLV(window.location + 'media/1001.flv');
    setCode("widget.playFLV(window.location + 'media/1001.flv');\n");
}

function serialSetValue() {
    var e = Math.random() + 5.3;
    widget.post('value', {label: 'aaa', value: e});
    e = Math.random() + 2.6;
    widget.post('value', {label: 'bbb', value: e});
    setTimeout(serialSetValue, 300);
}

function timeSerial() {
    show();
    widget.serial(1000, 60, [{label: 'aaa', initial: 5.0, color: 0xff0000},
			    {label: 'bbb', initial: 3.2}]);
    serialSetValue();
    
    var s =  "function serialSetValue() { \n";
    s += "    var e = Math.random() + 5.3;\n";
    s += "    widget.post('value', {label: 'aaa', value: e});\n";
    s += "    e = Math.random() + 2.6;\n";
    s += "    widget.post('value', {label: 'bbb', value: e});\n";
    s += "    setTimeout(serialSetValue, 300);\n";
    s += "}\n";
    s += "widget.serial(1000, 60, [{label: 'aaa', initial: 5.0, color: 0xff0000},\n";
    s += "       {label: 'bbb', initial: 3.2}]);\n";
    s += "serialSetValue();";
    setCode(s);
}

function clearWidget() {
    show();
    widget.clear();
    setCode("widget.clear();\n");
}

function show(div_id) {
    widget.clear();
    setCode('');
    $('.sub-commands').hide();
    if(div_id != undefined) {
	$('div#' + div_id + '.sub-commands').show();
    }
}

function setCode(code) {
    $('#code textarea').val(initCode + code);
}
$(document).ready(function() {
    setCode('');
});