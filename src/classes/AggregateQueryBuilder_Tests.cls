/******************************************************************************************************
* This file is part of the Nebula Query & Search project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaQueryAndSearch for full license details. *
******************************************************************************************************/
@isTest
private class AggregateQueryBuilder_Tests {

    @isTest
    static void it_should_be_usable_after_construction() {
        // Query builders should be usable as soon as it's constructed - it should be able to execute a query with some default values
        AggregateQueryBuilder aggregateQueryBuilder = new AggregateQueryBuilder(Schema.Opportunity.SobjectType);

        Test.startTest();

        AggregateResult result = (AggregateResult)aggregateQueryBuilder.getFirstResult();

        Test.stopTest();
    }

    @isTest
    static void it_should_cache_results() {
        AggregateQueryBuilder aggregateQueryBuilder = new AggregateQueryBuilder(Schema.Opportunity.SobjectType);
        aggregateQueryBuilder.cacheResults();

        Test.startTest();

        System.assertEquals(0, Limits.getQueries());
        for(Integer i = 0; i < 3; i++) {
            aggregateQueryBuilder.getResults();
        }

        System.assertEquals(1, Limits.getQueries());

        Test.stopTest();
    }

    @isTest
    static void it_should_group_by_cube() {
        String expectedString = 'SELECT Type, StageName, SUM(Amount) Amount__SUM FROM Opportunity GROUP BY CUBE(Type, StageName)';

        AggregateQueryBuilder aggregateQueryBuilder = new AggregateQueryBuilder(Schema.Opportunity.SobjectType)
            .groupBy(Schema.Opportunity.Type)
            .groupBy(Schema.Opportunity.StageName)
            .addAggregateField(Soql.Aggregate.SUM, Schema.Opportunity.Amount)
            .usingGroupingDimension(Soql.GroupingDimension.CUBE);

        Test.startTest();

        List<AggregateResult> results = aggregateQueryBuilder.getResults();

        Test.stopTest();
    }

    @isTest
    static void it_should_group_by_rollup() {
        String expectedString = 'SELECT Type, StageName, SUM(Amount) Amount__SUM FROM Opportunity GROUP BY ROLLUP(Type, StageName)';

        AggregateQueryBuilder aggregateQueryBuilder = new AggregateQueryBuilder(Schema.Opportunity.SobjectType)
            .groupBy(Schema.Opportunity.Type)
            .groupBy(Schema.Opportunity.StageName)
            .addAggregateField(Soql.Aggregate.SUM, Schema.Opportunity.Amount)
            .usingGroupingDimension(Soql.GroupingDimension.ROLLUP);

        Test.startTest();

        List<AggregateResult> results = aggregateQueryBuilder.getResults();

        Test.stopTest();
    }

    @isTest
    static void it_should_group_by_having_aggregate() {
        String expectedString = 'SELECT Name, COUNT(Id) Id__COUNT FROM Account GROUP BY Name HAVING COUNT(Id) > 2';

        AggregateQueryBuilder aggregateQueryBuilder = new AggregateQueryBuilder(Schema.Account.SobjectType)
          .groupBy(Account.Name)
          .addAggregateField(Soql.Aggregate.COUNT, Account.Id)
          .havingAggregate(Soql.Aggregate.COUNT, Account.Id, '>', 2);

        Test.startTest();

        List<AggregateResult> results = aggregateQueryBuilder.getResults();

        Test.stopTest();
    }

    @isTest
    static void it_should_build_an_ridiculous_query_string() {
        String expectedString = 'SELECT Account.Type, StageName, AVG(Amount) Amount__AVG, COUNT(AccountId) AccountId__COUNT,'
            + ' COUNT_DISTINCT(AccountId) AccountId__COUNT_DISTINCT, COUNT_DISTINCT(OwnerId) OwnerId__COUNT_DISTINCT, COUNT_DISTINCT(Type) Type__COUNT_DISTINCT,'
            + ' MAX(CreatedDate) CreatedDate__MAX, MIN(CreatedDate) CreatedDate__MIN, SUM(Amount) Amount__SUM'
            + ' FROM Opportunity'
            + ' WHERE AccountId != null'
            + ' GROUP BY Account.Type, StageName'
            + ' ORDER BY Account.Type ASC NULLS FIRST, StageName ASC NULLS FIRST, SUM(Amount) ASC NULLS FIRST,'
                + ' MIN(CloseDate) DESC NULLS FIRST, MAX(Account.LastActivityDate) ASC NULLS FIRST'
            + ' LIMIT 100'
            + ' OFFSET 0';

        AggregateQueryBuilder aggregateQueryBuilder = new AggregateQueryBuilder(Schema.Opportunity.SobjectType)
            .addAggregateField(Soql.Aggregate.MAX, Schema.Opportunity.CreatedDate)
            .addAggregateField(Soql.Aggregate.AVG, Schema.Opportunity.Amount)
            .addAggregateField(Soql.Aggregate.COUNT_DISTINCT, Schema.Opportunity.OwnerId)
            .addAggregateField(Soql.Aggregate.MIN, Schema.Opportunity.CreatedDate)
            .groupBy(new Soql.QueryField(new List<Schema.SobjectField>{
                Schema.Opportunity.AccountId, Schema.Account.Type
            }))
            .addAggregateField(Soql.Aggregate.SUM, Schema.Opportunity.Amount)
            .groupBy(Schema.Opportunity.StageName)
            .addAggregateField(Soql.Aggregate.COUNT, Schema.Opportunity.AccountId)
            .addAggregateField(Soql.Aggregate.COUNT_DISTINCT, Schema.Opportunity.AccountId)
            .addAggregateField(Soql.Aggregate.COUNT_DISTINCT, new Soql.QueryField(new List<Schema.SobjectField>{
                Schema.Opportunity.AccountId, Schema.Account.Type
            }))
            .orderBy(new Soql.QueryField(new List<Schema.SobjectField>{
                Schema.Opportunity.AccountId, Schema.Account.Type
            }))
            .orderBy(Schema.Opportunity.StageName)
            .orderByAggregate(Soql.Aggregate.SUM, Schema.Opportunity.Amount)
            .orderByAggregate(Soql.Aggregate.MIN, Schema.Opportunity.CloseDate, Soql.SortOrder.DESCENDING)
            .orderByAggregate(
                Soql.Aggregate.MAX,
                new Soql.QueryField(new List<Schema.SobjectField>{Schema.Opportunity.AccountId, Schema.Account.LastActivityDate})
            )
            .filterWhere(Schema.Opportunity.AccountId, '!=', null)
            .limitTo(100)
            .offsetBy(0);

        Test.startTest();

        String returnedQueryString = aggregateQueryBuilder.getQuery();

        Test.stopTest();

        System.assertEquals(expectedString, returnedQueryString);

        // Verify that the query can be executed
        List<AggregateResult> results = Database.query(returnedQueryString);
    }


}