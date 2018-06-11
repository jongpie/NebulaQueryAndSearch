# Nebula Query & Search
A lightweight Apex library for easily building dynamic SOQL queries & SOSL searches<br /><br />
[![Travis CI](https://img.shields.io/travis/jongpie/NebulaLogger/master.svg)](https://travis-ci.org/jongpie/NebulaLogger)

<a href="https://githubsfdeploy.herokuapp.com" target="_blank">
    <img alt="Deploy to Salesforce" src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png">
</a>

## Features
* Easily add a field if the field meets the category specified, using the Soql.FieldCategory enum
* Easily add any fields that are accessible, updateable, standard or custom, using the Soql.FieldCategory enum
* Easily add fields from a field set
* Automatically adds the parent name field for any lookup/master-detail fields
* Adds translations for picklist fields & record types by calling includeLabels()
* Adds localized formatting for number, date, datetime, time, or currency fields by calling includeFormattedValues()
* Leverage query scope to filter results
* Reuse your dynamic SOQL queries to quickly build dynamic SOSL searches

## SOQL Query Examples
**Basic Usage:** Query an object & return the object's ID and display name field (typically the 'Name' field, but some objects use other fields, like Task.Subject and Case.CaseNumber). Since no filters have been added, this query would also return all accounts.

```
List<Account> accounts = new Soql(Schema.Account.SobjectType).getQueryResults();
```

**Advanced Usage:** Query an object & leverage the query builder methods. The order of the builder methods does not matter - you can arrange the calls to these methods in any order that you prefer.

```
Soql accountQuery = new Soql(Schema.Account)                                         // Query the account object
    .addField(Schema.Account.ParentId)                                               // Include the ParentId field, using SObjectField. The current user must have at least read access to the field
    .addField(Schema.Account.Type, Soql.FieldCategory.UPDATEABLE)                    // Include the Type field if the current user has access to update it
    .addFields(Soql.FieldCategory.CUSTOM)                                            // Include all custom fields - Soql.cls only includes fields that are accessible to the user
    .addFields(myAccountFieldSet)                                                    // Include all fields in a field set that are accessible to the user
    .removeField(Schema.Account.My_custom_Field__c)                                  // remove a custom field
    .usingScope(Soql.Scope.MINE)                                                     // Set the query scope
    .filterWhere(Schema.Account.CreatedDate, '=', new Soql.DateLiteral('LAST_WEEK')) // Filter on the created date, using a date literal
    .orderBy(Schema.Account.Type)                                                    // Order by a field API name - sort order/nulls defaults to 'Type ASC NULLS FIRST'
    .orderBy(Account.Name, Soql.SortOrder.ASCENDING)                                 // Order by, using SObjectField & sort order
    .orderBy(Account.AnnualRevenue, Soql.SortOrder.DESCENDING, false)                // Order by, using SObjectField, sort order and nulls sort order
    .limitCount(100)                                                                 // Limit the results to 100 records
    .includeLabels()                                                                 // Include labels/translations for any picklist fields or record types. These are aliased using the convention 'FieldName__c_Label'
    .includeFormattedValues()                                                        // Include formatted values for any number, date, time, or currency fields
    .cacheResults()                                                                  // When enabled, the query results are internally cached - any subsequent calls for getQueryResults() will returned cached results instead of executing the query again
    .offset(25);                                                                     // Skip the first 25 results

// Execute the query and store the results in the 'accounts' variable
List<Account> accounts = accountQuery.getQueryResults();
```

## SOSL Search Examples
**Basic Usage:** Search a single object

```
Soql userQuery               = new Soql(Schema.User.SobjectType);     // Create an instance of Soql for an Sobject - you can include additional fields, filters, etc
Sosl userSearch              = new Sosl('my search term', userQuery); // Create a new Sosl instance with a search term & instance of Soql
List<User> userSearchResults = userSearch.getFirstSearchResults();    // Sosl returns a list of lists of sobjects - getFirstSearchResults() returns the first list
```

**Advanced Usage:** Search several objects

```
Soql accountQuery  = new Soql(Schema.Account.SobjectType);                  // Create an instance of Soql for the Account object
Soql contactQuery  = new Soql(Schema.Contact.SobjectType);                  // Create an instance of Soql for the Contact object
Soql leadQuery     = new Soql(Schema.Lead.SobjectType);                     // Create an instance of Soql for the Lead object
List<Soql> queries = new List<Soql>{accountQuery, contactQuery, leadQuery}; // Add the Soql queries to a list

Sosl mySearch                     = new Sosl('my search term', queries);    // Create a new Sosl instance with a search term & the list of Soql queries
List<List<Sobject>> searchResults = mySearch.getSearchResults();            // Returns all search results
```