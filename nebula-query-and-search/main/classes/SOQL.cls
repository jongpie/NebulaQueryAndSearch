/*******************************************************************************************************
 * This file is part of the Nebula Query & Search project, released under the MIT License.             *
 * See LICENSE file or go to https://github.com/jongpie/NebulaQueryAndSearch for full license details. *
 ******************************************************************************************************/

/**
 * @group SOQL Queries
 * @description Handles common functionality needed for writing SOQL queries
 * @see Query
 * @see AggregateQuery
 */
@SuppressWarnings(
  'PMD.ApexDoc, PMD.ApexSharingViolations, PMD.AvoidGlobalModifier, PMD.CyclomaticComplexity, PMD.EagerlyLoadedDescribeSObjectResult, PMD.ExcessivePublicCount, PMD.FieldDeclarationsShouldBeAtStart'
)
global abstract class SOQL implements Comparable {
  global enum Aggregate {
    AVG,
    COUNT,
    COUNT_DISTINCT,
    MAX,
    MIN,
    SUM
  }

  global enum GroupingDimension {
    CUBE,
    ROLLUP
  }

  global enum FieldCategory {
    ACCESSIBLE,
    UPDATEABLE,
    STANDARD,
    CUSTOM,
    IGNORE_FLS
  }

  global enum Operator {
    EQUALS,
    NOT_EQUAL_TO,
    GREATER_THAN,
    GREATER_THAN_OR_EQUAL_TO,
    LESS_THAN,
    LESS_THAN_OR_EQUAL_TO,
    IS_IN,
    IS_NOT_IN,
    INCLUDES,
    EXCLUDES,
    IS_LIKE,
    IS_NOT_LIKE
  }

  global enum Scope {
    EVERYTHING,
    DELEGATED,
    TEAM,
    MINE,
    MY_TERRITORY,
    MY_TEAM_TERRITORY
  }

  global enum SortOrder {
    ASCENDING,
    DESCENDING
  }

  global enum DateFunction {
    HOUR_IN_DAY,
    DAY_ONLY,
    DAY_IN_MONTH,
    DAY_IN_WEEK,
    DAY_IN_YEAR,
    WEEK_IN_MONTH,
    WEEK_IN_YEAR,
    FISCAL_MONTH,
    FISCAL_QUARTER,
    FISCAL_YEAR,
    CALENDAR_MONTH,
    CALENDAR_QUARTER,
    CALENDAR_YEAR
  }

  global enum FixedDateLiteral {
    YESTERDAY,
    TODAY,
    TOMORROW,
    LAST_WEEK,
    THIS_WEEK,
    NEXT_WEEK,
    LAST_MONTH,
    THIS_MONTH,
    NEXT_MONTH,
    LAST_90_DAYS,
    NEXT_90_DAYS,
    LAST_QUARTER,
    THIS_QUARTER,
    NEXT_QUARTER,
    LAST_FISCAL_QUARTER,
    THIS_FISCAL_QUARTER,
    NEXT_FISCAL_QUARTER,
    LAST_YEAR,
    THIS_YEAR,
    NEXT_YEAR,
    LAST_FISCAL_YEAR,
    THIS_FISCAL_YEAR,
    NEXT_FISCAL_YEAR
  }

  global enum RelativeDateLiteral {
    N_DAYS_AGO,
    LAST_N_DAYS,
    NEXT_N_DAYS,
    LAST_N_WEEKS,
    NEXT_N_WEEKS,
    LAST_N_MONTHS,
    NEXT_N_MONTHS,
    LAST_N_QUARTERS,
    NEXT_N_QUARTERS,
    LAST_N_FISCAL_QUARTERS,
    NEXT_N_FISCAL_QUARTERS,
    LAST_N_YEARS,
    NEXT_N_YEARS,
    LAST_N_FISCAL_YEARS,
    NEXT_N_FISCAL_YEARS
  }

  private static final SOQL.FieldCategory DEFAULT_FIELD_CATEGORY = SOQL.FieldCategory.ACCESSIBLE;
  private static final SOQL.SortOrder DEFAULT_SORT_ORDER = SOQL.SortOrder.ASCENDING;
  private static final Boolean DEFAULT_NULLS_SORT_ORDER_FIRST = true;

  private static Map<Integer, List<SObject>> cachedResultsByHashCode = new Map<Integer, List<SObject>>();

  public static String getOperatorValue(SOQL.Operator operator) {
    switch on operator {
      when EQUALS {
        return '=';
      }
      when NOT_EQUAL_TO {
        return '!=';
      }
      when GREATER_THAN {
        return '>';
      }
      when GREATER_THAN_OR_EQUAL_TO {
        return '>=';
      }
      when LESS_THAN {
        return '<';
      }
      when LESS_THAN_OR_EQUAL_TO {
        return '<=';
      }
      when IS_IN {
        return 'IN';
      }
      when IS_NOT_IN {
        return 'NOT IN';
      }
      when INCLUDES {
        return 'INCLUDES';
      }
      when EXCLUDES {
        return 'EXCLUDES';
      }
      when IS_LIKE {
        return 'LIKE';
      }
      when IS_NOT_LIKE {
        return 'NOT LIKE';
      }
      when else {
        return null;
      }
    }
  }

  protected String query;
  protected Schema.SObjectType sobjectType;
  protected Schema.DescribeSObjectResult sobjectDescribe;
  protected Map<SOQL.QueryField, SOQL.FieldCategory> includedQueryFieldsAndCategory;
  protected Set<SOQL.QueryField> excludedQueryFields;
  protected Scope scope;
  protected List<QueryFilter> whereClauseFilters;
  protected String whereClauseFilterLogic;
  protected System.AccessLevel accessLevel;
  protected List<String> orderByFieldApiNames;
  protected Integer limitCount;
  protected Integer offset;
  protected Boolean hasChanged;
  protected Boolean sortQueryFields;
  protected Map<String, Object> bindsMap;
  protected Boolean cacheResults;
  private Boolean generateBindVariableKeys;
  private Integer generatedBindVariableKeyCounter;

  protected SOQL(Schema.SObjectType sobjectType, Boolean sortQueryFields) {
    this.sobjectType = sobjectType;
    this.sortQueryFields = sortQueryFields;

    this.sobjectDescribe = this.sobjectType.getDescribe(Schema.SObjectDescribeOptions.DEFERRED);
    this.includedQueryFieldsAndCategory = new Map<SOQL.QueryField, SOQL.FieldCategory>();
    this.excludedQueryFields = new Set<SOQL.QueryField>();
    this.whereClauseFilters = new List<QueryFilter>();
    this.whereClauseFilterLogic = '';
    this.orderByFieldApiNames = new List<String>();
    this.accessLevel = System.AccessLevel.SYSTEM_MODE;
    this.bindsMap = new Map<String, Object>();
    this.cacheResults = false;
    this.hasChanged = false;
    this.generateBindVariableKeys = false;
    this.generatedBindVariableKeyCounter = 0;
  }

  global Schema.SObjectType getSObjectType() {
    return this.sobjectType;
  }

  // TODO decide if this should be global
  global abstract String getQuery();

  public Integer compareTo(Object compareTo) {
    String currentSObjectApiName = String.valueOf(this.getSObjectType());
    SOQL soqlToCompareTo = (SOQL) compareTo;
    String compareToSObjectApiName = String.valueOf(soqlToCompareTo.getSObjectType());

    if (currentSObjectApiName == compareToSObjectApiName) {
      return 0;
    } else if (currentSObjectApiName > compareToSObjectApiName) {
      return 1;
    } else {
      return -1;
    }
  }

  protected void doCacheResults() {
    this.cacheResults = true;
  }

  protected void doAddFields(List<SOQL.QueryField> queryFields, SOQL.FieldCategory fieldCategory) {
    if (fieldCategory == null) {
      fieldCategory = DEFAULT_FIELD_CATEGORY;
    }
    for (SOQL.QueryField queryField : queryFields) {
      this.includedQueryFieldsAndCategory.put(queryField, fieldCategory);
    }
    this.doSetHasChanged();
  }

  protected void doRemoveFields(List<SOQL.QueryField> queryFields) {
    this.excludedQueryFields.addAll(queryFields);
  }

  protected void doUsingScope(Scope scope) {
    this.scope = scope;
  }

  protected void doFilterWhere(List<SOQL.QueryFilter> filters) {
    if (filters?.isEmpty() != false) {
      return;
    }

    for (SOQL.QueryFilter filter : filters) {
      this.whereClauseFilters.add(filter);
      this.whereClauseFilterLogic += (this.whereClauseFilters.size() == 1 ? '1' : ' AND ' + this.whereClauseFilters.size());
    }
    this.doSetHasChanged();
  }

  protected void doOrFilterWhere(List<SOQL.QueryFilter> filters) {
    if (filters?.isEmpty() != false) {
      return;
    }

    filters.sort();

    this.whereClauseFilterLogic += (this.whereClauseFilters.isEmpty() ? '' : ' AND ') + '(';
    for (Integer i = 0; i < filters.size(); i++) {
        SOQL.QueryFilter filter = filters[i];
        this.whereClauseFilters.add(filter);
        this.whereClauseFilterLogic += (i == 0 ? '' : ' OR ') + this.whereClauseFilters.size();
    }
    this.whereClauseFilterLogic += ')';
    this.doSetHasChanged();
  }

  protected void doWithAccessLevel(System.AccessLevel accessLevel) {
    this.accessLevel = accessLevel;
  }

  protected void doOrderBy(SOQL.QueryField queryField, SOQL.SortOrder sortOrder, Boolean sortNullsFirst) {
    this.doOrderBy(queryField.toString(), sortOrder, sortNullsFirst);
  }

  protected void doOrderBy(String fieldPath, SOQL.SortOrder sortOrder, Boolean sortNullsFirst) {
    if (sortOrder == null) {
      sortOrder = DEFAULT_SORT_ORDER;
    }
    if (sortNullsFirst == null) {
      sortNullsFirst = DEFAULT_NULLS_SORT_ORDER_FIRST;
    }

    String sortOrderString = sortOrder == SOQL.SortOrder.ASCENDING ? 'ASC' : 'DESC';
    String nullsSortOrder = sortNullsFirst ? 'FIRST' : 'LAST';
    this.orderByFieldApiNames.add(fieldPath + ' ' + sortOrderString + ' NULLS ' + nullsSortOrder);
  }

  protected void doLimitTo(Integer numberOfRecords) {
    this.limitCount = numberOfRecords;
  }

  protected void doOffsetBy(Integer offset) {
    this.offset = offset;
  }

  protected void doSetBind(String key, Object value) {
    this.bindsMap.put(key, value);
  }

  protected void doSetBinds(Map<String, Object> binds) {
    this.bindsMap.putAll(binds);
  }

  protected void doRemoveBind(String key) {
    this.bindsMap.remove(key);
    for (QueryFilter filter : this.whereClauseFilters)
    {
      if (filter.bindKey == key)
      {
        filter.bindKey = null;
      }
    }
  }

  protected void doClearBinds() {
    this.bindsMap.clear();
    for (QueryFilter filter : this.whereClauseFilters)
    {
      filter.bindKey = null;
    }
  }

  protected void doGenerateBindVariableKeys() {
    this.generateBindVariableKeys = true;
  }

  protected String generateNextBindVariableKey() {
    return this.generateBindVariableKeys != true ? null : 'bindVar' + this.generatedBindVariableKeyCounter++;
  }

  protected SObject doGetFirstResult() {
    List<SObject> results = this.doGetResults();
    return results == null || results.isEmpty() ? null : results[0];
  }

  protected List<SObject> doGetResults() {
    if (this.cacheResults) {
      return this.getCachedResults();
    } else {
      return Database.queryWithBinds(
        this.getQuery(),
        this.doGetBindsMap(),
        this.doGetAccessLevel()
      );
    }
  }

  protected List<String> doGetFieldsToQuery(SOQL.QueryField queryField, SOQL.FieldCategory fieldCat) {
    List<String> fieldsToReturn = new List<String>();

    if (fieldCat == null) {
      return fieldsToReturn;
    } else if (fieldCat == SOQL.FieldCategory.ACCESSIBLE && !queryField.getDescribe().isAccessible()) {
      return fieldsToReturn;
    } else if (fieldCat == SOQL.FieldCategory.UPDATEABLE && !queryField.getDescribe().isUpdateable()) {
      return fieldsToReturn;
    } else if (fieldCat == SOQL.FieldCategory.STANDARD && queryField.getDescribe().isCustom()) {
      return fieldsToReturn;
    } else if (fieldCat == SOQL.FieldCategory.CUSTOM && !queryField.getDescribe().isCustom()) {
      return fieldsToReturn;
    }

    fieldsToReturn.add(queryField.toString());

    return fieldsToReturn;
  }

  protected String doGetQueryFieldString() {
    Set<String> distinctFieldApiNamesToQuery = new Set<String>();
    for (SOQL.QueryField queryField : this.includedQueryFieldsAndCategory.keySet()) {
      SOQL.FieldCategory fieldCategory = this.includedQueryFieldsAndCategory.get(queryField);

      List<String> fieldsToQuery = this.doGetFieldsToQuery(queryField, fieldCategory);
      if (!fieldsToQuery.isEmpty()) {
        distinctFieldApiNamesToQuery.addAll(fieldsToQuery);
      }
    }

    // Remove an excluded field paths
    for (SOQL.QueryField excludedQueryField : this.excludedQueryFields) {
      distinctFieldApiNamesToQuery.remove(excludedQueryField.toString());
    }

    List<String> fieldApiNamesToQuery = new List<String>(distinctFieldApiNamesToQuery);
    if (this.sortQueryFields) {
      fieldApiNamesToQuery.sort();
    }
    return String.join(fieldApiNamesToQuery, ', ');
  }

  protected String doGetUsingScopeString() {
    return this.scope == null ? '' : ' USING SCOPE ' + this.scope.name();
  }

  protected String doGetFilterableClauseString(String clause, LIST<SOQL.QueryFilter> filters, String filterLogic) {
    List<String> filterStrings = new List<String>();
    for (Soql.QueryFilter filter : filters)
    {
        filter.setBindKey(filter.getBindKey() ?? this.generateNextBindVariableKey());
        if (String.isNotBlank(filter.getBindKey())) {
          this.bindsMap.put(filter.getBindKey(), filter.getValue());
        }
        filterStrings.add(filter.toString());
    }
    if (String.isBlank(filterLogic))
    {
        return '';
    }

    List<String> filterLogicParts = filterLogic.split('\\s+');
    List<String> filterLogicPartsReplaced = new List<String>();
    for (String filterLogicPart : filterLogicParts)
    {
        Matcher m = Pattern.compile('\\d+').matcher(filterLogicPart);
        Boolean indexFound = m.find();
        if (indexFound)
        {
            Integer filterLogicIndex = Integer.valueOf(m.group());
            try
            {
                filterLogicPartsReplaced.add(
                    filterLogicPart.replace(
                        m.group(),
                        filterStrings[filterLogicIndex - 1]
                    )
                );
            }
            catch (ListException e)
            {
                throw new QueryException('No query ' + clause + ' filter defined for index "' + filterLogicIndex + '" specified in filter conditions "' + filterLogic + '"');
            }
        }
        else
        {
            filterLogicPartsReplaced.add(filterLogicPart);
        }
    }
    return ' ' + clause + ' ' + String.join(filterLogicPartsReplaced, ' ');
  }

  protected String doGetWhereClauseString() {
    return this.doGetFilterableClauseString('WHERE', this.whereClauseFilters, this.whereClauseFilterLogic);
  }

  protected System.AccessLevel doGetAccessLevel() {
    return this.accessLevel ?? System.AccessLevel.SYSTEM_MODE;
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

  protected Map<String, Object> doGetBindsMap() {
    return this.bindsMap ?? new Map<String, Object>();
  }

  private void doSetHasChanged() {
    this.hasChanged = true;
  }

  private List<SObject> getCachedResults() {
    String query = this.getQuery();
    Integer hashCode = query.hashCode();

    Boolean isCached = cachedResultsByHashCode.containsKey(hashCode);
    if (!isCached) {
      cachedResultsByHashCode.put(
        hashCode,
        Database.queryWithBinds(
          this.getQuery(),
          this.doGetBindsMap(),
          this.doGetAccessLevel()
        )
      );
    }

    // Always return a deep clone so the original cached version is never modified
    return cachedResultsByHashCode.get(hashCode).deepClone(true, true, true);
  }

  public class DateLiteral {
    private String dateLiteral;

    public DateLiteral(SOQL.FixedDateLiteral fixedDateLiteral) {
      this.dateLiteral = fixedDateLiteral.name();
    }

    public DateLiteral(SOQL.RelativeDateLiteral relativeDateLiteral, Integer n) {
      this.dateLiteral = relativeDateLiteral.name() + ':' + n;
    }

    public override String toString() {
      return this.dateLiteral;
    }
  }

  public class IsoCurrency {
    private final String isoCurrency;

    public IsoCurrency(String isoCode, Decimal currencyAmount) {
      if (!System.UserInfo.isMultiCurrencyOrganization()) {
        throw new SOQLException('IsoCurrency is only supported in multi-currency orgs');
      }
      this.isoCurrency = isoCode + currencyAmount;
    }

    public override String toString() {
      return this.isoCurrency;
    }
  }

  global class QueryField {
    private final String queryFieldPath;
    private final Schema.DescribeFieldResult fieldDescribe;

    global QueryField(Schema.SObjectType sobjectType, String queryFieldPath) {
      this.fieldDescribe = this.getLastFieldDescribe(sobjectType, queryFieldPath);
      this.queryFieldPath = queryFieldPath;
    }

    global QueryField(Schema.SObjectField field) {
      this(new List<Schema.SObjectField>{ field });
    }

    global QueryField(List<Schema.SObjectField> fieldChain) {
      this.fieldDescribe = this.getLastFieldDescribe(fieldChain);
      this.queryFieldPath = this.getQueryField(fieldChain);
    }

    global QueryField(SOQL.DateFunction dateFunction, Schema.SObjectField field) {
      this(dateFunction, field, false);
    }

    global QueryField(SOQL.DateFunction dateFunction, Schema.SObjectField field, Boolean convertTimeZone) {
      this(dateFunction, new List<Schema.SObjectField>{ field }, convertTimeZone);
    }

    global QueryField(SOQL.DateFunction dateFunction, List<Schema.SObjectField> fieldChain) {
      this(dateFunction, fieldChain, false);
    }

    global QueryField(SOQL.DateFunction dateFunction, List<Schema.SObjectField> fieldChain, Boolean convertTimeZone) {
      this.fieldDescribe = this.getLastFieldDescribe(fieldChain);
      this.queryFieldPath = this.getDateFunctionFieldPath(dateFunction, fieldChain, convertTimeZone);
    }
    //https://help.salesforce.com/articleView?id=custom_field_geolocate_overview.htm&type=5
    global QueryField(List<Schema.SObjectField> fieldChain, Decimal latitude, Decimal longitude) {
      this.fieldDescribe = this.getLastFieldDescribe(fieldChain);
      //this.queryFieldPath = 'DISTANCE(' + this.getQueryField(fieldChain), GEOLOCATION(10,10), :units)
    }

    // TODO decide if this should be global
    public override String toString() {
      return this.queryFieldPath;
    }

    // TODO decide if this should be global
    public Schema.DescribeFieldResult getDescribe() {
      return this.fieldDescribe;
    }

    // TODO decide if this should be global
    public String getFieldPath() {
      return this.queryFieldPath;
    }

    private String getDateFunctionFieldPath(SOQL.DateFunction dateFunction, List<Schema.SObjectField> fieldChain, Boolean convertTimeZone) {
      String fieldPath = !convertTimeZone ? this.getQueryField(fieldChain) : 'convertTimeZone(' + this.getQueryField(fieldChain) + ')';

      return dateFunction.name() + '(' + fieldPath + ')';
    }

    private Schema.DescribeFieldResult getLastFieldDescribe(Schema.SObjectType sobjectType, String queryField) {
      Schema.SObjectType currentSObjectType = sobjectType;

      List<Schema.SObjectField> fields = new List<Schema.SObjectField>();
      List<String> queryFieldPieces = queryField.split('\\.');
      Integer lastFieldIndex = queryFieldPieces.size() <= 1 ? 0 : queryFieldPieces.size() - 1;

      for (Integer i = 0; i < queryFieldPieces.size(); i++) {
        String queryFieldPiece = queryFieldPieces[i];

        String fieldApiName;
        if (i == lastFieldIndex) {
          fieldApiName = queryFieldPiece;
        } else if (queryFieldPiece.endsWith('__r')) {
          fieldApiName = queryFieldPiece.replace('__r', '__c');
        } else {
          fieldApiName = queryFieldPiece + 'Id';
        }

        Schema.SObjectField field = currentSObjectType.getDescribe(Schema.SObjectDescribeOptions.DEFERRED).fields.getMap().get(fieldApiName);

        if (i < lastFieldIndex) {
          // TODO add support for polymorphic fields
          currentSObjectType = field.getDescribe().getReferenceTo()[0];
        }

        fields.add(field);
      }
      return this.getLastFieldDescribe(fields);
    }

    private Schema.DescribeFieldResult getLastFieldDescribe(List<Schema.SObjectField> fields) {
      Integer lastFieldIndex = fields.size() - 1;
      return fields[lastFieldIndex].getDescribe();
    }

    private String getQueryField(List<Schema.SObjectField> fields) {
      Integer lastFieldIndex = fields.size() - 1;
      List<String> queryFieldPieces = new List<String>();
      for (Integer i = 0; i < fields.size(); i++) {
        Schema.SObjectField field = fields[i];
        // If any field in the chain is not accessible, then the user cant access the data, so return an empty list
        if (!field.getDescribe().isAccessible()) {
          return null;
        } else if (i == lastFieldIndex) {
          queryFieldPieces.add(field.getDescribe().getName());
        } else {
          queryFieldPieces.add(field.getDescribe().getRelationshipName());
        }
      }
      return String.join(queryFieldPieces, '.');
    }
  }

  global virtual class QueryFilter implements Comparable {
    protected SOQL.QueryField queryField;
    protected SOQL.Operator operator;
    protected Object value;
    protected String bindKey;
    protected Schema.SObjectType childSObjectType;
    protected Query childQuery;
    protected Boolean inOrNotIn;
    protected Schema.SObjectField lookupFieldOnChildSObject;

    global QueryFilter(Schema.SObjectField field, SOQL.Operator operator, Object value) {
      this(new QueryField(field), operator, value);
    }

    global QueryFilter(Schema.SObjectField field, SOQL.Operator operator, Object value, String bindKey) {
      this(new QueryField(field), operator, value, bindKey);
    }

    global QueryFilter(QueryField queryField, SOQL.Operator operator, Object value) {
      this(queryField, operator, value, null);
    }

    global QueryFilter(QueryField queryField, SOQL.Operator operator, Object value, String bindKey) {
      this.queryField = queryField;
      this.operator = operator;
      this.value = value;
      this.bindKey = bindKey;
    }

    global QueryFilter(Schema.SObjectType childSObjectType, Boolean inOrNotIn, Schema.SObjectField lookupFieldOnChildSObject) {
      this.operator = inOrNotIn ? SOQL.Operator.IS_IN : SOQL.Operator.IS_NOT_IN;
      this.childSObjectType = childSObjectType;
      this.inOrNotIn = inOrNotIn;
      this.lookupFieldOnChildSObject = lookupFieldOnChildSObject;
    }

    global QueryFilter(Query childQuery, Boolean inOrNotIn, Schema.SObjectField lookupFieldOnChildSObject) {
      this.operator = inOrNotIn ? SOQL.Operator.IS_IN : SOQL.Operator.IS_NOT_IN;
      this.childQuery = childQuery;
      this.inOrNotIn = inOrNotIn;
      this.lookupFieldOnChildSObject = lookupFieldOnChildSObject;
    }

    global Integer compareTo(Object compareTo) {
      QueryFilter compareToQueryFilter = (QueryFilter) compareTo;

      if (this.toString() == compareToQueryFilter.toString()) {
        return 0;
      } else if (this.toString() > compareToQueryFilter.toString()) {
        return 1;
      } else {
        return -1;
      }
    }

    global SOQL.QueryField getQueryField() {
      return this.queryField;
    }

    global SOQL.Operator getOperator() {
      return this.operator;
    }

    global Object getValue() {
      return this.value;
    }

    global String getBindKey() {
      return this.bindKey;
    }

    global void setBindKey(String bindKey) {
      if (this.queryField != null)
      {
        this.bindKey = bindKey;
      }
    }

    // TODO decide if this should be global
    public Object getFormattedValue() {
      return (String.isNotBlank(this.bindKey) ? ':' + this.bindKey : new QueryArgument(this.value).toString());
    }

    // TODO decide if this should be global
    public virtual override String toString() {
      return (
        this.queryField != null ?
        this.queryField + ' ' + SOQL.getOperatorValue(this.operator) + ' ' + this.getFormattedValue() :
        (
            this.childSObjectType != null ?
            'Id ' + SOQL.getOperatorValue(this.operator) + ' (SELECT ' + this.lookupFieldOnChildSObject + ' FROM ' + this.childSObjectType + ')' :
            'Id ' + SOQL.getOperatorValue(this.operator) + ' ' + this.childQuery.getSubquery(this.lookupFieldOnChildSObject)
        )
      );
    }
  }

  // TODO decide if this should be global (or deleted)
  public class SOQLException extends Exception {
  }

  public class QueryArgument {
    private String value;

    public QueryArgument(Object valueToFormat) {
      this.value = this.formatObjectForQueryString(valueToFormat);
    }

    public override String toString() {
      return this.value;
    }

    private String formatObjectForQueryString(Object valueToFormat) {
      if (valueToFormat == null) {
        return null;
      } else if (valueToFormat instanceof Iterable<Object>) {
        return this.convertIterableToQueryString((Iterable<Object>) valueToFormat);
      } else if (valueToFormat instanceof Map<Object, Object>) {
        return this.convertMapToQueryString(valueToFormat);
      } else if (valueToFormat instanceof Date) {
        return String.valueOf((Date) valueToFormat).left(10);
      } else if (valueToFormat instanceof Datetime) {
        Datetime datetimeValue = (Datetime) valueToFormat;
        return datetimeValue.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'', 'Greenwich Mean Time');
      } else if (valueToFormat instanceof SObject) {
        return this.wrapInSingleQuotes(((SObject) valueToFormat).Id);
      } else if (valueToFormat instanceof String) {
        // Escape single quotes to prevent SOQL/SOSL injection
        String unformattedString = (String) valueToFormat;
        String stringArgument = String.escapeSingleQuotes(unformattedString.trim());
        return this.wrapInSingleQuotes(stringArgument);
      } else {
        return String.valueOf(valueToFormat);
      }
    }

    private String wrapInSingleQuotes(String input) {
      input = input.trim();
      if (input.left(1) != '\'') {
        input = '\'' + input;
      }
      if (input.right(1) != '\'') {
        input = input + '\'';
      }
      return input;
    }

    private String convertIterableToQueryString(Iterable<Object> valueIterable) {
      List<String> parsedValueList = new List<String>();
      Iterator<Object> valueIterator = valueIterable.iterator();
      while (valueIterator.hasNext()) {
        Object value = valueIterator.next();
        parsedValueList.add(this.formatObjectForQueryString(value));
      }
      return '(' + String.join(parsedValueList, ', ') + ')';
    }

    private String convertMapToQueryString(Object valueMap) {
      Map<String, Object> untypedMap = (Map<String, Object>) Json.deserializeUntyped(Json.serialize(valueMap));
      return this.convertIterableToQueryString(untypedMap.keySet());
    }
  }
}
