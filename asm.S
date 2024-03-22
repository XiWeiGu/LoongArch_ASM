//
// Contributed by Gu Xiwei(2414434710@qq.com)
//

//
// MAJOR version: Usage changes, incompatible with previous version.
// MINOR version: Add new macros/functions, or bug fixes.
// MICRO version: Comment changes or implementation changes.
//

#define ASM_VERSION_MAJOR 0
#define ASM_VERSION_MINOR 0
#define ASM_VERSION_MICRO 1

#if __loongarch_grlen == 64
#define LA_REG    int64_t
#define REG_SIZE  8
#define REG_LOG   3
#define PTR_ADDI  addi.d
#define PTR_ADD   add.d
#define PTR_SUB   sub.d
#define PTR_LD    ld.d
#define PTR_ST    st.d
#define PTR_SLLI  slli.d
#define PTR_SRLI  srli.d
#define PTR_ALSL  alsl.d
#else
#define LA_REG    int32_t
#define REG_SIZE  4
#define REG_LOG   2
#define PTR_ADDI  addi.w
#define PTR_ADD   add.w
#define PTR_SUB   sub.w
#define PTR_LD    ld.w
#define PTR_ST    st.w
#define PTR_SLLI  slli.w
#define PTR_SRLI  srli.w
#define PTR_ALSL  alsl.w
#endif

#if __loongarch_frlen == 64
#define FREG_SIZE 8
#define FREG_LOG  3
#define PTR_FLD   fld.d
#define PTR_FST   fst.d
#else
#define FREG_SIZE 4
#define FREG_LOG  2
#define PTR_FLD   fld.s
#define PTR_FST   fst.s
#endif

//
// LoongArch register alias
//
#define a0 $a0
#define a1 $a1
#define a2 $a2
#define a3 $a3
#define a4 $a4
#define a5 $a5
#define a6 $a6
#define a7 $a7

#define t0 $t0
#define t1 $t1
#define t2 $t2
#define t3 $t3
#define t4 $t4
#define t5 $t5
#define t6 $t6
#define t7 $t7
#define t8 $t8

#define s0 $s0
#define s1 $s1
#define s2 $s2
#define s3 $s3
#define s4 $s4
#define s5 $s5
#define s6 $s6
#define s7 $s7
#define s8 $s8

#define zero $zero
#define sp   $sp
#define ra   $ra

#define fa0  $fa0
#define fa1  $fa1
#define fa2  $fa2
#define fa3  $fa3
#define fa4  $fa4
#define fa5  $fa5
#define fa6  $fa6
#define fa7  $fa7
#define ft0  $ft0
#define ft1  $ft1
#define ft2  $ft2
#define ft3  $ft3
#define ft4  $ft4
#define ft5  $ft5
#define ft6  $ft6
#define ft7  $ft7
#define ft8  $ft8
#define ft9  $ft9
#define ft10 $ft10
#define ft11 $ft11
#define ft12 $ft12
#define ft13 $ft13
#define ft14 $ft14
#define ft15 $ft15
#define fs0  $fs0
#define fs1  $fs1
#define fs2  $fs2
#define fs3  $fs3
#define fs4  $fs4
#define fs5  $fs5
#define fs6  $fs6
#define fs7  $fs7

#define f0  $f0
#define f1  $f1
#define f2  $f2
#define f3  $f3
#define f4  $f4
#define f5  $f5
#define f6  $f6
#define f7  $f7
#define f8  $f8
#define f9  $f9
#define f10 $f10
#define f11 $f11
#define f12 $f12
#define f13 $f13
#define f14 $f14
#define f15 $f15
#define f16 $f16
#define f17 $f17
#define f18 $f18
#define f19 $f19
#define f20 $f20
#define f21 $f21
#define f22 $f22
#define f23 $f23
#define f24 $f24
#define f25 $f25
#define f26 $f26
#define f27 $f27
#define f28 $f28
#define f29 $f29
#define f30 $f30
#define f31 $f31

