public class QueryGenerator {

    private Schema.FieldSet fieldSet;
    private SObjectType sobjectType;
    private Schema.DescribeSObjectResult sobjectResult;
    private Set<String> queryFields;

    public QueryGenerator(Schema.DescribeSObjectResult sobjectResult) {
        this(sobjectResult, null);
    }

    public QueryGenerator(Schema.FieldSet fieldSet) {
        this(null, fieldSet);
    }

    private QueryGenerator(Schema.DescribeSObjectResult sobjectResult, Schema.FieldSet fieldSet) {
        this.fieldSet      = fieldSet;
        this.sobjectResult = sobjectResult;

        this.sobjectType   = fieldSet != null ? fieldSet.getSObjectType() : sobjectResult.getSobjectType();
        this.queryFields   = new Set<String>{'Id'};

        if(this.fieldSet == null) this.parseSObjectFields();
        else this.parseFieldSetMembers();
    }

    public String buildQuery() {
        return this.buildQuery('');
    }

    public String buildQuery(String whereClause) {
        String query =
            'SELECT ' + String.join(new List<String>(this.queryFields), ', ')
            + ' FROM ' + this.sobjectType;

        if(!String.isEmpty(whereClause)) query = query + whereClause;

        return query;
    }

    public void parseSObjectFields() {
         for(Schema.SObjectField sobjectField : this.sobjectResult.fields.getMap().values()) {
            this.queryFields.add(sobjectField.getDescribe().getName());
         }
    }

    private void parseFieldSetMembers() {
        if(this.fieldSet == null) return;

        for(Schema.FieldSetMember field : this.fieldSet.getFields()) this.queryFields.add(field.getFieldPath());
    }

}