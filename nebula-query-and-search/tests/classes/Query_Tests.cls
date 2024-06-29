/*******************************************************************************************************
 * This file is part of the Nebula Query & Search project, released under the MIT License.             *
 * See LICENSE file or go to https://github.com/jongpie/NebulaQueryAndSearch for full license details. *
 ******************************************************************************************************/

@SuppressWarnings(
  'PMD.ApexDoc, PMD.ApexAssertionsShouldIncludeMessage, PMD.ApexUnitTestClassShouldHaveAsserts, PMD.CyclomaticComplexity, PMD.EagerlyLoadedDescribeSObjectResult, PMD.ExcessiveParameterList, PMD.MethodNamingConventions, PMD.NcssMethodCount, PMD.UnusedLocalVariable'
)
@IsTest(IsParallel=true)
private class Query_Tests {

  @IsTest
  static void it_should_construct_a_query_without_binds()
  {
    // SETUP
    String expectedQueryString = 'SELECT Id, Name FROM Account WHERE CreatedDate >= THIS_MONTH';

    // TEST
    Query accountQuery = new Query(Schema.Account.SObjectType)
      .filterWhere(new SOQL.QueryFilter(Schema.Account.CreatedDate, SOQL.Operator.GREATER_THAN_OR_EQUAL_TO, new SOQL.DateLiteral(SOQL.FixedDateLiteral.THIS_MONTH)));

    // VERIFY
    System.Assert.areEqual(expectedQueryString, accountQuery.getQuery());
  }

  @IsTest
  static void it_should_construct_a_query_with_binds()
  {
    // SETUP
    String expectedQueryString = 'SELECT Id, Name FROM Account WHERE CreatedDate >= :dateFilter';

    // TEST
    Query accountQuery = new Query(Schema.Account.SObjectType)
      .filterWhere(new SOQL.QueryFilter(Schema.Account.CreatedDate, SOQL.Operator.GREATER_THAN_OR_EQUAL_TO, Date.today().addMonths(-1), 'dateFilter'));

    // VERIFY
    System.Assert.areEqual(expectedQueryString, accountQuery.getQuery());
  }

  @IsTest
  static void it_should_return_results_for_a_simple_query() {
    String expectedQueryString = 'SELECT Id, Name FROM Account';

    Query simpleAccountQuery = new Query(Schema.Account.SObjectType);

    System.Assert.areEqual(expectedQueryString, simpleAccountQuery.getQuery());
    List<Account> accounts = simpleAccountQuery.getResults();
  }

  @IsTest
  static void it_should_correctly_represent_sets_in_query_filters() {
    String expectedName = 'someName';
    String expectedQueryString = 'SELECT Id, Name FROM Account WHERE Name IN (\'' + expectedName + '\')';

    String actualQuery = new Query(Schema.Account.SObjectType)
      .filterWhere(Schema.Account.Name, SOQL.Operator.IS_IN, new Set<String>{ expectedName })
      .getQuery();

    System.Assert.areEqual(expectedQueryString, actualQuery);
  }

  @IsTest
  static void it_should_return_results_for_an_advanced_query() {
    Datetime now = System.now();
    String expectedQueryString =
      'SELECT Alias, Email, Id, IsActive, Profile.Name, ProfileId' +
      ' FROM User USING SCOPE MINE' +
      ' WHERE IsActive = true' +
      ' AND Profile.Id != \'' +
      System.UserInfo.getProfileId() +
      '\'' +
      ' AND LastModifiedDate <= ' +
      now.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'', 'Greenwich Mean Time') +
      ' AND LastLoginDate >= LAST_N_DAYS:3' +
      ' AND CreatedDate <= LAST_WEEK' +
      ' AND Email != null' +
      ' ORDER BY Profile.CreatedBy.LastModifiedDate ASC NULLS FIRST, Name ASC NULLS FIRST, Email ASC NULLS FIRST' +
      ' LIMIT 100 OFFSET 1 FOR VIEW';
    List<Schema.SObjectField> fieldsToQuery = new List<Schema.SObjectField>{ Schema.User.IsActive, Schema.User.Alias };

