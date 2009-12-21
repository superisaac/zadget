package {
    public class Log {
	public static function trace(msg:Object):void {
	    main.trigger('log.trace', String(msg));
	}
	public static function info(msg:Object):void {
	    main.trigger('log.info', String(msg));
	}
	public static function warn(msg:Object):void {
	    main.trigger('log.warn', String(msg));
	}
	public static function error(msg:Object):void {
	    main.trigger('log.error', String(msg));
	}
	public static function critical(msg:Object):void {
	    main.trigger('log.critical', String(msg));
	}
    }
}
