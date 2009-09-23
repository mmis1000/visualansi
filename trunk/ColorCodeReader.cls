VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "ColorCodeReader"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Private tmpCCStr As String 'Temp Color Code String
Private tmpCLA() As ColorLayer
Private tmpVArr() As Variant
Private Ba_CLA() As ColorLayer


Public Property Get SetCCStr() As Variant
    SetCCStr = tmpCCStr
End Property

Public Property Let SetCCStr(ByVal vNewValue As Variant)
    tmpCCStr = vNewValue
    
End Property

Public Sub AnalyzeCC()
On Error GoTo out
'�D�}�CtmpVArr(�����)(�Ϭq����,0 or 1) 0�s��X�}�C 1�s�r��
'�ŧi�ܼ�
    Dim tmpStrLA() As String    '�x�s�C��
    Dim tmpstrA() As String     '�x�s�U�өR�O�Ϭq
    Dim tmpStrA1() As String    '�x�s0�R�O1�r��
    Dim tmpInt As Integer       '�º�
    Dim IntCounter As Integer
    Dim tmpIntCounter As Integer
    Dim tmpbyte As Byte
    Dim tmpStr As String * 1
'�Ĥ@���q�إ�STR�D�}�C
    tmpStrLA = Split(tmpCCStr, vbCrLf) '�N����}
    tmpInt = UBound(tmpStrLA)   'tmpint�����-1
    ReDim tmpVArr(tmpInt)    '�إߥD�}�C
    For i = 0 To tmpInt
        If tmpStrLA(i) <> "" Then
            tmpstrA = Split(tmpStrLA(i), "[")  '���O�Ϭq����
            ReDim tmpStrA1(UBound(tmpstrA), 1)  '�ĤG���� 0�s��X�}�C 1�s�r��
            tmpIntCounter = 0  '�N�p��r�ƪ�counter�k�s
            For j = 0 To UBound(tmpstrA)
                tmpInt = InStr(tmpstrA(j), "m")
                If tmpInt <> 0 Then
                    tmpStrA1(j, 0) = Replace(Left(tmpstrA(j), tmpInt - 1), " ", "") '�D���X��m�X �åh���Ҧ��ť�
                End If
                tmpStrA1(j, 1) = Right(tmpstrA(j), Len(tmpstrA(j)) - tmpInt)    '�D���XANSI�r�곡��
                tmpIntCounter = tmpIntCounter + Tlen(tmpStrA1(j, 1))    '�N�r�Ʋ֭p��COUNTER��
                tmpVArr(i) = tmpStrA1   '�N���椧�}�C��J�D�}�C
                
            Next j
        Else
            ReDim tmpStrA1(0, 1)
            tmpVArr(i) = tmpStrA1
        End If
        If tmpIntCounter > IntCounter Then IntCounter = tmpIntCounter   '�p�G����r�ƪ�����h�N�]�w�e��������
    Next i
    If IntCounter = 0 Then
        Debug.Print "error �פJ�m��X�K�W���e�׬O0  "
        Exit Sub
    End If
