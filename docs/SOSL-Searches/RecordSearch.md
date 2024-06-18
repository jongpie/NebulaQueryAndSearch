---
layout: default
---
# RecordSearch

`SUPPRESSWARNINGS`

`APIVERSION: 57`

`STATUS: ACTIVE`

Handles generating & executing SObject SOSL searches


**Inheritance**

[SOSL](./SOSL.md)
 &gt; 
RecordSearch


**Group** SOSL Searches


**See** [SOSL](./SOSL.md)


**See** [Query](../SOQL-Queries/Query.md)

## Constructors
### `RecordSearch(String searchTerm, Query sobjectQuery)`
### `RecordSearch(String searchTerm, List<Query> sobjectQueries)`
---
## Methods
### `inSearchGroup(SOSL searchGroup)`
### `withDataCategory(Schema dataCategory, SOSL dataCategoryLocation, Schema childDataCategory)`
### `withDataCategory(Schema dataCategory, SOSL dataCategoryLocation, List<Schema.DataCategory> childDataCategories)`
### `withHighlight()`
### `withSnippet(Integer targetLength)`
### `withSpellCorrection()`
### `updateArticleReporting(SOSL articleReporting)`
### `cacheResults()`
### `override getSearch()`

`SUPPRESSWARNINGS`
### `getFirstResult()`
### `getFirstResults()`
### `getResults()`
### `getSObjectTypes()`

*Inherited*

---
