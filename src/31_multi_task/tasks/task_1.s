task_1:
        ;---------------------------------------
        ;文字列の表示
        ;---------------------------------------
        cdecl   draw_str, 63, 0, 0x07, .s0      ;draw_str();

        ;---------------------------------------
        ;タスクの終了
        ;---------------------------------------
        iret

        ;---------------------------------------
        ;データ
        ;---------------------------------------
.s0:    db  "Task-1", 0