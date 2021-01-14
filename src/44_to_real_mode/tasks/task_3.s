task_3:
        ;---------------------------------------
        ;スタックフレームの構築
        ;---------------------------------------
        mov     ebp, esp                        ;EBP+ 0| EBP(元の値)
                                                ;------|---------
        push    dword 0                         ;   - 4| x0 = 0; //X座標原点
        push    dword 0                         ;   - 8| y0 = 0; //Y座標原点
        push    dword 0                         ;   -12| x  = 0; //X座標描画
        push    dword 0                         ;   -16| y  = 0; //Y座標描画
        push    dword 0                         ;   -20| r  = 0; //角度

        ;---------------------------------------
        ;初期化
        ;---------------------------------------
        mov     esi, 0x0010_7000                 ;ESI = 描画パラメータ

        ;---------------------------------------
        ;タイトル表示
        ;---------------------------------------
        mov     eax, [esi + rose.x0]            ;X0座標
        mov     ebx, [esi + rose.y0]            ;Y0座標

        shr     eax, 3                          ;ESI = EAX / 8; //X座標を文字位置に変換
        shr     ebx, 4                          ;EDI = EBX / 16; //Y座標を文字位置に変換
        dec     ebx                             ;//1文字分上に移動
        mov     ecx, [esi + rose.color_s]       ;文字色
        lea     edx, [esi + rose.title]         ;タイトル

        cdecl   draw_str, eax, ebx, ecx, edx    ;   draw_str(.s0);

        ;---------------------------------------
        ;X軸の中点
        ;---------------------------------------
        mov     eax, [esi + rose.x0]            ;EAX = X0座標;
        mov     ebx, [esi + rose.x1]            ;EBX = X1座標;
        sub     ebx, eax                        ;EBX = (X1 - X0);
        shr     ebx, 1                          ;EBX /= 2;
        add     ebx, eax                        ;EBX += X0;
        mov     [ebp - 4], ebx                  ;x0 = EBX; //X座標原点;

        ;---------------------------------------
        ;Y軸の中点
        ;---------------------------------------
        mov     eax, [esi + rose.y0]            ;EAX = Y0座標;
        mov     ebx, [esi + rose.y1]            ;EBX = Y1座標;
        sub     ebx, eax                        ;EBX = (Y1 - Y0);
        shr     ebx, 1                          ;EBX /= 2;
        add     ebx, eax                        ;EBX += Y0;
        mov     [ebp - 8], ebx                  ;y0 = EBX; //Y座標原点;

        ;---------------------------------------
        ;X軸の描画
        ;---------------------------------------
        mov     eax, [esi + rose.x0]            ;EAX = X0座標;
        mov     ebx, [ebp - 8]                  ;EBX = Y軸の中点
        mov     ecx, [esi + rose.x1]            ;ECX = X1座標;

        cdecl   draw_line, eax, ebx, ecx, ebx, dword [esi + rose.color_x]       ;X軸
        
        ;---------------------------------------
        ;Y軸の描画
        ;---------------------------------------
        mov     eax, [esi + rose.y0]            ;EAX = Y0座標;
        mov     ebx, [ebp - 4]                  ;EBX = X軸の中点
        mov     ecx, [esi + rose.y1]            ;ECX = Y1座標;

        cdecl   draw_line, ebx, eax, ebx, ecx, dword [esi + rose.color_y]       ;Y軸

        ;---------------------------------------
        ;枠の描画
        ;---------------------------------------
        mov     eax, [esi + rose.x0]            ;X0座標
        mov     ebx, [esi + rose.y0]            ;Y0座標
        mov     ecx, [esi + rose.x1]            ;X1座標
        mov     edx, [esi + rose.y1]            ;y1座標

        cdecl   draw_rect, eax, ebx, ecx, edx, dword [esi + rose.color_z]       ;枠

        ;---------------------------------------
        ;振れ幅をX軸の約95%とする
        ;---------------------------------------
        mov     eax, [esi + rose.x1]            ;EAX = X1座標;
        sub     eax, [esi + rose.x0]            ;EAX -= X0座標;
        shr     eax, 1                          ;EAX /= 2; //半分
        mov     ebx, eax                        ;EBX = EAX;
        shr     ebx, 4                          ;EBX /= 16;
        sub     eax, ebx                        ;EAX -= EBX;

        ;---------------------------------------
        ;FPUの初期化(パラ曲線の初期化)
        ;---------------------------------------
        cdecl   fpu_rose_init, eax, dword [esi + rose.n], dword [esi + rose.d]  ;fpu_rose_init(A, n, d);

        ;---------------------------------------
        ;メインループ
        ;---------------------------------------
