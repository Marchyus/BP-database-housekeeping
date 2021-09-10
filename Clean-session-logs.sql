--
-- Cleanups session logs, older than defined day
-- Tested with BluePrism 5.* and 6.*, but use on your own risk, make backups.
-- Session tables are [BPASessionLog_NonUnicode] and [BPASessionLog_Unicode]. 
-- BP 6.6+ may have tables [BPASessionLog_Unicode_pre65] or [BPASessionLog_NonUnicode_pre65], but these could be truncated (usually)
-- 
-- 
-- Main difference from cleanup script, provided by BluePrism, is this:
-- - Does not lock out table (if deleting huge ammount of rows)
-- - Can be executed on active database
-- - Can be executed in small batches
-- - Can be executed on huge tables (tested with >200GB)
-- - Downside: it's not super fast.
--
-- How to/before executing. Set values to:
-- @beforedate - date to delete logs (up to, but not included). Format: YYYYMMDD HH:mm:ss.SSS
-- @maxloops - how many update loops to perform
-- @rowcount - how many rows to delete in one loop
--
-- To calculate ammount of rows deleted, multiplicate @maxloops with @rowcount (e.g. 100 * 100 = 10K rows will be deleted)
-- 
--
DECLARE @loopno INT = 0;
-- Define total loop count
DECLARE @maxloops INT = 10;
-- Ammount of rows to delete in one loop
DECLARE @rowcount INT = 10000;
-- Define log age (format YYYYMMDD). Logs older than this day will be deleted
DECLARE @beforedate DATETIME = CAST('20190713 00:00:00.000' AS DATETIME);
 
-- Using loop to minimize impact on database
WHILE @loopno < @maxloops
BEGIN
   PRINT 'loop ' + CAST(@loopno AS VARCHAR);
   DELETE TOP (@rowcount)  FROM [DATABASE_NAME].[dbo].[BPASessionLog_Unicode] WHERE startdatetime < @beforedate
   SET @loopno = @loopno + 1;
-- Stop looping if row count in 0. Not sure if this works properly.
   /*IF (@@ROWCOUNT < 1)
       BREAK;*/
        
END;
PRINT 'Done deleting';
GO
