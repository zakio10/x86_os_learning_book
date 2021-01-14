lba_chs:
        ;-----------------------------------
        ;スタックフレームの構築
        ;-----------------------------------
                                            ;  + 8| LBA
                                            ;  + 6| drive構造体(変換後のシリンダ番号、ヘッド番号、セクタ番号を保存する)のアドレス
                                            ;  + 4| drive構造体(ドライブパラメータが格納)のアドレス
                                            ;  + 2| IP(戻り番号)
        push    bp                          ;BP+ 0| BP(元の値)
        mov     bp, sp                      ;-----|---------

        ;-----------------------------------
        ;レジスタの保存
        ;-----------------------------------
        push    bx
        push    di
        push    dx
        push    si

        ;---------------------------------------
        ;LBAからCHSを計算
        ;---------------------------------------
        mov     si, [bp + 4]                    ;SI = driveバッファ;
        mov     di, [bp + 6]                    ;DI = drv_dhsブッファ;

        mov     al, [si + drive.head]           ;AL = 最大ヘッド数;
        mul     byte [si + drive.sect]          ;AX = 最大ヘッド数 * 最大セクタ数;
        mov     bx, ax                          ;BX = シリンダ当たりのセクタ数;

        mov     dx, 0                           ;DX = LBA(上位2バイト)
        mov     ax, [bp + 8]                    ;AX = LBA(下位2バイト)
        div     bx                              ;DX = DX:AX % BX; //残り
                                                ;AX = DX:AX / BX; //シリンダ番号
        mov     [di + drive.cyln], ax           ;drv_chs.cyln = シリンダ番号;

        mov     ax, dx                          ;AX = 残り;
        div     byte [si + drive.sect]          ;AH = AX % 最大セクタ数; //セクタ番号
                                                ;AL = AX / 最大セクタ数; //ヘッド番号

        movzx   dx, ah                          ;DX = セクタ番号
        inc     dx                              ;(セクタは1始まりなので+1)

        mov     ah, 0x00                        ;AX = ヘッド位置; //AHを0x00にしてAX=ALとした
        
        mov     [di + drive.head], ax           ;drv_chs.head = ヘッド番号;
        mov     [di + drive.sect], dx           ;drv_chs.sect = セクタ番号;

        ;---------------------------------------
        ;レジスタの復帰
        ;---------------------------------------
        pop     si
        pop     dx
        pop     di
        pop     bx

        ;---------------------------------------
        ;スタックフレームの破棄
        ;---------------------------------------
        mov     sp, bp
        pop     bp

        ret