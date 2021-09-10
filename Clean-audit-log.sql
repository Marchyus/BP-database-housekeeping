--
-- Cleanups audit log BPAAuditEvents, by writing NULLs into oldXML and newXML columns. 
-- Tested with BluePrism 6.*
-- 
-- Main difference from cleanup script, provided by BluePrism, is this:
-- - Does not lock out table (if updating >5000 rows)
-- - Can be executed on active database
-- - Can be executed in small batches
-- - Can be executed on huge tables (tested with >250GB)
-- - Downside: it's not super fast.
--
-- How to/before executing. Set values to:
-- @daystokeep - days to keep. Default value - 365 days.
-- @maxloops - how many update loops to perform
-- @rowcount - how many recors to update in one loop
--
-- To calculate ammount of rows will be updated, multiplicate maxloops with row count (e.g. 100 * 100 = 10K rows will be updated)
-- 
--
-- IMPORTANT! Set how many days of process edit history to keep.
DECLARE @daystokeep int;
SET @daystokeep = 365;

-- Define how many loops to perform (from @loopno to @maxloops)
DECLARE @loopno INT = 0;
DECLARE @maxloops INT = 100;

-- Ammount of rows to update in one loop
DECLARE @rowcount INT = 100;

-- Set this to midnight on the day @daystokeep days ago
declare @threshold datetime;
set @threshold = DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()), -@daystokeep);

PRINT 'Date treshold: ' + CAST(@threshold AS VARCHAR);

WHILE @loopno < @maxloops
	BEGIN
		PRINT 'loop nr.: ' + CAST(@loopno AS VARCHAR);
		UPDATE TOP (@rowcount) BPAAuditEvents SET 
			oldXML = null,
			newXml = null
		WHERE eventdatetime < @threshold
		AND (oldXML IS NOT NULL OR newXML IS NOT NULL);

		SET @loopno = @loopno + 1;

	END;
PRINT 'Done updating';
GO
