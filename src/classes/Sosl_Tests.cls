@isTest
private class Sosl_Tests {

    @isTest
    static void it_should_return_results_for_a_single_sobject_type() {
        String expectedSearchQueryString = 'FIND \'' + UserInfo.getUserEmail() + '\' IN ALL FIELDS RETURNING User(Id, Name)';

        Sosl.SearchSoql userQuery  = new Sosl.SearchSoql(Schema.User.SobjectType);
        Sosl userSearch = new Sosl(UserInfo.getUserEmail(), userQuery);

        System.assertEquals(expectedSearchQueryString, userSearch.getQuery());
        List<User> userSearchResults = (List<User>)userSearch.getFirstSearchResults();
    }

    @isTest
    static void it_should_return_results_for_multiple_sobject_types() {
        String expectedSearchQueryString = 'FIND \'' + UserInfo.getUserEmail() + '\' IN ALL FIELDS RETURNING Account(Id, Name), User(Id, Name)';

        List<Sosl.SearchSoql> queries = new List<Sosl.SearchSoql>{
            new Sosl.SearchSoql(Schema.User.SobjectType),
            new Sosl.SearchSoql(Schema.Account.SobjectType)
        };
        Sosl search = new Sosl(UserInfo.getUserEmail(), queries);

        System.assertEquals(expectedSearchQueryString, search.getQuery());
        List<List<Sobject>> searchResults = search.getSearchResults();
    }


    @isTest
    static void it_should_cache_search_results_when_enabled() {
        Integer loops = 4;
        Sosl.SearchSoql userQuery  = new Sosl.SearchSoql(Schema.User.SobjectType);
        Sosl userSearch = new Sosl(UserInfo.getUserEmail(), userQuery);

        // First, verify that caching is not enabled by default
        System.assertEquals(0, Limits.getSoslQueries());
        for(Integer i=0; i < loops; i++) {
            userSearch.getSearchResults();
        }
        System.assertEquals(loops, Limits.getSoslQueries());

        Test.startTest();

        userSearch.cacheResults();
        for(Integer i=0; i < loops; i++) {
            userSearch.getSearchResults();
        }
        System.assertEquals(1, Limits.getSoslQueries());

        Test.stopTest();
    }

}