int_pf:
        ;---------------------------------------
        ;スタックフレームの構築
        ;---------------------------------------
                                                ;   + 4| EIP(戻り番号)
        push    ebp                             ;EBP+ 0| EBP(元の値)
        mov     ebp, esp                        ;------|---------

        ;---------------------------------------
        ;レジスタの保存
        ;---------------------------------------
        pusha
        push    ds
        push    es

        ;---------------------------------------
        ;例外を生成したアドレスの確認
        ;---------------------------------------
        mov     eax, cr2                        ;//CR2
        and     eax, ~0x0FFF                    ;//4Kバイト以内のアクセス
        cmp     eax, 0x0010_7000                ;ptr = アクセスアドレス;
        jne     .10F                            ;if(0x0010_7000 == ptr)
                                                ;{
        mov     [0x00106000 + 0x107 * 4], dword 0x00107007  ;//ページの有効化
        cdecl   memcpy, 0x0010_7000, DRAW_PARAM, rose_size  ;描画パラメータ:タスク3用
                                                ;}
        jmp     .10E                            ;else
.10F:                                           ;{
        ;---------------------------------------
        ;スタックの調整
        ;---------------------------------------
        add     esp, 4                          ;pop es
        add     esp, 4                          ;pop ds
        popa
        pop     ebp

        ;---------------------------------------
        ;タスク終了処理
        ;---------------------------------------
        pushf                                   ;   //EFLAGS
        push    cs                              ;   //CS
        push    int_stop                        ;   //スタック表示処理

        mov     eax, .s0                        ;   //割り込み種別
        iret                                    ;}
.10E:
        ;---------------------------------------
        ;レジスタの復帰
        ;---------------------------------------
        pop     es
        pop     ds
        popa

        ;---------------------------------------
        ;スタックフレームの破棄
        ;---------------------------------------
        mov     esp, ebp
        pop     ebp

        ;---------------------------------------
        ;エラーコードの破棄
        ;---------------------------------------
        add     esp, 4                          ;//エラーコードの破棄

        iret
        ;---------------------------------------
        ;データ
        ;---------------------------------------
.s0:    db  " < PAGE FAULT > ", 0