  /* **************************************************************************************** */
  -- DDL
  /* **************************************************************************************** */
-- 테이블 생성
CREATE TABLE ITEMID (

 CORPID INT NOT NULL,
 INVORG CHAR(2) NOT NULL,
 ITEMNM NVARCHAR(128),
 ADDEMP NVARCHAR(17),
 ADDTIM DATETIME,
 LOGEMP NVARCHAR(17),
 LOGTIM DATETIME
)

-- 테이블 삭제
DROP TABLE ITEMID

-- 테이블 수정
-- 1. 테이블 컬럼 수정
ALTER TABLE ITEMID
ALTER COLUMN LOGTIM DATE NULL -- 새로 컬럼 타입 정의

-- 2. 테이블 컬럼 추가
ALTER TABLE ITEMID
ADD ITEMGRP NVARCHAR(20) NULL -- 기존 테이블 ROW는 NULL값이 되기 때문에 NOT NULL로 선언 불가(오류 발생)

-- 3. 테이블 컬럼 삭제
ALTER TABLE ITEMID
DROP COLUMN ITEMGRP 

-- 테이블 변경 사항 확인
SP_HELP ITEMID

  /* **************************************************************************************** */
  -- DML
  /* **************************************************************************************** */

--  데이터 조회
SELECT * FROM ITEMID

--  데이터 삽입
INSERT INTO ITEMID 
VALUES ( 0
, '20'
, N'itemA'
, N'JYJ'
, GETDATE()
,''
,''
)

-- 데이터 수정
UPDATE ITEMID
   SET LOGTIM = NULL -- 날짜 데이터 형식에 1900-01-01 00:00:00.000 값이 들어가지 않으려면 INSERT시 NULL로 설정함
 WHERE CORPID = 0

 -- 데이터 삭제
 DELETE ITEMID -- 테이블 삭제는 DROP TABLE 테이블명, 데이터 삭제는 DELETE
  WHERE CORPID = 0

  /* **************************************************************************************** */
  -- 반복문
  /* **************************************************************************************** */
 SET NOCOUNT ON -- (1개 행이 적용됨) 출력되지 않도록 설정(빠른 실행 처리)
 DECLARE @NUM INT  --반복문에 사용될 변수 선언
 SET @NUM = 0 -- 기본값 설정
 -- 한줄로 작성
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
	
	-- 변수값 증가
	SET @NUM = @NUM + 1
  END

  
   /* **************************************************************************************** */
  -- 조건문
  /* **************************************************************************************** */
--  IF .. ELSE (BEGIN...END)
IF DATENAME(WEEKDAY, GETDATE()) IN (N'Saturday', N'Sunday')
	SELECT N'주말'
ELSE
	SELECT N'주중'
	
  -- IF-ELSE 분기 루틴에서 2개 이상의 처리 구문이 들어가면 반드시 BEGIN-END로 블록을 지정해 단위별로 수행해야함
  -- BEGIN-END로 묶지 않으면, 에러 또는 첫 구문만 실행됨

-- CASE WHEN .. THEN ..END
-- 1. 대소비교 (CASE WHEN 컬럼명 <,> 값)
SELECT  CORPID
		, "우선순위" = CASE  
				   WHEN CORPID < 5 THEN N'우선순위1'
				   WHEN CORPID < 8 THEN N'우선순위2'
		ELSE N'우선순위3'-- ELSE는 THEN을 쓰지 않는다.
		END
FROM ITEMID

-- 2. 등가비교 (CASE 컬럼명 WHEN 값)
SELECT  CORPID
		, "우선순위" = CASE CORPID
				   WHEN 5 THEN N'우선순위1'
				   WHEN 8 THEN N'우선순위2'
		ELSE N'우선순위3'
		END
FROM ITEMID

/* **************************************************************************************** */
  -- TOP, RANK, ROW_NUMBER, 계층/역계층 조회
  /* **************************************************************************************** */
  -- TOP N 컬럼명
  SELECT TOP 3 CORPID -- 해당 컬럼만 조회됨
    FROM ITEMID 
ORDER BY CORPID

 SELECT TOP 5 * -- 모든 컬럼 조회
  FROM ITEMID
 ORDER BY CORPID

