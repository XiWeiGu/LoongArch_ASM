//
// Contributed by Gu Xiwei(2414434710@qq.com)
//

#define ASM_PREF

#define cpucfg_lsx   0x01 // (1 << 0)
#define cpucfg_lasx  0x03 // (1 << 1) | cpucfg_lsx
#define cpucfg_lsx2  0x05 // (1 << 2) | cpucfg_lsx
#define cpucfg_lasx2 0x0f // (1 << 3) | cpucfg_lsx2 | cpucfg_lasx2 | cpucfg_lsx

.altmacro // Enable alternate macro mode

//
// Auxiliary Macros
//
.macro function name, cpucfg, align=4
.macro endfunc
    jirl    $r0, $r1, 0x0
.if \cpucfg == cpucfg_lsx
    .size ASM_PREF\name\()_lsx, . - ASM_PREF\name\()_lsx
.elseif \cpucfg == cpucfg_lasx
    .size ASM_PREF\name\()_lasx, . - ASM_PREF\name\()_lasx
.endif
    .purgem endfunc
.endm
.text ;
.align \align ;
.if \cpucfg == cpucfg_lsx
.globl ASM_PREF\name\()_lsx ;
.type  ASM_PREF\name\()_lsx, @function ;
ASM_PREF\name\()_lsx: ;
.elseif \cpucfg == cpucfg_lasx
.globl ASM_PREF\name\()_lasx ;
.type  ASM_PREF\name\()_lasx, @function ;
ASM_PREF\name\()_lasx: ;
.endif
.endm
//
// Basic instruction execution template
// *_template: Both input and output are register numbers,
// will be parsed to the specified width.
// *_template2: only output is register number. We can use
// input directly.
//
.macro xv_template ins, in0, in1, out // 256-bit Vector
    \ins $xr\out, $xr\in1, $xr\in0
.endm
.macro v_template ins, in0, in1, out // 128-bit Vector
    \ins $vr\out, $vr\in1, $vr\in0
.endm
.macro f_template ins, in0, in1, out // 64-bit FPR
    \ins $f\out, $f\in1, $f\in0
.endm
.macro xv_template2 ins, in0, in1, out // 256-bit Vector
    \ins $xr\out, \in1, \in0
.endm
.macro v_template2 ins, in0, in1, out // 128-bit Vector
    \ins $vr\out, \in1, \in0
.endm
.macro f_template2 ins, in0, in1, out // 64-bit FPR
    \ins $f\out, \in1, \in0
.endm
//
// Macros parameter check
//
.macro parameter_check start, end, value
.if \end - \start != \value
    .err
.endif
.endm
.macro const name, align=5
.macro endconst
    .size  \name, . - \name
    .purgem endconst
.endm
.section .rodata
.align   \align
\name:
.endm


//
// Instruction Related Macros
//
//
// LD: Support fetch 32-bits, 64-bits, 128-bits and 256-bit from src with stride(imm).
// LD xv, , src, stride, 0, 2: Fetch 256-bit into $xr0, $xr2 with stride
// LD v , , src, stride, 0, 2: Fetch 128-bit into $vr0, $vr2 with stride
// LD f, d, src, stride, 0, 2: Fetch 64-bits into $f0, $f2 with stride
// LD f, s, src, stride, 0, 2: Fetch 32-bits into $f0, $f2 with stride
//
.macro LD pre_op:req, suf_op=0, src:req, stride:req, out:req, more:vararg
.if \suf_op == 0
    \pre_op\()_template2 \pre_op\()ld, 0, \src, \out
.else
    \pre_op\()_template2 \pre_op\()ld.\suf_op, 0, \src, \out
.endif
    addi.d    \src,    \src,   \stride
.ifnb \more
    LD \pre_op, \suf_op, \src, \stride, \more
.endif
.endm
//
// LDX is same as LD except the stride is a register
//
.macro LDX pre_op:req, suf_op=0, src:req, stride:req, out:req, more:vararg
.if \suf_op == 0
    \pre_op\()_template2 \pre_op\()ld, 0, \src, \out
.else
    \pre_op\()_template2 \pre_op\()ld.\suf_op, 0, \src, \out
.endif
    add.d     \src,    \src,   \stride
.ifnb \more
    LDX \pre_op, \suf_op, \src, \stride, \more