.10L:                                           ;while(1)
                                                ;{

        ;---------------------------------------
        ;座標計算
        ;---------------------------------------
        lea     ebx, [ebp -12]                  ;       EBX = &x;
        lea     ecx, [ebp -16]                  ;       ECX = &y;
        mov     eax, [ebp -20]                  ;       EAX = r;

        cdecl   fpu_rose_update, ebx, ecx, eax  ;       fpu_rose_update(&x, &y, r);

        ;---------------------------------------
        ;角度更新(r = r % 36000)
        ;---------------------------------------
        mov     edx, 0                          ;       EDX = 0;
        inc     eax                             ;       EAX++;
        mov     ebx, 360 * 100                  ;       EBX = 36000
        div     ebx                             ;       EDX = EDX:EAX % EBX;
        mov     [ebp -20], edx

        ;---------------------------------------
        ;ドット描画
        ;---------------------------------------
        mov     ecx, [ebp -12]                  ;       ECX = X座標
        mov     edx, [ebp -16]                  ;       ECX = Y座標

        add     ecx, [ebp - 4]                  ;       ECX += X座標原点;
        add     edx, [ebp - 8]                  ;       EDX += Y座標原点;

        mov     ebx, [esi + rose.color_f]       ;       EBX = 表示色;
        int     0x82                            ;       sys_call_82(表示色, X, Y);

        ;---------------------------------------
        ;ウェイト
        ;---------------------------------------
        cdecl   wait_tick, 2                    ;   wait_tick(2);

        ;---------------------------------------
        ;ドット描画(消去)
        ;---------------------------------------
        mov     ebx, [esi + rose.color_b]       ;       EBX = 背景色;
        int     0x82                            ;       sys_call_82(背景色, X, Y);

        jmp     .10L                            ;}

        ;---------------------------------------
        ;データ
        ;---------------------------------------
ALIGN 4, db 0
DRAW_PARAM:
.t3:
        istruc  rose
                at      rose.x0,        dd      32              ;左上座標:X0
                at      rose.y0,        dd      32              ;左上座標:Y0
                at      rose.x1,        dd      208             ;右下座標:X1
                at      rose.y1,        dd      208             ;右下座標:Y1

                at      rose.n,         dd      2               ;変数:n
                at      rose.d,         dd      1               ;変数:d

                at      rose.color_x,   dd      0x0007          ;描画色:X軸
                at      rose.color_y,   dd      0x0007          ;描画色:Y軸
                at      rose.color_z,   dd      0x000F          ;描画色:枠
                at      rose.color_s,   dd      0x030F          ;描画色:文字
                at      rose.color_f,   dd      0x000F          ;描画色:グラフ描画色
                at      rose.color_b,   dd      0x0003          ;描画色:グラフ消去色

                at      rose.title,     db      "Task-3", 0     ;タイトル
        iend

.t4:
        istruc  rose
                at      rose.x0,        dd      248             ;左上座標:X0
                at      rose.y0,        dd      32              ;左上座標:Y0
                at      rose.x1,        dd      424             ;右下座標:X1
                at      rose.y1,        dd      208             ;右下座標:Y1

                at      rose.n,         dd      3               ;変数:n
                at      rose.d,         dd      1               ;変数:d

                at      rose.color_x,   dd      0x0007          ;描画色:X軸
                at      rose.color_y,   dd      0x0007          ;描画色:Y軸
                at      rose.color_z,   dd      0x000F          ;描画色:枠
                at      rose.color_s,   dd      0x030F          ;描画色:文字
                at      rose.color_f,   dd      0x000F          ;描画色:グラフ描画色
                at      rose.color_b,   dd      0x0004          ;描画色:グラフ消去色

                at      rose.title,     db      "Task-4", 0     ;タイトル
        iend

