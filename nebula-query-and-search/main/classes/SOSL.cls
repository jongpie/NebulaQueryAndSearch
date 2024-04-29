/*******************************************************************************************************
 * This file is part of the Nebula Query & Search project, released under the MIT License.             *
 * See LICENSE file or go to https://github.com/jongpie/NebulaQueryAndSearch for full license details. *
 ******************************************************************************************************/

/**
 * @group SOSL Searches
 * @description Handles common functionality needed for writing SOSL searches
 * @see SOSL
 * @see Query
 */
@SuppressWarnings('PMD.ApexDoc, PMD.AvoidGlobalModifier')
global abstract class SOSL {
  global enum ArticleReporting {
    TRACKING,
    VIEWSTAT
  }

  global enum DataCategoryLocation {
    AT,
    ABOVE,
    BELOW,
    ABOVE_OR_BELOW
  }

  global enum SearchGroup {
    ALL_FIELDS,
    NAME_FIELDS,
    EMAIL_FIELDS,
    PHONE_FIELDS,
    SIDEBAR_FIELDS
  }

  private static Map<Integer, List<List<SObject>>> cachedSearchResultsByHashCode = new Map<Integer, List<List<SObject>>>();

  protected String searchQuery;
  protected String searchTerm;
  protected List<Query> sobjectQueries;
  protected Set<Schema.SObjectType> sobjectTypes;
  protected Boolean cacheResults;
  protected Boolean hasChanged;
  protected SOSL.ArticleReporting articleReporting;
  protected List<String> withClauses;
  protected List<String> withDataCategoryClauses;
  protected System.AccessLevel accessLevel;
  protected SOSL.SearchGroup searchGroup;

  protected SOSL(String searchTerm, Query sobjectQuery) {
    this(searchTerm, new List<Query>{ sobjectQuery });
  }

  protected SOSL(String searchTerm, List<Query> sobjectQueries) {
    this.searchTerm = String.escapeSingleQuotes(searchTerm);
    this.sobjectQueries = sobjectQueries;

    this.cacheResults = false;
    this.hasChanged = false;
    this.searchGroup = SOSL.SearchGroup.ALL_FIELDS;
    this.withClauses = new List<String>();
    this.withDataCategoryClauses = new List<String>();
    this.accessLevel = System.AccessLevel.SYSTEM_MODE;
  }

  public Set<Schema.SObjectType> getSObjectTypes() {
    if (this.sobjectTypes != null) {
      return this.sobjectTypes;
    }

    this.sobjectTypes = new Set<Schema.SObjectType>();
    for (Query query : this.sobjectQueries) {
      this.sobjectTypes.add(query.getSObjectType());
    }
    return this.sobjectTypes;
  }

  // TODO decide if this should be global
  global abstract String getSearch();

  protected SObject doGetFirstResult() {
    List<List<SObject>> results = this.doGetResults();
    return results.isEmpty() || results[0].isEmpty() ? null : results[0][0];
  }

  protected List<SObject> doGetFirstResults() {
    List<List<SObject>> results = this.doGetResults();
    return results.isEmpty() ? null : results[0];
  }

  protected List<List<SObject>> doGetResults() {
    if (this.cacheResults) {
      return this.getCachedResults();
    } else {
      return System.Search.query(this.getSearch(), this.doGetAccessLevel());
    }
  }

  protected String doGetSearchGroupString() {
    return ' IN ' + this.searchGroup.name().replace('_', ' ');
  }

  protected String doGetReturningSObjectsString() {
    if (this.sobjectQueries.isEmpty()) {
      return '';
    }

    List<String> queryStrings = new List<String>();
    this.sobjectQueries.sort();
    for (Query query : this.sobjectQueries) {
      queryStrings.add(query.getSearchQuery());
    }
    return ' RETURNING ' + String.join(queryStrings, ', ');
  }

  protected String doGetWithClauseString() {
    List<String> combinedWithClauses = new List<String>(this.withClauses);
    if (!this.withDataCategoryClauses.isEmpty()) {
      String withDataCategoryClausesString = 'DATA CATEGORY ' + String.join(withDataCategoryClauses, ' AND ');
      combinedWithClauses.add(withDataCategoryClausesString);
    }
    this.withClauses.sort();
    return this.withClauses.isEmpty() ? '' : ' WITH ' + String.join(this.withClauses, ' WITH ');
  }

  protected System.AccessLevel doGetAccessLevel() {
    return this.accessLevel ?? System.AccessLevel.SYSTEM_MODE;
  }

  protected String doGetUpdateArticleReportingString() {
    return this.articleReporting == null ? '' : ' UPDATE ' + this.articleReporting.name();
  }

  private List<List<SObject>> getCachedResults() {
    String searchQuery = this.getSearch();
    Integer hashCode = searchQuery.hashCode();

    Boolean isCached = cachedSearchResultsByHashCode.containsKey(hashCode);
    if (!isCached) {
      cachedSearchResultsByHashCode.put(
        hashCode,
        System.Search.query(searchQuery, this.doGetAccessLevel())
      );
    }

    // Always return a deep clone so the original cached version is never modified
    List<List<SObject>> cachedResults = cachedSearchResultsByHashCode.get(hashCode);
    List<List<SObject>> deepClonedResults = new List<List<SObject>>();
    for (List<SObject> cachedListOfResults : cachedResults) {
      deepClonedResults.add(cachedListOfResults.deepClone(true, true, true));
    }
    return deepClonedResults;
  }
}
