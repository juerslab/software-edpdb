
	subroutine set_x(*)
chk	================
	include 'edp_main.inc'
!	use edp_main

	parameter 	(num_dlm=3)
!	integer, parameter :: num_dlm=3
	character*1 dlm(num_dlm)
	data dlm/' ','	',','/

	parameter 	(num_kw=11)
!	integer, parameter :: num_kw=11
	character*10 keyword(num_kw)
	data keyword/'atom','residue','chain','id','text','x','y','z',
     1 'weight','b','entry'/

	integer kw_status, rl_status, in_status

	integer wd_status, word
	data word/1/

	n_of_syn=9					!000515
	syntax(1)='syntax:' 
	syntax(2)='set atom atom_name.s'
	syntax(3)='set residue residue_name.s'
	syntax(4)='set chain chain_name.s'
	syntax(5)='set id starting_id.i increament.i'
	syntax(6)='set weight [w.r]'
	syntax(7)='set b b.r'
	syntax(8)='set text text_string.s [column_1.i [column_2.i]]' 
	syntax(9)='set entry'

	call oneword(
     1 num_dlm,dlm,num_kw,keyword,
     1 wd_status, kw_status, rl_status, in_status,
     1 rl,in)

	if(wd_status.ne.word) then
	  return 1
	else if(kw_status.lt.0) then
	  return 1
	else if(kw_status.eq.0) then
	  return
	else if(kw_status.eq.1) then
	  call seta(*900)
	else if(kw_status.eq.2) then
	  call setr(*900)
	else if(kw_status.eq.3) then
	  call setcm(*900)
	else if(kw_status.eq.4) then
	  call seti(*900)
	else if(kw_status.eq.5) then
	  call sett(*900)
	else if(kw_status.eq.6) then
	  return 1
	else if(kw_status.eq.7) then
	  return 1
	else if(kw_status.eq.8) then
	  return 1
	else if(kw_status.eq.9) then
	  call setw(*900)
	else if(kw_status.eq.10) then
	  call setb(*900)
	else if(kw_status.eq.11) then
	  call sete(*900)
	  endif
	return
900	return 1
	end

	subroutine oneword(
chk	==================
     1 num_dlm,dlm,num_kw,keyword,
     1 wd_status, kw_status, rl_status, in_status,
     1 rl,in)

chk	output:
chk	kw_status < 0 no keyword
chk	          = 0 ambiguous
chk	          > 0 found a keyword
chk	in_status < 0 no integer
chk	          = 0 no integer
chk	          > 0 found an integer
chk	rl_status < 0 no number
chk	          = 0 found an integer
chk	          > 1 found a  real number 
	include 'edp_dim.inc'
!	use edp_dim

	character*1 dlm(num_dlm)
	parameter (isp=32, itb=9, icm=44, ihf=45)

	character*(*) keyword(num_kw)

	integer kw_status, rl_status, in_status
	
	integer wd_status, word, skip, eol
	data word, skip, eol/1,2,3/

	character*(max_num_chars)  txt
	common /cmm_txt/n_len,txt,ib,ie

	character*20 tmp
	dimension nk(16)

	kw_status= -1
	rl_status= -1 
	in_status= -1

	if(ie.le.0) then 
	  ie=1
	else
	  ie=ie+2
	  endif

	do ib=ie,n_len
	  j=ichar(txt(ib:ib))
	  if(j.ne.isp.and.j.ne.itb) goto 100
	  enddo
	wd_status=eol
	return

100	wd_status=skip
	do ie=ib,n_len 		! found something
	  do j=1,num_dlm
	    if(txt(ie:ie).eq.dlm(j)) goto 200
	    enddo
	  enddo
	ie=n_len+1

200	ie=ie-1			! found a word
	if(ie.lt.ib) return

	wd_status=word
	tmp=txt(ib:ie)
	if(num_kw.gt.0) then	! looking for keyword
	  l= min(ie-ib+1, len(keyword(1)))
	  if(l.gt.0) then
	    k=0
	    do kw_status=1,num_kw
	      if(tmp.eq.keyword(kw_status)(:l)) then
	        j=index(keyword(kw_status),' ')
	        if(j.le.0.or.j.eq.l+1) goto 300
	        if(k.lt.16) k=k+1
	        nk(k)=kw_status
	        endif
	      enddo
	    if(k.eq.1) then
	      kw_status=nk(1)
	    else if (k.gt.1) then
	      write(6,1001) (keyword(nk(j)),j=1,k)
	      kw_status=0
	    else
	      kw_status=-1
	      endif
1001	format(
     1' keyword-W> ambiguous command verb -- supply more characters'
     1/(8x,5a12))
	    endif
	   endif

300	if(txt(ib:ib).lt.'0'.or.txt(ib:ib).gt.'9') return
	read(tmp,*,err=400) in
	in_status=1
	rl_status=0
	rl=in
	return

400	read(txt(ib:ie),*,err=900) rl
	rl_status=1
900	end
	
	subroutine setcm(*)
chk	================
	include 'edp_main.inc'
!	use edp_main
	include 'edp_dat.inc'
!	use edp_dat

	character*1 cm
	character*4 iresj
	integer k(2)

	logical nword, done
	character*(max_num_chars) txt	!, txt_tmp
	common /cmm_txt/n_len,txt,ib,ie
	save	!030422

	call beforecm
	i0=22
	i1=22
	if(.not.nword(n_len,txt,ib,ie)) goto 505

	do i=1, n_atom
	  if(lf(i)) then
	    ic=1
	    iresj=text(i)(23:26)
2501	    if(iresj(ic:ic).lt.'0'.or.iresj(ic:ic).gt.'9') goto 2502
	    read(iresj(ic:),*,err=2502) ista
	    if(ic.le.1) then
	      cm=' '
	    else 
	      cm=iresj(ic-1:ic-1)
	      endif
	    if(cm.eq.' ') then 
	      write( text(i)(23:26), 1066, err=2503) ista
	    else
	      write( text(i)(22:26), 1065, err=2503) cm,ista
	      endif
	    goto 2503	    !?
2502	    ic=ic+1
	    if(ic.le.4) goto 2501
	    endif
2503	  enddo	! i=1,n_atom
	return
	
	entry seta(*)
c	============
	call beforea
	i0=13 ! DJ 6/22
c	i0=14 ! Original
	i1=17
	goto 500

	entry setr(*)
c	============
	call beforer
	i0=18
	i1=20
	goto 500

	entry sete(*)
c	============
	n=1
	call read_ai(1,n,*900,*700)
700	n=n-1
	do ii=1, n_atom
	  i=iorder(ii)
	  if(lf(i)) then
	    n=n+1
	    if(n.gt.9999) n=0
	    write( text(i)(8:11),1061) n
	    endif
	  enddo
