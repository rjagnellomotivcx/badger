SELECT 
   jobs.jobName saw_0,
   jobs.salesTerritoryId saw_1,
   jobs.salesTerritoryName saw_2,
   jobs.postal saw_3,
   jobs.CreationDate saw_4,
   jobs.lastTerritoryAssignedDate saw_5,
   lta.territoryId saw_6,
   lta.postal saw_7,
   ltaName.salesTerritoryName saw_8
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
        AND "ServiceRequest0"."CreationDate" >= now() - 730
        AND ("ServiceRequest0"."ExtnAttributeTimestamp009" < CURRENT_DATE
        OR "ServiceRequest0"."ExtnAttributeTimestamp009" IS NULL)
) jobs LEFT JOIN (
        SELECT
        "LeadTerritoryAssignment_c"."Country_c" country,
        "LeadTerritoryAssignment_c"."FSA_c" fsa,
        "LeadTerritoryAssignment_c"."RecordName" recordName,
        "LeadTerritoryAssignment_c"."Territory_Id_c" territoryId,
        CAST("LeadTerritoryAssignment_c"."Zip_c" AS CHAR(5)) postal
    FROM "custExt66d59094_7e34_4bc3_85d5_6e6215853fee"
    WHERE "LeadTerritoryAssignment_c"."Country_c"  = 'United States'
) lta on lta.postal = jobs.postal LEFT JOIN (
SELECT
        "SalesTerritory1"."Name" salesTerritoryName,
        CAST("SalesTerritory1"."TerritoryId" AS INT) + 1 salesTerritoryId
    FROM "custExtb088fb5f_c79f_4504_b773_4939f5d365fd"
) ltaName ON ltaName.salesTerritoryId = lta.territoryId
 WHERE 
(ltaName.salesTerritoryName <> jobs.salesTerritoryName) AND jobs.jobStatus <> 'Cancelled' AND jobs.postal IS NOT NULL
