public class Sosl {
// currency conversion (when multi-currency enabled) https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_sosl_querying_currency_fields.htm
    public enum Clause { HIGHLIGHT, SPELL_CORRECTION }
    public enum DataCategoryLocation { AT, ABOVE, BELOW, ABOVE_OR_BELOW }
    public enum SearchGroup { ALL_FIELDS, NAME_FIELDS, EMAIL_FIELDS, PHONE_FIELDS, SIDEBAR_FIELDS }




public class SearchSoql extends Soql {

    private String listViewDeveloperName;

    public SearchSoql(Schema.SobjectType sobjectType) {
        super(sobjectType);
    }

    public SearchSoql usingListview(String listViewDeveloperName) {
        // TODO finish implementing
        this.listViewDeveloperName = listViewDeveloperName;
        this.setHasChanged();
        return this;
    }

    public override String getQuery() {
        String sobjectTypeOptions = this.getQueryFieldString()
            + this.getUsingListviewString()
            + this.getWhereClauseString()
            + this.getOrderByString()
            + this.getLimitCountString();

        // If we have any sobject-specific options, then wrap the options in parentheses
        sobjectTypeOptions = String.isEmpty(sobjectTypeOptions) ? '' : '(' + sobjectTypeOptions + ')';

        String searchQuery = this.getSobjectType() + sobjectTypeOptions;
        System.debug(LoggingLevel.FINEST, searchQuery);
        return searchQuery;
    }

    private String getUsingListviewString() {
        return this.listViewDeveloperName == null ? '' : ' USING ListView=' + this.listViewDeveloperName;
    }

}




    private static Map<Integer, List<List<Sobject>>> cachedSearchResultsByHashCode = new Map<Integer, List<List<Sobject>>>();

    private String searchQuery, searchTerm;
    private List<String> withClauses, withDataCategoryClauses;
    private SearchGroup searchGroup;
    private List<SearchSoql> searchQueries;
    private Boolean cacheResults, hasChanged;

    public Sosl(String searchTerm, SearchSoql searchQuery) {
        this(searchTerm, new List<SearchSoql>{searchQuery});
    }

    public Sosl(String searchTerm, List<SearchSoql> searchQueries) {
        this.searchTerm    = searchTerm;
        this.searchQueries = searchQueries;

        this.cacheResults            = false;
        this.searchGroup             = Sosl.SearchGroup.ALL_FIELDS;
        this.withClauses             = new List<String>();
        this.withDataCategoryClauses = new List<String>();
    }

    public Sosl inSearchGroup(SearchGroup searchGroup) {
        this.searchGroup = searchGroup;
        return this.setHasChanged();
    }

    /*public Sosl convertCurrency() {
        // TODO finish implementing
        // https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_sosl_querying_currency_fields.htm
        return this.setHasChanged();
    }*/

    public Sosl includeFormattedValues() {
        // TODO finish implementing
        // https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_sosl_format.htm
        return this.setHasChanged();
    }

    public Sosl updateTracking() {
        // TODO finish implementing
        // https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_sosl_update_tracking.htm
        return this.setHasChanged();
    }

    public Sosl updateViewstat() {
        // TODO finish implementing
        // https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_sosl_update_viewstat.htm
        return this.setHasChanged();
    }

/*public Sosl usingListView() {
    // TODO finish implementing
    // https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_sosl_using_listview.htm
    return this.setHasChanged();
}*/

/*
   https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_sosl_with_data_category.htm
   need to add support for multiple datacategories + 'AND'
FIND {tourism} RETURNING FAQ__kav
    (Id, Title WHERE PublishStatus='online')
    WITH DATA CATEGORY Geography__c ABOVE France__c
    AND Product__c AT mobile_phones__c
    */


    public Sosl withDataCategory(Schema.DataCategory dataCategory, Sosl.DataCategoryLocation dataCategoryLocation, Schema.DataCategory childDataCategory) {
        return this.withDataCategory(dataCategory, dataCategoryLocation, new List<Schema.DataCategory>{childDataCategory});
    }

    public Sosl withDataCategory(Schema.DataCategory dataCategory, Sosl.DataCategoryLocation dataCategoryLocation, List<Schema.DataCategory> childDataCategories) {
        List<String> childDataCategoryApiNames = new List<String>();
        for(Schema.DataCategory childDataCategory : childDataCategories) {
            childDataCategoryApiNames.add(childDataCategory.getName());
        }
        this.withDataCategoryClauses.add(dataCategory.getName() + ' ' + dataCategoryLocation + ' (' + String.join(childDataCategoryApiNames, ', ') + ')');
        return this.setHasChanged();
    }

    public Sosl withHighlight() {
        this.withClauses.add('HIGHLIGHT');
        return this.setHasChanged();
    }

    public Sosl withSnippet(Integer targetLength) {
        this.withClauses.add('SNIPPET (target_length=' + targetLength + ')');
        return this.setHasChanged();
    }

    public Sosl withSpellCorrection() {
        this.withClauses.add('SPELL_CORRECTION = true');
        return this.setHasChanged();
    }

    public Sosl limitCount(Integer limitCount) {
        // TODO finish implementing
        //this.limitCount = limitCount;
        return this.setHasChanged();
    }

    public Sosl offset(Integer offset) {
        // TODO finish implementing - not 100% sure it's needed
        //https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_sosl_offset.htm
        //this.offset = offset;
        return this.setHasChanged();
    }

    public Sosl cacheResults() {
        this.cacheResults = true;
        return this.setHasChanged();
    }

    public String getQuery() {
        if(this.searchQuery != null && !this.hasChanged) return this.searchQuery;

        this.searchQuery = 'FIND \'' + this.searchTerm + '\''
            + this.getSearchGroupString()
            + this.getReturningSobjectsString()
            + this.getWithClauseString();

        // Change hasChanged to false so that subsequent calls to getQuery() use the cached search query string
        // If additional builder methods are later called, the builder methods will set hasChanged = true
        this.hasChanged = false;

        System.debug(LoggingLevel.FINEST, this.searchQuery);
        return this.searchQuery;
    }

    public List<Sobject> getFirstSearchResults() {
        return this.getSearchResults()[0];
    }

    public List<List<Sobject>> getSearchResults() {
        if(this.cacheResults) return this.getCachedQuery();
        else return Search.query(this.getQuery());
    }

    private Sosl setHasChanged() {
        this.hasChanged = true;
        return this;
    }

    private List<List<Sobject>> getCachedQuery() {
        String searchQuery = this.getQuery();
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

    private String getSearchGroupString() {
        return ' IN ' + this.searchGroup.name().replace('_', ' ');
    }

    private String getReturningSobjectsString() {
        if(this.searchQueries.isEmpty()) return '';

        List<String> searchQueryStrings = new List<String>();
        this.searchQueries.sort();
        for(SearchSoql searchQuery : this.searchQueries) {
            searchQueryStrings.add(searchQuery.getQuery());
        }
        return ' RETURNING ' + String.join(searchQueryStrings, ', ');
    }

    private String getWithClauseString() {
        List<String> combinedWithClauses = new List<String>(this.withClauses);
        if(!this.withDataCategoryClauses.isEmpty()) {
            String withDataCategoryClausesString = 'DATA CATEGORY ' + String.join(withDataCategoryClauses, ' AND ');
            combinedWithClauses.add(withDataCategoryClausesString);
        }
        this.withClauses.sort();
        return this.withClauses.isEmpty() ? '' : ' WITH ' + String.join(this.withClauses, ' WITH ');
    }

}