/**
 * This is a generated class and is not intended for modfication.  To customize behavior
 * of this service wrapper you may modify the generated sub-class of this class - MapsService.as.
 */
package services.mapsservice
{
import com.adobe.fiber.core.model_internal;
import com.adobe.fiber.services.wrapper.RemoteObjectServiceWrapper;
import com.adobe.serializers.utility.TypeUtility;
import mx.data.ItemReference;
import mx.data.ManagedAssociation;
import mx.data.ManagedOperation;
import mx.data.ManagedQuery;
import mx.data.RPCDataManager;
import mx.rpc.AbstractOperation;
import mx.rpc.AsyncToken;
import mx.rpc.remoting.Operation;
import mx.rpc.remoting.RemoteObject;
import valueObjects.Maps;

import mx.collections.ItemResponder;
import com.adobe.fiber.valueobjects.AvailablePropertyIterator;

[ExcludeClass]
internal class _Super_MapsService extends com.adobe.fiber.services.wrapper.RemoteObjectServiceWrapper
{      
    private var _mapsRPCDataManager : mx.data.RPCDataManager;
    private var managersArray : Array = new Array();
        
    public const DATA_MANAGER_MAPS : String = "Maps";         
        
    public function getDataManager(dataManagerName:String) : mx.data.RPCDataManager
    {
        switch (dataManagerName)
        {
             case (DATA_MANAGER_MAPS):
                return _mapsRPCDataManager;      
            default:
                return null;
        }
    }
    
    /**
     * Commit all of the pending changes for this DataService, as well as all of the pending changes of all DataServices
     * sharing the same DataStore.  By default, a DataService shares the same DataStore with other DataServices if they have 
     * managed association properties and share the same set of channels. 
     *
     * @see mx.data.DataManager
     * @see mx.data.DataStore
     *
     * @param itemsOrCollections:Array This is an optional parameter which defaults to null when
     *  you want to commit all pending changes.  If you want to commit a subset of the pending
     *  changes use this argument to specify a list of managed ListCollectionView instances
     *  and/or managed items.  ListCollectionView objects are most typically ArrayCollections
     *  you have provided to your fill method.  The items appropriate for this method are
     *  any managed version of the item.  These are any items you retrieve from getItem, createItem
     *  or using the getItemAt method from a managed collection.  Only changes for the
     *  items defined by any of the values in this array will be committed.
     *
     * @param cascadeCommit if true, also commit changes made to any associated
     *  items supplied in this list.
     *
     *  @return AsyncToken that is returned in <code>call</code> property of
     *  either the <code>ResultEvent.RESULT</code> or in the
     *  <code>FaultEvent.FAULT</code>.
     *  Custom data can be attached to this object and inspected later
     *  during the event handling phase.  If no changes have been made
     *  to the relevant items, null is returned instead of an AsyncToken.
     */
    public function commit(itemsOrCollections:Array=null, cascadeCommit:Boolean=false):mx.rpc.AsyncToken
    {
    	return _mapsRPCDataManager.dataStore.commit(itemsOrCollections, cascadeCommit);
    }
    
    /**
     *  Reverts all pending (uncommitted) changes for this DataService, as well as all of the pending changes of all DataServics
     *  sharing the same DataStore.  By default, a DataService shares the same DataStore with other DataServices if they have 
     * managed association properties and share the same set of channels. 
     *
     * @see mx.data.DataManager
     * @see mx.data.DataStore
     *
     *  @return true if any changes were reverted.
     *  
     */
    public function revertChanges():Boolean
    {
        return _mapsRPCDataManager.dataStore.revertChanges();
    }    
       
    // Constructor
    public function _Super_MapsService()
    {
        // initialize service control
        _serviceControl = new mx.rpc.remoting.RemoteObject();
        
        var operations:Object = new Object();
        var operation:mx.rpc.remoting.Operation;
         
        operation = new mx.rpc.remoting.Operation(null, "getAllMaps");
		 operation.resultElementType = valueObjects.Maps;
        operations["getAllMaps"] = operation;

        valueObjects.Maps._initRemoteClassAlias();
        operation = new mx.rpc.remoting.Operation(null, "getMapsByID");
		 operation.resultType = valueObjects.Maps; 		 
        operations["getMapsByID"] = operation;

        valueObjects.Maps._initRemoteClassAlias();
        operation = new mx.rpc.remoting.Operation(null, "createMaps");
		 operation.resultType = int; 		 
        operations["createMaps"] = operation;

        operation = new mx.rpc.remoting.Operation(null, "updateMaps");
        operations["updateMaps"] = operation;

        operation = new mx.rpc.remoting.Operation(null, "deleteMaps");
        operations["deleteMaps"] = operation;

        operation = new mx.rpc.remoting.Operation(null, "count");
		 operation.resultType = int; 		 
        operations["count"] = operation;

        operation = new mx.rpc.remoting.Operation(null, "getMaps_paged");
		 operation.resultElementType = valueObjects.Maps;
        operations["getMaps_paged"] = operation;

        valueObjects.Maps._initRemoteClassAlias();
    
        _serviceControl.operations = operations;   
		_serviceControl.convertResultHandler = com.adobe.serializers.utility.TypeUtility.convertResultHandler;
        _serviceControl.source = "MapsService";
        _serviceControl.endpoint = "gateway.php";
		destination = "MapsService";
        
        var managedAssociation : mx.data.ManagedAssociation;
    	var managedAssocsArray : Array;
        // initialize Maps data manager     
        _mapsRPCDataManager = new mx.data.RPCDataManager();
        managersArray.push(_mapsRPCDataManager);
        
        managedAssocsArray = new Array();
        
        _mapsRPCDataManager.destination = "mapsRPCDataManager";
        _mapsRPCDataManager.service = _serviceControl;        
        _mapsRPCDataManager.identities =  "map_id";      
        _mapsRPCDataManager.itemClass = valueObjects.Maps; 
        
                   
    
        var dmOperation : mx.data.ManagedOperation;
        var dmQuery : mx.data.ManagedQuery;
         
        dmOperation = new mx.data.ManagedOperation("getMapsByID", "get");
        dmOperation.parameters = "map_id";
        _mapsRPCDataManager.addManagedOperation(dmOperation);     
            
        dmOperation = new mx.data.ManagedOperation("deleteMaps", "delete");
        dmOperation.parameters = "id";
        _mapsRPCDataManager.addManagedOperation(dmOperation);     
            
        dmQuery = new mx.data.ManagedQuery("getAllMaps");
        dmQuery.propertySpecifier = "title,map_id,userName,user_id,createdDate,modifiedDate";
        dmQuery.parameters = "";
        _mapsRPCDataManager.addManagedOperation(dmQuery);                 

        dmOperation = new mx.data.ManagedOperation("updateMaps", "update");
        dmOperation.parameters = "item";
        _mapsRPCDataManager.addManagedOperation(dmOperation);     
            
        dmOperation = new mx.data.ManagedOperation("createMaps", "create");
        dmOperation.parameters = "item";
        _mapsRPCDataManager.addManagedOperation(dmOperation);     
            
        dmQuery = new mx.data.ManagedQuery("getMaps_paged");
        dmQuery.propertySpecifier = "title,map_id,userName,user_id,createdDate,modifiedDate";
        dmQuery.countOperation = "count";
        dmQuery.pagingEnabled = true;
        dmQuery.positionalPagingParameters = true;
        dmQuery.parameters = "startIndex,numItems";
        _mapsRPCDataManager.addManagedOperation(dmQuery);                 

        _serviceControl.managers = managersArray;
                      
         model_internal::initialize();
    }

	/**
	  * This method is a generated wrapper used to call the 'getAllMaps' operation. It returns an mx.rpc.AsyncToken whose 
	  * result property will be populated with the result of the operation when the server response is received. 
	  * To use this result from MXML code, define a CallResponder component and assign its token property to this method's return value. 
	  * You can then bind to CallResponder.lastResult or listen for the CallResponder.result or fault events.
      *
      * @see mx.rpc.AsyncToken
      * @see mx.rpc.CallResponder 
      *
      * @return an mx.rpc.AsyncToken whose result property will be populated with the result of the operation when the server response is received.
	  */          
	public function getAllMaps() : mx.rpc.AsyncToken
	{
		var _internal_operation:mx.rpc.AbstractOperation = _serviceControl.getOperation("getAllMaps");
		var _internal_token:mx.rpc.AsyncToken = _internal_operation.send() ;

		return _internal_token;
	}   
	 
	/**
	  * This method is a generated wrapper used to call the 'getMapsByID' operation. It returns an mx.data.ItemReference whose 
	  * result property will be populated with the result of the operation when the server response is received. 
	  * To use this result from MXML code, define a CallResponder component and assign its token property to this method's return value. 
	  * You can then bind to CallResponder.lastResult or listen for the CallResponder.result or fault events.
      *
      * @see mx.data.ItemReference
      * @see mx.rpc.CallResponder 
      *
      * @return an mx.data.ItemReference whose result property will be populated with the result of the operation when the server response is received.
	  */          
	public function getMapsByID(itemID:int) : mx.data.ItemReference
	{
		var _internal_operation:mx.rpc.AbstractOperation = _serviceControl.getOperation("getMapsByID");
		var _internal_token:mx.data.ItemReference = _internal_operation.send(itemID) as mx.data.ItemReference;

		return _internal_token;
	}   
	 
	/**
	  * This method is a generated wrapper used to call the 'createMaps' operation. It returns an mx.data.ItemReference whose 
	  * result property will be populated with the result of the operation when the server response is received. 
	  * To use this result from MXML code, define a CallResponder component and assign its token property to this method's return value. 
	  * You can then bind to CallResponder.lastResult or listen for the CallResponder.result or fault events.
      *
      * @see mx.data.ItemReference
      * @see mx.rpc.CallResponder 
      *
      * @return an mx.data.ItemReference whose result property will be populated with the result of the operation when the server response is received.
	  */          
	public function createMaps(item:valueObjects.Maps) : mx.data.ItemReference
	{
		var _internal_operation:mx.rpc.AbstractOperation = _serviceControl.getOperation("createMaps");
		var _internal_token:mx.data.ItemReference = _internal_operation.send(item) as mx.data.ItemReference;

		return _internal_token;
	}   
	 
	/**
	  * This method is a generated wrapper used to call the 'updateMaps' operation. It returns an mx.data.ItemReference whose 
	  * result property will be populated with the result of the operation when the server response is received. 
	  * To use this result from MXML code, define a CallResponder component and assign its token property to this method's return value. 
	  * You can then bind to CallResponder.lastResult or listen for the CallResponder.result or fault events.
      *
      * @see mx.data.ItemReference
      * @see mx.rpc.CallResponder 
      *
      * @return an mx.data.ItemReference whose result property will be populated with the result of the operation when the server response is received.
	  */          
	public function updateMaps(item:valueObjects.Maps) : mx.data.ItemReference
	{
		var _internal_operation:mx.rpc.AbstractOperation = _serviceControl.getOperation("updateMaps");
		var _internal_token:mx.data.ItemReference = _internal_operation.send(item) as mx.data.ItemReference;

		return _internal_token;
	}   
	 
	/**
	  * This method is a generated wrapper used to call the 'deleteMaps' operation. It returns an mx.rpc.AsyncToken whose 
	  * result property will be populated with the result of the operation when the server response is received. 
	  * To use this result from MXML code, define a CallResponder component and assign its token property to this method's return value. 
	  * You can then bind to CallResponder.lastResult or listen for the CallResponder.result or fault events.
      *
      * @see mx.rpc.AsyncToken
      * @see mx.rpc.CallResponder 
      *
      * @return an mx.rpc.AsyncToken whose result property will be populated with the result of the operation when the server response is received.
	  */          
	public function deleteMaps(itemID:int) : mx.rpc.AsyncToken
	{
		var _internal_operation:mx.rpc.AbstractOperation = _serviceControl.getOperation("deleteMaps");
		var _internal_token:mx.rpc.AsyncToken = _internal_operation.send(itemID) ;

		return _internal_token;
	}   
	 
	/**
	  * This method is a generated wrapper used to call the 'count' operation. It returns an mx.rpc.AsyncToken whose 
	  * result property will be populated with the result of the operation when the server response is received. 
	  * To use this result from MXML code, define a CallResponder component and assign its token property to this method's return value. 
	  * You can then bind to CallResponder.lastResult or listen for the CallResponder.result or fault events.
      *
      * @see mx.rpc.AsyncToken
      * @see mx.rpc.CallResponder 
      *
      * @return an mx.rpc.AsyncToken whose result property will be populated with the result of the operation when the server response is received.
	  */          
	public function count() : mx.rpc.AsyncToken
	{
		var _internal_operation:mx.rpc.AbstractOperation = _serviceControl.getOperation("count");
		var _internal_token:mx.rpc.AsyncToken = _internal_operation.send() ;

		return _internal_token;
	}   
	 
	/**
	  * This method is a generated wrapper used to call the 'getMaps_paged' operation. It returns an mx.rpc.AsyncToken whose 
	  * result property will be populated with the result of the operation when the server response is received. 
	  * To use this result from MXML code, define a CallResponder component and assign its token property to this method's return value. 
	  * You can then bind to CallResponder.lastResult or listen for the CallResponder.result or fault events.
      *
      * @see mx.rpc.AsyncToken
      * @see mx.rpc.CallResponder 
      *
      * @return an mx.rpc.AsyncToken whose result property will be populated with the result of the operation when the server response is received.
	  */          
	public function getMaps_paged() : mx.rpc.AsyncToken
	{
		var _internal_operation:mx.rpc.AbstractOperation = _serviceControl.getOperation("getMaps_paged");
		var _internal_token:mx.rpc.AsyncToken = _internal_operation.send() ;

		return _internal_token;
	}   
	 
}

}