#define vr0 $vr0
#define vr1 $vr1
#define vr2 $vr2
#define vr3 $vr3
#define vr4 $vr4
#define vr5 $vr5
#define vr6 $vr6
#define vr7 $vr7
#define vr8 $vr8
#define vr9 $vr9
#define vr10 $vr10
#define vr11 $vr11
#define vr12 $vr12
#define vr13 $vr13
#define vr14 $vr14
#define vr15 $vr15
#define vr16 $vr16
#define vr17 $vr17
#define vr18 $vr18
#define vr19 $vr19
#define vr20 $vr20
#define vr21 $vr21
#define vr22 $vr22
#define vr23 $vr23
#define vr24 $vr24
#define vr25 $vr25
#define vr26 $vr26
#define vr27 $vr27
#define vr28 $vr28
#define vr29 $vr29
#define vr30 $vr30
#define vr31 $vr31

#define xr0 $xr0
#define xr1 $xr1
#define xr2 $xr2
#define xr3 $xr3
#define xr4 $xr4
#define xr5 $xr5
#define xr6 $xr6
#define xr7 $xr7
#define xr8 $xr8
#define xr9 $xr9
#define xr10 $xr10
#define xr11 $xr11
#define xr12 $xr12
#define xr13 $xr13
#define xr14 $xr14
#define xr15 $xr15
#define xr16 $xr16
#define xr17 $xr17
#define xr18 $xr18
#define xr19 $xr19
#define xr20 $xr20
#define xr21 $xr21
#define xr22 $xr22
#define xr23 $xr23
#define xr24 $xr24
#define xr25 $xr25
#define xr26 $xr26
#define xr27 $xr27
#define xr28 $xr28
#define xr29 $xr29
#define xr30 $xr30
#define xr31 $xr31

// The max registers available to the user which
// do not need to be preserved across calls.
// Ref: https://loongson.github.io/LoongArch-Documentation/LoongArch-ELF-ABI-CN.html
#define MAX_INT_CALLER_SAVED 17
#define MAX_FP_CALLER_SAVED  24

// The prefix of function name, default is null.
#define ASM_PREF
#define DEFAULT_ALIGN=5

.altmacro // Enable alternate macro mode

// Define a function
.macro function name, align=DEFAULT_ALIGN
.macro endfunc
    jirl    $r0, $r1, 0x0
    .size ASM_PREF\name, . - ASM_PREF\name
    .purgem endfunc
.endm
.text ;
.align \align ;
.globl ASM_PREF\name ;
.type  ASM_PREF\name, @function ;
ASM_PREF\name: ;
.endm

// Define a const
.macro const name, align=DEFAULT_ALIGN
    .macro endconst
    .size  \name, . - \name
    .purgem endconst
    .endm
.section .rodata
.align   \align
\name:
.endm

// Pushing and popping static registers onto/from the stack.
// regs: number of static general-purpose registers, greater than or equal to 0, less than or equal to 9
// fregs: number of static floating-point registers, greater than or equal to 0, less than or equal to 8
.macro push_if_used regs, fregs
.if \regs > 0
    PTR_ADDI      $sp,    $sp,    -(\regs << REG_LOG)
    push_regs 0, \regs - 1
.endif
.if \fregs > 0
    PTR_ADDI      $sp,    $sp,    -(\fregs << FREG_LOG)
    push_fregs 0, \fregs - 1
.endif
.endm // End push_if_used

.macro pop_if_used regs, fregs
.if \fregs > 0
    pop_fregs 0, \fregs - 1
    PTR_ADDI      $sp,    $sp,    (\fregs) << FREG_LOG
.endif
.if \regs > 0
    pop_regs 0, \regs - 1
    PTR_ADDI      $sp,    $sp,    (\regs) << REG_LOG
.endif
.endm // End pop_if_used

.macro push_regs from, to
    PTR_ST    $s\()\from,     $sp,    \from << REG_LOG
.if \to - \from
    push_regs %from + 1, \to
.endif
.endm // End push_regs

.macro pop_regs from, to
    PTR_LD    $s\()\from,     $sp,    \from << REG_LOG
.if \to - \from
    pop_regs %from + 1, \to
.endif
.endm // End pop_regs

.macro push_fregs from, to
    PTR_FST   $fs\()\from,    $sp,    \from << FREG_LOG
