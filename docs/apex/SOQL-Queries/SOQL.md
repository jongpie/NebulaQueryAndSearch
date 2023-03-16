---
layout: default
---
# SOQL

`SUPPRESSWARNINGS`

`APIVERSION: 57`

`STATUS: ACTIVE`

Handles common functionality needed for writing SOQL queries


**Implemented types**

[Comparable](Comparable)


**Group** SOQL Queries


**See** [Query](./Query.md)


**See** [AggregateQuery](./AggregateQuery.md)

## Methods
### `static getOperatorValue(SOQL operator)`
### `getSObjectType()`
### `getQuery()`
### `getQueryLocator()`
### `compareTo(Object compareTo)`
---
## Enums
### Aggregate

### DateFunction

### FieldCategory

### FixedDateLiteral

### GroupingDimension

### Operator

### RelativeDateLiteral

### Scope

### SortOrder

---
## Classes
### DateLiteral
#### Constructors
##### `DateLiteral(SOQL fixedDateLiteral)`
##### `DateLiteral(SOQL relativeDateLiteral, Integer n)`
---
#### Methods
##### `override toString()`
---

### IsoCurrency
#### Constructors
##### `IsoCurrency(String isoCode, Decimal currencyAmount)`
---
#### Methods
##### `override toString()`
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
#### Methods
##### `override toString()`
##### `getDescribe()`
##### `getAlias()`
##### `getAliasedFieldPath()`
##### `getFieldPath()`
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
##### `getFormattedValue()`
##### `override toString()`
---

### SOQLException

**Inheritance**

SOQLException


---
## Interfaces
### Cacheable
#### Methods
##### `contains(String key)`
##### `get(String key)`
##### `put(String key, Object value)`
##### `remove(String key)`
---

