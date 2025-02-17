SELECT
    jobs.jobName,
    jobs.salesTerritoryId,
    jobs.salesTerritoryName,
    jobs.postal,
    jobs.CreationDate,
    jobs.lastTerritoryAssignedDate,
    jobs.jobStatus,
    lta.territoryId,
    lta.postal,
    ltaName.salesTerritoryName
FROM (
    SELECT
        "SalesTerritory1"."Name" salesTerritoryName,
        "SalesTerritory1"."TerritoryId" salesTerritoryId,
        CAST("ServiceRequest0"."ExtnAttributeChar013" AS CHAR(5)) postal,
        "ServiceRequest0"."SrNumber" jobName,
        "ServiceRequest0"."ExtnAttributeChar044" country,
        "ServiceRequest0"."CreationDate" CreationDate,
        "ServiceRequest0"."ExtnAttributeTimestamp009" lastTerritoryAssignedDate,
        "ServiceRequest0"."ExtnAttributeChar026" jobStatus
    FROM "custExtb088fb5f_c79f_4504_b773_4939f5d365fd"
    WHERE "ServiceRequest0"."ExtnAttributeChar044" = 'US'
        AND "ServiceRequest0"."CreationDate" > (CURRENT_DATE - 730)
        AND ("ServiceRequest0"."ExtnAttributeTimestamp009" < CURRENT_DATE
        OR "ServiceRequest0"."ExtnAttributeTimestamp009" IS NULL)
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
    LEFT JOIN (
SELECT
        "SalesTerritory1"."Name" salesTerritoryName,
        "SalesTerritory1"."TerritoryId" salesTerritoryId
    FROM "custExtb088fb5f_c79f_4504_b773_4939f5d365fd"
) ltaName ON ltaName.salesTerritoryId = lta.territoryId
WHERE jobs.jobStatus <> 'Cancelled'
    AND jobs.postal IS NOT NULL
    AND jobs.salesTerritoryId <> lta.territoryId
        AND jobs.postal = '46975'


