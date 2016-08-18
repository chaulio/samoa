#include "Compilation_control.f90"

#if defined(_SWE_DG)
MODULE SWE_DG_matrices
!  use SWE_data_types
  implicit none

#       if defined(_SINGLE_PRECISION)
            integer, PARAMETER :: GRID_SR = kind(1.0e0)
#       elif defined(_DOUBLE_PRECISION)
            integer, PARAMETER :: GRID_SR = kind(1.0d0)
#       elif defined(_QUAD_PRECISION)
            integer, PARAMETER :: GRID_SR = kind(1.0q0)
#       else
#           error "No floating point precision is chosen!"
#       endif


#if _SWE_DG_ORDER == 1

!Conversion matrices
#include "dg_matrices/phi_1.incl"
#include "dg_matrices/mue_lu_1.incl"
#include "dg_matrices/mue_lu_pivot_1.incl"

!DG_Solver matrices
#include "dg_matrices/s_k_x_1.incl"
#include "dg_matrices/s_k_y_1.incl"
#include "dg_matrices/b_m_1_1.incl"
#include "dg_matrices/b_m_2_1.incl"
#include "dg_matrices/b_m_3_1.incl"
#include "dg_matrices/s_m_lu_1.incl"
#include "dg_matrices/s_m_lu_pivot_1.incl"


!DG_Predictor matrices
#include "dg_matrices/st_k_x_1.incl"
#include "dg_matrices/st_k_y_1.incl"

#include "dg_matrices/st_m_1.incl"

#include "dg_matrices/st_w_k_t_1_0_1.incl"
#include "dg_matrices/st_w_k_t_1_1_lu_1.incl"
#include "dg_matrices/st_w_k_t_1_1_lu_pivot_1.incl"

! #include "dg_matrices/st_k_t_1_0_1.incl"
! #include "dg_matrices/st_k_t_1_1_lu_1.incl"
! #include "dg_matrices/st_k_t_1_1_lu_pivot_1.incl"

#endif

#if _SWE_DG_ORDER == 2

!Conversion matrices
#include "dg_matrices/phi_2.incl"
#include "dg_matrices/mue_lu_2.incl"
#include "dg_matrices/mue_lu_pivot_2.incl"

!DG_Solver matrices
#include "dg_matrices/s_k_x_2.incl"
#include "dg_matrices/s_k_y_2.incl"

#include "dg_matrices/b_m_1_2.incl"
#include "dg_matrices/b_m_2_2.incl"
#include "dg_matrices/b_m_3_2.incl"

#include "dg_matrices/s_m_lu_2.incl"
#include "dg_matrices/s_m_lu_pivot_2.incl"


!DG_Predictor matrices
#include "dg_matrices/st_k_x_2.incl"
#include "dg_matrices/st_k_y_2.incl"

#include "dg_matrices/st_m_2.incl"

#include "dg_matrices/st_w_k_t_1_0_2.incl"
#include "dg_matrices/st_w_k_t_1_1_lu_2.incl"
#include "dg_matrices/st_w_k_t_1_1_lu_pivot_2.incl"

! #include "dg_matrices/st_k_t_1_0_4.incl"
! #include "dg_matrices/st_k_t_1_1_lu_4.incl"
! #include "dg_matrices/st_k_t_1_1_lu_pivot_4.incl"

#endif

#if _SWE_DG_ORDER == 4

!Conversion matrices
#include "dg_matrices/phi_4.incl"
#include "dg_matrices/mue_lu_4.incl"
#include "dg_matrices/mue_lu_pivot_4.incl"

!DG_Solver matrices
#include "dg_matrices/s_k_x_4.incl"
#include "dg_matrices/s_k_y_4.incl"

#include "dg_matrices/b_m_1_4.incl"
#include "dg_matrices/b_m_2_4.incl"
#include "dg_matrices/b_m_3_4.incl"

#include "dg_matrices/s_m_lu_4.incl"
#include "dg_matrices/s_m_lu_pivot_4.incl"


!DG_Predictor matrices
#include "dg_matrices/st_k_x_4.incl"
#include "dg_matrices/st_k_y_4.incl"

#include "dg_matrices/st_m_4.incl"

#include "dg_matrices/st_w_k_t_1_0_4.incl"
#include "dg_matrices/st_w_k_t_1_1_lu_4.incl"
#include "dg_matrices/st_w_k_t_1_1_lu_pivot_4.incl"

! #include "dg_matrices/st_k_t_1_0_4.incl"
! #include "dg_matrices/st_k_t_1_1_lu_4.incl"
! #include "dg_matrices/st_k_t_1_1_lu_pivot_4.incl"

#endif

contains 

subroutine lusolve(mat,n,pivot,b)
 integer :: n,ii,i,j,ll
 integer, intent(in) :: pivot(n)

 real(kind=GRID_SR) ::  sum
 real(kind=GRID_SR),intent(inout) ::  b(n)
 real(kind=GRID_SR),intent(in) ::  mat(n,n)

 ii = 0

 do i=1,n
   ll = pivot(i)
   sum = b(ll)
   b(ll) = b(i)
   if(ii.ne.0) then
     do j=ii,i-1
       sum = sum - mat(i,j)*b(j)
     end do ! j loop
   else if(sum.ne.0.0_GRID_SR) then
     ii = i
   end if
   b(i) = sum
 end do ! i loop

 do i=n,1,-1
   sum = b(i)
   if(i < n) then
     do j=i+1,n
       sum = sum - mat(i,j)*b(j)
     end do ! j loop
   end if
   b(i) = sum / mat(i,i)
 end do ! i loop

 return
 end subroutine lusolve

end MODULE SWE_DG_matrices
#endif
