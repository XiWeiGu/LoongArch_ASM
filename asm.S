//
// Contributed by Gu Xiwei(2414434710@qq.com)
//

// The prefix of function name, default is null.
#define ASM_PREF

// Vector instruction sets
#define cpucfg_lsx   0x01 // (1 << 0)
#define cpucfg_lasx  0x03 // (1 << 1) | cpucfg_lsx
#define cpucfg_lsx2  0x05 // (1 << 2) | cpucfg_lsx
#define cpucfg_lasx2 0x0f // (1 << 3) | cpucfg_lsx2 | cpucfg_lasx2 | cpucfg_lsx

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

// The max registers available to the user which
// do not need to be preserved across calls.
// Ref: https://loongson.github.io/LoongArch-Documentation/LoongArch-ELF-ABI-CN.html
#define MAX_INT_CALLER_SAVED 17
#define MAX_FP_CALLER_SAVED  24

.altmacro // Enable alternate macro mode

//
// Auxiliary Macros
//
// function:
// name   = function name.
// cpucfg = specified the vector instruction set.
// align  = align to the specified byte.
// args   = number of arguments. loads them from stack if needed.
// regs   = number of int registers used. pushes callee-saved regs if needed.
// fregs  = number of FP registers used. pushes callee-saved regs if needed.
// stack  = (optional) stack size to be allocated. If the required stack alignment is
//          larger than the defaut stack alignment (16 bytes) the stack will be manually aligned
//          and an extra int register will be specified to hold the original stack
//          pointer if do want to store on stack.
.macro function name:req, /*cpucfg:req,*/ /*align=4,*/ args=0, regs=0, fregs=0/*, stack:vararg*/
.if \cpucfg == cpucfg_lsx
    function_internal ASM_PREF\name\()_lsx, \cpucfg, \align, \args, \regs, \fregs, \stack
.elseif \cpucfg == cpucfg_lasx
    function_internal ASM_PREF\name\()_lasx, \cpucfg, \align, \args, \regs, \fregs, \stack
.else
    function_internal ASM_PREF\name\()_c, \cpucfg, \align, \args, \regs, \fregs, \stack
.endif
.endm // End function
.macro function_internal name:req, cpucfg:req, align=4, args=0, regs=0, fregs=0, stack:vararg
.macro endfunc
.ifnb \stack
    free_stack \cpucfg, \stack
.endif
pop_if_used \regs, \fregs
jirl    $r0, $r1, 0x0
.size \name, . - \name
.purgem endfunc
.endm // End of endfunc
.text ;
.align \align ;
.globl \name ;
.type  \name, @function ;
\name: ;
push_if_used \regs, \fregs
.ifnb \stack
    alloc_stack \cpucfg, \stack
.endif
.endm // End function_internal
.macro alloc_stack cpucfg:req, size:req, reg:vararg
.if \cpucfg == cpucfg_lasx
// For 256-bit vector instructions, the stack requires 32 byte alignment.
// If reg is not empty, save original stack location $sp into reg directly,
// else an additional 8 bytes are allocated on the stack to save original
// stack location $sp (loongarch64).
la.local    $t0,    align_mask
PTR_LD      $t1,    $t0,    0
.ifnb \reg
    or          \reg,   $sp,    $sp
    and         $sp,    $sp,    $t1
    PTR_ADDI    $sp,    $sp,    -\size
.else
    or          $t0,    $sp,    $sp
    and         $sp,    $sp,    $t1
    PTR_ADDI    $sp,    $sp,    -(\size + REG_SIZE)
    PTR_ST      $t0,    $sp,    \size
.endif
.else
    PTR_ADDI    $sp,    $sp,    -\size
.endif
.endm // End alloc_stack
.macro free_stack cpucfg:req, size:req, reg:vararg
.if \cpucfg == cpucfg_lasx
.ifnb \reg
    or          $sp,    \reg,   \reg
.else
    PTR_LD      $sp,    $sp,    \size
.endif
.else
    PTR_ADDI    $sp,    $sp,    \size