1061	format(i4)
	return
900	return 1
10 	return 1
	
	entry sett(*)
c	============
	call beforecm
	call beforea
	call beforer

	k(1)=0
	k(2)=0

	if(nword(n_len,txt,ib,ie)) then
	 write(6,*) ('1234567890',i=1,7),'*undone*'
	 return 
	endif

	
	ic=ichar(delimiter)
	if(ichar(txt(ib:ib)).eq.ic) then
	  ib0=ib+1
	  j=ib+2
	  do while(ichar(txt(j:j)).ne.ic.and.j.le.n_len) 
	    j=j+1
	    enddo
	  ie0=j-1
	  ie=j
	else
	  ib0=ib
	  ie0=ie
	  endif
	length_of_text=ie0-ib0+1

	call read_ai( 2, k, *900, *800)

c800	ok=.false.
800	if(k(1).le.0) then
	  do i=1, n_atom
	    if(lf(i)) then
	      text(i)=txt(ib0:ie0)
	    end if
	  end do
	else 
	  if(k(2).lt.k(1)) k(2)=k(1)+length_of_text-1
	  do i=1, n_atom
	    if(lf(i)) then
	      text(i)(k(1):k(2))=txt(ib0:ie0)
	      end if
	    enddo
	  end if
	return
	
	entry seti(*)
c	============
	i0=23
	i1=26
	if(nword(n_len,txt,ib,ie)) goto 500
	call beforecm
	read( txt(ib:ie), *, err=505) ista
	ie1=ie
	if(nword(n_len,txt,ib1,ie1)) goto 505
	read( txt(ib1:ie1), *, err=10) incr
c-u1063	format( i<ie1-ib1+1>)
	do j=1, n_res
	done=.false.
	do i=ijk(j),ijk(j+1)-1
	if(lf(i)) then
	write( text(i)(23:26), 1064, err=100) ista
1064	format(i4)
	done=.true.
	end if
	end do
	if(done) ista=ista+incr
	end do
	return
100	write(6,*) 'seti-W> ERROR in encoding [',ista,']'
	return

500	if(nword(n_len,txt,ib,ie)) then
	  if( .not.(i0.eq.22.and.i1.eq.22) .and. 
     1     .not.(i0.eq.23.and.i1.eq.26)) return 1   
	  do j=1, n_res
	    ic=1
501	    if(ires(j)(ic:ic).lt.'0'.or.ires(j)(ic:ic).gt.'9') goto 502
	    read(ires(j)(ic:),*,err=502) ista
	    if(ic.le.1) then
	      cm=' '
	    else 
	      cm=ires(j)(ic-1:ic-1)
	      endif
	    do i=ijk(j),ijk(j+1)-1
	      if(lf(i)) then
	        if(cm.eq.' ') then 
	          write( text(i)(23:26), 1066, err=503) ista
	        else
	          write( text(i)(22:26), 1065, err=503) cm,ista
	          endif
	        endif
	      enddo	! i: atom
	    goto 503
502	    ic=ic+1
	    if(ic.lt.4) goto 501
503	    enddo	! j: res
	  return
1065	  format(a1,i4)
1066	  format(i4)
	  endif		! nword.eq.true.

505	icm=ichar(delimiter)
	if(ichar(txt(ib:ib)) .eq. icm) then	! using ' ' to input chain marker
	  ib=ib+1
	  do j=ib, n_len
	    if(ichar(txt(j:j)).eq.icm) then
	      txt(j:j)=' '	!000303, it may screw up the history file
	      goto 510
	      endif
	    end do
	  j=n_len
510	  ie=j-1
	  if(ib  .gt.ie) return 1
	  end if

550	do i=1, n_atom
	  if(lf(i)) then
	    text(i)(i0:i1)=txt(ib:ie)
	    end if
	  end do
	return

	entry permut(*,*)
c	============
	n_of_syn=3					!000515
	syntax(1)='syntax:'
	syntax(2)='1) permute' 
	syntax(3)='2) permute i0.i i1.i right_shift.i'

	call beforecm
	call beforea
	call beforer

	if(nword(n_len,txt,ib,ie)) then
	 write(6,*) ('1234567890',i=1,7),'*undone*'
	 return 2
	endif

	read( txt(ib:ie), *, err=10) i0
c-u1065	format( i<ie-ib+1>)
	if(i0.le.0.or.i0.gt.30) return 1

	if(nword(n_len,txt,ib,ie)) return 1
	read( txt(ib:ie), *, err=10) i1
	if(i1.le.i0.or.i1.gt.30) return 1

	if(nword(n_len,txt,ib,ie)) return 1
	read( txt(ib:ie), *, err=10) i2
	if(i2.lt.-30.or.i2.gt.30) return 1
	i3= i1-i0+1
	i2=-i2
	do while(i2.lt.0)
	  i2=i2+i3
	enddo
	i2=mod(i2,i3)

	i3=i0+i2
	do i=1,n_atom
	 if(lf(i)) then
	  text(i)(i0:i1)= text(i)(i3:i1)//text(i)(i0:i3-1)
	 endif
	enddo
	end 

copyright by X. Cai Zhang

	subroutine read_vdw(file_name,rdi,*)
chk	====================
	include 'edp_main.inc'
!	use edp_main
	include 'edp_file.inc'
!	use edp_file
	include 'edp_dat.inc'
!	use edp_dat

	character*(108) file_name
	real	rdi(max_atom), def_rdi
	character*4 resj0

	logical  open_file
	external open_file

	if(.not.open_file(8,file_name,'old','.txt')) return 1
	update_in=file_name
	
	call read_acctxt(def_rdi,*900)

	resj0=' '
	do j=1,n_res
	 do i=ijk(j), ijk(j+1)-1
	  if(lf(i)) then 
	    rdi(i)=read_rdi(i,j,resj0,def_rdi)
	  endif
	 enddo	
	enddo
	return
900	return 1
	end

copyright by X. Cai Zhang

	subroutine edp_shape(*)
chk	====================

chk	future modification: sort the ON atoms according to the 
chk	distance from the centre atom.

	include 'edp_main.inc'
! 	use edp_main
	include 'edp_file.inc'
! 	use edp_file
	include 'edp_dat.inc'
! 	use edp_dat

	integer index1(max_atom), index2(max_atom), jtmp(max_atom)
	real rdi(max_atom), x0(3), xs(3), xt(3), xtmp(3,max_atom)
	character*30 text_string

	integer atom_id

	logical nword 
	character*(max_num_chars) txt
	common /cmm_txt/ n_len,txt,ib,ie

	data iseed/1024/

	if(pdb_out.eq.'?') then
	  errmsg=' errmsg: there is no output PDB file opened.'
	  return 1
	  endif

