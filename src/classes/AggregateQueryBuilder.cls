/******************************************************************************************************
* This file is part of the Nebula Query & Search project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaQueryAndSearch for full license details. *
******************************************************************************************************/
public class AggregateQueryBuilder extends Soql {

    private Soql.GroupingDimension groupingDimension;
    private List<AggregateField> aggregateFields;
    private List<String> havingConditions;

    public AggregateQueryBuilder(Schema.SobjectType sobjectType) {
        super(sobjectType, false);

        this.aggregateFields  = new List<AggregateField>();
        this.havingConditions = new List<String>();
    }

    public AggregateQueryBuilder groupBy(Schema.SobjectField field) {
       return this.groupBy(new List<Schema.SobjectField>{field});
    }

    public AggregateQueryBuilder groupBy(Soql.QueryField queryField) {
        return this.groupBy(new List<Soql.QueryField>{queryField});
    }

    public AggregateQueryBuilder groupBy(Schema.FieldSet fieldSet) {
        List<Soql.QueryField> queryFields = new List<Soql.QueryField>();
        for(Schema.FieldSetMember fieldSetMember : fieldSet.getFields()) {
            queryFields.add(new Soql.QueryField(this.sobjectType, fieldSetMember.getFieldPath()));
        }
        return this.groupBy(queryFields);
    }

    public AggregateQueryBuilder groupBy(List<Schema.SobjectField> fields) {
        List<Soql.QueryField> queryFields = new List<Soql.QueryField>();
        for(Schema.SobjectField field : fields) {
            queryFields.add(new Soql.QueryField(field));
        }
        return this.groupBy(queryFields);
    }

    public AggregateQueryBuilder groupBy(List<Soql.QueryField> queryFields) {
        super.doAddFields(queryFields, null);
        return this.setHasChanged();
    }

    public AggregateQueryBuilder usingGroupingDimension(Soql.GroupingDimension groupingDimension) {
        this.groupingDimension = groupingDimension;
        return this.setHasChanged();
    }

    public AggregateQueryBuilder addAggregateField(Soql.Aggregate aggregateFunction, Schema.SobjectField field) {
        return this.addAggregateField(aggregateFunction, field, null);
    }

    public AggregateQueryBuilder addAggregateField(Soql.Aggregate aggregateFunction, Schema.SobjectField field, String fieldAlias) {
        return this.addAggregateField(aggregateFunction, new Soql.QueryField(field), fieldAlias);
    }

    public AggregateQueryBuilder addAggregateField(Soql.Aggregate aggregateFunction, Soql.QueryField queryField) {
        return this.addAggregateField(aggregateFunction, queryField, null);
    }

    public AggregateQueryBuilder addAggregateField(Soql.Aggregate aggregateFunction, Soql.QueryField queryField, String fieldAlias) {
        //return this.addAggregateField(aggregateFunction, queryField, fieldAlias);
        this.aggregateFields.add(new AggregateField(this.getSobjectType(), aggregateFunction, queryField, fieldAlias));
        return this.setHasChanged();
    }

    public AggregateQueryBuilder havingAggregate(Soql.Aggregate aggregateFunction, Schema.SobjectField field, String operator, Object value) {
        return this.havingAggregate(aggregateFunction, new Soql.QueryField(field), operator, value);
    }

    public AggregateQueryBuilder havingAggregate(Soql.Aggregate aggregateFunction, Soql.QueryField queryField, String operator, Object value) {
        this.havingConditions.add(aggregateFunction.name() + '(' + queryField + ') ' + operator + ' ' + value);
        return this.setHasChanged();
    }

    public AggregateQueryBuilder filterWhere(Schema.SobjectField field, String operator, Object value) {
        return this.filterWhere(new Soql.QueryField(field), operator, value);
    }

    public AggregateQueryBuilder filterWhere(Soql.QueryField queryField, String operator, Object value) {
        return this.filterWhere(new Soql.QueryFilter(queryField, operator, value));
    }

    public AggregateQueryBuilder filterWhere(Soql.QueryFilter filter) {
        return this.filterWhere(new List<Soql.QueryFilter>{filter});
    }

    public AggregateQueryBuilder filterWhere(List<Soql.QueryFilter> filters) {
        super.doFilterWhere(filters);
        return this.setHasChanged();
    }

    public AggregateQueryBuilder orderBy(Schema.SobjectField field) {
        return this.orderBy(field, null);
    }

    public AggregateQueryBuilder orderBy(Soql.QueryField queryField) {
        return this.orderBy(queryField, null);
    }

    public AggregateQueryBuilder orderBy(Schema.SobjectField field, Soql.SortOrder sortOrder) {
        return this.orderBy(field, sortOrder, null);
    }

    public AggregateQueryBuilder orderBy(Soql.QueryField queryField, Soql.SortOrder sortOrder) {
        return this.orderBy(queryField, sortOrder, null);
    }

    public AggregateQueryBuilder orderBy(Schema.SobjectField field, Soql.SortOrder sortOrder, Boolean sortNullsFirst) {
        return this.orderBy(new Soql.QueryField(field), sortOrder, sortNullsFirst);
    }

    public AggregateQueryBuilder orderBy(Soql.QueryField queryField, Soql.SortOrder sortOrder, Boolean sortNullsFirst) {
        super.doOrderBy(queryField, sortOrder, sortNullsFirst);
        return this.setHasChanged();
    }

    public AggregateQueryBuilder orderByAggregate(Soql.Aggregate aggregateFunction, Schema.SobjectField field) {
        return this.orderByAggregate(aggregateFunction, field, null);
    }

