/******************************************************************************************************
* This file is part of the Nebula Query & Search project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaQueryAndSearch for full license details. *
******************************************************************************************************/
@isTest
private class SobjectQueryBuilder_Tests {

    @isTest
    static void it_should_return_results_for_a_simple_query() {
        String expectedQueryString = 'SELECT Id, Name FROM Account';

        SobjectQueryBuilder simpleAccountQuery = new SobjectQueryBuilder(Schema.Account.SobjectType);

        System.assertEquals(expectedQueryString, simpleAccountQuery.getQuery());
        List<Account> accounts = simpleAccountQuery.getResults();
    }

    @isTest
    static void it_should_return_results_for_an_advanced_query() {
        Datetime now = System.now();

        // The fields are conditionally added to the query based on the current user's permissions
        // To keep the test simpler for now, the rest of the query (excluding the 'SELECT <fields>') is validated
        String expectedPartialQueryString = 'FROM User USING SCOPE MINE WHERE IsActive = true'
            + ' AND Profile.Id != \'' + UserInfo.getProfileId() + '\' AND LastModifiedDate <= ' + now
            + ' AND CreatedDate <= LAST_WEEK AND Email != null'
            + ' ORDER BY Profile.Name ASC NULLS FIRST, Name ASC NULLS FIRST, Email ASC NULLS FIRST LIMIT 100 OFFSET 1 FOR VIEW';

        List<SobjectField> fieldsToQuery = new List<SobjectField>{Schema.User.IsActive, Schema.User.Alias};

        SobjectQueryBuilder userQuery = new SobjectQueryBuilder(Schema.User.SobjectType)
            .addFields(fieldsToQuery)
            .addField(Schema.User.ProfileId)
            .addField(Schema.User.Email, Soql.FieldCategory.UPDATEABLE)
            .addFields(Soql.FieldCategory.STANDARD)
            .removeField(new Soql.QueryField(Schema.User.Name))
            .removeField(Schema.User.UserRoleId)
            .includeLabels()
            .includeFormattedValues()
            .usingScope(Soql.Scope.MINE)
            .filterWhere(Schema.User.IsActive, Soql.Operator.EQUALS, true)
            .filterWhere(new Soql.QueryField(Schema.User.SobjectType, 'Profile.Id'), Soql.Operator.NOT_EQUAL_TO, UserInfo.getProfileId())
            .filterWhere(Schema.User.LastModifiedDate, Soql.Operator.LESS_THAN_OR_EQUAL_TO, now)
            .filterWhere(Schema.User.CreatedDate, Soql.Operator.LESS_THAN_OR_EQUAL_TO, new Soql.DateLiteral('LAST_WEEK'))
            .filterWhere(Schema.User.Email, Soql.Operator.NOT_EQUAL_TO, null)
            .orderByField(new Soql.QueryField(Schema.User.SobjectType, 'Profile.CreatedBy.LastModifiedDate'))
            .orderByField(Schema.User.Name, Soql.SortOrder.ASCENDING)
            .orderByField(Schema.User.Email)
            .limitTo(100)
            .offsetBy(1)
            .forView();

        //System.assert(userQuery.getQuery().endsWith(expectedPartialQueryString), Json.serialize(userQuery.getQuery())); //TODO finish implementing this assert
        List<User> users = userQuery.getResults();
    }

    @isTest
    static void it_should_return_results_and_include_grandparent_query_field() {
        String expectedQueryString = 'SELECT Id, Name, Parent.Owner.Name FROM Account';

        List<Schema.SobjectField> fieldChain = new List<Schema.SobjectField>{
            Schema.Account.ParentId, Schema.Account.OwnerId, Schema.User.Name
        };
        Soql.QueryField queryField = new Soql.QueryField(fieldChain);

        SobjectQueryBuilder accountQuery = new SobjectQueryBuilder(Schema.Account.SobjectType);
        accountQuery.addField(queryField);

        System.assertEquals(expectedQueryString, accountQuery.getQuery());
        List<Account> accounts = accountQuery.getResults();
    }

