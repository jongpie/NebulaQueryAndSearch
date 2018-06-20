/******************************************************************************************************
* This file is part of the Nebula Query & Search project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaQueryAndSearch for full license details. *
******************************************************************************************************/
public abstract class Soql implements Comparable {

    public enum FieldCategory { ACCESSIBLE, UPDATEABLE, STANDARD, CUSTOM, IGNORE_FLS }
    public enum Scope { EVERYTHING, DELEGATED, TEAM, MINE, MY_TERRITORY, MY_TEAM_TERRITORY }
    public enum SortOrder { ASCENDING, DESCENDING }

    private static final Soql.FieldCategory DEFAULT_FIELD_CATEGORY = Soql.FieldCategory.ACCESSIBLE;
    private static final Soql.SortOrder DEFAULT_SORT_ORDER         = Soql.SortOrder.ASCENDING;
    private static final Boolean DEFAULT_NULLS_SORT_ORDER_FIRST    = true;

    private static Map<Integer, List<Sobject>> cachedResultsByHashCode = new Map<Integer, List<Sobject>>();

    protected String query;
    protected Schema.SobjectType sobjectType;
    protected Schema.DescribeSobjectResult sobjectDescribe;
    protected Map<Soql.QueryField, Soql.FieldCategory> includedQueryFieldsAndCategory;
    protected Set<Soql.QueryField> excludedQueryFields;
    protected Scope scope;
    protected List<String> whereFilters, orderByFieldApiNames;
    protected Integer limitCount;
    protected Integer offset;
    protected Boolean hasChanged, sortQueryFields;

    protected Boolean cacheResults;

    protected Soql(Schema.SobjectType sobjectType, Boolean sortQueryFields) {
        this.sobjectType     = sobjectType;
        this.sortQueryFields = sortQueryFields;

        this.sobjectDescribe                = this.sobjectType.getDescribe();
        this.includedQueryFieldsAndCategory = new Map<Soql.QueryField, Soql.FieldCategory>();
        this.excludedQueryFields            = new Set<Soql.QueryField>();
        this.whereFilters                   = new List<String>();
        this.orderByFieldApiNames           = new List<String>();
        this.cacheResults                   = false;
        this.hasChanged                     = false;
    }

    public Schema.SobjectType getSobjectType() {
        return this.sobjectType;
    }

    public abstract String getQuery();

    public Integer compareTo(Object compareTo) {
        String currentSobjectApiName   = String.valueOf(this.getSobjectType());
        Soql soqlToCompareTo           = (Soql)compareTo;
        String compareToSobjectApiName = String.valueOf(soqlToCompareTo.getSobjectType());

        if(currentSobjectApiName == compareToSobjectApiName) return 0;
        else if(currentSobjectApiName > compareToSobjectApiName) return 1;
        else return -1;
    }

    protected void doCacheResults() {
        this.cacheResults = true;
    }

    protected void doAddFields(List<Soql.QueryField> queryFields, Soql.FieldCategory fieldCategory) {
        if(fieldCategory == null) fieldCategory = DEFAULT_FIELD_CATEGORY;
        for(Soql.QueryField queryField : queryFields) {
            this.includedQueryFieldsAndCategory.put(queryField, fieldCategory);
        }
        this.doSetHasChanged();
    }

    protected void doRemoveFields(List<Soql.QueryField> queryFields) {
        this.excludedQueryFields.addAll(queryFields);
    }

    protected void doUsingScope(Scope scope) {
        this.scope = scope;
    }

    protected void doFilterWhere(List<Soql.QueryFilter> filters) {
        if(filters == null) return;

        for(Soql.QueryFilter filter : filters) this.whereFilters.add(filter.toString());
        this.doSetHasChanged();
    }

    protected void doOrderBy(Soql.QueryField queryField, Soql.SortOrder sortOrder, Boolean sortNullsFirst) {
        this.doOrderBy(queryField.toString(), sortOrder, sortNullsFirst);
    }

