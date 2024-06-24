/*******************************************************************************************************
 * This file is part of the Nebula Query & Search project, released under the MIT License.             *
 * See LICENSE file or go to https://github.com/jongpie/NebulaQueryAndSearch for full license details. *
 ******************************************************************************************************/

@SuppressWarnings(
  'PMD.ApexDoc, PMD.ApexAssertionsShouldIncludeMessage, PMD.ApexUnitTestClassShouldHaveAsserts, PMD.CyclomaticComplexity, PMD.EagerlyLoadedDescribeSObjectResult, PMD.ExcessiveParameterList, PMD.MethodNamingConventions, PMD.NcssMethodCount, PMD.UnusedLocalVariable'
)
@IsTest(IsParallel=true)
private class AggregateQuery_Tests {

  @IsTest
  static void it_should_construct_a_count_query_without_binds()
  {
    // SETUP
    String expectedQueryString = 'SELECT COUNT() FROM Opportunity WHERE AccountId != null';

    // TEST
    AggregateQuery aggregateQuery = new AggregateQuery(Schema.Opportunity.SObjectType)
      .filterWhere(new SOQL.QueryFilter(Schema.Opportunity.AccountId, SOQL.Operator.NOT_EQUAL_TO, null));

    // VERIFY
    System.Assert.areEqual(expectedQueryString, aggregateQuery.getCountQuery());
  }

  @IsTest
  static void it_should_construct_a_count_query_with_binds()
  {
    // SETUP
    String expectedQueryString = 'SELECT COUNT() FROM Opportunity WHERE AccountId != :accountIdFilter';

    // TEST
    AggregateQuery aggregateQuery = new AggregateQuery(Schema.Opportunity.SObjectType)
      .filterWhere(new SOQL.QueryFilter(Schema.Opportunity.AccountId, SOQL.Operator.NOT_EQUAL_TO, null, 'accountIdFilter'));

    // VERIFY
    System.Assert.areEqual(expectedQueryString, aggregateQuery.getCountQuery());
  }

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
  static void it_should_return_count_result_when_filtering_with_binds()
  {
    // SETUP
    String expectedQueryString = 'SELECT COUNT() FROM Opportunity WHERE AccountId != :accountIdFilter';
    Integer expectedResult = Database.countQueryWithBinds(
      expectedQueryString,
      new Map<String, Object> {
        'accountIdFilter' => null
      },
      System.AccessLevel.SYSTEM_MODE
    );
    AggregateQuery aggregateQuery = new AggregateQuery(Schema.Opportunity.SObjectType)
      .filterWhere(new SOQL.QueryFilter(Schema.Opportunity.AccountId, SOQL.Operator.NOT_EQUAL_TO, null, 'accountIdFilter'));

    // TEST
    Integer returnedResult = aggregateQuery.getResultCount();

    // VERIFY
    System.Assert.areEqual(expectedQueryString, aggregateQuery.getCountQuery());
    System.Assert.areEqual(expectedResult, returnedResult);
  }