.endif
.endm //End free_stack
.macro push_if_used regs, fregs
.if \regs > MAX_INT_CALLER_SAVED
    PTR_ADDI      $sp,    $sp,    -((\regs - MAX_INT_CALLER_SAVED) << REG_LOG)
    push_regs 0, \regs - MAX_INT_CALLER_SAVED - 1
.endif
.if \fregs > MAX_FP_CALLER_SAVED
    PTR_ADDI      $sp,    $sp,    -((\fregs - MAX_FP_CALLER_SAVED) << FREG_LOG)
    push_fregs 0, \fregs - MAX_FP_CALLER_SAVED - 1
.endif
.endm // End push_if_used
.macro pop_if_used regs, fregs
.if \fregs > MAX_FP_CALLER_SAVED
    pop_fregs 0, \fregs - MAX_FP_CALLER_SAVED - 1
    PTR_ADDI      $sp,    $sp,    (\fregs - MAX_FP_CALLER_SAVED) << FREG_LOG
.endif
.if \regs > MAX_INT_CALLER_SAVED
    pop_regs 0, \regs - MAX_INT_CALLER_SAVED - 1
    PTR_ADDI      $sp,    $sp,    (\regs - MAX_INT_CALLER_SAVED) << REG_LOG
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

.macro const name, align=5
.macro endconst
    .size  \name, . - \name
    .purgem endconst
.endm
.section .rodata
.align   \align
\name:
.endm

const align_mask
.dword ~(32 - 1)
endconst


//
// Media Related Macros
//
.macro SBUTTERFLY pre_op, suf_op, in0, in1, out0, out1
    \pre_op\()_template \pre_op\()ilvl.\suf_op, \in0, \in1, \out0
    \pre_op\()_template \pre_op\()ilvh.\suf_op, \in0, \in1, \out1
.endm
.macro INTERLACE pre_op, suf_op, in0, in1, out0, out1
    \pre_op\()_template \pre_op\()pickev.\suf_op, \in0, \in1, \out0
    \pre_op\()_template \pre_op\()pickod.\suf_op, \in0, \in1, \out1
.endm

.macro TRANSPOSE4x4_H pre_op, in0, in1, in2, in3,\
                      out0, out1, out2, out3, vt0, vt1
    ILVL \pre_op, h, \in0, \in1, \vt0, \in2, \in3, \vt1
    SBUTTERFLY \pre_op, w, \vt0, \vt1, \out0, \out2
    ILVH \pre_op, d, \out0, \out0, \out1, \out2, \out0, \out3
.endm

//
// TRANSPOSE8x8_H: Transpose 8x8 block with half-word elements in vectors.
// Typically, eight temporary vector registers are used. In some extreme cases
// vector registers are rare. When the input and output are different vector
// registers, the output is used internally as a temporary vector register so
// that only four temporary vector registers are needed.
//
.macro TRANSPOSE8x8_H pre_op, in0, in1, in2, in3, in4, in5, in6, in7, \
                      out0, out1, out2, out3, out4, out5, out6, out7, \
                      vt0, vt1, vt2, vt3, more:vararg
.ifnb \more
    transpose8x8_h_internal \pre_op, \in0, \in1, \in2, \in3, \in4, \in5, \in6, \in7, \
                            \out0, \out1, \out2, \out3, \out4, \out5, \out6, \out7, \
                            \vt0, \vt1, \vt2, \vt3, \more
.else
    ILVL \pre_op, h, \in4, \in6, \out0, \in5, \in7, \out1, \in0, \in2, \out2, \in1, \in3, \out3
    SBUTTERFLY \pre_op, h, \out0, \out1, \out4, \out5
    SBUTTERFLY \pre_op, h, \out2, \out3, \out6, \out7
    INTERLACE \pre_op, d, \out6, \out4, \out0, \out1
    INTERLACE \pre_op, d, \out7, \out5, \out2, \out3
    ILVH \pre_op, h, \in4, \in6, \out4, \in5, \in7, \out5, \in0, \in2, \out6, \in1, \in3, \out7
    SBUTTERFLY \pre_op, h, \out4, \out5, \vt0, \vt1
    SBUTTERFLY \pre_op, h, \out6, \out7, \vt2, \vt3
    INTERLACE \pre_op, d, \vt2, \vt0, \out4, \out5
    INTERLACE \pre_op, d, \vt3, \vt1, \out6, \out7
