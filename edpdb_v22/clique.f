
	subroutine diff_g_o(igr,igo,s1,s2)
chk	===================
	include 'edp_main.inc'
! 	use edp_main

	n_of_syn=3					!000515
	syntax(1)='syntax:' 
	syntax(2)='diff group_id.s [(rms, morph [lamda.r], '
	syntax(3)='     scale [scale1.r scale2.r])] '

	n_group0=0
	do i=1,n_atom
	 if(lf(i)) n_group0=n_group0+1
	enddo
	n_group2=n_groupa(igr)

	write(6,1009) n_group0,cgroup(igr),n_group2
1009	format(' diff> #of on atoms (na)=',i5,
     1 ', #of atoms in group ',a,' (ng)=',i5)

	if(n_group0.ne.n_group2) then
	  write(6,'(a)') ' diff-W> UNDONE: na =/= ng.'
	  return
	endif

	do jj=1,n_group2
	  if(lf(igroupa( jj,igr))) then
	   write(6,1010) cgroup(igr)
1010	   format(
     1' diff-W> UNDONE: group ',a,' overlaps with the on atoms.')
	   return
	  endif
	enddo

	jj=0
	if(igo.eq.0) then
	  do i=1,n_atom
	    if(lf(i)) then
	     jj=jj+1
	     j=igroupa( jj,igr)
	     read(text(i)(31:54),1061,err=900) xi,yi,zi
	     read(text(j)(31:54),1061,err=900) xj,yj,zj
1061	format(3f8.3)
	     dx=xj*s1-xi*s2
	     dy=yj*s1-yi*s2
	     dz=zj*s1-zi*s2
	     write(text(i)(31:54),1061,err=901) dx,dy,dz
	     w(i)=w(j)*s1-w(i)*s2
	     b(i)=b(j)*s1-b(i)*s2
	    endif
	  enddo
	else
	  do i=1,n_atom
	   if(lf(i)) then
	    jj=jj+1
	    j=igroupa( jj,igr)
	    read(text(i)(31:54),1061,err=900) xi,yi,zi
	    read(text(j)(31:54),1061,err=900) xj,yj,zj
	    dx=xj-xi
	    dy=yj-yi
	    dz=zj-zi
	    write(text(i)(31:54),1061,err=901) dx,dy,dz
	    w(i)=sqrt(dx*dx+dy*dy+dz*dz)
	    b(i)=b(j)-b(i)
	   endif
	  enddo
	endif
	return
900	write(6,'(a)') ' diff-W> ABORTED: error in encoding x,y,z'
	return
901	write(6,'(a)') ' diff-W> ABORTED: error in decoding x,y,z'
	end

	subroutine ratio_g_o(igr,s,dfr)
chk	====================
	include 'edp_main.inc'
! 	use edp_main

	n_of_syn=2					!000515
	syntax(1)='syntax:' 
	syntax(2)='ratio group_id.s [scale [def_value]] '

	n_group0=0
	do i=1,n_atom
	 if(lf(i)) n_group0=n_group0+1
	enddo
	n_group2=n_groupa(igr)

	write(6,1009) n_group0,cgroup(igr),n_group2
1009	format(' ratio> # of on atoms (na)=',i5,
     1 ', # of atoms in group ',a,' (ng)=',i5)

	if(n_group0.ne.n_group2) then
	  write(6,'(a)') ' ratio-W> UNDONE: na =/= ng.'
	  return
	endif

	do jj=1,n_group2
	  if(lf(igroupa( jj,igr))) then
	   write(6,1010) cgroup(igr)
1010	format(' ratio-W> UNDONE: group ',a,' overlaps with the on atoms.')
	   return
	  endif
	enddo

	jj=0
	idf=0
	ierr=0
	do i=1,n_atom
	  if( lf(i)) then
	    jj=jj+1
	    j=igroupa( jj,igr)
	    if( abs(w(i)) .gt. 5.e-3) then 
	     w(i)=w(j)/w(i)*s
	     if( w(i) .lt. -99. .or. w(i) .gt. 999.) goto 700
	    else
	     w(i)=dfr
	     idf= idf+ 1
	    endif
	    if( abs(b(i)) .gt. 5.e-3) then 
	     b(i)=b(j)/b(i)*s
	     if( b(i) .lt. -99. .or. b(i) .gt. 999.) then
	      b(i)= dfr
	      goto 700
	     endif
	    else
	     b(i)=dfr
	     idf= idf+ 1
	    endif
	    read(text(i)(31:54),1061,err=900) xi,yi,zi
	    read(text(j)(31:54),1061,err=900) xj,yj,zj
1061	format(3f8.3)
	    if( abs(xi) .gt. 1.e-3) then 
	     xi=xj/xi*s
	    else
	     xi= dfr
	     idf= idf+ 1
	    endif
	    if( abs(yi) .gt. 1.e-3) then 
	     yi=yj/yi*s
	    else
	     yi= dfr
	     idf= idf+ 1
	    endif
	    if( abs(zi) .gt. 1.e-3) then 
	     zi=zj/zi*s
	    else
	     zi= dfr
	     idf= idf+ 1
	    endif
	    write(text(i)(31:54),1061,err=700) xi,yi,zi
	  endif
	  goto 800
700	  ierr= ierr+ 1
	  w(i)= dfr
800	enddo
	if( idf .gt. 0)  write(6,'(a)') 
     1 ' ratio-W> # of def_v used for /0. =',idf 
	if( ierr .gt. 0) write(6,'(a)') 
     1 ' ratio-W> # of errors (other than /0.) =',ierr
	return

900	write(6,'(a)') ' ratio-W> ABORTED: error in encoding x,y,z.'
	return
	end

copyright by X. Cai Zhang

	subroutine swap(*)
chk	===============
	include 'edp_main.inc'
! 	use edp_main

	integer isort(max_atom)

	n_of_syn=3					!000515
	syntax(1)='syntax:' 
	syntax(2)='1) swap '
	syntax(3)='2) swap group_id.s '	

	call find_a_group(igr)

	if( igr .lt. 0) then
	  return 1
	else if( igr .eq. 999) then
	  do i= 1, n_atom
	    lf(i)= .not. lf(i)
	  enddo
	else 
	  do i= 1, n_atom
	    if( lf(i)) then
	      isort(i)= 1
	    else
	      isort(i)= 0
	    endif
	    lf(i)= .false.
	  enddo
	  n_group1= n_groupa(igr)
	  do i= 1, n_group1
	    lf(igroupa( i,igr))= .true.
	  enddo
	  j=0
	  do ir= 1, n_res
	    do i= ijk(ir), ijk(ir+1)-1
	      if( isort(i) .eq. 1) then
		j= j+ 1
		igroupa(j,igr)= i
	      endif
	    enddo
	  enddo
	  n_groupa(igr)=j
	endif
	end

	subroutine group(*)
chk	================
	include 'edp_main.inc'
! 	use edp_main

	character*(max_num_chars) txt
	common /cmm_txt/ n_len,txt,ib,ie
	logical nword

	logical from_phrase

	n_of_syn=2					!000515
	syntax(1)='syntax:' 
	syntax(2)='group [group_id.s]' 

	from_phrase=index(txt(:n_len),'from').le.0
	call dfgroup(igr,*900) 

	call find_a_group(ist)
	if( ist .eq. 999) then
	  do igr=1, max_gr
	    if(n_groupa(igr).gt.0) then
	      write(6,1079)  cgroup(igr), n_groupa(igr)
1079	      format(2x,'group ',a,' [',i6,']')
	      endif
	    enddo
	  return
	else if(ist.lt.0) then
	  return 1
	else if(.not.nword(n_len,txt,ib,ie) ) then
	  return 1
	  endif
	
2001	if(.not.from_phrase) then
	  n_g=n_groupa(igr)
	  do i=1,n_g
	    igroupa(i,ist)=igroupa(i,igr)
	    enddo
	else
	  n_g=0
	  do i=1,n_atom
	      if(lf(i)) then
	        n_g=n_g+1
	        igroupa( n_g,ist)=i
		end if
	    end do
	  endif
	n_groupa(ist)=n_g
	return
900	return 1
	end
	
	subroutine load(*)
chk	===============
	include 'edp_main.inc'
! 	use edp_main
	include 'edp_dat.inc'
!	use edp_dat

	logical lf1(max_atom)

	n_of_syn=2					!000515
	syntax(1)='syntax:' 
	syntax(2)='load group_id.s '

	do i=1,n_atom
	  lf1(i)=.false.
	  enddo

	call dfgroup(igr,*900) 

	call find_a_group(ist)

	if( ist .eq. 999) then
	  do igr=1, max_gr
	    if(n_groupa(igr).gt.0) then
	      write(6,1079)  cgroup(igr), n_groupa(igr)
1079	      format(2x,'group ',a,' [',i6,']')
	      endif
	    enddo
	  return
	else if(ist.lt.0) then
	  return 1
	  endif

c	ist= match_l( max_gr, cgroup)  
c	if( ist .le. 0) return 1

	j1=n_groupa(igr)
	do j=1,j1
	  i=igroupa( j,igr)
	  lf1(i)=.true.
	  enddo

	do while (ist.gt.0)
	  if (n_groupa(ist).le.0.and.verbose.ge.3 ) 
     1    write(6,'(a)') ' load-W3> empty or undefined group(s)'
  	  jje=n_groupa(ist)
	  do  jj=1,jje
	    j=igroupa( jj,ist)
	    if(lf1(j)) lf(j)=incl
	    end do
	  ist= match_l( max_gr, cgroup)  
	  enddo 
	return
900	return 1
	end

	subroutine dist( *)
