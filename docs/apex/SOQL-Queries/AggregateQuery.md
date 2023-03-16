---
layout: default
---
# AggregateQuery

`SUPPRESSWARNINGS`

`APIVERSION: 57`

`STATUS: ACTIVE`

Handles generating & executing aggregate queries


**Inheritance**

[SOQL](./SOQL.md)
 &gt; 
AggregateQuery


**Group** SOQL Queries


**See** [SOQL](./SOQL.md)


**See** [Query](./Query.md)

## Constructors
### `AggregateQuery(Schema sobjectType)`
---
## Methods
### `groupByField(Schema field)`
### `groupByField(SOQL queryField)`
### `groupByFields(List<Schema.SObjectField> fields)`
### `groupByFields(List<SOQL.QueryField> queryFields)`
### `groupByFieldSet(Schema fieldSet)`
### `groupingField(Schema field)`
### `groupingField(SOQL queryField)`
### `groupingFields(List<SOQL.QueryField> queryFields)`
### `usingGroupingDimension(SOQL groupingDimension)`
### `addAggregate(SOQL aggregateFunction, Schema field)`
### `addAggregate(SOQL aggregateFunction, Schema field, String fieldAlias)`
### `addAggregate(SOQL aggregateFunction, SOQL queryField)`
### `addAggregate(SOQL aggregateFunction, SOQL queryField, String fieldAlias)`
### `havingAggregate(SOQL aggregateFunction, Schema field, SOQL operator, Object value)`
### `havingAggregate(SOQL aggregateFunction, SOQL queryField, SOQL operator, Object value)`
### `filterWhere(Schema field, SOQL operator, Object value)`
### `filterWhere(SOQL queryField, SOQL operator, Object value)`
### `filterWhere(SOQL filter)`
### `filterWhere(List<SOQL.QueryFilter> filters)`
### `orFilterWhere(List<SOQL.QueryFilter> filters)`
### `orderByField(Schema field)`
### `orderByField(SOQL queryField)`
### `orderByField(Schema field, SOQL sortOrder)`
### `orderByField(SOQL queryField, SOQL sortOrder)`
### `orderByField(Schema field, SOQL sortOrder, Boolean sortNullsFirst)`
### `orderByField(SOQL queryField, SOQL sortOrder, Boolean sortNullsFirst)`
### `orderByAggregate(SOQL aggregateFunction, Schema field)`
### `orderByAggregate(SOQL aggregateFunction, Schema field, SOQL sortOrder)`
### `orderByAggregate(SOQL aggregateFunction, Schema field, SOQL sortOrder, Boolean sortNullsFirst)`
### `orderByAggregate(SOQL aggregateFunction, SOQL queryField)`
### `orderByAggregate(SOQL aggregateFunction, SOQL queryField, SOQL sortOrder)`
### `orderByAggregate(SOQL aggregateFunction, SOQL queryField, SOQL sortOrder, Boolean sortNullsFirst)`
### `limitTo(Integer numberOfRecords)`
### `offsetBy(Integer offset)`
### `cacheQuery(SOQL cache)`
### `cacheResults()`
### `cacheResults(SOQL cache, String key)`
### `override getQuery()`

`SUPPRESSWARNINGS`
### `getResultCount()`

`SUPPRESSWARNINGS`
### `getFirstResult()`
### `getResults()`
### `getResultProxies()`
### `static getOperatorValue(SOQL operator)`

*Inherited*

### `getSObjectType()`

*Inherited*

### `getQueryLocator()`

*Inherited*

### `compareTo(Object compareTo)`

*Inherited*

---
## Classes
### AggregateResultFieldProxy
#### Constructors
##### `AggregateResultFieldProxy(String fieldPath, String fieldAlias, Object value)`
---
#### Fields

##### `fieldAlias` → `String`


##### `fieldPath` → `String`


##### `value` → `Object`


---

### AggregateResultProxy
#### Constructors
##### `AggregateResultProxy(Schema result)`
---
#### Fields

##### `fields` → `List&lt;AggregateResultFieldProxy&gt;`


##### `result` → `Schema`


---
#### Methods
##### `addField(AggregateResultFieldProxy resultFieldProxy)`
##### `getFields()`
---

---
