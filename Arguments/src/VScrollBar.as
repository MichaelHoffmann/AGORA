package 
	{
	    import flash.events.MouseEvent;
		     
	    import mx.core.mx_internal;
		     
	    import spark.components.VScrollBar;
	    import spark.core.IViewport;
	     
	    use namespace mx_internal;
	     
	    [Style(name="movementDelta", inherit="yes", type="number", format="length")]
	    public class VScrollBar extends spark.components.VScrollBar
		    {
		        public function VScrollBar()
			        {
			            setStyle("movementDelta", 50);
			        }
			         
		        override mx_internal function mouseWheelHandler(event:MouseEvent):void
			        {
			            var viewport:IViewport = this.viewport;
			            if ( viewport == null || !viewport.visible || event.isDefaultPrevented() )
			                return;
			             
			            var delta:Number = event.delta;
			            var direction:int = (event.delta > 0) ? -1 : (event.delta < 0) ? 1 : 0;
			            var movement:Number = getStyle("movementDelta");
			            viewport.verticalScrollPosition += movement * direction;
			            event.preventDefault();
			        }
			 
			    }
		}