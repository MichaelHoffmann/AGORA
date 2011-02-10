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
			mt = new ModusTollens("Basic Claim", ["Reason 1", "Reason 2"], false, "If Foo, then Bar, and Baz", false);
			mt.ifThen(true);
			trace("~~ Printing all reasons in testIfThenTrue");
			for each (var reason:String in mt.getReason()){
				trace(reason);
			}
			trace("The claim is: ", mt.getClaim());
			trace("The inference is: ", mt.getInference("ifThen"));
		}
		[Test(order=2)]
		public function testIfThenFalse():void
		{
			mt = new ModusTollens("Basic Claim", ["Reason 1", "Reason 2"], false, "If Foo, then Bar, and Baz", false);
			mt.ifThen(false);
			trace("~~ Printing all reasons in testIfThenFalse");
			for each (var reason:String in mt.getReason()){
				trace(reason);
			}
			trace("The claim is: ", mt.getClaim());
			trace("The inference is: ", mt.getInference("ifThen"));
		}
		
		[Test(order=3)]
		public function testImpliesTrue():void
		{
			mt = new ModusTollens("Basic Claim", ["Reason 1", "Reason 2"], false, "Foo implies Bar, and Baz", false);
			mt.implies(true);
			trace("~~ Printing all reasons in testImpliesTrue");
			for each (var reason:String in mt.getReason()){
				trace(reason);
			}
			trace("The claim is: ", mt.getClaim());
			trace("The inference is: ", mt.getInference("implies"));
		}
		[Test(order=4)]
		public function testImpliesFalse():void
		{
			mt = new ModusTollens("Basic Claim", ["Reason 1", "Reason 2"], false, "Foo implies Bar, and Baz", false);
			mt.implies(false);
			trace("~~ Printing all reasons in testImpliesFalse");
			for each (var reason:String in mt.getReason()){
				trace(reason);
			}
			trace("The claim is: ", mt.getClaim());
			trace("The inference is: ", mt.getInference("implies"));
		}
		
		[Test(order=5)]
		public function testWheneverTrue():void
		{
			mt = new ModusTollens("Basic Claim", ["Reason 1", "Reason 2"], false, "Whenever Foo, Bar, and Baz", false);
			mt.whenever(true);
			trace("~~ Printing all reasons in testWheneverTrue");
			for each (var reason:String in mt.getReason()){
				trace(reason);
			}
			trace("The claim is: ", mt.getClaim());
			trace("The inference is: ", mt.getInference("whenever"));			
		}		
		[Test(order=6)]
		public function testWheneverFalse():void
		{
			mt = new ModusTollens("Basic Claim", ["Reason 1", "Reason 2"], false, "Whenever Foo, Bar, and Baz", false);
			mt.whenever(false);
			trace("~~ Printing all reasons in testWheneverFalse");
			for each (var reason:String in mt.getReason()){
				trace(reason);
			}
			trace("The claim is: ", mt.getClaim());
			trace("The inference is: ", mt.getInference("whenever"));			
		}
		
		[Test(order=7)]
		public function testProvidedThatTrue():void
		{
			mt = new ModusTollens("Basic Claim", ["Reason 1", "Reason 2"], false, "Foo provided that Bar, and Baz", false);			
			mt.providedThat(true);
			trace("~~ Printing all reasons in testProvidedThatTrue");
			for each (var reason:String in mt.getReason()){
				trace(reason);
			}
			trace("The claim is: ", mt.getClaim());
			trace("The inference is: ", mt.getInference("providedThat"));		
		}
		[Test(order=8)]
		public function testProvidedThatFalse():void
		{
			mt = new ModusTollens("Basic Claim", ["Reason 1", "Reason 2"], false, "Foo provided that Bar, and Baz", false);	
			mt.providedThat(false);
			trace("~~ Printing all reasons in testProvidedThatFalse");
			for each (var reason:String in mt.getReason()){
				trace(reason);
			}
			trace("The claim is: ", mt.getClaim());
			trace("The inference is: ", mt.getInference("providedThat"));		
		}
		
		[Test(order=9)]
		public function testOnlyIfTrue():void
		{
			mt = new ModusTollens("Basic Claim", ["Reason 1", "Reason 2"], false, "Foo only if Bar, and Baz", false);	
			mt.onlyIf(true);
			trace("~~ Printing all reasons in testOnlyIfTrue");
			for each (var reason:String in mt.getReason()){
				trace(reason);
			}
			trace("The claim is: ", mt.getClaim());
			trace("The inference is: ", mt.getInference("onlyIf"));		
		}
		[Test(order=10)]
		public function testOnlyIfFalse():void
		{
			mt = new ModusTollens("Basic Claim", ["Reason 1", "Reason 2"], false, "Foo only if Bar, and Baz", false);
			mt.onlyIf(true);
			trace("~~ Printing all reasons in testOnlyIfFalse");
			for each (var reason:String in mt.getReason()){
				trace(reason);
			}
			trace("The claim is: ", mt.getClaim());
			trace("The inference is: ", mt.getInference("onlyIf"));		
		}
		
		[Test(order=11)]
		public function testSufficientConditionTrue():void
		{
			mt = new ModusTollens("Basic Claim", ["Reason 1", "Reason 2"], false, 
				"Foo is a sufficient condition for Bar, and Baz", false);
			mt.sufficientCondition(true);
			trace("~~ Printing all reasons in testSufficientConditionTrue");
			for each (var reason:String in mt.getReason()){
				trace(reason);
			}
			trace("The claim is: ", mt.getClaim());
			trace("The inference is: ", mt.getInference("sufficientCondition"));	
		}
		[Test(order=12)]
		public function testSufficientConditionFalse():void
		{
			mt = new ModusTollens("Basic Claim", ["Reason 1", "Reason 2"], false, 
				"Foo is a sufficient condition for Bar, and Baz", false);
			mt.sufficientCondition(true);
			trace("~~ Printing all reasons in testSufficientConditionFalse");
			for each (var reason:String in mt.getReason()){
				trace(reason);
			}
			trace("The claim is: ", mt.getClaim());
			trace("The inference is: ", mt.getInference("sufficientCondition"));	
		}
		
		[Test(order=13)]
		public function testNecessaryConditionTrue():void
		{
			mt = new ModusTollens("Basic Claim", ["Reason 1", "Reason 2"], false, 
				"Foo is a necessary condition for Bar, and Baz", false);
			mt.necessaryCondition(true);
			trace("~~ Printing all reasons in testNecessaryConditionTrue");
			for each (var reason:String in mt.getReason()){
				trace(reason);
			}
			trace("The claim is: ", mt.getClaim());
			trace("The inference is: ", mt.getInference("necessaryCondition"));	
		}
		[Test(order=14)]
		public function testNecessaryConditionFalse():void
		{
			mt = new ModusTollens("Basic Claim", ["Reason 1", "Reason 2"], false, 
				"Foo is a necessary condition for Bar, and Baz", false);
			mt.necessaryCondition(true);
			trace("~~ Printing all reasons in testNecessaryConditionFalse");
			for each (var reason:String in mt.getReason()){
				trace(reason);
			}
			trace("The claim is: ", mt.getClaim());
			trace("The inference is: ", mt.getInference("necessaryCondition"));	
		}
		
	}
}