.endif
.endm
//
// ST: Support store 32-bits, 64-bits, 128-bits and 256-bit to dst with stride(imm).
// ST xv, , dst, stride, 0, 2: Store 256-bit from $xr0, $xr2 into dst with stride
// ST v , , dst, stride, 0, 2: Store 128-bit from $vr0, $vr2 into dst with stride
// ST f, d, dst, stride, 0, 2: Store 64-bits from $f0, $f2 into dst with stride
// ST f, s, dst, stride, 0, 2: Store 32-bits from $f0, $f2 into dst with stride
//
.macro ST pre_op:req, suf_op=0, dst:req, stride:req, in:req, more:vararg
.if \suf_op == 0
    \pre_op\()_template2 \pre_op\()st, 0, \dst, \in
.else
    \pre_op\()_template2 \pre_op\()st.\suf_op, 0, \dst, \in
.endif
    addi.d    \dst,    \dst,   \stride
.ifnb \more
    ST \pre_op, \suf_op, \dst, \stride, \more
.endif
.endm
//
// STX is same as ST except the stride is a register
//
.macro STX pre_op:req, suf_op=0, dst:req, stride:req, in:req, more:vararg
.if \suf_op == 0
    \pre_op\()_template2 \pre_op\()st, 0, \dst, \in
.else
    \pre_op\()_template2 \pre_op\()st.\suf_op, 0, \dst, \in
.endif
    add.d    \dst,    \dst,   \stride
.ifnb \more
    STX \pre_op, \suf_op, \dst, \stride, \more
.endif
.endm
//
// XOR: Support continuous xor and has no suf_op param.
// XOR xv, 0, 2, 1, 3, 5, 4 is equal to:
// xvxor.v $xr1, $xr2, $xr0
// xvxor.v $xr4, $xr5, $xr3
//
.macro XOR pre_op:req, in0:req, in1:req, out:req, more:vararg
    \pre_op\()_template \pre_op\()xor.v, \in0, \in1, \out
.ifnb \more
    XOR \pre_op, \more
.endif
.endm
//
// ILVL: Support continuous ilvl.
// ILVL xv, w, 0, 2, 1, 3, 5, 4 is equal to:
// xvilvl.w $xr1, $xr2, $xr0
// xvilvl.w $xr4, $xr5, $xr3
//
.macro ILVL pre_op:req, suf_op:req, in0:req, in1:req, out:req, more:vararg
    \pre_op\()_template    \pre_op\()ilvl.\suf_op, \in0, \in1, \out
.ifnb \more
    ILVL \pre_op, \suf_op, \more
.endif
.endm
//
// ILVH: Support continuous ilvh. Like ILVL.
//
.macro ILVH pre_op:req, suf_op:req, in0:req, in1:req, out:req, more:vararg
    \pre_op\()_template    \pre_op\()ilvh.\suf_op, \in0, \in1, \out
.ifnb \more
    ILVH \pre_op, \suf_op, \more
.endif
.endm


//
// Media Related Macros
//
.macro SBUTTERFLY pre_op, suf_op, in0, in1, out0, out1
    \pre_op\()_template \pre_op\()ilvl.\suf_op, \in0, \in1, \out0
    \pre_op\()_template \pre_op\()ilvh.\suf_op, \in0, \in1, \out1
.endm

.macro TRANSPOSE4x4_H pre_op, in0, in1, in2, in3,\
                      out0, out1, out2, out3, vt0, vt1
    ILVL \pre_op, h, \in0, \in1, \vt0, \in2, \in3, \vt1
    SBUTTERFLY \pre_op, w, \vt0, \vt1, \out0, \out2
    ILVH \pre_op, d, \out0, \out0, \out1, \out2, \out0, \out3
.endm

.macro TRANSPOSE4x4_W pre_op, in0, in1, in2, in3, \
                      out0, out1, out2, out3, vt0, vt1
    SBUTTERFLY \pre_op, w, \in0,  \in1,  \vt0,  \out1
    SBUTTERFLY \pre_op, w, \in2,  \in3,  \vt1,  \out3
    ILVL \pre_op, d, \vt0, \vt1, \out0, \out1, \out3, \out2
    ILVH \pre_op, d, \out1, \out3, \out3, \vt0, \vt1, \out1
.endm


//
// Math Related Macros
//
