DECLARE @PartitionsCount int;
SET @PartitionsCount = 4;

SELECT
CASE
    WHEN previous IS NULL THEN FORMATMESSAGE('"PartitionKey lt ''%s''", ', [next])
    WHEN [next] IS NULL THEN FORMATMESSAGE('"PartitionKey gt ''%s''"', projectId)
    ELSE FORMATMESSAGE('"PartitionKey ge ''%s'' and PartitionKey le ''%s''", ', projectId, [next])
END AS [filter]
FROM
	(SELECT projectId, bucket, LAG(projectId) OVER(ORDER BY bucket) AS previous, LEAD(projectId) OVER(ORDER BY bucket) as [next] FROM
		(SELECT projectId, bucket, ROW_NUMBER() OVER(PARTITION BY bucket ORDER BY projectId) AS rn
		FROM
			(SELECT projectId, NTILE(@PartitionsCount) OVER(ORDER BY projectId) bucket
			FROM (SELECT CAST([ProjectId] AS varchar(100)) AS projectId FROM [dbo].[Project]) AS X) AS Y) AS Z
	WHERE rn = 1) AS W