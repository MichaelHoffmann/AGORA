/**
 * This is a generated class and is not intended for modfication.  To customize behavior
 * of this value object you may modify the generated sub-class of this class - Users.as.
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
public class _Super_Users extends flash.events.EventDispatcher implements com.adobe.fiber.valueobjects.IValueObject
{
    model_internal static function initRemoteClassAliasSingle(cz:Class) : void 
    {
    }   
     
    model_internal static function initRemoteClassAliasAllRelated() : void 
    {
    }

	model_internal var _dminternal_model : _UsersEntityMetadata;

	/**
	 * properties
	 */
	private var _internal_lastName : String;
	private var _internal_email : String;
	private var _internal_userLevel : int;
	private var _internal_userName : String;
	private var _internal_user_id : int;
	private var _internal_firstName : String;
	private var _internal_createdDate : Date;
	private var _internal_password : String;

    private static var emptyArray:Array = new Array();

    /**
     * derived property cache initialization
     */  
    model_internal var _cacheInitialized_isValid:Boolean = false;   
    
	model_internal var _changeWatcherArray:Array = new Array();   

	public function _Super_Users() 
	{	
		_model = new _UsersEntityMetadata(this);
	
		// Bind to own data properties for cache invalidation triggering  
       
	}

    /**
     * data property getters
     */
	[Bindable(event="propertyChange")] 
    public function get lastName() : String    
    {
            return _internal_lastName;
    }    
	[Bindable(event="propertyChange")] 
    public function get email() : String    
    {
            return _internal_email;
    }    
	[Bindable(event="propertyChange")] 
    public function get userLevel() : int    
    {
            return _internal_userLevel;
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
    public function get firstName() : String    
    {
            return _internal_firstName;
    }    
	[Bindable(event="propertyChange")] 
    public function get createdDate() : Date    
    {
            return _internal_createdDate;
    }    
	[Bindable(event="propertyChange")] 
    public function get password() : String    
    {
            return _internal_password;
    }    

    /**
     * data property setters
     */      
    public function set lastName(value:String) : void 
    {    	
        var recalcValid:Boolean = false;
    	if (value == null || _internal_lastName == null)
    	{
    		recalcValid = true;
    	}	
    	
    	
    	var oldValue:String = _internal_lastName;               
        if (oldValue !== value)
        {
            _internal_lastName = value;
        }    	     
        
        if (recalcValid && model_internal::_cacheInitialized_isValid)
        {
            model_internal::isValid_der = model_internal::calculateIsValid();
        }  
    }    
    public function set email(value:String) : void 
    {    	
        var recalcValid:Boolean = false;
    	if (value == null || _internal_email == null)
    	{
    		recalcValid = true;
    	}	
    	
    	
    	var oldValue:String = _internal_email;               
        if (oldValue !== value)
        {
            _internal_email = value;
        }    	     
        
        if (recalcValid && model_internal::_cacheInitialized_isValid)
        {
            model_internal::isValid_der = model_internal::calculateIsValid();
        }  
    }    
    public function set userLevel(value:int) : void 
    {    	
        var recalcValid:Boolean = false;
    	
    	
    	var oldValue:int = _internal_userLevel;               
        if (oldValue !== value)
        {
            _internal_userLevel = value;
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
    public function set firstName(value:String) : void 
    {    	
        var recalcValid:Boolean = false;
    	if (value == null || _internal_firstName == null)
    	{
    		recalcValid = true;
    	}	
    	
    	
    	var oldValue:String = _internal_firstName;               
        if (oldValue !== value)
        {
            _internal_firstName = value;
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
    public function set password(value:String) : void 
    {    	
        var recalcValid:Boolean = false;
    	if (value == null || _internal_password == null)
    	{
    		recalcValid = true;
    	}	
    	
    	
    	var oldValue:String = _internal_password;               
        if (oldValue !== value)
        {
            _internal_password = value;
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

		if (_model.isLastNameAvailable && _internal_lastName == null)
		{
			violatedConsts.push("lastNameIsRequired");
			validationFailureMessages.push("lastName is required");
		}
		if (_model.isEmailAvailable && _internal_email == null)
		{
			violatedConsts.push("emailIsRequired");
			validationFailureMessages.push("email is required");
		}
		if (_model.isUserNameAvailable && _internal_userName == null)
		{
			violatedConsts.push("userNameIsRequired");
			validationFailureMessages.push("userName is required");
		}
		if (_model.isFirstNameAvailable && _internal_firstName == null)
		{
			violatedConsts.push("firstNameIsRequired");
			validationFailureMessages.push("firstName is required");
		}
		if (_model.isCreatedDateAvailable && _internal_createdDate == null)
		{
			violatedConsts.push("createdDateIsRequired");
			validationFailureMessages.push("createdDate is required");
		}
		if (_model.isPasswordAvailable && _internal_password == null)
		{
			violatedConsts.push("passwordIsRequired");
			validationFailureMessages.push("password is required");
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
    public function get _model() : _UsersEntityMetadata
    {
		return model_internal::_dminternal_model;              
    }	
    
    public function set _model(value : _UsersEntityMetadata) : void       
    {
    	var oldValue : _UsersEntityMetadata = model_internal::_dminternal_model;               
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