chk	===============
	include 'edp_main.inc'
! 	use edp_main
	include 'edp_dat.inc'
!	use edp_dat
	include 'edp_file.inc'
!	use edp_file

	parameter (io=48, max_as= 2048)
	parameter (max_th=256)
	parameter (pi=3.1416, pi2=pi*2.0, hpi=pi*0.5)
!	integer, parameter :: io=48, max_as= min(max_atom/3,2048)
!	integer, parameter :: max_th=256
!	real,    parameter :: pi=3.1416, pi2=pi*2.0, hpi=pi*0.5

	logical lth 
	dimension rdi(max_atom), rdj(max_atom)		! for acc
     1,rd1(max_as),rd2(max_as),ird(max_as)
     1,th1(max_th),th2(max_th), lth(max_th)
	equivalence (rd1(1),rdi(1))		! save memory
	equivalence (rd2(1),rdi(max_as+1))
	equivalence (ird(1),rdi(max_as*2+1))

	integer  
     1 index1(max_atom),index2(max_atom)
     1,isort(max_atom)			!swap
     1,jsort(max_atom)			!sdistance

	character*(max_num_chars) txt
	common /cmm_txt/ n_len,txt,ib,ie
	logical nword, nword0

	logical unit, storea, wsymm, storeb
!	logical ierr, unit, storea, wsymm, storeb
c	logical l_prekin	! for dist
	logical overlap		! for sdistance
	logical isolated, buried	! for acc
	logical one_on_atom	! for acc

	character*12 s_move(5)	!, s_load, s_copy, s_prekin
	character*6 cnum
c	equivalence (s_load,s_move(1))

	dimension trn(3,4), trn1(3,3), trn0(3,3), sym(3,4)
	character*32 symm_txt

	real ts(3), tmpa(3,3), sym0(3,3), ts0(3)
	integer its(3), fx1(3),fx2(3)

	data s_move/'load','move','punch_all','copy','mark'/
c	data s_prekin/'prekin'/
	save

	n_of_syn=3					!000515
	syntax(1)='syntax:' 
	syntax(2)='distance group_id.s dmin.r dmax.r '
	syntax(3)='  [skip.i max_output.i] [(load, copy)]' 

c	l_prekin=.false.
	igr= match_l( max_gr, cgroup)
	if( igr .le. 0) then
	  errmsg=' errmsg: a group name needed'
	  return 1
	  end if
	n_group2= n_groupa(igr)
	if( n_group2.le.0) then
	  write(6,*) 
     1 'dist-W> UNDONE: define group ['//cgroup(igr)//'] first.'
	  return
	  end if

	n_group1=0
	xc=0.
	yc=0.
	zc=0.
	do i= 1, n_atom
	  if( lf(i)) then
	    xa=x(i)
	    ya=y(i)
	    za=z(i)
	    xc=xc+xa
	    yc=yc+ya
	    zc=zc+za
	    n_group1=n_group1+1
	    endif
	  enddo
	if( n_group1 .le. 0) then
	  write(6,'(a)') ' dist-W>  UNDONE: no on atom exist.'
	  return
	  end if

chk	input dmin, dmax
	dmax=0.0
	call read_ar(1, dmin, *990, *49)
	call read_ar(1, dmax, *990, *49)
49	if(dmax.lt.dmin) then
	  rsmax=dmax
	  dmax=dmin
	  dmin=rsmax
	  endif
	if(dmin.lt.0.) return 1

chk	input iskip
	iskip=1	! 990422
	imax=max_atom
	storea= .false.
	itmp=0

	call read_ai(1, iskip, *990, *50)
	iskip= abs( iskip)
50	if( .not. nword0(n_len,txt,ib,ie) ) then
	  if( ib  .gt.ie) then
	    imax=max_atom
	  else
	    read(txt(ib:ie),*,err=990) imax
	    if( imax .lt. 0 .or. imax .gt. max_atom) then
	      write(cnum,1062) max_atom
1062	      format(i6)
	      errmsg=
     1' errmsg: the maximum # of listout should be less than'//cnum
	      return 1
	      endif
	    endif
	  itmp= match_l1(5,s_move)
	  if( itmp.ne.1 .and. itmp.ne.4 .and. itmp.ne.5) return 1
	  storea=itmp.eq.1
	  endif

	if(verbose.ge.4 ) then
	  write(6,'(a,f6.2)') ' distance-I4> dmin=', dmin
	  write(6,'(a,f6.2)') ' distance-I4> dmax=', dmax
	  write(6,'(a,i6)'  ) ' distance-I4> skip=', iskip
	  write(6,'(a,i6)')   ' distance-I4> max_output=', imax
	
	  if(igo.eq.1) then
	    write(6,*) 
     1'distance> the group SCR is stuffed with selected atoms'//
     1' from group ['//cgroup( igr)//']'
	  else  if(igo.eq.4) then
	    write(6,'(a)') 
     1' distance-I> the  occ(w) of the ON atom is replaced with '
	    write(6,'(a)') 
     1'              that of the last matched atom from the group'
	    endif
	  endif

	write(6,1009) 'distance', n_group1, cgroup(igr), n_group2

	rsmin=dmin*dmin
	rsmax=dmax*dmax

	ksum=0
	av=0.
	sgm=0.
	do ir= 1, n_res
	  do 110 i= ijk(ir), ijk(ir+1)-1
	    if( lf(i)) then
	      xa=x(i)
	      ya=y(i)
	      za=z(i)
	      w(i)=0.
	      do 100 jj=1,n_group2
		j= igroupa(jj,igr)
		jr=aa_seq(j)
		if( abs(ir-jr) .lt. iskip) goto 100
c	        if( lf(j) .and. j.le.i ) goto 100
		dx=xa-x(j)
		if( abs(dx) .gt. dmax) goto 100
		dy=ya-y(j)
		if( abs(dy) .gt. dmax) goto 100
		dz=za-z(j)
		if( abs(dz) .gt. dmax) goto 100
		dr=dx*dx+dy*dy+dz*dz
		if(dr .lt. rsmin .or. rsmax .lt. dr) goto 100
		curr=sqrt(dr)
		av=av+curr
		sgm=sgm+curr*curr
		write(io,1001) text(i)(14:27),text(j)(14:27), curr
		if(itmp.eq.4) then	! the option 'COPY' !010126
		  text(i)(31:54)=text(j)(31:54)
		  b(i)=b(j)
		  w(i)=w(j)
		else if(itmp.eq.5) then	! the option 'MARK' !990422
		  w(i)=w(j)
		else 
		  w(i)=w(i)+1.
		  endif
c	        if(.not.incl) lf(j)=.false.		! 940324
	        ksum=ksum+1
		if( storea) then
	          igroupa( ksum,1)= j

c	        else if( l_prekin) then
cc	prekin is a subroutine to make vectorlist for kinemage plotting.
c	          call prekin(i,ir,j,jr)

	          endif
		if( ksum .ge. imax) then
	          write(cnum,1062) imax
		  errmsg=
     1' errmsg: the number of atom pairs is larger than '//cnum
		  return 1
		  endif
	        if(.not.incl) then 
		  lf(i)=.false.		! 021218
		  goto 110
		endif
100	      end do 
	    end if
110	  end do
	end do
	xg=0.
	yg=0.
	zg=0.
	do jj=1,n_group2
	  j=igroupa( jj,igr)
	  xg=xg+x(j)
	  yg=yg+y(j)
	  zg=zg+z(j)
	  enddo
	xc=xc/n_group1
	yc=yc/n_group1
	zc=zc/n_group1
	xg=xg/n_group2
	yg=yg/n_group2
	zg=zg/n_group2
	distance=sqrt((xc-xg)**2+(yc-yg)**2+(zc-zg)**2)

200	if( storea) n_groupa(1)=ksum
	if( ksum .eq. 0)then
	  write(6,1008) ksum
	  write(6,1007) distance
	else
	  sumk=1./ksum
	  av=av*sumk
	  sgm=sgm*sumk
	  sgm=sqrt( max(0.,sgm-av*av))
	  write(6,1008)  ksum, av, sgm
	  write(6,1007)  distance
	  write(io,1008) ksum, av, sgm
	  write(io,1007) distance
	end if

1001	format(1x,2(a14,','),'d= ',f8.3)
1007	format(
     1'                      dist. between the mass centres =',f8.3)
1008	format('!distance>',i6,' records are calculated':
     1', avd=',f8.3,', sgmd=',f8.3)
1009	format(' ',a,'> # of on atoms =',i5,
     1 ', # of atoms in group ',a,' =',i5)

c	if(l_prekin) call prekin1
	call typelist(io)
	return

990	return 1

	entry closer(*)
chk	============
chk	input: group_id1, group_id2, dmax
chk	output: w(i)=999. -- not closer to group1
chk	output: w(i)<dmax --     closer to group2

	n_of_syn=2					!000515
	syntax(1)='syntax:'
	syntax(2)='closer group1.s group2.s dmax.r' 

chk	the first group
	igr= match_l( max_gr, cgroup)
	if( igr .le. 0) then
	  errmsg=' errmsg: a group name needed'
	  return 1
	  endif

	n_group2= n_groupa(igr)
	if( n_group2.le.0) then
	  write(6,*) 
     1 'closer-W> UNDONE: define group ['//cgroup(igr)//'] first.'
	  return
	  end if

