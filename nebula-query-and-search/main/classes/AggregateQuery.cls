/*******************************************************************************************************
 * This file is part of the Nebula Query & Search project, released under the MIT License.             *
 * Copyright (c) 2018, Jonathan Gillespie. All rights reserved.                                        *
 * See LICENSE file or go to https://github.com/jongpie/NebulaQueryAndSearch for full license details. *
 ******************************************************************************************************/

/**
 * @group SOQL Queries
 * @description Handles generating & executing aggregate queries
 * @see SOQL
 * @see Query
 */
@SuppressWarnings(
  'PMD.ApexDoc, PMD.ApexSharingViolations, PMD.AvoidGlobalModifier, PMD.CyclomaticComplexity, PMD.ExcessiveParameterList, PMD.ExcessivePublicCount, PMD.FieldDeclarationsShouldBeAtStart'
)
global virtual class AggregateQuery extends SOQL {
  private SOQL.GroupingDimension groupingDimension;
  private List<AggregateField> aggregateFields = new List<AggregateField>();
  private List<GroupByField> groupByFields = new List<GroupByField>();
  private List<SOQL.GroupBySubtotalField> groupBySubtotalFields = new List<SOQL.GroupBySubtotalField>();
  private List<SOQL.QueryField> queryFields = new List<SOQL.QueryField>();
  private List<String> havingConditions = new List<String>();

  global AggregateQuery(Schema.SObjectType sobjectType) {
    super(sobjectType, false);
  }

  global AggregateQuery groupByField(Schema.SObjectField field) {
    return this.groupByFields(new List<Schema.SObjectField>{ field });
  }

  global AggregateQuery groupByField(SOQL.QueryField queryField) {
    return this.groupByFields(new List<SOQL.QueryField>{ queryField });
  }

  global AggregateQuery groupByFields(List<Schema.SObjectField> fields) {
    List<SOQL.QueryField> queryFields = new List<SOQL.QueryField>();
    for (Schema.SObjectField field : fields) {
      queryFields.add(new SOQL.QueryField(field));
    }
    return this.groupByFields(queryFields);
  }

  global AggregateQuery groupByFields(List<SOQL.QueryField> queryFields) {
    for (SOQL.QueryField queryField : queryFields) {
      this.groupByFields.add(new GroupByField(queryField));
    }
    // super.doAddFields(queryFields, null);
    return this.setHasChanged();
  }

  global AggregateQuery groupByFieldSet(Schema.FieldSet fieldSet) {
    List<SOQL.QueryField> queryFields = new List<SOQL.QueryField>();
    for (Schema.FieldSetMember fieldSetMember : fieldSet.getFields()) {
      queryFields.add(new SOQL.QueryField(this.sobjectType, fieldSetMember.getFieldPath()));
    }
    return this.groupByFields(queryFields);
  }

  global AggregateQuery groupBySubtotalField(Schema.SObjectField field) {
    return this.groupBySubtotalField(new SOQL.QueryField(field));
  }

  global AggregateQuery groupBySubtotalField(SOQL.QueryField queryField) {
    return this.groupBySubtotalFields(new List<SOQL.QueryField>{ queryField });
  }

  global AggregateQuery groupBySubtotalFields(List<SOQL.QueryField> queryFields) {
    // TODO https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_select_groupby_grouping.htm
    for (SOQL.QueryField queryField : queryFields) {
      this.groupBySubtotalFields.add(new SOQL.GroupBySubtotalField(queryField));
    }
    return this.setHasChanged();
  }

  global AggregateQuery usingGroupingDimension(SOQL.GroupingDimension groupingDimension) {
    this.groupingDimension = groupingDimension;
    return this.setHasChanged();
  }

  global AggregateQuery addAggregate(SOQL.Aggregate aggregateFunction, Schema.SObjectField field) {
    return this.addAggregate(aggregateFunction, field, null);
  }

  global AggregateQuery addAggregate(SOQL.Aggregate aggregateFunction, Schema.SObjectField field, String fieldAlias) {
    return this.addAggregate(aggregateFunction, new SOQL.QueryField(field), fieldAlias);
  }

  global AggregateQuery addAggregate(SOQL.Aggregate aggregateFunction, SOQL.QueryField queryField) {
    return this.addAggregate(aggregateFunction, queryField, null);
  }

  global AggregateQuery addAggregate(SOQL.Aggregate aggregateFunction, SOQL.QueryField queryField, String fieldAlias) {
    this.aggregateFields.add(new AggregateField(aggregateFunction, queryField, fieldAlias));
    return this.setHasChanged();
  }

  global AggregateQuery havingAggregate(SOQL.Aggregate aggregateFunction, Schema.SObjectField field, SOQL.Operator operator, Object value) {
    return this.havingAggregate(aggregateFunction, new SOQL.QueryField(field), operator, value);
  }

  global AggregateQuery havingAggregate(SOQL.Aggregate aggregateFunction, SOQL.QueryField queryField, SOQL.Operator operator, Object value) {
    this.havingConditions.add(aggregateFunction.name() + '(' + queryField + ') ' + SOQL.getOperatorValue(operator) + ' ' + value);
    return this.setHasChanged();
  }

  global AggregateQuery filterWhere(Schema.SObjectField field, SOQL.Operator operator, Object value) {
    return this.filterWhere(new SOQL.QueryField(field), operator, value);
  }

  global AggregateQuery filterWhere(SOQL.QueryField queryField, SOQL.Operator operator, Object value) {
    return this.filterWhere(new SOQL.QueryFilter(queryField, operator, value));
  }

  global AggregateQuery filterWhere(SOQL.QueryFilter filter) {
    return this.filterWhere(new List<SOQL.QueryFilter>{ filter });
  }

  global AggregateQuery filterWhere(List<SOQL.QueryFilter> filters) {
    super.doFilterWhere(filters);
    return this.setHasChanged();
  }

  global AggregateQuery orFilterWhere(List<SOQL.QueryFilter> filters) {
    super.doOrFilterWhere(filters);
    return this.setHasChanged();
  }

  global AggregateQuery orderByField(Schema.SObjectField field) {
    return this.orderByField(field, null);
  }

  global AggregateQuery orderByField(SOQL.QueryField queryField) {
    return this.orderByField(queryField, null);
  }

  global AggregateQuery orderByField(Schema.SObjectField field, SOQL.SortOrder sortOrder) {
    return this.orderByField(field, sortOrder, null);
  }

  global AggregateQuery orderByField(SOQL.QueryField queryField, SOQL.SortOrder sortOrder) {
    return this.orderByField(queryField, sortOrder, null);
  }

  global AggregateQuery orderByField(Schema.SObjectField field, SOQL.SortOrder sortOrder, Boolean sortNullsFirst) {
    return this.orderByField(new SOQL.QueryField(field), sortOrder, sortNullsFirst);
  }

  global AggregateQuery orderByField(SOQL.QueryField queryField, SOQL.SortOrder sortOrder, Boolean sortNullsFirst) {
    super.doOrderBy(queryField, sortOrder, sortNullsFirst);
    return this.setHasChanged();
  }

  global AggregateQuery orderByAggregate(SOQL.Aggregate aggregateFunction, Schema.SObjectField field) {
    return this.orderByAggregate(aggregateFunction, field, null);
  }

  global AggregateQuery orderByAggregate(SOQL.Aggregate aggregateFunction, Schema.SObjectField field, SOQL.SortOrder sortOrder) {
    return this.orderByAggregate(aggregateFunction, field, sortOrder, null);
  }

  global AggregateQuery orderByAggregate(SOQL.Aggregate aggregateFunction, Schema.SObjectField field, SOQL.SortOrder sortOrder, Boolean sortNullsFirst) {
    return this.orderByAggregate(aggregateFunction, new SOQL.QueryField(field), sortOrder, sortNullsFirst);
  }

  global AggregateQuery orderByAggregate(SOQL.Aggregate aggregateFunction, SOQL.QueryField queryField) {
    return this.orderByAggregate(aggregateFunction, queryField, null);
  }

  global AggregateQuery orderByAggregate(SOQL.Aggregate aggregateFunction, SOQL.QueryField queryField, SOQL.SortOrder sortOrder) {
    return this.orderByAggregate(aggregateFunction, queryField, sortOrder, null);
  }

  global AggregateQuery orderByAggregate(SOQL.Aggregate aggregateFunction, SOQL.QueryField queryField, SOQL.SortOrder sortOrder, Boolean sortNullsFirst) {
    super.doOrderBy(aggregateFunction.name() + '(' + queryField + ')', sortOrder, sortNullsFirst);
    return this.setHasChanged();
  }

  global AggregateQuery limitTo(Integer numberOfRecords) {
    super.doLimitTo(numberOfRecords);
    return this.setHasChanged();
  }

  global AggregateQuery offsetBy(Integer offset) {
    super.doOffsetBy(offset);
    return this.setHasChanged();
  }

  // public AggregateQuery cacheQuery(SOQL.Cacheable cache) {
  //     // TODO
  //     return this;
  // }

  public AggregateQuery cacheResults() {
    super.doCacheResults();
    return this;
  }

  // public AggregateQuery cacheResults(SOQL.Cacheable cache, String key) {
  //     // TODO
  //     return this;
  // }

  @SuppressWarnings('PMD.AvoidDebugStatements')
  public override String getQuery() {
    if (this.query != null && this.hasChanged == false) {
      return this.query;
    }

    List<String> queryFieldPaths = new List<String>();
    // List<SOQL.QueryField> consolidatedFields = new List<SOQL.QueryField>();
    // // this.aggregateFields.sort();
    // consolidatedFields.addAll(this.groupByFields);
    // consolidatedFields.addAll(this.groupBySubtotalFields);
    // consolidatedFields.addAll(this.aggregateFields);
    // System.debug('>>> this.groupBySubtotalFields: ' + this.groupBySubtotalFields);
    // for (SOQL.QueryField queryField : consolidatedFields) {
    //     queryFieldPaths.add(queryField.getAliasedFieldPath());
    // }

    if (queryFieldPaths.isEmpty()) {
      Schema.SObjectField idField = this.getSObjectType().getDescribe().fields.getMap().get('Id');
      queryFieldPaths.add(new AggregateField(SOQL.Aggregate.COUNT, new SOQL.QueryField(idField), null).getAliasedFieldPath());
    }

    this.query = this.createQuery(queryFieldPaths);
    System.debug('>>> query: ' + this.query);
    return this.query;
  }

  @SuppressWarnings('PMD.ApexSOQLInjection')
  global Integer getResultCount() {
    String countQuery = this.createQuery(new List<String>{'COUNT()'});
    return System.Database.countQuery(countQuery);
  }

  global virtual Schema.AggregateResult getFirstResult() {
    return (Schema.AggregateResult) super.doGetFirstResult();
  }

  global List<Schema.AggregateResult> getResults() {
    return (List<Schema.AggregateResult>) super.doGetResults();
  }

  global virtual SOQL.AggregateRecord getFirstRecord() {
    List<SOQL.AggregateRecord> records = this.getRecords();
    return records == null || records.isEmpty() ? null : records.get(0);
  }

  global virtual List<SOQL.AggregateRecord> getRecords() {
    List<SOQL.AggregateRecord> aggregateRecords = new List<SOQL.AggregateRecord>();
    List<SOQL.QueryField> consolidatedFields = new List<SOQL.QueryField>();
    // this.aggregateFields.sort();
    // consolidatedFields.addAll(this.groupByFields);
    // consolidatedFields.addAll(this.groupBySubtotalFields);
    // consolidatedFields.addAll(this.aggregateFields);
    for (Schema.AggregateResult result : this.getResults()) {
      for (SOQL.QueryField queryField : consolidatedFields) {
        SOQL.AggregateRecord aggregateRecord = new SOQL.AggregateRecord(result);

        // TODO revist constructor & properties for AggregateResultFieldProxy
        String fieldPath = queryField.getFieldPath();
        String fieldAlias; // = queryField.getAlias();

        System.debug('converting result field to proxy, fieldPath: ' + fieldPath + ', fieldAlias: ' + fieldAlias);

        Object resultValue = result.get(fieldAlias);
        aggregateRecord.addField(new SOQL.AggregateRecordField(fieldPath, fieldAlias, resultValue));

        aggregateRecords.add(aggregateRecord);
      }
    }
    return aggregateRecords;
  }

  private AggregateQuery setHasChanged() {
    this.hasChanged = true;
    return this;
  }

  private String getAggregateQueryFieldString() {
    if (this.aggregateFields.isEmpty()) {
      return '';
    }

    List<String> aggregateFieldStrings = new List<String>();
    for (AggregateQuery.AggregateField aggregatedField : this.aggregateFields) {
      aggregateFieldStrings.add(aggregatedField.getFieldPath());
    }
    aggregateFieldStrings.sort();
    return String.join(aggregateFieldStrings, ', ');
  }

  private String getGroupByString() {
    List<String> groupByStatementFieldPaths = new List<String>();
    for (GroupByField groupByField : this.groupByFields) {
      groupByStatementFieldPaths.add(groupByField.getFieldPath());
    }
    String queryFieldString = String.join(groupByStatementFieldPaths, ', ');

    String groupByTextString = ' GROUP BY ';
    String groupingDimensionClosingString = '';
    if (this.groupingDimension != null) {
      groupByTextString += this.groupingDimension.name() + '(';
      groupingDimensionClosingString = ')';
    }

    return String.isEmpty(queryFieldString) ? '' : groupByTextString + queryFieldString + groupingDimensionClosingString;
  }

  private String getHavingString() {
    return this.havingConditions.isEmpty() ? '' : ' HAVING ' + String.join(this.havingConditions, ', ');
  }

  private String createQuery(List<String> selectFieldPaths) {
    return 'SELECT ' + String.join(selectFieldPaths, ', ') + ' FROM ' +
    this.sobjectType +
    super.getUsingScopeClause() +
    super.getWhereClauseClause() +
    this.getGroupByString() +
    this.getHavingString() +
    super.getOrderByClause() +
    super.getLimitClause() +
    super.getOffetClause();
  }
}