.if \to - \from
    push_fregs %from + 1, \to
.endif
.endm // End push_fregs
.macro pop_fregs from, to
    PTR_FLD   $fs\()\from,    $sp,    \from << FREG_LOG
.if \to - \from
    pop_fregs %from + 1, \to
.endif
.endm // End pop_fregs

//
// Instruction Related Macros
//
// GLD
//
.macro GLD pre_op:req, suf_op=0, out:req, src:req, offset:req/* imm */, more:vararg
.ifeqs "\suf_op", "0"
    \pre_op\()ld    \out,   \src,   \offset
.else
    \pre_op\()ld.\suf_op    \out,   \src,   \offset
.endif
.ifnb \more
    GLD \pre_op, \suf_op, \more
.endif
.endm
//
// GLD_INC
//
.macro GLD_INC pre_op:req, suf_op=0, inc:req, out:req, src:req, offset:req/* imm */, more:vararg
.ifeqs "\suf_op", "0"
    \pre_op\()ld    \out,   \src,   \offset
.else
    \pre_op\()ld.\suf_op    \out,   \src,   \offset
.endif
    PTR_ADDI  \src,   \src,   \inc
.ifnb \more
    GLD_INC \pre_op, \suf_op, \inc, \more
.endif
.endm
//
// GLDX is same as GLD except the stride is a register
//
.macro GLDX pre_op:req, suf_op=0, out:req, src:req, offset:req/* reg */, more:vararg
.ifeqs "\suf_op", "0"
    \pre_op\()ldx    \out,   \src,   \offset
.else
    \pre_op\()ldx.\suf_op    \out,   \src,   \offset
.endif
.ifnb \more
    GLDX \pre_op, \suf_op, \more
.endif
.endm
//
// GLDREPL
//
.macro GLDREPL pre_op:req, suf_op:req, out:req, src:req, offset:req/* imm */, more:vararg
    \pre_op\()ldrepl.\suf_op    \out,   \src,   \offset
.ifnb \more
    GLDREPL  \pre_op, \suf_op, \more
.endif
.endm
//
// GST
//
.macro GST pre_op:req, suf_op=0, src:req, dst:req, offset:req/* imm */, more:vararg
.ifeqs "\suf_op", "0"
    \pre_op\()st    \src,   \dst,   \offset
.else
    \pre_op\()st.\suf_op \src,  \dst, \offset
.endif
.ifnb \more
    GST \pre_op, \suf_op, \more
.endif
.endm
//
// GMUL
//
.macro GMUL pre_op, suf_op:req, out:req, in0:req, in1:req, more:vararg
    \pre_op\()mul.\suf_op   \out,   \in0,   \in1
.ifnb \more
    GMUL \pre_op, \suf_op, \more
.endif
.endm
//
// GMADD
//
.macro GMADD pre_op, suf_op:req, out:req, in0:req, in1:req, in2:req, more:vararg
    \pre_op\()madd.\suf_op \out, \in0, \in1, \in2
.ifnb \more
    GMADD \pre_op, \suf_op, \more
.endif
.endm
//
// GADD
//
.macro GADD pre_op, suf_op:req, out:req, in0:req, in1:req, more:vararg
    \pre_op\()add.\suf_op \out, \in0, \in1
.ifnb \more
    GADD \pre_op, \suf_op, \more
.endif
.endm
//
// GADDI
//
.macro GADDI pre_op, suf_op:req, out:req, in0:req, in1:req, more:vararg
    \pre_op\()addi.\suf_op  \out,   \in0,   \in1
.ifnb \more
    GADDI \pre_op, \suf_op, \more
.endif
.endm
//
// GSUB
//
.macro GSUB pre_op, suf_op:req, out:req, in0:req, in1:req, more:vararg
    \pre_op\()sub.\suf_op \out, \in0, \in1
.ifnb \more
    GSUB \pre_op, \suf_op, \more
.endif
.endm
//
// GSLLI
//
.macro GSLLI pre_op, suf_op:req, out:req, in0:req, in1:req, more:vararg
    \pre_op\()slli.\suf_op  \out,   \in0,   \in1
.ifnb \more
    GSLLI \pre_op, \suf_op, \more