chk	input search_radius
	call read_ar(1,sphere,*990,*990)
	if(sphere.le.0.) goto 990

chk	input center atom		
	call get_atoms(1, atom_id, ierr) 
	if(ierr.ne.0) return 1
	x0(1)= x(atom_id)
	x0(2)= y(atom_id)
	x0(3)= z(atom_id)
	xs(1)= x0(1)
	xs(2)= x0(2)
	xs(3)= x0(3)
	text_string=text(atom_id)(1:30) 

chk	input max_RT
	call read_ai(1,n_try,*990,*990)
	if(n_try.le.0) goto 990
	if(n_try.gt.max_atom) n_try=max_atom

chk	input probe_radius
	probe=1.4
	call read_ar(1,probe,*990,*103)
103	if(probe.le.0.) goto 990

chk	input file_name
	if(acc_in.eq.'?') acc_in=acc_dat
        if(.not.nword(n_len,txt,ib,ie)) acc_in=txt(ib:ie)

chk	input random_seed
	call read_ai(1,iseed,*990,*105)

105	scale=1.0
	call read_ar(1,scale,*990,*106)
106	if(scale.le.0.) scale=1.0

	write(6,1002)  sphere, n_try, probe, iseed, scale
1002	format( ' shape-I> search radius =', f12.2
     1      /' shape-I> max_random_try=', i12
     1      /' shape-I> probe_radius  =', f12.2
     1      /' shape-I> random_seed   =', i12
     1      /' shape-I> scale         =', f12.2)

	sphere= sphere*sphere
	k=0
	do j=1,n_res
	  i0=ijk(j)
	  i1=ijk(j+1)-1
	  do i=i0,i1
	    if(lf(i)) then
	      k= k+1
 	      index1(k)=i
	      index2(k)=j
	      endif
	    enddo
	  enddo

chk	define the vdw radius.
	r_max=probe
	call acc_index( k,index1,index2,rdi,r_max,*991)
	k=0   
	do j=1,n_atom
	  if(lf(j)) then
	    k=k+1
	    rdi(k)=rdi(k)*rdi(k)
	    endif
	  enddo

	n_legal=0
	do 200 i=1,n_try
	  do j=1,3
	    if( n_legal.le.0) then
	      xt(j)= xs(j)+ (ran(iseed) - 0.5)*3.0*r_max
	    else
 	      xt(j)= xs(j)+ (ran(iseed) - 0.5)*2.0*probe
	      endif
 	    enddo
	   dx=xt(1)-x0(1)
	   dy=xt(2)-x0(2)
	   dz=xt(3)-x0(3)
	   if( dx*dx+dy*dy+dz*dz .gt. sphere) goto 200
	   rmin=1.e+10
	   bmin=0.0
	   k=0   
	   do j=1,n_atom
	     if(lf(j)) then
	       k=k+1
	       dx=xt(1)-x(j)
	       dy=xt(2)-y(j)
	       dz=xt(3)-z(j)
	       r=dx*dx+dy*dy+dz*dz
	       if( r .le. rdi(k)) goto 200
	       if(rmin.gt. r) then
	         rmin=r
	         bmin=b(j)
	         endif
	       endif
	     enddo

	   n_legal=n_legal +1
chk	   channel 4 is an open PDB file.
	   write(text_string(15:19),1072)  n_legal
1072	   format(i5)
	   write(4,1071)  text_string, xt, 0.0, bmin
1071	   format('ATOM   ',a23,3f8.3,2f6.2)
	   jtmp(n_legal)=0
	   n_rad=ran(iseed)*n_legal
	   do j=1,n_legal
	     j_rad=mod(n_rad+j, n_legal)+1
	     if(jtmp(j_rad).lt. int(ran(iseed)*scale)) then
	       jtmp(j_rad)=jtmp(j_rad)+1
	       goto 190
	     endif
	   enddo
	   j_rad=n_legal
	   	   
190	   do j=1,3
	     xtmp(j,n_legal)=xt(j)	   
	     xs(j)=xtmp(j,j_rad)
	   enddo
200	 continue

300	write(6,1003)  n_legal
1003	format(' shape>  #_legal_probe=',i12)
	return
990	return 1
991	write(6,*) 'shape-W> UNDONE'
	end

c****	end of shape.for

copyright by X. Cai Zhang

	subroutine check_cell(cell_in)
chk	=====================
        real cell_in(6)

	common /chk_cell_cmm/ cell(6), av(3,3)
	logical cubic, rltc, hexag, tetra, orth, mono, tric
	external cubic, rltc, hexag, tetra, orth, mono, tric
	real av0(3,3), rm(3,3)
	data eps, eps_a/1., 2./
	
	do i=1,6
	  cell(i)=cell_in(i)
	  enddo
 
	if((cell(4)+cell(5)+cell(6)).gt.360.) then
	  write(6,1009)
1009	  format(' cell-W> Wrong cell parameter!'
     1 /' The summation of the three angles should ',
     1 'not be greater then 360.0 degrees.')
	  goto 100
	  endif
	
	call trnslnb1(cell,av0,1)
	if(
     1 av0(1,1)*(av0(2,2)*av0(3,3)-av0(2,3)*av0(3,2))
     1+av0(1,2)*(av0(2,3)*av0(3,1)-av0(2,1)*av0(3,3))
     1+av0(1,3)*(av0(2,1)*av0(3,2)-av0(2,2)*av0(3,1))
     1 .lt. 0.1) then 
	  write(6,1010)
