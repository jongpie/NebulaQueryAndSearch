# Nebula Query & Search for Salesforce Apex

A dynamic SOQL query & SOSL search library for Salesforce Apex

## Unlocked Package - no namespace - v3.1.1

[![Install Unlocked Package in a Sandbox](./images/btn-install-unlocked-package-sandbox.png)](https://test.salesforce.com/packaging/installPackage.apexp?p0=04t5Y000001TsMJQA0)
[![Install Unlocked Package in Production](./images/btn-install-unlocked-package-production.png)](https://login.salesforce.com/packaging/installPackage.apexp?p0=04t5Y000001TsMJQA0)

Install with SF CLI:

```shell
sf package install --apex-compile package --wait 20 --security-type AdminsOnly --package 04t5Y000001TsMJQA0
```

Install with SFDX CLI:

```shell
sfdx force:package:install --apexcompile package --wait 20 --securitytype AdminsOnly --package 04t5Y000001TsMJQA0
```

## Unlocked Package - `Nebula` namespace - v3.1.1

[![Install Unlocked Package in a Sandbox](./images/btn-install-unlocked-package-sandbox.png)](https://test.salesforce.com/packaging/installPackage.apexp?p0=04t5Y000001TsMEQA0)
[![Install Unlocked Package in Production](./images/btn-install-unlocked-package-production.png)](https://login.salesforce.com/packaging/installPackage.apexp?p0=04t5Y000001TsMEQA0)

Install with SF CLI:

```shell
sf package install --apex-compile package --wait 20 --security-type AdminsOnly --package 04t5Y000001TsMEQA0
```

Install with SFDX CLI:

```shell
sfdx force:package:install --apexcompile package --wait 20 --securitytype AdminsOnly --package 04t5Y000001TsMEQA0
```

## Features

- Provides chainable builder methods for dyanmically building SOQL queries & SOSL searches in Apex
- Easily add fields to a query based on field level security
- Easily add fields from a field set
- Automatically adds the parent name field for any lookup/master-detail fields
- Adds translations for picklist fields & record types by calling includeLabels()
- Adds localized formatting for number, date, datetime, time, or currency fields by calling includeFormattedValues()
- Leverage query scope to filter results
- Enable query & search caching by simple calling cacheResults()
- Reuse your dynamic SOQL queries to quickly build dynamic SOSL searches

## Overview

There are 3 main builder classes

| &nbsp;      | Query                        | AggregateQuery                               | RecordSearch                                        |
| ----------- | ---------------------------- | -------------------------------------------- | --------------------------------------------------- |
| Super Class | SOQL.cls (Queries)           | SOQL.cls (Queries)                           | SOSL.cls (Searches)                                 |
| Action      | Queries an SObject           | Queries an SObject                           | Searches 1 or more SObjects                         |
| Returns     | `SObject` or `List<SObject>` | `AggregateResult` or `List<AggregateResult>` | `SObject`, `List<SObject>` or `List<List<SObject>>` |

## SOQL SObject Query Examples

**Basic Usage:** Query an object & return the object's ID and display name field (typically the 'Name' field, but some objects use other fields, like Task.Subject and Case.CaseNumber). Since no filters have been added, this query would also return all accounts.

```
List<Account> accounts = new Query(Schema.Account.SObjectType).getResults();
```

**Advanced Usage:** Query an object & leverage the query builder methods. The order of the builder methods does not matter - you can arrange the calls to these methods in any order that you prefer.

```
Query accountQuery = new Query(Schema.Account.SObjectType) // Query the account object
    .addField(Schema.Account.ParentId)                                                 // Include the ParentId field, using SObjectField. The current user must have at least read access to the field
    .addField(Schema.Account.Type, SOQL.FieldCategory.UPDATEABLE)                      // Include the Type field if the current user has access to update it
    .addFields(SOQL.FieldCategory.CUSTOM)                                              // Include all custom fields - only fields that are accessible to the user are included
    .addFieldSet(Schema.Account.MyFieldSet)                                            // Include all fields in a field set that are accessible to the user
    .removeField(Schema.Account.My_Custom_Field__c)                                    // remove a custom field
    .usingScope(SOQL.Scope.MINE)                                                       // Set the query scope
    .filterWhere(Schema.Account.CreatedDate, '=', new SOQL.DateLiteral('LAST_WEEK'))   // Filter on the created date, using a date literal
    .orderBy(Schema.Account.Type)                                                      // Order by a field API name - sort order/nulls defaults to 'Type ASC NULLS FIRST'
    .orderBy(Account.Name, SOQL.SortOrder.ASCENDING)                                   // Order by, using SObjectField & sort order
    .orderBy(Account.AnnualRevenue, SOQL.SortOrder.DESCENDING, false)                  // Order by, using SObjectField, sort order and nulls sort order
    .limitTo(100)                                                                      // Limit the results to 100 records
    .includeLabels()                                                                   // Include labels/translations for any picklist fields or record types. These are aliased using the convention 'FieldName__c_Label'
    .includeFormattedValues()                                                          // Include formatted values for any number, date, time, or currency fields
    .cacheResults()                                                                    // When enabled, the query results are internally cached - any subsequent calls for getResults() will returned cached results instead of executing the query again
    .offsetBy(25);                                                                     // Skip the first 25 results

// Execute the query and store the results in the 'accounts' variable
List<Account> accounts = accountQuery.getResults();

/****** Resulting output *******
SELECT Id, MyCustomDateField__c, MyCustomPicklistField__c, Name,
    format(MyCustomDateField__c) MyCustomDateField__c__Formatted,
    toLabel(MyCustomPicklistField__c) MyCustomPicklistField__c__Label
FROM Account
USING SCOPE MINE
WHERE CreatedDate = LAST_WEEK
ORDER BY Type ASC NULLS FIRST, Name ASC NULLS FIRST, AnnualRevenue DESC NULLS LAST LIMIT 100 OFFSET 25
*******************************/

System.debug(accountQuery.getQuery());
```

## SOSL Search Examples

**Basic Usage:** Search a single object

```java
Query userQuery = new Query(Schema.User.SObjectType); // Create an instance of Query for an SObject - you can include additional fields, filters, etc
RecordSearch userSearch      = new RecordSearch('my search term', userQuery);   // Create a new RecordSearch instance with a search term & instance of Query
List<User> userSearchResults  = userSearch.getFirstResults();                     // RecordSearch returns a list of lists of sobjects - getFirstResults() returns the first list

/****** Resulting output *******
FIND 'my search term' IN ALL FIELDS RETURNING User(Id, Name)
*******************************/

System.debug(userSearch.getSearch());
```

**Advanced Usage:** Search several objects

```java
Query accountQuery  = new Query(Schema.Account.SObjectType);                  // Create an instance of Query for the Account object
Query contactQuery  = new Query(Schema.Contact.SObjectType);                  // Create an instance of Query for the Contact object
Query leadQuery     = new Query(Schema.Lead.SObjectType);                     // Create an instance of Query for the Lead object
List<Query> queries = new List<Query>{contactQuery, accountQuery, leadQuery}; // Add the Query queries to a list

RecordSearch mySearch            = new RecordSearch('my search term', queries); // Create a new RecordSearch instance with a search term & the list of Query queries
List<List<SObject>> searchResults = mySearch.getResults();                        // Returns all search results

/****** Resulting output *******
FIND 'my search term' IN ALL FIELDS RETURNING Account(Id, Name), Contact(Id, Name), Lead(Id, Name)
*******************************/

System.debug(mySearch.getSearch());
```