.endif
.endm
//
// GINSVE0
//
.macro GINSVE0 pre_op:req, suf_op:req, out:req, in0:req, in1:req, more:vararg
    \pre_op\()insve0.\suf_op    \out,   \in0,   \in1
.ifnb \more
    GINSVE0 \pre_op, \suf_op, \more
.endif
.endm
//
// GXOR
//
.macro GXOR pre_op:req, suf_op:req, out:req, in0:req, in1:req, more:vararg
    \pre_op\()xor.\suf_op    \out,   \in0,   \in1
.ifnb \more
    GXOR \pre_op, \suf_op, \more
.endif
.endm
//
// GPERMI
//
.macro GPERMI pre_op:req, suf_op:req, out:req, in0:req, in1:req, more:vararg
    \pre_op\()permi.\suf_op     \out,   \in0,   \in1
.ifnb \more
    GPERMI \pre_op, \suf_op, \more
.endif
.endm
//
// GNMSUB
//
.macro GNMSUB pre_op:req, suf_op:req, out:req, in0:req, in1:req, in2:req, more:vararg
    \pre_op\()nmsub.\suf_op     \out,   \in0,   \in1,   \in2
.ifnb \more
    GNMSUB \pre_op, \suf_op, \more
.endif
.endm
//
// GPRELD
//
.macro GPRELD in0:req, in1:req, in2:req, more:vararg
    preld \in0, \in1, \in2
.ifnb \more
    GPRELD \more
.endif
.endm

//
// Compound instructions
//
// GACC: Accumulate the values of vector registers
//
.macro GACC pre_op:req, suf_op:req, out:req, in:req, more:vararg
.ifeqs "\pre_op", "xvf"
    xvpermi.q              \out,   \in,    0x01
    \pre_op\()add.\suf_op  \in,    \out,   \in
    xvpackod.d             \out,   \in,    \in
    \pre_op\()add.\suf_op  \out,   \out,   \in
.ifeqs "\suf_op", "s"
    xvpackod.w             \in,    \out,   \out
    \pre_op\()add.\suf_op  \out,   \out,   \in
.endif
.endif

.ifeqs "\pre_op", "vf"
    vpackod.d              \out,   \in,    \in
    \pre_op\()add.\suf_op  \out,   \out,   \in
.ifeqs "\suf_op", "s"
    vpackod.w              \in,    \out,   \out
    \pre_op\()add.\suf_op  \out,   \out,   \in
.endif
.endif

.ifeqs "\pre_op", "xv"
    xvpermi.q              \out,   \in,    0x01
    \pre_op\()add.\suf_op  \in,    \out,   \in
    xvpackod.d             \out,   \in,    \in
    \pre_op\()add.\suf_op  \out,   \out,   \in
.ifnc "\suf_op", "d"
    xvpackod.w             \in,    \out,   \out
    \pre_op\()add.\suf_op  \out,   \out,   \in
.ifnc "\suf_op", "w"
    xvpackod.h             \in,    \out,   \out
    \pre_op\()add.\suf_op  \out,   \out,   \in
.ifnc "\suf_op", "h"
    xvpackod.b             \in,    \out,   \out
    \pre_op\()add.\suf_op  \out,   \out,   \in
.endif
.endif
.endif
.endif

.ifeqs "\pre_op", "v"
    vpackod.d              \out,   \in,    \in
    \pre_op\()add.\suf_op  \out,   \out,   \in
.ifnc "\suf_op", "d"
    vpackod.w              \in,    \out,   \out
    \pre_op\()add.\suf_op  \out,   \out,   \in
.ifnc "\suf_op", "w"
    vpackod.h              \in,    \out,   \out
    \pre_op\()add.\suf_op  \out,   \out,   \in
.ifnc "\suf_op", "h"
    vpackod.b              \in,    \out,   \out
    \pre_op\()add.\suf_op  \out,   \out,   \in
.endif
.endif
.endif
.endif

.ifnb \more
    GACC \pre_op, \suf_op, \more
.endif
.endm
//
// GMOV
//
.macro GMOV pre_op:req, out:req, in:req, more:vararg
    \pre_op\()or.v  \out, \in, \in
