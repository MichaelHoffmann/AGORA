package unittests
{
	import flexunit.framework.Assert;
	
	import logic.ModusPonens;
	
	public class TestModusPonens
	{		
		private var mp:ModusPonens;
		[Before]
		public function setUp():void
		{
			//ModusPonens(claimText:String,reasonText:Array,reversePos:Boolean,inferenceText:String="",inferencePresent:Boolean = false)
			mp = new ModusPonens("Basic Claim", ["Reason 1", "Reason 2"], false, "If Foo, then Bar, and Baz implies Quux", false);
		}
		
		[After]
		public function tearDown():void
		{
		}
		
		[BeforeClass]
		public static function setUpBeforeClass():void
		{
			trace("Setting up Modus Ponens testing...");
		}
		
		[AfterClass]
		public static function tearDownAfterClass():void
		{
		}
		//Copied from the superclass tests
		[Test]
		public function testConstructorClaim():void{
			Assert.assertEquals("Basic Claim", mp.getClaim());
		}
		[Test]
		public function testConstructorReason():void{
			Assert.assertEquals("Reason 1", mp.getReason()[0]);
		}
		//New tests for this subclass's particular functions
		//Not asserting anything because it's currently pointless
		[Test(order=1)]
		public function testIfThenTrue():void
		{
			mp.ifThen(true);
			trace("~~ Printing all reasons in testIfThenTrue");
			for each (var reason:String in mp.getReason()){
				trace(reason);
			}
			trace("The claim is: ", mp.getClaim());
			trace("The inference is: ", mp.getInference("ifThen"));
		}
		[Test(order=2)]
		public function testIfThenFalse():void
		{
			mp.ifThen(false);
			trace("~~ Printing all reasons in testIfThenFalse");
			for each (var reason:String in mp.getReason()){
				trace(reason);
			}
			trace("The claim is: ", mp.getClaim());
			trace("The inference is: ", mp.getInference("ifThen"));
		}
		
		[Test]
		public function testImplies():void
		{
			Assert.fail("Test method Not yet implemented");
		}
		
		[Test]
		public function testModusPonens():void
		{
			Assert.fail("Test method Not yet implemented");
		}
		
		[Test]
		public function testNecessaryCondition():void
		{
			Assert.fail("Test method Not yet implemented");
		}
		
		[Test]
		public function testOnlyIf():void
		{
			Assert.fail("Test method Not yet implemented");
		}
		
		[Test]
		public function testProvidedThat():void
		{
			Assert.fail("Test method Not yet implemented");
		}
		
		[Test]
		public function testSufficientCondition():void
		{
			Assert.fail("Test method Not yet implemented");
		}
		
		[Test]
		public function testWhenever():void
		{
			Assert.fail("Test method Not yet implemented");
		}		
	}
}