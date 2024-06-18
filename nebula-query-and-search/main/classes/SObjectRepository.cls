/*************************************************************************************************
 * This file is part of the Nebula Framework project, released under the MIT License.             *
 * See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
 *************************************************************************************************/

/**
 *
 * @group Repository
 *
 * @description TODO
 *
 */
@SuppressWarnings('PMD.ExcessivePublicCount')
global inherited sharing virtual class SObjectRepository extends DataManipulator {
  private final Schema.SObjectType sobjectType;
  private final List<SOQL.QueryField> queryFields;
  private final SOQL.QueryField idQueryField;

  global SObjectRepository(Schema.SObjectType sobjectType) {
    this(sobjectType, new List<SOQL.QueryField>());
  }

  global SObjectRepository(Schema.SObjectType sobjectType, List<SOQL.QueryField> queryFields) {
    super();
    this.sobjectType = sobjectType;
    this.queryFields = queryFields;

    this.idQueryField = new SOQL.QueryField(sobjectType.getDescribe().fields.getMap().get('Id'));
  }

  global Schema.SObjectType getSObjectType() {
    return this.sobjectType;
  }

  // SOQL - Query
  global virtual SObject queryData(Id recordId) {
    List<SObject> results = this.queryData(new List<Id>{ recordId });
    return results.isEmpty() ? null : results.get(0);
  }

  global virtual List<SObject> queryData(Set<Id> recordIds) {
    return this.queryData(new List<Id>(recordIds));
  }

  global virtual List<SObject> queryData(List<Id> recordIds) {
    return this.queryData(new SOQL.QueryFilter(this.idQueryField, SOQL.Operator.IS_IN, recordIds));
  }

  global virtual List<SObject> queryData(SOQL.QueryFilter queryFilter) {
    return this.queryData(new List<SOQL.QueryFilter>{ queryFilter });
  }

  global virtual List<SObject> queryData(List<SOQL.QueryFilter> queryFilters) {
    return this.getQuery(queryFilters).getResults();
  }

  public virtual Query getQuery(List<SOQL.QueryFilter> queryFilters) {
    return new Query(this.getSObjectType()).addFields(this.queryFields);
  }

  // SOQL - AggregateQuery
  global virtual List<SOQL.AggregateRecord> aggregateData(
    List<SOQL.AggregateField> aggregateFields,
    List<SOQL.QueryField> groupByFields,
    List<SOQL.QueryFilter> queryFilters
  ) {
    return this.getAggregateQuery(queryFilters).getRecords();
  }

  public virtual AggregateQuery getAggregateQuery(List<SOQL.QueryFilter> queryFilters) {
    return new AggregateQuery(this.getSObjectType());
  }

  // SOSL - Single object search
  global virtual List<SObject> searchData(String searchTerm) {
    return this.searchData(searchTerm, SOSL.SearchGroup.ALL_FIELDS, null);
  }

  global virtual List<SObject> searchData(String searchTerm, SOSL.SearchGroup searchGroup) {
    return this.searchData(searchTerm, searchGroup, null);
  }

  global virtual List<SObject> searchData(String searchTerm, SOSL.SearchGroup searchGroup, List<SOQL.QueryFilter> queryFilters) {
    return this.getSearch(searchTerm, searchGroup, queryFilters).getFirstResults();
  }

  public virtual RecordSearch getSearch(String searchTerm, SOSL.SearchGroup searchGroup, List<SOQL.QueryFilter> queryFilters) {
    return new RecordSearch(searchTerm, this.getQuery(queryFilters)).inSearchGroup(searchGroup);
  }
}
