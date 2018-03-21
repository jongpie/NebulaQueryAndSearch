@isTest
private class Soql_Tests {

    @isTest
    static void it_should_return_results_for_a_simple_query_using_tokens() {
        Soql simpleQuery = new Soql(Schema.Account.SObjectType);
        List<Account> accounts = (List<Account>)simpleQuery.getQueryResults();
    }

    @isTest
    static void it_should_return_results_for_a_simple_query_using_strings() {
        Soql simpleQuery = new Soql('Account');
        List<Account> accounts = (List<Account>)simpleQuery.getQueryResults();
    }

    @isTest
    static void it_should_return_results_for_an_advanced_query() {
        List<SobjectField> fieldsToQuery = new List<SobjectField>{Schema.User.IsActive, Schema.User.Alias};

        Soql userQuery = new Soql(Schema.User.SObjectType)
            .addFields(fieldsToQuery)
            .addField(Schema.User.ProfileId)
            .addField('Email', Soql.FieldCategory.UPDATEABLE)
            .addFields(Soql.FieldCategory.STANDARD)
            .removeField('Name')
            .removeField(Schema.User.UserRoleId)
            .usingScope(Soql.Scope.MINE)
            .filterWhere('IsActive', '=', true)
            .filterWhere('Profile.Id', '!=', UserInfo.getProfileId())
            .filterWhere(Schema.User.LastModifiedDate, '<=', System.now())
            .filterWhere(Schema.User.CreatedDate, '<=', new Soql.DateLiteral('LAST_WEEK'))
            .filterWhere('Email != null')
            .orderBy('Profile.Name')
            .orderBy(Schema.User.Name, Soql.SortOrder.ASCENDING)
            .orderBy(Schema.User.Email)
            .limitCount(100)
            .offset(1)
            .forView();
        List<User> users = userQuery.getQueryResults();
    }

    @isTest
    static void it_should_return_results_for_aggregate_query() {
        Soql aggregateAccountQuery = new Soql(Schema.User.SObjectType)
            .addField('ProfileId')
            .aggregateField('CreatedDate', Soql.Aggregate.MAX)
            .aggregateField('CreatedDate', Soql.Aggregate.MIN)
            .aggregateField(Schema.User.Email, Soql.Aggregate.COUNT);
        List<AggregateResult> results = aggregateAccountQuery.getQueryResults();
    }

    @isTest
    static void it_should_return_results_when_filtering_with_iso_currency() {
        // If multi-currency isn't enabled, then we cannot use IsoCurrency, so skip running this test
        if(!UserInfo.isMultiCurrencyOrganization()) return;

        // If multi-currency is enabled, then execute the test
        Soql accountQuery = new Soql(Schema.Account.SObjectType)
            .addField(Schema.Account.AnnualRevenue)
            .filterWhere(Schema.Account.AnnualRevenue, '<', new Soql.IsoCurrency('USD', 100));
        List<Account> accounts = accountQuery.getQueryResults();
    }

    @isTest
    static void it_should_cache_query_results_when_enabled() {
        //.cacheResults()
        //.includeLabels()
        //.includeFormattedValues()
        // TYPEOF support - https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_select_typeof.htm
        // converting time zones? https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_select_convert_time_zone.htm
        // convert currency https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_querying_currency_fields.htm
        System.assert(false, 'need to finish writing test');
    }

}