    public AggregateQueryBuilder orderByAggregate(Soql.Aggregate aggregateFunction, Schema.SobjectField field, Soql.SortOrder sortOrder) {
        return this.orderByAggregate(aggregateFunction, field, sortOrder, null);
    }

    public AggregateQueryBuilder orderByAggregate(Soql.Aggregate aggregateFunction, Schema.SobjectField field, Soql.SortOrder sortOrder, Boolean sortNullsFirst) {
        return this.orderByAggregate(aggregateFunction, new Soql.QueryField(field), sortOrder, sortNullsFirst);
    }

    public AggregateQueryBuilder orderByAggregate(Soql.Aggregate aggregateFunction, Soql.QueryField queryField) {
        return this.orderByAggregate(aggregateFunction, queryField, null);
    }

    public AggregateQueryBuilder orderByAggregate(Soql.Aggregate aggregateFunction, Soql.QueryField queryField, Soql.SortOrder sortOrder) {
        return this.orderByAggregate(aggregateFunction, queryField, sortOrder, null);
    }

    public AggregateQueryBuilder orderByAggregate(Soql.Aggregate aggregateFunction, Soql.QueryField queryField, Soql.SortOrder sortOrder, Boolean sortNullsFirst) {
        super.doOrderBy(aggregateFunction.name() + '(' + queryField + ')', sortOrder, sortNullsFirst);
        return this.setHasChanged();
    }

    public AggregateQueryBuilder limitTo(Integer numberOfRecords) {
        super.doLimitTo(numberOfRecords);
        return this.setHasChanged();
    }

    public AggregateQueryBuilder offsetBy(Integer offset) {
        super.doOffsetBy(offset);
        return this.setHasChanged();
    }

    public AggregateQueryBuilder cacheResults() {
        super.doCacheResults();
        return this;
    }

    public override String getQuery() {
        if(this.query != null && !this.hasChanged) return this.query;

        String queryFieldString = super.doGetQueryFieldString();
        String aggregateQueryFieldString = this.getAggregateQueryFieldString();
        String aggregateFieldDelimiter = !String.isEmpty(queryFieldString) && !String.isEmpty(aggregateQueryFieldString) ? ', ' : '';

        String combinedFieldsString = queryFieldString + aggregateFieldDelimiter + aggregateQueryFieldString;
        if(String.isBlank(combinedFieldsString)) {
            Schema.SobjectField idField = this.getSobjectType().getDescribe().fields.getMap().get('Id');
            combinedFieldsString = new AggregateField(this.getSobjectType(), Soql.Aggregate.COUNT, new Soql.QueryField(idField), null).toString();
        }

        this.query = 'SELECT ' + combinedFieldsString
            + ' FROM ' + this.sobjectType
            + super.doGetUsingScopeString()
            + super.doGetWhereClauseString()
            + this.getGroupByString()
            + this.getHavingString()
            + super.doGetOrderByString()
            + super.doGetLimitCountString()
            + super.doGetOffetString();

        System.debug(LoggingLevel.FINEST, this.query);
        return this.query;
    }

    public AggregateResult getFirstResult() {
        return (AggregateResult)super.doGetFirstResult();
    }

    public List<AggregateResult> getResults() {
        return (List<AggregateResult>)super.doGetResults();
    }

    private AggregateQueryBuilder setHasChanged() {
        this.hasChanged = true;
        return this;
    }

    private String getAggregateQueryFieldString() {
        if(this.aggregateFields.isEmpty()) return '';

        List<String> aggregateFieldStrings = new List<String>();
        for(AggregateQueryBuilder.AggregateField aggregatedField : this.aggregateFields) {
            aggregateFieldStrings.add(aggregatedField.toString());
        }
        aggregateFieldStrings.sort();
        return String.join(aggregateFieldStrings, ', ');
    }

    private String getGroupByString() {
        String queryFieldString = super.doGetQueryFieldString();

        String groupByTextString              = ' GROUP BY ';
        String groupingDimensionClosingString = '';
        if(this.groupingDimension != null) {
            groupByTextString              += this.groupingDimension.name() + '(';
            groupingDimensionClosingString = ')';
        }

        return String.isEmpty(queryFieldString) ? '' : groupByTextString + queryFieldString + groupingDimensionClosingString;
    }

    private String getHavingString() {
        return this.havingConditions.isEmpty() ? '' : ' HAVING ' + String.join(this.havingConditions, ', ');
    }

    private class AggregateField {

        private Schema.SobjectType sobjectType;
        private String aggregateFieldPath;

        public AggregateField(Schema.SobjectType sobjectType, Soql.Aggregate aggregateFunction, Soql.QueryField queryField, String fieldAlias) {
            this.sobjectType        = sobjectType;
            this.aggregateFieldPath = this.getAggregateFieldPath(aggregateFunction, queryField, fieldAlias);
        }

        public override String toString() {
            return this.aggregateFieldPath;
        }

        private String getAggregateFieldPath(Soql.Aggregate aggregateFunction, Soql.QueryField queryField, String fieldAlias) {
            String fieldApiName = queryField.getDescribe().getName();
            fieldAlias = !String.isEmpty(fieldAlias) ? fieldAlias : fieldApiName + '__' + aggregateFunction.name();

            // Example: MIN(Schema.Lead.MyField__c) is auto-aliased to MyField__c__MIN
            return aggregateFunction.name() + '(' + fieldApiName + ') ' + fieldAlias;
        }

    }

}