@isTest
private class Sosl_Tests {

    @isTest
    static void it_should_return_results_for_a_single_sobject_type() {
        String expectedSearchQueryString = 'FIND \'' + UserInfo.getUserEmail() + '\' IN ALL FIELDS RETURNING User(Id, Name)';

        Soql userQuery  = new Soql(Schema.User.SobjectType);
        Sosl userSearch = new Sosl(UserInfo.getUserEmail(), userQuery);

        System.assertEquals(expectedSearchQueryString, userSearch.getSearchQuery());
        List<User> userSearchResults = (List<User>)userSearch.getFirstSearchResults();
    }

    @isTest
    static void it_should_return_results_for_multiple_sobject_types() {
        String expectedSearchQueryString = 'FIND \'' + UserInfo.getUserEmail() + '\' IN ALL FIELDS RETURNING Account(Id, Name), User(Id, Name)';

        List<Soql> queries = new List<Soql>{
            new Soql(Schema.User.SobjectType),
            new Soql(Schema.Account.SobjectType)
        };
        Sosl search = new Sosl(UserInfo.getUserEmail(), queries);

        System.assertEquals(expectedSearchQueryString, search.getSearchQuery());
        List<List<Sobject>> searchResults = search.getSearchResults();
    }

}