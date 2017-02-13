public abstract class SObjectRepository implements ISObjectRepository {

    public enum SortOrder { ASCENDING, DESCENDING }
    public enum NullsSortOrder { FIRST, LAST }

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
        this.whereClauseList     = new List<String>();
        this.orderByList         = new List<String>();
        this.forUpdate           = false;

        this.addCommonQueryFields();
        this.addFieldSetMembers();
    }

    public ISObjectRepository addCondition(String condition) {
        this.whereClauseList.add(condition);
        return this;
    }

    public ISObjectRepository addConditionIdEquals(Id recordId) {
        return this.addCondition('Id = ' + StringUtils.wrapInSingleQuotes(recordId));
    }

    public ISObjectRepository addConditionIdIn(Set<Id> recordIdSet) {
        return this.addConditionIdIn(new List<Id>(recordIdSet));
    }

    public ISObjectRepository addConditionIdIn(List<Id> recordList) {
        return this.addCondition('Id IN ' + CollectionUtils.toString(recordList));
    }

    public ISObjectRepository orderBy(Schema.SObjectField orderByField) {
        return this.orderBy(orderByField, null, null);
    }

    public ISObjectRepository orderBy(Schema.SObjectField orderByField, SObjectRepository.SortOrder sortOrder) {
        return orderBy(orderByField, sortOrder, null);
    }

    public ISObjectRepository orderBy(Schema.SObjectField orderByField, SObjectRepository.SortOrder sortOrder, SObjectRepository.NullsSortOrder nullsSortOrder) {
        String sortOrderSoql = '';
        if(sortOrder == SObjectRepository.SortOrder.ASCENDING) sortOrderSoql = ' ASC';
        else if(sortOrder == SObjectRepository.SortOrder.DESCENDING) sortOrderSoql = ' DESC';

        if(nullsSortOrder != null) sortOrderSoql += ' NULLS ' + nullsSortOrder;

        this.orderByList.add(orderByField.getDescribe().getName() + sortOrderSoql);

        return this;
    }

    public ISObjectRepository limitCount(Integer limitCount) {
        this.limitCount = limitCount;
        return this;
    }

    public ISObjectRepository setAsUpdate(Boolean bool) {
        this.forUpdate = bool;
        return this;
    }

    private void addCommonQueryFields() {
        if(!this.addCommonQueryFields) return;

        this.queryFields = new Set<String>();
        // Auto-add the common fields that are available for the SObject Type
        List<String> commonFieldNameList = new List<String>{
            'Id', 'CaseNumber', 'CreatedById', 'CreatedDate', 'LastModifiedById', 'LastModifiedDate',
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

    public String buildQuery() {
        this.query = 'SELECT ' + String.join(new List<String>(this.queryFields), ', ')
            + ' FROM ' + this.sobjectType;

        // Generate the WHERE clause
        if(!this.whereClauseList.isEmpty()) this.query += ' WHERE ' + String.join(this.whereClauseList, ' AND ');

        // Generate the ORDER BY clause
        if(!this.orderByList.isEmpty()) this.query += ' ORDER BY ' + String.join(new List<String>(orderByList), ', ');

        // Add the LIMIT if provided
        if(this.limitCount != null) this.query += ' LIMIT '+ this.limitCount;
        // Mark the query as FOR UPDATE if true. You can't use LIMIT and FOR UPDATE together
        if(this.limitCount == null && this.forUpdate) this.query += ' FOR UPDATE';
        // Show the final query
        System.debug(this.query);

        return this.query;
    }

}