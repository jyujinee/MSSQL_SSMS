  /* **************************************************************************************** */
  -- DDL
  /* **************************************************************************************** */
-- ���̺� ����
CREATE TABLE ITEMID (

 CORPID INT NOT NULL,
 INVORG CHAR(2) NOT NULL,
 ITEMNM NVARCHAR(128),
 ADDEMP NVARCHAR(17),
 ADDTIM DATETIME,
 LOGEMP NVARCHAR(17),
 LOGTIM DATETIME
)

-- ���̺� ����
DROP TABLE ITEMID

-- ���̺� ����
-- 1. ���̺� �÷� ����
ALTER TABLE ITEMID
ALTER COLUMN LOGTIM DATE NULL -- ���� �÷� Ÿ�� ����

-- 2. ���̺� �÷� �߰�
ALTER TABLE ITEMID
ADD ITEMGRP NVARCHAR(20) NULL -- ���� ���̺� ROW�� NULL���� �Ǳ� ������ NOT NULL�� ���� �Ұ�(���� �߻�)

-- 3. ���̺� �÷� ����
ALTER TABLE ITEMID
DROP COLUMN ITEMGRP 

-- ���̺� ���� ���� Ȯ��
SP_HELP ITEMID

  /* **************************************************************************************** */
  -- DML
  /* **************************************************************************************** */

--  ������ ��ȸ
SELECT * FROM ITEMID

--  ������ ����
INSERT INTO ITEMID 
VALUES ( 0
, '20'
, N'itemA'
, N'JYJ'
, GETDATE()
,''
,''
)

-- ������ ����
UPDATE ITEMID
   SET LOGTIM = NULL -- ��¥ ������ ���Ŀ� 1900-01-01 00:00:00.000 ���� ���� �������� INSERT�� NULL�� ������
 WHERE CORPID = 0

 -- ������ ����
 DELETE ITEMID -- ���̺� ������ DROP TABLE ���̺��, ������ ������ DELETE
  WHERE CORPID = 0

  /* **************************************************************************************** */
  -- �ݺ���
  /* **************************************************************************************** */
 SET NOCOUNT ON -- (1�� ���� �����) ��µ��� �ʵ��� ����(���� ���� ó��)
 DECLARE @NUM INT  --�ݺ����� ���� ���� ����
 SET @NUM = 0 -- �⺻�� ����
 -- ���ٷ� �ۼ�
 -- DECLARE @NUM INT = 0

  WHILE(@NUM < 10)
  BEGIN
   INSERT INTO ITEMID
   VALUES ( @NUM
			, '30'
			, N'itemB'
			, N'JYJ'
			, GETDATE()
			,''
			,''
			,3 )
	
	-- ������ ����
	SET @NUM = @NUM + 1
  END

  
   /* **************************************************************************************** */
  -- ���ǹ�
  /* **************************************************************************************** */
--  IF .. ELSE (BEGIN...END)
IF DATENAME(WEEKDAY, GETDATE()) IN (N'Saturday', N'Sunday')
	SELECT N'�ָ�'
ELSE
	SELECT N'����'
	
  -- IF-ELSE �б� ��ƾ���� 2�� �̻��� ó�� ������ ���� �ݵ�� BEGIN-END�� ����� ������ �������� �����ؾ���
  -- BEGIN-END�� ���� ������, ���� �Ǵ� ù ������ �����

-- CASE WHEN .. THEN ..END
-- 1. ��Һ� (CASE WHEN �÷��� <,> ��)
SELECT  CORPID
		, "�켱����" = CASE  
				   WHEN CORPID < 5 THEN N'�켱����1'
				   WHEN CORPID < 8 THEN N'�켱����2'
		ELSE N'�켱����3'-- ELSE�� THEN�� ���� �ʴ´�.
		END
FROM ITEMID

-- 2. ��� (CASE �÷��� WHEN ��)
SELECT  CORPID
		, "�켱����" = CASE CORPID
				   WHEN 5 THEN N'�켱����1'
				   WHEN 8 THEN N'�켱����2'
		ELSE N'�켱����3'
		END
FROM ITEMID

/* **************************************************************************************** */
  -- TOP, RANK, ROW_NUMBER, ����/������ ��ȸ
  /* **************************************************************************************** */
  -- TOP N �÷���
  SELECT TOP 3 CORPID -- �ش� �÷��� ��ȸ��
    FROM ITEMID 
ORDER BY CORPID

 SELECT TOP 5 * -- ��� �÷� ��ȸ
  FROM ITEMID
 ORDER BY CORPID

