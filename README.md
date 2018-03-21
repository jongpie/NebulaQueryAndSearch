# Apex Query
A lightweight Apex library for easily building dynamic SOQL queries <br />
<a href="https://githubsfdeploy.herokuapp.com" target="_blank">
    <img alt="Deploy to Salesforce" src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png">
</a>

## Features
* All constructors & methods are overloaded to support both strings and tokens for SObject names, field names, etc
* Easily add fields if the field meets the category specified
    * `new Soql('Contact').addFields('MyField__c', FieldCategory.ACCESSIBLE)` --> Includes the field MyField__c if the current user has read access
    * `new Soql('Contact').addFields('MyField__c', FieldCategory.UPDATEABLE)` --> Includes the field MyField__c if the current user has write access
* Easily add any fields that are accessible, updateable, standard or custom
    * `new Soql('Contact').addFields(FieldCategory.ACCESSIBLE)` --> All fields with isAccessible() == true are returned in the query
    * `new Soql('Contact').addFields(FieldCategory.UPDATEABLE)` --> All fields with isUpdateable() == true are returned in the query
    * `new Soql('Contact').addFields(FieldCategory.STANDARD)` --> All standard fields on the object are returned in the query
    * `new Soql('Contact').addFields(FieldCategory.CUSTOM)` --> All custom fields on the object are returned in the query
* Easily add fields from a field set
    * `new Soql('Contact').addFields(myContactFieldSet)` --> All fields in the field set are returned in the query
* Automatically adds the parent name field for any lookup/master-detail fields
    * `new Soql('Contact').addField('AccountId')` --> AccountId and Account.Name are both returned in the query
* Adds translations for picklist fields & record types by calling includeLabels()
    * `new Soql('Contact').addField('Type').includeLabels()` --> Type and Type__Label are both returned in the query
* Adds localized formatting for number, date, datetime, time, or currency fields by calling includeFormattedValues()
    * `new Soql('Account').addField('AnnualRevenue').includeFormattedValues()` --> AnnualRevenue and AnnualRevenue__Formatted are both returned in the query
* Leverage query scope to filter results
    * `new Soql('Contact').usingScope(Query.Scope.MINE)`

## Examples
Basic usage: Query an object & return the object's ID and display name field (typically the 'Name' field, but some objects use other fields, like Task.Subject and Case.CaseNumber). Since no filters have been added, this query would also return all accounts.

```
List<Account> accounts = new Soql('Account').getQueryResults();
```

Advanced usage: Query an object & leverage the query builder methods. The order of the builder methods does not matter - you can arrange the calls to these methods in any order that you prefer.

```
Query accountQuery = new Soql('Account')                                             // Query the account object
    .addField(Schema.Account.ParentId)                                               // Include the ParentId field, using SObjectField. The current user must have at least read access to the field
    .addField('Type', Soql.FieldCategory.UPDATEABLE)                                 // Include the Type field, using the field API name, if the user has access to update it
    .addFields(Soql.FieldCategory.CUSTOM)                                            // Include all custom fields - Soql.cls only includes fields that are accessible to the user
    .addFields(myContactFieldSet)                                                    // Include all fields in a field set that are accessible to the user
    .removeField('my_custom_field__c')                                               // remove a custom field
    .usingScope(Soql.Scope.MINE)                                                     // Set the query scope
    .filterWhere(Schema.Account.CreatedDate, '=', new Soql.DateLiteral('LAST_WEEK')) // Filter on the created date, using a date literal
    .filterWhere('Type != null')                                                     // A string version of a query filter can also be used
    .orderBy('type')                                                                 // Order by a field API name - sort order/nulls defaults to 'Type ASC NULLS FIRST'
    .orderBy(Account.Name, Soql.SortOrder.ASCENDING)                                 // Order by, using SObjectField & sort order
    .orderBy(Account.AnnualRevenue, Soql.SortOrder.DESCENDING, false)                // Order by, using SObjectField, sort order and nulls sort order
    .limitCount(100)                                                                 // Limit the results to 100 records
    .includeLabels()                                                                 // Include labels/translations for any picklist fields or record types. These are aliased using the convention 'FieldName__c_Label'
    .includeFormattedValues()                                                        // Include formatted values for any number, date, time, or currency fields
    .cacheResults()                                                                  // When enabled, the query results are internally cached - any subsequent calls for getQueryResults() will returned cached results instead of executing the query again
    .offset(25);                                                                     // Skip the first 25 results

// Execute the query and store the results in the 'accounts' variable
List<Account> accounts = accountQuery.getQueryResults();
for(Account account : accounts) {
    // Get the localized label for the Industry picklist value
    System.debug(account.get('Industry_Label'));
}
```