chk	the second group
	igrb= match_l( max_gr, cgroup)
	if( igrb .lt. 0) then
	  write(6,*) 
     1 'closer-W>  UNDONE: define group ['//cgroup(igr)//'] first.'
	  return
	else if(igrb.eq.0) then
	  n_group2b= 0
	else
	  n_group2b= n_groupa(igrb)
	  endif

	n_group1=0
	do i= 1, n_atom
	  if( lf(i)) n_group1=n_group1+1
	  enddo
	if( n_group1 .le. 0) then
	  write(6,'(a)') 'closer-W>  UNDONE: no on atom exist.'
	  return
	  endif

	call read_ar(1, dmax, *990, *990)
	if(dmax.lt.0.) return 1
	rsmax=dmax*dmax

	write(6,1009) 'closer', n_group1, cgroup(igr), n_group2
	write(6,1009) 'closer', n_group1, cgroup(igrb), n_group2b

	do ir= 1, n_res
	do i=ijk(ir),ijk(ir+1)-1
	  if( lf(i)) then
	    xa=x(i)
	    ya=y(i)
	    za=z(i)
	    dmin_b=999.
	    w(i)=999.	    
	    do 5100 jj=1,n_group2b
	      j= igroupa( jj,igrb)
	      dx=xa-x(j)
	      if( abs(dx) .gt. dmax) goto 5100
	      dy=ya-y(j)
	      if( abs(dy) .gt. dmax) goto 5100
	      dz=za-z(j)
	      if( abs(dz) .gt. dmax) goto 5100
	      dr=dx*dx+dy*dy+dz*dz
	      if( rsmax .lt. dr) goto 5100
	      dr=sqrt(dr)
	      if(dr.lt.dmin_b) dmin_b=dr
5100	      enddo	! group atoms

	    dmax_b=min(dmax,dmin_b)
	    rsmax_b=dmin_b*dmin_b
	    do 6100 jj=1,n_group2
	      j= igroupa( jj,igr)
	      dx=xa-x(j)
	      if( abs(dx) .gt. dmax_b) goto 6100
	      dy=ya-y(j)
	      if( abs(dy) .gt. dmax_b) goto 6100
	      dz=za-z(j)
	      if( abs(dz) .gt. dmax_b) goto 6100
	      dr=dx*dx+dy*dy+dz*dz
	      if( dr .gt. rsmax_b ) goto 6100
	      dr=sqrt(dr)
	      if(dr.lt.w(i)) then
	        w(i)=dr
	        endif
6100	      enddo	! group atoms
	    endif	! ON?
7100	  enddo	! atoms
	  enddo	! residues
	return
	
c	include nbe.for
c	this entry has been deleted 920625
391	return

	entry acc(*)
chk	============
	n_of_syn=3					!000515
	syntax(1)='syntax:' 
	syntax(2)=
     1'access [group_id.s] [{isolated,buried}] '
	syntax(3)=
     1'  [r_probe.r] [zstep.r] [filename.s]' 

	if(verbose.ge.6 ) write(6,1069) 	!000504
1069	format(' access-I6> reference:'
     1/'  Lee, B. and Richards, F. M.(1971). J. Mol. Biol. 55:379-400.')	

chk	input parameters

chk	input group_id
	igr= match_l( max_gr, cgroup)
	if( igr .lt. 0) then
	  errmsg=' errmsg: a wrong group name.'
	  return 1
	else if(igr.eq.0) then
	  n_group2=0
	else
	  n_group2= n_groupa(igr)
	  endif

	isolated=.false.
	buried=.false.
	r_max=1.4
	zstep=0.2
	if(acc_in.eq.'?') acc_in=acc_dat

chk	input 'isolated' option
	if (.not.nword(n_len,txt,ib,ie) ) then
	  if( txt(ib:ie).eq.'isolated') then
	      isolated=.true.
	  else if( txt(ib:ie).eq.'buried' ) then
		  buried=.true.
	  else
	      return 1
	    endif
	  endif

chk	input probe radius
	call read_ar(1,r_max, *900, *4002)
4002	if (r_max.lt.0..or.r_max.gt.10.) then
	  errmsg=' errmsg: 0.< probe_radius < 10.'
	  return 1
	  endif

chk	input integration step size
	call read_ar(1,zstep, *900, *4003)
4003	if(zstep.lt.0.) zstep=0.2

chk	input file name of acc.txt type
	if (.not.nword(n_len,txt,ib,ie)) acc_in=txt(ib:ie)

chk	end of parameter input

	n_gb=0
	do ii=1,n_res
		do i=ijk(ii),ijk(ii+1)-1		
			if(lf(i)) then
				n_gb=n_gb+1
				index1(n_gb)=i
				index2(n_gb)=ii
				rdi(n_gb)=z(i)
				w(i)=0.
			end if
		end do
	end do
	if(n_gb.le.0) then
	  write(6,'(a)') ' access-W> UNDONE: no on atom exist.'
	  write(6,1020)  0.0
	  return
	else
	  one_on_atom=n_gb.eq.1
	end if

	if(igr.gt.0) then
	  write(6,1019) cgroup(igr), n_group2
	else
	  write(6,1019) ' ', n_group2
	  endif
1019	format(' access> # of atoms in group ',a,' =',i5,
     1', which will be used as background.')

	if(verbose.ge.4 ) write(6,1029) r_max, zstep
1029	format(
     1' access-I4> occ(w) of the on atoms will be replaced '
     1,'by accessible areas.'
     1/' access-I4> r_probe=',f5.2,', zstep=',f5.2)
	
	n_ga=n_gb
	do i=1,n_group2
	  if( .not. lf(igroupa( i,igr))) then
		n_gb= n_gb +1
		index1(n_gb)=igroupa(i,igr)
		index2(n_gb)=aa_seq(index1(n_gb))
		rdi(n_gb)=z(index1(n_gb))
	  end if
	end do

c	sort atoms by z
	call sort_rl(n_gb,rdi,isort)

c	define the vdw radius.
	call acc_index(n_gb,index1,index2,rdi,r_max,*391)

	jerr=0
	jj=0
	kk=n_ga
	zmin=1024.
	zmax=-1024.

	do ii=1,n_gb
		isorti=isort(ii)
		if(isorti.le.n_ga) then
			jj= jj +1
			index2(jj)= index1(isorti)
			rdj(jj)= rdi(isorti)
			if (zmin.gt.z(index2(jj)) -rdj(jj))  !rdj(1)=/=rdj(i)
     1		    zmin=   z(index2(jj)) -rdj(jj)
			if (zmax.lt.z(index2(jj)) +rdj(jj))  !rdj(n_ga)=/=rdj(i)
     1		    zmax=   z(index2(jj)) +rdj(jj)
		else
			kk= kk +1
			index2(kk)= index1(isorti)
			rdj(kk)= rdi(isorti)
		end if
	end do
	
	one_or_minus_one=1.0
	
500	zcurr=zmin +zstep*0.5
	j1=1
	i1=n_ga+1
	area=0.0
	  
	do while (zcurr.lt.zmax)
	  j0=j1
	  nj=0
	  do j=j0,n_ga
	    dz=zcurr-z(index2(j))
	    if(dz.ge.r_max) then
	      j1= j+1
	    else 
	      if(-dz.ge.r_max) goto 420
	      ri= rdj(j)
	      if(abs(dz).lt.ri ) then
	        nj= nj +1
		if(nj.gt.max_as) goto 499
		rd1(nj)= sqrt(ri*ri-dz*dz)
		rd2(nj)= zstep*ri
		ird(nj)= index2(j)
		if(one_on_atom) phi=acosd(dz/ri)
	        endif
	      endif
	    enddo

420	  if(nj.le.0) goto 492
	  ni= nj
	  i0=i1
	  do i=i0,n_gb
		dz=zcurr-z(index2(i))
		if(dz.ge.r_max) then
		  i1=i+1
		else 
		  if(-dz.ge.r_max) goto 430
		  ri=rdj(i)
		  if(abs(dz).lt.ri ) then
		  	nj= nj +1
			if(nj.gt.max_as) goto 499
			rd1(nj)= sqrt(ri*ri-dz*dz)
			ird(nj)= index2(i)
		  end if
		end if
	  end do

430	  arc=0.
	  if(isolated) then
	    jj0=ni+1
	  else
	    jj0=1
	    endif
	  do ii=1,ni
	    i= ird(ii)
	    ri= rd1(ii)
	    ris= ri*ri
	    ri2= ri*2.
	    k=0
	    do 480 jj=jj0,nj
		if(ii.eq.jj) goto 480
		j= ird(jj)
		rj= rd1(jj)
		rij= ri +rj
		dx= x(j) -x(i)
		if(abs(dx).ge.rij) goto 480
		dy= y(j) -y(i)
		if(abs(dy).ge.rij) goto 480
		r2= dx*dx +dy*dy
		r1= sqrt(r2)
		if(r1.ge.rij.or.ri.ge.r1+rj) goto 480
		if(rj.ge.r1+ri) goto 485
	        r1= (ris +r2 -rj*rj)/(r1*ri2)
		if( abs(r1) .gt. 1.) r1=sign(1.,r1)
		r1= acos(r1)
	        r2= atan2(dy,dx)

		if(k.ge.max_th) then
		 if(jerr.eq.0)  write(6,*) 
     1 'access-W> record #',i,' has too many neigbours.'
		 jerr=jerr+1
		 goto 498
		endif
		k=k+1
		lth(k)=.true.
		th1(k)= r2 -r1
		th2(k)= r2 +r1
		if(th1(k).lt.-pi) then
		  if(k.ge.max_th) then
		   th1(k)=-pi
		   if(jerr.eq.0) write(6,*)
     1 'access-W> record #',i,' has too many neigbours.'
		   jerr=jerr+1
		   goto 498
		  endif
		  k=k+1
		  lth(k)=.true.
		  th1(k)= pi2 + th1(k-1)
		  th2(k)= pi
		  th1(k-1)=-pi
		else if(th2(k).gt.pi) then
		  if(k.ge.max_th) then
		   th2(k)=pi
		   if(jerr.eq.0)write(6,*)
     1 'access-W> record #',i,' has too many neigbours.'
		   jerr=jerr+1
		   goto 498
		  endif
		  k=k+1
		  lth(k)=.true.
		  th1(k)= -pi
		  th2(k)= th2(k-1)-pi2
		  th2(k-1)= pi
		end if
