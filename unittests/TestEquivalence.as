package unittests
{
	public class TestEquivalence
	{		
		import logic.Equivalence;
		import org.flexunit.Assert;
		
		private var eq:Equivalence;
		
		[Before]
		public function setUp():void
		{
			//Equivalence(claimText:String,reasonText:Array,reversePos:Boolean,inferenceText:String="",inferencePresent:Boolean = false)
			eq= new Equivalence("Basic Claim", ["Reason 1", "Reason 2"], false, "Foo if and only if Bar just in case Baz is a necessary and sufficient condition for Quux", false);
		}
		
		[After]
		public function tearDown():void
		{
		}
		
		[BeforeClass]
		public static function setUpBeforeClass():void
		{
			trace("Setting up Equivalence testing...");
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
		//New tests for this subclass's particular functions
		//Not asserting anything because it's currently pointless
		[Test(order=1)]
		public function testIfOnlyIfPTrue():void{
			eq.ifOnlyIfP(true);
			trace("~~ Printing all reasons in IfOnlyIfPTrue");
			for each (var reason:String in eq.getReason()){
				trace(reason);
			}
			trace("The claim is: ", eq.getClaim());
			trace("The inference is: ", eq.getInference("ifOnlyIfP"));
		}
		[Test(order=2)]
		public function testIfOnlyIfPFalse():void{
			eq.ifOnlyIfP(false);
			trace("~~ Printing all reasons in IfOnlyIfPFalse");
			for each (var reason:String in eq.getReason()){
				trace(reason);
			}
			trace("The claim is: ", eq.getClaim());
			trace("The inference is: ", eq.getInference("ifOnlyIfP"));
		}
		[Test(order=3)]
		public function testIfOnlyIfQTrue():void{
			eq.ifOnlyIfQ(true);
			trace("~~ Printing all reasons in IfOnlyIfQTrue");
			for each (var reason:String in eq.getReason()){
				trace(reason);
			}
			trace("The claim is: ", eq.getClaim());
			trace("The inference is: ", eq.getInference("ifOnlyIfQ"));
		}
		[Test(order=4)]
		public function testIfOnlyIfQFalse():void{
			eq.ifOnlyIfQ(false);
			trace("~~ Printing all reasons in IfOnlyIfQFalse");
			for each (var reason:String in eq.getReason()){
				trace(reason);
			}
			trace("The claim is: ", eq.getClaim());
			trace("The inference is: ", eq.getInference("ifOnlyIfQ"));
		}
		[Test(order=5)]
		public function testIfOnlyIfNotPTrue():void{
			eq.ifOnlyIfNotP(true);
			trace("~~ Printing all reasons in IfOnlyIfNotPTrue");
			for each (var reason:String in eq.getReason()){
				trace(reason);
			}
			trace("The claim is: ", eq.getClaim());
			trace("The inference is: ", eq.getInference("ifOnlyIfNotP"));
		}
		[Test(order=6)]
		public function testIfOnlyIfNotPFalse():void{
			eq.ifOnlyIfNotP(false);
			trace("~~ Printing all reasons in IfOnlyIfNotPFalse");
			for each (var reason:String in eq.getReason()){
				trace(reason);
			}
			trace("The claim is: ", eq.getClaim());
			trace("The inference is: ", eq.getInference("ifOnlyIfNotP"));
		}
		[Test(order=7)]
		public function testIfOnlyIfNotQTrue():void{
			eq.ifOnlyIfNotQ(true);
			trace("~~ Printing all reasons in IfOnlyIfNotQTrue");
			for each (var reason:String in eq.getReason()){
				trace(reason);
			}
			trace("The claim is: ", eq.getClaim());
			trace("The inference is: ", eq.getInference("ifOnlyIfNotQ"));
		}
		[Test(order=8)]
		public function testIfOnlyIfNotQFalse():void{
			eq.ifOnlyIfNotQ(false);
			trace("~~ Printing all reasons in IfOnlyIfNotQFalse");
			for each (var reason:String in eq.getReason()){
				trace(reason);
			}
			trace("The claim is: ", eq.getClaim());
			trace("The inference is: ", eq.getInference("ifOnlyIfNotQ"));
		}
		[Test(order=9)]
		public function testJustInCasePTrue():void{
			eq.justInCaseP(true);
			trace("~~ Printing all reasons in JustInCasePTrue");
			for each (var reason:String in eq.getReason()){
				trace(reason);
			}
			trace("The claim is: ", eq.getClaim());
			trace("The inference is: ", eq.getInference("justInCaseP"));
		}
		[Test(order=10)]
		public function testJustInCasePFalse():void{
			eq.justInCaseP(false);
			trace("~~ Printing all reasons in JustInCasePFalse");
			for each (var reason:String in eq.getReason()){
				trace(reason);
			}
			trace("The claim is: ", eq.getClaim());
			trace("The inference is: ", eq.getInference("justInCaseP"));
		}
		[Test(order=11)]
		public function testJustInCaseQTrue():void{
			eq.justInCaseQ(true);
			trace("~~ Printing all reasons in JustInCaseQTrue");
			for each (var reason:String in eq.getReason()){
				trace(reason);
			}
			trace("The claim is: ", eq.getClaim());
			trace("The inference is: ", eq.getInference("justInCaseQ"));
		}
		[Test(order=12)]
		public function testJustInCaseQFalse():void{
			eq.justInCaseQ(false);
			trace("~~ Printing all reasons in JustInCaseQFalse");
			for each (var reason:String in eq.getReason()){
				trace(reason);
			}
			trace("The claim is: ", eq.getClaim());
			trace("The inference is: ", eq.getInference("justInCaseQ"));
		}
		[Test(order=13)]
		public function testJustInCaseNotPTrue():void{
			eq.justInCaseNotP(true);
			trace("~~ Printing all reasons in JustInCaseNotPTrue");
			for each (var reason:String in eq.getReason()){
				trace(reason);
			}
			trace("The claim is: ", eq.getClaim());
			trace("The inference is: ", eq.getInference("justInCaseNotP"));
		}
		[Test(order=14)]
		public function testJustInCaseNotPFalse():void{
			eq.justInCaseNotP(false);
			trace("~~ Printing all reasons in JustInCaseNotPFalse");
			for each (var reason:String in eq.getReason()){
				trace(reason);
			}
			trace("The claim is: ", eq.getClaim());
			trace("The inference is: ", eq.getInference("justInCaseNotP"));
		}
		[Test(order=15)]
		public function testJustInCaseNotQTrue():void{
			eq.justInCaseNotQ(true);
			trace("~~ Printing all reasons in JustInCaseNotQTrue");
			for each (var reason:String in eq.getReason()){
				trace(reason);
			}
			trace("The claim is: ", eq.getClaim());
			trace("The inference is: ", eq.getInference("justInCaseNotQ"));
		}
		[Test(order=16)]
		public function testJustInCaseNotQFalse():void{
			eq.justInCaseNotQ(false);
			trace("~~ Printing all reasons in JustInCaseNotQFalse");
			for each (var reason:String in eq.getReason()){
				trace(reason);
			}
			trace("The claim is: ", eq.getClaim());
			trace("The inference is: ", eq.getInference("justInCaseNotQ"));
		}
		[Test(order=17)]
		public function testNecessaryPTrue():void{
			eq.necessaryP(true);
			trace("~~ Printing all reasons in NecessaryPTrue");
			for each (var reason:String in eq.getReason()){
				trace(reason);
			}
			trace("The claim is: ", eq.getClaim());
			trace("The inference is: ", eq.getInference("necessaryP"));
		}
		[Test(order=18)]
		public function testNecessaryPFalse():void{
			eq.necessaryP(false);
			trace("~~ Printing all reasons in NecessaryPFalse");
			for each (var reason:String in eq.getReason()){
				trace(reason);
			}
			trace("The claim is: ", eq.getClaim());
			trace("The inference is: ", eq.getInference("necessaryP"));
		}
		[Test(order=19)]
		public function testNecessaryQTrue():void{
			eq.necessaryQ(true);
			trace("~~ Printing all reasons in NecessaryQTrue");
			for each (var reason:String in eq.getReason()){
				trace(reason);
			}
			trace("The claim is: ", eq.getClaim());
			trace("The inference is: ", eq.getInference("necessaryQ"));
		}
		[Test(order=20)]
		public function testNecessaryQFalse():void{
			eq.necessaryQ(false);
			trace("~~ Printing all reasons in NecessaryQFalse");
			for each (var reason:String in eq.getReason()){
				trace(reason);
			}
			trace("The claim is: ", eq.getClaim());
			trace("The inference is: ", eq.getInference("necessaryQ"));
		}
		[Test(order=21)]
		public function testNecessaryNotPTrue():void{
			eq.necessaryNotP(true);
			trace("~~ Printing all reasons in NecessaryNotPTrue");
			for each (var reason:String in eq.getReason()){
				trace(reason);
			}
			trace("The claim is: ", eq.getClaim());
			trace("The inference is: ", eq.getInference("necessaryNotP"));
		}
		[Test(order=22)]
		public function testNecessaryNotPFalse():void{
			eq.necessaryNotP(false);
			trace("~~ Printing all reasons in NecessaryNotPFalse");
			for each (var reason:String in eq.getReason()){
				trace(reason);
			}
			trace("The claim is: ", eq.getClaim());
			trace("The inference is: ", eq.getInference("necessaryNotP"));
		}
		[Test(order=23)]
		public function testNecessaryNotQTrue():void{
			eq.necessaryNotQ(true);
			trace("~~ Printing all reasons in NecessaryNotQTrue");
			for each (var reason:String in eq.getReason()){
				trace(reason);
			}
			trace("The claim is: ", eq.getClaim());
			trace("The inference is: ", eq.getInference("necessaryNotQ"));
		}
		[Test(order=24)]
		public function testNecessaryNotQFalse():void{
			eq.necessaryQ(false);
			trace("~~ Printing all reasons in NecessaryNotQFalse");
			for each (var reason:String in eq.getReason()){
				trace(reason);
			}
			trace("The claim is: ", eq.getClaim());
			trace("The inference is: ", eq.getInference("necessaryNotQ"));
		}
		[Test(order=25)]
		public function testEquivalentPTrue():void{
			eq.equivalentP(true);
			trace("~~ Printing all reasons in EquivalentPTrue");
			for each (var reason:String in eq.getReason()){
				trace(reason);
			}
			trace("The claim is: ", eq.getClaim());
			trace("The inference is: ", eq.getInference("equivalentP"));
		}
		[Test(order=18)]
		public function testEquivalentPFalse():void{
			eq.equivalentP(false);
			trace("~~ Printing all reasons in EquivalentPFalse");
			for each (var reason:String in eq.getReason()){
				trace(reason);
			}
			trace("The claim is: ", eq.getClaim());
			trace("The inference is: ", eq.getInference("equivalentP"));
		}
		[Test(order=19)]
		public function testEquivalentQTrue():void{
			eq.equivalentQ(true);
			trace("~~ Printing all reasons in EquivalentQTrue");
			for each (var reason:String in eq.getReason()){
				trace(reason);
			}
			trace("The claim is: ", eq.getClaim());
			trace("The inference is: ", eq.getInference("equivalentQ"));
		}
		[Test(order=20)]
		public function testEquivalentQFalse():void{
			eq.equivalentQ(false);
			trace("~~ Printing all reasons in EquivalentQFalse");
			for each (var reason:String in eq.getReason()){
				trace(reason);
			}
			trace("The claim is: ", eq.getClaim());
			trace("The inference is: ", eq.getInference("equivalentQ"));
		}
		[Test(order=21)]
		public function testEquivalentNotPTrue():void{
			eq.equivalentNotP(true);
			trace("~~ Printing all reasons in EquivalentNotPTrue");
			for each (var reason:String in eq.getReason()){
				trace(reason);
			}
			trace("The claim is: ", eq.getClaim());
			trace("The inference is: ", eq.getInference("equivalentNotP"));
		}
		[Test(order=22)]
		public function testEquivalentNotPFalse():void{
			eq.equivalentNotP(false);
			trace("~~ Printing all reasons in EquivalentNotPFalse");
			for each (var reason:String in eq.getReason()){
				trace(reason);
			}
			trace("The claim is: ", eq.getClaim());
			trace("The inference is: ", eq.getInference("equivalentNotP"));
		}
		[Test(order=23)]
		public function testEquivalentNotQTrue():void{
			eq.equivalentNotQ(true);
			trace("~~ Printing all reasons in EquivalentNotQTrue");
			for each (var reason:String in eq.getReason()){
				trace(reason);
			}
			trace("The claim is: ", eq.getClaim());
			trace("The inference is: ", eq.getInference("equivalentNotQ"));
		}
		[Test(order=24)]
		public function testEquivalentNotQFalse():void{
			eq.equivalentQ(false);
			trace("~~ Printing all reasons in EquivalentNotQFalse");
			for each (var reason:String in eq.getReason()){
				trace(reason);
			}
			trace("The claim is: ", eq.getClaim());
			trace("The inference is: ", eq.getInference("equivalentNotQ"));
		}
	}
}