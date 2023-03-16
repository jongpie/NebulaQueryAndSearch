---
layout: default
---
# Query

`SUPPRESSWARNINGS`

`APIVERSION: 57`

`STATUS: ACTIVE`

Handles generating & executing SObject queries


**Inheritance**

[SOQL](./SOQL.md)
 &gt; 
Query


**Group** SOQL Queries


**See** [SOQL](./SOQL.md)


**See** [AggregateQuery](./AggregateQuery.md)

## Constructors
### `Query(Schema sobjectType)`
---
## Methods
### `addField(Schema field)`
### `addField(Schema field, SOQL fieldCategory)`
### `addField(SOQL queryField)`
### `addField(SOQL queryField, SOQL fieldCategory)`
### `addFields(List<Schema.SObjectField> fields)`
### `addFields(List<Schema.SObjectField> fields, SOQL fieldCategory)`
### `addFields(List<SOQL.QueryField> queryFields)`
### `addFields(SOQL fieldCategory)`
### `addFields(List<SOQL.QueryField> queryFields, SOQL fieldCategory)`
### `addFieldSet(Schema fieldSet)`
### `addFieldSet(Schema fieldSet, SOQL fieldCategory)`
### `addPolymorphicFields(Schema polymorphicRelationshipField)`
### `addPolymorphicFields(Schema polymorphicRelationshipField, Map<Schema.SObjectType,List<Schema.SObjectField>> fieldsBySObjectType)`
### `addPolymorphicFields(Schema polymorphicRelationshipField, Map<Schema.SObjectType,List<SOQL.QueryField>> queryFieldsBySObjectType)`

`SUPPRESSWARNINGS`
### `includeLabels()`
### `includeFormattedValues()`
### `removeField(Schema field)`
### `removeField(SOQL queryField)`
### `removeFields(Schema fieldSet)`
### `removeFields(List<Schema.SObjectField> fields)`
### `removeFields(List<SOQL.QueryField> queryFields)`
### `includeRelatedRecords(Schema childToParentRelationshipField, Query relatedSObjectQuery)`
### `usingScope(Scope scope)`
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
### `limitTo(Integer numberOfRecords)`
### `offsetBy(Integer offset)`
### `forReference()`
### `forUpdate()`
### `forView()`
### `cacheResults()`
### `getSObjectType()`

*Inherited*

---
