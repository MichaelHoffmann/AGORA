/**
 * This is a generated class and is not intended for modfication.  To customize behavior
 * of this value object you may modify the generated sub-class of this class - Maps.as.
 */

package valueObjects
{
import com.adobe.fiber.services.IFiberManagingService;
import com.adobe.fiber.valueobjects.IValueObject;
import flash.events.Event;
import flash.events.EventDispatcher;
import mx.events.PropertyChangeEvent;

import flash.net.registerClassAlias;
import flash.net.getClassByAlias;
import com.adobe.fiber.core.model_internal;
import com.adobe.fiber.valueobjects.IPropertyIterator;
import com.adobe.fiber.valueobjects.AvailablePropertyIterator;

use namespace model_internal;

[Managed]
[ExcludeClass]
public class _Super_Maps extends flash.events.EventDispatcher implements com.adobe.fiber.valueobjects.IValueObject
{
    model_internal static function initRemoteClassAliasSingle(cz:Class) : void 
    {
    }   
     
    model_internal static function initRemoteClassAliasAllRelated() : void 
    {
    }

	model_internal var _dminternal_model : _MapsEntityMetadata;

	/**
	 * properties
	 */
	private var _internal_title : String;
	private var _internal_map_id : int;
	private var _internal_userName : String;
	private var _internal_user_id : int;
	private var _internal_createdDate : Date;
	private var _internal_modifiedDate : Date;

    private static var emptyArray:Array = new Array();

    /**
     * derived property cache initialization
     */  
    model_internal var _cacheInitialized_isValid:Boolean = false;   
    
	model_internal var _changeWatcherArray:Array = new Array();   

	public function _Super_Maps() 
	{	
		_model = new _MapsEntityMetadata(this);
	
		// Bind to own data properties for cache invalidation triggering  
       
	}

    /**
     * data property getters
     */
	[Bindable(event="propertyChange")] 
    public function get title() : String    
    {
            return _internal_title;
    }    
	[Bindable(event="propertyChange")] 
    public function get map_id() : int    
    {
            return _internal_map_id;
    }    
	[Bindable(event="propertyChange")] 
    public function get userName() : String    
    {
            return _internal_userName;
    }    
	[Bindable(event="propertyChange")] 
    public function get user_id() : int    
    {
            return _internal_user_id;
    }    
	[Bindable(event="propertyChange")] 
    public function get createdDate() : Date    
    {
            return _internal_createdDate;
    }    
	[Bindable(event="propertyChange")] 
    public function get modifiedDate() : Date    
    {
            return _internal_modifiedDate;
    }    

    /**
     * data property setters
     */      
    public function set title(value:String) : void 
    {    	
        var recalcValid:Boolean = false;
    	if (value == null || _internal_title == null)
    	{
    		recalcValid = true;
    	}	
    	
    	
    	var oldValue:String = _internal_title;               
        if (oldValue !== value)
        {
            _internal_title = value;
        }    	     
        
        if (recalcValid && model_internal::_cacheInitialized_isValid)
        {
            model_internal::isValid_der = model_internal::calculateIsValid();
        }  
    }    
    public function set map_id(value:int) : void 
    {    	
        var recalcValid:Boolean = false;
    	
    	
    	var oldValue:int = _internal_map_id;               
        if (oldValue !== value)
        {
            _internal_map_id = value;
        }    	     
        
        if (recalcValid && model_internal::_cacheInitialized_isValid)
        {
            model_internal::isValid_der = model_internal::calculateIsValid();
        }  
    }    
    public function set userName(value:String) : void 
    {    	
        var recalcValid:Boolean = false;
    	if (value == null || _internal_userName == null)
    	{
    		recalcValid = true;
    	}	
    	
    	
    	var oldValue:String = _internal_userName;               
        if (oldValue !== value)
        {
            _internal_userName = value;
        }    	     
        
        if (recalcValid && model_internal::_cacheInitialized_isValid)
        {
            model_internal::isValid_der = model_internal::calculateIsValid();
        }  
    }    
    public function set user_id(value:int) : void 
    {    	
        var recalcValid:Boolean = false;
    	
    	
    	var oldValue:int = _internal_user_id;               
        if (oldValue !== value)
        {
            _internal_user_id = value;
        }    	     
        
        if (recalcValid && model_internal::_cacheInitialized_isValid)
        {
            model_internal::isValid_der = model_internal::calculateIsValid();
        }  
    }    
    public function set createdDate(value:Date) : void 
    {    	
        var recalcValid:Boolean = false;
    	if (value == null || _internal_createdDate == null)
    	{
    		recalcValid = true;
    	}	
    	
    	
    	var oldValue:Date = _internal_createdDate;               
        if (oldValue !== value)
        {
            _internal_createdDate = value;
        }    	     
        
        if (recalcValid && model_internal::_cacheInitialized_isValid)
        {
            model_internal::isValid_der = model_internal::calculateIsValid();
        }  
    }    
    public function set modifiedDate(value:Date) : void 
    {    	
        var recalcValid:Boolean = false;
    	if (value == null || _internal_modifiedDate == null)
    	{
    		recalcValid = true;
    	}	
    	
    	
    	var oldValue:Date = _internal_modifiedDate;               
        if (oldValue !== value)
        {
            _internal_modifiedDate = value;
        }    	     
        
        if (recalcValid && model_internal::_cacheInitialized_isValid)
        {
            model_internal::isValid_der = model_internal::calculateIsValid();
        }  
    }    

    /**
     * data property setter listeners
     */   

   model_internal function setterListenerAnyConstraint(value:flash.events.Event):void
   {
        if (model_internal::_cacheInitialized_isValid)
        {
            model_internal::isValid_der = model_internal::calculateIsValid();
        }        
   }   

    /**
     * valid related derived properties
     */
    model_internal var _isValid : Boolean;
    model_internal var _invalidConstraints:Array = new Array();
    model_internal var _validationFailureMessages:Array = new Array();

    /**
     * derived property calculators
     */

    /**
     * isValid calculator
     */
    model_internal function calculateIsValid():Boolean
    {
        var violatedConsts:Array = new Array();    
        var validationFailureMessages:Array = new Array();    

		if (_model.isTitleAvailable && _internal_title == null)
		{
			violatedConsts.push("titleIsRequired");
			validationFailureMessages.push("title is required");
		}
		if (_model.isUserNameAvailable && _internal_userName == null)
		{
			violatedConsts.push("userNameIsRequired");
			validationFailureMessages.push("userName is required");
		}
		if (_model.isCreatedDateAvailable && _internal_createdDate == null)
		{
			violatedConsts.push("createdDateIsRequired");
			validationFailureMessages.push("createdDate is required");
		}
		if (_model.isModifiedDateAvailable && _internal_modifiedDate == null)
		{
			violatedConsts.push("modifiedDateIsRequired");
			validationFailureMessages.push("modifiedDate is required");
		}

		var styleValidity:Boolean = true;
	
	
	
	
	
	
    
        model_internal::_cacheInitialized_isValid = true;
        model_internal::invalidConstraints_der = violatedConsts;
        model_internal::validationFailureMessages_der = validationFailureMessages;
        return violatedConsts.length == 0 && styleValidity;
    }  

    /**
     * derived property setters
     */

    model_internal function set isValid_der(value:Boolean) : void
    {
       	var oldValue:Boolean = model_internal::_isValid;               
        if (oldValue !== value)
        {
        	model_internal::_isValid = value;
        	_model.model_internal::fireChangeEvent("isValid", oldValue, model_internal::_isValid);
        }        
    }

    /**
     * derived property getters
     */

    [Transient] 
	[Bindable(event="propertyChange")] 
    public function get _model() : _MapsEntityMetadata
    {
		return model_internal::_dminternal_model;              
    }	
    
    public function set _model(value : _MapsEntityMetadata) : void       
    {
    	var oldValue : _MapsEntityMetadata = model_internal::_dminternal_model;               
        if (oldValue !== value)
        {
        	model_internal::_dminternal_model = value;
        	this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "_model", oldValue, model_internal::_dminternal_model));
        }     
    }      

    /**
     * methods
     */  


    /**
     *  services
     */                  
     private var _managingService:com.adobe.fiber.services.IFiberManagingService;
    
     public function set managingService(managingService:com.adobe.fiber.services.IFiberManagingService):void
     {
         _managingService = managingService;
     }                      
     
    model_internal function set invalidConstraints_der(value:Array) : void
    {  
     	var oldValue:Array = model_internal::_invalidConstraints;
     	// avoid firing the event when old and new value are different empty arrays
        if (oldValue !== value && (oldValue.length > 0 || value.length > 0))
        {
            model_internal::_invalidConstraints = value;   
			_model.model_internal::fireChangeEvent("invalidConstraints", oldValue, model_internal::_invalidConstraints);   
        }     	             
    }             
    
     model_internal function set validationFailureMessages_der(value:Array) : void
    {  
     	var oldValue:Array = model_internal::_validationFailureMessages;
     	// avoid firing the event when old and new value are different empty arrays
        if (oldValue !== value && (oldValue.length > 0 || value.length > 0))
        {
            model_internal::_validationFailureMessages = value;   
			_model.model_internal::fireChangeEvent("validationFailureMessages", oldValue, model_internal::_validationFailureMessages);   
        }     	             
    }        
     
     // Individual isAvailable functions     
	// fields, getters, and setters for primitive representations of complex id properties

}

}
