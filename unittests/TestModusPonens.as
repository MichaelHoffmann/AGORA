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
			mp = new ModusPonens("Basic Claim", ["Reason 1", "Reason 2"], false, 
				"If Foo, then Bar is a sufficient condition for Baz provided Quux, and Flarp implies Bletch only if Snork", false);
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
		
		[Test(order=3)]
		public function testImpliesTrue():void
		{
			mp.implies(true);
			trace("~~ Printing all reasons in testImpliesTrue");
			for each (var reason:String in mp.getReason()){
				trace(reason);
			}
			trace("The claim is: ", mp.getClaim());
			trace("The inference is: ", mp.getInference("implies"));
		}
		[Test(order=4)]
		public function testImpliesFalse():void
		{
			mp.implies(false);
			trace("~~ Printing all reasons in testImpliesFalse");
			for each (var reason:String in mp.getReason()){
				trace(reason);
			}
			trace("The claim is: ", mp.getClaim());
			trace("The inference is: ", mp.getInference("implies"));
		}
		
		[Test(order=5)]
		public function testWheneverTrue():void
		{
			mp.whenever(true);
			trace("~~ Printing all reasons in testWheneverTrue");
			for each (var reason:String in mp.getReason()){
				trace(reason);
			}
			trace("The claim is: ", mp.getClaim());
			trace("The inference is: ", mp.getInference("whenever"));			
		}		
		[Test(order=6)]
		public function testWheneverFalse():void
		{
			mp.whenever(false);
			trace("~~ Printing all reasons in testWheneverFalse");
			for each (var reason:String in mp.getReason()){
				trace(reason);
			}
			trace("The claim is: ", mp.getClaim());
			trace("The inference is: ", mp.getInference("whenever"));			
		}
		
		[Test(order=7)]
		public function testProvidedThatTrue():void
		{
			mp.providedThat(true);
			trace("~~ Printing all reasons in testProvidedThatTrue");
			for each (var reason:String in mp.getReason()){
				trace(reason);
			}
			trace("The claim is: ", mp.getClaim());
			trace("The inference is: ", mp.getInference("providedThat"));		
		}
		[Test(order=8)]
		public function testProvidedThatFalse():void
		{
			mp.providedThat(false);
			trace("~~ Printing all reasons in testProvidedThatFalse");
			for each (var reason:String in mp.getReason()){
				trace(reason);
			}
			trace("The claim is: ", mp.getClaim());
			trace("The inference is: ", mp.getInference("providedThat"));		
		}
		
		[Test(order=9)]
		public function testOnlyIfTrue():void
		{
			mp.onlyIf(true);
			trace("~~ Printing all reasons in testOnlyIfTrue");
			for each (var reason:String in mp.getReason()){
				trace(reason);
			}
			trace("The claim is: ", mp.getClaim());
			trace("The inference is: ", mp.getInference("onlyIf"));		
		}
		[Test(order=10)]
		public function testOnlyIfFalse():void
		{
			mp.onlyIf(true);
			trace("~~ Printing all reasons in testOnlyIfFalse");
			for each (var reason:String in mp.getReason()){
				trace(reason);
			}
			trace("The claim is: ", mp.getClaim());
			trace("The inference is: ", mp.getInference("onlyIf"));		
		}
		
		[Test(order=11)]
		public function testSufficientConditionTrue():void
		{
			mp.sufficientCondition(true);
			trace("~~ Printing all reasons in testSufficientConditionTrue");
			for each (var reason:String in mp.getReason()){
				trace(reason);
			}
			trace("The claim is: ", mp.getClaim());
			trace("The inference is: ", mp.getInference("sufficientCondition"));	
		}
		[Test(order=12)]
		public function testSufficientConditionFalse():void
		{
			mp.sufficientCondition(true);
			trace("~~ Printing all reasons in testSufficientConditionFalse");
			for each (var reason:String in mp.getReason()){
				trace(reason);
			}
			trace("The claim is: ", mp.getClaim());
			trace("The inference is: ", mp.getInference("sufficientCondition"));	
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
		
	}
}