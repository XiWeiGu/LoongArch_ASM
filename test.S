#include "asm.S"

const test_ld
.int 0, 1,   2,   3,   4,   5,   6,   7
.int 8, 9, 0xa, 0xb, 0xc, 0xd, 0xe, 0xf
.int 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17
.int 0x18, 0x19, 0x1a, 0x1b, 0x1c, 0x1d, 0x1e, 0x1f
.int 0, 1,   2,   3,   4,   5,   6,   7
.int 8, 9, 0xa, 0xb, 0xc, 0xd, 0xe, 0xf
.int 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17
.int 0x18, 0x19, 0x1a, 0x1b, 0x1c, 0x1d, 0x1e, 0x1f
endconst

.macro TEST_LD name, cpucfg
function \name, \cpucfg
    la.local $t0,   test_ld

    LD f, s, $t0, 4, 0, 15
    ST f, s, $a0, 4, 0, 15

    LD f, d, $t0, 8, 0, 7
    ST f, d, $a0, 8, 0, 7

    LD v, , $t0, 16, 0, 3
    ST v, , $a0, 16, 0, 3

    LD xv, , $t0, 32, 0, 1
    ST xv, , $a0, 32, 0, 1
endfunc
.endm

TEST_LD test_ld, cpucfg_lasx

.macro TEST_LDX name, cpucfg
function \name, \cpucfg
    la.local    $t0,    test_ld

    addi.d      $t1,    $zero,  4
    LDX f, s, $t0, $t1, 0, 15
    STX f, s, $a0, $t1, 0, 15

    addi.d      $t1,    $zero,  8
    LDX f, d, $t0, $t1, 0, 7
    STX f, d, $a0, $t1, 0, 7

    addi.d      $t1,    $zero,  16
    LDX v, , $t0, $t1, 0, 3
    STX v, , $a0, $t1, 0, 3

    addi.d      $t1,    $zero,  32
    LDX xv, , $t0, $t1, 0, 1
    STX xv, , $a0, $t1, 0, 1
endfunc
.endm

TEST_LDX test_ldx, cpucfg_lasx

.macro TEST_XOR name, cpucfg
function \name, \cpucfg
    la.local $t0,   test_ld

    LD v, , $t0, 16, 0, 7
    XOR v, 0, 3, 8, 11
    ST v, , $a0, 16, 8, 11
    XOR v, 4, 7, 12, 13
    ST v, , $a0, 16, 12, 13

    LD xv, , $t0, 32, 0, 3
    XOR xv, 0, 1, 4, 5
    ST xv, , $a0, 32, 4, 5
    XOR xv, 2, 3, 6
    ST xv, , $a0, 32, 6
endfunc
.endm

TEST_XOR test_xor, cpucfg_lasx

.macro TEST_ILVL name, cpucfg
function \name, \cpucfg
    la.local $t0,   test_ld

    LD v, , $t0, 16, 0, 7
    ILVL v, w, 0, 3, 8, 11
    ST v, , $a0, 16, 8, 11
    ILVL v, w, 4, 7, 12, 13
    ST v, , $a0, 16, 12, 13

    LD xv, , $t0, 32, 0, 3
    ILVL v, w, 0, 1, 4, 5
    ST xv, , $a0, 32, 4, 5
    ILVL v, w, 2, 3, 6
    ST xv, , $a0, 32, 6
endfunc
.endm

TEST_ILVL test_ilvl, cpucfg_lasx
