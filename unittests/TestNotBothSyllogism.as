package unittests
{
	import flexunit.framework.Assert;
	
	import logic.NotBothSyllogism;
	
	public class TestNotBothSyllogism
	{		
		private var nbs:NotBothSyllogism;
		[Before]
		public function setUp():void
		{
		}
		
		[After]
		public function tearDown():void
		{
		}
		
		[BeforeClass]
		public static function setUpBeforeClass():void
		{
			trace("Setting up Not Both Syllogism testing...");
		}
		
		[AfterClass]
		public static function tearDownAfterClass():void
		{
		}
		[Test(order=1)]
		public function TestNotPTrue():void{
			nbs = new NotBothSyllogism("Basic Claim", ["Reason 1", "Reason 2"], false, "Not both Foo and Bar", false);
			nbs.notP(true);
			trace("~~ Printing all reasons in TestNotPTrue");
			for each (var reason:String in nbs.getReason()){
				trace(reason);
			}
			trace("The claim is: ", nbs.getClaim());
			trace("The inference is: ", nbs.getInference("notP"));
		}
		[Test(order=2)]
		public function TestNotPFalse():void{
			nbs = new NotBothSyllogism("Basic Claim", ["Reason 1", "Reason 2"], false, "Not both Foo and Bar", false);
			nbs.notP(false);
			trace("~~ Printing all reasons in TestNotPFalse");
			for each (var reason:String in nbs.getReason()){
				trace(reason);
			}
			trace("The claim is: ", nbs.getClaim());
			trace("The inference is: ", nbs.getInference("notP"));
		}
		
		[Test(order=3)]
		public function TestNotQTrue():void{
			nbs = new NotBothSyllogism("Basic Claim", ["Reason 1", "Reason 2"], false, "Not both Foo and Bar", false);
			nbs.notQ(true);
			trace("~~ Printing all reasons in TestNotQTrue");
			for each (var reason:String in nbs.getReason()){
				trace(reason);
			}
			trace("The claim is: ", nbs.getClaim());
			trace("The inference is: ", nbs.getInference("notQ"));
		}
		[Test(order=4)]
		public function TestNotQFalse():void{
			nbs = new NotBothSyllogism("Basic Claim", ["Reason 1", "Reason 2"], false, "Not both Foo and Bar", false);
			nbs.notQ(false);
			trace("~~ Printing all reasons in TestNotQFalse");
			for each (var reason:String in nbs.getReason()){
				trace(reason);
			}
			trace("The claim is: ", nbs.getClaim());
			trace("The inference is: ", nbs.getInference("notQ"));
		}
	}
}