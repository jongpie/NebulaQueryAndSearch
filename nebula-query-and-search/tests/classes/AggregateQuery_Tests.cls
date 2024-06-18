/*******************************************************************************************************
 * This file is part of the Nebula Query & Search project, released under the MIT License.             *
 * Copyright (c) 2018, Jonathan Gillespie. All rights reserved.                                        *
 * See LICENSE file or go to https://github.com/jongpie/NebulaQueryAndSearch for full license details. *
 ******************************************************************************************************/

@SuppressWarnings(
  'PMD.ApexDoc, PMD.ApexAssertionsShouldIncludeMessage, PMD.ApexUnitTestClassShouldHaveAsserts, PMD.CyclomaticComplexity, PMD.EagerlyLoadedDescribeSObjectResult, PMD.ExcessiveParameterList, PMD.MethodNamingConventions, PMD.NcssMethodCount, PMD.UnusedLocalVariable'
)
@IsTest(IsParallel=true)
private class AggregateQuery_Tests {
<<<<<<< Updated upstream
  @IsTest
  static void it_should_be_usable_after_construction() {
    String expectedQueryString = 'SELECT COUNT(Id) COUNT__Id FROM Opportunity';

    AggregateQuery aggregateQuery = new AggregateQuery(Schema.Opportunity.SObjectType);

    System.Assert.areEqual(expectedQueryString, aggregateQuery.getQuery());
    List<Schema.AggregateResult> expectedResults = Database.query(expectedQueryString);
    List<Schema.AggregateResult> returnedResults = aggregateQuery.getResults();
    System.Assert.areEqual(expectedResults, returnedResults);
  }

  @IsTest
  static void it_should_return_results_when_filtering() {
    String expectedQueryString = 'SELECT Type FROM Opportunity WHERE AccountId != null GROUP BY Type';

    AggregateQuery aggregateQuery = new AggregateQuery(Schema.Opportunity.SObjectType)
      .groupByField(Schema.Opportunity.Type)
      .filterWhere(new SOQL.QueryFilter(Schema.Opportunity.AccountId, SOQL.Operator.NOT_EQUAL_TO, null));

    System.Assert.areEqual(expectedQueryString, aggregateQuery.getQuery());
    List<Schema.AggregateResult> expectedResults = Database.query(expectedQueryString);
    List<Schema.AggregateResult> returnedResults = aggregateQuery.getResults();
    System.Assert.areEqual(expectedResults, returnedResults);
  }

  @IsTest
  static void it_should_return_results_when_filtering_with_an_or_statement() {
    String expectedQueryString = 'SELECT Type, COUNT(Id) COUNT__Id FROM Account WHERE (AnnualRevenue = null OR Type = null) AND ParentId != null GROUP BY Type';

    AggregateQuery aggregateQuery = new AggregateQuery(Schema.Account.SObjectType)
      .groupByField(Schema.Account.Type)
      .filterWhere(new SOQL.QueryFilter(Schema.Account.ParentId, SOQL.Operator.NOT_EQUAL_TO, null))
      .orFilterWhere(
        new List<SOQL.QueryFilter>{
          new SOQL.QueryFilter(Schema.Account.Type, SOQL.Operator.EQUALS, null),
          new SOQL.QueryFilter(Schema.Account.AnnualRevenue, SOQL.Operator.EQUALS, null)
        }
      )
      .addAggregate(SOQL.Aggregate.COUNT, Schema.Account.Id);

    System.Assert.areEqual(expectedQueryString, aggregateQuery.getQuery());
    List<Schema.AggregateResult> expectedResults = Database.query(expectedQueryString);
    List<Schema.AggregateResult> returnedResults = aggregateQuery.getResults();
    System.Assert.areEqual(expectedResults, returnedResults);
  }

  @IsTest
  static void it_should_cache_results() {
    AggregateQuery aggregateQuery = new AggregateQuery(Schema.Opportunity.SObjectType);
    aggregateQuery.cacheResults();
    System.assertEquals(0, Limits.getQueries());

    for (Integer i = 0; i < 3; i++) {
      aggregateQuery.getResults();
    }

    System.assertEquals(1, Limits.getQueries());
  }

