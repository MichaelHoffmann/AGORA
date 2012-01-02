package
{
	public class PropNotFoundError extends Error
	{
		public function PropNotFoundError(message:String, errorID:int=0)
		{
			super(message, errorID);
		}
	}
}