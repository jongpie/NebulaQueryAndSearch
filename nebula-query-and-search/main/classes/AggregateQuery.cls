/*******************************************************************************************************
 * This file is part of the Nebula Query & Search project, released under the MIT License.             *
 * See LICENSE file or go to https://github.com/jongpie/NebulaQueryAndSearch for full license details. *
 ******************************************************************************************************/

/**
 * @group SOQL Queries
 * @description Handles generating & executing aggregate queries
 * @see SOQL
 * @see Query
 */
@SuppressWarnings(
    'PMD.ApexDoc, PMD.ApexSharingViolations, PMD.CyclomaticComplexity, PMD.ExcessiveParameterList, PMD.ExcessivePublicCount, PMD.FieldDeclarationsShouldBeAtStart'
)
public class AggregateQuery extends SOQL {
    private SOQL.GroupingDimension groupingDimension;
    private List<AggregateField> aggregateFields;
    private List<String> havingConditions;

    public AggregateQuery(Schema.SObjectType sobjectType) {
        super(sobjectType, false);

        this.aggregateFields = new List<AggregateField>();
        this.havingConditions = new List<String>();
    }

    public AggregateQuery groupByField(Schema.SObjectField field) {
        return this.groupByFields(new List<Schema.SObjectField>{ field });
    }

    public AggregateQuery groupByField(SOQL.QueryField queryField) {
        return this.groupByFields(new List<SOQL.QueryField>{ queryField });
    }

    public AggregateQuery groupByFields(List<Schema.SObjectField> fields) {
        List<SOQL.QueryField> queryFields = new List<SOQL.QueryField>();
        for (Schema.SObjectField field : fields) {
            queryFields.add(new SOQL.QueryField(field));
        }
        return this.groupByFields(queryFields);
    }

    public AggregateQuery groupByFields(List<SOQL.QueryField> queryFields) {
        super.doAddFields(queryFields, null);
        return this.setHasChanged();
    }

    public AggregateQuery groupByFieldSet(Schema.FieldSet fieldSet) {
        List<SOQL.QueryField> queryFields = new List<SOQL.QueryField>();
        for (Schema.FieldSetMember fieldSetMember : fieldSet.getFields()) {
            queryFields.add(new SOQL.QueryField(this.sobjectType, fieldSetMember.getFieldPath()));
        }
        return this.groupByFields(queryFields);
    }

    public AggregateQuery usingGroupingDimension(SOQL.GroupingDimension groupingDimension) {
        this.groupingDimension = groupingDimension;
        return this.setHasChanged();
    }

    public AggregateQuery addAggregate(SOQL.Aggregate aggregateFunction, Schema.SObjectField field) {
        return this.addAggregate(aggregateFunction, field, null);
    }

    public AggregateQuery addAggregate(SOQL.Aggregate aggregateFunction, Schema.SObjectField field, String fieldAlias) {
        return this.addAggregate(aggregateFunction, new SOQL.QueryField(field), fieldAlias);
    }

    public AggregateQuery addAggregate(SOQL.Aggregate aggregateFunction, SOQL.QueryField queryField) {
        return this.addAggregate(aggregateFunction, queryField, null);
    }

    public AggregateQuery addAggregate(SOQL.Aggregate aggregateFunction, SOQL.QueryField queryField, String fieldAlias) {
        this.aggregateFields.add(new AggregateField(this.getSObjectType(), aggregateFunction, queryField, fieldAlias));
        return this.setHasChanged();
    }

    public AggregateQuery havingAggregate(SOQL.Aggregate aggregateFunction, Schema.SObjectField field, SOQL.Operator operator, Object value) {
        return this.havingAggregate(aggregateFunction, new SOQL.QueryField(field), operator, value);
    }

    public AggregateQuery havingAggregate(SOQL.Aggregate aggregateFunction, SOQL.QueryField queryField, SOQL.Operator operator, Object value) {
        this.havingConditions.add(aggregateFunction.name() + '(' + queryField + ') ' + SOQL.getOperatorValue(operator) + ' ' + value);
        return this.setHasChanged();
    }

    public AggregateQuery filterWhere(Schema.SObjectField field, SOQL.Operator operator, Object value) {
        return this.filterWhere(new SOQL.QueryField(field), operator, value);
    }

    public AggregateQuery filterWhere(SOQL.QueryField queryField, SOQL.Operator operator, Object value) {
        return this.filterWhere(new SOQL.QueryFilter(queryField, operator, value));
    }

    public AggregateQuery filterWhere(SOQL.QueryFilter filter) {
        return this.filterWhere(new List<SOQL.QueryFilter>{ filter });
    }

    public AggregateQuery filterWhere(List<SOQL.QueryFilter> filters) {
        super.doFilterWhere(filters);
        return this.setHasChanged();
    }

    public AggregateQuery orFilterWhere(List<SOQL.QueryFilter> filters) {
        super.doOrFilterWhere(filters);
        return this.setHasChanged();
    }

    public AggregateQuery orderByField(Schema.SObjectField field) {
        return this.orderByField(field, null);
    }

    public AggregateQuery orderByField(SOQL.QueryField queryField) {
        return this.orderByField(queryField, null);
    }

    public AggregateQuery orderByField(Schema.SObjectField field, SOQL.SortOrder sortOrder) {
        return this.orderByField(field, sortOrder, null);
    }

    public AggregateQuery orderByField(SOQL.QueryField queryField, SOQL.SortOrder sortOrder) {
        return this.orderByField(queryField, sortOrder, null);
    }

    public AggregateQuery orderByField(Schema.SObjectField field, SOQL.SortOrder sortOrder, Boolean sortNullsFirst) {
        return this.orderByField(new SOQL.QueryField(field), sortOrder, sortNullsFirst);
    }

