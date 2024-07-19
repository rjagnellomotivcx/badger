SELECT
count(jobName)
FROM (
    SELECT
        "SalesTerritory1"."Name" salesTerritoryName,
        "SalesTerritory1"."TerritoryId" salesTerritoryId,
        CAST("ServiceRequest0"."ExtnAttributeChar013" AS CHAR(5)) postal,
        "ServiceRequest0"."SrNumber" jobName,
        "ServiceRequest0"."ExtnAttributeChar044" country,
        "ServiceRequest0"."CreationDate" CreationDate,
        
    FROM "custExtb088fb5f_c79f_4504_b773_4939f5d365fd"
    WHERE "ServiceRequest0"."ExtnAttributeChar044" = 'US'
        AND "ServiceRequest0"."CreationDate" >= now() - 730
) jobs
    LEFT JOIN
    (
        SELECT
        "LeadTerritoryAssignment_c"."Country_c" country,
        "LeadTerritoryAssignment_c"."FSA_c" fsa,
        "LeadTerritoryAssignment_c"."RecordName" recordName,
        "LeadTerritoryAssignment_c"."Territory_Id_c" territoryId,
        CAST("LeadTerritoryAssignment_c"."Zip_c" AS CHAR(5)) postal
    FROM "custExt66d59094_7e34_4bc3_85d5_6e6215853fee"
    WHERE "LeadTerritoryAssignment_c"."Country_c"  = 'United States'
) lta on lta.postal = jobs.postal
WHERE jobs.salesTerritoryId <> lta.territoryId