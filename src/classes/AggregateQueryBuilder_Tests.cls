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

        List<AggregateResult> results = (List<AggregateResult>)aggregateQueryBuilder.getResults();

        Test.stopTest();
    }

    @isTest
    static void it_should_cache_results() {
        AggregateQueryBuilder aggregateQueryBuilder = new AggregateQueryBuilder(Schema.Opportunity.SobjectType);
        aggregateQueryBuilder.cacheResults();

        Test.startTest();

        System.assertEquals(0, Limits.getQueries());
        for(Integer i = 0; i < 10; i++) {
            System.debug(aggregateQueryBuilder.getResults());
        }

        System.assertEquals(1, Limits.getQueries());

        Test.stopTest();
    }

    @isTest
    static void it_should_build_a_ridiculous_query_string() {
        String expectedString = 'SELECT Account.Type, StageName, AVG(Amount) Amount__AVG, COUNT(AccountId) AccountId__COUNT,'
            + ' COUNT_DISTINCT(AccountId) AccountId__COUNT_DISTINCT, COUNT_DISTINCT(OwnerId) OwnerId__COUNT_DISTINCT, COUNT_DISTINCT(Type) Type__COUNT_DISTINCT,'
            + ' MAX(CreatedDate) CreatedDate__MAX, MIN(CreatedDate) CreatedDate__MIN, SUM(Amount) Amount__SUM'
            + ' FROM Opportunity'
            + ' WHERE AccountId != null'
            + ' GROUP BY Account.Type, StageName'
            + ' ORDER BY Account.Type ASC NULLS FIRST, StageName ASC NULLS FIRST'
            + ' LIMIT 100'
            + ' OFFSET 0';

        AggregateQueryBuilder aggregateQueryBuilder = new AggregateQueryBuilder(Schema.Opportunity.SobjectType)
            .max(Schema.Opportunity.CreatedDate)
            .avg(Schema.Opportunity.Amount)
            .countDistinct(Schema.Opportunity.OwnerId)
            .min(Schema.Opportunity.CreatedDate)
            .groupBy(new Soql.QueryField(new List<Schema.SobjectField>{
                Schema.Opportunity.AccountId, Schema.Account.Type
            }))
            .sum(Schema.Opportunity.Amount)
            .groupBy(Schema.Opportunity.StageName)
            .count(Schema.Opportunity.AccountId)
            .countDistinct(Schema.Opportunity.AccountId)
            .countDistinct(new Soql.QueryField(new List<Schema.SobjectField>{
                Schema.Opportunity.AccountId, Schema.Account.Type
            }))
            .orderBy(new Soql.QueryField(new List<Schema.SobjectField>{
                Schema.Opportunity.AccountId, Schema.Account.Type
            }))
            .orderBy(Schema.Opportunity.StageName)
            .orderBy(Schema.Opportunity.Amount, AggregateQueryBuilder.Aggregate.SUM)
            .filterWhere(Schema.Opportunity.AccountId, '!=', null)
            .limitTo(100)
            .offsetBy(0);
        String returnedQueryString = aggregateQueryBuilder.getQuery();

        System.assertEquals(expectedString, returnedQueryString);

        // Verify that the query can be executed
        Database.query(returnedQueryString);
    }


}