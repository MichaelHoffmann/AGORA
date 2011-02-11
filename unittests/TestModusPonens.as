package unittests
{
	import flexunit.framework.Assert;
	
	import logic.ModusPonens;
	
	public class TestModusPonens
	{		
		private var mp:ModusPonens;
		[Before]
		public function setUp():void
		{
			//The functions are too various to use the same one over and over.
		}
		
		[After]
		public function tearDown():void
		{
		}
		
		[BeforeClass]
		public static function setUpBeforeClass():void
		{
			trace("Setting up Modus Ponens testing...");
		}
		[AfterClass]
		public static function tearDownAfterClass():void
		{
		}

		//Not asserting anything because it's currently pointless
		[Test(order=1)]
		public function testIfThenTrue():void
		{
			//ModusPonens(claimText:String,reasonText:Array,reversePos:Boolean,inferenceText:String="",inferencePresent:Boolean = false)
			mp = new ModusPonens("Basic Claim", ["Reason 1", "Reason 2"], false, "If Foo, then Bar, and Baz", true);
			trace("The inference is: ", mp.getInference("ifThen"));
			trace("~~ Printing all reasons in testIfThenTrue");
			for each (var reason:String in mp.getReason()){
				trace(reason);
			}
			trace("The claim is: ", mp.getClaim());
		}
		[Test(order=2)]
		public function testIfThenFalse():void
		{
			mp = new ModusPonens("Basic Claim", ["Reason 1", "Reason 2"], false, "", false);
			trace("The inference is: ", mp.getInference("ifThen"));
			trace("~~ Printing all reasons in testIfThenFalse");
			for each (var reason:String in mp.getReason()){
				trace(reason);
			}
			trace("The claim is: ", mp.getClaim());
		}
		
		[Test(order=3)]
		public function testImpliesTrue():void
		{
			mp = new ModusPonens("Basic Claim", ["Reason 1", "Reason 2"], false, "Foo implies Bar, and Baz", true);
			trace("The inference is: ", mp.getInference("implies"));
			trace("~~ Printing all reasons in testImpliesTrue");
			for each (var reason:String in mp.getReason()){
				trace(reason);
			}
			trace("The claim is: ", mp.getClaim());
		}
		[Test(order=4)]
		public function testImpliesFalse():void
		{
			mp = new ModusPonens("Basic Claim", ["Reason 1", "Reason 2"], false, "", false);
			trace("The inference is: ", mp.getInference("implies"));
			trace("~~ Printing all reasons in testImpliesFalse");
			for each (var reason:String in mp.getReason()){
				trace(reason);
			}
			trace("The claim is: ", mp.getClaim());
		}
		
		[Test(order=5)]
		public function testWheneverTrue():void
		{
			mp = new ModusPonens("Basic Claim", ["Reason 1", "Reason 2"], false, "Whenever Foo, Bar, and Baz", true);
			trace("The inference is: ", mp.getInference("whenever"));
			trace("~~ Printing all reasons in testWheneverTrue");
			for each (var reason:String in mp.getReason()){
				trace(reason);
			}
			trace("The claim is: ", mp.getClaim());
		}		
		[Test(order=6)]
		public function testWheneverFalse():void
		{
			mp = new ModusPonens("Basic Claim", ["Reason 1", "Reason 2"], false, "", false);
			trace("The inference is: ", mp.getInference("whenever"));
			trace("~~ Printing all reasons in testWheneverFalse");
			for each (var reason:String in mp.getReason()){
				trace(reason);
			}
			trace("The claim is: ", mp.getClaim());
		}
		
		[Test(order=7)]
		public function testProvidedThatTrue():void
		{
			mp = new ModusPonens("Basic Claim", ["Reason 1", "Reason 2"], false, "Foo provided that Bar, and Baz", true);			
			trace("The inference is: ", mp.getInference("providedThat"));
			trace("~~ Printing all reasons in testProvidedThatTrue");
			for each (var reason:String in mp.getReason()){
				trace(reason);
			}
			trace("The claim is: ", mp.getClaim());
		}
		[Test(order=8)]
		public function testProvidedThatFalse():void
		{
			mp = new ModusPonens("Basic Claim", ["Reason 1", "Reason 2"], false, "", false);	
			trace("The inference is: ", mp.getInference("providedThat"));
			trace("~~ Printing all reasons in testProvidedThatFalse");
			for each (var reason:String in mp.getReason()){
				trace(reason);
			}
			trace("The claim is: ", mp.getClaim());		
		}
		
		[Test(order=9)]
		public function testOnlyIfTrue():void
		{
			mp = new ModusPonens("Basic Claim", ["Reason 1", "Reason 2"], false, "Foo only if Bar, and Baz", true);	
			trace("The inference is: ", mp.getInference("onlyIf"));
			trace("~~ Printing all reasons in testOnlyIfTrue");
			for each (var reason:String in mp.getReason()){
				trace(reason);
			}
			trace("The claim is: ", mp.getClaim());
		}
		[Test(order=10)]
		public function testOnlyIfFalse():void
		{
			mp = new ModusPonens("Basic Claim", ["Reason 1", "Reason 2"], false, "", false);
			trace("The inference is: ", mp.getInference("onlyIf"));
			trace("~~ Printing all reasons in testOnlyIfFalse");
			for each (var reason:String in mp.getReason()){
				trace(reason);
			}
			trace("The claim is: ", mp.getClaim());
		}
		
		[Test(order=11)]
		public function testSufficientConditionTrue():void
		{
			mp = new ModusPonens("Basic Claim", ["Reason 1", "Reason 2"], false, 
				"Foo is a sufficient condition for Bar, and Baz", true);
			trace("The inference is: ", mp.getInference("sufficientCondition"));
			trace("~~ Printing all reasons in testSufficientConditionTrue");
			for each (var reason:String in mp.getReason()){
				trace(reason);
			}
			trace("The claim is: ", mp.getClaim());
		}
		[Test(order=12)]
		public function testSufficientConditionFalse():void
		{
			mp = new ModusPonens("Basic Claim", ["Reason 1", "Reason 2"], false, "", false);
			trace("The inference is: ", mp.getInference("sufficientCondition"));
			trace("~~ Printing all reasons in testSufficientConditionFalse");
			for each (var reason:String in mp.getReason()){
				trace(reason);
			}
			trace("The claim is: ", mp.getClaim());
		}
		
		[Test(order=13)]
		public function testNecessaryConditionTrue():void
		{
			mp = new ModusPonens("Basic Claim", ["Reason 1", "Reason 2"], false, 
				"Foo is a necessary condition for Bar, and Baz", true);
			trace("The inference is: ", mp.getInference("necessaryCondition"));	
			trace("~~ Printing all reasons in testNecessaryConditionTrue");
			for each (var reason:String in mp.getReason()){
				trace(reason);
			}
			trace("The claim is: ", mp.getClaim());
		}
		[Test(order=14)]
		public function testNecessaryConditionFalse():void
		{
			mp = new ModusPonens("Basic Claim", ["Reason 1", "Reason 2"], false, "", false);
			trace("The inference is: ", mp.getInference("necessaryCondition"));	
			trace("~~ Printing all reasons in testNecessaryConditionFalse");
			for each (var reason:String in mp.getReason()){
				trace(reason);
			}
			trace("The claim is: ", mp.getClaim());
		}
	}
}