.ifnb \more
    GMOV \pre_op, \more
.endif
.endm
//
// GCOMPLEXACC: Complex accumulate the values of vector registers
// pre_op: xvf or vf, differentiate between LSX or LASX instruction
// suf_op: s or d, differentiate between single precision or double precision complex numbers
// Note: When "pre_op = xvf && suf_op = s", in will be modified.
//
.macro GCOMPLEXACC pre_op:req, suf_op:req, out:req, in:req, more:vararg
.ifeqs "\pre_op", "xvf"
    xvpermi.q              \out,   \in,    0x01
.ifeqs "\suf_op", "s"
    \pre_op\()add.\suf_op  \in,    \out,   \in
    xvpackod.d             \out,   \in,    \in
    \pre_op\()add.\suf_op  \out,   \out,   \in
.else
    \pre_op\()add.\suf_op  \out,   \out,   \in
.endif
.endif

.ifeqs "\pre_op", "vf"
.ifeqs "\suf_op", "s"
    vpackod.d              \out,   \in,    \in
    \pre_op\()add.\suf_op  \out,   \out,   \in
.endif
.endif

.ifnb \more
    GCOMPLEXACC \pre_op, \suf_op, \more
.endif
.endm
//
// GCOMPLEXMUL: Complex multiplication, out = in0 * in1
// xconj: default value 0.
// if !(xconj)
//     out_r = in0_r * in1_r - in0_i * in1_i;
//     out_i = in0_r * in1_i + in0_i * in1_r;
// else
//     out_r = in0_r * in1_r + in0_i * in1_i;
//     out_i = in0_r * in1_i - in0_i * in1_r;
// pre_op: xvf or vf, differentiate between LSX or LASX instruction
// suf_op: s or d, differentiate between single precision or double precision complex numbers
//
.macro GCOMPLEXMUL xconj=0, pre_op:req, suf_op:req, out:req, in0:req, in1:req, tmp0:req, tmp1:req, tmp2:req, more:vararg
.ifeqs "\pre_op", "xvf"
    xvxor.v           \tmp1,     \tmp1,     \tmp1
.ifeqs "\suf_op", "s"
    xvpackev.w  \tmp0,     \in0,      \in0
.else
    xvpackev.d  \tmp0,     \in0,      \in0
.endif
.else
    vxor.v           \tmp1,     \tmp1,     \tmp1
.ifeqs "\suf_op", "s"
    vpackev.w  \tmp0,     \in0,      \in0
.else
    vpackev.d  \tmp0,     \in0,      \in0
.endif
.endif

    \pre_op\()sub.\suf_op    \tmp1,     \tmp1,     \in0

.ifeqs "\pre_op", "xvf"
.ifeqs "\suf_op", "s"
.ifeqs "\xconj", "0"
    xvpackod.w  \tmp1,     \in0,      \tmp1
.else
    xvpackod.w  \tmp1,     \tmp1,     \in0
.endif
    xvshuf4i.w  \tmp2,     \in1,      0xb1
.else
.ifeqs "\xconj", "0"
    xvpackod.d  \tmp1,     \in0,      \tmp1
.else
    xvpackod.d  \tmp1,     \tmp1,     \in0
.endif
    xvshuf4i.d  \tmp2,     \in1,      0x0b
.endif
.else
.ifeqs "\suf_op", "s"
.ifeqs "\xconj", "0"
    vpackod.w  \tmp1,     \in0,      \tmp1
.else
    vpackod.w  \tmp1,     \tmp1,     \in0
.endif
    vshuf4i.w  \tmp2,     \in1,      0xb1
.else
.ifeqs "\xconj", "0"
    vpackod.d  \tmp1,     \in0,      \tmp1
.else
    vpackod.d  \tmp1,     \tmp1,     \in0
.endif
    vshuf4i.d  \tmp2,     \in1,      0x0b
.endif
.endif

    \pre_op\()mul.\suf_op    \out,      \tmp0,     \in1
    \pre_op\()madd.\suf_op   \out,      \tmp1,     \tmp2,     \out

.ifnb \more
    GCOMPLEXMUL \xconj, \pre_op, \suf_op, \more
