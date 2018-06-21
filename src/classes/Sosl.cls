/******************************************************************************************************
* This file is part of the Nebula Query & Search project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaQueryAndSearch for full license details. *
******************************************************************************************************/
public abstract class Sosl {

    public enum ArticleReporting { TRACKING, VIEWSTAT }
    public enum DataCategoryLocation { AT, ABOVE, BELOW, ABOVE_OR_BELOW }
    public enum SearchGroup { ALL_FIELDS, NAME_FIELDS, EMAIL_FIELDS, PHONE_FIELDS, SIDEBAR_FIELDS }

    public abstract Set<Schema.SobjectType> getSobjectTypes();
    public abstract String getSearch();

}