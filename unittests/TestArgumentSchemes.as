package unittests
{
	public class TestArgumentSchemes
	{		
		import logic.ArgumentSchemes;
		
		import org.flexunit.Assert;
				
		private var count:int = 0;
		private var argSchemes:ArgumentSchemes;
		[Before]
		public function setUp():void
		{
			argSchemes = new ArgumentSchemes("Basic claim", "Basic Reason".split(""), false, "Basic Inference", true);
		}
		
		[After]
		public function tearDown():void
		{
			count = 0;
		}
		
		[BeforeClass]
		public static function setUpBeforeClass():void
		{
		}
		
		[AfterClass]
		public static function tearDownAfterClass():void
		{
		}
		
		[Test]
		public function testConstructor():void{
			Assert.assertEquals("Basic claim", argSchemes.getClaim());	
		}
	}
}