1010	  format(' cell-W> Wrong cell parameter!'
     1 /' The unit cell volume is zero.')
	  goto 100
	  endif

	call mxinv(3,av0,ierr)
	call shortest

	if(cubic(eps, eps_a)) 	then
	  write(6,*)  'possible lattice: P, possible s.g.: cubic'
	else if( rltc(eps, eps_a)) 	then
	  write(6,*)  'possible Lattice: R '
	else if(hexag(eps, eps_a))	then
	  write(6,*)  'possible lattice: P, possible s.g.: hexagonal '
	else if(tetra(eps, eps_a))	then
	  write(6,*)  'possible lattice: P, possible s.g.: tetrigonal '
	else if(orth(eps, eps_a))	then
	  write(6,*)  'possible lattice: P, possible s.g.: orthorhombic'
	else if(mono(eps, eps_a, ierr))	then
	  if(ierr.eq.1) then
	    write(6,*)  'possible lattice: C, possible s.g.: orthorhombic'
	  else if(ierr.eq.2) then
	    write(6,*)  'possible lattice: C, possible s.g.: orthorhombic'
	  else
	    write(6,*)  'possible lattice: P, possible s.g.: monoclinic '
	    endif
	else if(tric(eps, eps_a,ierr))	then
	  if(ierr.eq.0) then
	    write(6,*)  'possible lattice: P, possible s.g.: triclinic'
	  else if(ierr.eq.1) then
	    write(6,*)  'possible lattice: C, possible s.g.: monoclinic'
	  else if(ierr.eq.2) then
	    write(6,*)  'possible lattice: I, possible s.g.: orthorhombic'
	  else if(ierr.eq.3) then	
	    write(6,*)  'possible lattice: F, possible s.g.: orthorhombic'
	    endif
	  endif

	if(abs(cell(1)-cell_in(1)).lt. eps   .and.
     1  abs(cell(2)-cell_in(2)).lt. eps   .and.
     1  abs(cell(3)-cell_in(3)).lt. eps   .and.
     1  abs(cell(4)-cell_in(4)).lt. eps_a .and.
     1  abs(cell(5)-cell_in(5)).lt. eps_a .and.
     1  abs(cell(6)-cell_in(6)).lt. eps_a) goto 100

	call axbeqc(av0,av,rm)
	do i=1,3
	do j=1,3
	  av0(j,i)=rm(i,j)
	  enddo
	  enddo
	call mxinv(3,av0,ierr)
	write(6,1003) (( nint(rm(j,i)),j=1,3),(av0(j,i),j=1,3),i=1,3)

	write(6,1001) cell
1001	format(1x,'suggested cell',6f10.3)
1003	format(
     1  5x,'a''= (',i2,') a + (',i2,') b + (',i2,') c'
     1, 5x,'fx''= (',f6.3,')fx + (',f6.3,')fy + (',f6.3,')fz'
     1/ 5x,'b''= (',i2,') a + (',i2,') b + (',i2,') c'
     1, 5x,'fy''= (',f6.3,')fx + (',f6.3,')fy + (',f6.3,')fz'
     1/ 5x,'c''= (',i2,') a + (',i2,') b + (',i2,') c'
     1, 5x,'fz''= (',f6.3,')fx + (',f6.3,')fy + (',f6.3,')fz')
100	end

	subroutine face_ltc(eps, eps_a, ierr)
	common /chk_cell_cmm/ a,b,c,al,be,ga, av(3,3)
	real d1(3), d2(3), d3(3)
	ierr=0

	do i=1,3
	  d1(i)= av(i,2)-av(i,3)	
	  d2(i)= av(i,3)-av(i,1)	
	  d3(i)= av(i,1)-av(i,2)
	  enddo
	
	if(abs(b-c) .lt. eps .and.
     1  abs(be-ga) .lt. eps_a ) then
	  call mm(0,1,0, 0,0,1, 1,0,0) 
c	  write(6,1002) 'a:=b; b:=c; c:=a'
	else if(abs(c-a) .lt. eps .and.
     1  abs(ga-al) .lt. eps_a ) then
	  call mm(0,0,1, 1,0,0, 0,1,0) 
c	  write(6,1002) 'a:=c; b:=a; c:=b'
	  endif

	if(abs(b-a) .lt. eps .and.
     1  abs(al-be) .lt. eps_a ) then
	  call mm(1,1,0, -1,1,0, 0,0,1)
c	  write(6,1002) 'a:=a+b; b:=b-a;'
	  call get_cell
	  ac=(av(1,1)*av(1,3)+ av(2,1)*av(2,3)+ av(3,1)*av(3,3))/a
	  if(abs(ac-0.5*a).lt.eps) then
	    call mm(1,0,0, 0,1,0, -1,0,2)
c	    write(6,1002) 'c:=-a+2c'
	    call get_cell
	    ierr=3	! F lattice, orth
	  else if(abs(ac+0.5*c).lt.eps) then
	    call mm(1,0,0, 0,1,0, 1,0,2)
c	    write(6,1002) 'c:=a+2c'
	    call get_cell
	    ierr=3	! F lattice, orth
	  else 
	    ierr=1	! C mono
	    endif
	else if( abs( a - rr(d1)) .lt. eps .and.	
     1   abs( b - rr(d2)) .lt. eps .and.	
     1   abs( c - rr(d3)) .lt. eps ) then
	  call mm(-1,1,1, 1,-1,1, 1,1,-1)
c	  write(6,1002) 'a:=b+c-a; b:=c+a-b; c:=a+b-c'
	  ierr=3
	  call get_cell
	  endif
c1002	format(1x,a)
	end

	function tric(eps, eps_a, ierr)
chk	==============
	logical tric
	common /chk_cell_cmm/ a,b,c,al,be,ga, av(3,3)

	tric=.true.
	ierr=0
	if (abs(be-90.).lt.eps_a) then
	  call mm(0,1,0, 0,0,1, 1,0,0)
c	  write(6,1002) 'a:=b; b:=c; c:=a'
	else if (abs(ga-90.).lt.eps_a) then
	  call mm(0,0,1, 1,0,0, 0,1,0)
c	  write(6,1002) 'a:=c; b:=a; c:=b'
	else if (abs(al-90.).gt.eps_a) then 
	  call face_ltc(eps, eps_a, ierr)
	  return
	  endif

	call get_cell
	ac=(av(1,1)*av(1,3)+ av(2,1)*av(2,3)+ av(3,1)*av(3,3))/c
	ab=(av(1,1)*av(1,2)+ av(2,1)*av(2,2)+ av(3,1)*av(3,2))/b
	if(abs(ac-0.5*c).lt.eps) then
	  if(abs(ab-0.5*b).lt.eps) then
	    ierr=2	! I lattice, Orth
	    call mm(2,-1,-1, 0,1,0, 0,0,1)
c	    write(6,1002) 'a:=2a-b-c'
	  else if(abs(ab+0.5*b).lt.eps) then
	    ierr=2	! I lattice, Orth
	    call mm(2,1,-1, 0,1,0, 0,0,1)
c	    write(6,1002) 'a:=2a+b-c'
	  else
	    ierr=1	! C Mono
	    call mm(2,0,-1, 0,1,0, 0,0,1)
c	    write(6,1002) 'a:=2a-c'
	    call mm(1,0,0, 0,0,-1, 0,1,0)
c	    write(6,1002) 'b:=-c; c:=b'
	    endif
	else if(abs(ac+0.5*c).lt.eps) then
	  if(abs(ab-0.5*b).lt.eps) then
	    ierr=2	! I lattice, Orth
	    call mm(2,-1,1, 0,1,0, 0,0,1)
c	    write(6,1002) 'a:=2a-b+c'
	  else if(abs(ab+0.5*b).lt.eps) then
	    ierr=2	! I lattice, Orth
	    call mm(2,1,1, 0,1,0, 0,0,1)
