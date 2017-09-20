package classes {

    import flash.errors.IllegalOperationError;
    import flash.external.ExternalInterface;
    import flash.net.navigateToURL;
    import flash.net.URLRequest;
    import flash.system.Capabilities;
    public class SWFAddress {

        private static var _availability:Boolean = ExternalInterface.available;
        
		/**
         * @throws IllegalOperationError The class cannot be instantiated.
         */
        public function SWFAddress() {
            throw new IllegalOperationError('SWFAddress cannot be instantiated.');
        }
        
        private static function _initialize():Boolean {
            if (_availability) {
                try {
                    _availability = 
                        ExternalInterface.call('function() { return (typeof SWFAddress != "undefined"); }') 
                            as Boolean;
                } catch (e:Error) {
                    _availability = false;
                }
            }
            return true;
        }
        private static var _initializer:Boolean = _initialize();
        
        
        public static function getValue():String {
            var value:String, ids:String = null;
            if (_availability) { 
                value = ExternalInterface.call('SWFAddress.getValue') as String;
            }
            if (value == 'undefined' || value == null) {
                value = '';
            }
            return value || '';
        }
        
        /**
         * Opens a new URL in the browser. 
         * @param url The resource to be opened.
         * @param target Target window.
         */
        public static function href(url:String, target:String = '_self'):void {
            if (_availability && Capabilities.playerType == 'ActiveX') {
                ExternalInterface.call('SWFAddress.href', url, target);
                return;
            }
            navigateToURL(new URLRequest(url), target);
        }
    }
}