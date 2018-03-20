public class Sosl {
// currency conversion (when multi-currency enabled) https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_sosl_querying_currency_fields.htm
    public enum SearchGroup { ALL_FIELDS, NAME_FIELDS, EMAIL_FIELDS, PHONE_FIELDS, SIDEBAR_FIELDS }

    private String searchTerm;
    private SearchGroup searchGroup;
    private List<Soql> queries;
    private Boolean withHighlight;
    private Boolean withSpellCorrection;

    public Sosl(String searchTerm, Soql query) {
        this(searchTerm, new List<Soql>{query});
    }

    public Sosl(String searchTerm, List<Soql> queries) {
        this.searchTerm = searchTerm;
        this.queries    = queries;

        this.searchGroup = Sosl.SearchGroup.ALL_FIELDS;
    }

    public Sosl inSearchGroup(SearchGroup searchGroup) {
        this.searchGroup = searchGroup;
        return this;
    }

    public Sosl withHighlight(Boolean withHighlight) {
        this.withHighlight = withHighlight;
        return this;
    }

    public Sosl withSpellCorrection(Boolean withSpellCorrection) {
        this.withSpellCorrection = withSpellCorrection;
        return this;
    }

    public String getSearchQuery() {
        List<String> searchQueries = new List<String>();
        for(Soql query : this.queries) searchQueries.add(query.getSearchQuery());

        String query = 'FIND \'' + this.searchTerm + '\''
            + ' IN ' + this.searchGroup.name().replace('_', ' ')
            + ' RETURNING ' + String.join(searchQueries, ', ');

        if(this.withHighlight != null) query += ' WITH HIGHLIGHT';
        if(this.withSpellCorrection != null) query += ' WITH SPELL_CORRECTION = ' + this.withSpellCorrection;

        return query;
    }

    public List<List<SObject>> getSearchResults() {
        return Search.query(this.getSearchQuery());
    }

}