480	    continue

498	    do 481 k1=1,k
		do j2= k1+1,k
	          if (th2(j2)-th1(j2).ge.pi2) goto 485
	if         (th1(j2).le.th1(k1).and.th1(k1).le.th2(j2)) then
		if (th2(j2).lt.th2(k1)) th2(j2)=th2(k1)
		lth(k1)=.false.
		goto 481
	else	if (th1(j2).le.th2(k1).and.th2(k1).le.th2(j2)) then
		if (th1(k1).lt.th1(j2)) th1(j2)=th1(k1)
		lth(k1)=.false.
		goto 481
	else	if (th1(k1).lt.th1(j2).and.th2(j2).lt.th2(k1)) then
		th1(j2)= th1(k1)
		th2(j2)= th2(k1)
		lth(k1)=.false.
		goto 481
	end if
		end do
481	continue

	    arc=pi2
	    do k1=1,k
	      if(lth(k1)) then
	        arc=arc -(th2(k1)-th1(k1))
	        endif
	      enddo
	    arc= arc*rd2(ii)
	    area= area +arc
	    w(i)=w(i) +arc*one_or_minus_one
485	    if(one_on_atom) write(io,1090) phi,arc
1090	    format(5x,'phi=',f8.3,', acc=',f8.3)
	  enddo

492	  zcurr= zcurr +zstep
	  enddo

	if(buried) then
	 if(one_or_minus_one .le. 0.0) then
	  area=area0-area
	 else
	  area0=area
	  n_gb=n_ga
	  one_or_minus_one=-1.0
	  goto 500
	 endif
	endif

	if(jerr.gt.0) write(6,1021)  jerr
	write(6,1020)  area
1020	format(' access> the sum of the area is about',f8.0
     1,' square angstroms.')
1021	format(' access-W> # of errors =',i8)
	if(one_on_atom) call typelist(io)
	return

499	write(6,'(a)') 
     1' access-W> UNDONE: too many atoms in one section.'
	if(verbose.ge.3 ) write(6,*)
     1 '%EdPDB-I3- increase max_as in edp_dim.inc (currently'
     1 ,max_as,')'

	return
900	return 1

	entry sdistance(*)
c	===============
	n_of_syn=2					!000515
	syntax(1)='syntax:'
	syntax(2)=
     1'sdistance group_id.s dmin.r dmax.r [(load, move, punch_all)]' 

	igr= match_l( max_gr, cgroup)
	if( igr .le. 0) then
	  errmsg=' errmsg: a group name needed'
	  return 1
	end if
	n_group1= n_groupa( igr)
	if( n_group1.le.0) then
	  write(6,*) 
     1'sdistance-W> UNDONE: define group ['//cgroup( igr)//'] first.'
	  return
	end if
	
	n_group2=0
	do i= 1, n_atom
	  if( lf(i)) n_group2=n_group2+1
	end do
	if( n_group2 .le. 0) then
	  write(6,'(a)') ' sdistance-W> UNDONE: no on atom exist.'
	  return
	end if

chk	input dmin, dmax
	dmax=0.0
	call read_ar(1, dmin, *900, *549)
	call read_ar(1, dmax, *900, *549)
549	if(dmax.lt.dmin) then
	  rsmax=dmax
	  dmax=dmin
	  dmin=rsmax
	  endif
	if(dmin.lt.0.) return 1

	dmin0=dmin
	dmin=dmax

	igo= match_l1( 3,s_move)
	if( igo .lt. 0) then
	  return 1
	else if( igo .ge. 2) then ! move
	  do i=1,n_atom
	    if( lf(i) ) w(i)=999.0
	    end do
	else if( igo .eq. 1) then ! load 
	  n_groupa(1)=0
	  ksum=0
	  end if

	if(verbose.ge.4 ) then
	  write(6,*) 'sdistance-I4> dmin=', dmin0
	  write(6,*) 'sdistance-I4> dmax=', dmin
	  if(igo.eq.1) then
	    write(6,*) 
     1'sdistance> the group SCR is stuffed with selected atoms'//
     1' from group ['//cgroup( igr)//']'
	  else  if(igo.eq.2) then
	    write(6,'(a)') 
     1' sdistance> '
     1,'the displayed x,y,z and occ(w) of ON atoms are changed '
	    write(6,'(a)') 
     1'               to the closest positions and distances'
	  else  if(igo.eq.3) then
	    write(6,'(a)') 
     1' sdistance-I> all atoms in contacts are punched out'
	    endif
	  endif
	goto 992

	entry mmig(*)
c	==============
	n_of_syn=2					!000515
	syntax(1)='syntax:'
	syntax(2)=
     1'mmig group_id.s dmax.r [(load, move, punch_all)] [dmin.r]' 

	dmin0=0.

	igr= match_l( max_gr, cgroup)
	if( igr .le. 0) then
	  errmsg=' errmsg: a group name needed'
	  return 1
	end if
	n_group1= n_groupa( igr)
	if( n_group1.le.0) then
	  write(6,*) 
     1'mmig-W> UNDONE: define group ['//cgroup( igr)//'] first.'
	  return
	end if
	
	n_group2=0
	do i= 1, n_atom
	  if( lf(i)) n_group2=n_group2+1
	end do
	if( n_group2 .le. 0) then
	  write(6,'(a)') ' mmig-W> UNDONE: no on atom exist.'
	  return
	end if

c	read dmin
	call read_ar(1, dmin, *991, *991)
	if( dmin.le.0..or.dmin.gt.7.) then
	  if(txt(ib:ib).ne.'+'.or.dmin.le.0.) then
	    errmsg=' errmsg:  violation of 0.0 < dmin < 7.0'
	    return 1
	    endif
	  endif

	igo= match_l1( 3,s_move)
	if( igo .lt. 0) then
	  return 1
	else if( igo .ge. 2) then
	  do i=1,n_atom
	    if( lf(i) ) w(i)=999.0
	    end do
	else if( igo .eq. 1) then
	  n_groupa(1)=0
	  ksum=0
	  end if

	call read_ar(1, dmin0, *991,*992)
	goto 992
991	return 1

992	overlap=.false.
	do ii=1,n_group1
	  i=igroupa( ii,igr) 
	  if( lf(i)) then
	    overlap=.true.
	    write(6,'(a)') 
     1  ' sdistance-W> overlap! unitary symmetry operator is ignored.'
	    goto 3000
	    endif
	  enddo

3000	isymm=0
	call get_trn(isymm,trn,trn1,symm_txt)
	if(isymm.eq.0) return 

	do ii=1,3
	do jj=1,3
	  trn0(ii,jj)=trn1(ii,jj)
	  enddo
	  enddo
	call mxinv(3,trn0,i_err)
	if(i_err.ne.0) then
	  write(6,'(a)')
     1 ' sdistance-W> ERROR in inversing the orthogonal matrix'
	  return 1
	  endif

c	at this point,
c	trn: 	the first symmetry operator in the cartetian system
c	trn1:	fractional_coor -> orthoganal_coor
c	trn0:	orthoganal_coor -> fractional_coor 

	write(6,1009) 'sdistance', n_group2, cgroup(igr), n_group1

c	treat the on atoms
	xc=0.
	yc=0.
	zc=0.
	do i=1,n_atom
	  if( lf(i)) then	
	    xc=xc+x(i)
	    yc=yc+y(i)
	    zc=zc+z(i)
	  end if
	end do
	xc2=xc/n_group2
	yc2=yc/n_group2
	zc2=zc/n_group2

	rmax2=0.
	ii=0
	do i=1,n_atom
	  if( lf(i)) then
	    ii=ii+1
	    xc=x(i)-xc2
	    yc=y(i)-yc2
	    zc=z(i)-zc2
	    rc=sqrt(xc*xc+yc*yc+zc*zc)
	    rdi(ii)= -rc
 	    rdj(ii)= rc
	    isort(ii)= i
	    if( rc .gt. rmax2) rmax2=rc
	  end if
	end do

c	sort on atoms by radius, in decreasing order
	call sort_rl( n_group2,rdi,jsort)
	do ii= 1,n_group2
	  i= jsort(ii)
	  index2(ii)= isort(i) 
	  rdi(ii)= rdj(i)	! radiu of on atoms 
	end do

c	treat atoms in the given group 
	xc=0.
	yc=0.
	zc=0.
	do ii=1,n_group1
	  i=igroupa( ii,igr)
	  xc=xc+x(i)
	  yc=yc+y(i)
	  zc=zc+z(i)
	end do
	xc1=xc/n_group1
	yc1=yc/n_group1
	zc1=zc/n_group1

	rmax1=0.
	do ii=1,n_group1
	  i=igroupa( ii,igr)
	  xc=x(i)-xc1
	  yc=y(i)-yc1
	  zc=z(i)-zc1
	  rc= sqrt( xc*xc+yc*yc+zc*zc)
	  rdj(ii)= -rc
	  if(rc.gt.rmax1) rmax1=rc
	end do

