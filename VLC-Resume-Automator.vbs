Option Explicit

Dim fso, WshShell, appData, vlcConfigPath
Dim stream, line, lastFileRaw, cleanPath, parentFolder, targetFileName
Dim folderObj, files, file, i, j, temp
Dim listaArquivos(), encontrouNaLista, playlistPath, playlistContent
Dim caminhoVLC

Set fso = CreateObject("Scripting.FileSystemObject")
Set WshShell = CreateObject("WScript.Shell")

' --- CONFIGURAÇÃO ---
' Como você confirmou o caminho, vamos travar ele aqui com aspas triplas para segurança
caminhoVLC = "C:\Program Files\VideoLAN\VLC\vlc.exe"
' --------------------

' 1. Achar histórico do VLC
appData = WshShell.ExpandEnvironmentStrings("%APPDATA%")
vlcConfigPath = appData & "\vlc\vlc-qt-interface.ini"

If Not fso.FileExists(vlcConfigPath) Then
    MsgBox "Arquivo de histórico do VLC não encontrado. Abra um vídeo no VLC antes.", 48, "Erro"
    WScript.Quit
End If

' 2. Ler histórico
Set stream = fso.OpenTextFile(vlcConfigPath, 1)
lastFileRaw = ""
Do Until stream.AtEndOfStream
    line = stream.ReadLine
    If Left(line, 5) = "list=" Then
        Dim posVirgula
        posVirgula = InStr(line, ",")
        If posVirgula > 0 Then lastFileRaw = Mid(line, 6, posVirgula - 6) Else lastFileRaw = Mid(line, 6)
        Exit Do
    End If
Loop
stream.Close

If lastFileRaw = "" Then
    MsgBox "Histórico do VLC vazio.", 48, "Aviso"
    WScript.Quit
End If

' 3. Limpeza (Decodificação Manual)
cleanPath = lastFileRaw
If Left(cleanPath, 8) = "file:///" Then cleanPath = Mid(cleanPath, 9)
If Left(cleanPath, 7) = "file://" Then cleanPath = Mid(cleanPath, 8)
cleanPath = Replace(cleanPath, "/", "\")
cleanPath = Replace(cleanPath, "%20", " ")
cleanPath = Replace(cleanPath, "%27", "'") 
cleanPath = Replace(cleanPath, "%5B", "[")
cleanPath = Replace(cleanPath, "%5D", "]")
cleanPath = Replace(cleanPath, "%28", "(")
cleanPath = Replace(cleanPath, "%29", ")")
cleanPath = Replace(cleanPath, "%2C", ",")
cleanPath = Replace(cleanPath, "%21", "!")
cleanPath = Replace(cleanPath, "%26", "&")

' 4. Validar Pasta
parentFolder = fso.GetParentFolderName(cleanPath)
targetFileName = fso.GetFileName(cleanPath)

If Not fso.FolderExists(parentFolder) Then
    MsgBox "A pasta do último vídeo não foi encontrada:" & vbCrLf & parentFolder, 16, "Erro"
    WScript.Quit
End If

' 5. Listar e Buscar (Lógica de Aproximação)
Set folderObj = fso.GetFolder(parentFolder)
Set files = folderObj.Files
i = 0
Dim nomeRealNoDisco
nomeRealNoDisco = ""

Function LimparNome(t)
    t = LCase(t)
    t = Replace(t, " ", ""): t = Replace(t, "_", ""): t = Replace(t, "-", "")
    t = Replace(t, "'", ""): t = Replace(t, "%27", ""): t = Replace(t, "[", ""): t = Replace(t, "]", "")
    LimparNome = t
End Function

Dim alvoLimpo
alvoLimpo = LimparNome(targetFileName)

For Each file In files
    If InStr(1, ".mkv.mp4.avi.mov.wmv.flv.webm", LCase(fso.GetExtensionName(file.Name))) > 0 Then
        ReDim Preserve listaArquivos(i)
        listaArquivos(i) = file.Name
        
        If LimparNome(file.Name) = alvoLimpo Then nomeRealNoDisco = file.Name
        If nomeRealNoDisco = "" And InStr(LimparNome(file.Name), alvoLimpo) > 0 Then nomeRealNoDisco = file.Name
        
        i = i + 1
    End If
Next

' 6. Ordenar
If i > 0 Then
    For i = 0 To UBound(listaArquivos) - 1
        For j = i + 1 To UBound(listaArquivos)
            If LCase(listaArquivos(i)) > LCase(listaArquivos(j)) Then
                temp = listaArquivos(i)
                listaArquivos(i) = listaArquivos(j)
                listaArquivos(j) = temp
            End If
        Next
    Next
End If

If nomeRealNoDisco = "" And i > 0 Then nomeRealNoDisco = listaArquivos(0)

' 7. Criar Playlist
playlistContent = "#EXTM3U" & vbCrLf
encontrouNaLista = False

For i = 0 To UBound(listaArquivos)
    If LCase(listaArquivos(i)) = LCase(nomeRealNoDisco) Then encontrouNaLista = True
    If encontrouNaLista Then
        playlistContent = playlistContent & parentFolder & "\" & listaArquivos(i) & vbCrLf
    End If
Next

' 8. Salvar Playlist
playlistPath = fso.GetSpecialFolder(2) & "\playlist_auto.m3u"
Set stream = fso.CreateTextFile(playlistPath, True)
stream.Write(playlistContent)
stream.Close

' --- CORREÇÃO FINAL PARA EXECUTAR O VLC ---
' Verifica se o VLC existe antes de tentar rodar
If Not fso.FileExists(caminhoVLC) Then
    MsgBox "O arquivo do VLC não está em:" & vbCrLf & caminhoVLC, 16, "VLC Sumiu"
    WScript.Quit
End If

' Executa de forma simples
WshShell.Run Chr(34) & caminhoVLC & Chr(34) & " " & Chr(34) & playlistPath & Chr(34)