--
-- Cleanup audit log BPAAuditEvents, by writing NULLs into oldXML and newXML columns. 
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
