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
### `cacheResults()`
### `getSObjectType()`

*Inherited*

---
