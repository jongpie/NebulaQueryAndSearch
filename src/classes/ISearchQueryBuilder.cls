public interface ISearchQueryBuilder {

    ISearchQueryBuilder cacheResults();

    ISearchQueryBuilder inSearchGroup(QueryBuilder.SearchGroup searchGroup);
    ISearchQueryBuilder withHighlight(Boolean withHighlight);
    ISearchQueryBuilder withSpellCorrection(Boolean withSpellCorrection);

    String getQuery();

    List<SObject> getFirstSearchResult();
    List<List<SObject>> getSearchResults();

}