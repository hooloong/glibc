/* Multiple versions of stpcpy.
   All versions must be listed in ifunc-impl-list.c.
   Copyright (C) 2015 Free Software Foundation, Inc.
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

/* Define multiple versions only for the definition in libc.  */
#if IS_IN (libc)
# define _HAVE_STRING_ARCH_stpcpy
# define NO_MEMPCPY_STPCPY_REDIRECT
/* Redefine stpcpy so that the compiler won't complain about the type
   mismatch with the IFUNC selector in strong_alias, below.  */
# undef stpcpy
# define stpcpy __redirect_stpcpy
# include <string.h>
# undef stpcpy

# include <init-arch.h>

extern __typeof (__redirect_stpcpy) __stpcpy_i386 attribute_hidden;
extern __typeof (__redirect_stpcpy) __stpcpy_i586 attribute_hidden;
extern __typeof (__redirect_stpcpy) __stpcpy_sse2 attribute_hidden;
extern __typeof (__redirect_stpcpy) __stpcpy_ssse3 attribute_hidden;

/* Avoid DWARF definition DIE on ifunc symbol so that GDB can handle
   ifunc symbol properly.  */
extern __typeof (__redirect_stpcpy) __stpcpy;
extern void *stpcpy_ifunc (void) __asm__ ("__stpcpy");

void *
stpcpy_ifunc (void)
{
  if (HAS_CPU_FEATURE (SSSE3))
    return __stpcpy_ssse3;
  else if (HAS_CPU_FEATURE (SSE2))
    return __stpcpy_sse2;

  if (USE_I586)
    return __stpcpy_i586;
  else
    return __stpcpy_i386;
}
__asm__ (".type __stpcpy, %gnu_indirect_function");

weak_alias (__stpcpy, stpcpy)
#endif