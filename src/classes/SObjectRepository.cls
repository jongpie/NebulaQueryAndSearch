public abstract class SObjectRepository implements ISObjectRepository {

    public enum SortOrder { ASCENDING, DESCENDING }
    public enum NullsSortOrder { FIRST, LAST }

    public enum SearchGroup { ALL_FIELDS, NAME_FIELDS, EMAIL_FIELDS, PHONE_FIELDS, SIDEBAR_FIELDS }

    private SObjectType sobjectType;
    private Map<String, Schema.SObjectField> sobjectTypeFieldMap;
    private Set<String> queryFields;
    private String query;
    private Boolean shouldAddCommonFields;
    private Schema.FieldSet fieldSet;
    private List<String> whereClauseList;
    private List<String> orderByList;
    private Integer limitCount;
    private Boolean forUpdate;

    protected SObjectRepository(Schema.FieldSet fieldSet) {
        this(fieldSet, true);
    }

    protected SObjectRepository(Schema.FieldSet fieldSet, Boolean shouldAddCommonFields) {
        this.fieldSet              = fieldSet;
        this.shouldAddCommonFields = shouldAddCommonFields;

        this.sobjectType           = fieldSet.getSObjectType();
        this.sobjectTypeFieldMap   = this.sobjectType.getDescribe().fields.getMap();
        this.queryFields           = new Set<String>();
        this.whereClauseList       = new List<String>();
        this.orderByList           = new List<String>();
        this.forUpdate             = false;

        this.addCommonQueryFields();
        this.addFieldSetMembers();
    }

    protected SObjectRepository whereFieldOperatorEqualsValue(Schema.SObjectField field, String operator, Object value) {
        return this.addCondition(field, operator, SOQLUtils.toSOQLString(value));
    }

    protected SObjectRepository whereFieldOperatorEqualsListValues(Schema.SObjectField field, String operator, List<Object> values) {
        return this.addCondition(field, operator, SOQLUtils.toSOQLString(values));
    }

    protected SObjectRepository orderBy(Schema.SObjectField orderByField) {
        return this.orderBy(orderByField, null, null);
    }

    protected SObjectRepository orderBy(Schema.SObjectField orderByField, SObjectRepository.SortOrder sortOrder) {
        return this.orderBy(orderByField, sortOrder, null);
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

    protected SObjectRepository setAsUpdate() {
        this.forUpdate = true;
        return this;
    }

    protected SObject getFirstQueryResult() {
        return this.getQueryResults()[0];
    }

    protected List<SObject> getQueryResults() {
        return Database.query(this.getQuery());
    }

    protected List<SObject> getSearchResults(String searchTerm, SObjectRepository.SearchGroup searchGroup) {
        return Search.query(this.getSearchQuery(searchTerm, searchGroup))[0];
    }


    //CRUD
    protected void doInsert(SObject record) {doInsert(new List<SObject>{record});}
    protected void doInsert(List<SObject> records) {Database.insert(records);}
    protected void doUpsert(List<SObject> records) {Database.upsert(records);}
    protected void doUpdate(List<SObject> records) {Database.update(records);}
    protected void doDelete(List<SObject> records) {Database.delete(records);}

    private void addCommonQueryFields() {
        if(!this.shouldAddCommonFields) return;

        // Auto-add the common fields that are available for the SObject Type
        Set<String> commonFieldNameList = new Set<String>{
            'Id', 'CaseNumber', 'CreatedById', 'CreatedDate',  'IsClosed', 'LastModifiedById', 'LastModifiedDate',
            'Name', 'OwnerId', 'Subject', 'RecordTypeId', 'SystemModStamp'
        };

        for(String commonFieldName : commonFieldNameList) {
            //Verify that the field is available on the object being used
            if(!this.sobjectTypeFieldMap.containsKey(commonFieldName)) continue;

            //Salesforce has some inconsistencies in casing for standard field names. We'll go lowercase
            //here and in addFieldSetMembers() to ensure the set is unique
            this.queryFields.add(commonFieldName.toLowerCase());
        }
    }

    private void addFieldSetMembers() {
        if(this.fieldSet == null) return;

        for(Schema.FieldSetMember field : this.fieldSet.getFields()) {
            //Lowercase here as well to ensure strings added to the set are unique
            this.queryFields.add(field.getFieldPath().toLowerCase());
        }
    }

    private SObjectRepository addCondition(Schema.SObjectField field, String operator, String value) {
        this.whereClauseList.add(field + ' ' + operator.trim() + ' ' + value);
        return this;
    }

    private String getQueryFieldString() {
        return String.join(new List<String>(this.queryFields), ',');
    }

    private String getWhereClauseString() {
        String whereClauseString = '';
        if(!this.whereClauseList.isEmpty()) whereClauseString = '\nWHERE ' + String.join(this.whereClauseList, '\nAND ');
        return whereClauseString;
    }

    private String getOrderByString() {
        String orderByString = '';
        if(!this.orderByList.isEmpty()) orderByString = '\nORDER BY ' + String.join(new List<String>(orderByList), ', ');
        return orderByString;
    }

    private String getLimitCountString() {
        String limitString = '';
        if(this.limitCount != null) limitString = '\nLIMIT '+ this.limitCount;
        return limitString;
    }

    private String getForUpdateString() {
        String forUpdateString = '';
        if(this.orderByList.isEmpty() && this.forUpdate) forUpdateString = '\nFOR UPDATE';
        return forUpdateString;
    }

    private String getQuery() {
        this.query = 'SELECT ' + this.getQueryFieldString()
            + ' FROM ' + this.sobjectType
            + this.getWhereClauseString()
            + this.getOrderByString()
            + this.getLimitCountString()
            + this.getForUpdateString();

        System.debug(this.query);

        return this.query;
    }

    private String getSearchQuery(String searchTerm, SObjectRepository.SearchGroup searchGroup) {
        this.query = 'FIND ' + SOQLUtils.toSOQLString(searchTerm)
            + ' IN ' + searchGroup.name().replace('_', ' ')
            + ' RETURNING ' + this.sobjectType + '('
                + this.getQueryFieldString()
                + this.getWhereClauseString()
                + this.getOrderByString()
                + this.getLimitCountString()
            + ')';

        if(this.forUpdate) System.debug(LoggingLevel.WARN, 'SOSL Search Query method flagged as FOR UPDATE. SOSL cannot use FOR UPDATE, ignoring');

        System.debug(this.query);

        return this.query;
    }

}