    @isTest
    static void it_should_return_results_and_not_include_sobject_type_for_monomorphic_field() {
        String expectedQueryString = 'SELECT Id, Name, Owner.Name, OwnerId FROM Account';

        SobjectQueryBuilder accountQuery = new SobjectQueryBuilder(Schema.Account.SobjectType)
            .addField(new Soql.QueryField(Schema.Account.OwnerId));

        System.assertEquals(expectedQueryString, accountQuery.getQuery());
        List<Account> accounts = accountQuery.getResults();
    }

    @isTest
    static void it_should_return_results_and_include_sobject_type_for_polymorphic_field() {
        String expectedQueryString = 'SELECT Id, Name, Owner.Name, Owner.Type, OwnerId FROM Lead';

        SobjectQueryBuilder leadQuery = new SobjectQueryBuilder(Schema.Lead.SobjectType)
            .addField(new Soql.QueryField(Schema.Lead.OwnerId));

        System.assertEquals(expectedQueryString, leadQuery.getQuery());
        List<Lead> leads = leadQuery.getResults();
    }

    @isTest
    static void it_should_return_results_and_include_related_records() {
        String expectedQueryString = 'SELECT Id, Name, Type, (SELECT Email, Id, Name FROM Contacts) FROM Account';

        SobjectQueryBuilder contactQuery = new SobjectQueryBuilder(Schema.Contact.SobjectType)
            .addField(Schema.Contact.Email);

        SobjectQueryBuilder accountQuery = new SobjectQueryBuilder(Schema.Account.SobjectType)
            .includeRelatedRecords(Schema.Contact.AccountId, contactQuery)
            .addField(new Soql.QueryField(Schema.Account.Type));

        System.assertEquals(expectedQueryString, accountQuery.getQuery());
        List<Account> accounts = accountQuery.getResults();
    }

    @isTest
    static void it_should_return_results_when_filtering_with_an_or_statement() {
        String expectedQueryString = 'SELECT Id, Name FROM Account WHERE ParentId != null AND (AccountNumber = null OR Type = null)';

        SobjectQueryBuilder accountQuery = new SobjectQueryBuilder(Schema.Account.SobjectType)
            .addField(Schema.Account.AnnualRevenue)
            .orFilterWhere(new List<Soql.QueryFilter>{
                new Soql.QueryFilter(Schema.Account.Type, Soql.Operator.EQUALS, null),
                new Soql.QueryFilter(Schema.Account.AccountNumber, Soql.Operator.EQUALS, null)
            })
            .filterWhere(new Soql.QueryFilter(Schema.Account.ParentId, Soql.Operator.NOT_EQUAL_TO, null));
        List<Account> accounts = accountQuery.getResults();
    }

    @isTest
    static void it_should_return_results_when_filtering_with_iso_currency() {
        // If multi-currency isn't enabled, then we cannot use IsoCurrency, so skip running this test
        if(!UserInfo.isMultiCurrencyOrganization()) return;

        // If multi-currency is enabled, then execute the test
        SobjectQueryBuilder accountQuery = new SobjectQueryBuilder(Schema.Account.SobjectType)
            .addField(Schema.Account.AnnualRevenue)
            .filterWhere(Schema.Account.AnnualRevenue, Soql.Operator.LESS_THAN, new Soql.IsoCurrency('USD', 100));
        List<Account> accounts = accountQuery.getResults();
    }

    @isTest
    static void it_should_cache_query_results_when_enabled() {
        Integer loops = 4;
        SobjectQueryBuilder userQuery = new SobjectQueryBuilder(Schema.User.SobjectType).limitTo(1);

        // First, verify that caching is not enabled by default
        System.assertEquals(0, Limits.getQueries());
        for(Integer i = 0; i < loops; i++) {
            userQuery.getResults();
        }
        System.assertEquals(loops, Limits.getQueries());

        Test.startTest();

        userQuery.cacheResults();
        for(Integer i = 0; i < loops; i++) {
            userQuery.getResults();
        }
        System.assertEquals(1, Limits.getQueries());

        Test.stopTest();
    }

}