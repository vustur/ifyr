import osproc, os, strutils, std/tables, unicode

var location = os.getCurrentDir()
var hostname = strutils.strip(osproc.execCmdEx("hostname").output)
var username = strutils.strip(osproc.execCmdEx("whoami").output)

func translit(inpCmd: string): string =
    let rus2eng = { # thx raskladki.net.ru for making this dictionary so i can steal and use it
        "\"": "@",
        "№": "#",
        ";": "$",
        ":": "^",
        "?": "&",
        "Й": "Q",
        "Ц": "W",
        "У": "E",
        "К": "R",
        "Е": "T",
        "Н": "Y",
        "Г": "U",
        "Ш": "I",
        "Щ": "O",
        "З": "P",
        "Х": "{",
        "Ъ": "}",
        "/": "|",
        "Ф": "A",
        "Ы": "S",
        "В": "D",
        "А": "F",
        "П": "G",
        "Р": "H",
        "О": "J",
        "Л": "K",
        "Д": "L",
        "Ж": ":",
        "Э": "\"",
        "Я": "Z",
        "Ч": "X",
        "С": "C",
        "М": "V",
        "И": "B",
        "Т": "N",
        "Ь": "M",
        "Б": "<",
        "Ю": ">",
        ",": "?",
        "Ё": "~",
        "й": "q",
        "ц": "w",
        "у": "e",
        "к": "r",
        "е": "t",
        "н": "y",
        "г": "u",
        "ш": "i",
        "щ": "o",
        "з": "p",
        "х": "[",
        "ъ": "]",
        "\\\\": "\\\\",
        "ф": "a",
        "ы": "s",
        "в": "d",
        "а": "f",
        "п": "g",
        "р": "h",
        "о": "j",
        "л": "k",
        "д": "l",
        "ж": ";",
        "э": "'",
        "я": "z",
        "ч": "x",
        "с": "c",
        "м": "v",
        "и": "b",
        "т": "n",
        "ь": "m",
        "б": ",",
        "ю": ".",
        ".": "/",
        "ё": "`"
    }.toTable

    var inpCmdTrn = ""
    for ch in inpCmd.runes:
        if rus2eng.hasKey($ch):
            inpCmdTrn = inpCmdTrn & rus2eng[$ch]
        else:
            inpCmdTrn = inpCmdTrn & $ch

    return inpCmdTrn

while true:
    let lastLocationDir = location[location.rfind("/") + 1..^1]
    stdout.write("[" & username & "@" & hostname & " " & lastLocationDir & "] ")
    
    var inp = readLine(stdin)
    inp = strutils.strip(inp)
    if inp.len == 0:
        continue
    if inp == "exit":
        break

    let cmdBase = strutils.strip(inp.split(' ')[0]) # this part checks if first word exists in $path or is builtin
    let pathDirs = getEnv("PATH", "").split(":")

    var exsInPath = false
    for dir in pathDirs:
        let fullPath = dir / cmdBase
        if fileExists(fullPath):
            exsInPath = true
            break
    let builtIns = ["cd", "export", "unset", "source", ".", "echo", "eval", "command"]
    if not (cmdBase in builtIns or exsInPath):
        inp = translit(inp)

    let shellInput = "cd " & location & ";" & inp & "; pwd"
    # echo "SHINPT: ", shellInput
    let result = osproc.execCmdEx(shellInput)
    var output = result.output.splitLines()[0 ..< ^2].join("\n") # output without last two lines
    if (result.exitCode == 0):
        location = result.output.splitLines()[^2]
    echo output

