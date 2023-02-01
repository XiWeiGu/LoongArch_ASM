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

#ifdef __LP64__
// The size of int register and FP register.
#define REG_SIZE 3
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
.macro function name:req, cpucfg:req, align=4, args=0, regs=0, fregs=0, stack:vararg
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
ld.d        $t1,    $t0,    0
.ifnb \reg
    or      \reg,   $sp,    $sp
    and     $sp,    $sp,    $t1
    addi.d  $sp,    $sp,    -\size
.else
    or      $t0,    $sp,    $sp
    and     $sp,    $sp,    $t1
    addi.d  $sp,    $sp,    -(\size + 8)
    st.d    $t0,    $sp,    \size
.endif
.else
    addi.d  $sp,    $sp,    -\size
.endif
.endm // End alloc_stack
.macro free_stack cpucfg:req, size:req, reg:vararg
.if \cpucfg == cpucfg_lasx
.ifnb \reg
    or      $sp,    \reg,   \reg
.else
    ld.d    $sp,    $sp,    \size
.endif
.else
    addi.d  $sp,    $sp,    \size
.endif
.endm //End free_stack
.macro push_if_used regs, fregs
.if \regs > MAX_INT_CALLER_SAVED
    addi.d      $sp,    $sp,    -((\regs - MAX_INT_CALLER_SAVED) << REG_SIZE)
    push_regs 0, \regs - MAX_INT_CALLER_SAVED - 1
.endif
.if \fregs > MAX_FP_CALLER_SAVED
    addi.d      $sp,    $sp,    -((\fregs - MAX_FP_CALLER_SAVED) << REG_SIZE)
    push_fregs 0, \fregs - MAX_FP_CALLER_SAVED - 1
.endif
.endm // End push_if_used
.macro pop_if_used regs, fregs
.if \fregs > MAX_FP_CALLER_SAVED
    pop_fregs 0, \fregs - MAX_FP_CALLER_SAVED - 1
    addi.d      $sp,    $sp,    (\fregs - MAX_FP_CALLER_SAVED) << REG_SIZE
.endif
.if \regs > MAX_INT_CALLER_SAVED
    pop_regs 0, \regs - MAX_INT_CALLER_SAVED - 1
    addi.d      $sp,    $sp,    (\regs - MAX_INT_CALLER_SAVED) << REG_SIZE
.endif
.endm // End pop_if_used
.macro push_regs from, to
    st.d    $s\()\from,     $sp,    \from << REG_SIZE
.if \to - \from
    push_regs %from + 1, \to
.endif
.endm // End push_regs
.macro pop_regs from, to
    ld.d    $s\()\from,     $sp,    \from << REG_SIZE
.if \to - \from
    pop_regs %from + 1, \to
.endif
.endm // End pop_regs
.macro push_fregs from, to
    fst.d   $fs\()\from,    $sp,    \from << REG_SIZE
.if \to - \from
    push_fregs %from + 1, \to
.endif
.endm // End push_fregs
.macro pop_fregs from, to
    fld.d   $fs\()\from,    $sp,    \from << REG_SIZE
.if \to - \from
    pop_fregs %from + 1, \to
.endif
.endm // End pop_fregs
//
// Basic instruction execution template
// *_template: Both input and output are register numbers,
// will be parsed to the specified width.
// *_template2: only output is register number, using
// input directly.
// *_template3: output and in1 are register number, using
// in0 directly.
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
.macro xv_template3 ins, in0, in1, out // 256-bit Vector
    \ins $xr\out, $xr\in1, \in0
.endm
.macro v_template3 ins, in0, in1, out // 128-bit Vector
    \ins $vr\out, $vr\in1, \in0
.endm
.macro f_template3 ins, in0, in1, out // 64-bit FPR
    \ins $f\out, $f\in1, \in0
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

const align_mask
.dword ~(32 - 1)
endconst



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
// MOV
//
.macro MOV pre_op:req, in:req, out:req, more:vararg
    \pre_op\()_template \pre_op\()or.v, \in, \in, \out
.ifnb \more
    MOV \pre_op, \more
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
// PERMI: Support continuous permi.
//
.macro PERMI pre_op:req, suf_op:req, in0:req, in1:req, out:req, more:vararg
    \pre_op\()_template3 \pre_op\()permi.\suf_op \in0, \in1, \out
.ifnb \more
    PERMI \pre_op, \suf_op, \more
.endif
.endm


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
