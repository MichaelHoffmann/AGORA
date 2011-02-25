package unittests
{
	import flexunit.framework.Assert;
	
	import logic.XORSyllogism;
	public class TestXORSyllogism
	{		
		private var xs:XORSyllogism;
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
			trace("Setting up XOR Syllogism testing...");
		}
		
		[AfterClass]
		public static function tearDownAfterClass():void
		{
		}
		
		//Not asserting anything as it's currently pointless.
		[Test(order=1)]
		public function testAlternateQTrue():void
		{
			xs = new XORSyllogism("Basic Claim", ["Reason 1", "Reason 2"], false, "Either Foo or Bar, but not both", true);
			trace("The inference is: ", xs.getInference("alternateQ"));
			trace("~~ Printing all reasons in TestAlternateQTrue");
			for each (var reason:String in xs.getReason()){
				trace(reason);
			}
			trace("The claim is: ", xs.getClaim());
		}
		[Test(order=2)]
		public function testAlternateQFalse():void
		{
			xs = new XORSyllogism("Basic Claim", ["Reason 1", "Reason 2"], false, "", false);
			trace("The inference is: ", xs.getInference("alternateQ"));
			trace("~~ Printing all reasons in TestAlternateQFalse");
			for each (var reason:String in xs.getReason()){
				trace(reason);
			}
			trace("The claim is: ", xs.getClaim());
		}
		
		[Test(order=3)]
		public function testAlternatePTrue():void
		{
			xs = new XORSyllogism("Basic Claim", ["Reason 1", "Reason 2"], false, "Either Foo or Bar, but not both", true);
			trace("The inference is: ", xs.getInference("alternateP"));
			trace("~~ Printing all reasons in TestAlternatePTrue");
			for each (var reason:String in xs.getReason()){
				trace(reason);
			}
			trace("The claim is: ", xs.getClaim());
		}
		[Test(order=4)]
		public function testAlternatePFalse():void
		{
			xs = new XORSyllogism("Basic Claim", ["Reason 1", "Reason 2"], false, "", false);
			trace("The inference is: ", xs.getInference("alternateP"));
			trace("~~ Printing all reasons in TestAlternatePFalse");
			for each (var reason:String in xs.getReason()){
				trace(reason);
			}
			trace("The claim is: ", xs.getClaim());
		}
		[Test(order=5)]
		public function testNotQTrue():void
		{
			xs = new XORSyllogism("Basic Claim", ["Reason 1", "Reason 2"], false, "Either Foo or Bar, but not both", true);
			trace("The inference is: ", xs.getInference("notQ"));
			trace("~~ Printing all reasons in TestNotQTrue");
			for each (var reason:String in xs.getReason()){
				trace(reason);
			}
			trace("The claim is: ", xs.getClaim());
		}
		[Test(order=6)]
		public function testNotQFalse():void
		{
			xs = new XORSyllogism("Basic Claim", ["Reason 1", "Reason 2"], false, "", false);
			trace("The inference is: ", xs.getInference("notQ"));
			trace("~~ Printing all reasons in TestNotQFalse");
			for each (var reason:String in xs.getReason()){
				trace(reason);
			}
			trace("The claim is: ", xs.getClaim());
		}
		
		[Test(order=7)]
		public function testNotPTrue():void
		{
			xs = new XORSyllogism("Basic Claim", ["Reason 1", "Reason 2"], false, "Either Foo or Bar, but not both", true);
			trace("The inference is: ", xs.getInference("notP"));
			trace("~~ Printing all reasons in TestNotPTrue");
			for each (var reason:String in xs.getReason()){
				trace(reason);
			}
			trace("The claim is: ", xs.getClaim());
		}
		[Test(order=8)]
		public function testNotPFalse():void
		{
			xs = new XORSyllogism("Basic Claim", ["Reason 1", "Reason 2"], false, "", false);
			trace("The inference is: ", xs.getInference("notP"));
			trace("~~ Printing all reasons in TestNotPFalse");
			for each (var reason:String in xs.getReason()){
				trace(reason);
			}
			trace("The claim is: ", xs.getClaim());
		}
		
	}
}