c	sort group atoms by radius
	call sort_rl( n_group1, rdj, isort)
	do ii=1,n_group1
	  i=igroupa(  isort(ii), igr)
	  index1(ii)=i
	  xc=x(i)-xc1
	  yc=y(i)-yc1
	  zc=z(i)-zc1
	  rdj(ii)= sqrt( xc*xc+yc*yc+zc*zc)
	  enddo

c	fx1 is the fractional coordinate of the given group (integerlized);
c	fx2 is the fractional coordinate of the ON atoms    (integerlized).

	fx1(1)= nint(trn0(1,1)*xc1+ trn0(1,2)*yc1+ trn0(1,3)*zc1)
	fx1(2)= nint(trn0(2,1)*xc1+ trn0(2,2)*yc1+ trn0(2,3)*zc1)
	fx1(3)= nint(trn0(3,1)*xc1+ trn0(3,2)*yc1+ trn0(3,3)*zc1)
	fx2(1)= nint(trn0(1,1)*xc2+ trn0(1,2)*yc2+ trn0(1,3)*zc2)
	fx2(2)= nint(trn0(2,1)*xc2+ trn0(2,2)*yc2+ trn0(2,3)*zc2)
	fx2(3)= nint(trn0(3,1)*xc2+ trn0(3,2)*yc2+ trn0(3,3)*zc2)

	r1=rmax1+dmin	
	r2=rmax2+dmin		
	rr=rmax1+rmax2+dmin

5003	if (abs(trn(1,1)-1.).lt.1.e-6.and.
     1   abs(trn(2,2)-1.).lt.1.e-6.and.
     1   abs(trn(3,3)-1.).lt.1.e-6) then
	  unit=.true.
	else
	  unit=.false.
	  end if

c	make matrix sym0, which is the original symmetry matrix
c	[sym0] = [trn0] [trn] [trn1]
 
	call axbeqc(trn0,trn,tmpa)
	call axbeqc(tmpa,trn1,sym0)

	do ii=1,3
	  ts0(ii)=trn0(ii,1)*trn(1,4)
     1        +trn0(ii,2)*trn(2,4)
     1        +trn0(ii,3)*trn(3,4)

	  if(ts0(ii).ge.0.0) then
	    ts(ii)=mod(ts0(ii),1.)
	  else	
	    ts(ii)=-mod(-ts0(ii),1.)
	    endif

c	The following translation vector, 'its' will bring the the center
c	of mass of the ON atoms into the xtal cell where the center of mass
c	of the given group is.

	  its(ii)=nint(ts0(ii)-ts(ii))+fx1(ii)
     1 -(sym0(ii,1)*fx2(1)+ sym0(ii,2)*fx2(2)+ sym0(ii,3)*fx2(3))

c 	'ts0', the translation components of the symmetry operator 
c	  should be between  -1 and 1.

	  ts0(ii)=ts(ii)
	  enddo  

  	do ii=1,3
	do jj=1,3
	  sym(ii,jj)=trn(ii,jj)
	  end do
	  ts(ii)=trn1(ii,1)*ts0(1)
     1       +trn1(ii,2)*ts0(2)
     1       +trn1(ii,3)*ts0(3)
	  end do

	do 5030 jx=-1+its(1),1+its(1)
	do 5030 jy=-1+its(2),1+its(2)
	do 5030 jz=-1+its(3),1+its(3)

	  sym(1,4)=ts(1) +trn1(1,1)*jx+trn1(1,2)*jy+trn1(1,3)*jz
	  sym(2,4)=ts(2) +trn1(2,1)*jx+trn1(2,2)*jy+trn1(2,3)*jz
	  sym(3,4)=ts(3) +trn1(3,1)*jx+trn1(3,2)*jy+trn1(3,3)*jz
	  if(abs(sym(1,4)).lt.1.e-6.and.
     1    abs(sym(2,4)).lt.1.e-6.and.
     1    abs(sym(3,4)).lt.1.e-6.and.
     1    unit .and. overlap) goto 5030

	  xc= sym(1,1)*xc2+ sym(1,2)*yc2+ sym(1,3)*zc2+ sym(1,4)
	  yc= sym(2,1)*xc2+ sym(2,2)*yc2+ sym(2,3)*zc2+ sym(2,4)
	  zc= sym(3,1)*xc2+ sym(3,2)*yc2+ sym(3,3)*zc2+ sym(3,4)

	  call get_dist(xc,yc,zc,xc1,yc1,zc1, rr,rc,*5030)
	  wsymm=.true.

	rcc= rc - r2 
	itt=0

	do 5005 ii=1,n_group1
	  i=index1(ii)
	  if(rdj(ii).le.rcc) goto 5006
	  xp=x(i)
	  yp=y(i)
	  zp=z(i)
	  call get_dist(xc,yc,zc,xp,yp,zp,r2,rac,*5005)
	  itt=itt+1
	  isort(itt)= i
5005	  continue

5006	if(itt.le.0) goto 5030
	rcc=rcc+r2-r1

	do jj=1,n_group2
	  if(rdi(jj).le.rcc) goto 5021
	  end do

5021	jtt=jj-1
	if(jtt .gt. 0) call sort_in2( jtt, index2, jsort)
	do 5020 jj=1,jtt
	  j= index2(jsort(jj))
	  xp=x(j)
	  yp=y(j)
	  zp=z(j)
	  xc= sym(1,1)*xp+ sym(1,2)*yp+ sym(1,3)*zp+ sym(1,4)
	  yc= sym(2,1)*xp+ sym(2,2)*yp+ sym(2,3)*zp+ sym(2,4)
	  zc= sym(3,1)*xp+ sym(3,2)*yp+ sym(3,3)*zp+ sym(3,4)
	  call get_dist(xc,yc,zc,xc1,yc1,zc1,r1,rac,*5020)
	  storea= .true.
	  storeb= igo.ge.3

	  do 5010 ii=1,itt
	    i=isort(ii)
	    xp=x(i)
	    yp=y(i)
	    zp=z(i)
	    call get_dist(xc,yc,zc,xp,yp,zp,dmin,raa,*5010)
	    if(raa.lt.dmin0) goto 5010				!(930612)
            if(wsymm) then
	      if(verbose.le.0) 
     1     write(6,1030)   isymm,symm_txt, jx,jy,jz, rc
	      write(io,1030)   isymm,symm_txt, jx,jy,jz, rc
 	      if(verbose.ge.3) then
	        write(io,1230) isymm,jx,jy,jz
	        write(6 ,1032) isymm,symm_txt, jx,jy,jz, rc
	      endif

1030	format(/' sdistance> symmetry #'
     1,i2,': ',a,' plus [',i3,',',i3,',',i3,']'
     1/' is used onto ON atoms. Dist. between the mass centres ='
     1,f8.3)
1032	format(' sdistance-I3> symmetry #'
     1,i2,': ',a,' plus [',i3,',',i3,',',i3,']'
     1/' is used onto ON atoms. Dist. between the mass centres ='
     1,f8.3)
1230	format(' sdistance-I3> To apply the transformation, type:'
     1 /'   rtn symmetry',4i4)

	      wsymm=.false.
	      endif
	    write(io,1001) text(j)(14:27),text(i)(14:27), raa
	    if( igo .eq. 1) then
	      ksum=ksum+1
              if(ksum.gt.max_atom) then
	        if(verbose.ge.7 ) write(6,*)
     1 ' sdistance-I7> num_atom=',ksum,', max_atom=',max_atom
		write(6,'(a)') 
     1 ' sdistance-W> load is deactivated; too many contacts.'
		igo= 0
		n_groupa(1)=0
	      end if
	      igroupa( ksum,1)= i
	    else if( igo .ge. 2) then
chk	      write out everything in contact				!930517
	      if(storeb.and.pdb_out.ne.' ') 				!940308
     1       write(4,1065) text(j)(1:30),xc,yc,zc,1.,b(j)		!930517
!1065	      format('ATOM   ',A23,3f8.3,2F6.2)				!930517 
1065	      format(A30,3f8.3,2F6.2)				!930517 
	      storeb=.false.
	      if( raa .lt. w(j)) then
		w(j)= raa
	        if(storea) then
	          storea=.false.
c	          if(.not. (lf(i).and.i.lt.j))
	  write(text(j)(31:54),1064) xc, yc, zc	
1064              format(3f8.3)
	          endif
	        endif
              endif
5010	    continue	! loop of grouped atoms

5020	  continue	! loop of ON atoms

5030	continue	! loop of crystallographic translations
	jsymm=isymm
	call get_trn(isymm,trn,trn1,symm_txt)
	if(isymm.gt.jsymm) goto 5003		! loop of symmetry operaters

	if(storea) n_groupa(1)=ksum
	call typelist(io)
	end

	subroutine find_a_group(igr)
chk	=======================
chk	input:group_name 	output:igr
chk	group name		0 - max_gr
chk	blank			999
chk	too many groups		-1
 
	include 'edp_main.inc'
! 	use edp_main
	character*(max_num_chars) txt
	common /cmm_txt/ n_len,txt,ib,ie

	igr= match_l( max_gr, cgroup)
	if( igr .eq. 0 ) igr=999		! no group name found
 
	if(igr.lt.0) then
	  if(ie-ib+1 .gt. 4) then
	    igr=-1
	    errmsg=
     1 ' errmsg: the maximum length of a group name is 4 characters.'
	    return
	    endif
	  do igr=3,max_gr
	    if(n_groupa(igr).le.0) then
	      cgroup(igr)=txt(ib:ie)
	      return
	      endif
	    enddo
	  errmsg=' errmsg: too many groups have been defined!'
	  igr=-1
	  endif
	end

copyright by X. Cai Zhang

	subroutine list_clique(n,id)
