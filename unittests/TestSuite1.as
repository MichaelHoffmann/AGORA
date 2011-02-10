package unittests
{
	import unittests.TestArgumentSchemes;
	import unittests.TestDisjunctiveSyllogism;
	[Suite]
	[RunWith("org.flexunit.runners.Suite")]
	public class TestSuite1
	{
		public var test1:unittests.TestArgumentSchemes;
		public var test2:unittests.TestDisjunctiveSyllogism;
		public var test3:unittests.TestEquivalence;
		public var test4:unittests.TestModusPonens;
		public var test5:unittests.TestModusTollens;
		public var test6:unittests.TestNotBothSyllogism;
	}
}