  @IsTest
  static void it_should_group_by_cube() {
    String expectedQueryString = 'SELECT Type, StageName, SUM(Amount) SUM__Amount FROM Opportunity GROUP BY CUBE(Type, StageName)';

    AggregateQuery aggregateQuery = new AggregateQuery(Schema.Opportunity.SObjectType)
      .groupByField(Schema.Opportunity.Type)
      .groupByField(Schema.Opportunity.StageName)
      .addAggregate(SOQL.Aggregate.SUM, Schema.Opportunity.Amount)
      .usingGroupingDimension(SOQL.GroupingDimension.CUBE);

    System.Assert.areEqual(expectedQueryString, aggregateQuery.getQuery());
    List<Schema.AggregateResult> expectedResults = Database.query(expectedQueryString);
    List<Schema.AggregateResult> returnedResults = aggregateQuery.getResults();
    System.Assert.areEqual(expectedResults, returnedResults);
  }

  @IsTest
  static void it_should_group_by_rollup() {
    String expectedQueryString = 'SELECT Type, StageName, SUM(Amount) SUM__Amount FROM Opportunity GROUP BY ROLLUP(Type, StageName)';

    AggregateQuery aggregateQuery = new AggregateQuery(Schema.Opportunity.SObjectType)
      .groupByField(Schema.Opportunity.Type)
      .groupByField(Schema.Opportunity.StageName)
      .addAggregate(SOQL.Aggregate.SUM, Schema.Opportunity.Amount)
      .usingGroupingDimension(SOQL.GroupingDimension.ROLLUP);

    System.Assert.areEqual(expectedQueryString, aggregateQuery.getQuery());
    List<Schema.AggregateResult> expectedResults = Database.query(expectedQueryString);
    List<Schema.AggregateResult> returnedResults = aggregateQuery.getResults();
    System.Assert.areEqual(expectedResults, returnedResults);
  }

  @IsTest
  static void it_should_group_by_having_aggregate() {
    String expectedQueryString = 'SELECT Name, COUNT(Id) COUNT__Id FROM Account GROUP BY Name HAVING COUNT(Id) > 2';

    AggregateQuery aggregateQuery = new AggregateQuery(Schema.Account.SObjectType)
      .groupByField(Schema.Account.Name)
      .addAggregate(SOQL.Aggregate.COUNT, Schema.Account.Id)
      .havingAggregate(SOQL.Aggregate.COUNT, Schema.Account.Id, SOQL.Operator.GREATER_THAN, 2);

    System.Assert.areEqual(expectedQueryString, aggregateQuery.getQuery());
    List<Schema.AggregateResult> expectedResults = Database.query(expectedQueryString);
    List<Schema.AggregateResult> returnedResults = aggregateQuery.getResults();
    System.Assert.areEqual(expectedResults, returnedResults);
  }

  @IsTest
  static void it_should_group_by_a_date_function() {
    String expectedQueryString = 'SELECT CALENDAR_MONTH(CloseDate), COUNT(Id) COUNT__Id FROM Opportunity GROUP BY CALENDAR_MONTH(CloseDate)';

    AggregateQuery aggregateQuery = new AggregateQuery(Schema.Opportunity.SObjectType)
      .groupByField(new SOQL.QueryField(SOQL.DateFunction.CALENDAR_MONTH, Schema.Opportunity.CloseDate))
      .addAggregate(SOQL.Aggregate.COUNT, Opportunity.Id);

    System.Assert.areEqual(expectedQueryString, aggregateQuery.getQuery());
    List<Schema.AggregateResult> expectedResults = Database.query(expectedQueryString);
    List<Schema.AggregateResult> returnedResults = aggregateQuery.getResults();
    System.Assert.areEqual(expectedResults, returnedResults);
  }

