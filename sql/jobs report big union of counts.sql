    SELECT
        'LTA and Job Territory Mismatch' rtype,
        count(jobName) rcount
    FROM (
    SELECT
            "SalesTerritory1"."Name" salesTerritoryName,
            "SalesTerritory1"."TerritoryId" salesTerritoryId,
            CAST("ServiceRequest0"."ExtnAttributeChar013" AS CHAR(5)) postal,
            "ServiceRequest0"."SrNumber" jobName,
            "ServiceRequest0"."ExtnAttributeChar044" country,
            "ServiceRequest0"."CreationDate" CreationDate
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

UNION ALL

    SELECT
        'Empty LTA but has Sales Territory' rtype,
        count(jobs2.jobName) rcount
    FROM (
    SELECT
            "SalesTerritory1"."Name" salesTerritoryName,
            "SalesTerritory1"."TerritoryId" salesTerritoryId,
            CAST("ServiceRequest0"."ExtnAttributeChar013" AS CHAR(5)) postal,
            "ServiceRequest0"."SrNumber" jobName,
            "ServiceRequest0"."ExtnAttributeChar044" country,
            "ServiceRequest0"."CreationDate" CreationDate
        FROM "custExtb088fb5f_c79f_4504_b773_4939f5d365fd"
        WHERE "ServiceRequest0"."ExtnAttributeChar044" = 'US'
            AND "ServiceRequest0"."CreationDate" >= now() - 730
) jobs2
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
) lta2 on lta2.postal = jobs2.postal
    WHERE jobs2.salesTerritoryId IS NOT NULL
        AND lta2.territoryId IS NULL

UNION ALL

    SELECT
        'Empty Sales Territory but has LTA',
        count(jobs3.jobName)
    FROM (
    SELECT
            "SalesTerritory1"."Name" salesTerritoryName,
            "SalesTerritory1"."TerritoryId" salesTerritoryId,
            CAST("ServiceRequest0"."ExtnAttributeChar013" AS CHAR(5)) postal,
            "ServiceRequest0"."SrNumber" jobName,
            "ServiceRequest0"."ExtnAttributeChar044" country,
            "ServiceRequest0"."CreationDate" CreationDate
        FROM "custExtb088fb5f_c79f_4504_b773_4939f5d365fd"
        WHERE "ServiceRequest0"."ExtnAttributeChar044" = 'US'
            AND "ServiceRequest0"."CreationDate" >= now() - 730
) jobs3
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
) lta3 on lta3.postal = jobs3.postal
    WHERE jobs3.salesTerritoryId IS NULL
        AND lta3.territoryId IS NOT NULL

UNION ALL

SELECT
    'Jobs within 2 years Updated today',
    count(jobs4.jobName)
FROM (
    SELECT
        "SalesTerritory1"."Name" salesTerritoryName,
        "SalesTerritory1"."TerritoryId" salesTerritoryId,
        CAST("ServiceRequest0"."ExtnAttributeChar013" AS CHAR(5)) postal,
        "ServiceRequest0"."SrNumber" jobName,
        "ServiceRequest0"."ExtnAttributeChar044" country,
        "ServiceRequest0"."CreationDate" CreationDate
    FROM "custExtb088fb5f_c79f_4504_b773_4939f5d365fd"
    WHERE "ServiceRequest0"."ExtnAttributeChar044" = 'US'
        AND "ServiceRequest0"."CreationDate" >= now() - 730
) jobs4
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
) lta4 on lta4.postal = jobs4.postal
WHERE jobs4.salesTerritoryId IS NULL
    AND lta4.territoryId IS NOT NULL