.endif
.endm
//
// GCOMPLEXMADD: Complex multiply-accumulate, out = in0 * in1 + in2
// xconj: default value 0
// conj: default value 0
// if !(CONJ)
// if !(XCONJ)
//     out_r = in0_r * in1_r - in0_i * in1_i + in2_r;
//     out_i = in0_r * in1_i + in0_i * in1_r + in2_i;
// else
//     out_r = in0_r * in1_r + in0_i * in1_i + in2_r;
//     out_i = in0_r * in1_i - in0_i * in1_r + in2_i;
// else
// if !(XCONJ)
//     out_r = in0_r * in1_r + in0_i * in1_i + in2_r;
//     out_i = in2_i - (in0_r * in1_i - in0_i * in1_r);
// else
//     out_r = in0_r * in1_r   - in0_i * in1_i + in2_r;
//     out_i = in2_i - (in0_r * in1_i + in0_i * in1_r);
// pre_op: xvf or vf, differentiate between LSX or LASX instruction
// suf_op: s or d, differentiate between single precision or double precision complex numbers
//
.macro GCOMPLEXMADD xconj=0, conj=0, pre_op:req, suf_op:req, out:req, in0:req, in1:req, in2:req, tmp0:req, tmp1:req, tmp2:req, more:vararg
.ifeqs "\pre_op", "xvf"
    xvxor.v           \tmp1,     \tmp1,     \tmp1
.ifeqs "\suf_op", "s"
    xvpackev.w  \tmp0,     \in0,      \in0
.else
    xvpackev.d  \tmp0,     \in0,      \in0
.endif
.else
    vxor.v           \tmp1,     \tmp1,     \tmp1
.ifeqs "\suf_op", "s"
    vpackev.w  \tmp0,     \in0,      \in0
.else
    vpackev.d  \tmp0,     \in0,      \in0
.endif
.endif

    \pre_op\()madd.\suf_op   \tmp2,      \tmp0,     \in1,      \in2
.ifeqs "\conj", "1"
    \pre_op\()nmsub.\suf_op  \tmp0,      \tmp0,     \in1,      \in2
.ifeqs "\pre_op", "xvf"
.ifeqs "\suf_op", "s"
    xvshuf4i.w  \tmp0,     \tmp0,      0xb1
    xvpackev.w  \out,      \tmp0,      \tmp2
.else
    xvshuf4i.d  \tmp0,     \tmp0,      0x0b
    xvpackev.d  \out,      \tmp0,      \tmp2
.endif
.else
.ifeqs "\suf_op", "s"
    vshuf4i.w  \tmp0,     \tmp0,      0xb1
    vpackev.w  \out,      \tmp0,      \tmp2
.else
    vshuf4i.d  \tmp0,     \tmp0,      0x0b
    vpackev.d  \out,      \tmp0,      \tmp2
.endif
.endif /* pre_op = xvf */
.else
    \pre_op\()add.\suf_op    \out,     \tmp2,     \tmp1
.endif /* conj = 1 */

    \pre_op\()sub.\suf_op    \tmp1,     \tmp1,     \in0

.ifeqs "\pre_op", "xvf"
.ifeqs "\suf_op", "s"
.ifeqs "\conj",  "0"
.ifeqs "\xconj", "0"
    xvpackod.w  \tmp1,     \in0,      \tmp1
.else
    xvpackod.w  \tmp1,     \tmp1,     \in0
.endif
.else
.ifeqs "\xconj", "0"
    xvpackod.w  \tmp1,     \in0,     \in0
.else
    xvpackod.w  \tmp1,     \tmp1,     \tmp1
.endif
.endif
    xvshuf4i.w  \tmp2,     \in1,      0xb1
.else
.ifeqs "\conj",  "0"
.ifeqs "\xconj", "0"
    xvpackod.d  \tmp1,     \in0,      \tmp1
.else
    xvpackod.d  \tmp1,     \tmp1,     \in0
.endif
.else
.ifeqs "\xconj", "0"
    xvpackod.d  \tmp1,     \in0,     \in0
.else
    xvpackod.d  \tmp1,     \tmp1,    \tmp1