c	    write(6,1002) 'a:=2a+b+c'
	  else
	    ierr=1	! C Mono
	    call mm(2,0,1, 0,1,0, 0,0,1)
c	    write(6,1002) 'a:=2a+c'
	    call mm(1,0,0, 0,0,-1, 0,1,0)
c	    write(6,1002) 'b:=-c; c:=b'
	    endif
	else
	  if(abs(ab-0.5*b).lt.eps) then
	    ierr=1	! C Mono
	    call mm(2,-1,0, 0,1,0, 0,0,1)
c	    write(6,1002) 'a:=2a-b'
	  else if(abs(ab+0.5*b).lt.eps) then
	    ierr=1	! C mono
	    call mm(2,1,0, 0,1,0, 0,0,1)
c	    write(6,1002) 'a:=2a+b'
	    endif
	  endif
	if(ierr.gt.0) call get_cell
	if(ierr.eq.1) then
	  if(be.lt.90.0) then
	    call mm(-1,0,0, 0,-1,0, 0,0,1)
c	    write(6,1002) 'a:=-a; b:=-b'
	    call get_cell
	    endif
	  endif
c1002	format(1x,a)
	end

	function mono(eps, eps_a, ierr)
chk	==============
	logical mono
	common /chk_cell_cmm/ a,b,c,al,be,ga, av(3,3)
	real cell(6)
	equivalence (cell(1), a)

	mono=.false.
	ierr=0
	if(abs(al-90.) .lt. eps_a .and.
     1  abs(be-90.) .lt. eps_a  ) then
	  call mm(0,1,0, 0,0,1, 1,0,0)
c	  write(6,1002) 'a:=b; b:=c; c:=a'
	  mono=.true.
	else if(abs(be-90.) .lt. eps_a .and.
     1       abs(ga-90.) .lt. eps_a  ) then
	  call mm(0,0,1, 1,0,0, 0,1,0)
c	  write(6,1002) 'a:=c; b:=a; c:=b'
	  mono=.true.
	else if(abs(ga-90.) .lt. eps_a .and.
     1       abs(al-90.) .lt. eps_a  ) then
	  mono=.true.
	  endif

	call get_cell
	if(mono.and.abs(a-c).lt.eps) then
	  call mm(1,0,1, 1,0,-1, 0,1,0)
c	  write(6,1002) 'a:=a+c; b:=a-c; c:=b'
	  ierr=1
	  call get_cell
	else if(abs(abs(2.0*a*cosd(be))-c).le.eps) then
	  if(cosd(be).ge.0.) then
	    call mm(2,0,-1, 0,1,0, 0,0,1)
	  else
	    call mm(2,0, 1, 0,1,0, 0,0,1)
	    endif
	    ierr=2
	    call mm(0,0,1, 1,0,0, 0,1,0)
	    call get_cell
	else if(abs(abs(2.0*c*cosd(be))-a).le.eps) then
	  if(cosd(be).ge.0.) then
	    call mm(1,0,0, 0,1,0, -1,0,2)
	  else
	    call mm(1,0,0, 0,1,0,  1,0,2)
	    endif
	    ierr=2
	    call mm(0,0,1, 1,0,0, 0,1,0)
	    call get_cell
	  endif
c1002	format(1x,a)
	end

	function orth(eps, eps_a)
chk	==============
	logical orth
	common /chk_cell_cmm/ a,b,c,al,be,ga, av(3,3)

	orth=.false.
	if(abs(al-90.) .gt. eps_a .or.
     1  abs(be-90.) .gt. eps_a .or.
     1  abs(ga-90.) .gt. eps_a ) return
	orth=.true.
	end

	function tetra(eps, eps_a)
chk	==============
	logical tetra
	common /chk_cell_cmm/ a,b,c,al,be,ga, av(3,3)

	tetra=.false.
	if(abs(al-90.) .gt. eps_a .or.
     1  abs(be-90.) .gt. eps_a .or.
     1  abs(ga-90.) .gt. eps_a ) return

	if(abs(b-c) .lt. eps) then
	    call mm(0,1,0, 0,0,1, 1,0,0)
c	    write(6,1002) 'a:=b; b:=c; c:=a'
	    tetra=.true.
	else if(abs(a-c) .lt. eps) then
	    call mm(0,0,1, 1,0,0, 0,1,0)
c	    write(6,1002) 'a:=c; b:=a; c:=b'
	    tetra=.true.
	else if(abs(b-a) .lt. eps) then
	    tetra=.true.
	  endif
	call get_cell
c1002	format(1x,a)
	end

	function hexag(eps, eps_a)
chk	==============
	logical hexag
	common /chk_cell_cmm/ a,b,c,al,be,ga, av(3,3)

	hexag=.false.

	if(abs(al-120.0) .lt. eps_a ) then
	  if(abs(be-90.) .lt. eps_a .and.
     1    abs(ga-90.) .lt. eps_a .and. 
     1    abs(b-c) .lt. eps) then
	    call mm(0,1,0, 0,0,1, 1,0,0)
c	    write(6,1002) 'a:=b; b:=c; c:=a'
	    hexag=.true.
	    endif
	else if(abs(be-120.0) .lt. eps_a ) then
	  if(abs(al-90.) .lt. eps_a .and.
     1    abs(ga-90.) .lt. eps_a .and. 
     1    abs(a-c) .lt. eps) then
	    call mm(0,0,1, 1,0,0, 0,1,0)
c	    write(6,1002) 'a:=c; b:=a; c:=b'
	    hexag=.true.
	    endif
	else if(abs(ga-120.0) .lt. eps_a ) then
	  if(abs(be-90.) .lt. eps_a .and.
     1    abs(al-90.) .lt. eps_a .and. 
     1    abs(b-a) .lt. eps) then
	    hexag=.true.
	    endif
	  endif
c	if(hexag.and.abs(ga-60.0) .lt. eps_a) ga=180.0-ga
	call get_cell
c1002	format(1x,a)
	end

	function rltc( eps, eps_a)
chk	==============
	logical rltc
	common /chk_cell_cmm/ a,b,c,al,be,ga ,av(3,3)

	rltc = .false.
	if(abs(a-b).lt.eps ) then
	if(abs(b-c).lt.eps ) then
	if(abs(c-a).lt.eps ) then
	if(abs(al-be).lt.eps_a ) then
	if(abs(be-ga).lt.eps_a ) then
	if(abs(ga-al).lt.eps_a ) then
	  rltc = .true.
	  endif
	  endif
	  endif
	  endif
	  endif
	  endif
	end

	function cubic(eps, eps_a)
