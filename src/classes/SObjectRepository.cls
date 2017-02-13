public abstract class SObjectRepository implements ISObjectRepository {

    public enum SortOrder {
        ASCENDING, DESCENDING
    }

    private SObjectType sobjectType;
    private Map<String, Schema.SObjectField> sobjectTypeFieldMap;
    private Set<String> queryFields;
    private String query;
    private Schema.FieldSet fieldSet;
    private List<String> whereClauseList;
    private List<String> orderByList;
    private Integer limitCount;
    private Boolean forUpdate;

    protected SObjectRepository(Schema.FieldSet fieldSet) {
        this.fieldSet = fieldSet;

        this.sobjectType         = fieldSet.getSObjectType();
        this.sobjectTypeFieldMap = this.sobjectType.getDescribe().fields.getMap();
        this.queryFields         = new Set<String>{'Id'}; // Always add the ID field, just in case it's not in the field set
        this.whereClauseList     = new List<String>();
        this.orderByList         = new List<String>();
        this.forUpdate           = false;

        this.parseFieldSetMembers();
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
        return this.orderBy(orderByField, null);
    }

    public ISObjectRepository orderBy(Schema.SObjectField orderByField, SObjectRepository.SortOrder sortOrder) {
        String sortOrderSoql = '';
        if(sortOrder == SObjectRepository.SortOrder.ASCENDING) sortOrderSoql = ' ASC';
        else if(sortOrder == SObjectRepository.SortOrder.DESCENDING) sortOrderSoql = ' DESC';

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

    private void parseFieldSetMembers() {
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