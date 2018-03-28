public class Sosl {
// currency conversion (when multi-currency enabled) https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_sosl_querying_currency_fields.htm
    public enum SearchGroup { ALL_FIELDS, NAME_FIELDS, EMAIL_FIELDS, PHONE_FIELDS, SIDEBAR_FIELDS }

    private static Map<Integer, List<List<Sobject>>> cachedSearchResultsByHashCode = new Map<Integer, List<List<Sobject>>>();

    private String searchQuery, searchTerm;
    private SearchGroup searchGroup;
    private List<Soql> queries;
    private Boolean cacheResults, soslHasChanged, withHighlight, withSpellCorrection;

    public Sosl(String searchTerm, Soql query) {
        this(searchTerm, new List<Soql>{query});
    }

    public Sosl(String searchTerm, List<Soql> queries) {
        this.searchTerm = searchTerm;
        this.queries    = queries;

        this.cacheResults = false;
        this.inSearchGroup(Sosl.SearchGroup.ALL_FIELDS);
        this.withHighlight(false);
        this.withSpellCorrection(false);
    }

    public Sosl inSearchGroup(SearchGroup searchGroup) {
        this.searchGroup = searchGroup;
        return this.setSoslHasChanged();
    }

    public Sosl withHighlight(Boolean withHighlight) {
        this.withHighlight = withHighlight;
        return this.setSoslHasChanged();
    }

    public Sosl withSpellCorrection(Boolean withSpellCorrection) {
        this.withSpellCorrection = withSpellCorrection;
        return this.setSoslHasChanged();
    }

    public Sosl cacheResults() {
        this.cacheResults = true;
        return this.setSoslHasChanged();
    }

    public String getSearchQuery() {
        if(this.searchQuery != null && !this.soslHasChanged) return this.searchQuery;

        List<String> searchQueries = new List<String>();
        this.queries.sort();
        for(Soql query : this.queries) {
            searchQueries.add(query.getSearchQuery());
        }

        this.searchQuery = 'FIND \'' + this.searchTerm + '\''
            + ' IN ' + this.searchGroup.name().replace('_', ' ')
            + ' RETURNING ' + String.join(searchQueries, ', ');

        if(this.withHighlight) searchQuery += ' WITH HIGHLIGHT';
        if(this.withSpellCorrection) searchQuery += ' WITH SPELL_CORRECTION = ' + this.withSpellCorrection;

        // Change soslHasChanged to false so that subsequent calls to getSearchQuery() use the cached search query string
        // If additional builder methods are later called, the builder methods will set soslHasChanged = true
        this.soslHasChanged = false;

        System.debug(LoggingLevel.FINEST, this.searchQuery);
        return this.searchQuery;
    }

    public List<Sobject> getFirstSearchResults() {
        return this.getSearchResults()[0];
    }

    public List<List<Sobject>> getSearchResults() {
        if(this.cacheResults) return this.getCachedSearchQuery();
        else return Search.query(this.getSearchQuery());
    }

    private Sosl setSoslHasChanged() {
        this.soslHasChanged = true;
        return this;
    }

    private List<List<Sobject>> getCachedSearchQuery() {
        String searchQuery = this.getSearchQuery();
        Integer hashCode   = searchQuery.hashCode();

        Boolean isCached = cachedSearchResultsByHashCode.containsKey(hashCode);
        if(!isCached) cachedSearchResultsByHashCode.put(hashCode, Search.query(searchQuery));

        // Always return a deep clone so the original cached version is never modified
        List<List<SObject>> cachedResults = cachedSearchResultsByHashCode.get(hashCode);
        List<List<SObject>> deepClonedResults = new List<List<SObject>>();
        for(List<SObject> cachedListOfResults : cachedResults) {
            deepClonedResults.add(cachedListOfResults.deepClone(true, true, true));
        }
        return deepClonedResults;
    }


}