chk	======================
chk	called by mcs_clique()
	include 'edp_dim.inc'
!	use edp_dim
	include 'edp_dat.inc'
!	use edp_dat
	include 'edp_file.inc'
!	use edp_file

	integer n, id(n)
   
	character*(16) ssl(max_lv,2)
	real vc(7,max_lv,2)
	logical order
	character*4 mark
	common /cmm_match3d/ kv1, kv2, vc, cutoff(2)
     1 ,order, mark, ssl
     1 ,rms0, rms1, nv(0:1)	
	integer name_save(max_l,0:1)
	character*(80) best_save(0:1)

	logical  t(max_l,max_l)
	common /cmm_mcs/ is_angle, num_total, t, icode(2,max_l)

	parameter (max_lv2= max_lv*2)
!	integer, parameter :: max_lv2= max_lv*2
	real s(3,max_lv2), p(3,max_lv2), wt(max_lv2)
	real trn(3,4), a_polar(3)
	integer isort(max_lv), jsort(max_lv)
!	save name_save, best_save
	save	!030422

	num_p=0
	do i=1,n
	  ii=icode(1,id(i))
	  jj=icode(2,id(i))
	  num_p=num_p+1
	  s(1,num_p)=vc(1,ii,1)
	  s(2,num_p)=vc(2,ii,1)
	  s(3,num_p)=vc(3,ii,1)

	  p(1,num_p)=vc(1,jj,2)
	  p(2,num_p)=vc(2,jj,2)
	  p(3,num_p)=vc(3,jj,2)
	  wt(num_p)= 1.0

	  num_p=num_p+1
	  s(1,num_p)=vc(4,ii,1)
	  s(2,num_p)=vc(5,ii,1)
	  s(3,num_p)=vc(6,ii,1)

	  p(1,num_p)=vc(4,jj,2)
	  p(2,num_p)=vc(5,jj,2)
	  p(3,num_p)=vc(6,jj,2)

	  wt(num_p)= 1.0
	  enddo

	call edp_rms_doit(rms, num_p, s,p, wt, trn, 0
     1 ,.false., .true.)

	if(rms.gt.0.0.and.rms.lt.cutoff(2)) then
c	  if(best) then
	    new=0
	    if( rms.lt.rms0) then
	      new=1
	      rms0=rms
	      nv(0)=n
	      call get_polar(trn,a_polar)
	      write(best_save(0),1001) 
     1  nint(a_polar(1)), nint(a_polar(2)), nint(a_polar(3)),
     1  nint(trn(1,4)), nint(trn(2,4)), nint(trn(3,4)),	
     1  n,rms
	        
	      if(lverbose.ge.4 ) then		!list best cliques
	        do i=1,n
	          isort(i)=icode(1,id(i))
	          enddo
	        call sort_in2(n,isort,jsort)
	        do j=1,n
	          name_save(j,0)=id(jsort(j))
	          enddo
	        endif	!lverbose>=4

	      if(nv(1).le.0) then
	        rms1=rms0
	        nv(1)=nv(0)
	        best_save(1)=best_save(0)
	        rewind(29)
	        write(29,1018) ((trn(i,j),j=1,3),i=1,3),(trn(i,4),i=1,3)
	  if(lverbose.ge.3) write(6,1230) rtn_out(:ltrim(rtn_out))
1230	format(' clique-I3> To apply the transformation, type:'
     1 /'   rtn file ',a)		
1018	format(3(3f12.7/),3f12.5)
	        if(lverbose.ge.4 ) then
	          do j=1,n
	            name_save(j,1)=name_save(j,0)
	            enddo
	          endif	!lverbose>=4
	        endif	!copy solution 0 to solution 1
	      endif	!new solution 0

	    if( (rms.lt.rms1.and.n.eq.nv(1)) .or. n.gt.nv(1)) then
	      new=1
	      rms1=rms
	      nv(1)=n
	      call get_polar(trn,a_polar)
	      write(best_save(1),1001) 
     1  nint(a_polar(1)), nint(a_polar(2)), nint(a_polar(3)),
     1  nint(trn(1,4)), nint(trn(2,4)), nint(trn(3,4)),	
     1  n,rms
	      rewind(29)
	      write(29,1018) ((trn(i,j),j=1,3),i=1,3),(trn(i,4),i=1,3)
	      if(lverbose.ge.3) write(6,1230) rtn_out(:ltrim(rtn_out))
	      
	      if(lverbose.ge.4 ) then		! list best cliques
	        do i=1,n
	          isort(i)=icode(1,id(i))
	          enddo
	        call sort_in2(n,isort,jsort)
	        do j=1,n
	          name_save(j,1)=id(jsort(j))
	          enddo
	        endif	!lverbose>=4
	      endif	!new solution 1
c	    return
c	    endif	!list only best

	  if(lverbose.ge.5 .and.new.eq.0) then
	    call get_polar(trn,a_polar)
	    write(48,1001) 
     1  nint(a_polar(1)), nint(a_polar(2)), nint(a_polar(3)),
     1  nint(trn(1,4)), nint(trn(2,4)), nint(trn(3,4)),	
     1  n,rms
1001	format(' rtn polar ',6i5,' ! ',i3,' vectors w/ rms=',g12.4)
	    if(lverbose.ge.6 ) then
	      do i=1,n
	        isort(i)=icode(1,id(i))
	        enddo
	      call sort_in2(n,isort,jsort)
	      do j=1,n
	        i=id(jsort(j))
	        write(48,1002) mark,ssl(icode(1,i),1),ssl(icode(2,i),2)
     1       ,vc(7,icode(1,i),1)
1002	format(1x,a,t10,a,'   ',a,' ; w_type: ',f6.2)
	        enddo
	      endif	!lverbose>=6
	    endif	!lverbose>=5
	  endif		!potential match ( 0<rms<rms_min)

	return

	entry list_best_clique()
chk	======================
	if(nv(0).le.0) then
	  write(6,1012) 
1012	format(' match3d> no match is found.')
	  return
	  endif
	if(lverbose.le.2 ) return		! quiet

	if(best_save(0).ne.best_save(1)) then
	  k1=1
	else
	  k1=0
	  endif
	do k=0,k1
	  write(48,1003) best_save(k)
	  if(lverbose.ge.4 ) then		! list best cliques
	    do j=1,nv(k)
	      i=name_save(j,k)
	      write(48,1002) mark,ssl(icode(1,i),1),ssl(icode(2,i),2)
     1       ,vc(7,icode(1,i),1)
	      enddo
	    endif
	  enddo
1003	format(a80)
	end

	subroutine mcs_clique(*)
chk	=====================
chk	return 1: error

	include 'edp_main.inc'
!	use edp_main
	include 'edp_dat.inc'
!	use edp_dat

	character*(16) ssl(max_lv,2)
	real vc(7,max_lv,2)
	logical order
	character*4 mark
	common /cmm_match3d/ kv1, kv2, vc, cutoff(2)
     1 ,order,mark, ssl
     1 ,rms0, rms1, nv(0:1)

	logical  t(max_l,max_l)
	common /cmm_mcs/ is_angle, num_total, t, icode(2,max_l)

	integer d, name_d(max_l), num_c(max_l), name_c(max_l,max_l)

	n_of_syn=2					!000515
	syntax(1)='syntax:' 
	syntax(2)=
     1'clique group_id.s c_min.i rms_cutoff.r eps.r max_cliques.i' 

	rms0=999.99
	rms1=999.99
	nv(0)=0
	nv(1)=0
	min_clique=nint(cutoff(1))
	if(lverbose.ge.4 ) write(6,1001) min_clique,cutoff(2),order	
1001	format(' mcs_clique-I4> min_clique=',i3,', cutoff=',f8.1,
     1 ', sequential:',L1)
	if(min_clique.lt.2) then
	  errmsg=' errmsg: min_clique too small'
	  return 1
	  endif

	if(lverbose.ge.2 ) write(6,1004) num_total,num_total
1004	format(' mcs_clique-I2> The MCS matrix has a dimension of ',
     1 i6,' x ',i6,'.')

chk	initialize:
	d=1
	do i=1,num_total
	  name_c(i,d)=i
	  enddo
	num_c(d)=num_total

chk	find the node of the maximum # of connections
200	num_ce=num_c(d)
	m1=0
	do i=1,num_ce
	  m0=0
	  do j= 1,num_ce
	    if(t(name_c(j,d),name_c(i,d))) m0=m0+1
	    enddo
	  if(m0.gt.m1) then
	    m1=m0
	    i1=i
	    endif
	  enddo
	if(m1.lt.min_clique-d ) goto 600

chk	goto d+1 level
400	name_c_i=name_c(i1,d)
	name_d(d)=name_c_i
	num_ce=num_c(d)
	m1=0
	do i= 1,num_ce
	  ii=abs(name_c(i,d))
	  if(t(name_c_i,ii)) then
	    if(ii.ne.name_c_i) then
	      m1=m1+1
	      name_c(m1,d+1)=ii
	      endif
	    name_c(i,d)=-ii
	    endif
	  enddo
	d=d+1
	num_c(d)=m1
	if(m1.gt.0) goto 200

chk	Great! found a clique
	if(d-1.ge.min_clique) call list_clique(d-1,name_d)

chk	Come back to d-1 level
600	d=d-1
	if(d.le.0) return		! finished
	num_ce=num_c(d)
	do i=1,num_ce
	  if(name_c(i,d).gt.0) then
	    i1=i
	    goto 400
	    endif
	   enddo
	goto 600
	end


	function fxf(ic,jc)
chk	============
	include 'edp_dim.inc'