    protected void doOrderBy(String fieldPath, Soql.SortOrder sortOrder, Boolean sortNullsFirst) {
        if(sortOrder == null) sortOrder = DEFAULT_SORT_ORDER;
        if(sortNullsFirst == null) sortNullsFirst = DEFAULT_NULLS_SORT_ORDER_FIRST;

        String sortOrderString = sortOrder == Soql.SortOrder.ASCENDING ? 'ASC' : 'DESC';
        String nullsSortOrder = sortNullsFirst ? 'FIRST' : 'LAST';
        this.orderByFieldApiNames.add(fieldPath + ' ' + sortOrderString + ' NULLS ' + nullsSortOrder);
    }

    protected void doLimitTo(Integer numberOfRecords) {
        this.limitCount = numberOfRecords;
    }

    protected void doOffsetBy(Integer offset) {
        this.offset = offset;
    }

    protected Sobject doGetFirstResult() {
        List<Sobject> results = this.doGetResults();
        return results == null ? null : results[0];
    }

    protected List<Sobject> doGetResults() {
        if(this.cacheResults) return this.getCachedResults();
        else return Database.query(this.getQuery());
    }

    protected List<String> doGetFieldsToQuery(Soql.QueryField queryField, Soql.FieldCategory fieldCat) {
        List<String> fieldsToReturn = new List<String>();

        if(fieldCat == null) return fieldsToReturn;
        else if(fieldCat == Soql.FieldCategory.ACCESSIBLE && !queryField.getDescribe().isAccessible()) return fieldsToReturn;
        else if(fieldCat == Soql.FieldCategory.UPDATEABLE && !queryField.getDescribe().isUpdateable()) return fieldsToReturn;
        else if(fieldCat == Soql.FieldCategory.STANDARD && queryField.getDescribe().isCustom()) return fieldsToReturn;
        else if(fieldCat == Soql.FieldCategory.CUSTOM && !queryField.getDescribe().isCustom()) return fieldsToReturn;

        fieldsToReturn.add(queryField.toString());

        return fieldsToReturn;
    }

    protected String doGetQueryFieldString() {
        Set<String> distinctFieldApiNamesToQuery = new Set<String>();
        for(Soql.QueryField queryField : this.includedQueryFieldsAndCategory.keySet()) {
            Soql.FieldCategory fieldCategory = this.includedQueryFieldsAndCategory.get(queryField);

            List<String> fieldsToQuery = this.doGetFieldsToQuery(queryField, fieldCategory);
            if(!fieldsToQuery.isEmpty()) distinctFieldApiNamesToQuery.addAll(fieldsToQuery);
        }


        // Remove an excluded field paths
        for(Soql.QueryField excludedQueryField : this.excludedQueryFields) {
            distinctFieldApiNamesToQuery.remove(excludedQueryField.toString());
        }

        List<String> fieldApiNamesToQuery = new List<String>(distinctFieldApiNamesToQuery);
        if(this.sortQueryFields) fieldApiNamesToQuery.sort();
        return String.join(fieldApiNamesToQuery, ', ');
    }

    protected String doGetUsingScopeString() {
        return this.scope == null ? '' : ' USING SCOPE ' + this.scope.name();
    }

    protected String doGetWhereClauseString() {
        return this.whereFilters.isEmpty() ? '' : ' WHERE ' + String.join(this.whereFilters, ' AND ');
    }

    protected String doGetOrderByString() {
        return this.orderByFieldApiNames.isEmpty() ? '' : ' ORDER BY ' + String.join(this.orderByFieldApiNames, ', ');
    }

    protected String doGetLimitCountString() {
        return this.limitCount == null ? '' : ' LIMIT ' + this.limitCount;
    }

    protected String doGetOffetString() {
        return this.offset == null ? '' : ' OFFSET ' + this.offset;
    }

    private void doSetHasChanged() {
        this.hasChanged = true;
    }

    private List<Sobject> getCachedResults() {
        String query     = this.getQuery();
        Integer hashCode = query.hashCode();

        Boolean isCached = cachedResultsByHashCode.containsKey(hashCode);
        if(!isCached) cachedResultsByHashCode.put(hashCode, Database.query(query));

        // Always return a deep clone so the original cached version is never modified
        return cachedResultsByHashCode.get(hashCode).deepClone(true, true, true);
    }

