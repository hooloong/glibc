/* roundf  function.  PowerPC32 version.
   Copyright (C) 2004-2017 Free Software Foundation, Inc.
   This file is part of the GNU C Library.

   The GNU C Library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2.1 of the License, or (at your option) any later version.

   The GNU C Library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with the GNU C Library; if not, see
   <http://www.gnu.org/licenses/>.  */

#include <sysdep.h>
#include <libm-alias-float.h>

	.section	.rodata.cst8,"aM",@progbits,8
	.align	3
.LC0:	/* 2**23 */
	.long 0x4b000000
.LC1:	/* 0.5 */
	.long 0x3f000000

/* float [fp1] roundf  (float x [fp1])
   IEEE 1003.1 round function.  IEEE specifies "round to the nearest
   integer value, rounding halfway cases away from zero, regardless of
   the current rounding mode."  However PowerPC Architecture defines
   "Round to Nearest" as "Choose the best approximation. In case of a
   tie, choose the one that is even (least significant bit o).".
   So we can't use the PowerPC "Round to Nearest" mode. Instead we set
   "Round toward Zero" mode and round by adding +-0.5 before rounding
   to the integer value.  */

	.section	".text"
ENTRY (__roundf )
#ifdef SHARED
	mflr	r11
	cfi_register(lr,r11)
	SETUP_GOT_ACCESS(r9,got_label)
	addis	r9,r9,.LC0-got_label@ha
	addi	r9,r9,.LC0-got_label@l
	mtlr	r11
	cfi_same_value (lr)
	lfs	fp13,0(r9)
#else
	lis	r9,.LC0@ha
	lfs	fp13,.LC0@l(r9)
#endif
	fabs	fp0,fp1
	fsubs	fp12,fp13,fp13	/* generate 0.0  */
	fcmpu	cr7,fp0,fp13	/* if (fabs(x) > TWO23)  */
	mffs	fp11		/* Save current FPU rounding mode and
				   "inexact" state.  */
	fcmpu	cr6,fp1,fp12	/* if (x > 0.0)  */
	bnl-	cr7,.L10
	mtfsfi	7,1		/* Set rounding mode toward 0.  */
#ifdef SHARED
	lfs	fp10,.LC1-.LC0(r9)
#else
	lfs	fp10,.LC1@l(r9)
#endif
	ble-	cr6,.L4
	fadds	fp1,fp1,fp10	/* x+= 0.5;  */
	fadds	fp1,fp1,fp13	/* x+= TWO23;  */
	fsubs	fp1,fp1,fp13	/* x-= TWO23;  */
	fabs	fp1,fp1		/* if (x == 0.0)  */
				/* x = 0.0; */
	mtfsf	0xff,fp11	/* Restore previous rounding mode and
				   "inexact" state.  */
	blr
.L4:
	fsubs	fp9,fp1,fp10	/* x+= 0.5;  */
	bge-	cr6,.L9		/* if (x < 0.0)  */
	fsubs	fp1,fp9,fp13	/* x-= TWO23;  */
	fadds	fp1,fp1,fp13	/* x+= TWO23;  */
	fnabs	fp1,fp1		/* if (x == 0.0)  */
				/* x = -0.0; */
.L9:
	mtfsf	0xff,fp11	/* Restore previous rounding mode and
				   "inexact" state.  */
	blr
.L10:
	/* Ensure sNaN input is converted to qNaN.  */
	fcmpu	cr7,fp1,fp1
	beqlr	cr7
	fadds	fp1,fp1,fp1
	blr
	END (__roundf)

libm_alias_float (__round, round)

