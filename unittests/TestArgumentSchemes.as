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
			argSchemes = new ArgumentSchemes("Basic Claim", "Basic Reason".split(""), false, "Basic Inference", true);
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
		public function testConstructorClaim():void{
			Assert.assertEquals("Basic Claim", argSchemes.getClaim());
		}
		[Test]
		public function testConstructorReason():void{
			Assert.assertEquals("Basic Reason".split("").toString(), argSchemes.getReason().toString());
		}
		[Test]
		public function testConstructorInference():void{
			//Don't test this until we know what to use in args to getInference(selectFunction:String)
			//Assert.assertEquals("Basic Inference", argSchemes.getInference(""));
		}
	}
}