  @IsTest
  static void it_should_build_a_ridiculous_query_string() {
    String expectedQueryString =
      'SELECT Account.Type, StageName, AVG(Amount) AVG__Amount, COUNT(AccountId) COUNT__AccountId,' +
      ' COUNT_DISTINCT(AccountId) COUNT_DISTINCT__AccountId, COUNT_DISTINCT(OwnerId) COUNT_DISTINCT__OwnerId, COUNT_DISTINCT(Type) COUNT_DISTINCT__Type,' +
      ' MAX(CreatedDate) MAX__CreatedDate, MIN(CreatedDate) MIN__CreatedDate, SUM(Amount) SUM__Amount' +
      ' FROM Opportunity' +
      ' WHERE AccountId != null' +
      ' GROUP BY Account.Type, StageName' +
      ' ORDER BY Account.Type ASC NULLS FIRST, StageName ASC NULLS FIRST, SUM(Amount) ASC NULLS FIRST,' +
      ' MIN(CloseDate) DESC NULLS FIRST, MAX(Account.LastActivityDate) ASC NULLS FIRST' +
      ' LIMIT 100' +
      ' OFFSET 0';

    AggregateQuery aggregateQuery = new AggregateQuery(Schema.Opportunity.SObjectType)
      .addAggregate(SOQL.Aggregate.MAX, Schema.Opportunity.CreatedDate)
      .addAggregate(SOQL.Aggregate.AVG, Schema.Opportunity.Amount)
      .addAggregate(SOQL.Aggregate.COUNT_DISTINCT, Schema.Opportunity.OwnerId)
      .addAggregate(SOQL.Aggregate.MIN, Schema.Opportunity.CreatedDate)
      .groupByField(new SOQL.QueryField(new List<Schema.SObjectField>{ Schema.Opportunity.AccountId, Schema.Account.Type }))
      .addAggregate(SOQL.Aggregate.SUM, Schema.Opportunity.Amount)
      .groupByField(Schema.Opportunity.StageName)
      .addAggregate(SOQL.Aggregate.COUNT, Schema.Opportunity.AccountId)
      .addAggregate(SOQL.Aggregate.COUNT_DISTINCT, Schema.Opportunity.AccountId)
      .addAggregate(SOQL.Aggregate.COUNT_DISTINCT, new SOQL.QueryField(new List<Schema.SObjectField>{ Schema.Opportunity.AccountId, Schema.Account.Type }))
      .orderByField(new SOQL.QueryField(new List<Schema.SObjectField>{ Schema.Opportunity.AccountId, Schema.Account.Type }))
      .orderByField(Schema.Opportunity.StageName)
      .orderByAggregate(SOQL.Aggregate.SUM, Schema.Opportunity.Amount)
      .orderByAggregate(SOQL.Aggregate.MIN, Schema.Opportunity.CloseDate, SOQL.SortOrder.DESCENDING)
      .orderByAggregate(SOQL.Aggregate.MAX, new SOQL.QueryField(new List<Schema.SObjectField>{ Schema.Opportunity.AccountId, Schema.Account.LastActivityDate }))
      .filterWhere(Schema.Opportunity.AccountId, SOQL.Operator.NOT_EQUAL_TO, null)
      .limitTo(100)
      .offsetBy(0);

    System.Assert.areEqual(expectedQueryString, aggregateQuery.getQuery());
    List<Schema.AggregateResult> expectedResults = Database.query(expectedQueryString);
    List<Schema.AggregateResult> returnedResults = aggregateQuery.getResults();
    System.Assert.areEqual(expectedResults, returnedResults);
  }
=======
    @IsTest
    static void it_should_be_usable_after_construction() {
        String expectedQueryString = 'SELECT COUNT(Id) COUNT__Id FROM Opportunity';

        AggregateQuery aggregateQuery = new AggregateQuery(Schema.Opportunity.SObjectType);

        System.Assert.areEqual(expectedQueryString, aggregateQuery.getQuery());
        List<Schema.AggregateResult> expectedResults = Database.query(expectedQueryString);
        List<Schema.AggregateResult> returnedResults = aggregateQuery.getResults();
        System.Assert.areEqual(expectedResults, returnedResults);
    }

    @IsTest
    static void it_should_return_results_when_filtering() {
        String expectedQueryString = 'SELECT Type FROM Opportunity WHERE AccountId != null GROUP BY Type';

        AggregateQuery aggregateQuery = new AggregateQuery(Schema.Opportunity.SObjectType)
            .groupByField(Schema.Opportunity.Type)
            .filterWhere(new SOQL.QueryFilter(Schema.Opportunity.AccountId, SOQL.Operator.NOT_EQUAL_TO, null));

        System.Assert.areEqual(expectedQueryString, aggregateQuery.getQuery());
        List<Schema.AggregateResult> expectedResults = Database.query(expectedQueryString);
        List<Schema.AggregateResult> returnedResults = aggregateQuery.getResults();
        System.Assert.areEqual(expectedResults, returnedResults);
    }