chk	==============
	logical cubic
	common /chk_cell_cmm/ a,b,c,al,be,ga ,av(3,3)
	if(abs(a-b).lt.eps. and.
     1  abs(b-c).lt.eps. and.
     1  abs(c-a).lt.eps. and.
     1  abs(al-90.).lt.eps_a. and.
     1  abs(be-90.).lt.eps_a. and.
     1  abs(ga-90.).lt.eps_a) then
	  cubic = .true.
	else
	  cubic = .false.
	  endif
	end

	subroutine shortest
chk	===================
	common /chk_cell_cmm/ cell(6), av(3,3) 
	real d(3)
	
	call trnslnb1(cell,av,1)

100	do iv=1,3
	  iv1=mod(iv,3)+1
	  iv2=mod(iv1,3)+1
	  d_min=1.e+12

	  do i=-3,3
	  do j=-3,3
	    do jv=1,3  
	      d(jv)= av(jv,iv)+ av(jv,iv1)*i+ av(jv,iv2)*j	  
	      enddo
	    dr=rr(d)*400.+ (360.0-vv_angle(d,av(1,iv1))-vv_angle(d,av(1,iv2)))
	    if(dr .lt. d_min) then
	      i_min=i
	      j_min=j
	      d_min=dr
	      endif 
	    enddo
	    enddo
	  if(i_min.ne.0. or. j_min.ne.0) then
	    if(iv.eq.1) then
	      call mm(1,i_min,j_min, 0,1,0, 0,0,1)
c	      write(6,1002) 'a:= a+ (',i_min,')*b+ (',j_min,')*c'
	    else if(iv.eq.2) then
	      call mm(1,0,0, j_min,1,i_min, 0,0,1)
c	      write(6,1002) 'b:= (',j_min,')*a+ b+ (',i_min,')*c'
	    else 
	      call mm(1,0,0, 0,1,0, i_min,j_min,1)
c	      write(6,1002) 'c:= (',i_min,')*a+ (',j_min,')*b+ c'
	      endif
c1002	    format(1x,a,i3,a,i3,a)
	    goto 100
	    endif
	  enddo

	call get_cell

	if(
     1 (cell(4).lt.90. .and. cell(5).gt.90. .and. cell(6).gt.90.) .or.
     1 (cell(4).gt.90. .and. cell(5).lt.90. .and. cell(6).lt.90.)) then
	  call mm(-1,0,0, 0,0,1, 0,1,0)
c	  write(6,1002) 'a:=-a; b:=c; c:=b'
	  call get_cell
	else if(
     1 (cell(4).gt.90. .and. cell(5).lt.90. .and. cell(6).gt.90.) .or.
     1 (cell(4).lt.90. .and. cell(5).gt.90. .and. cell(6).lt.90.)) then
	  call mm(0,0,1, 0,-1,0, 1,0,0)
c	  write(6,1002) 'a:=c; b:=-b; c:=a'
	  call get_cell
	else if(
     1 (cell(4).gt.90. .and. cell(5).gt.90. .and. cell(6).lt.90.) .or.
     1 (cell(4).lt.90. .and. cell(5).lt.90. .and. cell(6).gt.90.)) then
	  call mm(0,1,0, 1,0,0, 0,0,-1)
c	  write(6,1002) 'a:=b; b:=a; c:=-c'
	  call get_cell
	  endif
	end

	subroutine mm(i11,i12,i13,i21,i22,i23,i31,i32,i33)
	common /chk_cell_cmm/ cell(6), av(3,3)			
	real a(3,3)						
	
	a(1,1)= i11*av(1,1)+ i12*av(1,2)+i13*av(1,3)
	a(2,1)= i11*av(2,1)+ i12*av(2,2)+i13*av(2,3)
	a(3,1)= i11*av(3,1)+ i12*av(3,2)+i13*av(3,3)

	a(1,2)= i21*av(1,1)+ i22*av(1,2)+i23*av(1,3)
	a(2,2)= i21*av(2,1)+ i22*av(2,2)+i23*av(2,3)
	a(3,2)= i21*av(3,1)+ i22*av(3,2)+i23*av(3,3)

	a(1,3)= i31*av(1,1)+ i32*av(1,2)+i33*av(1,3)
	a(2,3)= i31*av(2,1)+ i32*av(2,2)+i33*av(2,3)
	a(3,3)= i31*av(3,1)+ i32*av(3,2)+i33*av(3,3)

	do i=1,3
	do j=1,3
	  av(j,i)=a(j,i)
	  enddo
	  enddo

	if(
     1 a(1,1)*(a(2,2)*a(3,3)-a(2,3)*a(3,2))
     1+a(1,2)*(a(2,3)*a(3,1)-a(2,1)*a(3,3))
     1+a(1,3)*(a(2,1)*a(3,2)-a(2,2)*a(3,1))
     1 .lt. 0.1) then 
	  write(6,1010)
1010	  format(' %EdPDB-E- wrong cell parameter!'
     1 ,' The unit cell volume is zero.')
	  call exit(4)
	  endif
	end

	subroutine get_cell
chk	===================
	common /chk_cell_cmm/ cell(6), av(3,3)
	cell(1)=rr(av(1,1))
	cell(2)=rr(av(1,2))
	cell(3)=rr(av(1,3))
	cell(4)=vv_angle(av(1,2), av(1,3))
	cell(5)=vv_angle(av(1,3), av(1,1))
	cell(6)=vv_angle(av(1,1), av(1,2))
	end

	function vv_angle(a,b)
chk	=================
	real a(3), b(3)

	vv_angle=-999.0
	ar=a(1)*a(1)+ a(2)*a(2)+ a(3)*a(3)
	if(ar.le.1.e-1) return
	br=b(1)*b(1)+ b(2)*b(2)+ b(3)*b(3)
	if(br.le.1.e-1) return
	tmp1=(a(1)*b(1)+ a(2)*b(2)+ a(3)*b(3))
	tmp2=sqrt(ar*br)
	if(tmp1.gt.tmp2) then
	  vv_angle=0.0
	else if(tmp1.lt.-tmp2) then
	  vv_angle=180.0
	else
	  t=tmp1/tmp2
	  if(abs(t).lt.eps()) then
	    vv_angle=90.0
	  else
	    vv_angle=acosd(t)
	    endif
	  endif
	end

	function rr(a)
chk	=================
	real a(3)
	rr=sqrt(a(1)*a(1)+a(2)*a(2)+a(3)*a(3))
	end

	function f_dist(j_a)
chk	=================
	include 'edp_main.inc'
!	use edp_main

	dimension j_a(2)

	f_dist=sqrt( (x(j_a(1))-x(j_a(2)))**2
     1           +(y(j_a(1))-y(j_a(2)))**2
     1           +(z(j_a(1))-z(j_a(2)))**2)
	end

	subroutine typelist(jo)
chk	=================
	include 'edp_main.inc'
