package unittests
{
	public class TestEquivalence
	{		
		import logic.Equivalence;
		import org.flexunit.Assert;
		
		private var eq:Equivalence;
		private var eqReverse:Equivalence;
		
		[Before]
		public function setUp():void
		{
			trace("Setting up Equivalence testing...");
			//Equivalence(claimText:String,reasonText:Array,reversePos:Boolean,inferenceText:String="",inferencePresent:Boolean = false)
			eqReverse = new Equivalence("Basic Claim", ["Reason 1", "Reason 2"], true, "Either Foo or Bar, and Baz unless Quux", false);
			eq= new Equivalence("Basic Claim", ["Reason 1", "Reason 2"], false, "Either Foo or Bar, and Baz unless Quux", false);
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
			Assert.assertEquals("Basic Claim", eq.getClaim());
		}
		[Test]
		public function testConstructorReason():void{
			Assert.assertEquals("Reason 1", eq.getReason()[0]);
		}
		
	}
}