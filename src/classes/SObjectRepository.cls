public abstract class SObjectRepository implements ISObjectRepository {

    public enum SortOrder { ASCENDING, DESCENDING }
    public enum NullsSortOrder { FIRST, LAST }

    public enum SearchGroup { ALL_FIELDS, NAME_FIELDS, EMAIL_FIELDS, PHONE_FIELDS, SIDEBAR_FIELDS }

    private SObjectType sobjectType;
    private Map<String, Schema.SObjectField> sobjectTypeFieldMap;
    private Set<String> queryFields;
    private String query;
    private Boolean addCommonQueryFields;
    private Schema.FieldSet fieldSet;
    private List<String> whereClauseList;
    private List<String> orderByList;
    private Integer limitCount;
    private Boolean forUpdate;

    protected SObjectRepository(Schema.FieldSet fieldSet) {
        this(fieldSet, true);
    }

    protected SObjectRepository(Schema.FieldSet fieldSet, Boolean addCommonQueryFields) {
        this.fieldSet             = fieldSet;
        this.addCommonQueryFields = addCommonQueryFields;

        this.sobjectType         = fieldSet.getSObjectType();
        this.sobjectTypeFieldMap = this.sobjectType.getDescribe().fields.getMap();
        this.queryFields         = new Set<String>();
        this.whereClauseList     = new List<String>();
        this.orderByList         = new List<String>();
        this.forUpdate           = false;

        this.addCommonQueryFields();
        this.addFieldSetMembers();
    }

    protected SObjectRepository addCondition(String condition) {
        this.whereClauseList.add(condition);
        return this;
    }

    protected SObjectRepository addConditionIdEquals(Id recordId) {
        return this.addCondition('Id = ' + StringUtils.wrapInSingleQuotes(recordId));
    }

    protected SObjectRepository addConditionIdIn(Set<Id> recordIdSet) {
        return this.addConditionIdIn(new List<Id>(recordIdSet));
    }

    protected SObjectRepository addConditionIdIn(List<Id> recordList) {
        return this.addCondition('Id IN ' + CollectionUtils.toString(recordList));
    }

    protected SObjectRepository orderBy(Schema.SObjectField orderByField) {
        return this.orderBy(orderByField, null, null);
    }

    protected SObjectRepository orderBy(Schema.SObjectField orderByField, SObjectRepository.SortOrder sortOrder) {
        return orderBy(orderByField, sortOrder, null);
    }

    protected SObjectRepository orderBy(Schema.SObjectField orderByField, SObjectRepository.SortOrder sortOrder, SObjectRepository.NullsSortOrder nullsSortOrder) {
        String sortOrderSoql = '';
        if(sortOrder == SObjectRepository.SortOrder.ASCENDING) sortOrderSoql = ' ASC';
        else if(sortOrder == SObjectRepository.SortOrder.DESCENDING) sortOrderSoql = ' DESC';

        if(nullsSortOrder != null) sortOrderSoql += ' NULLS ' + nullsSortOrder;

        this.orderByList.add(orderByField.getDescribe().getName() + sortOrderSoql);

        return this;
    }

    protected SObjectRepository limitCount(Integer limitCount) {
        this.limitCount = limitCount;
        return this;
    }

    protected SObjectRepository setAsForUpdate() {
        this.forUpdate = true;
        return this;
    }

    protected String getQuery() {
        this.query = 'SELECT ' + this.getQueryFieldString()
            + ' FROM ' + this.sobjectType
            + this.getWhereClauseString()
            + this.getOrderByString()
            + this.getLimitCountString()
            + this.getForUpdateString();

        System.debug(this.query);

        return this.query;
    }

    protected String getSearchQuery(String searchTerm) {
        return this.getSearchQuery(searchTerm, SObjectRepository.SearchGroup.ALL_FIELDS);
    }

    protected String getSearchQuery(String searchTerm, SObjectRepository.SearchGroup searchGroup) {
        this.query = 'FIND ' + StringUtils.wrapInSingleQuotes(searchTerm)
            + ' IN ' + searchGroup.name().replace('_', ' ')
            + ' RETURNING ' + this.sobjectType + '('
                + this.getQueryFieldString()
                + this.getWhereClauseString()
                + this.getOrderByString()
                + this.getLimitCountString()
            + ') ';

        if(this.forUpdate) System.debug(Logginglevel.WARN, 'Search Query flagged as FOR UPDATE. SOSL cannot use FOR UPDATE, ignoring');

        System.debug(this.query);

        return this.query;
    }

    private void addCommonQueryFields() {
        if(!this.addCommonQueryFields) return;

        // Auto-add the common fields that are available for the SObject Type
        List<String> commonFieldNameList = new List<String>{
            'Id', 'CaseNumber', 'CreatedById', 'CreatedDate',  'IsClosed', 'LastModifiedById', 'LastModifiedDate',
            'Name', 'OwnerId', 'Subject', 'RecordTypeId', 'SystemModStamp'
        };
        for(String commonFieldName : commonFieldNameList) {
            if(!this.sobjectTypeFieldMap.containsKey(commonFieldName)) continue;

            this.queryFields.add(commonFieldName);
        }
    }

    private void addFieldSetMembers() {
        if(this.fieldSet == null) return;

        for(Schema.FieldSetMember field : this.fieldSet.getFields()) this.queryFields.add(field.getFieldPath());
    }

    private String getQueryFieldString() {
        return String.join(new List<String>(this.queryFields), ',');
    }

    private String getWhereClauseString() {
        String whereClauseString = '';
        if(!this.whereClauseList.isEmpty()) whereClauseString = ' WHERE ' + String.join(this.whereClauseList, ' AND ');
        return whereClauseString;
    }

    private String getOrderByString() {
        String orderByString = '';
        if(!this.orderByList.isEmpty()) orderByString = ' ORDER BY ' + String.join(new List<String>(orderByList), ', ');
        return orderByString;
    }

    private String getLimitCountString() {
        String limitString = '';
        if(this.limitCount != null) limitString = ' LIMIT '+ this.limitCount;
        return limitString;
    }

    private String getForUpdateString() {
        String forUpdateString = '';
        if(this.orderByList.isEmpty() && this.forUpdate) forUpdateString = ' FOR UPDATE';
        return forUpdateString;
    }

}