    public class DateLiteral {

        private String dateLiteral;

        public DateLiteral(String dateLiteral) {
            this.dateLiteral = String.escapeSingleQuotes(dateLiteral);
        }

        public override String toString() {
            return this.dateLiteral;
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

    public class QueryField {

        private final String queryFieldPath;
        private final Schema.DescribeFieldResult fieldDescribe;

        public QueryField(Schema.SobjectType sobjectType, String queryFieldPath) {
            this.fieldDescribe  = this.getLastFieldDescribe(sobjectType, queryFieldPath);
            this.queryFieldPath = queryFieldPath;
        }

        public QueryField(Schema.SobjectField field) {
            this(new List<Schema.SobjectField>{field});
        }

        public QueryField(List<Schema.SobjectField> fieldChain) {
            this.fieldDescribe  = this.getLastFieldDescribe(fieldChain);
            this.queryFieldPath = this.getQueryField(fieldChain);
        }

        public override String toString() {
            return this.queryFieldPath;
        }

        public Schema.DescribeFieldResult getDescribe() {
            return this.fieldDescribe;
        }

        public String getFieldPath() {
            return this.queryFieldPath;
        }

        private Schema.DescribeFieldResult getLastFieldDescribe(Schema.SobjectType sobjectType, String queryField) {
            Schema.SobjectType currentSobjectType = sobjectType;

            List<Schema.SobjectField> fields = new List<Schema.SobjectField>();
            List<String> queryFieldPieces = queryField.split('\\.');
            Integer lastFieldIndex = queryFieldPieces.size() <= 1 ? 0 : queryFieldPieces.size() - 1;

            for(Integer i = 0; i < queryFieldPieces.size(); i++) {
                String queryFieldPiece = queryFieldPieces[i];

                String fieldApiName;
                if(i == lastFieldIndex) fieldApiName = queryFieldPiece;
                else if(queryFieldPiece.endsWith('__r')) fieldApiName = queryFieldPiece.replace('__r', '__c');
                else fieldApiName = queryFieldPiece + 'Id';

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

        private String getQueryField(List<Schema.SobjectField> fields) {
            Integer lastFieldIndex = fields.size() - 1;
            List<String> queryFieldPieces = new List<String>();
            for(Integer i = 0; i < fields.size(); i++) {
                SobjectField field = fields[i];
                // If any field in the chain is not accessible, then the user cant access the data, so return an empty list
                if(!field.getDescribe().isAccessible()) return null;
                else if(i == lastFieldIndex) queryFieldPieces.add(field.getDescribe().getName());
                else queryFieldPieces.add(field.getDescribe().getRelationshipName());
            }
            return String.join(queryFieldPieces, '.');
        }

    }

    public class QueryFilter implements Comparable {

        private String value;

        public QueryFilter(Schema.SobjectField field, String operator, Object value) {
            this(new QueryField(field), operator, value);
        }

        public QueryFilter(QueryField queryField, String operator, Object value) {
            this.value = queryField + ' ' + operator + ' ' + new QueryArgument(value);
        }

        public Integer compareTo(Object compareTo) {
            QueryFilter compareToQueryFilter = (QueryFilter)compareTo;
            if(this.toString() == compareToQueryFilter.toString()) return 0;
            else if(this.toString() > compareToQueryFilter.toString()) return 1;
            else return -1;
        }

        public override String toString() {
            return this.value;
        }

    }

    public class SoqlException extends Exception {}

    private class QueryArgument {

        private String value;

        public QueryArgument(Object valueToFormat) {
            this.value = this.formatObjectForQueryString(valueToFormat);
        }

        public override String toString() {
            return this.value;
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
            else if(valueToFormat instanceOf Sobject) {
                Sobject record = (Sobject)valueToFormat;
                return this.wrapInSingleQuotes(((Sobject)valueToFormat).Id);
            }
            else if(valueToFormat instanceOf String) {
                // Escape single quotes to prevent SOQL/SOSL injection
                String unformattedString = (String)valueToFormat;
                String stringArgument = String.escapeSingleQuotes(unformattedString.trim());
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

    }

}