    public AggregateQuery orderByField(SOQL.QueryField queryField, SOQL.SortOrder sortOrder, Boolean sortNullsFirst) {
        super.doOrderBy(queryField, sortOrder, sortNullsFirst);
        return this.setHasChanged();
    }

    public AggregateQuery orderByAggregate(SOQL.Aggregate aggregateFunction, Schema.SObjectField field) {
        return this.orderByAggregate(aggregateFunction, field, null);
    }

    public AggregateQuery orderByAggregate(SOQL.Aggregate aggregateFunction, Schema.SObjectField field, SOQL.SortOrder sortOrder) {
        return this.orderByAggregate(aggregateFunction, field, sortOrder, null);
    }

    public AggregateQuery orderByAggregate(SOQL.Aggregate aggregateFunction, Schema.SObjectField field, SOQL.SortOrder sortOrder, Boolean sortNullsFirst) {
        return this.orderByAggregate(aggregateFunction, new SOQL.QueryField(field), sortOrder, sortNullsFirst);
    }

    public AggregateQuery orderByAggregate(SOQL.Aggregate aggregateFunction, SOQL.QueryField queryField) {
        return this.orderByAggregate(aggregateFunction, queryField, null);
    }

    public AggregateQuery orderByAggregate(SOQL.Aggregate aggregateFunction, SOQL.QueryField queryField, SOQL.SortOrder sortOrder) {
        return this.orderByAggregate(aggregateFunction, queryField, sortOrder, null);
    }

    public AggregateQuery orderByAggregate(SOQL.Aggregate aggregateFunction, SOQL.QueryField queryField, SOQL.SortOrder sortOrder, Boolean sortNullsFirst) {
        super.doOrderBy(aggregateFunction.name() + '(' + queryField + ')', sortOrder, sortNullsFirst);
        return this.setHasChanged();
    }

    public AggregateQuery limitTo(Integer numberOfRecords) {
        super.doLimitTo(numberOfRecords);
        return this.setHasChanged();
    }

    public AggregateQuery offsetBy(Integer offset) {
        super.doOffsetBy(offset);
        return this.setHasChanged();
    }

    public AggregateQuery cacheResults() {
        super.doCacheResults();
        return this;
    }

    @SuppressWarnings('PMD.AvoidDebugStatements')
    public override String getQuery() {
        if (this.query != null && !this.hasChanged) {
            return this.query;
        }

        String queryFieldString = super.doGetQueryFieldString();
        String aggregateQueryFieldString = this.getAggregateQueryFieldString();
        String aggregateFieldDelimiter = !String.isEmpty(queryFieldString) && !String.isEmpty(aggregateQueryFieldString) ? ', ' : '';

        String combinedFieldsString = queryFieldString + aggregateFieldDelimiter + aggregateQueryFieldString;
        if (String.isBlank(combinedFieldsString)) {
            Schema.SObjectField idField = this.getSObjectType().getDescribe().fields.getMap().get('Id');
            combinedFieldsString = new AggregateField(this.getSObjectType(), SOQL.Aggregate.COUNT, new SOQL.QueryField(idField), null).toString();
        }

        this.query =
            'SELECT ' +
            combinedFieldsString +
            ' FROM ' +
            this.sobjectType +
            super.doGetUsingScopeString() +
            super.doGetWhereClauseString() +
            this.getGroupByString() +
            this.getHavingString() +
            super.doGetOrderByString() +
            super.doGetLimitCountString() +
            super.doGetOffetString();

        System.debug(LoggingLevel.FINEST, this.query);
        return this.query;
    }

    @SuppressWarnings('PMD.ApexSOQLInjection')
    public Integer getResultCount() {
        String countQuery =
            'SELECT COUNT()' +
            ' FROM ' +
            this.sobjectType +
            super.doGetUsingScopeString() +
            super.doGetWhereClauseString() +
            this.getGroupByString() +
            this.getHavingString() +
            super.doGetOrderByString() +
            super.doGetLimitCountString() +
            super.doGetOffetString();
        return Database.countQuery(countQuery);
    }

    public AggregateResult getFirstResult() {
        return (AggregateResult) super.doGetFirstResult();
    }

    public List<AggregateResult> getResults() {
        return (List<AggregateResult>) super.doGetResults();
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
            aggregateFieldStrings.add(aggregatedField.toString());
        }
        aggregateFieldStrings.sort();
        return String.join(aggregateFieldStrings, ', ');
    }

    private String getGroupByString() {
        String queryFieldString = super.doGetQueryFieldString();

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

    private class AggregateField {
        private Schema.SObjectType sobjectType;
        private String aggregateFieldPath;

        public AggregateField(Schema.SObjectType sobjectType, SOQL.Aggregate aggregateFunction, SOQL.QueryField queryField, String fieldAlias) {
            this.sobjectType = sobjectType;
            this.aggregateFieldPath = this.getAggregateFieldPath(aggregateFunction, queryField, fieldAlias);
        }

        public override String toString() {
            return this.aggregateFieldPath;
        }

        private String getAggregateFieldPath(SOQL.Aggregate aggregateFunction, SOQL.QueryField queryField, String fieldAlias) {
            String fieldApiName = queryField.getDescribe().getName();
            fieldAlias = !String.isEmpty(fieldAlias) ? String.escapeSingleQuotes(fieldAlias) : aggregateFunction.name() + '__' + fieldApiName;

            // Example: MIN(Schema.Lead.MyField__c) is auto-aliased to MyField__c__MIN
            return aggregateFunction.name() + '(' + fieldApiName + ') ' + fieldAlias;
        }
    }
}