-- RANK = 중복값 만큼 건너뛴 순위 
  SELECT CORPID, INVORG, ITEMNM
	   , RANK() OVER (ORDER BY CORPID DESC) AS RANK등수 -- DENSE_RANK()중복값 이후 순차적 순위 
    FROM ITEMID
 
-- ROW_NUMBER = 행 일련번호(중복X)
SELECT CORPID, INVORG, ITEMNM
	 , ROW_NUMBER() OVER(ORDER BY CORPID DESC) AS ROW_NUMBER등수
  FROM ITEMID

 -- PARTITION BY = 그룹별 등수, ORDER BY = 모든 행 기준 => 둘다 같이 쓸수 있음
 SELECT CORPID, INVORG, ITEMNM
	 , ROW_NUMBER() OVER(PARTITION BY CORPID ORDER BY CORPID DESC) AS ROW_NUMBER등수
  FROM ITEMID

SELECT *
  FROM (
   SELECT CORPID, INVORG, ITEMNM
	 , ROW_NUMBER() OVER(ORDER BY CORPID DESC) AS RN
  FROM ITEMID
				) AS A -- MSSQL은 인라인뷰는 무조건 AS 별칭이 작성되어야함
WHERE RN < 6

-- 계층조회
--SELECT *
--  FROM ITEMID
--START WITH GROUPID = 1
--CONNECT BY PRIOR CORPID = GROUPID -- START WITCH, CONNECT BY는 오라클 전용 함수!

-- MSSQL은 WITH, UNTION ALL로 재귀 CRE를 사용
WITH CTE AS (			-- WITH은 임시 가상 테이블 키워드
    -- 루트 노드 (부모)
    SELECT CORPID, GROUPID
    FROM ITEMID
    WHERE GROUPID = 1
    
    UNION ALL -- UNION은 중복 제거, UNION ALL은 중복 포함 합집합
    
    -- 재귀적으로 자식 찾기
    SELECT C.CORPID, C.GROUPID
    FROM ITEMID C
    INNER JOIN CTE P				-- CTE를 참조하면서 CONNECT BY PRIOR 역할을 대신함
        ON C.GROUPID = P.CORPID   -- (PRIOR 자식 = 부모 조건에 해당)
)
SELECT *
FROM CTE

 /* **************************************************************************************** */
  -- 그룹화
  /* **************************************************************************************** */
SELECT COUNT(CORPID), GROUPID -- COUNT, MAX, MIN, AVG 등 집계 함수와 그룹화 대상 컬럼만 작성가능
  FROM ITEMID
 GROUP BY GROUPID
 HAVING COUNT(CORPID) > 1

 /* **************************************************************************************** */
  -- 프로시저 생성
  /* **************************************************************************************** */
  CREATE PROCEDURE SP_SELPRO
	  (
		@CORPID INT = -1		 -- 매개변수 선언시 기본값을 선언해줘야 프로시저 호출시 오류 발생X
		, @INVORG CHAR(2) = ''
		, @ITEMNM NVARCHAR(128) = N''
		, @ADDEMP NVARCHAR(17) = N''
		, @ADDTIM DATETIME = NULL -- 날짜 타입의 기본값은 ''는 변환 에러 발생 가능함 => NULL로 처리
		, @LOGEMP NVARCHAR(17) = N''
		, @LOGTIM DATETIME = NULL
								)
-- WITH ENCRYPTION				-- 암호화
AS
--DECLARE

SELECT * FROM ITEMID	--BEGIN ... END 여러 개의 실행은 묶어서 작성
WHERE CORPID = @CORPID	AND INVORG = @INVORG -- 파라미터 값과 일치하는 데이터가 조회됨(파라미터은 필수값이 됨)
  AND (ISNULL(@ITEMNM, N'') = N'') OR ITEMNM = @ITEMNM -- 필수값이 아니려면 ISNULL을 이용해서 NULL 값도 허용하는 OR조건을 추가
  AND (@ADDTIM IS NULL OR ADDTIM = @ADDTIM) -- DATETIME은 N''과 비교하면 암묵적 형변환 오류 가능해서 IS NULL로 비교함
-- 프로시저 실행
--EXEC SP_SELPRO
EXEC SP_SELPRO @CORPID = 1, @INVORG = 10

-- 프로시저 삭제
DROP PROCEDURE SP_SELPRO 