    Query userQuery = new Query(Schema.User.SObjectType)
      .addFields(fieldsToQuery)
      .addField(Schema.User.ProfileId)
      .addField(Schema.User.Email, SOQL.FieldCategory.UPDATEABLE)
      .removeField(new SOQL.QueryField(Schema.User.Name))
      .removeField(Schema.User.UserRoleId)
      .includeLabels()
      .includeFormattedValues()
      .usingScope(SOQL.Scope.MINE)
      .filterWhere(Schema.User.IsActive, SOQL.Operator.EQUALS, true)
      .filterWhere(new SOQL.QueryField(Schema.User.SObjectType, 'Profile.Id'), SOQL.Operator.NOT_EQUAL_TO, System.UserInfo.getProfileId())
      .filterWhere(Schema.User.LastModifiedDate, SOQL.Operator.LESS_THAN_OR_EQUAL_TO, now)
      .filterWhere(Schema.User.LastLoginDate, SOQL.Operator.GREATER_THAN_OR_EQUAL_TO, new SOQL.DateLiteral(SOQL.RelativeDateLiteral.LAST_N_DAYS, 3))
      .filterWhere(Schema.User.CreatedDate, SOQL.Operator.LESS_THAN_OR_EQUAL_TO, new SOQL.DateLiteral(SOQL.FixedDateLiteral.LAST_WEEK))
      .filterWhere(Schema.User.Email, SOQL.Operator.NOT_EQUAL_TO, null)
      .orderByField(new SOQL.QueryField(Schema.User.SObjectType, 'Profile.CreatedBy.LastModifiedDate'))
      .orderByField(Schema.User.Name, SOQL.SortOrder.ASCENDING)
      .orderByField(Schema.User.Email)
      .limitTo(100)
      .offsetBy(1)
      .forView();

