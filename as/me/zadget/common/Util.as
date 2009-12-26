/*
 * Zadget - the all-in-one mini flash gadget http://zadget.me
 * Copyright (C) 2008-2009 Zeng Ke
 * 
 * Licensed under to term of GNU General Public License Version 2 or Later (the "GPL")
 *   http://www.gnu.org/licenses/gpl.html
 *
 */
package me.zadget.common {
    import flash.display.DisplayObject;
    import flash.filters.*;

    public class Util {
    public static var colorTable:Array = [
			 0x0000ff, // Blue
			 0x8a2be2, // BlueVoilet
			 0xa52a2a, // Brown
			 0x00ffff, // Aqua
			 0xdeb887, // BurlyWood
			 0x7fffd4, // Aquamarine
			 0xf0ffff, // Azure
			 0xffebcd, // BlanchedAlmond
			 0x5f9ea0, // CadetBlue
			 0x7fff00, // Chartreuse
			 0xd2691e, // Chocolate
			 0xff7f50, // Coral
			 0x6495ed, // CornflowerBlue
			 0xfff8dc, // Cornsilk
			 0xdc143c, // Crimson
			 //0x00ffff, // Cyan
			 0x00008B, // Darkblue
			 0x8b0000, // DarkRed
			 0x556b2f, // DarkOliverGreen
			 0x696969, // DimGray
			 0x808080, // Gray
			 0x008000, // Green
			 0xadd8e6, // LightBlue
			 0x00ff00, // Lime
			 0x32cd32, // LimeGreen
			 0x000080, // Navy
			 0xffa500, // Orange
			 0xff4500, // Orangered
			 0xda70d6, // Orchild
			 0xffc0c8, // Pink
			 0xff0000, // Red
			 0x8b4513, // SaddleBrown
			 0x000000, // Black
			 0xc0c0c0, // Silver
			 0x87ceeb, // Skyblue
			 0xd2b48c, // Tan
			 0xee82ee, // Violet
			 0xfff8ff, // AliceBlue
			 0xffff00, // Yellow
			 0x9acd32, // Yellow green
			 ];

	private static var nextColorIndex:int = 0;
	public static function get chooseColor():Number {
	    var color:Number = Util.colorTable[Util.nextColorIndex];
	    Util.nextColorIndex += 1;
	    if(Util.nextColorIndex >= Util.colorTable.length) {
		Util.nextColorIndex = 0;
	    }
	    return color;
	}

	public static function resetColorIndex():void {
	    nextColorIndex = 0;
	}

	public static function getOption(option:Object, key:String, defaultVal:Object):Object {
	    if(option && option.hasOwnProperty(key)) {
		return option[key];
	    } else {
		return defaultVal;
	    }
	}

	public static function getBound(max:Number, min:Number):Object {
	    var degree:Number = Math.pow(10, Math.floor(Math.log(max - min)/Math.log(10)));
	    var bound:Object = new Object();
	    bound.high = Math.ceil(max/degree) * degree;
	    bound.low = Math.floor(min/degree) * degree;
	    return bound;
	}
	
	public static function installShadow(sprite:DisplayObject, distance:int=6): DropShadowFilter {
	    var filter:DropShadowFilter = new DropShadowFilter();
	    filter.distance = distance;
	    filter.color = 0xaaaaaa;
	    var filterList:Array = sprite.filters;
	    filterList.push(filter);
	    sprite.filters = filterList;
	    return filter;
	}
    }
}
