%define     RING_ITEM_SIZE  (1 << 4)
%define     RING_INDEX_MASK (RING_ITEM_SIZE - 1)

struc rose
        .x0         resd    1                       ;左上座標:X0
        .y0         resd    1                       ;左上座標:Y0
        .x1         resd    1                       ;右下座標:X1
        .y1         resd    1                       ;右下座標:Y1

        .n          resd    1                       ;変数:n
        .d          resd    1                       ;変数:d

        .color_x    resd    1                       ;描画色:X座標
        .color_y    resd    1                       ;描画色:Y座標
        .color_z    resd    1                       ;描画色:枠
        .color_s    resd    1                       ;描画色:文字
        .color_f    resd    1                       ;描画色:グラフ描画色
        .color_b    resd    1                       ;描画色:グラフ消去色

        .title      resb    16                      ;タイトル

endstruc

struc drive
        .no         resw    1                       ;ドライブ番号
        .cyln       resw    1                       ;シリンダ
        .head       resw    1                       ;ヘッド
        .sect       resw    1                       ;セクタ
endstruc

struc ring_buff
        .rp         resd    1                       ;RP:書き込み位置
        .wp         resd    1                       ;WP:読み込み位置
        .item       resb    RING_ITEM_SIZE          ;ブッファ
endstruc

%macro  cdecl   1-*.nolist

    %rep    %0 - 1
        push    %{-1:-1}
        %rotate -1
    %endrep
    %rotate -1

        call    %1

    %if 1 < %0
        add     sp, (__BITS__ >> 3) * (%0 - 1)
    %endif

%endmacro

%macro  set_vect    1-*
        push    eax
        push    edi

        mov     edi, VECT_BASE + (%1 * 8)           ;ベクタアドレス
        mov     eax, %2

    %if 3 == %0
        mov     [edi + 4], %3                       ;フラグ
    %endif

        mov     [edi + 0], ax                       ;例外アドレス[15:0]
        shr     eax, 16
        mov     [edi + 6], ax                       ;6はエンディアン(?) 例外アドレス[31:16]

        pop     edi
        pop     eax
%endmacro

%macro  outp    2
        mov     al, %2
        out     %1, al
%endmacro

%macro  set_desc    2-*
        push    eax
        push    edi

        mov     edi, %1                             ;ディスクリプタアドレス
        mov     eax, %2                             ;ベースアドレス

    %if 3 == %0
        mov     [edi + 0], %3                       ;リミット
    %endif
    
        mov     [edi + 2], ax                       ;ベース([15: 0])
        shr     eax, 16
        mov     [edi + 4], al                       ;ベース([23:16])
        mov     [edi + 7], ah                       ;ベース([31:24])

        pop     edi
        pop     eax
%endmacro

%macro  set_gate    2-*
        push    eax
        push    edi

        mov     edi, %1                             ;ディスクリプタアドレス
        mov     eax, %2                             ;ベースアドレス

        mov     [edi + 0], ax                       ;ベース([15:0])
        shr     eax, 16
        mov     [edi + 6], ax                       ;ベース([31:16])

        pop     edi
        pop     eax
%endmacro