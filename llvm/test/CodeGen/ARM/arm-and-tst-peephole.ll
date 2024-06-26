; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=arm-eabi -arm-atomic-cfg-tidy=0 %s -o - | FileCheck -check-prefix=ARM %s
; RUN: llc -mtriple=thumb-eabi -arm-atomic-cfg-tidy=0 %s -o - | FileCheck -check-prefix=THUMB %s
; RUN: llc -mtriple=thumb-eabi -arm-atomic-cfg-tidy=0 -mcpu=arm1156t2-s -mattr=+thumb2 %s -o - | FileCheck -check-prefix=T2 %s
; RUN: llc -mtriple=thumbv8-eabi -arm-atomic-cfg-tidy=0 %s -o - | FileCheck -check-prefix=V8 %s

; FIXME: The -mtriple=thumb test doesn't change if -disable-peephole is specified.

%struct.Foo = type { ptr }

define ptr @foo(ptr %this, i32 %acc) nounwind readonly align 2 {
; ARM-LABEL: foo:
; ARM:       @ %bb.0: @ %entry
; ARM-NEXT:    add r2, r0, #4
; ARM-NEXT:    mov r12, #1
; ARM-NEXT:    b .LBB0_3
; ARM-NEXT:  .LBB0_1: @ %tailrecurse.switch
; ARM-NEXT:    @ in Loop: Header=BB0_3 Depth=1
; ARM-NEXT:    cmp r3, #1
; ARM-NEXT:    movne pc, lr
; ARM-NEXT:  .LBB0_2: @ %sw.bb
; ARM-NEXT:    @ in Loop: Header=BB0_3 Depth=1
; ARM-NEXT:    orr r1, r3, r1, lsl #1
; ARM-NEXT:    add r2, r2, #4
; ARM-NEXT:    add r12, r12, #1
; ARM-NEXT:  .LBB0_3: @ %tailrecurse
; ARM-NEXT:    @ =>This Inner Loop Header: Depth=1
; ARM-NEXT:    ldr r3, [r2, #-4]
; ARM-NEXT:    ands r3, r3, #3
; ARM-NEXT:    beq .LBB0_2
; ARM-NEXT:  @ %bb.4: @ %tailrecurse.switch
; ARM-NEXT:    @ in Loop: Header=BB0_3 Depth=1
; ARM-NEXT:    cmp r3, #3
; ARM-NEXT:    moveq r0, r2
; ARM-NEXT:    moveq pc, lr
; ARM-NEXT:  .LBB0_5: @ %tailrecurse.switch
; ARM-NEXT:    @ in Loop: Header=BB0_3 Depth=1
; ARM-NEXT:    cmp r3, #2
; ARM-NEXT:    bne .LBB0_1
; ARM-NEXT:  @ %bb.6: @ %sw.bb8
; ARM-NEXT:    add r1, r1, r12
; ARM-NEXT:    add r0, r0, r1, lsl #2
; ARM-NEXT:    mov pc, lr
;
; THUMB-LABEL: foo:
; THUMB:       @ %bb.0: @ %entry
; THUMB-NEXT:    .save {r4, r5, r7, lr}
; THUMB-NEXT:    push {r4, r5, r7, lr}
; THUMB-NEXT:    movs r2, #1
; THUMB-NEXT:    movs r3, r0
; THUMB-NEXT:  .LBB0_1: @ %tailrecurse
; THUMB-NEXT:    @ =>This Inner Loop Header: Depth=1
; THUMB-NEXT:    ldr r5, [r3]
; THUMB-NEXT:    movs r4, #3
; THUMB-NEXT:    ands r4, r5
; THUMB-NEXT:    beq .LBB0_5
; THUMB-NEXT:  @ %bb.2: @ %tailrecurse.switch
; THUMB-NEXT:    @ in Loop: Header=BB0_1 Depth=1
; THUMB-NEXT:    cmp r4, #3
; THUMB-NEXT:    beq .LBB0_6
; THUMB-NEXT:  @ %bb.3: @ %tailrecurse.switch
; THUMB-NEXT:    @ in Loop: Header=BB0_1 Depth=1
; THUMB-NEXT:    cmp r4, #2
; THUMB-NEXT:    beq .LBB0_7
; THUMB-NEXT:  @ %bb.4: @ %tailrecurse.switch
; THUMB-NEXT:    @ in Loop: Header=BB0_1 Depth=1
; THUMB-NEXT:    cmp r4, #1
; THUMB-NEXT:    bne .LBB0_9
; THUMB-NEXT:  .LBB0_5: @ %sw.bb
; THUMB-NEXT:    @ in Loop: Header=BB0_1 Depth=1
; THUMB-NEXT:    lsls r1, r1, #1
; THUMB-NEXT:    orrs r4, r1
; THUMB-NEXT:    adds r3, r3, #4
; THUMB-NEXT:    adds r2, r2, #1
; THUMB-NEXT:    movs r1, r4
; THUMB-NEXT:    b .LBB0_1
; THUMB-NEXT:  .LBB0_6: @ %sw.bb6
; THUMB-NEXT:    adds r0, r3, #4
; THUMB-NEXT:    b .LBB0_8
; THUMB-NEXT:  .LBB0_7: @ %sw.bb8
; THUMB-NEXT:    adds r1, r1, r2
; THUMB-NEXT:    lsls r1, r1, #2
; THUMB-NEXT:    adds r0, r0, r1
; THUMB-NEXT:  .LBB0_8: @ %sw.bb6
; THUMB-NEXT:    pop {r4, r5, r7}
; THUMB-NEXT:    pop {r1}
; THUMB-NEXT:    bx r1
; THUMB-NEXT:  .LBB0_9: @ %sw.epilog
; THUMB-NEXT:    pop {r4, r5, r7}
; THUMB-NEXT:    pop {r0}
; THUMB-NEXT:    bx r0
;
; T2-LABEL: foo:
; T2:       @ %bb.0: @ %entry
; T2-NEXT:    adds r2, r0, #4
; T2-NEXT:    mov.w r12, #1
; T2-NEXT:    b .LBB0_3
; T2-NEXT:  .LBB0_1: @ %tailrecurse.switch
; T2-NEXT:    @ in Loop: Header=BB0_3 Depth=1
; T2-NEXT:    cmp r3, #1
; T2-NEXT:    it ne
; T2-NEXT:    bxne lr
; T2-NEXT:  .LBB0_2: @ %sw.bb
; T2-NEXT:    @ in Loop: Header=BB0_3 Depth=1
; T2-NEXT:    orr.w r1, r3, r1, lsl #1
; T2-NEXT:    adds r2, #4
; T2-NEXT:    add.w r12, r12, #1
; T2-NEXT:  .LBB0_3: @ %tailrecurse
; T2-NEXT:    @ =>This Inner Loop Header: Depth=1
; T2-NEXT:    ldr r3, [r2, #-4]
; T2-NEXT:    ands r3, r3, #3
; T2-NEXT:    beq .LBB0_2
; T2-NEXT:  @ %bb.4: @ %tailrecurse.switch
; T2-NEXT:    @ in Loop: Header=BB0_3 Depth=1
; T2-NEXT:    cmp r3, #3
; T2-NEXT:    itt eq
; T2-NEXT:    moveq r0, r2
; T2-NEXT:    bxeq lr
; T2-NEXT:  .LBB0_5: @ %tailrecurse.switch
; T2-NEXT:    @ in Loop: Header=BB0_3 Depth=1
; T2-NEXT:    cmp r3, #2
; T2-NEXT:    bne .LBB0_1
; T2-NEXT:  @ %bb.6: @ %sw.bb8
; T2-NEXT:    add r1, r12
; T2-NEXT:    add.w r0, r0, r1, lsl #2
; T2-NEXT:    bx lr
;
; V8-LABEL: foo:
; V8:       @ %bb.0: @ %entry
; V8-NEXT:    adds r2, r0, #4
; V8-NEXT:    mov.w r12, #1
; V8-NEXT:    b .LBB0_3
; V8-NEXT:  .LBB0_1: @ %tailrecurse.switch
; V8-NEXT:    @ in Loop: Header=BB0_3 Depth=1
; V8-NEXT:    cmp r3, #1
; V8-NEXT:    it ne
; V8-NEXT:    bxne lr
; V8-NEXT:  .LBB0_2: @ %sw.bb
; V8-NEXT:    @ in Loop: Header=BB0_3 Depth=1
; V8-NEXT:    orr.w r1, r3, r1, lsl #1
; V8-NEXT:    adds r2, #4
; V8-NEXT:    add.w r12, r12, #1
; V8-NEXT:  .LBB0_3: @ %tailrecurse
; V8-NEXT:    @ =>This Inner Loop Header: Depth=1
; V8-NEXT:    ldr r3, [r2, #-4]
; V8-NEXT:    ands r3, r3, #3
; V8-NEXT:    beq .LBB0_2
; V8-NEXT:  @ %bb.4: @ %tailrecurse.switch
; V8-NEXT:    @ in Loop: Header=BB0_3 Depth=1
; V8-NEXT:    cmp r3, #3
; V8-NEXT:    itt eq
; V8-NEXT:    moveq r0, r2
; V8-NEXT:    bxeq lr
; V8-NEXT:  .LBB0_5: @ %tailrecurse.switch
; V8-NEXT:    @ in Loop: Header=BB0_3 Depth=1
; V8-NEXT:    cmp r3, #2
; V8-NEXT:    bne .LBB0_1
; V8-NEXT:  @ %bb.6: @ %sw.bb8
; V8-NEXT:    add r1, r12
; V8-NEXT:    add.w r0, r0, r1, lsl #2
; V8-NEXT:    bx lr
entry:
  %scevgep = getelementptr %struct.Foo, ptr %this, i32 1
  br label %tailrecurse

tailrecurse:                                      ; preds = %sw.bb, %entry
  %lsr.iv2 = phi ptr [ %scevgep3, %sw.bb ], [ %scevgep, %entry ]
  %lsr.iv = phi i32 [ %lsr.iv.next, %sw.bb ], [ 1, %entry ]
  %acc.tr = phi i32 [ %or, %sw.bb ], [ %acc, %entry ]
  %scevgep5 = getelementptr ptr, ptr %lsr.iv2, i32 -1
  %tmp2 = load ptr, ptr %scevgep5
  %0 = ptrtoint ptr %tmp2 to i32




  %and = and i32 %0, 3
  %tst = icmp eq i32 %and, 0
  br i1 %tst, label %sw.bb, label %tailrecurse.switch

tailrecurse.switch:                               ; preds = %tailrecurse

  switch i32 %and, label %sw.epilog [
    i32 1, label %sw.bb
    i32 3, label %sw.bb6
    i32 2, label %sw.bb8
  ], !prof !1

sw.bb:                                            ; preds = %tailrecurse.switch, %tailrecurse
  %shl = shl i32 %acc.tr, 1
  %or = or i32 %and, %shl
  %lsr.iv.next = add i32 %lsr.iv, 1
  %scevgep3 = getelementptr %struct.Foo, ptr %lsr.iv2, i32 1
  br label %tailrecurse

sw.bb6:                                           ; preds = %tailrecurse.switch
  ret ptr %lsr.iv2

sw.bb8:                                           ; preds = %tailrecurse.switch
  %tmp1 = add i32 %acc.tr, %lsr.iv
  %add.ptr11 = getelementptr inbounds %struct.Foo, ptr %this, i32 %tmp1
  ret ptr %add.ptr11

sw.epilog:                                        ; preds = %tailrecurse.switch
  ret ptr undef
}

; Another test that exercises the AND/TST peephole optimization and also
; generates a predicated ANDS instruction. Check that the predicate is printed
; after the "S" modifier on the instruction.

%struct.S = type { ptr, [1 x i8] }

define internal zeroext i8 @bar(ptr %x, ptr nocapture %y) nounwind readonly {
; ARM-LABEL: bar:
; ARM:       @ %bb.0: @ %entry
; ARM-NEXT:    ldrb r2, [r0, #4]
; ARM-NEXT:    ands r2, r2, #112
; ARM-NEXT:    ldrbne r1, [r1, #4]
; ARM-NEXT:    andsne r1, r1, #112
; ARM-NEXT:    beq .LBB1_2
; ARM-NEXT:  @ %bb.1: @ %bb2
; ARM-NEXT:    cmp r2, #16
; ARM-NEXT:    cmpne r1, #16
; ARM-NEXT:    andeq r0, r0, #255
; ARM-NEXT:    moveq pc, lr
; ARM-NEXT:  .LBB1_2: @ %return
; ARM-NEXT:    mov r0, #1
; ARM-NEXT:    mov pc, lr
;
; THUMB-LABEL: bar:
; THUMB:       @ %bb.0: @ %entry
; THUMB-NEXT:    ldrb r2, [r0, #4]
; THUMB-NEXT:    movs r3, #112
; THUMB-NEXT:    ands r2, r3
; THUMB-NEXT:    beq .LBB1_4
; THUMB-NEXT:  @ %bb.1: @ %bb
; THUMB-NEXT:    ldrb r1, [r1, #4]
; THUMB-NEXT:    ands r1, r3
; THUMB-NEXT:    beq .LBB1_4
; THUMB-NEXT:  @ %bb.2: @ %bb2
; THUMB-NEXT:    cmp r2, #16
; THUMB-NEXT:    beq .LBB1_5
; THUMB-NEXT:  @ %bb.3: @ %bb2
; THUMB-NEXT:    cmp r1, #16
; THUMB-NEXT:    beq .LBB1_5
; THUMB-NEXT:  .LBB1_4: @ %return
; THUMB-NEXT:    movs r0, #1
; THUMB-NEXT:    bx lr
; THUMB-NEXT:  .LBB1_5: @ %bb4
; THUMB-NEXT:    movs r1, #255
; THUMB-NEXT:    ands r0, r1
; THUMB-NEXT:    bx lr
;
; T2-LABEL: bar:
; T2:       @ %bb.0: @ %entry
; T2-NEXT:    ldrb r2, [r0, #4]
; T2-NEXT:    ands r2, r2, #112
; T2-NEXT:    itt ne
; T2-NEXT:    ldrbne r1, [r1, #4]
; T2-NEXT:    andsne r1, r1, #112
; T2-NEXT:    beq .LBB1_2
; T2-NEXT:  @ %bb.1: @ %bb2
; T2-NEXT:    cmp r2, #16
; T2-NEXT:    itee ne
; T2-NEXT:    cmpne r1, #16
; T2-NEXT:    uxtbeq r0, r0
; T2-NEXT:    bxeq lr
; T2-NEXT:  .LBB1_2: @ %return
; T2-NEXT:    movs r0, #1
; T2-NEXT:    bx lr
;
; V8-LABEL: bar:
; V8:       @ %bb.0: @ %entry
; V8-NEXT:    ldrb r2, [r0, #4]
; V8-NEXT:    ands r2, r2, #112
; V8-NEXT:    itt ne
; V8-NEXT:    ldrbne r1, [r1, #4]
; V8-NEXT:    andsne r1, r1, #112
; V8-NEXT:    beq .LBB1_2
; V8-NEXT:  @ %bb.1: @ %bb2
; V8-NEXT:    cmp r2, #16
; V8-NEXT:    itee ne
; V8-NEXT:    cmpne r1, #16
; V8-NEXT:    uxtbeq r0, r0
; V8-NEXT:    bxeq lr
; V8-NEXT:  .LBB1_2: @ %return
; V8-NEXT:    movs r0, #1
; V8-NEXT:    bx lr
entry:
  %0 = getelementptr inbounds %struct.S, ptr %x, i32 0, i32 1, i32 0
  %1 = load i8, ptr %0, align 1
  %2 = zext i8 %1 to i32
  %3 = and i32 %2, 112
  %4 = icmp eq i32 %3, 0
  br i1 %4, label %return, label %bb

bb:                                               ; preds = %entry
  %5 = getelementptr inbounds %struct.S, ptr %y, i32 0, i32 1, i32 0
  %6 = load i8, ptr %5, align 1
  %7 = zext i8 %6 to i32
  %8 = and i32 %7, 112
  %9 = icmp eq i32 %8, 0
  br i1 %9, label %return, label %bb2

bb2:                                              ; preds = %bb
  %10 = icmp eq i32 %3, 16
  %11 = icmp eq i32 %8, 16
  %or.cond = or i1 %10, %11
  br i1 %or.cond, label %bb4, label %return

bb4:                                              ; preds = %bb2
  %12 = ptrtoint ptr %x to i32
  %phitmp = trunc i32 %12 to i8
  ret i8 %phitmp

return:                                           ; preds = %bb2, %bb, %entry
  ret i8 1
}


; We were looking through multiple COPY instructions to find an AND we might
; fold into a TST, but in doing so we changed the register being tested allowing
; folding of unrelated tests (in this case, a TST against r1 was eliminated in
; favour of an AND of r0).

define i32 @test_tst_assessment(i32 %a, i32 %b) {
; ARM-LABEL: test_tst_assessment:
; ARM:       @ %bb.0:
; ARM-NEXT:    and r0, r0, #1
; ARM-NEXT:    tst r1, #1
; ARM-NEXT:    subne r0, r0, #1
; ARM-NEXT:    mov pc, lr
;
; THUMB-LABEL: test_tst_assessment:
; THUMB:       @ %bb.0:
; THUMB-NEXT:    movs r2, r0
; THUMB-NEXT:    movs r0, #1
; THUMB-NEXT:    ands r0, r2
; THUMB-NEXT:    lsls r1, r1, #31
; THUMB-NEXT:    beq .LBB2_2
; THUMB-NEXT:  @ %bb.1:
; THUMB-NEXT:    subs r0, r0, #1
; THUMB-NEXT:  .LBB2_2:
; THUMB-NEXT:    bx lr
;
; T2-LABEL: test_tst_assessment:
; T2:       @ %bb.0:
; T2-NEXT:    and r0, r0, #1
; T2-NEXT:    lsls r1, r1, #31
; T2-NEXT:    it ne
; T2-NEXT:    subne r0, #1
; T2-NEXT:    bx lr
;
; V8-LABEL: test_tst_assessment:
; V8:       @ %bb.0:
; V8-NEXT:    and r0, r0, #1
; V8-NEXT:    lsls r1, r1, #31
; V8-NEXT:    it ne
; V8-NEXT:    subne r0, #1
; V8-NEXT:    bx lr
  %and1 = and i32 %a, 1
  %sub = sub i32 %and1, 1
  %and2 = and i32 %b, 1
  %cmp = icmp eq i32 %and2, 0
  %sel = select i1 %cmp, i32 %and1, i32 %sub
  ret i32 %sel
}

!1 = !{!"branch_weights", i32 1, i32 1, i32 3, i32 2 }