-- RANK = �ߺ��� ��ŭ �ǳʶ� ���� 
  SELECT CORPID, INVORG, ITEMNM
	   , RANK() OVER (ORDER BY CORPID DESC) AS RANK��� -- DENSE_RANK()�ߺ��� ���� ������ ���� 
    FROM ITEMID
 
-- ROW_NUMBER = �� �Ϸù�ȣ(�ߺ�X)
SELECT CORPID, INVORG, ITEMNM
	 , ROW_NUMBER() OVER(ORDER BY CORPID DESC) AS ROW_NUMBER���
  FROM ITEMID

 -- PARTITION BY = �׷캰 ���, ORDER BY = ��� �� ���� => �Ѵ� ���� ���� ����
 SELECT CORPID, INVORG, ITEMNM
	 , ROW_NUMBER() OVER(PARTITION BY CORPID ORDER BY CORPID DESC) AS ROW_NUMBER���
  FROM ITEMID

SELECT *
  FROM (
   SELECT CORPID, INVORG, ITEMNM
	 , ROW_NUMBER() OVER(ORDER BY CORPID DESC) AS RN
  FROM ITEMID
				) AS A -- MSSQL�� �ζ��κ�� ������ AS ��Ī�� �ۼ��Ǿ����
WHERE RN < 6

-- ������ȸ
--SELECT *
--  FROM ITEMID
--START WITH GROUPID = 1
--CONNECT BY PRIOR CORPID = GROUPID -- START WITCH, CONNECT BY�� ����Ŭ ���� �Լ�!

-- MSSQL�� WITH, UNTION ALL�� ��� CRE�� ���
WITH CTE AS (			-- WITH�� �ӽ� ���� ���̺� Ű����
    -- ��Ʈ ��� (�θ�)
    SELECT CORPID, GROUPID
    FROM ITEMID
    WHERE GROUPID = 1
    
    UNION ALL -- UNION�� �ߺ� ����, UNION ALL�� �ߺ� ���� ������
    
    -- ��������� �ڽ� ã��
    SELECT C.CORPID, C.GROUPID
    FROM ITEMID C
    INNER JOIN CTE P				-- CTE�� �����ϸ鼭 CONNECT BY PRIOR ������ �����
        ON C.GROUPID = P.CORPID   -- (PRIOR �ڽ� = �θ� ���ǿ� �ش�)
)
SELECT *
FROM CTE

 /* **************************************************************************************** */
  -- �׷�ȭ
  /* **************************************************************************************** */
SELECT COUNT(CORPID), GROUPID -- COUNT, MAX, MIN, AVG �� ���� �Լ��� �׷�ȭ ��� �÷��� �ۼ�����
  FROM ITEMID
 GROUP BY GROUPID
 HAVING COUNT(CORPID) > 1

 /* **************************************************************************************** */
  -- ���ν��� ����
  /* **************************************************************************************** */
  CREATE PROCEDURE SP_SELPRO
	  (
		@CORPID INT = -1		 -- �Ű����� ����� �⺻���� ��������� ���ν��� ȣ��� ���� �߻�X
		, @INVORG CHAR(2) = ''
		, @ITEMNM NVARCHAR(128) = N''
		, @ADDEMP NVARCHAR(17) = N''
		, @ADDTIM DATETIME = NULL -- ��¥ Ÿ���� �⺻���� ''�� ��ȯ ���� �߻� ������ => NULL�� ó��
		, @LOGEMP NVARCHAR(17) = N''
		, @LOGTIM DATETIME = NULL
								)
-- WITH ENCRYPTION				-- ��ȣȭ
AS
--DECLARE

SELECT * FROM ITEMID	--BEGIN ... END ���� ���� ������ ��� �ۼ�
WHERE CORPID = @CORPID	AND INVORG = @INVORG -- �Ķ���� ���� ��ġ�ϴ� �����Ͱ� ��ȸ��(�Ķ������ �ʼ����� ��)
  AND (ISNULL(@ITEMNM, N'') = N'') OR ITEMNM = @ITEMNM -- �ʼ����� �ƴϷ��� ISNULL�� �̿��ؼ� NULL ���� ����ϴ� OR������ �߰�
  AND (@ADDTIM IS NULL OR ADDTIM = @ADDTIM) -- DATETIME�� N''�� ���ϸ� �Ϲ��� ����ȯ ���� �����ؼ� IS NULL�� ����
-- ���ν��� ����
--EXEC SP_SELPRO
EXEC SP_SELPRO @CORPID = 1, @INVORG = 10

-- ���ν��� ����
DROP PROCEDURE SP_SELPRO 