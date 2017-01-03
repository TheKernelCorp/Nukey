section .rodata
dd 0xDACFFCAD
keymap:
    db `\0`                 ; NUL
    db `\e`                 ; ESC
    db `1234567890-=`       ;
    db `\b`                 ; BS
    db `\t`                 ; TAB
    db `qwertyuiop[]\n`     ;
    db 0                    ; Control
    db `asdfghjkl;'\``      ;
    db 0                    ; LShift
    db `\\zxcvbnm,./`       ;
    db 0                    ; RShift
    db 0                    ; Alt
    db ' '                  ; Space
    db 0                    ; Caps Lock
    db 0,0,0,0,0,0,0,0,0,0  ; F1 - F10
    db 0                    ; Num Lock
    db 0                    ; Scroll Lock
    db 0                    ; Home
    db 0                    ; Arrow Up
    db 0                    ; Page Up
    db '-'                  ; Keypad Minus
    db 0                    ; Arrow Left
    db 0                    ;
    db 0                    ; Arrow Right
    db '+'                  ; Keypad Plus
    db 0                    ; End
    db 0                    ; Arrow Down
    db 0                    ; Page Down
    db 0                    ; Insert
    db 0                    ; Delete
    db 0,0,0                ;
    db 0,0                  ; F11 - F12
    times 128-$+keymap db 0
    db 0
    db 0
    db `!@#$%^&*()_+`
    db 0
    db 0
    db `QWERTYUIOP{}\n`
    db 0
    db `ASDFGHJKL:"~`
    db 0
    db `|ZXCVBNM<>?`
    db 0
    db 0
    db ' '
    db 0
    db 0,0,0,0,0,0,0,0,0,0
    db 0
    db 0
    db 0
    db 0
    db 0
    db '-'
    db 0
    db 0
    db 0
    db '+'
    db 0
    db 0
    db 0
    db 0
    db 0
    db 0,0,0
    db 0,0
    times 256-$+keymap db 0