.endif
.endm
.macro transpose8x8_h_internal pre_op, in0, in1, in2, in3, in4, in5, in6, in7, \
                               out0, out1, out2, out3, out4, out5, out6, out7, \
                               vt0, vt1, vt2, vt3, vt4, vt5, vt6, vt7
    ILVL \pre_op, h, \in4, \in6, \vt0, \in5, \in7, \vt1, \in0, \in2, \vt2, \in1, \in3, \vt3
    SBUTTERFLY \pre_op, h, \vt0, \vt1, \vt4, \vt5
    SBUTTERFLY \pre_op, h, \vt2, \vt3, \vt6, \vt7
    ILVH \pre_op, h, \in4, \in6, \vt0, \in5, \in7, \vt1, \in0, \in2, \vt2, \in1, \in3, \vt3
    INTERLACE \pre_op, d, \vt6, \vt4, \out0, \out1
    INTERLACE \pre_op, d, \vt7, \vt5, \out2, \out3
    SBUTTERFLY \pre_op, h, \vt0, \vt1, \vt4, \vt5
    SBUTTERFLY \pre_op, h, \vt2, \vt3, \vt6, \vt7
    INTERLACE \pre_op, d, \vt6, \vt4, \out4, \out5
    INTERLACE \pre_op, d, \vt7, \vt5, \out6, \out7
.endm

.macro TRANSPOSE4x4_W pre_op, in0, in1, in2, in3, \
                      out0, out1, out2, out3, vt0, vt1
    SBUTTERFLY \pre_op, w, \in0,  \in1,  \vt0,  \out1
    SBUTTERFLY \pre_op, w, \in2,  \in3,  \vt1,  \out3
    ILVL \pre_op, d, \vt0, \vt1, \out0, \out1, \out3, \out2
    ILVH \pre_op, d, \out1, \out3, \out3, \vt0, \vt1, \out1
.endm

//
// TRANSPOSE8x8_W: Transpose 8x8 block with word elements in vectors,
// has no pre_op param. 128-bit vector instructions are not supported.
//
.macro TRANSPOSE8x8_W in0, in1, in2, in3, in4, in5, in6, in7, \
                      out0, out1, out2, out3, out4, out5, out6, out7, \
                      vt0, vt1, vt2, vt3
    SBUTTERFLY xv, w, \in0, \in2, \vt0, \vt2
    SBUTTERFLY xv, w, \in1, \in3, \vt1, \vt3
    SBUTTERFLY xv, w, \vt0, \vt1, \out0, \out1
    SBUTTERFLY xv, w, \vt2, \vt3, \out2, \out3
    SBUTTERFLY xv, w, \in4, \in6, \vt0, \vt2
    SBUTTERFLY xv, w, \in5, \in7, \vt1, \vt3
    SBUTTERFLY xv, w, \vt0, \vt1, \out4, \out5
    SBUTTERFLY xv, w, \vt2, \vt3, \out6, \out7
    MOV xv, \out0, \vt0, \out1, \vt1, \out2, \vt2, \out3, \vt3
    PERMI xv, q, 0x02, \out4, \out0, 0x02, \out5, \out1, 0x02, \out6, \out2, 0x02, \out7, \out3, \
                 0x31, \vt0, \out4, 0x31, \vt1, \out5, 0x31, \vt2, \out6, 0x31, \vt3, \out7
.endm

//
// TRANSPOSE4x4_D: Transpose 4x4 block with double-word elements in vectors,
// has no pre_op param. 128-bit vector instructions are not supported.
//
.macro TRANSPOSE4x4_D in0, in1, in2, in3, out0, out1, out2, out3, \
                      vt0, vt1
    SBUTTERFLY xv, d, \in0, \in1, \vt0,  \out1
    SBUTTERFLY xv, d, \in2, \in3, \out2, \vt1
    MOV xv, \vt0, \out0, \vt1, \out3
    PERMI xv, q, 0x02, \out2, \out0, 0x31, \vt0, \out2, 0x31, \out1, \out3, 0x02, \vt1, \out1
.endm


//
// Math Related Macros
//
