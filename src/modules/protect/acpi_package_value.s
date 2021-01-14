acpi_package_value:
        ;----------------------------------------
        ;スタックフレームの構築
        ;----------------------------------------
                                                ;   + 8| 入力されたキーコード
                                                ;   + 4| EIP(戻り番号)
        push   ebp                              ;EBP+ 0| EBP(元の値)
        mov    ebp, esp                         ;------|---------

        ;----------------------------------------
        ;レジスタの保存
        ;----------------------------------------
        push    esi

        ;---------------------------------------
        ;引数を取得
        ;---------------------------------------
        mov     esi, [ebp + 8]                  ;EDI = パッケージへのアドレス;

        ;---------------------------------------
        ;パケットのヘッダをスキップ
        ;---------------------------------------
        inc     esi                             ;ESI++; //Skip 'PackageOp'
        inc     esi                             ;ESI++; //Skip 'PkgLength'
        inc     esi                             ;ESI++; //Skip 'NumElements'
                                                ;EDI = PackageElemantList;

        ;---------------------------------------
        ;2バイトのみを取得
        ;---------------------------------------
        mov     al, [esi]                       ;AL = *ESI;
        cmp     al, 0x0B                        ;switch(AL)
        je      .C0B                            ;{
        cmp     al, 0x0C                        ;
        je      .C0C                            ;
        cmp     al, 0x0E                        ;
        je      .C0E                            ;
        jmp     .C0A                            ;
.C0B:                                           ;   case 0x0B: // 'WordPrefix'
.C0C:                                           ;   case 0x0C: // 'DWordPrefix'
.C0E:                                           ;   case 0x0E: // 'QWordPrefix'
        mov     al, [esi + 1]                   ;       AL = ESI[1];
        mov     ah, [esi + 2]                   ;       AH = ESI[2];
        jmp     .10E                            ;       break;

.C0A:                                           ;   drfault: // 'BytePrefix' | 'constObj'
                                                ;       //最初の1バイト
        cmp     al, 0x0A                        ;       if(0x0A == AL)
        jne     .11E                            ;       {
        mov     al, [esi + 1]                   ;           AL = *ESI;
        inc     esi                             ;           ESI++;
.11E:                                           ;       }

                                                ;   //次の1バイト
        inc     esi                             ;   ESI++;

        mov     ah, [esi]                       ;   AH = *ESI;
        cmp     ah, 0x0A                        ;   if(0x0A == AL)
        jne     .12E                            ;   {
        mov     ah, [esi + 1]                   ;       AH = ESI[1];
.12E:                                           ;   }
.10E:                                           ;}

        ;---------------------------------------
        ;レジスタの復帰
        ;---------------------------------------
        pop     esi

        ;---------------------------------------
        ;スタックフレームの破棄
        ;---------------------------------------
        mov     esp, ebp
        pop     ebp

        ret