    System.Assert.areEqual(expectedQueryString, userQuery.getQuery());
    List<User> expectedResults = Database.query(expectedQueryString);
    List<User> returnedResults = userQuery.getResults();
    System.Assert.areEqual(expectedResults, returnedResults);
  }

  @IsTest
  static void it_should_return_results_and_include_grandparent_query_field() {
    String expectedQueryString = 'SELECT Id, Name, Profile.UserLicense.LicenseDefinitionKey FROM User LIMIT 1';
    List<Schema.SObjectField> fieldChain = new List<Schema.SObjectField>{
      Schema.User.ProfileId,
      Schema.Profile.UserLicenseId,
      Schema.UserLicense.LicenseDefinitionKey
    };
    SOQL.QueryField queryField = new SOQL.QueryField(fieldChain);

    Query userQuery = new Query(Schema.User.SObjectType).addField(queryField).limitTo(1);

    System.Assert.areEqual(expectedQueryString, userQuery.getQuery());
    List<User> expectedResults = Database.query(expectedQueryString);
    List<User> returnedResults = userQuery.getResults();
    System.Assert.areEqual(expectedResults, returnedResults);
  }

  @IsTest
  static void it_should_return_results_and_not_include_sobject_type_for_monomorphic_field() {
    String expectedQueryString = 'SELECT Id, Name, Owner.Name, OwnerId FROM Account';

    Query accountQuery = new Query(Schema.Account.SObjectType).addField(new SOQL.QueryField(Schema.Account.OwnerId));

    System.Assert.areEqual(expectedQueryString, accountQuery.getQuery());
    List<Account> accounts = accountQuery.getResults();
  }

  @IsTest
  static void it_should_return_results_and_include_separate_fields_for_for_polymorphic_field() {
    List<String> supportedPolymorphicFieldNames = new List<String>();
    for (Schema.SObjectField field : Schema.Name.SObjectType.getDescribe(Schema.SObjectDescribeOptions.DEFERRED).fields.getMap().values()) {
      Schema.DescribeFieldResult fieldDescribe = field.getDescribe();

      if (!fieldDescribe.isAccessible()) {
        continue;
      }
      supportedPolymorphicFieldNames.add(String.valueOf(field));

      Set<String> referenceFieldNames = new Set<String>{ 'ProfileId', 'RecordTypeId', 'UserRoleId' };
      if (referenceFieldNames.contains(fieldDescribe.getName())) {
        supportedPolymorphicFieldNames.add(fieldDescribe.getRelationshipName() + '.Name');
      }
    }
    supportedPolymorphicFieldNames.sort();
    String expectedQuery =
      'SELECT Id, Subject, TYPEOF Who WHEN Contact THEN Account.Name, AccountId, Id, Name' +
      ' WHEN Lead THEN Company, Id, LeadSource, Name' +
      ' ELSE ' +
      String.join(supportedPolymorphicFieldNames, ', ') +
      ' END' +
      ' FROM Task';

    System.Test.startTest();

    Map<Schema.SObjectType, List<Schema.SObjectField>> fieldsBySObjectType = new Map<Schema.SObjectType, List<Schema.SObjectField>>();

    // Contact fields
    List<Schema.SObjectField> contactFields = new List<Schema.SObjectField>{ Schema.Contact.Id, Schema.Contact.Name, Schema.Contact.AccountId };
    fieldsBySObjectType.put(Schema.Contact.SObjectType, contactFields);

    // Lead fields
    List<Schema.SObjectField> leadFields = new List<Schema.SObjectField>{ Schema.Lead.Id, Schema.Lead.Name, Schema.Lead.Company, Schema.Lead.LeadSource };
    fieldsBySObjectType.put(Schema.Lead.SObjectType, leadFields);

    // Query the task object
    Query taskQuery = new Query(Schema.Task.SObjectType).addPolymorphicFields(Schema.Task.WhoId, fieldsBySObjectType);

    System.Test.stopTest();

    System.Assert.areEqual(expectedQuery, taskQuery.getQuery());
  }

  @IsTest
  static void it_should_return_results_and_include_sobject_type_for_polymorphic_field() {
    String expectedQueryString = 'SELECT Id, Name, Owner.Name, Owner.Type, OwnerId FROM Lead';

    Query leadQuery = new Query(Schema.Lead.SObjectType).addField(new SOQL.QueryField(Schema.Lead.OwnerId));

    System.Assert.areEqual(expectedQueryString, leadQuery.getQuery());
    List<Lead> expectedResults = Database.query(expectedQueryString);
    List<Lead> returnedResults = leadQuery.getResults();
    System.Assert.areEqual(expectedResults, returnedResults);
  }

  @IsTest
  static void it_should_return_results_and_include_related_records() {
    String expectedQueryString = 'SELECT Id, Name, Type, (SELECT Email, Id, Name FROM Contacts) FROM Account';

    Query contactQuery = new Query(Schema.Contact.SObjectType).addField(Schema.Contact.Email);

    Query accountQuery = new Query(Schema.Account.SObjectType)
      .includeRelatedRecords(Schema.Contact.AccountId, contactQuery)
      .addField(new SOQL.QueryField(Schema.Account.Type));

    System.Assert.areEqual(expectedQueryString, accountQuery.getQuery());
    List<Account> accounts = accountQuery.getResults();
  }

  @IsTest
  static void it_should_return_results_when_filtering_with_an_or_statement() {
    String expectedQueryString = 'SELECT Id, Name FROM Account WHERE ParentId != null AND (AnnualRevenue = null OR Type = null)';

    Query accountQuery = new Query(Schema.Account.SObjectType)
      .addField(Schema.Account.AnnualRevenue)
      .orFilterWhere(
        new List<SOQL.QueryFilter>{
          new SOQL.QueryFilter(Schema.Account.Type, SOQL.Operator.EQUALS, null),
          new SOQL.QueryFilter(Schema.Account.AnnualRevenue, SOQL.Operator.EQUALS, null)
        }
      )
      .filterWhere(new SOQL.QueryFilter(Schema.Account.ParentId, SOQL.Operator.NOT_EQUAL_TO, null));

    List<Account> accounts = accountQuery.getResults();
  }

  @IsTest
  static void it_should_return_results_when_filtering_with_binds()
  {
    // SETUP
    String expectedQueryString = 'SELECT Id, Name FROM Account WHERE CreatedDate >= :createdDateFilter';
    List<Account> expectedResults = Database.queryWithBinds(
      expectedQueryString,
      new Map<String, Object> {
        'createdDateFilter' => Date.today()
      },
      System.AccessLevel.SYSTEM_MODE
    );
    Query accountQuery = new Query(Schema.Account.SObjectType)
      .filterWhere(new SOQL.QueryFilter(Schema.Account.CreatedDate, SOQL.Operator.GREATER_THAN_OR_EQUAL_TO, Date.today(), 'createdDateFilter'));

    // TEST
    List<Account> returnedResults = accountQuery.getResults();

    // VERIFY
    System.Assert.areEqual(expectedQueryString, accountQuery.getQuery());
    System.Assert.areEqual(expectedResults, returnedResults);
  }

  @IsTest
  static void it_should_run_with_system_mode() {
    String expectedQueryString = 'SELECT Id, Name FROM Account LIMIT 1';

    Query accountQuery = new Query(Schema.Account.SObjectType)
      .limitTo(1)
      .withAccessLevel(System.AccessLevel.SYSTEM_MODE);

    System.Assert.areEqual(expectedQueryString, accountQuery.getQuery());
    List<Account> expectedResults = Database.query(expectedQueryString);
    List<Account> returnedResults;
    Exception caughtException;
    System.runAs(minimumAccessUser()) {
        try {
            returnedResults = accountQuery.getResults();
        } catch (Exception e) {
            caughtException = e;
        }
    }
    System.Assert.isNull(caughtException, 'Query should not throw exception when run in System Mode');
    System.Assert.areEqual(expectedResults, returnedResults);
  }

  @IsTest
  static void it_should_run_with_user_mode() {
    String expectedQueryString = 'SELECT Id, Name FROM Account LIMIT 1';

    Query accountQuery = new Query(Schema.Account.SObjectType)
      .limitTo(1)
      .withAccessLevel(System.AccessLevel.USER_MODE);

    System.Assert.areEqual(expectedQueryString, accountQuery.getQuery());
    List<Account> expectedResults = Database.query(expectedQueryString);
    List<Account> returnedResults;
    Exception caughtException;
    System.runAs(minimumAccessUser()) {
        try {
            returnedResults = accountQuery.getResults();
        } catch (Exception e) {
            caughtException = e;
        }
    }
    System.Assert.isInstanceOfType(caughtException, System.QueryException.class, 'Query should throw exception when run in User Mode');
    System.Assert.isTrue(caughtException.getMessage().contains('sObject type \'Account\' is not supported'), 'Query should throw exception when run in User Mode');
  }

  @IsTest
  static void it_includes_order_by_statement_for_single_field() {
    String expectedQueryString = 'SELECT Id, Name FROM Lead ORDER BY CreatedDate ASC NULLS FIRST';

    Query leadQuery = new Query(Schema.Lead.SObjectType).orderByField(Schema.Lead.CreatedDate);

    System.Assert.areEqual(expectedQueryString, leadQuery.getQuery());
    List<Lead> expectedResults = Database.query(expectedQueryString);
    List<Lead> returnedResults = leadQuery.getResults();
    System.Assert.areEqual(expectedResults, returnedResults);
  }

  @IsTest
  static void it_marks_query_for_reference() {
    String expectedQueryString = 'SELECT Id, Name FROM Lead FOR REFERENCE';

    Query leadQuery = new Query(Schema.Lead.SObjectType).forReference();

    System.Assert.areEqual(expectedQueryString, leadQuery.getQuery());
    List<Lead> expectedResults = Database.query(expectedQueryString);
    List<Lead> returnedResults = leadQuery.getResults();
    System.Assert.areEqual(expectedResults, returnedResults);
  }

  @IsTest
  static void it_marks_query_for_update() {
    String expectedQueryString = 'SELECT Id, Name FROM Lead FOR UPDATE';

    Query leadQuery = new Query(Schema.Lead.SObjectType).forUpdate();

    System.Assert.areEqual(expectedQueryString, leadQuery.getQuery());
    List<Lead> expectedResults = Database.query(expectedQueryString);
    List<Lead> returnedResults = leadQuery.getResults();
    System.Assert.areEqual(expectedResults, returnedResults);
  }

  @IsTest
  static void it_marks_query_for_view() {
    String expectedQueryString = 'SELECT Id, Name FROM Lead FOR VIEW';

    Query leadQuery = new Query(Schema.Lead.SObjectType).forView();

    System.Assert.areEqual(expectedQueryString, leadQuery.getQuery());
    List<Lead> expectedResults = Database.query(expectedQueryString);
    List<Lead> returnedResults = leadQuery.getResults();
    System.Assert.areEqual(expectedResults, returnedResults);
  }

  @IsTest
  static void it_should_return_results_when_filtering_with_iso_currency() {
    // If multi-currency isn't enabled, then we cannot use IsoCurrency, so skip running this test
    if (!System.UserInfo.isMultiCurrencyOrganization()) {
      return;
    }

    // If multi-currency is enabled, then execute the test
    Query accountQuery = new Query(Schema.Account.SObjectType)
      .addField(Schema.Account.AnnualRevenue)
      .filterWhere(Schema.Account.AnnualRevenue, SOQL.Operator.LESS_THAN, new SOQL.IsoCurrency('USD', 100));
    List<Account> accounts = accountQuery.getResults();
  }

  @IsTest
  static void it_should_cache_query_results_when_enabled() {
    Integer loops = 4;
    Query userQuery = new Query(Schema.User.SObjectType).limitTo(1);

    // First, verify that caching is not enabled by default
    System.Assert.areEqual(0, System.Limits.getQueries());
    for (Integer i = 0; i < loops; i++) {
      userQuery.getResults();
    }
    System.Assert.areEqual(loops, System.Limits.getQueries());

    System.Test.startTest();

    userQuery.cacheResults();
    for (Integer i = 0; i < loops; i++) {
      userQuery.getResults();
    }
    System.Assert.areEqual(1, System.Limits.getQueries());

    System.Test.stopTest();
  }

  @IsTest
  static void it_will_set_a_bind_key()
  {
    // SETUP
    String expectedQueryString = 'SELECT CreatedDate, Id, Name FROM Account WHERE CreatedDate >= :dateFilter ORDER BY CreatedDate ASC NULLS FIRST LIMIT 1';
    List<Account> expectedResults = Database.queryWithBinds(
      expectedQueryString,
      new Map<String, Object> {
        'dateFilter' => Date.today().addDays(-1)
      },
      System.AccessLevel.SYSTEM_MODE
    );
    Query accountQuery = new Query(Schema.Account.SObjectType)
      .addField(Schema.Account.CreatedDate)
      .filterWhere(new SOQL.QueryFilter(Schema.Account.CreatedDate, SOQL.Operator.GREATER_THAN_OR_EQUAL_TO, Date.today().addMonths(-1), 'dateFilter'))
      .orderByField(Schema.Account.CreatedDate, SOQL.SortOrder.ASCENDING)
      .limitTo(1);

    // TEST
    accountQuery.setBind('dateFilter', Date.today().addDays(-1));
    List<Account> returnedResults = accountQuery.getResults();

    // VERIFY
    System.Assert.areEqual(expectedQueryString, accountQuery.getQuery());
    System.Assert.areEqual(expectedResults, returnedResults);
    if (!returnedResults.isEmpty())
    {
      System.Assert.isFalse(returnedResults[0].CreatedDate < Date.today().addDays(-1));
    }
  }

  @IsTest
  static void it_will_set_multiple_bind_keys()
  {
    // SETUP
    String expectedQueryString = 'SELECT CreatedDate, Id, Name FROM Account WHERE CreatedDate >= :minDateFilter AND CreatedDate < :maxDateFilter ORDER BY CreatedDate ASC NULLS FIRST LIMIT 1';
    List<Account> expectedResults = Database.queryWithBinds(
      expectedQueryString,
      new Map<String, Object> {
        'minDateFilter' => Date.today().addDays(-7),
        'maxDateFilter' => Date.today()
      },
      System.AccessLevel.SYSTEM_MODE
    );
    Query accountQuery = new Query(Schema.Account.SObjectType)
      .addField(Schema.Account.CreatedDate)
      .filterWhere(new SOQL.QueryFilter(Schema.Account.CreatedDate, SOQL.Operator.GREATER_THAN_OR_EQUAL_TO, Date.today().addMonths(-1), 'minDateFilter'))
      .filterWhere(new SOQL.QueryFilter(Schema.Account.CreatedDate, SOQL.Operator.LESS_THAN, Date.today().addDays(-1), 'maxDateFilter'))
      .orderByField(Schema.Account.CreatedDate, SOQL.SortOrder.ASCENDING)
      .limitTo(1);

    // TEST
    accountQuery.setBind('minDateFilter', Date.today().addDays(-7));
    accountQuery.setBind('maxDateFilter', Date.today());
    List<Account> returnedResults = accountQuery.getResults();

    // VERIFY
    System.Assert.areEqual(expectedQueryString, accountQuery.getQuery());
    System.Assert.areEqual(expectedResults, returnedResults);
    if (!returnedResults.isEmpty())
    {
      System.Assert.isFalse(returnedResults[0].CreatedDate < Date.today().addDays(-7));
      System.Assert.isFalse(returnedResults[0].CreatedDate >= Date.today());
    }
  }

  @IsTest
  static void it_will_remove_a_bind_key()
  {
    // SETUP
    String expectedQueryString = 'SELECT CreatedDate, Id, Name FROM Account WHERE CreatedDate >= 2000-01-01T05:00:00Z';
    Query accountQuery = new Query(Schema.Account.SObjectType)
      .addField(Schema.Account.CreatedDate)
      .filterWhere(new SOQL.QueryFilter(Schema.Account.CreatedDate, SOQL.Operator.GREATER_THAN_OR_EQUAL_TO, Datetime.newInstance(2000, 1, 1), 'dateFilter'));

    // TEST
    accountQuery.removeBind('dateFilter');

    // VERIFY
    System.Assert.areEqual(expectedQueryString, accountQuery.getQuery());
  }

  @IsTest
  static void it_will_clear_all_bind_keys()
  {
    // SETUP
    String expectedQueryString = 'SELECT CreatedDate, Id, Name FROM Account WHERE CreatedDate >= 2000-01-01T05:00:00Z AND CreatedDate < 2001-01-01T05:00:00Z';
    Query accountQuery = new Query(Schema.Account.SObjectType)
      .addField(Schema.Account.CreatedDate)
      .filterWhere(new SOQL.QueryFilter(Schema.Account.CreatedDate, SOQL.Operator.GREATER_THAN_OR_EQUAL_TO, Datetime.newInstance(2000, 1, 1), 'minDateFilter'))
      .filterWhere(new SOQL.QueryFilter(Schema.Account.CreatedDate, SOQL.Operator.LESS_THAN, Datetime.newInstance(2001, 1, 1), 'maxDateFilter'));

    // TEST
    accountQuery.clearBinds();

    // VERIFY
    System.Assert.areEqual(expectedQueryString, accountQuery.getQuery());
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
  static void it_will_generate_a_bind_key()
  {
    // SETUP
    String expectedQueryString = 'SELECT CreatedDate, Id, Name FROM Account WHERE CreatedDate >= :bindVar0 ORDER BY CreatedDate ASC NULLS FIRST LIMIT 1';
    List<Account> expectedResults = Database.queryWithBinds(
      expectedQueryString,
      new Map<String, Object> {
        'bindVar0' => Date.today().addDays(-1)
      },
      System.AccessLevel.SYSTEM_MODE
    );
    Query accountQuery = new Query(Schema.Account.SObjectType)
      .generateBindVariableKeys()
      .addField(Schema.Account.CreatedDate)
      .filterWhere(new SOQL.QueryFilter(Schema.Account.CreatedDate, SOQL.Operator.GREATER_THAN_OR_EQUAL_TO, Date.today().addMonths(-1)))
      .orderByField(Schema.Account.CreatedDate, SOQL.SortOrder.ASCENDING)
      .limitTo(1);

    // TEST
    List<Account> returnedResults = accountQuery.getResults();

    // VERIFY
    System.Assert.areEqual(expectedQueryString, accountQuery.getQuery());
    System.Assert.areEqual(expectedResults, returnedResults);
    if (!returnedResults.isEmpty())
    {
      System.Assert.isFalse(returnedResults[0].CreatedDate < Date.today().addDays(-1));
    }
  }

  @IsTest
  static void it_will_generate_a_bind_key_when_instructed_before_filter_is_added()
  {
    // SETUP
    String expectedQueryString = 'SELECT CreatedDate, Id, Name FROM Account WHERE CreatedDate >= :bindVar0 ORDER BY CreatedDate ASC NULLS FIRST LIMIT 1';
    List<Account> expectedResults = Database.queryWithBinds(
      expectedQueryString,
      new Map<String, Object> {
        'bindVar0' => Date.today().addDays(-1)
      },
      System.AccessLevel.SYSTEM_MODE
    );
    Query accountQuery = new Query(Schema.Account.SObjectType)
      .generateBindVariableKeys()
      .addField(Schema.Account.CreatedDate)
      .filterWhere(new SOQL.QueryFilter(Schema.Account.CreatedDate, SOQL.Operator.GREATER_THAN_OR_EQUAL_TO, Date.today().addMonths(-1)))
      .orderByField(Schema.Account.CreatedDate, SOQL.SortOrder.ASCENDING)
      .limitTo(1);

    // TEST
    List<Account> returnedResults = accountQuery.getResults();

    // VERIFY
    System.Assert.areEqual(expectedQueryString, accountQuery.getQuery());
    System.Assert.areEqual(expectedResults, returnedResults);
    if (!returnedResults.isEmpty())
    {
      System.Assert.isFalse(returnedResults[0].CreatedDate < Date.today().addDays(-1));
    }
  }

  @IsTest
  static void it_will_generate_a_bind_key_when_instructed_after_filter_is_added()
  {
    // SETUP
    String expectedQueryString = 'SELECT CreatedDate, Id, Name FROM Account WHERE CreatedDate >= :bindVar0 ORDER BY CreatedDate ASC NULLS FIRST LIMIT 1';
    List<Account> expectedResults = Database.queryWithBinds(
      expectedQueryString,
      new Map<String, Object> {
        'bindVar0' => Date.today().addDays(-1)
      },
      System.AccessLevel.SYSTEM_MODE
    );
    Query accountQuery = new Query(Schema.Account.SObjectType)
      .addField(Schema.Account.CreatedDate)
      .filterWhere(new SOQL.QueryFilter(Schema.Account.CreatedDate, SOQL.Operator.GREATER_THAN_OR_EQUAL_TO, Date.today().addMonths(-1)))
      .orderByField(Schema.Account.CreatedDate, SOQL.SortOrder.ASCENDING)
      .limitTo(1)
      .generateBindVariableKeys();

    // TEST
    List<Account> returnedResults = accountQuery.getResults();

    // VERIFY
    System.Assert.areEqual(expectedQueryString, accountQuery.getQuery());
    System.Assert.areEqual(expectedResults, returnedResults);
    if (!returnedResults.isEmpty())
    {
      System.Assert.isFalse(returnedResults[0].CreatedDate < Date.today().addDays(-1));
    }
  }

  @IsTest
  static void it_will_not_generate_a_bind_key_if_already_specified()
  {
    // SETUP
    String expectedQueryString = 'SELECT CreatedDate, Id, Name FROM Account WHERE CreatedDate >= :dateFilter ORDER BY CreatedDate ASC NULLS FIRST LIMIT 1';
    List<Account> expectedResults = Database.queryWithBinds(
      expectedQueryString,
      new Map<String, Object> {
        'dateFilter' => Date.today().addDays(-1)
      },
      System.AccessLevel.SYSTEM_MODE
    );
    Query accountQuery = new Query(Schema.Account.SObjectType)
      .addField(Schema.Account.CreatedDate)
      .filterWhere(new SOQL.QueryFilter(Schema.Account.CreatedDate, SOQL.Operator.GREATER_THAN_OR_EQUAL_TO, Date.today().addMonths(-1), 'dateFilter'))
      .orderByField(Schema.Account.CreatedDate, SOQL.SortOrder.ASCENDING)
      .limitTo(1)
      .generateBindVariableKeys();

    // TEST
    List<Account> returnedResults = accountQuery.getResults();

    // VERIFY
    System.Assert.areEqual(expectedQueryString, accountQuery.getQuery());
    System.Assert.areEqual(expectedResults, returnedResults);
    if (!returnedResults.isEmpty())
    {
      System.Assert.isFalse(returnedResults[0].CreatedDate < Date.today().addDays(-1));
    }
  }

  @IsTest
  static void it_will_generate_a_bind_key_if_removed()
  {
    // SETUP
    String expectedQueryString = 'SELECT CreatedDate, Id, Name FROM Account WHERE CreatedDate >= :bindVar0 ORDER BY CreatedDate ASC NULLS FIRST LIMIT 1';
    List<Account> expectedResults = Database.queryWithBinds(
      expectedQueryString,
      new Map<String, Object> {
        'bindVar0' => Date.today().addDays(-1)
      },
      System.AccessLevel.SYSTEM_MODE
    );
    Query accountQuery = new Query(Schema.Account.SObjectType)
      .addField(Schema.Account.CreatedDate)
      .filterWhere(new SOQL.QueryFilter(Schema.Account.CreatedDate, SOQL.Operator.GREATER_THAN_OR_EQUAL_TO, Date.today().addMonths(-1), 'dateFilter'))
      .orderByField(Schema.Account.CreatedDate, SOQL.SortOrder.ASCENDING)
      .limitTo(1)
      .removeBind('dateFilter')
      .generateBindVariableKeys();

    // TEST
    List<Account> returnedResults = accountQuery.getResults();

    // VERIFY
    System.Assert.areEqual(expectedQueryString, accountQuery.getQuery());
    System.Assert.areEqual(expectedResults, returnedResults);
    if (!returnedResults.isEmpty())
    {
      System.Assert.isFalse(returnedResults[0].CreatedDate < Date.today().addDays(-1));
    }
  }

}
