package unittests
{
	public class TestDisjunctiveSyllogism
	{		
		import logic.DisjunctiveSyllogism;
		
		import mx.controls.Alert;
		
		import org.flexunit.Assert;
		private var djs:DisjunctiveSyllogism;
		
		[Before]
		public function setUp():void
		{
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
		[Test]
		public function testNotPTrue():void{
			djs.notP(true);
			Assert.assertEquals("It is not the case that Foo", djs.getReason()[0]);
			trace("Printing all reasons in NotPTrue");
			for each (var reason:String in djs.getReason()){
				trace(reason);
			}
		}
		[Test]
		public function testNotPFalse():void{
			djs.notP(false);
			Assert.assertEquals("It is not the case that Reason 1", djs.getReason()[0]);
			trace("Printing all reasons in NotPFalse");
			for each (var reason:String in djs.getReason()){
				trace(reason);
			}
		}
		
	}
}