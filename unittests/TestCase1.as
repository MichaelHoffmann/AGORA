package unittests
{
	public class TestCase1
	{		
		private var count:int = 0;
		import org.flexunit.Assert;
		[Before]
		public function setUp():void
		{
			count = 10;
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
		public function subtraction():void { 
			Assert.assertEquals(8, count-2);
		}
		
	}
}