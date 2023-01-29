#include "asm.S"

const test_d
.dword 0, 1, 2, 3
.dword 4, 5, 6, 7
.dword 8, 9, 0xa, 0xb
.dword 0xc, 0xd, 0xe, 0xf
endconst

const test_w
.int 0, 1,   2,   3,   4,   5,   6,   7
.int 8, 9, 0xa, 0xb, 0xc, 0xd, 0xe, 0xf
.int 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17
.int 0x18, 0x19, 0x1a, 0x1b, 0x1c, 0x1d, 0x1e, 0x1f
.int 0, 1,   2,   3,   4,   5,   6,   7
.int 8, 9, 0xa, 0xb, 0xc, 0xd, 0xe, 0xf
.int 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17
.int 0x18, 0x19, 0x1a, 0x1b, 0x1c, 0x1d, 0x1e, 0x1f
endconst

const test_h
.short 0, 1,   2,   3,   4,   5,   6,   7
.short 8, 9, 0xa, 0xb, 0xc, 0xd, 0xe, 0xf
.short 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17
.short 0x18, 0x19, 0x1a, 0x1b, 0x1c, 0x1d, 0x1e, 0x1f
.short 0, 1,   2,   3,   4,   5,   6,   7
.short 8, 9, 0xa, 0xb, 0xc, 0xd, 0xe, 0xf
.short 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17
.short 0x18, 0x19, 0x1a, 0x1b, 0x1c, 0x1d, 0x1e, 0x1f
endconst

.macro TEST_LD name, cpucfg
function \name, \cpucfg
    la.local $t0,   test_w

    LD f, s, $t0, 4, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15
    ST f, s, $a0, 4, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15

    LD f, d, $t0, 8, 0, 1, 2, 3, 4, 5, 6, 7
    ST f, d, $a0, 8, 0, 1, 2, 3, 4, 5, 6, 7

    LD v, , $t0, 16, 0, 1, 2, 3
    ST v, , $a0, 16, 0, 1, 2, 3

    LD xv, , $t0, 32, 0, 1
    ST xv, , $a0, 32, 0, 1
endfunc
.endm

TEST_LD test_ld, cpucfg_lasx

.macro TEST_LDX name, cpucfg
function \name, \cpucfg
    la.local    $t0,    test_w

    addi.d      $t1,    $zero,  4
    LDX f, s, $t0, $t1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15
    STX f, s, $a0, $t1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15

    addi.d      $t1,    $zero,  8
    LDX f, d, $t0, $t1, 0, 1, 2, 3, 4, 5, 6, 7
    STX f, d, $a0, $t1, 0, 1, 2, 3, 4, 5, 6, 7

    addi.d      $t1,    $zero,  16
    LDX v, , $t0, $t1, 0, 1, 2, 3
    STX v, , $a0, $t1, 0, 1, 2, 3

    addi.d      $t1,    $zero,  32
    LDX xv, , $t0, $t1, 0, 1
    STX xv, , $a0, $t1, 0, 1
endfunc
.endm

TEST_LDX test_ldx, cpucfg_lasx

.macro TEST_XOR name, cpucfg
function \name, \cpucfg
    la.local $t0,   test_w

    LD v, , $t0, 16, 0, 1, 2, 3, 4, 5, 6, 7
    XOR v, 0, 0, 8, 1, 1, 9, 2, 2, 10, 3, 3, 11
    ST v, , $a0, 16, 8, 9, 10, 11
    XOR v, 4, 5, 12, 6, 7, 13
    ST v, , $a0, 16, 12, 13

    LD xv, , $t0, 32, 0, 1, 2, 3
    XOR xv, 0, 0, 4, 1, 1, 5
    ST xv, , $a0, 32, 4, 5
    XOR xv, 2, 3, 6
    ST xv, , $a0, 32, 6
endfunc
.endm

TEST_XOR test_xor, cpucfg_lasx

.macro TEST_ILVL name, cpucfg
function \name, \cpucfg
    la.local $t0,   test_w

    LD v, , $t0, 16, 0, 1, 2, 3, 4, 5, 6, 7
    ILVL v, w, 0, 0, 8, 1, 1, 9, 2, 2, 10, 3, 3, 11
    ST v, , $a0, 16, 8, 9, 10, 11
    ILVL v, w, 4, 5, 12, 6, 7, 13
    ST v, , $a0, 16, 12, 13

    LD xv, , $t0, 32, 0, 1, 2, 3
    ILVL xv, w, 0, 0, 4, 1, 1, 5
    ST xv, , $a0, 32, 4, 5
    ILVL xv, w, 2, 3, 6
    ST xv, , $a0, 32, 6
