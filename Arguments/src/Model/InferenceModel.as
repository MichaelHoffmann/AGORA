package Model
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	public class InferenceModel extends EventDispatcher
	{
		public function InferenceModel(target:IEventDispatcher=null)
		{
			super(target);
		}
	}
}