'�ĤG���q�NSTR�}�C�s��COLOR LAYER ARRAY
    Dim tmpStrA3() As String '���R��X���Ȧs�e��
    Dim tmpCountPerLine As Integer  '�椤�r�ƫ���(tlen)
    Dim tmpCL As ColorLayer
    Dim tmpCLbyte(2) As Byte
    If IntCounter = 0 Then Debug.Print "���~: �e�פ��i���s"
    ReDim tmpCLA(IntCounter - 1, UBound(tmpVArr)) '�إ�COLOR LAYER�}�C
    Debug.Print "�̼e�e��: " & IntCounter
    tmpCL.BColor = 0
    tmpCL.Color = 7
    For i = 0 To UBound(tmpVArr)
        tmpCountPerLine = 1 '�N�����k�s
        For j = 0 To UBound(tmpVArr(i), 1)
            'Debug.Print "Line:" & i; " ;Section: " & j & ";Len=" & Tlen(tmpVArr(i)(j, 1)) & "Pos:" & tmpCountPerLine
            If tmpVArr(i)(j, 0) = "" And j <> 0 Then
                '��m�����٭쬰�w�]��
                tmpCL.BColor = 0
                tmpCL.Color = 7
            Else
                tmpStrA3 = Split(tmpVArr(i)(j, 0), ";") '�N�U��X����
                If UBound(tmpStrA3) = 0 Then
                '����X�u���@�Ӯ�
                    tmpbyte = Val(tmpStrA3(0))
                    Select Case tmpbyte
                        Case 1
                            If tmpCL.Color \ 8 = 0 Then tmpCL.Color = tmpCL.Color + 8
                        Case Is >= 40
                            tmpCL.BColor = GetBC(tmpbyte)
                        Case Is >= 30
                            tmpCL.Color = GetFC(tmpbyte) + (tmpCL.Color \ 8) * 8
                    End Select
                Else
                    'Debug.Print "�h��X:" & UBound(tmpStrA3)
                    tmpCLbyte(0) = 0
                    tmpCLbyte(1) = 255
                    tmpCLbyte(2) = 255
                    For k = 0 To UBound(tmpStrA3)
                    '���B�z��m
                        tmpbyte = Val(tmpStrA3(k))
                        '�]�w�Ȧs���Ȧs�w�] 255���Ʀr�u�O���F��0�@���S���ܧ󪺤��G��

                        Select Case tmpbyte
                            '�٭��m�Ȧs���w�]
                            Case 0
                                tmpCL.BColor = 0
                                tmpCL.Color = 7
                                'Debug.Print "�Ȧs��m�٭�w�]"
                            '�B���m�Ȧs���Ȧs �Ω���
                            Case Is = 1
                                tmpCLbyte(0) = 8
                            Case Is >= 40
                                tmpCLbyte(2) = GetBC(tmpbyte)
                            Case Is >= 30
                                tmpCLbyte(1) = GetFC(tmpbyte)
                        End Select
                    Next k
                    '�q(��m�Ȧs���Ȧs)�g�J(��m�Ȧs)
                    If tmpCLbyte(1) <> 255 Then
                        tmpCL.Color = tmpCLbyte(1) + (tmpCL.Color \ 8) * 8
                    End If
                    If tmpCLbyte(0) <> 0 And tmpCL.Color \ 8 = 0 Then
                        tmpCL.Color = tmpCL.Color + tmpCLbyte(0)
                        'Debug.Print "�G��"
                    End If
                    If tmpCLbyte(2) <> 255 Then
                        tmpCL.BColor = tmpCLbyte(2)
                    End If
                    
                End If

            End If
                    '�A�g�J��r
                    If tmpVArr(i)(j, 1) <> "" Then
                        For L = 1 To Len(tmpVArr(i)(j, 1))
                            tmpStr = Mid(tmpVArr(i)(j, 1), L, 1)
                            'Debug.Print "Line:" & i; " ;section: " & j & ";�r��:" & tmpCountPerLine - 1
                            tmpCLA(tmpCountPerLine - 1, i).Ansi = Asc(tmpStr)
                            tmpCLA(tmpCountPerLine - 1, i).Color = tmpCL.Color
                            tmpCLA(tmpCountPerLine - 1, i).BColor = tmpCL.BColor
                            tmpbyte = Tlen(tmpStr)
                            If tmpbyte = 2 Then
                                tmpCLA(tmpCountPerLine, i).Ansi = -1
                                tmpCLA(tmpCountPerLine, i).Color = tmpCL.Color
                                tmpCLA(tmpCountPerLine, i).BColor = tmpCL.BColor
                            End If
                            tmpCountPerLine = tmpCountPerLine + tmpbyte
                            '��CPU�ݮ��@�U
                            DoEvents
                        Next L
                    End If
        Next j
    Next i
Exit Sub
out:
    Debug.Print "AnalyzeCC Error Out : " & Err.Description
End Sub