!	use edp_main
	include 'edp_dat.inc'
!	use edp_dat

	character*79 line, l_mark*1 
	data i/-1/
!	save k, io
	save	!030422

	io=abs(jo)
	if(jo.le.0) then
	  rewind (io)
	  i=-1
	  iadd=1
	  return
	  endif

!	if(.not.inter .or. i_pipe .ge. 0 ) return	
	if(verbose .le. 0 .or. i_pipe .ge. 0 ) return	

	rewind (io)
	do i=1,iadd
	  read(io,1800,end=900) 
	  end do
1800	format(a1,a)

	entry c_typelist
!	================
!	if(.not. inter .or.i.lt.0) return
	if(verbose .le. 0 .or.i.lt.0) return
	if(window_size.le.1) call get_window_size()
	k=1
	do while(.true.)
800	  read(io,1800,end=900) l_mark,line
	  i=i+1
	  if(l_mark.eq.'!') goto 800
	  k=k+1
	  write(6,*) line
	  if(k.ge.window_size) then
	    if(l_mark.ne.'^') write(6,*) 'list> return for more .....'
	    return
	    end if
	  end do

900	goto 910

	entry e_typelist
!	================
!	if(.not. inter .or.i.lt.0) return
	if(verbose .le. 0 .or.i.lt.0) return
	do while (.true.)
	  read(io,1800,end=910)
	  i=i+1
	  enddo
910	iadd=i-1
	i=-1
	call sgi_backspace(io) !	backspace(io)	!sgi-g90
	end

copyright by X. Cai Zhang

	subroutine udk(n_length,ierr,warning)
chk	==============
chk	ierr=1,  non udk
chk	ierr=0

	include 'edp_main.inc'
!	use edp_main
	include 'edp_dat.inc'
!	use edp_dat

	character*(*) warning

	logical nword 
	character*(max_num_chars) txt
	common /cmm_txt/n_len,txt,ib,ie
	
	character*8 udks(max_udks)
	character*(72) alias(max_udks)
	integer na(max_udks)

	data num_udks,nt,nk/0,0,0/

!	save udks, alias, na
	save	!030422

	ierr=999
	if(n_len.le.0) return  ! this could be the pipe '{' or blank input

	ie=0
	if(nk.gt.0) then	
	  call find1(nk,udks,i) ! get ib,i
	else 			! get ib
	  if(nword(n_len,txt,ib,ie)) return
	  i=-1
	  endif

	ierr=1
	ip=index(txt(:n_len),':=') 	! define keyword

	if(ip.gt.0) then
	  txt(ip:ip)=' '		! skip ':=', by temperarily delete it
	  if(nk.gt.0) then
	    ie=0
	    i=-1
	    call find1(nk,udks,i)
	    endif
	  txt(ip:ip)=':'		! put ':=' back
	  if(i.gt.0) then
	    write(6,*) udks(i)//' definition is overwritten.'
	  else
	    num_udks=mod(num_udks,max_udks)+1
	    nt=nt+1
	    nk=min(nt,9)
	    i=num_udks
	    if(nt.gt.max_udks) then
	      write(6,*) udks(i)//' definition is overwritten.'
	      endif
	    endif

	  np=n_len-ip
	  if(np.le.2) then	! end with ':='
	    udks(i)=' '
	    ierr=-1
	    return
	    endif

	  if(ip.gt.ie) then
	    udks(i)=txt(ib:ie)
	  else
	    udks(i)=txt(ib:ip-1)
	    endif

	  na(i)=np
	  ie=ip+1
	  if(nword(n_len,txt,ib,ie)) return	! get ib,ie
	  np=min(ie-ib+1,8)
	  if(udks(i)(:np).eq.txt(ib:ie)) then
	    udks(i)=' '
	    write(6,*) '%EdPDB-W- looped difinition is not allowed.'
	    return
	    endif
	  alias(i)=' '//txt(ib:n_len)
	  ierr=-1
	  return
	  endif !   'define keyword with :='
	if(i.le.0) return	!with ierr=1

!	n_d=na(i)-(ie-ib+1)
	n_length0=n_length
	n_d=na(i)-ie
	n_length=min(n_length+n_d,max_num_chars)
	n_len=n_len+n_d
	if(n_len.gt.max_num_chars) then 
	  errmsg=' errmsg: the translated statement is too long'
	  ierr=2
	  return
	  endif
	txt=alias(i)(:na(i))//txt(ie+1:n_length0)

	ierr=0
	n_err=n_err+1
	if(n_err.gt.max_err) then
	  errmsg=' errmsg: too many substitutions.'
	  ierr=2
	else if(max_err-n_err.le.3) then
          write(6,*) warning,' it is time to reset maxerr.'
          endif
	return

	entry udk1(*)
chk	==========
	n_of_syn=5					!000515
	syntax(1)='syntax:' 
	syntax(2)='1) alias '
	syntax(3)='2) alias name.s '
	syntax(4)='3) alias name.s entity.s or alias mame.s := entity.s' 
	syntax(5)='4) alias nams.s := '

	if(nk.gt.0) then		! there are some user defined keywords.
	  call find1(nk,udks,i)
	  if(i.lt.0) then
	    ib_udk=ib
	    ie_udk=ie
	    if(nword(n_len,txt,ib,ie)) then
	      errmsg=' errmsg: undifined alias'
	      return 1
	      endif
	    goto 1900			! define 'i'
	  else if(i.eq.0) then	! list aliases
	    do j=1,nk
	      if(udks(j).ne.' ') write(6,*) 
     1 udks(j)//' := '//alias(j)(:ltrim(alias(j)))
	      enddo
	    return
	  else			! specific alias
	    if(nword(n_len,txt,ib,ie)) then
	      write(6,*) udks(i)//' :='//alias(i)(:ltrim(alias(i)))
	      return
	    else
	      write(6,*) udks(i)//' definition is overwritten.'
              goto 2000
	      endif
	    endif
	else
	  if(nword(n_len,txt,ib,ie)) return
	  ib_udk=ib
	  ie_udk=ie
	  if(nword(n_len,txt,ib,ie)) then
	    errmsg=' errmsg: undifined alias'
	    return 1
	    endif
	  endif

1900	num_udks=mod(num_udks,max_udks)+1
	nt=nt+1
	if(nt.gt.max_udks) then
	    write(6,*) udks(num_udks)//' definition is overwritten.'
	    endif
	nk=min(nt,max_udks)
	i=num_udks
	udks(i)=txt(ib_udk:ie_udk)

2000	if(txt(ib:ib).eq. delimiter ) then
	  ib=ib+1
	  j=ib
	  do while (.true.)
	    if( txt(j:j).eq. delimiter ) goto 2100
	    j=j+1
	    if(j.ge.n_len) goto 2100
	    enddo
