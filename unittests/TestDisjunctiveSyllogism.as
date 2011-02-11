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
			//No initial setup any more since the functions expect different text.
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
		//Not asserting anything because it's currently pointless
		[Test(order=1)]
		public function testNotPTrue():void{
			djs = new DisjunctiveSyllogism("Basic Claim", ["Reason 1", "Reason 2"], false, "Either Foo or Bar, but maybe both", true);
			trace("~~ The inference is: ", djs.getInference("notP"));
			trace("Printing all reasons in NotPTrue");
			for each (var reason:String in djs.getReason()){
				trace(reason);
			}
			trace("The claim is: ", djs.getClaim());
			
		}
		[Test(order=2)]
		public function testNotPFalse():void{
			djs = new DisjunctiveSyllogism("Basic Claim", ["Reason 1", "Reason 2"], false, "", false);
			trace("~~ The inference is: ", djs.getInference("notP"));
			trace("Printing all reasons in NotPFalse");
			for each (var reason:String in djs.getReason()){
				trace(reason);
			}
			trace("The claim is: ", djs.getClaim());
			
		}
		[Test(order=3)]
		public function testNotQTrue():void{
			djs = new DisjunctiveSyllogism("Basic Claim", ["Reason 1", "Reason 2"], false, "Either Foo or Bar, but maybe both", true);
			trace("~~ The inference is: ", djs.getInference("notQ"));
			trace("Printing all reasons in NotQTrue");
			for each (var reason:String in djs.getReason()){
				trace(reason);
			}
			trace("The claim is: ", djs.getClaim());
		}
		[Test(order=4)]
		public function testNotQFalse():void{
			djs = new DisjunctiveSyllogism("Basic Claim", ["Reason 1", "Reason 2"], false, "", false);
			trace("~~ The inference is: ", djs.getInference("notQ"));
			trace("Printing all reasons in NotQFalse");
			for each (var reason:String in djs.getReason()){
				trace(reason);
			}
			trace("The claim is: ", djs.getClaim());
		}
		[Test(order=5)]
		public function testAlternatePTrue():void{
			djs = new DisjunctiveSyllogism("Basic Claim", ["Reason 1", "Reason 2"], false, "Foo unless Bar, and Baz", true);
			trace("~~ The inference is: ", djs.getInference("alternateP"));
			trace("Printing all reasons in AlternatePTrue");
			for each (var reason:String in djs.getReason()){
				trace(reason);
			}		
			trace("The claim is: ", djs.getClaim());
		}
		[Test(order=6)]
		public function testAlternatePFalse():void{
			djs = new DisjunctiveSyllogism("Basic Claim", ["Reason 1", "Reason 2"], false, "", false);
			trace("~~ The inference is: ", djs.getInference("alternateP"));
			trace("Printing all reasons in AlternatePFalse");
			for each (var reason:String in djs.getReason()){
				trace(reason);
			}		
			trace("The claim is: ", djs.getClaim());
		}
		[Test(order=7)]
		public function testAlternateQTrue():void{
			djs = new DisjunctiveSyllogism("Basic Claim", ["Reason 1", "Reason 2"], false, "Foo unless Bar, and Baz", true);
			trace("~~ The inference is: ", djs.getInference("alternateQ"));
			trace("Printing all reasons in AlternateQTrue");
			for each (var reason:String in djs.getReason()){
				trace(reason);
			}
			trace("The claim is: ", djs.getClaim());
		}
		[Test(order=8)]
		public function testAlternateQFalse():void{
			djs = new DisjunctiveSyllogism("Basic Claim", ["Reason 1", "Reason 2"], false, "Foo unless Bar, and Baz", false);
			trace("~~ The inference is: ", djs.getInference("alternateQ"));
			trace("Printing all reasons in AlternateQFalse");
			for each (var reason:String in djs.getReason()){
				trace(reason);
			}		
			trace("The claim is: ", djs.getClaim());
		}
	}
}