    @IsTest
    static void it_should_return_results_when_filtering_with_an_or_statement() {
        String expectedQueryString = 'SELECT Type Type, COUNT(Id) COUNT__Id FROM Account WHERE (AnnualRevenue = null OR Type = null) AND ParentId != null GROUP BY Type';

        AggregateQuery aggregateQuery = new AggregateQuery(Schema.Account.SObjectType)
            .groupByField(Schema.Account.Type)
            .filterWhere(new SOQL.QueryFilter(Schema.Account.ParentId, SOQL.Operator.NOT_EQUAL_TO, null))
            .orFilterWhere(
                new List<SOQL.QueryFilter>{
                    new SOQL.QueryFilter(Schema.Account.Type, SOQL.Operator.EQUALS, null),
                    new SOQL.QueryFilter(Schema.Account.AnnualRevenue, SOQL.Operator.EQUALS, null)
                }
            )
            .addAggregate(SOQL.Aggregate.COUNT, Schema.Account.Id);

        System.Assert.areEqual(expectedQueryString, aggregateQuery.getQuery());
        List<Schema.AggregateResult> expectedResults = Database.query(expectedQueryString);
        List<Schema.AggregateResult> returnedResults = aggregateQuery.getResults();
        System.Assert.areEqual(expectedResults, returnedResults);
    }

    @IsTest
    static void it_should_cache_results() {
        AggregateQuery aggregateQuery = new AggregateQuery(Schema.Opportunity.SObjectType);
        aggregateQuery.cacheResults();
        System.assertEquals(0, Limits.getQueries());

        for (Integer i = 0; i < 3; i++) {
            aggregateQuery.getResults();
        }

        System.assertEquals(1, Limits.getQueries());
    }

    @IsTest
    static void it_should_group_by_cube() {
        String expectedQueryString = 'SELECT Type Type, StageName StageName, SUM(Amount) SUM__Amount FROM Opportunity GROUP BY CUBE(Type, StageName)';

        AggregateQuery aggregateQuery = new AggregateQuery(Schema.Opportunity.SObjectType)
            .groupByField(Schema.Opportunity.Type)
            .groupByField(Schema.Opportunity.StageName)
            .addAggregate(SOQL.Aggregate.SUM, Schema.Opportunity.Amount)
            .usingGroupingDimension(SOQL.GroupingDimension.CUBE);

        System.Assert.areEqual(expectedQueryString, aggregateQuery.getQuery());
        List<Schema.AggregateResult> expectedResults = Database.query(expectedQueryString);
        List<Schema.AggregateResult> returnedResults = aggregateQuery.getResults();
        System.Assert.areEqual(expectedResults, returnedResults);
    }

    @IsTest
    static void it_should_group_by_rollup() {
        String expectedQueryString = 'SELECT Type Type, StageName StageName, SUM(Amount) SUM__Amount FROM Opportunity GROUP BY ROLLUP(Type, StageName)';

        AggregateQuery aggregateQuery = new AggregateQuery(Schema.Opportunity.SObjectType)
            .groupByField(Schema.Opportunity.Type)
            .groupByField(Schema.Opportunity.StageName)
            .addAggregate(SOQL.Aggregate.SUM, Schema.Opportunity.Amount)
            .usingGroupingDimension(SOQL.GroupingDimension.ROLLUP);

        System.Assert.areEqual(expectedQueryString, aggregateQuery.getQuery());
        List<Schema.AggregateResult> expectedResults = Database.query(expectedQueryString);
        List<Schema.AggregateResult> returnedResults = aggregateQuery.getResults();
        System.Assert.areEqual(expectedResults, returnedResults);
    }

    @IsTest
    static void it_should_group_by_having_aggregate() {
        String expectedQueryString = 'SELECT Name Name, COUNT(Id) COUNT__Id FROM Account GROUP BY Name HAVING COUNT(Id) > 2';

        AggregateQuery aggregateQuery = new AggregateQuery(Schema.Account.SObjectType)
            .groupByField(Schema.Account.Name)
            .addAggregate(SOQL.Aggregate.COUNT, Schema.Account.Id)
            .havingAggregate(SOQL.Aggregate.COUNT, Schema.Account.Id, SOQL.Operator.GREATER_THAN, 2);

        System.Assert.areEqual(expectedQueryString, aggregateQuery.getQuery());
        List<Schema.AggregateResult> expectedResults = Database.query(expectedQueryString);
        List<Schema.AggregateResult> returnedResults = aggregateQuery.getResults();
        System.Assert.areEqual(expectedResults, returnedResults);
    }

