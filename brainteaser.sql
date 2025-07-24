/*
This exercise analyses the data quality of BadMessage table, that  contains list of messages.
*/
SELECT
    bm.MessageId
    , bm.ReceivedDate
    , bm.Region
    , bm.Category
    , bm.Movement
FROM
    BadMessage bm
ORDER BY
    bm.MessageId;
 
/*
We have been told that the MessageId column has unique and contiguous values  
i.e. there are no dupicates and no missing values (so no gaps in the sequence of MessageId values).
 
Task 1:  Let's check for duplicates in the MessageId column. If there are duplicates,
(1) list the duplicate MessageId values and the number of times they are duplicated
(2) list (all columns of) the duplicated rows
 
*/
SELECT
    bm.MessageId
    ,COUNT(*) AS DuplicateCount
FROM
    BadMessage bm
GROUP BY bm.MessageId
HAVING COUNT(*) > 1;




SELECT *
FROM BadMessage
WHERE MessageId IN
                    (SELECT
                    bm.MessageId
                    FROM
                    BadMessage bm
                    GROUP BY bm.MessageId
                    HAVING COUNT(*) > 1
                    ) 
ORDER BY MessageID


--CTE alternative
WITH d AS
    (
    SELECT
            bm.MessageId
        ,COUNT(*) AS DuplicateCount
        FROM
            BadMessage bm
        GROUP BY bm.MessageId
        HAVING COUNT(*) > 1
    )
SELECT
    *
FROM
    BadMessage bm
WHERE bm.MessageId IN (SELECT  MessageId FROM d)
ORDER BY bm.MessageId;


--what are the missing message IDs
SELECT
    *
FROM(
SELECT
        *
    FROM
        Tally
    WHERE N <= (SELECT
        max(MessageId)
    FROM
        BadMessage)) t
    LEFT JOIN BadMessage bm
    ON t.N = bm.MessageId
WHERE bm.MessageId IS NULL
ORDER BY t.N;
 
 