Public Function GetFC(ByVal inFCC As Byte) As Byte
    'FCC (FORE COLOR CODE)
    '�w�q1;37 => 137
    Dim tmpbyte  As Byte
    
    Select Case inFCC Mod 100
        Case Is = 30
            tmpbyte = 0
        Case Is = 31
            tmpbyte = 4
        Case Is = 32
            tmpbyte = 2
        Case Is = 33
            tmpbyte = 6
        Case Is = 34
            tmpbyte = 1
        Case Is = 35
            tmpbyte = 5
        Case Is = 36
            tmpbyte = 3
        Case Is = 37
            tmpbyte = 7
        Case Else
            Debug.Print "SetFC �L�k���Ѩӷ�"
    End Select
    '�B�z�G��
    If inFCC > 100 Then
        tmpbyte = tmpbyte + 8
    End If
    '�^��
    GetFC = tmpbyte
    
End Function
Public Function GetBC(ByVal inBCC As Byte) As Byte
    'BCC (BACK COLOR CODE)

    Dim tmpbyte  As Byte
    
    Select Case inBCC
        Case Is = 40
            tmpbyte = 0
        Case Is = 41
            tmpbyte = 4
        Case Is = 42
            tmpbyte = 2
        Case Is = 43
            tmpbyte = 6
        Case Is = 44
            tmpbyte = 1
        Case Is = 45
            tmpbyte = 5
        Case Is = 46
            tmpbyte = 3
        Case Is = 47
            tmpbyte = 7
        Case Else
            Debug.Print "GETBC �L�k���Ѩӷ�"
    End Select

    '�^��
    GetBC = tmpbyte
    
End Function

Public Sub Post2Arrf(ByVal X As Integer, ByVal Y As Integer, Optional ByVal deBack As Byte)
    '��O�O�_�n�h�I
    If deBack = 1 Then
        Call CLArrayPaste_C(tmpCLA, Arrf, X, Y, OFP.CurrentPage)
    Else
        Call ObjLibPo(tmpCLA, Arrf, X, Y)
    End If
End Sub

