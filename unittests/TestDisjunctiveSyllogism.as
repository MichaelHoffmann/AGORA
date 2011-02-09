package unittests
{
	public class TestDisjunctiveSyllogism
	{		
		import logic.DisjunctiveSyllogism;
		import org.flexunit.Assert;
		
		private var djs:DisjunctiveSyllogism;
		
		[Before]
		public function setUp():void
		{
			//DisjunctiveSyllogism(claimText:String, reasonText:Array, reversePos:Boolean,inferenceText:String="", inferencePresent:Boolean=false)
			djs = new DisjunctiveSyllogism("Basic Claim", ["Reason 1", "Reason 2"], false, "Either Foo or Bar, and Baz unless Quux", false);
		}
		
		[After]
		public function tearDown():void
		{
		}
		
		[BeforeClass]
		public static function setUpBeforeClass():void
		{
			trace("Setting up Disjunctive Syllogism testing...");
		}
		
		[AfterClass]
		public static function tearDownAfterClass():void
		{
		}
		//Copied from the superclass tests
		[Test]
		public function testConstructorClaim():void{
			Assert.assertEquals("Basic Claim", djs.getClaim());
		}
		[Test]
		public function testConstructorReason():void{
			Assert.assertEquals("Reason 1", djs.getReason()[0]);
		}
		//New tests for this subclass's particular functions
		//Not asserting anything because it's currently pointless
		[Test(order=1)]
		public function testNotPTrue():void{
			djs.notP(true);
			trace("~~ Printing all reasons in NotPTrue");
			for each (var reason:String in djs.getReason()){
				trace(reason);
			}
			trace("The claim is: ", djs.getClaim());
			trace("The inference is: ", djs.getInference("notP"));
		}
		[Test(order=2)]
		public function testNotPFalse():void{
			djs.notP(false);
			trace("~~ Printing all reasons in NotPFalse");
			for each (var reason:String in djs.getReason()){
				trace(reason);
			}
			trace("The claim is: ", djs.getClaim());
			trace("The inference is: ", djs.getInference("notP"));
		}
		[Test(order=3)]
		public function testNotQTrue():void{
			djs.notQ(true);
			trace("~~ Printing all reasons in NotQTrue");
			for each (var reason:String in djs.getReason()){
				trace(reason);
			}
			trace("The claim is: ", djs.getClaim());
			trace("The inference is: ", djs.getInference("notQ"));
		}
		[Test(order=4)]
		public function testNotQFalse():void{
			djs.notQ(false);
			trace("~~ Printing all reasons in NotQFalse");
			for each (var reason:String in djs.getReason()){
				trace(reason);
			}
			trace("The claim is: ", djs.getClaim());
			trace("The inference is: ", djs.getInference("notQ"));
		}
		[Test(order=5)]
		public function testAlternatePTrue():void{
			djs.alternateP(true);
			trace("~~ Printing all reasons in AlternatePTrue");
			for each (var reason:String in djs.getReason()){
				trace(reason);
			}		
			trace("The claim is: ", djs.getClaim());
			trace("The inference is: ", djs.getInference("alternateP"));
		}
		[Test(order=6)]
		public function testAlternatePFalse():void{
			djs.alternateP(false);
			trace("~~ Printing all reasons in AlternatePFalse");
			for each (var reason:String in djs.getReason()){
				trace(reason);
			}		
			trace("The claim is: ", djs.getClaim());
			trace("The inference is: ", djs.getInference("alternateP"));
		}
		[Test(order=7)]
		public function testAlternateQTrue():void{
			djs.alternateQ(true);
			trace("~~ Printing all reasons in AlternateQTrue");
			for each (var reason:String in djs.getReason()){
				trace(reason);
			}
			trace("The claim is: ", djs.getClaim());
			trace("The inference is: ", djs.getInference("alternateQ"));
		}
		[Test(order=8)]
		public function testAlternateQFalse():void{
			djs.alternateQ(false);
			trace("~~ Printing all reasons in AlternateQFalse");
			for each (var reason:String in djs.getReason()){
				trace(reason);
			}		
			trace("The claim is: ", djs.getClaim());
			trace("The inference is: ", djs.getInference("alternateQ"));
		}
	}
}