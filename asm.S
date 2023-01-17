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
// LD: Support continuous fetch 32-bits, 64-bits, 128-bits and 256-bit
// from src with stride(imm).
// LD xv, , src, stride, 0, 2: Fetch 256-bit into $xr0, $xr1, $xr2 with stride
// LD v , , src, stride, 0, 2: Fetch 128-bit into $vr0, $vr1, $vr2 with stride
// LD f, d, src, stride, 0, 2: Fetch 64-bits into $f0, $f1, $f2 with stride
// LD f, s, src, stride, 0, 2: Fetch 32-bits into $f0, $f1, $f2 with stride
//
.macro LD pre_op, suf_op=0, src, stride, out_start=0, out_end
.if \suf_op == 0
    \pre_op\()_template2 \pre_op\()ld, 0, \src, \out_start
.else
    \pre_op\()_template2 \pre_op\()ld.\suf_op, 0, \src, \out_start
.endif
    addi.d    \src,    \src,   \stride
.if \out_end - \out_start
    LD \pre_op, \suf_op, \src, \stride, %out_start + 1, \out_end
.endif
.endm
//
// LDX is same as LD except the stride is a register
//
.macro LDX pre_op, suf_op=0, src, stride, out_start=0, out_end
.if \suf_op == 0
    \pre_op\()_template2 \pre_op\()ld, 0, \src, \out_start
.else
    \pre_op\()_template2 \pre_op\()ld.\suf_op, 0, \src, \out_start
.endif
    add.d     \src,    \src,   \stride
.if \out_end - \out_start
    LDX \pre_op, \suf_op, \src, \stride, %out_start + 1, \out_end
.endif
.endm
//
// ST: Support continuous fetch 32-bits, 64-bits, 128-bits and 256-bit
// from src with stride(imm).
// ST xv, , src, stride, 0, 2: Fetch 256-bit into $xr0, $xr1, $xr2 with stride
// ST v , , src, stride, 0, 2: Fetch 128-bit into $vr0, $vr1, $vr2 with stride
// ST f, d, src, stride, 0, 2: Fetch 64-bits into $f0, $f1, $f2 with stride
// ST f, s, src, stride, 0, 2: Fetch 32-bits into $f0, $f1, $f2 with stride
//
.macro ST pre_op, suf_op=0, src, stride, out_start=0, out_end=0
.if \suf_op == 0
    \pre_op\()_template2 \pre_op\()st, 0, \src, \out_start
.else
    \pre_op\()_template2 \pre_op\()st.\suf_op, 0, \src, \out_start
.endif
    addi.d    \src,    \src,   \stride
.if \out_end == 0
    .exitm
.endif
.if \out_end - \out_start
    ST \pre_op, \suf_op, \src, \stride, %out_start + 1, \out_end
.endif
.endm
//
// STX is same as ST except the stride is a register
//
.macro STX pre_op, suf_op=0, src, stride, out_start=0, out_end
.if \suf_op == 0
    \pre_op\()_template2 \pre_op\()st, 0, \src, \out_start
.else
    \pre_op\()_template2 \pre_op\()st.\suf_op, 0, \src, \out_start
.endif
    add.d    \src,    \src,   \stride
.if \out_end - \out_start
    STX \pre_op, \suf_op, \src, \stride, %out_start + 1, \out_end
.endif
.endm
//
// XOR: Support continuous xor and has no suf_op param.
// if (in_end - in_start) == (out_end - out_start),
// Means that the input parameters of the instruction
// are consistent, like vxor.v vr1, vr0, vr0.
// Otherwise the input parameter of the instruction
// is incremented, like vxor.v vr2, vr1, vr0.
//
.macro XOR pre_op, in_start, in_end, out_start, out_end=0
.if (\in_end - \in_start) == (\out_end - \out_start)
    \pre_op\()_template \pre_op\()xor.v, \in_start, \in_start, \out_start
    .if \in_end - \in_start
        XOR \pre_op, %in_start + 1, \in_end, %out_start + 1, \out_end
    .endif
.else
    \pre_op\()_template \pre_op\()xor.v, \in_start, %in_start + 1, \out_start
    .if \in_end - \in_start - 1
        XOR \pre_op, %in_start + 2, \in_end, %out_start + 1, \out_end
    .endif
.endif
.endm
//
// ILVL: Support continuous ilvl.
// There are two cases, see XOR for details.
//
.macro ILVL pre_op, suf_op, in_start, in_end, out_start, out_end=0
.if (\in_end - \in_start) == (\out_end - \out_start)
    \pre_op\()_template    \pre_op\()ilvl.\suf_op, \in_start, \in_start, \out_start
    .if \in_end - \in_start
        ILVL \pre_op, suf_op, %in_start + 1, \in_end, %out_start + 1, \out_end
    .endif
.else
    \pre_op\()_template    \pre_op\()ilvl.\suf_op, \in_start, %in_start + 1, \out_start
    .if \in_end - \in_start - 1
        ILVL \pre_op, suf_op, %in_start + 2, \in_end, %out_start + 1, \out_end
    .endif
.endif
.endm


//
// Media Related Macros
//
.macro SBUTTERFLY pre_op, suf_op, in0, in1, out0, out1
    \pre_op\()_template \pre_op\()ilvl.\suf_op, \in0, \in1, \out0
    \pre_op\()_template \pre_op\()ilvh.\suf_op, \in0, \in1, \out1
.endm

.macro TRANSPOSE4x4_H pre_op, in_start, in_end, \
                      out_start, out_end, vt_start, vt_end
    ILVL \pre_op, h, \in_start, \in_end, \vt_start
    SBUTTERFLY \pre_op, w, \vt_start, %vt_start + 1, \out_start, %out_start + 2
.endm

.macro TRANSPOSE4x4_W pre_op, in_start, in_end, \
                      out_start, out_end, vt_start, vt_end
    parameter_check \in_start,  \in_end,  3
    parameter_check \out_start, \out_end, 3
    parameter_check \vt_start,  \vt_end,  1
    SBUTTERFLY \pre_op, w, \in_start, %in_start + 1, \vt_start, %out_start + 1
    SBUTTERFLY \pre_op, w, %in_start + 2, %in_start + 3, %vt_start + 1, %out_start + 3
    SBUTTERFLY \pre_op, d, \vt_start, %vt_start + 1, \out_start, %out_start + 1
    SBUTTERFLY \pre_op, d, %out_start + 1,  %out_start + 3, %out_start + 2, %out_start + 3
.endm


//
// Math Related Macros
//