Public Function AnalyzeCC_ByteArray(ByVal X As Integer, ByVal Y As Integer, ByVal maxX As Integer, ByVal maxY As Integer, Optional ByVal toClpB As Byte)
    'Ū���ŶKï���}�C�i����R
    Dim CCMode As Byte  '0 �@��
    Dim tmpStr As String '�r��Ȧs��
    Dim tmpInt As Integer
    Dim i As Long
    Dim Pointer_X As Integer, Pointer_Y As Integer, cutX As Integer, cutY As Integer
    Dim tmpbiByte(1) As Byte, biByteFlag As Byte, preFC_Byte As Byte, preBC_Byte As Byte, FC_Byte As Byte, BC_Byte As Byte, rawFClight_Byte As Byte, rawFC_Byte As Byte, rawBC_Byte As Byte
    Dim colorResetFlag As Byte
    Dim tmpint2 As Integer
    ReDim Ba_CLA(maxX, maxY)
    FC_Byte = 7
    BC_Byte = 0
    For i = 0 To UBound(ByteArray)
        If CCMode = 0 Then
            If ByteArray(i) = 0 Then
                Exit For
            ElseIf ByteArray(i) = 27 Then   '�m��X�{��
                If ByteArray(i + 1) = 91 Then   '�T�w�m��X��{�r���ᬰ"["�N�i�J�Ҧ�1
                    i = i + 1
                    CCMode = 1
                End If
            ElseIf ByteArray(i) = 10 Then   '\n ����
                If Pointer_Y < maxY Then
                    Pointer_X = 0
                    Pointer_Y = Pointer_Y + 1
                End If
                biByteFlag = 0
            ElseIf biByteFlag = 1 Then
                If Pointer_X < maxX Then
                    tmpbiByte(0) = ByteArray(i)
                    Call CopyMemory(tmpInt, tmpbiByte(0), 2)
                    Ba_CLA(Pointer_X, Pointer_Y).Ansi = tmpInt
                    Ba_CLA(Pointer_X, Pointer_Y).Color = preFC_Byte
                    Ba_CLA(Pointer_X, Pointer_Y).BColor = preBC_Byte
                    Ba_CLA(Pointer_X + 1, Pointer_Y).Ansi = -1
                    Ba_CLA(Pointer_X + 1, Pointer_Y).Color = FC_Byte
                    Ba_CLA(Pointer_X + 1, Pointer_Y).BColor = BC_Byte
                    If cutX < Pointer_X + 1 Then cutX = Pointer_X + 1 '���̤j��x
                    Pointer_X = Pointer_X + 2
                End If
                biByteFlag = 0
            ElseIf (ByteArray(i) >= 32 And ByteArray(i) <= 127) Then
                If Pointer_X < maxX Then
                    Ba_CLA(Pointer_X, Pointer_Y).Ansi = ByteArray(i)
                    Ba_CLA(Pointer_X, Pointer_Y).Color = FC_Byte
                    Ba_CLA(Pointer_X, Pointer_Y).BColor = BC_Byte
                    If cutX < Pointer_X Then cutX = Pointer_X   '���̤j��x
                    Pointer_X = Pointer_X + 1
                End If
            

            ElseIf ByteArray(i) >= 128 Then '���줸�r
                If Pointer_X < maxX Then
                    tmpbiByte(1) = ByteArray(i)
                    preFC_Byte = FC_Byte
                    preBC_Byte = BC_Byte
                    biByteFlag = 1
                End If

            End If
            
        
        ElseIf CCMode = 1 Then
            '�^���m��X
            If ByteArray(i) >= 48 And ByteArray(i) <= 57 Then   '0~9
                tmpStr = tmpStr & Chr(ByteArray(i))
            ElseIf ByteArray(i) = 59 Then   ';
                tmpint2 = Val(tmpStr)
                tmpStr = ""
                If tmpint2 = 0 Then
                    colorResetFlag = 1
                ElseIf tmpint2 = 1 Then
                    rawFClight_Byte = 1
                ElseIf tmpint2 >= 40 And tmpint2 <= 48 Then
                    rawBC_Byte = tmpint2
                ElseIf tmpint2 >= 30 And tmpint2 <= 38 Then
                    rawFC_Byte = tmpint2
                End If
            ElseIf ByteArray(i) = 77 Or ByteArray(i) = 109 Then 'M or m
                tmpint2 = Val(tmpStr)
                tmpStr = ""
                If tmpint2 = 0 Then
                    colorResetFlag = 1
                ElseIf tmpint2 = 1 Then
                    rawFClight_Byte = 1
                ElseIf tmpint2 >= 40 And tmpint2 <= 48 Then
                    rawBC_Byte = tmpint2
                ElseIf tmpint2 >= 30 And tmpint2 <= 38 Then
                    rawFC_Byte = tmpint2
                End If
                If colorResetFlag = 1 Then  '��l�Ʀ�m
                    FC_Byte = 7
                    BC_Byte = 0
                    colorResetFlag = 0  '�٭즹�аO
                End If
                If rawFC_Byte = 0 Then  '�B�z�e����m
                    If rawFClight_Byte <> 0 Then
                        FC_Byte = (FC_Byte Mod 8) + 8
                        rawFClight_Byte = 0  '�٭�
                    End If
                Else
                    If rawFClight_Byte = 0 Then
                        If (FC_Byte \ 8) = 1 Then   '�P�_���L�~�ӫG��
                            FC_Byte = GetFC(rawFC_Byte) + 8
                        Else
                            FC_Byte = GetFC(rawFC_Byte)
                        End If
                    Else
                        FC_Byte = GetFC(rawFC_Byte) + 8
                        rawFClight_Byte = 0 '�٭�
                    End If
                    rawFC_Byte = 0  '�٭�
                End If
                If rawBC_Byte <> 0 Then
                    BC_Byte = GetBC(rawBC_Byte)
                    rawBC_Byte = 0
                End If
                CCMode = 0
            End If
            
        'ElseIf CCMode = 2 Then
            
        End If

    Next i
    'ReDim Preserve Ba_CLA(0 To cutX, 0 To Pointer_Y) As ColorLayer
    If toClpB = 1 Then
        ReDim CPArr(cutX, Pointer_Y)
        For j = 0 To Pointer_Y
            For i = 0 To cutX
                CPArr(i, j) = Ba_CLA(i, j)
            Next i
        Next j
    Else
        Call ObjLibPo_Area(Ba_CLA, Arrf, X, Y, cutX, Pointer_Y)
    End If
    ReDim Ba_CLA(0)
End Function