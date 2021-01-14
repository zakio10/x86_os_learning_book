read_lba:
        ;-----------------------------------
        ;スタックフレームの構築
        ;-----------------------------------
                                            ;  +10| 呼び出し先アドレス
                                            ;  + 8| 呼び出しセクタ数
                                            ;  + 6| LBA
                                            ;  + 4| drive構造体(ドライブパラメータが格納)のアドレス
                                            ;  + 2| IP(戻り番号)
        push    bp                          ;BP+ 0| BP(元の値)
        mov     bp, sp                      ;-----|---------

        ;-----------------------------------
        ;レジスタの保存
        ;-----------------------------------
        push    si

        ;---------------------------------------
        ;lba_chs呼び出し準備
        ;---------------------------------------
        mov     si, [bp + 4]                    ;SI = ドライブ情報;

        ;---------------------------------------
        ;LBAからCHSへ変換
        ;---------------------------------------
        mov     ax, [bp + 6]                    ;AX = LBA;
        cdecl   lba_chs, si, .chs, ax           ;lba_chs(drive, .chs, AX);

        ;---------------------------------------
        ;ドライブ番号のコピー
        ;---------------------------------------
        mov     al, [si + drive.no]
        mov     [.chs + drive.no], al           ;ドライブ番号

        ;---------------------------------------
        ;セクタの読み込み
        ;---------------------------------------
        cdecl   read_chs, .chs, word [bp + 8], word [bp +10]
                                                ;AX = read_chs(.chs, セクタ数, ofs);

        ;---------------------------------------
        ;レジスタの復帰
        ;---------------------------------------
        pop     si

        ;---------------------------------------
        ;スタックフレームの破棄
        ;---------------------------------------
        mov     sp, bp
        pop     bp

        ret

        ;---------------------------------------
        ;データ
        ;---------------------------------------
.chs:   times drive_size    db  0               ;読み込みセクタに関する情報