package ValueObjects
{
	public class ArgumentScheme
	{
		public var scheme:String;
		public var language:String;
		public var aslConnector:String;
		public function ArgumentScheme(scheme:String, language:String)
		{
			this.scheme = scheme;
			this.language = language;
			if(this.language == AGORAParameters.getInstance().ONLY_IF_AND || language == AGORAParameters.getInstance().ONLY_IF_OR){
				this.language = AGORAParameters.getInstance().ONLY_IF;
				aslConnector = language == AGORAParameters.getInstance().ONLY_IF_AND? AGORAParameters.getInstance().AND : AGORAParameters.getInstance().OR; 
			}
		}
	}	
}