  @IsTest
  static void it_should_return_results_when_filtering_with_binds()
  {
    // SETUP
    String expectedQueryString = 'SELECT Type FROM Opportunity WHERE AccountId != :accountIdFilter GROUP BY Type';
    List<Schema.AggregateResult> expectedResults = Database.queryWithBinds(
      expectedQueryString,
      new Map<String, Object> {
        'accountIdFilter' => null
      },
      System.AccessLevel.SYSTEM_MODE
    );
    AggregateQuery aggregateQuery = new AggregateQuery(Schema.Opportunity.SObjectType)
      .groupByField(Schema.Opportunity.Type)
      .filterWhere(new SOQL.QueryFilter(Schema.Opportunity.AccountId, SOQL.Operator.NOT_EQUAL_TO, null, 'accountIdFilter'));

    // TEST
    List<Schema.AggregateResult> returnedResults = aggregateQuery.getResults();

    // VERIFY
    System.Assert.areEqual(expectedQueryString, aggregateQuery.getQuery());
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
    System.assertEquals(0, System.Limits.getQueries());

    for (Integer i = 0; i < 3; i++) {
      aggregateQuery.getResults();
    }

    System.assertEquals(1, System.Limits.getQueries());
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
  static void it_should_group_by_having_aggregate_with_binds()
  {
    // SETUP
    String expectedQueryString = 'SELECT Name, COUNT(Id) COUNT__Id FROM Account GROUP BY Name HAVING COUNT(Id) > :minCount';
    List<Schema.AggregateResult> expectedResults = Database.queryWithBinds(
      expectedQueryString,
      new Map<String, Object> {
        'minCount' => 2
      },
      System.AccessLevel.SYSTEM_MODE
    );
    AggregateQuery aggregateQuery = new AggregateQuery(Schema.Account.SObjectType)
      .groupByField(Schema.Account.Name)
      .addAggregate(SOQL.Aggregate.COUNT, Schema.Account.Id)
      .havingAggregate(SOQL.Aggregate.COUNT, Schema.Account.Id, SOQL.Operator.GREATER_THAN, 2, 'minCount');

    // TEST
    List<Schema.AggregateResult> returnedResults = aggregateQuery.getResults();

    // VERIFY
    System.Assert.areEqual(expectedQueryString, aggregateQuery.getQuery());
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
  static void it_should_run_with_system_mode() {
    String expectedQueryString = 'SELECT COUNT(Id) COUNT__Id FROM Opportunity';

    AggregateQuery aggregateQuery = new AggregateQuery(Schema.Opportunity.SObjectType)
      .addAggregate(SOQL.Aggregate.COUNT, Opportunity.Id)
      .withAccessLevel(System.AccessLevel.SYSTEM_MODE);

    System.Assert.areEqual(expectedQueryString, aggregateQuery.getQuery());
    List<Schema.AggregateResult> expectedResults = Database.query(expectedQueryString);
    List<Schema.AggregateResult> returnedResults;
    Exception caughtException;
    System.runAs(minimumAccessUser()) {
        try {
            returnedResults = aggregateQuery.getResults();
        } catch (Exception e) {
            caughtException = e;
        }
    }
    System.Assert.isNull(caughtException, 'Query should not throw exception when run in System Mode');
    System.Assert.areEqual(expectedResults, returnedResults);
  }

  @IsTest
  static void it_should_run_with_user_mode() {
    String expectedQueryString = 'SELECT COUNT(Id) COUNT__Id FROM Opportunity';

    AggregateQuery aggregateQuery = new AggregateQuery(Schema.Opportunity.SObjectType)
      .addAggregate(SOQL.Aggregate.COUNT, Opportunity.Id)
      .withAccessLevel(System.AccessLevel.USER_MODE);

    System.Assert.areEqual(expectedQueryString, aggregateQuery.getQuery());
    List<Schema.AggregateResult> expectedResults = Database.query(expectedQueryString);
    List<Schema.AggregateResult> returnedResults;
    Exception caughtException;
    System.runAs(minimumAccessUser()) {
        try {
            returnedResults = aggregateQuery.getResults();
        } catch (Exception e) {
            caughtException = e;
        }
    }
    System.Assert.isInstanceOfType(caughtException, System.QueryException.class, 'Query should throw exception when run in User Mode');
    System.Assert.isTrue(caughtException.getMessage().contains('sObject type \'Opportunity\' is not supported'), 'Query should throw exception when run in User Mode');
  }

  @IsTest
  static void it_should_build_a_ridiculous_query_string() {
    String expectedQueryString =
      'SELECT Account.Type, StageName, AVG(Amount) AVG__Amount, COUNT(AccountId) COUNT__AccountId,' +
      ' COUNT_DISTINCT(AccountId) COUNT_DISTINCT__AccountId, COUNT_DISTINCT(OwnerId) COUNT_DISTINCT__OwnerId, COUNT_DISTINCT(Type) COUNT_DISTINCT__Type,' +
      ' MAX(CreatedDate) MAX__CreatedDate, MIN(CreatedDate) MIN__CreatedDate, SUM(Amount) SUM__Amount' +
      ' FROM Opportunity' +
      ' WHERE AccountId != null AND CreatedDate >= :createdDateFilter' +
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
      .filterWhere(Schema.Opportunity.CreatedDate, SOQL.Operator.GREATER_THAN_OR_EQUAL_TO, Date.today(), 'createdDateFilter')
      .limitTo(100)
      .offsetBy(0);

    System.Assert.areEqual(expectedQueryString, aggregateQuery.getQuery());
    List<Schema.AggregateResult> expectedResults = Database.queryWithBinds(
      expectedQueryString,
      new Map<String, Object> {
        'createdDateFilter' => Date.today()
      },
      System.AccessLevel.SYSTEM_MODE
    );
    List<Schema.AggregateResult> returnedResults = aggregateQuery.getResults();
    System.Assert.areEqual(expectedResults, returnedResults);
  }

  @IsTest
  static void it_will_set_a_bind_variable()
  {
    // SETUP
    String expectedQueryString = 'SELECT MIN(CreatedDate) MIN__CreatedDate FROM Account WHERE CreatedDate >= :dateFilter';
    List<Schema.AggregateResult> expectedResults = Database.queryWithBinds(
      expectedQueryString,
      new Map<String, Object> {
        'dateFilter' => Date.today().addDays(-1)
      },
      System.AccessLevel.SYSTEM_MODE
    );
    AggregateQuery aggregateQuery = new AggregateQuery(Schema.Account.SObjectType)
      .addAggregate(SOQL.Aggregate.MIN, Schema.Account.CreatedDate)
      .filterWhere(new SOQL.QueryFilter(Schema.Account.CreatedDate, SOQL.Operator.GREATER_THAN_OR_EQUAL_TO, Date.today().addMonths(-1), 'dateFilter'));

    // TEST
    aggregateQuery.setBind('dateFilter', Date.today().addDays(-1));
    List<Schema.AggregateResult> returnedResults = aggregateQuery.getResults();

    // VERIFY
    System.Assert.areEqual(expectedQueryString, aggregateQuery.getQuery());
    System.Assert.areEqual(expectedResults, returnedResults);
    if (!returnedResults.isEmpty())
    {
      System.Assert.isFalse((Date)returnedResults[0].get('MIN__CreatedDate') < Date.today().addDays(-1));
    }
  }

  @IsTest
  static void it_will_set_multiple_bind_variables()
  {
    // SETUP
    String expectedQueryString = 'SELECT MAX(CreatedDate) MAX__CreatedDate, MIN(CreatedDate) MIN__CreatedDate FROM Account WHERE CreatedDate < :maxDateFilter AND CreatedDate >= :minDateFilter';
    List<Schema.AggregateResult> expectedResults = Database.queryWithBinds(
      expectedQueryString,
      new Map<String, Object> {
        'minDateFilter' => Date.today().addDays(-7),
        'maxDateFilter' => Date.today()
      },
      System.AccessLevel.SYSTEM_MODE
    );
    AggregateQuery aggregateQuery = new AggregateQuery(Schema.Account.SObjectType)
      .addAggregate(SOQL.Aggregate.MIN, Schema.Account.CreatedDate)
      .addAggregate(SOQL.Aggregate.MAX, Schema.Account.CreatedDate)
      .filterWhere(new SOQL.QueryFilter(Schema.Account.CreatedDate, SOQL.Operator.GREATER_THAN_OR_EQUAL_TO, Date.today().addMonths(-1), 'minDateFilter'))
      .filterWhere(new SOQL.QueryFilter(Schema.Account.CreatedDate, SOQL.Operator.LESS_THAN, Date.today().addDays(-1), 'maxDateFilter'));

    // TEST
    aggregateQuery.setBind('minDateFilter', Date.today().addDays(-7));
    aggregateQuery.setBind('maxDateFilter', Date.today());
    List<Schema.AggregateResult> returnedResults = aggregateQuery.getResults();

    // VERIFY
    System.Assert.areEqual(expectedQueryString, aggregateQuery.getQuery());
    System.Assert.areEqual(expectedResults, returnedResults);
    if (!returnedResults.isEmpty())
    {
      System.Assert.isFalse((Date)returnedResults[0].get('MIN__CreatedDate') < Date.today().addDays(-7));
      System.Assert.isFalse((Date)returnedResults[0].get('MAX__CreatedDate') >= Date.today());
    }
  }

  @IsTest
  static void it_will_remove_a_bind_variable()
  {
    // SETUP
    String expectedQueryString = 'SELECT MIN(CreatedDate) MIN__CreatedDate FROM Account WHERE CreatedDate >= :dateFilter';
    AggregateQuery aggregateQuery = new AggregateQuery(Schema.Account.SObjectType)
      .addAggregate(SOQL.Aggregate.MIN, Schema.Account.CreatedDate)
      .filterWhere(new SOQL.QueryFilter(Schema.Account.CreatedDate, SOQL.Operator.GREATER_THAN_OR_EQUAL_TO, Date.today().addMonths(-1), 'dateFilter'));

    // TEST
    aggregateQuery.removeBind('dateFilter');
    Exception caughtException;
    try {
      List<Schema.AggregateResult> returnedResults = aggregateQuery.getResults();
    }
    catch (Exception e) {
      caughtException = e;
    }

    // VERIFY
    System.Assert.areEqual(expectedQueryString, aggregateQuery.getQuery());
    System.Assert.isInstanceOfType(caughtException, QueryException.class);
    System.Assert.areEqual('Key \'dateFilter\' does not exist in the bindMap', caughtException.getMessage());
  }

  @IsTest
  static void it_will_clear_all_bind_variables()
  {
    // SETUP
    String expectedQueryString = 'SELECT MAX(CreatedDate) MAX__CreatedDate, MIN(CreatedDate) MIN__CreatedDate FROM Account WHERE CreatedDate < :maxDateFilter AND CreatedDate >= :minDateFilter';
    AggregateQuery aggregateQuery = new AggregateQuery(Schema.Account.SObjectType)
      .addAggregate(SOQL.Aggregate.MIN, Schema.Account.CreatedDate)
      .addAggregate(SOQL.Aggregate.MAX, Schema.Account.CreatedDate)
      .filterWhere(new SOQL.QueryFilter(Schema.Account.CreatedDate, SOQL.Operator.GREATER_THAN_OR_EQUAL_TO, Date.today().addMonths(-1), 'minDateFilter'))
      .filterWhere(new SOQL.QueryFilter(Schema.Account.CreatedDate, SOQL.Operator.LESS_THAN, Date.today().addDays(-1), 'maxDateFilter'));

    // TEST
    aggregateQuery.clearBinds();
    Exception caughtException;
    try {
      List<Schema.AggregateResult> returnedResults = aggregateQuery.getResults();
    }
    catch (Exception e) {
      caughtException = e;
    }

    // VERIFY
    System.Assert.areEqual(expectedQueryString, aggregateQuery.getQuery());
    System.Assert.isInstanceOfType(caughtException, QueryException.class);
    System.Assert.areEqual('Key \'maxDateFilter\' does not exist in the bindMap', caughtException.getMessage());
  }

  static User minimumAccessUser() {
    return new User(
      Alias = 'newUser',
      Email = 'newuser@testorg.com',
      EmailEncodingKey = 'UTF-8',
      LastName = 'Testing',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      ProfileId = [SELECT Id FROM Profile WHERE Name = 'Minimum Access - Salesforce'].Id,
      TimeZoneSidKey = 'GMT',
      UserName = 'newuser@testorg.com'
    );
  }

  @IsTest
  static void it_will_generate_a_bind_variable_for_a_having_filter()
  {
    // SETUP
    String expectedQueryString = 'SELECT ParentId, MIN(CreatedDate) MIN__CreatedDate FROM Account GROUP BY ParentId HAVING MIN(CreatedDate) >= :bindVar0';
    List<Schema.AggregateResult> expectedResults = Database.queryWithBinds(
      expectedQueryString,
      new Map<String, Object> {
        'bindVar0' => Date.today().addDays(-1)
      },
      System.AccessLevel.SYSTEM_MODE
    );
    AggregateQuery aggregateQuery = new AggregateQuery(Schema.Account.SObjectType)
      .generateBindVariableKeys()
      .addAggregate(SOQL.Aggregate.MIN, Schema.Account.CreatedDate)
      .groupByField(Account.ParentId)
      .havingAggregate(SOQL.Aggregate.MIN, Schema.Account.CreatedDate, SOQL.Operator.GREATER_THAN_OR_EQUAL_TO, Date.today().addMonths(-1));

    // TEST
    List<Schema.AggregateResult> returnedResults = aggregateQuery.getResults();

    // VERIFY
    System.Assert.areEqual(expectedQueryString, aggregateQuery.getQuery());
    System.Assert.areEqual(expectedResults, returnedResults);
    if (!returnedResults.isEmpty())
    {
      System.Assert.isFalse((Date)returnedResults[0].get('MIN__CreatedDate') < Date.today().addDays(-1));
    }
  }

  @IsTest
  static void it_will_generate_a_bind_variable_for_a_where_filter()
  {
    // SETUP
    String expectedQueryString = 'SELECT MIN(CreatedDate) MIN__CreatedDate FROM Account WHERE CreatedDate >= :bindVar0';
    List<Schema.AggregateResult> expectedResults = Database.queryWithBinds(
      expectedQueryString,
      new Map<String, Object> {
        'bindVar0' => Date.today().addDays(-1)
      },
      System.AccessLevel.SYSTEM_MODE
    );
    AggregateQuery aggregateQuery = new AggregateQuery(Schema.Account.SObjectType)
      .generateBindVariableKeys()
      .addAggregate(SOQL.Aggregate.MIN, Schema.Account.CreatedDate)
      .filterWhere(new SOQL.QueryFilter(Schema.Account.CreatedDate, SOQL.Operator.GREATER_THAN_OR_EQUAL_TO, Date.today().addMonths(-1)));

    // TEST
    List<Schema.AggregateResult> returnedResults = aggregateQuery.getResults();

    // VERIFY
    System.Assert.areEqual(expectedQueryString, aggregateQuery.getQuery());
    System.Assert.areEqual(expectedResults, returnedResults);
    if (!returnedResults.isEmpty())
    {
      System.Assert.isFalse((Date)returnedResults[0].get('MIN__CreatedDate') < Date.today().addDays(-1));
    }
  }

}
