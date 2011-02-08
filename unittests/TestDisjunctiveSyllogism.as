package unittests
{
	public class TestDisjunctiveSyllogism
	{		
		import logic.DisjunctiveSyllogism;
		
		import mx.controls.Alert;
		
		import org.flexunit.Assert;
		private var djs:DisjunctiveSyllogism;
		private var djsReverse:DisjunctiveSyllogism;
		
		[Before]
		public function setUp():void
		{
			/*
			* reversePos apparently differentiates between Basic Claim and Reason 1.
			* ~~ Printing all reasons in NotPFalse
			* It is not the case that Reason 1
			* Reason 2
			* ~~ Printing all reasons in Reverse NotPFalse
			* It is not the case that Basic Claim
			* Reason 2
			*/
			//DisjunctiveSyllogism(claimText:String, reasonText:Array, reversePos:Boolean,inferenceText:String="", inferencePresent:Boolean=false)
			djsReverse = new DisjunctiveSyllogism("Basic Claim", ["Reason 1", "Reason 2"], true, "Either Foo or Bar, and Baz", false);
			djs = new DisjunctiveSyllogism("Basic Claim", ["Reason 1", "Reason 2"], false, "Either Foo or Bar, and Baz", false);
		}
		
		[After]
		public function tearDown():void
		{
		}
		
		[BeforeClass]
		public static function setUpBeforeClass():void
		{
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
		[Test]
		public function testNotPTrue():void{
			djs.notP(true);
			trace("Printing all reasons in NotPTrue");
			for each (var reason:String in djs.getReason()){
				trace(reason);
			}
			djsReverse.notP(true);
			trace("~~ Printing all reasons in Reverse NotPTrue");
			for each (reason in djsReverse.getReason()){
				trace(reason);
			}
		}
		[Test]
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
		[Test]
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
		[Test]
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
		[Test]
		public function testAlternatePTrue():void{
			djs.notQ(true);
			trace("~~ Printing all reasons in AlternatePTrue");
			for each (var reason:String in djs.getReason()){
				trace(reason);
			}
			djsReverse.notQ(true);
			trace("~~ Printing all reasons in Reverse AlternatePTrue");
			for each (reason in djsReverse.getReason()){
				trace(reason);
			}			
		}
		[Test]
		public function testAlternatePFalse():void{
			djs.notQ(false);
			trace("~~ Printing all reasons in AlternatePFalse");
			for each (var reason:String in djs.getReason()){
				trace(reason);
			}
			djsReverse.notQ(false);
			trace("~~ Printing all reasons in Reverse AlternatePFalse");
			for each (reason in djsReverse.getReason()){
				trace(reason);
			}
		}
		
	}
}