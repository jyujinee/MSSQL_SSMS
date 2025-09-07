/* 저장 프로시저 분기 처리 */
CREATE PROCEDURE [dbo].[SP_CRUDPRO]
	  (	 @OPTION CHAR(2) = ''	 -- 분기처리를 위한 옵션 매개변수
		, @CORPID INT = -1		 -- 매개변수 선언시 기본값을 선언해줘야 프로시저 호출시 오류 발생X
		, @INVORG CHAR(2) = ''
		, @ITEMNM NVARCHAR(128) = N''
		, @ADDEMP NVARCHAR(17) = N''
		, @ADDTIM DATETIME = NULL -- 날짜 타입의 기본값은 ''는 변환 에러 발생 가능함 => NULL로 처리
		, @LOGEMP NVARCHAR(17) = N''
		, @LOGTIM DATETIME = NULL
								)
-- WITH ENCRYPTION				-- 암호화
AS

/* 지역변수 선언 */
SET NOCOUNT ON
DECLARE @ERROR INT -- 에러코드
	  , @ERRDS NVARCHAR(128) -- 에러메시지

/* 분기 옵션 */
IF @OPTION = 'RE' GOTO SELECT_RTN
ELSE IF @OPTION = 'AD' GOTO INSERT_RTN
ELSE IF @OPTION = 'UP' GOTO UPDATE_RTN
ELSE GOTO DELETE_RTN

/* ******************************************************************************************************** */
SELECT_RTN:

SELECT * FROM ITEMID	--BEGIN ... END 여러 개의 실행은 묶어서 작성
WHERE CORPID = @CORPID	AND INVORG = @INVORG -- 파라미터 값과 일치하는 데이터가 조회됨(파라미터은 필수값이 됨)
  AND (ISNULL(@ITEMNM, N'') = N'') OR ITEMNM = @ITEMNM -- 필수값이 아니려면 ISNULL을 이용해서 NULL 값도 허용하는 OR조건을 추가
  AND (@ADDTIM IS NULL OR ADDTIM = @ADDTIM) -- DATETIME은 N''과 비교하면 암묵적 형변환 오류 가능해서 IS NULL로 비교함

RETURN -- SELECT는 RETURN으로 프로시저 종료
/* ******************************************************************************************************** */
INSERT_RTN:
BEGIN
PRINT 'INSERT_RTN 실행'
INSERT INTO ITEMID
VALUES ( @CORPID
		, @INVORG
		, @ITEMNM
		, @ADDEMP
		, GETDATE()
		, ''
		, NULL
		, 1
				)
	IF @ERROR <> 0 OR @@ROWCOUNT != 1 -- @@ROWCOUNT는 SQL SERVER가 제공하는 변수, 최근에 실행된 SQL문이 영향을 준 ROW의 개수를 반환
	GOTO abNormal_end -- 이 DML문에 GOTO를 작성하지 않으면 에러 확인 불가, EXEC는 파일의 처음부터 끝까지 실행되기 때문에 필요함(밑에 블록이 계속 실행됨)

	GOTO Normal_end
END
/* ******************************************************************************************************** */
UPDATE_RTN:
BEGIN
	PRINT 'UPDATE_RTN 실행'
	UPDATE ITEMID
	   SET ITEMNM = @ITEMNM
	 WHERE CORPID = @CORPID AND INVORG = @INVORG 

	 IF @ERROR <> 0 AND @@ROWCOUNT != 1
	 GOTO abNormal_end

	 GOTO Normal_end
END
/* ******************************************************************************************************** */
DELETE_RTN:
BEGIN
	PRINT 'DELETE_RTN 실행'
	DELETE ITEMID
	 WHERE CORPID = @CORPID AND INVORG = @INVORG
	   AND ADDEMP = @ADDEMP

	IF @ERROR <> 0 AND @@ROWCOUNT != 1
	GOTO abNormal_end

	GOTO Normal_end
END
/* ******************************************************************************************************** */
Normal_end:
BEGIN
    -- 정상종료 시 에러코드는 0, 에러메시지는 빈 메시지를 조회
    SELECT @ERROR = 0, @ERRDS = N''
    SELECT @ERROR AS ERROR, @ERRDS AS ERRDS
    RETURN
END
/* ******************************************************************************************************** */
abNormal_end:
BEGIN
    -- 비정상 종료 시 에러코드와 에러메시지는 NULL값
	-- 에러코드는 -1, 에러메시지는 '알 수 없는 오류'로 조회됨
    IF ISNULL(@ERROR, 0) = 0   
        SELECT @ERROR = -1, @ERRDS = ISNULL(@ERRDS, N'알 수 없는 오류')

    SELECT @ERROR AS ERROR, @ERRDS AS ERRDS
    RETURN
END
/* ******************************************************************************************************** */
--DROP PROCEDURE SP_CRUDPRO
EXEC SP_CRUDPRO @OPTION='RE', @CORPID = 0, @INVORG = 10 -- 조회
EXEC SP_CRUDPRO @OPTION='AD', @CORPID = 11, @INVORG = 21, @ADDEMP = N'ABB' -- 등록
EXEC SP_CRUDPRO @OPTION='UP',@CORPID = 11, @INVORG = 21, @ADDEMP = N'ABB', @ITEMNM =N'수정된 아이템' -- 수정
EXEC SP_CRUDPRO @OPTION='DE', @CORPID = 11, @INVORG = 21, @ADDEMP = N'' -- 삭제
SELECT * FROM ITEMID