!	use edp_dim

	character*(16) ssl(max_lv,2)
	real vc(7,max_lv,2)
	logical order
	character*4 mark
	common /cmm_match3d/ kv1, kv2, vc, cutoff(2)
     1 ,order,mark, ssl
     1 ,rms0, rms1, nv(0:1)	

	logical t(max_l,max_l)
	common /cmm_mcs/ is_angle, num_total, t, icode(2,max_l)

	real s(3,4), p(3,4), w(4), junk(12)

	i1=icode(1,ic)	! mol_a, frag. 1
	i2=icode(2,ic)	! mol_a, frag. 2 
	j1=icode(1,jc)	! mol_b, frag. 1
	j2=icode(2,jc)	! mol_b, frag. 2

	do j=1,3
	  s(j,1)=vc(j  ,i1,1)
	  s(j,2)=vc(j+3,i1,1) 
	  s(j,3)=vc(j  ,j1,1)
	  s(j,4)=vc(j+3,j1,1) 

	  p(j,1)=vc(j  ,i2,2)
	  p(j,2)=vc(j+3,i2,2) 
	  p(j,3)=vc(j  ,j2,2)
	  p(j,4)=vc(j+3,j2,2) 
	  enddo

1001	format(3e12.4)

	do i=1,4
	  w(i)= 1.0
	  enddo

	rms=-1.0
	call edp_rms_doit(rms,4,s,p,w, junk,0, .true.,.false.)
	fxf=rms
	end

	subroutine match_vectors(*)
chk	========================
	include 'edp_main.inc'
!	use edp_main
	include 'edp_dat.inc'
!	use edp_dat

	character*(16) ssl(max_lv,2)
	real vc(7,max_lv,2)
	logical order
	character*4 mark
	common /cmm_match3d/ kv1, kv2, vc, cutoff(2)
     1 ,order,mark, ssl
     1 ,rms0, rms1, nv(0:1)

	logical mtx(max_l,max_l)
	common /cmm_mcs/ is_angle, num_total, mtx, icode(2,max_l)

	num_total=0
	do i=1,kv1
	do j=1,kv2
	  if(vc(7,i,1).eq.vc(7,j,2)) then
	    num_total=num_total+1
	    if(num_total.gt.max_l) then
	if(verbose.ge.9 ) 
     1  write(6,*) 'match_vec-I9> num_l=',num_total,', max_l=',max_l
	      errmsg=' errmsg: too many vectors to match. increase max_l'
	      return 1
	      endif
	    icode(1,num_total)=i
	    icode(2,num_total)=j
	    endif
	  enddo
	  enddo

	do i=   1,num_total
	  mtx(i,i) =.true.
	  do j= i+1,num_total
	    if(icode(1,i).eq.icode(1,j) .or.      ! mol_a
     1      icode(2,i).eq.icode(2,j) ) then    ! mol_b
	      mtx(i,j)=.false.
	      mtx(j,i)=.false.
	    else if( order .and.
     1   (icode(1,i)-icode(1,j))*(icode(2,i)-icode(2,j)).le.0) then
	      mtx(i,j)=.false.
	      mtx(j,i)=.false.
	    else
	      rms=fxf(i,j)
	      if(rms.ge.0.0 .and. rms .le.cutoff(2)) then
	        mtx(i,j) =.true.
	        mtx(j,i) =.true.
	      else
	        mtx(i,j) =.false.
	        mtx(j,i) =.false.
	        endif
	      endif
	    enddo
	  enddo
	call mcs_clique(*900)
	close (29)
	call list_best_clique()
c	if(lverbose) call list_best_clique()
	call typelist(48)
	return 
900	errmsg=' errmsg: error in mcs_clique'
 	return 1
	end

	subroutine match3d(*)
chk	==================
chk     Reference:
chk     Algorithm 457, finding all cliques of an undirected graph. Bron, C
chk     & Kerbosch J (1973). Commum. A.C.M 16, 575-577.
 
	include 'edp_main.inc'
!	use edp_main
	include 'edp_dat.inc'
!	use edp_dat
	include 'edp_file.inc'
!	use edp_file

	parameter (max_xt=100)
!	integer, parameter :: max_xt=100
	real xt(4,max_xt), vc(7,max_lv,2)
	character*(16) ssl(max_lv,2)
	logical order
	character*4 mark
	common /cmm_match3d/ kv1, kv2, vc, cutoff(2)
     1 ,order,mark, ssl
     1 ,rms0, rms1, nv(0:1)	

	character*(max_num_chars) txt
	common /cmm_txt/ n_len,txt,ib,ie
	logical nword	!, nword0

	character*8 sequential
	data sequential/'nonsequ'/

	logical  open_file1
	external open_file1

	n_of_syn=2					!000515
	syntax(1)='syntax:' 
	syntax(2)=
     1 'match3d group_id.s c_min.i max_rms.r filename.s [nonsequ]' 

	igr= match_l( max_gr, cgroup)
	if( igr .le. 0) then
	  errmsg=' errmsg: a group name is needed'
	  return 1
	  end if
	ngr= n_groupa(igr)
	if( ngr.le.0) then
	  write(6,'(a)') 
     1 ' match-W> UNDONE: group ['//cgroup(igr)//'] is empty.'
	  return
	  end if

	call read_ar(2,cutoff,*900,*900)
	if(cutoff(1).le.2.0) return 1
	if(cutoff(2).le.0.0) return 1

	rtn_out='rtn_.txt'
	if(.not. open_file1(29, rtn_out, 'unknown','.txt')) return 1

	if(nword(n_len,txt,ib,ie)) then
	  order=.true.
	else if(ib.gt.ie) then
	  order=.true.
	else if(txt(ib:ie).eq.sequential(1:ie-ib+1)) then
	  order=.false.
	else
	  return 1
	  endif

c	if(.not. nword(n_len,txt,ib,ie)) then
c	  mark=txt(ib:ie)
c	else
	  mark='M3D>'
c	  endif

	lverbose=verbose
	verbose=1

	wc=-999.99
	kv=0
	n=0
	do i=1,n_atom
	  if(lf(i)) then
	    if(w(i).eq.wc) then ! accumulation
	      n=n+1
	      if(n.gt.max_xt) then
	if(lverbose.ge.9 ) write(6,*) 
     1 'match3d-I9> num_xt=',n,', max_xt=',max_xt
	        errmsg=
     1' errmsg: too many atoms in one vector. increase max_xt.'
	        goto 900
	        endif
	      xt(1,n)=x(i)
	      xt(2,n)=y(i)
	      xt(3,n)=z(i)
	      xt(4,n)=w(i)
	      i1=aa_seq(i)
	    else if(w(i).gt.0.0) then ! start a new vector
	      if(kv.gt.0) then
	        call find_the_long_axis1(n,xt,vc(1,kv,1),*900)
	        vc(7,kv,1)=xt(4,1)
	        ssl(kv,1)=ires(i0)//' - '//ires(i1)
	        endif
	      n=1
	      xt(1,n)=x(i)
	      xt(2,n)=y(i)
	      xt(3,n)=z(i)
	      xt(4,n)=w(i)
	      i0=aa_seq(i)
	      kv=kv+1
	      if(kv.gt.max_lv) then
	if(lverbose.ge.9 ) write(6,*) 
     1 'match3d-I9> num_lv=',kv,', max_lv=',max_lv
	        errmsg=
     1 ' errmsg: too many vectors in the ON buffer'
	        goto 900
	        endif
	      wc=w(i)
	    else
	      wc=-999.99
	      endif
	    endif
	  enddo
	if(kv.gt.0) then
	  call find_the_long_axis1(n,xt,vc(1,kv,1),*100)
	  vc(7,kv,1)=xt(4,1)
	  ssl(kv,1)=ires(i0)//' - '//ires(i1)
	  endif
100	kv1=kv

	wc=-999.99
	kv=0
	n=0
	do j=1,ngr
          i=igroupa(j,igr)
	    if(w(i).eq.wc) then
	      n=n+1
	    if(n.gt.max_xt) then
	if(lverbose.ge.9 ) write(6,*) 
     1 'match3d-I9> num_xt=',n,', max_xt=',max_xt
	        errmsg=
     1' errmsg: too many atoms in one vector. increase max_xt.'
	        goto 900
	        endif
	      xt(1,n)=x(i)
	      xt(2,n)=y(i)
	      xt(3,n)=z(i)
	      xt(4,n)=w(i)
	      i1=aa_seq(i)
	    else if(w(i).gt.0.0) then
	      if(kv.gt.0) then
	        call find_the_long_axis1(n,xt,vc(1,kv,2),*900)
	        vc(7,kv,2)=xt(4,1)
	        ssl(kv,2)=ires(i0)//' - '//ires(i1)
	        endif
	      n=1
	      xt(1,n)=x(i)
	      xt(2,n)=y(i)
	      xt(3,n)=z(i)
	      xt(4,n)=w(i)
	      i0=aa_seq(i)
	      kv=kv+1
	      if(kv.gt.max_lv) then
	if(lverbose.ge.9 ) write(6,*) 
     1 'match3d-I9> num_lv=',kv,', max_lv=',max_lv
	        errmsg=
     1' errmsg: too many vectors in group ['//cgroup(igr)//']'
	        goto 900
	        endif
	      wc=w(i)
	    else
	      wc=-999.99
	      endif
	  enddo
	if(kv.gt.0) then
	  call find_the_long_axis1(n,xt,vc(1,kv,2),*200)
	  vc(7,kv,2)=xt(4,1)
	  ssl(kv,2)=ires(i0)//' - '//ires(i1)
	  endif
200	kv2=kv

	write(6,1001) kv1, cgroup(igr), kv2
