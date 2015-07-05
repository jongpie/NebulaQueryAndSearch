@isTest
private class QueryUtils_Tests {
    @testSetup
    static void setupData() {
        /*
         Setup an test data
         For this class, we don't need data, we just want to validate that 
		 calling Database.query() works with the returned query string
		*/
    }
	
	@isTest
    static void queryAccounts() {
        Database.query(QueryUtils.getSObjectQuery('Account'));
    }
}