.t5:
        istruc  rose
                at      rose.x0,        dd      32              ;左上座標:X0
                at      rose.y0,        dd      272             ;左上座標:Y0
                at      rose.x1,        dd      208             ;右下座標:X1
                at      rose.y1,        dd      448             ;右下座標:Y1

                at      rose.n,         dd      2               ;変数:n
                at      rose.d,         dd      6               ;変数:d

                at      rose.color_x,   dd      0x0007          ;描画色:X軸
                at      rose.color_y,   dd      0x0007          ;描画色:Y軸
                at      rose.color_z,   dd      0x000F          ;描画色:枠
                at      rose.color_s,   dd      0x030F          ;描画色:文字
                at      rose.color_f,   dd      0x000F          ;描画色:グラフ描画色
                at      rose.color_b,   dd      0x0005          ;描画色:グラフ消去色

                at      rose.title,     db      "Task-5", 0     ;タイトル
        iend

.t6:
        istruc  rose
                at      rose.x0,        dd      248             ;左上座標:X0
                at      rose.y0,        dd      272             ;左上座標:Y0
                at      rose.x1,        dd      424             ;右下座標:X1
                at      rose.y1,        dd      448             ;右下座標:Y1

                at      rose.n,         dd      4               ;変数:n
                at      rose.d,         dd      6               ;変数:d

                at      rose.color_x,   dd      0x0007          ;描画色:X軸
                at      rose.color_y,   dd      0x0007          ;描画色:Y軸
                at      rose.color_z,   dd      0x000F          ;描画色:枠
                at      rose.color_s,   dd      0x030F          ;描画色:文字
                at      rose.color_f,   dd      0x000F          ;描画色:グラフ描画色
                at      rose.color_b,   dd      0x0006          ;描画色:グラフ消去色

                at      rose.title,     db      "Task-6", 0     ;タイトル
        iend

fpu_rose_init:
        ;---------------------------------------
        ;スタックフレームの構築
        ;---------------------------------------
                                                ;   +16| d
                                                ;   +12| n
                                                ;   + 8| A
                                                ;   + 4| EIP(戻り番号)
        push    ebp                             ;EBP+ 0| EBP(元の値)
        mov     ebp, esp                        ;------|---------
        push    dword 180                       ;   - 4| dword i = 180;

        ;---------------------------------------
        ;FPU
        ;---------------------------------------
                                        ;----------|-----------|-----------|-----------|-----------|-----------|
                                        ;       ST0|        ST1|        ST2|        ST3|        ST4|        ST5|
                                        ;----------|-----------|-----------|-----------|-----------|-----------|
        fldpi                           ;        pi|  xxxxxxxxx|  xxxxxxxxx|  xxxxxxxxx|  xxxxxxxxx|  xxxxxxxxx|
        fidiv   dword [ebp - 4]         ;    pi/180|  xxxxxxxxx|  xxxxxxxxx|  xxxxxxxxx|  xxxxxxxxx|  xxxxxxxxx|
        fild    dword [ebp +12]         ;         n|     pi/180|  xxxxxxxxx|  xxxxxxxxx|  xxxxxxxxx|  xxxxxxxxx|
        fidiv   dword [ebp +16]         ;       n/d|     pi/180|  xxxxxxxxx|  xxxxxxxxx|  xxxxxxxxx|  xxxxxxxxx|
        fild    dword [ebp + 8]         ;         A|        n/d|     pi/180|  xxxxxxxxx|  xxxxxxxxx|  xxxxxxxxx|
                                        ;----------|-----------|-----------|-----------|-----------|-----------|
                                        ;         A|          k|          r|  xxxxxxxxx|  xxxxxxxxx|  xxxxxxxxx|
                                        ;----------|-----------|-----------|-----------|-----------|-----------|

        ;---------------------------------------
        ;スタックフレームの破棄
        ;---------------------------------------
        mov     esp, ebp
        pop     ebp

        ret