endfunc
.endm

TEST_ILVL test_ilvl, cpucfg_lasx

.macro TEST_ILVH name, cpucfg
function \name, \cpucfg
    la.local $t0,   test_w

    LD v, , $t0, 16, 0, 1, 2, 3, 4, 5, 6, 7
    ILVH v, w, 0, 0, 8, 1, 1, 9, 2, 2, 10, 3, 3, 11
    ST v, , $a0, 16, 8, 9, 10, 11
    ILVH v, w, 4, 5, 12, 6, 7, 13
    ST v, , $a0, 16, 12, 13

    LD xv, , $t0, 32, 0, 1, 2, 3
    ILVH xv, w, 0, 0, 4, 1, 1, 5
    ST xv, , $a0, 32, 4, 5
    ILVH xv, w, 2, 3, 6
    ST xv, , $a0, 32, 6
endfunc
.endm

TEST_ILVH test_ilvh, cpucfg_lasx

.macro TEST_TRANSPOSE4x4_H name, cpucfg
function \name, \cpucfg
    la.local $t0,   test_h

    LD v, , $t0, 16, 0, 1, 2, 3
    TRANSPOSE4x4_H v, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9
    ST f, d, $a0, 8, 4, 5, 6, 7
    LD v, , $t0, 16, 0, 1, 2, 3
    TRANSPOSE4x4_H xv, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9
    ST f, d, $a0, 8, 4, 5, 6, 7
endfunc
.endm

TEST_TRANSPOSE4x4_H test_transpose4x4_h cpucfg_lasx

.macro TEST_TRANSPOSE8x8_H name, cpucfg
function \name, \cpucfg
    la.local $t0, test_h

    LD v, , $t0, 16, 0, 1, 2, 3, 4, 5, 6, 7
    TRANSPOSE8x8_H v, 0, 1, 2, 3, 4, 5, 6, 7, \
                      0, 1, 2, 3, 4, 5, 6, 7, \
                      8, 9, 10, 11, 12, 13, 14, 15
    TRANSPOSE8x8_H xv, 0, 1, 2, 3, 4, 5, 6, 7,      \
                       8, 9, 10, 11, 12, 13, 14, 15,\
                       16, 17, 18, 19
    ST v, , $a0, 16, 8, 9, 10, 11, 12, 13, 14, 15
endfunc
.endm

TEST_TRANSPOSE8x8_H test_transpose8x8_h, cpucfg_lasx

.macro TEST_TRANSPOSE4x4_W name, cpucfg
function \name, \cpucfg
    la.local $t0,   test_w

    LD v, , $t0, 16, 0, 1, 2, 3
    TRANSPOSE4x4_W v, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9
    ST v, , $a0, 16, 4, 5, 6, 7
    LD xv, , $t0, 32, 0, 1, 2, 3
    TRANSPOSE4x4_W xv, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9
    ST v, , $a0, 16, 4, 5, 6, 7
endfunc
.endm

TEST_TRANSPOSE4x4_W test_transpose4x4_w, cpucfg_lasx

.macro TEST_TRANSPOSE8x8_W name, cpucfg
function \name, \cpucfg
    la.local $t0,   test_w

    LD xv, , $t0, 32, 0, 1, 2, 3, 4, 5, 6, 7
    TRANSPOSE8x8_W 0, 1, 2, 3, 4, 5, 6, 7,       \
                   8, 9, 10, 11, 12, 13, 14, 15, \
                   16, 17, 18, 19
    TRANSPOSE8x8_W 8, 9, 10, 11, 12, 13, 14, 15, \
                   0, 1, 2, 3, 4, 5, 6, 7,       \
                   16, 17, 18, 19
    ST xv, , $a0, 32, 0, 1, 2, 3, 4, 5, 6, 7
endfunc
.endm

TEST_TRANSPOSE8x8_W test_transpose8x8_w, cpucfg_lasx

.macro TEST_TRANSPOSE4x4_D name, cpucfg
function \name, \cpucfg
    la.local $t0,   test_d
    LD xv, , $t0, 32, 0, 1, 2, 3
    TRANSPOSE4x4_D 0, 1, 2, 3, \
                   4, 5, 6, 7, \
                   8, 9
    TRANSPOSE4x4_D 4, 5, 6, 7, \
                   0, 1, 2, 3, \
                   8, 9
    ST xv, , $a0, 32, 0, 1, 2, 3
endfunc
.endm

TEST_TRANSPOSE4x4_D test_transpose4x4_d, cpucfg_lasx
