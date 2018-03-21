public class Soql {

    public enum Aggregate { AVG, COUNT, COUNT_DISTINCT, MAX, MIN, SUM }
    public enum FieldCategory { ACCESSIBLE, UPDATEABLE, STANDARD, CUSTOM }
    public enum Scope { EVERYTHING, DELEGATED, TEAM, MINE, MY_TERRITORY, MY_TEAM_TERRITORY }
    public enum SortOrder { ASCENDING, DESCENDING }

    public class DateLiteral {
        private String fieldExpression;
        public DateLiteral(String fieldExpression) {
            this.fieldExpression = fieldExpression;
        }
        public override String toString() {
            return this.fieldExpression;
        }
    }

    // TODO this appears to only works if multi-currency is enabled in the org
    public class IsoCurrency { // TODO https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_querying_currency_fields.htm
        private String isoCode;
        private Decimal currencyAmount;
        public IsoCurrency(String isoCode, Decimal currencyAmount) {
            if(!UserInfo.isMultiCurrencyOrganization()) throw new SoqlException('IsoCurrency is only supported in multi-currency orgs');

            this.isoCode        = isoCode;
            this.currencyAmount = currencyAmount;
        }
        public override String toString() {
            return this.isoCode + this.currencyAmount;
        }
    }

    private static final FieldCategory DEFAULT_FIELD_CATEGORY   = FieldCategory.ACCESSIBLE;
    private static final SortOrder DEFAULT_SORT_ORDER           = SortOrder.ASCENDING;
    private static final Boolean DEFAULT_NULLS_SORT_ORDER_FIRST = true;

    private static Map<Integer, List<SObject>> cachedQueryResultsByHashCode = new Map<Integer, List<SObject>>();

    private Schema.SobjectType sobjectType;
    private Schema.DescribeSobjectResult sobjectDescribe;
    private String displayFieldApiName;
    private Map<String, FieldCategory> includedFieldApiNamesAndCategory;
    private List<AggregateField> aggregatedFields;
    private Set<String> excludedFieldApiNames;
    private Scope scope;
    private List<String> whereFilters, orderByFieldApiNames;
    private Integer limitCount;
    private Integer offset;
    private Boolean forReference, forUpdate, forView, cacheResults, includeLabels, includeFormattedValues;

    public Soql(String sobjectApiName) {
        this(Schema.getGlobalDescribe().get(sobjectApiName));
    }

    public Soql(Schema.SobjectType sobjectType) {
        this.sobjectType         = sobjectType;
        this.displayFieldApiName = this.getDisplayFieldApiName(this.sobjectType);

        this.sobjectDescribe                  = this.sobjectType.getDescribe();
        this.includedFieldApiNamesAndCategory = new Map<String, FieldCategory>();
        this.aggregatedFields                 = new List<AggregateField>();
        this.excludedFieldApiNames            = new Set<String>();
        this.whereFilters                     = new List<String>();
        this.orderByFieldApiNames             = new List<String>();
        this.forReference                     = false;
        this.forUpdate                        = false;
        this.forView                          = false;
        this.cacheResults                     = false;
        this.includeLabels                    = false;
        this.includeFormattedValues           = false;
    }

    public Soql addField(SobjectField field) {
        return this.addField(field, DEFAULT_FIELD_CATEGORY);
    }

    public Soql addField(SobjectField field, Soql.FieldCategory fieldCategory) {
        return this.addFields(new List<SobjectField>{field}, fieldCategory);
    }

    public Soql addField(String fieldApiName) {
        return this.addField(fieldApiName, DEFAULT_FIELD_CATEGORY);
    }

    public Soql addField(String fieldApiName, FieldCategory fieldCategory) {
        return this.addFields(new List<String>{fieldApiName}, fieldCategory);
    }

    public Soql addFields(Schema.FieldSet fieldSet) {
        return this.addFields(FieldSet, DEFAULT_FIELD_CATEGORY);
    }

    public Soql addFields(Schema.FieldSet fieldSet, FieldCategory fieldCategory) {
        List<String> fieldApiNames = new List<String>();
        for(Schema.FieldSetMember fieldSetMember : fieldSet.getFields()) {
            fieldApiNames.add(fieldSetMember.getFieldPath());
        }
        return this.addFields(fieldApiNames, fieldCategory);
    }

    public Soql addFields(List<SobjectField> fields) {
        return this.addFields(fields, DEFAULT_FIELD_CATEGORY);
    }

    public Soql addFields(List<SobjectField> fields, Soql.FieldCategory fieldCategory) {
        List<String> fieldApiNames = new List<String>();
        for(SobjectField field : fields) {
            fieldApiNames.add(field.getDescribe().getName());
        }
        return this.addFields(fieldApiNames, fieldCategory);
    }

    public Soql addFields(List<String> fieldApiNames) {
        return this.addFields(fieldApiNames, DEFAULT_FIELD_CATEGORY);
    }

    public Soql addFields(Soql.FieldCategory fieldCategory) {
        return this.addFields(new List<String>(this.sobjectDescribe.fields.getMap().keySet()));
    }

    public Soql addFields(List<String> fieldApiNames, Soql.FieldCategory fieldCategory) {
        for(String fieldApiName : fieldApiNames) this.includedFieldApiNamesAndCategory.put(fieldApiName, fieldCategory);
        return this;
    }

     public Soql aggregateField(Schema.SobjectField field, Soql.Aggregate aggregateFunction) {
        return this.aggregateField(field.getDescribe().getName(), aggregateFunction);
     }

     public Soql aggregateField(String fieldApiName, Soql.Aggregate aggregateFunction) {
        this.aggregatedFields.add(new AggregateField(fieldApiName, aggregateFunction));
        return this;
    }

    public Soql removeField(SobjectField field) {
        return this.removeFields(new List<SobjectField>{field});
    }

    public Soql removeField(String fieldApiName) {
        return this.removeFields(new List<String>{fieldApiName});
    }

    public Soql removeFields(Schema.FieldSet fieldSet) {
        List<String> fieldApiNames = new List<String>();
        for(Schema.FieldSetMember fieldSetMember : fieldSet.getFields()) {
            fieldApiNames.add(fieldSetMember.getFieldPath());
        }
        return this.removeFields(fieldApiNames);
    }

    public Soql removeFields(List<SobjectField> fields) {
        List<String> fieldApiNames = new List<String>();
        for(SobjectField field : fields) {
            fieldApiNames.add(field.getDescribe().getName());
        }
        return this.removeFields(fieldApiNames);
    }

    public Soql removeFields(List<String> excludedFieldApiNames) {
        this.excludedFieldApiNames.addAll(excludedFieldApiNames);
        return this;
    }

    public Soql usingScope(Scope scope) {
        this.scope = scope;
        return this;
    }

    public Soql filterWhere(SobjectField field, String operator, Object value) {
        String whereFilter = field + ' ' + operator + ' ' + this.objectToQueryString(value);
        this.filterWhere(whereFilter);
        return this;
    }

    public Soql filterWhere(String fieldApiName, String operator, Object value) {
        return this.filterWhere(fieldApiName + ' ' + operator + ' ' + this.objectToQueryString(value));
    }

    public Soql filterWhere(String filter) {
        this.whereFilters.add(filter);
        return this;
    }

    public Soql orderBy(Schema.SobjectField field) {
        return this.orderBy(field, DEFAULT_SORT_ORDER, DEFAULT_NULLS_SORT_ORDER_FIRST);
    }

    public Soql orderBy(Schema.SobjectField field, SortOrder sortOrder) {
        return this.orderBy(field, sortOrder, DEFAULT_NULLS_SORT_ORDER_FIRST);
    }

    public Soql orderBy(Schema.SobjectField field, SortOrder sortOrder, Boolean sortNullsFirst) {
        String sortOrderString = sortOrder == Soql.SortOrder.ASCENDING ? 'ASC' : 'DESC';
        return this.orderBy(field.getDescribe().getName(), sortOrderString, sortNullsFirst);
    }

    public Soql orderBy(String fieldApiName) {
        return this.orderBy(fieldApiName, DEFAULT_SORT_ORDER == Soql.SortOrder.ASCENDING ? 'ASC' : 'DESC');
    }

    public Soql orderBy(String fieldApiName, String sortOrder) {
        return this.orderBy(fieldApiName, sortOrder, DEFAULT_NULLS_SORT_ORDER_FIRST);
    }

    public Soql orderBy(String fieldApiName, String sortOrder, Boolean sortNullsFirst) {
        String nullsSortOrder = sortNullsFirst ? 'FIRST' : 'LAST';
        this.orderByFieldApiNames.add(fieldApiName + ' ' + sortOrder + ' NULLS ' + nullsSortOrder);
        return this;
    }

    public Soql limitCount(Integer limitCount) {
        this.limitCount = limitCount;
        return this;
    }

    public Soql offset(Integer offset) {
        this.offset = offset;
        return this;
    }

    public Soql forReference() {
        this.forReference = true;
        return this;
    }

    public Soql forUpdate() {
        this.forUpdate = true;
        return this;
    }

    public Soql forView() {
        this.forView = true;
        return this;
    }

    public Soql includeLabels() {
        this.includeLabels = true;
        return this;
    }

    public Soql includeFormattedValues() {
        this.includeFormattedValues = true;
        return this;
    }

    public Soql cacheResults() {
        this.cacheResults = true;
        return this;
    }

    public String getQuery() {
        String queryFieldString = this.getQueryFieldString();
        String aggregateQueryFieldString = this.getAggregateQueryFieldString();
        String fieldDelimiter = !String.isEmpty(queryFieldString) && !String.isEmpty(aggregateQueryFieldString) ? ', ' : '';

        String query = 'SELECT ' + queryFieldString + fieldDelimiter + aggregateQueryFieldString
            + ' FROM ' + this.sobjectType
            + this.getUsingScopeString()
            + this.getWhereClauseString()
            + this.getGroupByString()
            + this.getOrderByString()
            + this.getLimitCountString()
            + this.getOffetString()
            + this.getForReferenceString()
            + this.getForUpdateString()
            + this.getForViewString();

        System.debug(LoggingLevel.FINEST, query);
        return query;
    }

    public String getSearchQuery() {
        String sobjectTypeOptions = this.getQueryFieldString()
            + this.getWhereClauseString()
            + this.getOrderByString()
            + this.getLimitCountString();

        // If we have any sobject-specific options, then wrap the options in parentheses
        sobjectTypeOptions = String.isEmpty(sobjectTypeOptions) ? '' : '(' + sobjectTypeOptions + ')';

        String searchQuery = this.sobjectType + sobjectTypeOptions;
        System.debug(LoggingLevel.FINEST, searchQuery);
        return searchQuery;
    }

    public Sobject getFirstQueryResult() {
        return this.getQueryResults()[0];
    }

    public List<Sobject> getQueryResults() {
        if(this.cacheResults) return this.getCachedQuery();
        else return Database.query(this.getQuery());
    }

    private String getDisplayFieldApiName(Schema.SObjectType sobjectType) {
        // There are several commonly used names for the display field name - typically, Name
        // Check the common names first before resorting to looping through all SObject fields
        // The order of the field names has been sorted based on number of objects in a dev org with that field
        List<String> educatedGuesses = new List<String>{
            'Name', 'DeveloperName', 'ApiName', 'Title', 'Subject', 'AssetRelationshipNumber', 'CaseNumber',
            'ContractNumber', 'Domain', 'FriendlyName', 'FunctionName', 'Label', 'LocalPart', 'OrderItemNumber',
            'OrderNumber', 'SolutionName', 'TestSuiteName'
        };
        for(String fieldApiName : educatedGuesses) {
            Schema.SObjectField field = sobjectType.getDescribe().fields.getMap().get(fieldApiName);

            if(field == null) continue;

            Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
            if(fieldDescribe.isNameField()) return fieldDescribe.getName();
        }

        // If we still don't have the displayFieldApiName, then loop through all fields to find it
        for(Schema.SObjectField field : sobjectType.getDescribe().fields.getMap().values()) {
            Schema.DescribeFieldResult fieldDescribe = field.getDescribe();

            if(fieldDescribe.isNameField()) return fieldDescribe.getName();
        }

        return null;
    }

    private String getParentObjectNameField(Schema.SobjectField field) {
        String relationshipName = field.getDescribe().getRelationshipName();
        Schema.SobjectType parentSobjectType = field.getDescribe().getReferenceTo()[0];
        String nameField = this.getDisplayFieldApiName(parentSobjectType);

        if(relationshipName == null) return null;
        if(nameField == null) return null;
        return relationshipName + '.' + nameField;
    }

    private String getFieldToLabel(String fieldApiName) {
        return 'toLabel(' + fieldApiName + ') ' + fieldApiName.replace('.', '_') + '__Label';
    }

    private String getFieldFormat(String fieldApiName) {
        return 'format(' + fieldApiName + ') ' + fieldApiName.replace('.', '_') + '__Format';
    }

    private String objectToQueryString(Object valueToFormat) {
        if(valueToFormat == null) return null;
        else if(valueToFormat instanceOf List<Object>) return this.listToQueryString((List<Object>)valueToFormat);
        else if(valueToFormat instanceOf Set<Object>) return this.setToQueryString(valueToFormat);
        else if(valueToFormat instanceOf Map<Object, Object>) return this.mapToQueryString(valueToFormat);
        else if(valueToFormat instanceOf Date) return String.valueOf((Date)valueToFormat).left(10);
        else if(valueToFormat instanceOf Datetime) {
            Datetime datetimeValue = (Datetime)valueToFormat;
            return datetimeValue.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'', 'Greenwich Mean Time');
        }
        else if(valueToFormat instanceOf SObject) {
            SObject record = (SObject)valueToFormat;
            return wrapInSingleQuotes(((SObject)valueToFormat).Id);
        }
        else if(valueToFormat instanceOf String) {
            // Escape single quotes to prevent SOQL/SOSL injection
            String stringArgument = String.escapeSingleQuotes((String)valueToFormat);
            return wrapInSingleQuotes(stringArgument);
        }
        else return String.valueOf(valueToFormat);
    }

    private String wrapInSingleQuotes(String input) {
        input = input.trim();
        if(input.left(1) != '\'') input = '\'' + input;
        if(input.right(1) != '\'') input = input + '\'';
        return input;
    }

    private String listToQueryString(List<Object> valueList) {
        List<String> parsedValueList = new List<String>();
        for(Object value : valueList) parsedValueList.add(this.objectToQueryString(value));
        return '(' + String.join(parsedValueList, ', ') + ')';
    }

    private String setToQueryString(Object valueSet) {
        String unformattedString = String.valueOf(valueSet).replace('{', '').replace('}', '');
        List<String> parsedValueList = new List<String>();
        for(String collectionItem : unformattedString.split(',')) {
            parsedValueList.add(this.objectToQueryString(collectionItem));
        }

        return '(' + String.join(parsedValueList, ', ') + ')';
    }

    private String mapToQueryString(Object valueMap) {
        Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(valueMap));

        return this.setToQueryString(m.keySet());
    }

    private List<String> getFieldsToQuery(String fieldApiName, FieldCategory fieldCat) {
        List<String> fieldsToReturn = new List<String>();
        Schema.SobjectField field = this.sobjectDescribe.fields.getMap().get(fieldApiName);

        if(field == null) {
            // TODO right now, this adds any field name that can't be parsed. This could be due to
            //      1. An invalid field name
            //      2. A parent field, using dot notation. Logic needs to be added to handle this scenario
            fieldsToReturn.add(fieldApiName);
            return fieldsToReturn;
        }

        if(fieldCat == null) return fieldsToReturn;
        else if(fieldCat == FieldCategory.ACCESSIBLE && !field.getDescribe().isAccessible()) return fieldsToReturn;
        else if(fieldCat == FieldCategory.UPDATEABLE && !field.getDescribe().isUpdateable()) return fieldsToReturn;
        else if(fieldCat == FieldCategory.STANDARD && field.getDescribe().isCustom()) return fieldsToReturn;
        else if(fieldCat == FieldCategory.CUSTOM && !field.getDescribe().isCustom()) return fieldsToReturn;

        fieldsToReturn.add(field.getDescribe().getName());

        // If the field has picklist options, then it can be translated
        if(this.includeLabels && !field.getDescribe().getPickListValues().isEmpty()) {
            fieldsToReturn.add(this.getFieldToLabel(field.getDescribe().getName()));
        }

        // If the field is a number, date, time, or currency, it can be formatted
        List<Schema.DisplayType> supportedTypesForFormat = new List<Schema.DisplayType>{
            Schema.DisplayType.CURRENCY, Schema.DisplayType.DATE, Schema.DisplayType.DATETIME, Schema.DisplayType.DOUBLE,
            Schema.DisplayType.INTEGER, Schema.DisplayType.PERCENT, Schema.DisplayType.TIME
        };
        if(this.includeFormattedValues && supportedTypesForFormat.contains(field.getDescribe().getType())) {
            fieldsToReturn.add(this.getFieldFormat(field.getDescribe().getName()));
        }

        // If the field is a lookup, then we need to get the name field from the parent object
        if(field.getDescribe().getType().name() == 'Reference') {
            String parentNameField = this.getParentObjectNameField(field);
            if(parentNameField != null) {
                fieldsToReturn.add(parentNameField);
                // Record type names can be translated, so include the translation
                if(this.includeLabels && fieldApiName == 'RecordTypeId') fieldsToReturn.add(this.getFieldToLabel(parentNameField));
            }
        }

        return fieldsToReturn;
    }

    private String getQueryFieldString() {
        for(String excludedFieldApiName : this.excludedFieldApiNames) {
            this.includedFieldApiNamesAndCategory.remove(excludedFieldApiName);
        }
        Set<String> fieldApiNamesToQuery = new Set<String>();
        for(String fieldApiName : this.includedFieldApiNamesAndCategory.keySet()) {
            FieldCategory fieldCategory = this.includedFieldApiNamesAndCategory.get(fieldApiName);

            List<String> fieldsToQuery = this.getFieldsToQuery(fieldApiName, fieldCategory);
            if(!fieldsToQuery.isEmpty()) fieldApiNamesToQuery.addAll(fieldsToQuery);
        }

        // If the query is NOT an aggregate query, then add the Id & display name fields automatically
        if(this.aggregatedFields.isEmpty()) {
            fieldApiNamesToQuery.add('Id');
            fieldApiNamesToQuery.add(this.displayFieldApiName);
        }

        return String.join(new List<String>(fieldApiNamesToQuery), ', ');
    }

    private String getAggregateQueryFieldString() {
        if(this.aggregatedFields.isEmpty()) return '';

        List<String> aggregatedFieldStrings = new List<String>();
        for(AggregateField aggregatedField : this.aggregatedFields) aggregatedFieldStrings.add(aggregatedField.toString());
        return String.join(aggregatedFieldStrings, ', ');
    }

    private String getUsingScopeString() {
        return this.scope == null ? '' : ' USING SCOPE ' + this.scope.name();
    }

    private String getWhereClauseString() {
        return this.whereFilters.isEmpty() ? '' : ' WHERE ' + String.join(this.whereFilters, ' AND ');
    }

    private String getGroupByString() {
        // TODO might need a better way to track if the query is a standard query or aggregate
        String queryFieldString = this.getQueryFieldString();
        return String.isEmpty(queryFieldString) || this.aggregatedFields.isEmpty() ? '' : ' GROUP BY ' + queryFieldString;
    }

    private String getOrderByString() {
        return this.orderByFieldApiNames.isEmpty() ? '' : ' ORDER BY ' + String.join(this.orderByFieldApiNames, ', ');
    }

    private String getLimitCountString() {
        return this.limitCount == null ? '' : ' LIMIT ' + limitCount;
    }

    private String getOffetString() {
        return this.offset == null ? '' : ' OFFSET ' + this.offset;
    }

    private String getForReferenceString() {
        return !this.forReference ? '' : ' FOR REFERENCE';
    }

    private String getForUpdateString() {
        return !this.forUpdate ? '' : ' FOR UPDATE';
    }

    private String getForViewString() {
        return !this.forView ? '' : ' FOR VIEW';
    }

    private List<SObject> getCachedQuery() {
        String query = this.getQuery();
        Integer hashCode = query.hashCode();

        Boolean isCached = cachedQueryResultsByHashCode.containsKey(hashCode);
        if(!isCached) cachedQueryResultsByHashCode.put(hashCode, Database.query(query));

        // Always return a deep clone so the original cached version is never modified
        return cachedQueryResultsByHashCode.get(hashCode).deepClone(true, true, true);
    }

    private class SoqlException extends Exception {}

    private class AggregateField {
        private String fieldApiName, fieldAlias;
        private Soql.Aggregate aggregateFunction;
        public AggregateField(String fieldApiName, Soql.Aggregate aggregateFunction) {
            this.aggregateFunction = aggregateFunction;
            this.fieldAlias        = aggregateFunction.name() + '__' + fieldApiName;
            this.fieldApiName      = fieldApiName;
        }
        public override String toString() {
            // Alias: MIN(Schema.Lead.MyField__c) is auto-aliased to MIN_MyField__c
            return this.aggregateFunction.name() + '(' + fieldApiName + ') ' + fieldAlias;
        }
    }

}