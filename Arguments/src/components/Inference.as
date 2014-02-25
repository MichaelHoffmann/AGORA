package components
{
	
	/**
	 AGORA - an interactive and web-based argument mapping tool that stimulates reasoning, 
	 reflection, critique, deliberation, and creativity in individual argument construction 
	 and in collaborative or adversarial settings. 
	 Copyright (C) 2011 Georgia Institute of Technology
	 
	 This program is free software: you can redistribute it and/or modify
	 it under the terms of the GNU Affero General Public License as
	 published by the Free Software Foundation, either version 3 of the
	 License, or (at your option) any later version.
	 
	 This program is distributed in the hope that it will be useful,
	 but WITHOUT ANY WARRANTY; without even the implied warranty of
	 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	 GNU Affero General Public License for more details.
	 
	 You should have received a copy of the GNU Affero General Public License
	 along with this program.  If not, see <http://www.gnu.org/licenses/>.
	 
	 */
	import Model.InferenceModel;
	import Model.StatementModel;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	import Controller.logic.*;
	
	import mx.binding.utils.BindingUtils;
	import mx.controls.Alert;
	import mx.controls.Label;
	import mx.controls.List;
	import mx.controls.Menu;
	import mx.controls.listClasses.ListData;
	import mx.core.IVisualElement;
	import mx.events.FlexEvent;
	import mx.events.ListEvent;
	import mx.events.MenuEvent;
	import mx.managers.FocusManager;
	import mx.utils.ArrayUtil;
	
	import org.osmf.layout.AbsoluteLayoutFacet;
	
	import spark.components.Button;
	import spark.components.HGroup;
	import spark.components.SkinnableContainer;
	import spark.components.VGroup;
	
	import classes.Configure;
	import classes.Language;
	
	
	//This class is no longer used.
	//This has been merged with ArgumentPanel
	public class Inference extends ArgumentPanel
	{
		
		private var _inferenceModel:InferenceModel;
		//temporary variable for generating temporary permanent ids
		//vgroup
		public var vgroup:VGroup;
		//The statement that is enabled by this enabler and a set of reasons
		public var claim:ArgumentPanel;
		//a reference to the panel that is directly above the Enabler (Inference)
		public var _menuPanel:MenuPanel;
		//The Menu
		public var myschemeSel:ArgSelector;
		//Reference to the specific argument scheme class
		public var myArg:ParentArg;		

		public static var REASON_ADDED:String  = "Reason Added";
		public static var REASON_DELETED:String = "Reason Deleted";
		private var _schemeSelected:Boolean;
		//The string that is displayed
		public var _displayStr:String;

		private var addReasonMenuData:XML;
		
		public function Inference()
		{
			super();
			addReasonMenuData = <root><menuitem   label = "... another reason for this argument so that only the combination of all reasons justifies the claim" /></root>;
	
			this.setStyle("cornerRadius",30);	
			//schemeSelected = false;
		}
		
		
		//--------- Getters and Setters -------------------//
		
		public function get inferenceModel():InferenceModel
		{
			return _inferenceModel;
		}

		public function set inferenceModel(value:InferenceModel):void
		{
			_inferenceModel = value;
		}

		public function get displayStr():String
		{
			return _displayStr;
		}
		
		public function set displayStr(value:String):void
		{
			_displayStr = value;
			displayTxt.text = _displayStr;
			invalidateProperties();
			invalidateSize();
			invalidateDisplayList();
		}
	}
}
