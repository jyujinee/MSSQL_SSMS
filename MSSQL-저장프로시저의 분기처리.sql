/* ���� ���ν��� �б� ó�� */
CREATE PROCEDURE [dbo].[SP_CRUDPRO]
	  (	 @OPTION CHAR(2) = ''	 -- �б�ó���� ���� �ɼ� �Ű�����
		, @CORPID INT = -1		 -- �Ű����� ����� �⺻���� ��������� ���ν��� ȣ��� ���� �߻�X
		, @INVORG CHAR(2) = ''
		, @ITEMNM NVARCHAR(128) = N''
		, @ADDEMP NVARCHAR(17) = N''
		, @ADDTIM DATETIME = NULL -- ��¥ Ÿ���� �⺻���� ''�� ��ȯ ���� �߻� ������ => NULL�� ó��
		, @LOGEMP NVARCHAR(17) = N''
		, @LOGTIM DATETIME = NULL
								)
-- WITH ENCRYPTION				-- ��ȣȭ
AS

/* �������� ���� */
SET NOCOUNT ON
DECLARE @ERROR INT -- �����ڵ�
	  , @ERRDS NVARCHAR(128) -- �����޽���

/* �б� �ɼ� */
IF @OPTION = 'RE' GOTO SELECT_RTN
ELSE IF @OPTION = 'AD' GOTO INSERT_RTN
ELSE IF @OPTION = 'UP' GOTO UPDATE_RTN
ELSE GOTO DELETE_RTN

/* ******************************************************************************************************** */
SELECT_RTN:

SELECT * FROM ITEMID	--BEGIN ... END ���� ���� ������ ��� �ۼ�
WHERE CORPID = @CORPID	AND INVORG = @INVORG -- �Ķ���� ���� ��ġ�ϴ� �����Ͱ� ��ȸ��(�Ķ������ �ʼ����� ��)
  AND (ISNULL(@ITEMNM, N'') = N'') OR ITEMNM = @ITEMNM -- �ʼ����� �ƴϷ��� ISNULL�� �̿��ؼ� NULL ���� ����ϴ� OR������ �߰�
  AND (@ADDTIM IS NULL OR ADDTIM = @ADDTIM) -- DATETIME�� N''�� ���ϸ� �Ϲ��� ����ȯ ���� �����ؼ� IS NULL�� ����

RETURN -- SELECT�� RETURN���� ���ν��� ����
/* ******************************************************************************************************** */
INSERT_RTN:
BEGIN
PRINT 'INSERT_RTN ����'
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
	IF @ERROR <> 0 OR @@ROWCOUNT != 1 -- @@ROWCOUNT�� SQL SERVER�� �����ϴ� ����, �ֱٿ� ����� SQL���� ������ �� ROW�� ������ ��ȯ
	GOTO abNormal_end -- �� DML���� GOTO�� �ۼ����� ������ ���� Ȯ�� �Ұ�, EXEC�� ������ ó������ ������ ����Ǳ� ������ �ʿ���(�ؿ� ����� ��� �����)

	GOTO Normal_end
END
/* ******************************************************************************************************** */
UPDATE_RTN:
BEGIN
	PRINT 'UPDATE_RTN ����'
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
	PRINT 'DELETE_RTN ����'
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
    -- �������� �� �����ڵ�� 0, �����޽����� �� �޽����� ��ȸ
    SELECT @ERROR = 0, @ERRDS = N''
    SELECT @ERROR AS ERROR, @ERRDS AS ERRDS
    RETURN
END
/* ******************************************************************************************************** */
abNormal_end:
BEGIN
    -- ������ ���� �� �����ڵ�� �����޽����� NULL��
	-- �����ڵ�� -1, �����޽����� '�� �� ���� ����'�� ��ȸ��
    IF ISNULL(@ERROR, 0) = 0   
        SELECT @ERROR = -1, @ERRDS = ISNULL(@ERRDS, N'�� �� ���� ����')

    SELECT @ERROR AS ERROR, @ERRDS AS ERRDS
    RETURN
END
/* ******************************************************************************************************** */
--DROP PROCEDURE SP_CRUDPRO
EXEC SP_CRUDPRO @OPTION='RE', @CORPID = 0, @INVORG = 10 -- ��ȸ
EXEC SP_CRUDPRO @OPTION='AD', @CORPID = 11, @INVORG = 21, @ADDEMP = N'ABB' -- ���
EXEC SP_CRUDPRO @OPTION='UP',@CORPID = 11, @INVORG = 21, @ADDEMP = N'ABB', @ITEMNM =N'������ ������' -- ����
EXEC SP_CRUDPRO @OPTION='DE', @CORPID = 11, @INVORG = 21, @ADDEMP = N'' -- ����
SELECT * FROM ITEMID