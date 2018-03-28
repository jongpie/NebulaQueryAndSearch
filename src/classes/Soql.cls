public class Soql {

    public enum Aggregate { AVG, COUNT, COUNT_DISTINCT, MAX, MIN, SUM }
    public enum FieldCategory { ACCESSIBLE, UPDATEABLE, STANDARD, CUSTOM }
    public enum Scope { EVERYTHING, DELEGATED, TEAM, MINE, MY_TERRITORY, MY_TEAM_TERRITORY }
    public enum SortOrder { ASCENDING, DESCENDING }

    public class SoqlException extends Exception {}

    public class DateLiteral {
        private String fieldExpression;
        public DateLiteral(String fieldExpression) {
            this.fieldExpression = fieldExpression;
        }
        public override String toString() {
            return this.fieldExpression;
        }
    }

    public class FieldPath {
        private final String fieldPath;
        private final Schema.DescribeFieldResult fieldDescribe;
        public FieldPath(Schema.SobjectType sobjectType, String fieldPath) {
            this.fieldDescribe = this.getLastFieldDescribe(sobjectType, fieldPath);
            this.fieldPath     = fieldPath;
        }
        public FieldPath(Schema.SobjectField field) {
            this(new List<Schema.SobjectField>{field});
        }
        public FieldPath(List<Schema.SobjectField> fields) {
            this.fieldDescribe = this.getLastFieldDescribe(fields);
            this.fieldPath     = this.getFieldPath(fields);
        }
        public override String toString() {
            return this.fieldPath;
        }
        public Schema.DescribeFieldResult getDescribe() {
            return this.fieldDescribe;
        }
        private Schema.DescribeFieldResult getLastFieldDescribe(Schema.SobjectType sobjectType, String fieldPath) {
            Schema.SobjectType currentSobjectType = sobjectType;
            List<Schema.SobjectField> fields = new List<Schema.SobjectField>();
            List<String> fieldPathPieces = fieldPath.split('\\.');
            Integer lastFieldIndex = fieldPathPieces.size() - 1;
            for(Integer i = 0; i < fieldPathPieces.size(); i++) {
                String fieldPathPiece = fieldPathPieces[i];

                String fieldApiName;
                if(i == lastFieldIndex) fieldApiName = fieldPathPiece;
                else if(fieldPathPiece.endsWith('__r')) fieldApiName = fieldPathPiece.replace('__r', '__c');
                else fieldApiName = fieldPathPiece + 'Id';

                Schema.SobjectField field = currentSobjectType.getDescribe().fields.getMap().get(fieldApiName);

                if(i < lastFieldIndex) currentSobjectType = field.getDescribe().getReferenceTo()[0]; // TODO add support for polymorphic fields

                fields.add(field);
            }
            return this.getLastFieldDescribe(fields);
        }
        private Schema.DescribeFieldResult getLastFieldDescribe(List<Schema.SobjectField> fields) {
            Integer lastFieldIndex = fields.size() - 1;
            return fields[lastFieldIndex].getDescribe();
        }
        private String getFieldPath(List<Schema.SobjectField> fields) {
            Integer lastFieldIndex = fields.size() - 1;
            List<String> fieldPathPieces = new List<String>();
            for(Integer i = 0; i < fields.size(); i++) {
                SobjectField field = fields[i];
                // If any field in the chain is not accessible, then the user cant access the data, so return an empty list
                if(!field.getDescribe().isAccessible()) return null;
                else if(i == lastFieldIndex) fieldPathPieces.add(field.getDescribe().getName());
                else fieldPathPieces.add(field.getDescribe().getRelationshipName());
            }
            return String.join(fieldPathPieces, '.');
        }
    }

    public class IsoCurrency {
        private final String isoCurrency;
        public IsoCurrency(String isoCode, Decimal currencyAmount) {
            if(!UserInfo.isMultiCurrencyOrganization()) throw new SoqlException('IsoCurrency is only supported in multi-currency orgs');
            this.isoCurrency = isoCode + currencyAmount;
        }
        public override String toString() {
            return this.isoCurrency;
        }
    }

    private static final FieldCategory DEFAULT_FIELD_CATEGORY   = FieldCategory.ACCESSIBLE;
    private static final SortOrder DEFAULT_SORT_ORDER           = SortOrder.ASCENDING;
    private static final Boolean DEFAULT_NULLS_SORT_ORDER_FIRST = true;

    private static Map<Integer, List<SObject>> cachedQueryResultsByHashCode = new Map<Integer, List<SObject>>();

    private Schema.SobjectType sobjectType;
    private Schema.DescribeSobjectResult sobjectDescribe;
    private String displayFieldApiName, query;
    private Map<Soql.FieldPath, FieldCategory> includedFieldPathsAndCategory;
    private List<Soql.AggregateField> aggregatedFields;
    private Set<Soql.FieldPath> excludedFieldPaths;
    private Scope scope;
    private List<String> whereFilters, orderByFieldApiNames;
    private Integer limitCount;
    private Integer offset;
    private Boolean soqlHasChanged, forReference, forUpdate, forView, cacheResults, includeLabels, includeFormattedValues;

    public Soql(Schema.SobjectType sobjectType) {
        this.sobjectType         = sobjectType;
        this.displayFieldApiName = this.getDisplayFieldApiName(this.sobjectType);

        this.sobjectDescribe                  = this.sobjectType.getDescribe();
        this.includedFieldPathsAndCategory    = new Map<Soql.FieldPath, FieldCategory>();
        this.aggregatedFields                 = new List<Soql.AggregateField>();
        this.excludedFieldPaths               = new Set<Soql.FieldPath>();
        this.whereFilters                     = new List<String>();
        this.orderByFieldApiNames             = new List<String>();
        this.forReference                     = false;
        this.forUpdate                        = false;
        this.forView                          = false;
        this.cacheResults                     = false;
        this.includeLabels                    = false;
        this.includeFormattedValues           = false;
        this.soqlHasChanged                   = false;
    }

    public Soql addField(Schema.SobjectField field) {
        return this.addField(field, DEFAULT_FIELD_CATEGORY);
    }

    public Soql addField(Schema.SobjectField field, Soql.FieldCategory fieldCategory) {
        return this.addFields(new List<Schema.SobjectField>{field}, fieldCategory);
    }

    public Soql addField(Soql.FieldPath fieldPath) {
        return this.addField(fieldPath, DEFAULT_FIELD_CATEGORY);
    }

    public Soql addField(Soql.FieldPath fieldPath, Soql.FieldCategory fieldCategory) {
        return this.addFields(new List<Soql.FieldPath>{fieldPath}, fieldCategory);
    }

    public Soql addFields(Schema.FieldSet fieldSet) {
        return this.addFields(FieldSet, DEFAULT_FIELD_CATEGORY);
    }

    public Soql addFields(Schema.FieldSet fieldSet, FieldCategory fieldCategory) {
        List<Soql.FieldPath> fieldPaths = new List<Soql.FieldPath>();
        for(Schema.FieldSetMember fieldSetMember : fieldSet.getFields()) {
            fieldPaths.add(new Soql.FieldPath(this.sobjectType, fieldSetMember.getFieldPath()));
        }
        return this.addFields(fieldPaths, fieldCategory);
    }

    public Soql addFields(List<Schema.SobjectField> fields) {
        return this.addFields(fields, DEFAULT_FIELD_CATEGORY);
    }

    public Soql addFields(List<Schema.SobjectField> fields, Soql.FieldCategory fieldCategory) {
        List<Soql.FieldPath> fieldPaths = new List<Soql.FieldPath>();
        for(Schema.SobjectField field : fields) {
            fieldPaths.add(new Soql.FieldPath(field));
        }
        return this.addFields(fieldPaths, fieldCategory);
    }

    public Soql addFields(List<Soql.FieldPath> fieldPaths) {
        return this.addFields(fieldPaths, DEFAULT_FIELD_CATEGORY);
    }

    public Soql addFields(List<Soql.FieldPath> fieldPaths, Soql.FieldCategory fieldCategory) {
        for(Soql.FieldPath fieldPath : fieldPaths) {
            this.includedFieldPathsAndCategory.put(fieldPath, fieldCategory);
        }
        return this;
    }

    public Soql addFields(Soql.FieldCategory fieldCategory) {
        List<Soql.FieldPath> fieldPaths = new List<Soql.FieldPath>();
        for(Schema.SobjectField field : this.sobjectDescribe.fields.getMap().values()) {
            fieldPaths.add(new Soql.FieldPath(field));
        }
        return this.addFields(fieldPaths, DEFAULT_FIELD_CATEGORY);
    }

    public Soql aggregateField(Schema.SobjectField field, Soql.Aggregate aggregateFunction) {
        this.aggregatedFields.add(new Soql.AggregateField(field, aggregateFunction));
        return this.setSoqlHasChanged();
    }

    public Soql removeField(Schema.SobjectField field) {
        return this.removeFields(new List<Schema.SobjectField>{field});
    }

    public Soql removeField(Soql.FieldPath fieldPath) {
        return this.removeFields(new List<Soql.FieldPath>{fieldPath});
    }

    public Soql removeFields(Schema.FieldSet fieldSet) {
        List<Soql.FieldPath> fieldPaths = new List<Soql.FieldPath>();
        for(Schema.FieldSetMember fieldSetMember : fieldSet.getFields()) {
            fieldPaths.add(new Soql.FieldPath(this.sobjectType, fieldSetMember.getFieldPath()));
        }
        return this.removeFields(fieldPaths);
    }

    public Soql removeFields(List<Schema.SobjectField> fields) {
        List<Soql.FieldPath> fieldPaths = new List<Soql.FieldPath>();
        for(Schema.SobjectField field : fields) {
            fieldPaths.add(new Soql.FieldPath(field));
        }
        return this.removeFields(fieldPaths);
    }

    public Soql removeFields(List<Soql.FieldPath> fieldPaths) {
        this.excludedFieldPaths.addAll(fieldPaths);
        return this.setSoqlHasChanged();
    }

    public Soql usingScope(Scope scope) {
        this.scope = scope;
        return this.setSoqlHasChanged();
    }

    public Soql filterWhere(Schema.SobjectField field, String operator, Object value) {
        Soql.FieldPath fieldPath = new FieldPath(new List<Schema.SobjectField>{field});
        return this.filterWhere(fieldPath, operator, value);
    }

    public Soql filterWhere(Soql.FieldPath fieldPath, String operator, Object value) {
        String whereFilter = fieldPath + ' ' + operator + ' ' + this.formatObjectForQueryString(value);
        //return this.filterWhere(whereFilter);
        this.whereFilters.add(whereFilter);
        return this.setSoqlHasChanged();
    }

//TODO decide to keep or eliminate
/*public Soql filterWhere(String filter) {
        this.whereFilters.add(String.escapeSingleQuotes(filter));
        return this.setSoqlHasChanged();
    }*/

    public Soql orderBy(Schema.SobjectField field) {
        return this.orderBy(field, DEFAULT_SORT_ORDER, DEFAULT_NULLS_SORT_ORDER_FIRST);
    }

    public Soql orderBy(Schema.SobjectField field, SortOrder sortOrder) {
        return this.orderBy(field, sortOrder, DEFAULT_NULLS_SORT_ORDER_FIRST);
    }

    public Soql orderBy(Schema.SobjectField field, SortOrder sortOrder, Boolean sortNullsFirst) {
        return this.orderBy(new FieldPath(field), sortOrder, sortNullsFirst);
    }

    public Soql orderBy(Soql.FieldPath fieldPath) {
        return this.orderBy(fieldPath, DEFAULT_SORT_ORDER, DEFAULT_NULLS_SORT_ORDER_FIRST);
    }

    public Soql orderBy(Soql.FieldPath fieldPath, SortOrder sortOrder) {
        return this.orderBy(fieldPath, sortOrder, DEFAULT_NULLS_SORT_ORDER_FIRST);
    }

    public Soql orderBy(Soql.FieldPath fieldPath, SortOrder sortOrder, Boolean sortNullsFirst) {
        String sortOrderString = sortOrder == Soql.SortOrder.ASCENDING ? 'ASC' : 'DESC';
        String nullsSortOrder = sortNullsFirst ? 'FIRST' : 'LAST';
        this.orderByFieldApiNames.add(fieldPath + ' ' + sortOrderString + ' NULLS ' + nullsSortOrder);
        return this.setSoqlHasChanged();
    }

    public Soql limitCount(Integer limitCount) {
        this.limitCount = limitCount;
        return this.setSoqlHasChanged();
    }

    public Soql offset(Integer offset) {
        this.offset = offset;
        return this.setSoqlHasChanged();
    }

    public Soql forReference() {
        this.forReference = true;
        return this.setSoqlHasChanged();
    }

    public Soql forUpdate() {
        this.forUpdate = true;
        return this.setSoqlHasChanged();
    }

    public Soql forView() {
        this.forView = true;
        return this.setSoqlHasChanged();
    }

    public Soql includeLabels() {
        this.includeLabels = true;
        return this.setSoqlHasChanged();
    }

    public Soql includeFormattedValues() {
        this.includeFormattedValues = true;
        return this.setSoqlHasChanged();
    }

    public Soql cacheResults() {
        this.cacheResults = true;
        return this.setSoqlHasChanged();
    }

    public String getQuery() {
        if(this.query != null && !this.soqlHasChanged) return this.query;

        String queryFieldString = this.getQueryFieldString();
        String aggregateQueryFieldString = this.getAggregateQueryFieldString();
        String fieldDelimiter = !String.isEmpty(queryFieldString) && !String.isEmpty(aggregateQueryFieldString) ? ', ' : '';

        this.query = 'SELECT ' + queryFieldString + fieldDelimiter + aggregateQueryFieldString
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

        // Change soqlHasChanged to false so that subsequent calls to getQuery() use the cached query string
        // If additional builder methods are later called, the builder methods will set soqlHasChanged = true
        this.soqlHasChanged = false;

        System.debug(LoggingLevel.FINEST, this.query);
        return this.query;
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

    private Soql setSoqlHasChanged() {
        this.soqlHasChanged = true;
        return this;
    }

    private String getDisplayFieldApiName(Schema.SObjectType sobjectType) {
        // There are several commonly used names for the display field name - typically, Name
        // Check the common names first before resorting to looping through all SObject fields
        // The order of the field names has been sorted based on number of objects in a dev org with that field
        List<String> possibleDisplayFieldApiNames = new List<String>{
            'Name', 'DeveloperName', 'ApiName', 'Title', 'Subject', 'AssetRelationshipNumber',
            'CaseNumber', 'ContractNumber', 'Domain', 'FriendlyName', 'FunctionName', 'Label', 'LocalPart',
            'OrderItemNumber', 'OrderNumber', 'SolutionName', 'TestSuiteName'
        };
        Map<String, Schema.SobjectField> fieldMap = sobjectType.getDescribe().fields.getMap();
        for(String fieldApiName : possibleDisplayFieldApiNames) {
            Schema.SObjectField field = fieldMap.get(fieldApiName);

            if(field == null) continue;

            Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
            if(fieldDescribe.isNameField()) return fieldDescribe.getName();
        }

        return null;
    }

    private String getParentObjectNameField(Schema.DescribeFieldResult fieldDescribe) {
        String relationshipName = fieldDescribe.getRelationshipName();
        Schema.SobjectType parentSobjectType = fieldDescribe.getReferenceTo()[0];
        String nameField = this.getDisplayFieldApiName(parentSobjectType);

        if(relationshipName == null) return null;
        if(nameField == null) return null;
        return relationshipName + '.' + nameField;
    }

    private String getFieldToLabel(String fieldApiName) {
        return 'toLabel(' + fieldApiName + ') ' + fieldApiName.replace('.', '_') + '__Label';
    }

    private String getFieldFormattedValue(String fieldApiName) {
        return 'format(' + fieldApiName + ') ' + fieldApiName.replace('.', '_') + '__Formatted';
    }

    private String formatObjectForQueryString(Object valueToFormat) {
        if(valueToFormat == null) return null;
        else if(valueToFormat instanceOf List<Object>) return this.convertListToQueryString((List<Object>)valueToFormat);
        else if(valueToFormat instanceOf Set<Object>) return this.convertSetToQueryString(valueToFormat);
        else if(valueToFormat instanceOf Map<Object, Object>) return this.convertMapToQueryString(valueToFormat);
        else if(valueToFormat instanceOf Date) return String.valueOf((Date)valueToFormat).left(10);
        else if(valueToFormat instanceOf Datetime) {
            Datetime datetimeValue = (Datetime)valueToFormat;
            return datetimeValue.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'', 'Greenwich Mean Time');
        }
        else if(valueToFormat instanceOf SObject) {
            SObject record = (SObject)valueToFormat;
            return this.wrapInSingleQuotes(((SObject)valueToFormat).Id);
        }
        else if(valueToFormat instanceOf String) {
            // Escape single quotes to prevent SOQL/SOSL injection
            String stringArgument = String.escapeSingleQuotes((String)valueToFormat);
            return this.wrapInSingleQuotes(stringArgument);
        }
        else return String.valueOf(valueToFormat);
    }

    private String wrapInSingleQuotes(String input) {
        input = input.trim();
        if(input.left(1) != '\'') input = '\'' + input;
        if(input.right(1) != '\'') input = input + '\'';
        return input;
    }

    private String convertListToQueryString(List<Object> valueList) {
        List<String> parsedValueList = new List<String>();
        for(Object value : valueList) {
            parsedValueList.add(this.formatObjectForQueryString(value));
        }
        return '(' + String.join(parsedValueList, ', ') + ')';
    }

    private String convertSetToQueryString(Object valueSet) {
        String unformattedString = String.valueOf(valueSet).replace('{', '').replace('}', '');
        List<String> parsedValueList = new List<String>();
        for(String collectionItem : unformattedString.split(',')) {
            parsedValueList.add(this.formatObjectForQueryString(collectionItem));
        }
        return '(' + String.join(parsedValueList, ', ') + ')';
    }

    private String convertMapToQueryString(Object valueMap) {
        Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(valueMap));
        return this.convertSetToQueryString(m.keySet());
    }

    private List<String> getFieldsToQuery(FieldPath fieldPath, FieldCategory fieldCat) {
        List<String> fieldsToReturn = new List<String>();
        //Schema.SobjectField field = this.sobjectDescribe.fields.getMap().get(fieldApiName);

        if(fieldCat == null) return fieldsToReturn;
        else if(fieldCat == FieldCategory.ACCESSIBLE && !fieldPath.getDescribe().isAccessible()) return fieldsToReturn;
        else if(fieldCat == FieldCategory.UPDATEABLE && !fieldPath.getDescribe().isUpdateable()) return fieldsToReturn;
        else if(fieldCat == FieldCategory.STANDARD && fieldPath.getDescribe().isCustom()) return fieldsToReturn;
        else if(fieldCat == FieldCategory.CUSTOM && !fieldPath.getDescribe().isCustom()) return fieldsToReturn;

        fieldsToReturn.add(fieldPath.toString());

        // If the field has picklist options, then it can be translated
        if(this.includeLabels && !fieldPath.getDescribe().getPickListValues().isEmpty()) {
            fieldsToReturn.add(this.getFieldToLabel(fieldPath.getDescribe().getName()));
        }

        // If the field is a number, date, time, or currency, it can be formatted
        List<Schema.DisplayType> supportedTypesForFormat = new List<Schema.DisplayType>{
            Schema.DisplayType.CURRENCY, Schema.DisplayType.DATE, Schema.DisplayType.DATETIME, Schema.DisplayType.DOUBLE,
            Schema.DisplayType.INTEGER, Schema.DisplayType.PERCENT, Schema.DisplayType.TIME
        };
        if(this.includeFormattedValues && supportedTypesForFormat.contains(fieldPath.getDescribe().getType())) {
            fieldsToReturn.add(this.getFieldFormattedValue(fieldPath.getDescribe().getName()));
        }

        // If the field is a lookup, then we need to get the name field from the parent object
        if(fieldPath.getDescribe().getType().name() == 'Reference') {
            String parentNameField = this.getParentObjectNameField(fieldPath.getDescribe());
            if(parentNameField != null) {
                fieldsToReturn.add(parentNameField);
                // Record type names can be translated, so include the translation
                if(this.includeLabels && fieldPath.toString() == 'RecordTypeId') fieldsToReturn.add(this.getFieldToLabel(parentNameField));
            }
        }

        return fieldsToReturn;
    }

    private String getQueryFieldString() {
        Set<String> distinctFieldApiNamesToQuery = new Set<String>();
        for(FieldPath fieldPath : this.includedFieldPathsAndCategory.keySet()) {
            FieldCategory fieldCategory = this.includedFieldPathsAndCategory.get(fieldPath);

            List<String> fieldsToQuery = this.getFieldsToQuery(fieldPath, fieldCategory);
            if(!fieldsToQuery.isEmpty()) distinctFieldApiNamesToQuery.addAll(fieldsToQuery);
        }

        // If the query is NOT an aggregate query, then add the Id & display name fields automatically
        if(this.aggregatedFields.isEmpty()) {
            distinctFieldApiNamesToQuery.add('Id');
            distinctFieldApiNamesToQuery.add(this.displayFieldApiName);
        }

        // Remove an excluded field paths
        for(Soql.FieldPath excludedFieldPath : this.excludedFieldPaths) {
            distinctFieldApiNamesToQuery.remove(excludedFieldPath.toString());
        }

        List<String> fieldApiNamesToQuery = new List<String>(distinctFieldApiNamesToQuery);
        if(this.aggregatedFields.isEmpty()) fieldApiNamesToQuery.sort();
        return String.join(fieldApiNamesToQuery, ', ');
    }

    private String getAggregateQueryFieldString() {
        if(this.aggregatedFields.isEmpty()) return '';

        List<String> aggregatedFieldStrings = new List<String>();
        for(Soql.AggregateField aggregatedField : this.aggregatedFields) {
            aggregatedFieldStrings.add(aggregatedField.toString());
        }
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
        return this.limitCount == null ? '' : ' LIMIT ' + this.limitCount;
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

    private class AggregateField {
        private String aggregateField;
        public AggregateField(Schema.SobjectField field, Soql.Aggregate aggregateFunction) {
            String fieldApiName = field.getDescribe().getName();
            String fieldAlias   = fieldApiName + '__' + aggregateFunction.name();

            // Alias: MIN(Schema.Lead.MyField__c) is auto-aliased to MyField__c__MIN
            this.aggregateField = aggregateFunction.name() + '(' + fieldApiName + ') ' + fieldAlias;
        }
        public override String toString() {
            return this.aggregateField;
        }
    }

}