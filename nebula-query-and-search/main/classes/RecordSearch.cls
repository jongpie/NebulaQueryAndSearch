/*******************************************************************************************************
 * This file is part of the Nebula Query & Search project, released under the MIT License.             *
 * See LICENSE file or go to https://github.com/jongpie/NebulaQueryAndSearch for full license details. *
 ******************************************************************************************************/

/**
 * @group SOSL Searches
 * @description Handles generating & executing SObject SOSL searches
 * @see SOSL
 * @see Query
 */
@SuppressWarnings('PMD.ApexDoc, PMD.AvoidGlobalModifier')
global class RecordSearch extends SOSL {
    global RecordSearch(String searchTerm, Query sobjectQuery) {
        super(searchTerm, sobjectQuery);
    }

    global RecordSearch(String searchTerm, List<Query> sobjectQueries) {
        super(searchTerm, sobjectQueries);
    }

    global RecordSearch inSearchGroup(SOSL.SearchGroup searchGroup) {
        if (searchGroup == null) {
            return this;
        }

        this.searchGroup = searchGroup;
        return this.setHasChanged();
    }

    global RecordSearch withDataCategory(
        Schema.DataCategory dataCategory,
        SOSL.DataCategoryLocation dataCategoryLocation,
        Schema.DataCategory childDataCategory
    ) {
        return this.withDataCategory(dataCategory, dataCategoryLocation, new List<Schema.DataCategory>{ childDataCategory });
    }

    global RecordSearch withDataCategory(
        Schema.DataCategory dataCategory,
        SOSL.DataCategoryLocation dataCategoryLocation,
        List<Schema.DataCategory> childDataCategories
    ) {
        List<String> childDataCategoryApiNames = new List<String>();
        for (Schema.DataCategory childDataCategory : childDataCategories) {
            childDataCategoryApiNames.add(childDataCategory.getName());
        }
        this.withDataCategoryClauses.add(dataCategory.getName() + ' ' + dataCategoryLocation + ' (' + String.join(childDataCategoryApiNames, ', ') + ')');
        return this.setHasChanged();
    }

    global RecordSearch withHighlight() {
        this.withClauses.add('HIGHLIGHT');
        return this.setHasChanged();
    }

    global RecordSearch withSnippet(Integer targetLength) {
        this.withClauses.add('SNIPPET (target_length=' + targetLength + ')');
        return this.setHasChanged();
    }

    global RecordSearch withSpellCorrection() {
        this.withClauses.add('SPELL_CORRECTION = true');
        return this.setHasChanged();
    }

    global RecordSearch updateArticleReporting(SOSL.ArticleReporting articleReporting) {
        this.articleReporting = articleReporting;
        return this.setHasChanged();
    }

    global RecordSearch cacheResults() {
        this.cacheResults = true;
        return this.setHasChanged();
    }

    // TODO decide if this should be global
    @SuppressWarnings('PMD.AvoidDebugStatements')
    public override String getSearch() {
        if (this.searchQuery != null && !this.hasChanged) {
            return this.searchQuery;
        }

        this.searchQuery =
            'FIND \'' +
            this.searchTerm +
            '\'' +
            super.doGetSearchGroupString() +
            super.doGetReturningSObjectsString() +
            super.doGetWithClauseString() +
            super.doGetUpdateArticleReportingString();

        // Change hasChanged to false so that subsequent calls to getSearchQuery() use the cached search query string
        // If additional builder methods are later called, the builder methods will set hasChanged = true
        this.hasChanged = false;

        System.debug(LoggingLevel.FINEST, this.searchQuery);
        return this.searchQuery;
    }

    global SObject getFirstResult() {
        return super.doGetFirstResult();
    }

    global List<SObject> getFirstResults() {
        return super.doGetFirstResults();
    }

    global List<List<SObject>> getResults() {
        return super.doGetResults();
    }

    private RecordSearch setHasChanged() {
        this.hasChanged = true;
        return this;
    }
}
