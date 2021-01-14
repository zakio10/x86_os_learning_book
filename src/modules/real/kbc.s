KBC_Data_Write:
        ;-----------------------------------
        ;スタックフレームの構築
        ;-----------------------------------
                                            ;  + 4| 書き込みデータアドレスデータ
                                            ;  + 2| IP(戻り番号)
        push    bp                          ;BP+ 0| BP(元の値)
        mov     bp, sp                      ;-----|---------

        ;-----------------------------------
        ;レジスタの保存
        ;-----------------------------------
        push    cx

        ;---------------------------------------
        ;ビジーウェイト(カウンタあり)
        ;---------------------------------------
        mov     cx, 0                           ;CX = 0; //最大カウント値
.10L:                                           ;do
                                                ;{
        ;KBCのブッファ確認
        in      al, 0x64                        ;AL = inp(0x64); //KBCステータス取得
        test    al, 0x02                        ;ZF = !(AL & 0x02); //書き込み可能かを確認
        loopnz  .10L                            ;}while(--CX && !ZF);

        ;---------------------------------------
        ;書き込み処理(未タイムアウト時)
        ;---------------------------------------
        cmp     cx, 0                           ;if(CX) //未タイムアウト
        jz      .20E                            ;{
        
        mov     al, [bp + 4]                    ;   AL = データ;
        out     0x60, al                        ;   outp(0x60, AL);
.20E:
        mov     ax, cx                          ;return CX;
        ;---------------------------------------
        ;レジスタの復帰
        ;---------------------------------------
        pop     cx

        ;---------------------------------------
        ;スタックフレームの破棄
        ;---------------------------------------
        mov     sp, bp
        pop     bp

        ret

KBC_Data_Read:
        ;-----------------------------------
        ;スタックフレームの構築
        ;-----------------------------------
                                            ;  + 4| 読み込みデータ格納アドレス
                                            ;  + 2| IP(戻り番号)
        push    bp                          ;BP+ 0| BP(元の値)
        mov     bp, sp                      ;-----|---------

        ;-----------------------------------
        ;レジスタの保存
        ;-----------------------------------
        push    cx

        ;---------------------------------------
        ;ビジーウェイト(カウンタあり)
        ;---------------------------------------
        mov     cx, 0                           ;CX = 0; //最大カウント値
.10L:                                           ;do
                                                ;{
        ;KBCのブッファ確認
        in      al, 0x64                        ;AL = inp(0x64); //KBCステータス取得
        test    al, 0x01                        ;ZF = !(AL & 0x01); //読み込み可能かを確認
        loopz  .10L                            ;}while(--CX && ZF);

        ;---------------------------------------
        ;書き込み処理(未タイムアウト時)
        ;---------------------------------------
        cmp     cx, 0                           ;if(CX) //未タイムアウト
        jz      .20E                            ;{
        
        mov     ah, 0x00                        ;AH = 0x00;
        in      al, 0x60                        ;AL = inp(0x60); //データ取得

        mov     di, [bp + 4]                    ;   AL = ptr;
        mov     [di + 0], ax                    ;   DI[0] = AX;
.20E:
        mov     ax, cx                          ;return CX;
        ;---------------------------------------
        ;レジスタの復帰
        ;---------------------------------------
        pop     cx

        ;---------------------------------------
        ;スタックフレームの破棄
        ;---------------------------------------
        mov     sp, bp
        pop     bp

        ret

KBC_Cmd_Write:
        ;-----------------------------------
        ;スタックフレームの構築
        ;-----------------------------------
                                            ;  + 4| 書き込みデータアドレスデータ
                                            ;  + 2| IP(戻り番号)
        push    bp                          ;BP+ 0| BP(元の値)
        mov     bp, sp                      ;-----|---------

        ;-----------------------------------
        ;レジスタの保存
        ;-----------------------------------
        push    cx

        ;---------------------------------------
        ;ビジーウェイト(カウンタあり)
        ;---------------------------------------
        mov     cx, 0                           ;CX = 0; //最大カウント値
.10L:                                           ;do
                                                ;{
        ;KBCのブッファ確認
        in      al, 0x64                        ;AL = inp(0x64); //KBCステータス取得
        test    al, 0x02                        ;ZF = !(AL & 0x02); //書き込み可能かを確認
        loopnz  .10L                            ;}while(--CX && ZF);

        ;---------------------------------------
        ;書き込み処理(未タイムアウト時)
        ;---------------------------------------
        cmp     cx, 0                           ;if(CX) //未タイムアウト
        jz      .20E                            ;{
        
        mov     al, [bp + 4]                    ;   AL = データ;
        out     0x64, al                        ;   outp(0x6, AL);
.20E:
        mov     ax, cx                          ;return CX;
        ;---------------------------------------
        ;レジスタの復帰
        ;---------------------------------------
        pop     cx

        ;---------------------------------------
        ;スタックフレームの破棄
        ;---------------------------------------
        mov     sp, bp
        pop     bp

        ret