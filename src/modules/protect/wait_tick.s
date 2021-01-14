;************************************************************************
;	ウェイト
;------------------------------------------------------------------------
;	指定された回数、システム割り込みが発生するまで待つ
;========================================================================
;■書式		: void wait_tick(tick);
;
;■引数
;	tick	: システム割り込み回数
;
;■戻り値	: 無し
;************************************************************************
wait_tick:
		;---------------------------------------
		; 【スタックフレームの構築】
		;---------------------------------------
												; ---------------
												; EBP+ 8| ウェイト
												; ---------------
		push	ebp								; EBP+ 4| EIP（戻り番地）
		mov		ebp, esp						; EBP+ 0| EBP（元の値）
												; ------|--------

		;---------------------------------------
		; 【レジスタの保存】
		;---------------------------------------
		push	eax
		push	ecx

		;---------------------------------------
		; ウェイト
		;---------------------------------------
		mov		ecx, [ebp +  8]					; ECX = ウェイト回数
		mov		eax, [TIMER_COUNT]				; EAX = TIMER;
												; do
												; {
.10L:	cmp		[TIMER_COUNT], eax				;   while (TIMER != EAX)
		je		.10L							;     ;
		inc		eax								;   EAX++;
		loop	.10L							; } while (--ECX);

		;---------------------------------------
		; レジスタの復帰
		;---------------------------------------
		pop		ecx
		pop		eax

		;---------------------------------------
		; スタックフレームの破棄
		;---------------------------------------
		mov		esp, ebp
		pop		ebp

		ret

