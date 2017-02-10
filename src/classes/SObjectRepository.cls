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

    public ISObjectRepository whereFieldEquals(Schema.SObjectField field, Object value) {
        if(value instanceOf String) value = '\'' + value + '\'';
        this.whereClauseList.add(field + ' = ' + value);
        return this;
    }

    public ISObjectRepository whereFieldIn(Schema.SObjectField field, Set<Object> valueSet) {
        return this.whereFieldIn(field, new List<Object>(valueSet));
    }

    public ISObjectRepository whereFieldIn(Schema.SObjectField field, Map<Id, Object> valueMap) {
        return this.whereFieldIn(field, valueMap.values());
    }

    public ISObjectRepository whereFieldIn(Schema.SObjectField field, List<Object> valueList) {
        this.whereClauseList.add(field + ' IN :valueList');
        return this;
    }

    public ISObjectRepository whereIdEquals(Id recordId) {
        return this.whereFieldEquals(this.sobjectTypeFieldMap.get('Id'), recordId);
    }

    public ISObjectRepository whereIdIn(Set<SObject> recordSet) {
        return this.whereFieldIn(this.sobjectTypeFieldMap.get('Id'), new List<SObject>(recordSet));
    }

    public ISObjectRepository whereIdIn(Map<Id, SObject> recordMap) {
        return this.whereFieldIn(this.sobjectTypeFieldMap.get('Id'), recordMap.values());
    }

    public ISObjectRepository whereIdIn(List<SObject> recordList) {
        this.whereClauseList.add(this.sobjectTypeFieldMap.get('Id') + ' IN :recordList');
        return this;
    }

    public ISObjectRepository whereRecordTypeIdEquals(Id recordTypeId) {
        return this.whereFieldEquals(this.sobjectTypeFieldMap.get('RecordTypeId'), recordTypeId);
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

    protected SObject getSObjectRecord() {
        return this.getSObjectList()[0];
    }

    protected List<SObject> getSObjectList() {
        this.buildQuery();
        return Database.query(this.query);
    }

    private void parseFieldSetMembers() {
        if(this.fieldSet == null) return;

        for(Schema.FieldSetMember field : this.fieldSet.getFields()) this.queryFields.add(field.getFieldPath());
    }

    private void buildQuery() {
        this.query = 'SELECT ' + String.join(new List<String>(this.queryFields), ', ')
            + ' FROM ' + this.sobjectType;

        // Generate the where clause
        if(!this.whereClauseList.isEmpty()) this.query += ' WHERE ' + String.join(this.whereClauseList, ' AND ');

        // Generate the order by clause
        if(!this.orderByList.isEmpty()) this.query += ' ORDER BY ' + String.join(new List<String>(orderByList), ', ');

        // Add the LIMIT if provided
        if(this.limitCount != null) this.query += ' LIMIT '+ this.limitCount;
        // Mark the query as FOR UPDATE if true. You can't use LIMIT and FOR UPDATE together
        if(this.limitCount == null && this.forUpdate) this.query += ' FOR UPDATE';
        // Show the final query
        System.debug(this.query);
    }

}