    @IsTest
    static void it_should_group_by_a_date_function() {
        String expectedQueryString = 'SELECT CALENDAR_MONTH(CloseDate) CALENDAR_MONTH__CloseDate, COUNT(Id) COUNT__Id FROM Opportunity GROUP BY CALENDAR_MONTH(CloseDate)';

        AggregateQuery aggregateQuery = new AggregateQuery(Schema.Opportunity.SObjectType)
            .groupByField(new SOQL.QueryField(SOQL.DateFunction.CALENDAR_MONTH, Schema.Opportunity.CloseDate))
            .addAggregate(SOQL.Aggregate.COUNT, Opportunity.Id);

        System.Assert.areEqual(expectedQueryString, aggregateQuery.getQuery());
        List<Schema.AggregateResult> expectedResults = Database.query(expectedQueryString);
        List<Schema.AggregateResult> returnedResults = aggregateQuery.getResults();
        System.Assert.areEqual(expectedResults, returnedResults);
    }

    @IsTest
    static void it_should_build_a_ridiculous_query_string() {
        String expectedQueryString =
            'SELECT Account.Type, StageName, AVG(Amount) AVG__Amount, COUNT(AccountId) COUNT__AccountId,' +
            ' COUNT_DISTINCT(AccountId) COUNT_DISTINCT__AccountId, COUNT_DISTINCT(OwnerId) COUNT_DISTINCT__OwnerId, COUNT_DISTINCT(Type) COUNT_DISTINCT__Type,' +
            ' MAX(CreatedDate) MAX__CreatedDate, MIN(CreatedDate) MIN__CreatedDate, SUM(Amount) SUM__Amount' +
            ' FROM Opportunity' +
            ' WHERE AccountId != null' +
            ' GROUP BY Account.Type, StageName' +
            ' ORDER BY Account.Type ASC NULLS FIRST, StageName ASC NULLS FIRST, SUM(Amount) ASC NULLS FIRST,' +
            ' MIN(CloseDate) DESC NULLS FIRST, MAX(Account.LastActivityDate) ASC NULLS FIRST' +
            ' LIMIT 100' +
            ' OFFSET 0';

        AggregateQuery aggregateQuery = new AggregateQuery(Schema.Opportunity.SObjectType)
            .addAggregate(SOQL.Aggregate.MAX, Schema.Opportunity.CreatedDate)
            .addAggregate(SOQL.Aggregate.AVG, Schema.Opportunity.Amount)
            .addAggregate(SOQL.Aggregate.COUNT_DISTINCT, Schema.Opportunity.OwnerId)
            .addAggregate(SOQL.Aggregate.MIN, Schema.Opportunity.CreatedDate)
            .groupByField(new SOQL.QueryField(new List<Schema.SObjectField>{ Schema.Opportunity.AccountId, Schema.Account.Type }))
            .addAggregate(SOQL.Aggregate.SUM, Schema.Opportunity.Amount)
            .groupByField(Schema.Opportunity.StageName)
            .addAggregate(SOQL.Aggregate.COUNT, Schema.Opportunity.AccountId)
            .addAggregate(SOQL.Aggregate.COUNT_DISTINCT, Schema.Opportunity.AccountId)
            .addAggregate(
                SOQL.Aggregate.COUNT_DISTINCT,
                new SOQL.QueryField(new List<Schema.SObjectField>{ Schema.Opportunity.AccountId, Schema.Account.Type })
            )
            .orderByField(new SOQL.QueryField(new List<Schema.SObjectField>{ Schema.Opportunity.AccountId, Schema.Account.Type }))
            .orderByField(Schema.Opportunity.StageName)
            .orderByAggregate(SOQL.Aggregate.SUM, Schema.Opportunity.Amount)
            .orderByAggregate(SOQL.Aggregate.MIN, Schema.Opportunity.CloseDate, SOQL.SortOrder.DESCENDING)
            .orderByAggregate(
                SOQL.Aggregate.MAX,
                new SOQL.QueryField(new List<Schema.SObjectField>{ Schema.Opportunity.AccountId, Schema.Account.LastActivityDate })
            )
            .filterWhere(Schema.Opportunity.AccountId, SOQL.Operator.NOT_EQUAL_TO, null)
            .limitTo(100)
            .offsetBy(0);

        System.Assert.areEqual(expectedQueryString, aggregateQuery.getQuery());
        List<Schema.AggregateResult> expectedResults = Database.query(expectedQueryString);
        List<Schema.AggregateResult> returnedResults = aggregateQuery.getResults();
        System.Assert.areEqual(expectedResults, returnedResults);
    }
>>>>>>> Stashed changes
}
