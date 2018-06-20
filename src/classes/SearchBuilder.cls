/******************************************************************************************************
* This file is part of the Nebula Query & Search project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaQueryAndSearch for full license details. *
******************************************************************************************************/
public class SearchBuilder {

    public enum ArticleReporting { TRACKING, VIEWSTAT }
    public enum Clause { HIGHLIGHT, SPELL_CORRECTION }
    public enum DataCategoryLocation { AT, ABOVE, BELOW, ABOVE_OR_BELOW }
    public enum SearchGroup { ALL_FIELDS, NAME_FIELDS, EMAIL_FIELDS, PHONE_FIELDS, SIDEBAR_FIELDS }

    private static Map<Integer, List<List<Sobject>>> cachedSearchResultsByHashCode = new Map<Integer, List<List<Sobject>>>();

    private String searchQuery, searchTerm;
    private ArticleReporting articleReporting;
    private List<String> withClauses, withDataCategoryClauses;
    private SearchGroup searchGroup;
    private List<SobjectQueryBuilder> searchQueries;
    private Boolean cacheResults, hasChanged;

    public SearchBuilder(String searchTerm, SobjectQueryBuilder query) {
        this(searchTerm, new List<SobjectQueryBuilder>{query});
    }

    public SearchBuilder(String searchTerm, List<SobjectQueryBuilder> queries) {
        this.searchTerm    = String.escapeSingleQuotes(searchTerm);
        this.searchQueries = queries;

        this.cacheResults            = false;
        this.searchGroup             = SearchBuilder.SearchGroup.ALL_FIELDS;
        this.withClauses             = new List<String>();
        this.withDataCategoryClauses = new List<String>();
    }

    public SearchBuilder inSearchGroup(SearchGroup searchGroup) {
        this.searchGroup = searchGroup;
        return this.setHasChanged();
    }

    public SearchBuilder withDataCategory(Schema.DataCategory dataCategory, SearchBuilder.DataCategoryLocation dataCategoryLocation, Schema.DataCategory childDataCategory) {
        return this.withDataCategory(dataCategory, dataCategoryLocation, new List<Schema.DataCategory>{childDataCategory});
    }

    public SearchBuilder withDataCategory(Schema.DataCategory dataCategory, SearchBuilder.DataCategoryLocation dataCategoryLocation, List<Schema.DataCategory> childDataCategories) {
        List<String> childDataCategoryApiNames = new List<String>();
        for(Schema.DataCategory childDataCategory : childDataCategories) {
            childDataCategoryApiNames.add(childDataCategory.getName());
        }
        this.withDataCategoryClauses.add(dataCategory.getName() + ' ' + dataCategoryLocation + ' (' + String.join(childDataCategoryApiNames, ', ') + ')');
        return this.setHasChanged();
    }

    public SearchBuilder withHighlight() {
        this.withClauses.add('HIGHLIGHT');
        return this.setHasChanged();
    }

    public SearchBuilder withSnippet(Integer targetLength) {
        this.withClauses.add('SNIPPET (target_length=' + targetLength + ')');
        return this.setHasChanged();
    }

    public SearchBuilder withSpellCorrection() {
        this.withClauses.add('SPELL_CORRECTION = true');
        return this.setHasChanged();
    }

    public SearchBuilder updateArticleReporting(SearchBuilder.ArticleReporting articleReporting) {
        this.articleReporting = articleReporting;
        return this.setHasChanged();
    }

    public SearchBuilder cacheResults() {
        this.cacheResults = true;
        return this.setHasChanged();
    }

    public String getSearch() {
        if(this.searchQuery != null && !this.hasChanged) return this.searchQuery;

        this.searchQuery = 'FIND \'' + this.searchTerm + '\''
            + this.getSearchGroupString()
            + this.getReturningSobjectsString()
            + this.getWithClauseString()
            + this.getUpdateArticleReportingString();

        // Change hasChanged to false so that subsequent calls to getSearchQuery() use the cached search query string
        // If additional builder methods are later called, the builder methods will set hasChanged = true
        this.hasChanged = false;

        System.debug(LoggingLevel.FINEST, this.searchQuery);
        return this.searchQuery;
    }

    public Sobject getFirstResult() {
        List<List<Sobject>> results = this.getResults();
        return results.isEmpty() || results[0].isEmpty() ? null : results[0][0];
    }

    public List<Sobject> getFirstResults() {
        List<List<Sobject>> results = this.getResults();
        return results.isEmpty() ? null : results[0];
    }

    public List<List<Sobject>> getResults() {
        if(this.cacheResults) return this.getCachedResults();
        else return Search.query(this.getSearch());
    }

    private SearchBuilder setHasChanged() {
        this.hasChanged = true;
        return this;
    }

    private List<List<Sobject>> getCachedResults() {
        String searchQuery = this.getSearch();
        Integer hashCode   = searchQuery.hashCode();

        Boolean isCached = cachedSearchResultsByHashCode.containsKey(hashCode);
        if(!isCached) cachedSearchResultsByHashCode.put(hashCode, Search.query(searchQuery));

        // Always return a deep clone so the original cached version is never modified
        List<List<Sobject>> cachedResults = cachedSearchResultsByHashCode.get(hashCode);
        List<List<Sobject>> deepClonedResults = new List<List<Sobject>>();
        for(List<Sobject> cachedListOfResults : cachedResults) {
            deepClonedResults.add(cachedListOfResults.deepClone(true, true, true));
        }
        return deepClonedResults;
    }

    private String getSearchGroupString() {
        return ' IN ' + this.searchGroup.name().replace('_', ' ');
    }

    private String getReturningSobjectsString() {
        if(this.searchQueries.isEmpty()) return '';

        List<String> queryStrings = new List<String>();
        this.searchQueries.sort();
        for(SobjectQueryBuilder query : this.searchQueries) {
            queryStrings.add(query.getSearchQuery());
        }
        return ' RETURNING ' + String.join(queryStrings, ', ');
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

    private String getUpdateArticleReportingString() {
        return this.articleReporting == null ? '' : ' UPDATE ' + this.articleReporting.name();
    }

}