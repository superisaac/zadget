/*
 * Zadget - the all-in-one mini flash gadget http://zadget.me
 * Copyright (C) 2008-2009 Zeng Ke
 * 
 * Licensed under to term of GNU General Public License Version 2 or Later (the "GPL")
 *   http://www.gnu.org/licenses/gpl.html
 *
 */
package me.zadget.common {
    import flash.events.Event;

    public class WidgetEvent extends Event{
	public var data:Object = null;
	public function WidgetEvent(type:String) {
	    super('widget.' + type);
	}
    }
}