2100	  n_len=j-1
	  endif

	np=n_len-ib+1
	ie0=0

	if(np.le.0) then
	  na(i)=0
	  udks(i)=' '
	else if(nword(np,txt(ib:n_len),ib0,ie0)) then
	  na(i)=0
	  udks(i)=' '
	else
	  na(i)=np+1
	  np=min(ie-ib+1,8)
	  if(udks(i)(:np).eq.txt(ib:ie)) then
	    udks(i)=' '
	    na(i)=0
	    errmsg=' errmsg: looped difinition is not allowed.'
	    return 1
	    endif
	  alias(i)=' '//txt(ib:n_len)
	  endif
	end

copyright by X. Cai Zhang

	subroutine volume(*)
chk	=================
	include 'edp_main.inc'
! 	use edp_main
	include 'edp_file.inc'
! 	use edp_file
	include 'edp_dat.inc'
! 	use edp_dat

	parameter 	(io=48, max_as=2000)
	parameter 	(pi=3.1416, pi2=pi*2.0, hpi=pi*0.5)

	logical map(max_map,max_map)
	dimension rdi(max_atom), rdj(max_atom)
     1,rd1(max_as),rd2(max_as),ird(max_as)

	integer  index1(max_atom), index2(max_atom), isort(max_atom)

	logical nword
	character*(max_num_chars) txt
	common /cmm_txt/ n_len,txt,ib,ie

	n_of_syn=2					!000515
	syntax(1)='syntax:' 
	syntax(2)='volume [probe_radius.r] [zstep.r] [filename.s]'

	r_max=0.0
	zstep=0.2
	if(acc_in.eq.'?') acc_in=acc_dat
	call read_ar(1, r_max, *900,*100)
100	if (r_max.lt.0..or.r_max.gt.8.0) then
	  errmsg=' errmsg: 0.<= probe_radius < 8.0'
	  return 1
	  endif

	call read_ar(1, zstep, *900,*200)
200	if (zstep.lt.0.05) then
	  errmsg=' errmsg: 0.05 < zstep'
	  return 1
	  endif

chk	input file name of acc.txt type
	if(.not.nword(n_len,txt,ib,ie)) acc_in=txt(ib:ie)

	vol=0.
	n_gb=0
	do ii=1,n_res
		do i=ijk(ii),ijk(ii+1)-1		
			if(lf(i)) then
				n_gb=n_gb+1
				index1(n_gb)=i
				index2(n_gb)=ii
				rdi(n_gb)=z(i)
			end if
		end do
	end do
	if(n_gb.le.0) then
	  write(6,*) 'volume-W> UNDONE: no on atom exist.'
	  return
	end if

	write(6,1019) r_max, zstep
1019	format(' volume-I> probe_r=',f5.2,', step_size=',f5.2)

c	sort atoms by z
	call sort_rl(n_gb,rdi,isort)

c	define the vdw radius.
	call acc_index(n_gb,index1,index2,rdi,r_max,*990)

	jj=0
	zmin=1024.
	zmax=-1024.
	do ii=1,n_gb
		isorti=isort(ii)
		jj= jj +1
		index2(jj)= index1(isorti)
		rdj(jj)= rdi(isorti)
		if (zmin.gt.z(index2(jj)) -rdj(jj)) 
     1	 zmin=   z(index2(jj)) -rdj(jj)
		if (zmax.lt.z(index2(jj)) +rdj(jj))  
     1	 zmax=   z(index2(jj)) +rdj(jj)
	end do

	zcurr=zmin +zstep*0.5
	j1=1
	vol1= zstep*zstep*zstep
	vol=0.
	do i=1,max_map
	 do j=1,max_map
	  map(j,i)=.false.
	 enddo
	enddo

	do while (zcurr.lt.zmax)
	  j0=j1
	  nj=0
	  xmin=1024.
	  ymin=1024.
	  xmax=-1024.
	  ymax=-1024.
	  do j=j0,n_gb
		jj=index2(j)
		dz=zcurr-z(jj)
		if(dz.ge.r_max) then
		  j1= j+1
		else 
		  if(-dz.ge.r_max) goto 420
		  ri= rdj(j)
		  if(abs(dz).lt.ri ) then
		   nj= nj +1
		   if(nj.gt.max_as) goto 499
		   rd2(nj)= ri*ri-dz*dz
		   rd1(nj)= sqrt(rd2(nj))
		   ird(nj)= jj
		   xmax= max( xmax,x(jj)+rd1(nj))	  
		   ymax= max( ymax,y(jj)+rd1(nj))	  
		   xmin= min( xmin,x(jj)-rd1(nj))	  
		   ymin= min( ymin,y(jj)-rd1(nj))	  
	 	  end if
		end if
	  end do

420	  if(nj.le.0) goto 492
	  maxx=(xmax-xmin)/zstep+2
	  if(maxx.gt.max_map) goto  497
	  maxy=(ymax-ymin)/zstep+2
	  if(maxy.gt.max_map) goto  497

	  do 485 ii=1,nj
	    i= ird(ii)
	    ri= rd1(ii)
	    ris= rd2(ii)
	    xi=x(i) -xmin
	    yi=y(i) -ymin
	    min_y= int((yi -ri)/zstep) +1
	    max_y= int((yi +ri)/zstep) 
	    do jj= min_y, max_y
	     yj= yi- jj* zstep
	     xj= ris-yj*yj
	     if(xj.gt.0.) then
	      xj=sqrt(xj)
	      min_x= int((xi -xj)/zstep) +1
	      max_x= int((xi +xj)/zstep) 
	      do kk= min_x, max_x
		map(kk,jj)=.true.
	      enddo
	     endif
	    enddo
485	  continue

	 n_count= 0 
	 do j=1,maxy
	 do i=1,maxx
	  if(map(i,j)) then
	   map(i,j)=.false.
	   n_count=n_count +1 
	   endif
	  enddo
	  enddo
	 vol=vol+ n_count* vol1
492      zcurr= zcurr +zstep
	end do

	write(6,1020) vol
1020	format(' volume> total volume is about ',e10.4
     1,' cubic angstroms.')
	return

497	write(6,*) 
     1'volume-W> UNDONE: the x-y dimension is too large. '
     1,'Increase the step size,'
	write(6,*)
     1'          or re-orient the molecule using MOMENTINERTIA.' 
	return

499	write(6,*) 
     1'volume-W> UNDONE: too many atoms in one section. '
     1,'Increase the step size,'
	write(6,*)
     1'          or re-orient the molecule using MOMENTINERTIA.' 
	return

900	return 1

990	end
c***	end of volume.for

copyright by X. Cai Zhang
