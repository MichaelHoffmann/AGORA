package components
{
		import mx.formatters.DateFormatter;
		
		public class AgoradateFormatter extends DateFormatter
		{
			public function AgoradateFormatter()
			{
				super();
			}
			
			public function parseDate(str:String):Date
			{
				return parseDateString(str);
			}       
		}
}