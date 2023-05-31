---
layout: default
---
# SOQL

`SUPPRESSWARNINGS`

Handles common functionality needed for writing SOQL queries


**Implemented types**

[Comparable](Comparable)


**Group** SOQL Queries


**See** [Query](./Query.md)


**See** [AggregateQuery](./AggregateQuery.md)

## Methods
### `getSObjectType()`
### `getQuery()`
---
## Enums
### Aggregate

### DateFunction

### FieldCategory

### FilterConjunction

### FixedDateLiteral

### GroupingDimension

### Operator

### RelativeDateLiteral

### Scope

### SortOrder

---
## Classes
### NestedQueryFilter

**Inheritance**

NestedQueryFilter

#### Constructors
##### `NestedQueryFilter(FilterConjunction filterConjunction, List&lt;QueryFilter&gt; innerFilters)`
---

### QueryField
#### Constructors
##### `QueryField(Schema sobjectType, String queryFieldPath)`
##### `QueryField(Schema field)`
##### `QueryField(List&lt;Schema.SObjectField&gt; fieldChain)`
##### `QueryField(SOQL dateFunction, Schema field)`
##### `QueryField(SOQL dateFunction, Schema field, Boolean convertTimeZone)`
##### `QueryField(SOQL dateFunction, List&lt;Schema.SObjectField&gt; fieldChain)`
##### `QueryField(SOQL dateFunction, List&lt;Schema.SObjectField&gt; fieldChain, Boolean convertTimeZone)`
##### `QueryField(List&lt;Schema.SObjectField&gt; fieldChain, Decimal latitude, Decimal longitude)`
---

### QueryFilter

**Implemented types**

[Comparable](Comparable)

#### Constructors
##### `QueryFilter(Schema field, SOQL operator, Object value)`
##### `QueryFilter(QueryField queryField, SOQL operator, Object value)`
##### `QueryFilter(Schema childSObjectType, Boolean inOrNotIn, Schema lookupFieldOnChildSObject)`
##### `QueryFilter(Query childQuery, Boolean inOrNotIn, Schema lookupFieldOnChildSObject)`
---
#### Methods
##### `compareTo(Object compareTo)`
##### `getQueryField()`
##### `getOperator()`
##### `getValue()`
---

---
