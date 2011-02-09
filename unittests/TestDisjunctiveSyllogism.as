package unittests
{
	public class TestDisjunctiveSyllogism
	{		
		import logic.DisjunctiveSyllogism;
		import org.flexunit.Assert;
		
		private var djs:DisjunctiveSyllogism;
		private var djsReverse:DisjunctiveSyllogism;
		
		[Before]
		public function setUp():void
		{
			//DisjunctiveSyllogism(claimText:String, reasonText:Array, reversePos:Boolean,inferenceText:String="", inferencePresent:Boolean=false)
			djsReverse = new DisjunctiveSyllogism("Basic Claim", ["Reason 1", "Reason 2"], true, "Either Foo or Bar, and Baz unless Quux", false);
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
			djsReverse.notP(true);
			trace("~~ Printing all reasons in Reverse NotPTrue");
			for each (reason in djsReverse.getReason()){
				trace(reason);
			}
		}
		[Test(order=2)]
		public function testNotPFalse():void{
			djs.notP(false);
			trace("~~ Printing all reasons in NotPFalse");
			for each (var reason:String in djs.getReason()){
				trace(reason);
			}
			djsReverse.notP(false);
			trace("~~ Printing all reasons in Reverse NotPFalse");
			for each (reason in djsReverse.getReason()){
				trace(reason);
			}
		}
		[Test(order=3)]
		public function testNotQTrue():void{
			djs.notQ(true);
			trace("~~ Printing all reasons in NotQTrue");
			for each (var reason:String in djs.getReason()){
				trace(reason);
			}
			djsReverse.notQ(true);
			trace("~~ Printing all reasons in Reverse NotQTrue");
			for each (reason in djsReverse.getReason()){
				trace(reason);
			}
		}
		[Test(order=4)]
		public function testNotQFalse():void{
			djs.notQ(false);
			trace("~~ Printing all reasons in NotQFalse");
			for each (var reason:String in djs.getReason()){
				trace(reason);
			}
			djsReverse.notQ(false);
			trace("~~ Printing all reasons in Reverse NotQFalse");
			for each (reason in djsReverse.getReason()){
				trace(reason);
			}
		}
		[Test(order=5)]
		public function testAlternatePTrue():void{
			djs.alternateP(true);
			trace("~~ Printing all reasons in AlternatePTrue");
			for each (var reason:String in djs.getReason()){
				trace(reason);
			}
			djsReverse.alternateP(true);
			trace("~~ Printing all reasons in Reverse AlternatePTrue");
			for each (reason in djsReverse.getReason()){
				trace(reason);
			}			
		}
		[Test(order=6)]
		public function testAlternatePFalse():void{
			djs.alternateP(false);
			trace("~~ Printing all reasons in AlternatePFalse");
			for each (var reason:String in djs.getReason()){
				trace(reason);
			}
			djsReverse.alternateP(false);
			trace("~~ Printing all reasons in Reverse AlternatePFalse");
			for each (reason in djsReverse.getReason()){
				trace(reason);
			}
		}
		[Test(order=7)]
		public function testAlternateQTrue():void{
			djs.alternateQ(true);
			trace("~~ Printing all reasons in AlternateQTrue");
			for each (var reason:String in djs.getReason()){
				trace(reason);
			}
			djsReverse.alternateQ(true);
			trace("~~ Printing all reasons in Reverse AlternateQTrue");
			for each (reason in djsReverse.getReason()){
				trace(reason);
			}			
		}
		[Test(order=8)]
		public function testAlternateQFalse():void{
			djs.alternateQ(false);
			trace("~~ Printing all reasons in AlternateQFalse");
			for each (var reason:String in djs.getReason()){
				trace(reason);
			}
			djsReverse.alternateQ(false);
			trace("~~ Printing all reasons in Reverse AlternateQFalse");
			for each (reason in djsReverse.getReason()){
				trace(reason);
			}
		}
	}
}