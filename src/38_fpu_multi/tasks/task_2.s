task_2:
        cdecl   draw_str, 63, 1, 0x07, .s0      ;   draw_str(.s0);

        ;---------------------------------------
        ;FPU
        ;---------------------------------------
                                    ;----------|-----------|-----------|-----------|-----------|-----------|
                                    ;       ST0|        ST1|        ST2|        ST3|        ST4|        ST5|
                                    ;----------|-----------|-----------|-----------|-----------|-----------|
        fild    dword [.c1000]      ;      1000|  xxxxxxxxx|  xxxxxxxxx|  xxxxxxxxx|  xxxxxxxxx|  xxxxxxxxx|
        fldpi                       ;        pi|       1000|  xxxxxxxxx|  xxxxxxxxx|  xxxxxxxxx|  xxxxxxxxx|
        fidiv   dword [.c180]       ;    pi/180|       1000|  xxxxxxxxx|  xxxxxxxxx|  xxxxxxxxx|  xxxxxxxxx|
        fldpi                       ;        pi|     pi/180|       1000|  xxxxxxxxx|  xxxxxxxxx|  xxxxxxxxx|
        fadd    st0, st0            ;      2*pi|     pi/180|       1000|  xxxxxxxxx|  xxxxxxxxx|  xxxxxxxxx|
        fldz                        ;     θ = 0|       2*pi|     pi/180|       1000|  xxxxxxxxx|  xxxxxxxxx|
                                    ;----------|-----------|-----------|-----------|-----------|-----------|

.10L:                                           ;while(1)
                                                ;{

                                    ;----------|-----------|-----------|-----------|-----------|-----------|
                                    ;         θ|       2*pi|          d|       1000|  xxxxxxxxx|  xxxxxxxxx|
                                    ;----------|-----------|-----------|-----------|-----------|-----------|
        fadd    st0, ST2            ;θ =  θ + d|       2*pi|          d|       1000|  xxxxxxxxx|  xxxxxxxxx|
        fprem                       ;    MOD(θ)|       2*pi|          d|       1000|  xxxxxxxxx|  xxxxxxxxx|
                                    ;----------|-----------|-----------|-----------|-----------|-----------|
                                    ;         θ|       2*pi|          d|       1000|  xxxxxxxxx|  xxxxxxxxx|
        fld     st0                 ;         θ|          θ|       2*pi|          d|       1000|  xxxxxxxxx|
        fsin                        ;    sin(θ)|          θ|       2*pi|          d|       1000|  xxxxxxxxx|
        fmul    st0, st4            ;ST4*sin(θ)|          θ|       2*pi|          d|       1000|  xxxxxxxxx|
        fbstp   [.bcd]              ;         θ|       2*pi|          d|       1000|  xxxxxxxxx|  xxxxxxxxx|

        ;---------------------------------------
        ;CPU
        ;---------------------------------------
        ;---------------------------------------
        ;数値出力
        ;---------------------------------------
        mov     eax, [.bcd]                     ;   EAX = 1000* sin(t);
        mov     ebx, eax                        ;   EBX = EAX;

        and     eax, 0x0F0F                     ;   //上位4ビットをマスク
        or      eax, 0x3030                     ;   //上位4ビットに0x3を設定

        shr     ebx, 4                          ;   EBX >> 4;
        and     ebx, 0x0F0F                     ;   //上位4ビットをマスク
        or      ebx, 0x3030                     ;   //上位4ビットに0x3を設定

        mov     [.s2 + 0], bh                   ;   //1桁目
        mov     [.s3 + 0], ah                   ;   //小数1桁目
        mov     [.s3 + 1], bl                   ;   //小数2桁目
        mov     [.s3 + 2], al                   ;   //小数3桁目

        ;---------------------------------------
        ;符号チェック
        ;---------------------------------------
        mov     eax, 7                          ;   //bt命令準備(取り出しbit番号指定)
        bt      [.bcd + 9], eax                 ;   CF = bcd[9] & 0x80;
        jc      .10F                            ;   if(CF)
                                                ;   {
        mov     [.s1 + 0], byte '+'             ;       *s1 = '+';
        jmp     .10E                            ;   }
.10F:                                           ;   else
                                                ;   {
        mov     [.s1 + 0], byte '-'             ;       *s1 = '-';
.10E:                                           ;   }

        cdecl   draw_str, 72, 1, 0x07, .s1      ;   draw_str(.s1);

        ;---------------------------------------
        ;ウェイト
        ;---------------------------------------
        cdecl   wait_tick, 10                   ;   wait_tick(10);

        jmp     .10L                            ;}

        ;---------------------------------------
        ;データ
        ;---------------------------------------
ALIGN   4,  db  0
.c1000:     dd  1000
.c180:      dd  180
.bcd:   times 10    db  0x00
.s0:    db  "Task-2", 0
.s1:    db  "-"
.s2:    db  "0."
.s3:    db  "000", 0