fpu_rose_update:
        ;---------------------------------------
        ;スタックフレームの構築
        ;---------------------------------------
                                                ;   +16| t(角度)
                                                ;   +12| Y(float)のアドレス
                                                ;   + 8| X(float)のアドレス
                                                ;   + 4| EIP(戻り番号)
        push   ebp                              ;EBP+ 0| EBP(元の値)
        mov    ebp, esp                         ;------|---------

        ;---------------------------------------
        ;レジスタの保存
        ;---------------------------------------
        push    eax
        push    ebx

        ;---------------------------------------
        ;X/Y座標の保存先を設定
        ;---------------------------------------
        mov     eax, [ebp + 8]                  ;EAX = pX; //X座標へのポインタ
        mov     ebx, [ebp + 12]                 ;EBX = pY; //Y座標へのポインタ
        
        ;---------------------------------------
        ;FPU
        ;---------------------------------------
                                        ;----------|-----------|-----------|-----------|-----------|-----------|
                                        ;       ST0|        ST1|        ST2|        ST3|        ST4|        ST5|
                                        ;----------|-----------|-----------|-----------|-----------|-----------|
        fild    dword [ebp +16]         ;         t|          A|          k|          r|  xxxxxxxxx|  xxxxxxxxx|
        fmul    st0, st3                ;        rt|          A|          k|          r|  xxxxxxxxx|  xxxxxxxxx|
        fld     st0                     ;        rt|         rt|          A|          k|          r|  xxxxxxxxx|
                                        ;----------|-----------|-----------|-----------|-----------|-----------|
                                        ;    θ=(rt)|     θ=(rt)|          A|          k|          r|  xxxxxxxxx|
                                        ;----------|-----------|-----------|-----------|-----------|-----------|
        fsincos                         ;    cos(θ)|     sin(θ)|          θ|          A|          k|          r|
                                        ;----------|-----------|-----------|-----------|-----------|-----------|
        fxch    st2                     ;         θ|     sin(θ)|     cos(θ)|          A|          k|          r|
        fmul    st0, st4                ;        kθ|     sin(θ)|     cos(θ)|          A|          k|          r|
        fsin                            ;   sin(kθ)|     sin(θ)|     cos(θ)|          A|          k|          r|
        fmul    st0, st3                ;  Asin(kθ)|     sin(θ)|     cos(θ)|          A|          k|          r|
                                        ;----------|-----------|-----------|-----------|-----------|-----------|
        fxch    st2                     ;    cos(θ)|     sin(θ)|   Asin(kθ)|          A|          k|          r|
        fmul    st0, st2                ;         x|     sin(θ)|   Asin(kθ)|          A|          k|          r|
        fistp   dword [eax]             ;    sin(θ)|   Asin(kθ)|          A|          k|          r|  xxxxxxxxx|
                                        ;----------|-----------|-----------|-----------|-----------|-----------|
        fmulp   st1, st0                ;         y|          A|          k|          r|  xxxxxxxxx|  xxxxxxxxx|
        fchs                            ;        -y|          A|          k|          r|  xxxxxxxxx|  xxxxxxxxx|
        fistp   dword [ebx]             ;         A|          k|          r|  xxxxxxxxx|  xxxxxxxxx|  xxxxxxxxx|
                                        ;----------|-----------|-----------|-----------|-----------|-----------|

        ;---------------------------------------
        ;レジスタの復帰
        ;---------------------------------------
        pop     ebx
        pop     eax

        ;---------------------------------------
        ;スタックフレームの破棄
        ;---------------------------------------
        mov     esp, ebp
        pop     ebp

        ret