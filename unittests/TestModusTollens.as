package unittests
{
	import flexunit.framework.Assert;
	
	import logic.ModusTollens;
	
	public class TestModusTollens
	{		
		private var mt:ModusTollens;
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
			trace("Setting up Modus Tollens testing...");
		}
		
		[AfterClass]
		public static function tearDownAfterClass():void
		{
		}
		
		//Not asserting anything because it's currently pointless
		[Test(order=1)]
		public function testIfThenTrue():void
		{
			//ModusTollens(claimText:String,reasonText:Array,reversePos:Boolean,inferenceText:String="",inferencePresent:Boolean = false)
			mt = new ModusTollens("Basic Claim", ["Reason 1", "Reason 2"], false, "If Foo, then Bar, and Baz", true);
			trace("The inference is: ", mt.getInference("ifThen"));
			trace("~~ Printing all reasons in testIfThenTrue");
			for each (var reason:String in mt.getReason()){
				trace(reason);
			}
			trace("The claim is: ", mt.getClaim());
		}
		[Test(order=2)]
		public function testIfThenFalse():void
		{
			mt = new ModusTollens("Basic Claim", ["Reason 1", "Reason 2"], false, "", false);
			trace("The inference is: ", mt.getInference("ifThen"));
			trace("~~ Printing all reasons in testIfThenFalse");
			for each (var reason:String in mt.getReason()){
				trace(reason);
			}
			trace("The claim is: ", mt.getClaim());
		}
		
		[Test(order=3)]
		public function testImpliesTrue():void
		{
			mt = new ModusTollens("Basic Claim", ["Reason 1", "Reason 2"], false, "Foo implies Bar, and Baz", true);
			trace("The inference is: ", mt.getInference("implies"));
			trace("~~ Printing all reasons in testImpliesTrue");
			for each (var reason:String in mt.getReason()){
				trace(reason);
			}
			trace("The claim is: ", mt.getClaim());
		}
		[Test(order=4)]
		public function testImpliesFalse():void
		{
			mt = new ModusTollens("Basic Claim", ["Reason 1", "Reason 2"], false, "", false);
			trace("The inference is: ", mt.getInference("implies"));
			trace("~~ Printing all reasons in testImpliesFalse");
			for each (var reason:String in mt.getReason()){
				trace(reason);
			}
			trace("The claim is: ", mt.getClaim());
		}
		
		[Test(order=5)]
		public function testWheneverTrue():void
		{
			mt = new ModusTollens("Basic Claim", ["Reason 1", "Reason 2"], false, "Whenever Foo, Bar, and Baz", true);
			trace("The inference is: ", mt.getInference("whenever"));		
			trace("~~ Printing all reasons in testWheneverTrue");
			for each (var reason:String in mt.getReason()){
				trace(reason);
			}
			trace("The claim is: ", mt.getClaim());	
		}		
		[Test(order=6)]
		public function testWheneverFalse():void
		{
			mt = new ModusTollens("Basic Claim", ["Reason 1", "Reason 2"], false, "", false);
			trace("The inference is: ", mt.getInference("whenever"));			
			trace("~~ Printing all reasons in testWheneverFalse");
			for each (var reason:String in mt.getReason()){
				trace(reason);
			}
			trace("The claim is: ", mt.getClaim());
		}
		
		[Test(order=7)]
		public function testProvidedThatTrue():void
		{
			mt = new ModusTollens("Basic Claim", ["Reason 1", "Reason 2"], false, "Foo provided that Bar, and Baz", true);
			trace("The inference is: ", mt.getInference("providedThat"));		
			trace("~~ Printing all reasons in testProvidedThatTrue");
			for each (var reason:String in mt.getReason()){
				trace(reason);
			}
			trace("The claim is: ", mt.getClaim());
		}
		[Test(order=8)]
		public function testProvidedThatFalse():void
		{
			mt = new ModusTollens("Basic Claim", ["Reason 1", "Reason 2"], false, "", false);	
			trace("The inference is: ", mt.getInference("providedThat"));	
			trace("~~ Printing all reasons in testProvidedThatFalse");
			for each (var reason:String in mt.getReason()){
				trace(reason);
			}
			trace("The claim is: ", mt.getClaim());	
		}
		
		[Test(order=9)]
		public function testOnlyIfTrue():void
		{
			mt = new ModusTollens("Basic Claim", ["Reason 1", "Reason 2"], false, "Foo only if Bar, and Baz", true);	
			trace("The inference is: ", mt.getInference("onlyIf"));		
			trace("~~ Printing all reasons in testOnlyIfTrue");
			for each (var reason:String in mt.getReason()){
				trace(reason);
			}
			trace("The claim is: ", mt.getClaim());
		}
		[Test(order=10)]
		public function testOnlyIfFalse():void
		{
			mt = new ModusTollens("Basic Claim", ["Reason 1", "Reason 2"], false, "", false);
			trace("The inference is: ", mt.getInference("onlyIf"));		
			trace("~~ Printing all reasons in testOnlyIfFalse");
			for each (var reason:String in mt.getReason()){
				trace(reason);
			}
			trace("The claim is: ", mt.getClaim());
		}
		
		[Test(order=11)]
		public function testSufficientConditionTrue():void
		{
			mt = new ModusTollens("Basic Claim", ["Reason 1", "Reason 2"], false, 
				"Foo is a sufficient condition for Bar, and Baz", true);
			trace("The inference is: ", mt.getInference("sufficientCondition"));	
			trace("~~ Printing all reasons in testSufficientConditionTrue");
			for each (var reason:String in mt.getReason()){
				trace(reason);
			}
			trace("The claim is: ", mt.getClaim());
		}
		[Test(order=12)]
		public function testSufficientConditionFalse():void
		{
			mt = new ModusTollens("Basic Claim", ["Reason 1", "Reason 2"], false, "", false);
			trace("The inference is: ", mt.getInference("sufficientCondition"));
			trace("~~ Printing all reasons in testSufficientConditionFalse");
			for each (var reason:String in mt.getReason()){
				trace(reason);
			}
			trace("The claim is: ", mt.getClaim());
		}
		
		[Test(order=13)]
		public function testNecessaryConditionTrue():void
		{
			mt = new ModusTollens("Basic Claim", ["Reason 1", "Reason 2"], false, 
				"Foo is a necessary condition for Bar, and Baz", true);
			trace("The inference is: ", mt.getInference("necessaryCondition"));	
			trace("~~ Printing all reasons in testNecessaryConditionTrue");
			for each (var reason:String in mt.getReason()){
				trace(reason);
			}
			trace("The claim is: ", mt.getClaim());
		}
		[Test(order=14)]
		public function testNecessaryConditionFalse():void
		{
			mt = new ModusTollens("Basic Claim", ["Reason 1", "Reason 2"], false, "", false);
			trace("The inference is: ", mt.getInference("necessaryCondition"));	
			trace("~~ Printing all reasons in testNecessaryConditionFalse");
			for each (var reason:String in mt.getReason()){
				trace(reason);
			}
			trace("The claim is: ", mt.getClaim());
		}
		
	}
}