.endif
.endif
    xvshuf4i.d  \tmp2,     \in1,      0x0b
.endif
.else
.ifeqs "\suf_op", "s"
.ifeqs "\conj",  "0"
.ifeqs "\xconj", "0"
    vpackod.w  \tmp1,     \in0,      \tmp1
.else
    vpackod.w  \tmp1,     \tmp1,     \in0
.endif
.else
.ifeqs "\xconj", "0"
    vpackod.w  \tmp1,     \in0,     \in0
.else
    vpackod.w  \tmp1,     \tmp1,    \tmp1
.endif
.endif
    vshuf4i.w  \tmp2,     \in1,      0xb1
.else
.ifeqs "\conj",  "0"
.ifeqs "\xconj", "0"
    vpackod.d  \tmp1,     \in0,      \tmp1
.else
    vpackod.d  \tmp1,     \tmp1,     \in0
.endif
.else
.ifeqs "\xconj", "0"
    vpackod.d  \tmp1,     \in0,     \in0
.else
    vpackod.d  \tmp1,     \tmp1,    \tmp1
.endif
.endif
    vshuf4i.d  \tmp2,     \in1,      0x0b
.endif
.endif

    \pre_op\()madd.\suf_op   \out,      \tmp1,     \tmp2,     \out

.ifnb \more
    GCOMPLEXMADD \xconj, \conj, \pre_op, \suf_op, \more
.endif
.endm

//
// Media Related Macros
//
//
// GSBUTTERFLY
//
.macro GSBUTTERFLY pre_op, suf_op, out0, out1, in0, in1
    \pre_op\()ilvl.\suf_op \out0, \in0, \in1
    \pre_op\()ilvh.\suf_op \out1, \in0, \in1
.endm
.macro GINTERLACE pre_op, suf_op, out0, out1, in0, in1
    \pre_op\()pickev.\suf_op \out0, \in0, \in1
    \pre_op\()pickod.\suf_op \out1, \in0, \in1
.endm
//
// TRANSPOSE4x4_D: Transpose 4x4 block with double-word elements in vectors,
// has no pre_op param. 128-bit vector instructions are not supported.
//
.macro GTRANSPOSE4x4_D in0, in1, in2, in3, out0, out1, out2, out3, \
                       vt0, vt1
    GSBUTTERFLY xv, d, \vt0, \out1, \in1, \in0
    GSBUTTERFLY xv, d, \vt1, \out3, \in3, \in2
    GMOV xv, \out0, \vt0, \out2, \vt1, \vt1, \out3
    GPERMI xv, q, \out0, \out2, 0x02, \out2, \vt0, 0x31, \out3, \out1, 0x31, \out1, \vt1, 0x02
.endm
//
// GTRANSPOSE8x8_W
//
.macro GTRANSPOSE8x8_W out0, out1, out2, out3, out4, out5, out6, out7, \
                       in0, in1, in2, in3, in4, in5, in6, in7, \
                       tmp0, tmp1, tmp2, tmp3
    GSBUTTERFLY xv, w, \tmp0, \tmp2, \in2, \in0
    GSBUTTERFLY xv, w, \tmp1, \tmp3, \in3, \in1
    GSBUTTERFLY xv, w, \out0, \out1, \tmp1, \tmp0
    GSBUTTERFLY xv, w, \out2, \out3, \tmp3, \tmp2

    GSBUTTERFLY xv, w, \tmp0, \tmp2, \in6, \in4
    GSBUTTERFLY xv, w, \tmp1, \tmp3, \in7, \in5
    GSBUTTERFLY xv, w, \out4, \out5, \tmp1, \tmp0
    GSBUTTERFLY xv, w, \out6, \out7, \tmp3, \tmp2

    GMOV xv, \tmp0, \out0, \tmp1, \out1, \tmp2, \out2, \tmp3, \out3

    GPERMI xv, q, \out0, \out4, 0x02, \out1, \out5, 0x02, \
                  \out2, \out6, 0x02, \out3, \out7, 0x02, \
                  \out4, \tmp0, 0x31, \out5, \tmp1, 0x31, \
                  \out6, \tmp2, 0x31, \out7, \tmp3, 0x31
.endm