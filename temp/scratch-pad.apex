// Normal query
Query accountQuery = new Query(Schema.Case.SObjectType)
    .addField(new SOQL.QueryField(new List<Schema.SObjectField>{
        Schema.Case.AccountId,
        Schema.Account.AnnualRevenue
    }))
    .addField(new SOQL.QueryField(new List<Schema.SObjectField>{
        Schema.Case.OwnerId,
        Schema.User.Username
    }))
    .addParentField(Schema.Case.CreatedById, Schema.User.Username)
    .addParentField(
        new List<Schema.SObjectField>{ Schema.Case.ContactId, Schema.Contact.AccountId, Schema.Contact.OwnerId },
        Schema.User.Email
    )
    .addParentFields(Schema.Case.OwnerId, new List<Schema.SObjectField>{ Schema.User.Email, Schema.User.Username })
    .addParentFields(
        new List<Schema.SObjectField>{ Schema.Case.ContactId, Schema.Contact.AccountId, Schema.Contact.OwnerId },
        new List<Schema.SObjectField>{ Schema.User.Email, Schema.User.Username }
    );

System.debug(accountQuery.getQuery());
System.debug(accountQuery.getResults());


// Aggregate query
SOQL.QueryField parentField = new SOQL.QueryField(new List<Schema.SObjectField>{Schema.User.ProfileId, Schema.Profile.Name});
// System.debug('grouping field: ' + JSON.serializePretty(new AggregateQuery.GroupingField(parentField)));

AggregateQuery aggrQuery = new AggregateQuery(Schema.User.SObjectType)
    // .groupByField(Schema.User.Profile.Name, 'profileName')
    .groupByField(parentField)
    .groupByField(Schema.User.Name)
    // .groupByField(Schema.User.IsActive)
    .limitTo(10)
    .addAggregate(SOQL.Aggregate.COUNT, Schema.User.Id, 'my_count');
System.debug('result: ' + JSON.serializePretty(aggrQuery.getQuery()));
// System.debug('result: ' + JSON.serializePretty(aggrQuery.getQueryLocator()));
System.debug('result: ' + JSON.serializePretty(aggrQuery.getResults()));
System.debug('result: ' + JSON.serializePretty(aggrQuery.getResultProxies()));


//System.debug('query locator: ' + Database.getQueryLocator('SELECT Count(Id), Profile.Name FROM User GROUP BY Profile.Name'));
// System.debug('query locator: ' + Database.getQueryLocator([SELECT Id, RecordVisibility.VisibilityAttribute FROM Account WHERE Id = 'xxx'
//    WITH RecordVisibilityContext (maxDescriptorPerRecord=100)]));

AggregateQuery leadAggregateQuery = new AggregateQuery(Schema.Lead.SObjectType)
    .groupByField(Schema.Lead.LeadSource)
    .groupByField(Schema.Lead.Rating)
    .groupingField(Schema.Lead.LeadSource)
    .groupingField(Schema.Lead.Rating)
    .usingGroupingDimension(Soql.GroupingDimension.CUBE)
    .addAggregate(SOQL.Aggregate.COUNT, Schema.Lead.Id);

System.debug('>>> query: ' + leadAggregateQuery.getQuery());
System.debug('>>> results: ' + leadAggregateQuery.getResults());
System.debug('>>> results: ' + JSON.serializePretty(leadAggregateQuery.getResultProxies()));
/*

    SELECT LeadSource, Rating,
    GROUPING(LeadSource) grpLS, GROUPING(Rating) grpRating,
    COUNT(Name) cnt
FROM Lead
GROUP BY ROLLUP(LeadSource, Rating) */