1001	format(' match3d> ON buffer contains',i3,' vectors,'
     1,' group ',a,' contains',i3,' vectors.')
	call match_vectors(*900)
	verbose=lverbose
	return
900	verbose=lverbose
	return 1
	end

	subroutine edp_match(*)
chk	=====================
	include 'edp_main.inc'
	include 'edp_dat.inc'
! 	use edp_main

	character*(max_num_chars) txt
	common /cmm_txt/ n_len,txt,ib,ie
	logical nword 

	character*(72) txt1, txt2
	character*1 txt1c(72), txt2c(72)
	equivalence (txt1,txt1c(1)), (txt2,txt2c(1))
	character*64 fmtst

	n_of_syn=4					!000515
	syntax(1)='syntax:'
	syntax(2)=
     1'load group2.s | match group1.s sub_group1.s [fmtstmt.s]'
	syntax(3)='notes:'
	syntax(4)=
     1'A correct format should be '//
     1'(<n1>x,<n2>a,<n3>x,<n4>a,...). Default is (13x,4a).'

	call dfgroup(igr0,*901)
	n_group0=n_groupa(igr0)

	igr1= match_l( max_gr, cgroup)
	if( igr1 .le. 0) then
	  errmsg=' errmsg: a group name is needed'
	  return 1
	  end if
	n_group1= n_groupa(igr1)
	if( n_group1.le.0) then
	  write(6,*) 
     1'match-W> UNDONE: define group ['//cgroup(igr1)//'] first.'
	  return
	  end if

	call find_a_group(igr2)
	if( igr2 .le. 0) return 1

	if(.not.nword(n_len,txt,ib,ie)) then
	  fmtst=txt(ib:n_len)
	else
	  fmtst='(13x,4a1)'
	endif
	if(verbose.ge.4) write(6,1001) fmtst(:ltrim(fmtst))
1001	format(' match-I4> fmtstmt = ',a) 

	txt1=
     1'{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{'//
     1'{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{'//
     1'{{{{{{{{{{{{'
	read(text(1),fmtst,end=301,err=902) txt1c
301	len1=index(txt1,'{')-1
	if(len1.gt.72.or.len1.lt.1) goto 902
	if(verbose.ge.4) then
	  write(6,1003) text(1)
	  write(6,fmtst)('^',n1=1,len1)
1003	  format(a)
	endif
	j1=0
	i1=0
	n_g=0

100	j0=j1+1
	do j= j0, n_group1
	  js=aa_seq(igroupa(j,igr1))
	  if(j.eq.j0) jr0= js
	  if( jr0 .ne. js) goto 200
	  enddo
200	j1=j-1
	if(j0.gt.j1) goto 603

	i0=i1+1
	do i= i0, n_group0
	  is=aa_seq(igroupa(i,igr0))
	  if(i.eq.i0) ir0= is
	  if( ir0.ne. is) goto 300
	  enddo
300	i1=i-1
	if(i0.gt.i1) goto 603

	do jj=j0,j1
	  j=igroupa( jj,igr1)
	  read(text(j),fmtst,err=902) (txt1c(n1),n1=1,len1)
	  i00=i0
	  do ii=i00,i1
	    i=igroupa( ii,igr0)
	    read(text(i),fmtst,err=902) (txt2c(n1), n1=1,len1)
	    if(txt1(1:len1).eq.txt2(1:len1)) then
	      i0=i0+1
	      n_g=n_g+1
	      igroupa(n_g,igr2)=j
	      lf(i)=incl
	      goto 400
	      endif
	    enddo
400	  enddo	
	goto 100

603	n_groupa(igr2)= n_g
	write(6,1009) cgroup(igr1),n_group1, cgroup(igr2), n_g
1009	format(' match> #of atoms in group ',a,' =',i5,
     1 ', #of atoms in group ',a,' (matched)=',i5)
	return

901	errmsg=' errmsg: wrong group/zone information'
	return 1
902	errmsg=' errmsg: incorrect fortran reading statement'
	return 1	
	end

	subroutine find_the_long_axis1(n,xt,vc,*)
chk	==============================
	implicit real* 8 (a-h)
	include 'edp_dat.inc'
!	use edp_dat

!	implicit real* 8 (a-h)

	parameter (max_xt=100)
!	integer, parameter :: max_xt=100
	real xt(4,max_xt), pc(3), v(3,3), vc(6), xc(3)
	dimension a(3,3), e(3)

	if(n.le.1) return 1
	if(n.eq.2) then
	  do j=1,3
	    vc(j)  =xt(j,1)
	    vc(j+3)=xt(j,n)
	    enddo
	  return
	  endif

	do i=1,3
	do j=1,3
	  a(j,i)=0.
	  enddo
	  pc(i)=0.
	  enddo


	sum_w=0.0
	do i=1,n
	  wi=xt(4,i)
	  sum_w=sum_w+wi
	  do j=1,3
	    pc(j)=pc(j) + xt(j,i)*wi
	    enddo
	  enddo
	if(sum_w.le.0.) then
	  write(6,'(a)') 
     1 ' find_the_long_axis1-W> UNDONE: mwt.le.0.'
	  return 1
	  endif

	do j=1,3
	  pc(j)= pc(j)/sum_w
	  enddo

chk	this loop takes time to run
	do i=1,n
	  do j=1,3
	    xc(j)=xt(j,i)-pc(j)
	    enddo
	  wi=xt(4,i)
	  do j=1,3
	  do k=1,3
	    a(k,j)=a(k,j) - xc(k)*xc(j)*wi
	    enddo
	    enddo
	  enddo

	a3=a(1,1)+a(2,2)+a(3,3)
	do j=1,3
	  a(j,j)=a(j,j)-a3
	  xc(j)=xt(j,n)-xt(j,1)
	  enddo

	call eigen(a,e,v,.true.,*900)
	
	if(xc(1)*v(3,1)+ xc(2)*v(3,2)+ xc(3)*v(3,3) .lt.0.) then
c	  v(2,1)=-v(2,1)
c	  v(2,2)=-v(2,2)
c	  v(2,3)=-v(2,3)
	  v(3,1)=-v(3,1)
	  v(3,2)=-v(3,2)
	  v(3,3)=-v(3,3)
	  endif

	s1=sqrt(e(1)/sum_w)
	s2=sqrt(e(2)/sum_w)
	s3=sqrt(e(3)/sum_w)
	wi=(s1+s2)*0.5  

	if(wi.gt.20.0 .and. lverbose.ge.6) 
     1  write(6,'(a)') 
     1 '%EdPDB-W6- vector length larger than 40.0 A'

	if(s3/wi .gt. 0.66 .and. lverbose.ge.6 ) 
     1  write(6,*) '%EdPDB-W6- r3/(r1+r2)=',s3/wi

	do i=1,3
	  vc(i  )=pc(i)-v(3,i)*wi
	  vc(i+3)=pc(i)+v(3,i)*wi
	  enddo
	return
900	return 1
	end

	subroutine find_the_long_axis2(n,xt,vc,*)
chk	=============================
	implicit real* 8 (a-h)

	parameter (max_xt=100)
!	integer, parameter :: max_xt=100
	real xt(4,max_xt), pc(3), v(3,3), vc(6), xc(3)
	dimension a(3,3), e(3)

	if(n.le.1) return 1
	if(n.eq.2) then
	  do j=1,3
	    vc(j)  =(xt(j,n)+xt(j,1))*0.5
	    vc(j+3)=(xt(j,n)-xt(j,1))
	    enddo
	  r=sqrt(vc(4)**2+vc(5)**2+vc(6)**2)
	  if(r.le.eps()) return 1
	  vc(4)=vc(4)/r
	  vc(5)=vc(5)/r
	  vc(6)=vc(6)/r
	  return
	  endif

	do i=1,3
	do j=1,3
	  a(j,i)=0.
	  enddo
	  pc(i)=0.
	  enddo


	sum_w=0.0
	do i=1,n
	  wi=xt(4,i)
	  sum_w=sum_w+wi
	  do j=1,3
	    pc(j)=pc(j) + xt(j,i)*wi
	    enddo
	  enddo
	if(sum_w.le.0.) then
	  write(6,'(a)') ' find_the_long_axis2-W> UNDONE:  mwt.le.0.'
	  return 1
	  endif

	do j=1,3
	  pc(j)= pc(j)/sum_w
	  enddo

chk	this loop takes time to run
	do i=1,n
	  do j=1,3
	    xc(j)=xt(j,i)-pc(j)
	    enddo
	  wi=xt(4,i)
	  do j=1,3
	  do k=1,3
	    a(k,j)=a(k,j) - xc(k)*xc(j)*wi
	    enddo
	    enddo
	  enddo

	a3=a(1,1)+a(2,2)+a(3,3)
	do j=1,3
	  a(j,j)=a(j,j)-a3
	  xc(j)=xt(j,n)-xt(j,1)
	  enddo

	call eigen(a,e,v,.true.,*900)
	
	if(xc(1)*v(3,1)+ xc(2)*v(3,2)+ xc(3)*v(3,3) .lt.0.) then
	  v(2,1)=-v(2,1)
	  v(2,2)=-v(2,2)
	  v(2,3)=-v(2,3)
	  v(3,1)=-v(3,1)
	  v(3,2)=-v(3,2)
	  v(3,3)=-v(3,3)
	  endif

	vc(1)=pc(1)
	vc(2)=pc(2)
	vc(3)=pc(3)
	vc(4)=v(3,1)
	vc(5)=v(3,2)
	vc(6)=v(3,3)
	return
900	return 1
	end
chk***	end of mcs_clique.for

copyright by X. Cai Zhang
