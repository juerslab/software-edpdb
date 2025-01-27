!
!  function threading is a clone of match1d.
!  threading('match1d') replaces the subroutine match1d
!
	integer function threading(switch0)
!       unit 79: penalty_table file,    format(3x,a1,f8.3)
!       	 score_table file,      format(3x,a1,<max_t>f4.1)

	include 'edp_main.inc'
!	use edp_main
	include 'edp_dat.inc'
!        use edp_dat

	PARAMETER 	(MAX_T=  max_rt) 
	parameter 	(max_n=  max_L)
	parameter 	(max_2n=max_n*2)
!      integer, PARAMETER :: MAX_T=  max_rt 
!      integer, parameter :: max_n=  max_L
!      integer, parameter :: max_2n=max_n*2

	integer ia0(max_n,2), ic0(max_n)
	common /cmm_1d/ num_aa(2), ad (max_n,2), ia0, ic0

	character*1 ss, pp
	common /cmm_tbl_1d/ kp, ss(max_t), sc(max_t,max_t) !&
     1  ,mp ,pp(max_t), dd(max_t)

        common /cmm_ctl_1d/ nr, iseed, pe, n_end, sl0, sl1, sl2, !&
     1	igr0, igr1,igr2, blk_file

	character*1 s1(max_n), si

!	logical nword 
!	character*(max_num_chars) txt
!	common /cmm_txt/ n_len,txt,ib,ie
!	external open_file

	logical open_file, blk_file
	integer get_thread_score_table
	character*(*)  switch0
	character*(16) switch

	switch=switch0
	threading=1
	
	call dfgroup(igr0,*901)
	n_group0=n_groupa(igr0)
	if(n_group0.gt.max_n) then
	  write(errmsg,'(a,i5,a)') !&
     1  ' errmsg: too many atoms to select.(max_n=',max_n,')'
	  return
	  endif

	igr1= match_l( max_gr, cgroup)
	if( igr1 .le. 0) then
	  errmsg=' errmsg: a group name is needed'
	  return 
	  end if
	n_group1= n_groupa(igr1)
	if( n_group1.le.0) then
	  write(6,*) switch(:ltrim(switch))//
     1'-W> UNDONE: define group ['//cgroup(igr1)//'] first.'
	  thread0=0
	  return
	else if(n_group1.gt.max_n) then
	  write(errmsg,'(a,i5,a)')  !&
     1' errmsg: too many atoms in group ['//cgroup(igr1)//
     1'] (max_n=',max_n,')'
	  return
	  end if

	call find_a_group(ng2)
	if( ng2 .le. 0) return
    	igr2=ng2

        NR=0
        ISEED=1
        PE=0.1
        SL0=1.5
        SL1=1.0
        SL2=0.5
        Scale1=0.5
        Scale2=0.5
        N_END=1000
        io=0

5005	call read_ar(1,sl0      ,*901,*5000)   !  default      1.5
	call read_ar(1,scale1      ,*901,*5000)   !               1.0
	call read_ar(1,scale2      ,*901,*5000)   !               0.5
	call read_ar(1,pe       ,*901,*5000)   !               0.1
	call read_ai(1,nr       ,*901,*5000)   !			   0
	call read_ai(1,iseed    ,*901,*5000)   !               1
	call read_ai(1,n_end    ,*901,*5000)   !               1000
        
5000	nr=max(0,min(99,nr))
        n_end=max(0,n_end)

	call   score_table_1d('score_seq.txt',*901)
	call penalty_table_1d('penalty_table.txt')

	ks=1
	call get_sequence(igr0,s1)

	num_aa(1)=n_group0
200	do i=1,num_aa(ks)
	  si=s1(i)
	  do j=1,kp
	    if(si.eq.ss(j))goto 220
	    enddo
	  errmsg='errmsg: a symbol unmatched with score_seq: ['//si//']'
	  return 
220	  ia0(i,ks)=j
	  do j=1,mp
	    if(si.eq.pp(j)) goto 240
	    enddo
	  errmsg='errmsg: a symbol unmatched with penalty_table: '//si//']'
	  return 
240	  ad(i,ks)=dd(j)
	  enddo
	if(ks.eq.1) then	
	  ks=2
	  call get_sequence(igr1,s1)
	  num_aa(2)=n_group1
	  goto 200
	  endif

	if(verbose .ge. 4 ) then
	  write(6,1016) !&
     1  switch(:ltrim(switch)), sl0, switch(:ltrim(switch)),sl1, !&
     1  switch(:ltrim(switch)), sl2, switch(:ltrim(switch)),pe,  !&
     1  switch(:ltrim(switch)), nr,  switch(:ltrim(switch)),iseed
	  write(6,1006)      switch(:ltrim(switch)),num_aa
	  endif
1016	format( !&
     1  ' ',a,'-I4> threshold for pair-selection=',f6.1 / 	!&
     1  ' ',a,'-I4> threshold for listing as (:)=',f6.1 / 	!&
     1  ' ',a,'-I4> threshold for listing as (.)=',f6.1 / 	!&
     1  ' ',a,'-I4>            extension penalty=',f6.1 / 	!&
     1  ' ',a,'-I4>           # of random trials=',I6 / 	!&
     1  ' ',a,'-I4>     seed for random trial(s)=',I6) 
1006	format( !&
     1  ' ',a,'-I4>     Length= ',i3, ',',i4) 

	if(num_aa(1).gt.3 .and. num_aa(2).gt.3) then
	  blk_file=.false.			!000413
	  if(verbose .ge. 6 ) then 
	    blk_file=open_file(7, 'seq_align.blk', 'unknown', '.blk')
	    if(blk_file) write(7,1031)
	    endif
	  if(switch(:ltrim(switch)) .ne. 'match1d') then
	    if(get_thread_score_table(scale1,scale2) .ge. 1) return
		endif
	  call thread_ab(switch)
	  endif
1031	format('>Seq-1'/'>Seq_2'/'*')
1032	format(2a1)
1033	format('*')
	call punch_thread_score_table
	threading=0
	return
901	continue
	end !function threading
 

	subroutine punch_thread_score_table()
 	include 'edp_dim.inc'
!	use edp_dim
 	include 'edp_dat.inc'
!	use edp_dat

	PARAMETER 	(MAX_T=  max_rt )
	parameter 	(max_n=  max_L)
	parameter 	(max_2n= max_n*2)
	parameter 	(max_thr=max_res/2)

!	integer, PARAMETER :: MAX_T=  max_rt 
!	integer, parameter :: max_n=  max_L
!	integer, parameter :: max_2n=max_n*2
!	integer, parameter :: max_thr=max_res/2
	common /cmm_thread/ nr, thread_sc(max_t,max_thr)
	end !subroutine punch_thread_score_table

!
! needleman_thread is a clone of needlemen_1d with the following 
! modification:
! the SC table is from threading algorithem 
! instead of a 20x20 sequence homology table

	subroutine needleman_thread(ratio,jtry)
 	include 'edp_dim.inc'
!	use edp_dim
 	include 'edp_dat.inc'
!	use edp_dat

	PARAMETER 	(MAX_T=  max_rt )
	parameter	(max_n=  max_L)
	parameter 	(max_2n=max_n*2)
	parameter	(max_thr=max_res/2)
!	integer, PARAMETER :: MAX_T=  max_rt 
!	integer, parameter :: max_n=  max_L
!	integer, parameter :: max_2n=max_n*2
!	integer, parameter :: max_thr=max_res/2
	common /cmm_thread/ nr, sc(max_t,max_thr)

	integer ia0(max_n) ,ib0(max_n) ,ic0(max_n)
	common /cmm_1d/ n1, n2, ad (max_n) ,bd(max_n) !&
     1  ,ia0 ,ib0 ,ic0 

	character*1 ss, pp
	common /cmm_tbl_1d/ kp, ss(max_t), sh_sc(max_t,max_t) !&
     1  ,mp ,pp(max_t), dd(max_t)

	common /cmm_ctl_1d/ num_random, iseed, pe, n_end0, sl0, sl1, sl2, !& 
     1	igr0, igr1,igr2, blk_file

	DIMENSION SM(max_n,max_n), TK_A(max_n)
	INTEGER*2 IC1(MAX_2N), IC2(MAX_2N)
	INTEGER*2 IGO(max_n,max_n),  KGO_A(max_n)

	if(verbose .ge. 6 ) write(6,1069) 	!000504
1069	format(' needleman-I6> reference:' !&
     1 /'  Needleman SB, Wunsch CD.' !&
     1 /'  A general method applicable to the search for similarities ' !&
     1 /'    in the amino acid sequence of two proteins.' !&
     1 /'  J Mol Biol. 1970 Mar;48(3):443-53.')

	n_end= min(n_end0,n1-1,n2-1)
	do i=1,max_2n
	  ic1(i)=max_t
	  ic2(i)=max_t
	  enddo

	IBJ=1
	DO I= 1, N1
	SM(I,1)= SC(ia0(I),IBJ)
	IGO(I,1)=0
	END DO

	IAI=ia0(1)
	DO J= 2, N2
	SM(1,J)= SC(IAI, j)
	IGO(1,J)=0
	END DO

	IAI=ia0(2)
	IBJ=2
	SM(2,2)=SM(1,1)+SC(IAI,IBJ)
	IGO(2,2)=0

	BDJ=BD(1)
	PEBDJ=PE*BDJ
	TL=-1024.
	DO I=3,N1
		JGO=0
		SMAX=SM(I-1,1)

		STMP=SM(I-2,1)+BDJ
		IF(SMAX.LT.STMP) THEN
		  SMAX=STMP
		  JGO=2-I
		END IF
		
		IF(SMAX.LT.TL) THEN
		  JGO=LGO
		  SMAX=TL
		  TL=TL+PEBDJ
		ELSE IF(TL.LT.STMP) THEN
		  TL=STMP+PEBDJ
		  LGO=2-I
		ELSE
		  TL=TL+PEBDJ
		END IF
	
		SM(I,2)=SMAX+SC(ia0(I),IBJ)
		IGO(I,2)=JGO
	END DO

	BDJ=AD(1)
	PEBDJ=PE*BDJ
	TL=-1024.
	DO I=3,N2
		JGO=0
		SMAX=SM(1,I-1)

		STMP=SM(1,I-2)+BDJ
		IF(SMAX.LT.STMP) THEN
		  SMAX=STMP
		  JGO= I-2
		END IF
		
		IF(SMAX.LT.TL) THEN
		  JGO=LGO
		  SMAX=TL
		  TL=TL+PEBDJ
		ELSE IF(TL.LT.STMP) THEN
		  TL=STMP+PEBDJ
		  LGO=I-2
		ELSE
		  TL=TL+PEBDJ
		END IF
	
!		SM(2,I)=SMAX+SC(IAI,ib0(I))
		SM(2,I)=SMAX+SC(IAI,i)
		IGO(2,I)=JGO
	END DO

	DO I=3,N1
		TK_A(I)=-1024.
	END DO
	DO J=3,N2
		J1=J-1
		J2=J-2
		J3=J-3
		BDJ=BD(J)
		PEBDJ=PE*BDJ
!		IBJ=ib0(J)
		IBJ=j
		
		TL=-1024.
		DO I=3,N1
			I1=I-1
			I2=I-2
			I3=I-3
			ADI=AD(I)
			PEADI=PE*ADI

			JGO=0
			SMAX=SM(I1, J1)

			STMP=SM(I2,J1)+BDJ
			IF(SMAX.LT.STMP) THEN
			  SMAX=STMP
			  JGO=-I2
			END IF
		
			IF(SMAX.LT.TL) THEN
			  JGO=LGO
			  SMAX=TL
			  TL=TL+PEBDJ
			ELSE IF(TL.LT.STMP) THEN
			  TL=STMP+PEBDJ
			  LGO=-I2
			ELSE
			  TL=TL+PEBDJ
			END IF

			STMP=SM(I1,J2)+ADI
			IF(SMAX.LT.STMP) THEN
			  SMAX=STMP
			  JGO=J2		! why not -j2
			END IF
		
			TK=TK_A(I)
			KGO=KGO_A(I)
			IF(SMAX.LT.TK) THEN
			  JGO=KGO
			  SMAX=TK
			  TK=TK+PEADI
			ELSE IF(TK.LT.STMP) THEN
			  TK=STMP+PEADI
			  KGO=J2		! why not -j2
			ELSE
			  TK=TK+PEADI
			END IF
			TK_A(I)=TK
			KGO_A(I)=KGO

			SM(I,J)=SMAX+SC(ia0(I),IBJ)
			IGO(I,J)=JGO
		END DO
	END DO

	SMAX=SM(N1,N2)
	IMAX=N1
	JMAX=N2
	I1=N1- n_end
	DO I=I1,N1
		IF(SMAX.LT.SM(I,N2)) THEN
			IMAX=I
			SMAX=SM(I,N2)
		END IF
	END DO

	J1=N2- n_end
 	DO J= J1, N2
		IF(SMAX.LT.SM(N1,J)) THEN
			JMAX=J
			SMAX=SM(N1,J)
		END IF
	END DO

	ratio=SMAX/MIN(N1,N2)

	IF(JTRY.GT.0) RETURN
	if(verbose .ge. 2 ) WRITE(6,1006) SMAX, RATIO
!1006	format(' match1d>   Score= ', F8.3,', Ratio= ',F8.3)
1006	format(' thread-I2>    Score= ', F8.3,', Ratio= ',F8.3)

	K=0
	IF(JMAX.LT.N2) THEN
		IMAX=N1
		DO J=N2, JMAX+1, -1
			K=K+1
			IC2(K)=ib0(J)
		END DO
	ELSE 
		DO I=N1, IMAX+1, -1
			K=K+1
			IC1(K)=ia0(I)
		END DO
	END IF

!	Search maximun score

	kgap1=0		!970211
	kgap2=0

	DO WHILE(IMAX.GE.1.AND.JMAX.GE.1)
		K=K+1
		IC1(K)=ia0(IMAX)
		IC2(K)=ib0(JMAX)
		JGO=IGO(IMAX,JMAX)
		IF(JGO) 100, 200, 300

100	KGAP2=KGAP2+1
	IS=IMAX-1
	IMAX=1-JGO
	DO I=IS,IMAX,-1
	K=K+1
	IC1(K)=ia0(I)
	END DO
	GOTO 200

300	KGAP1=KGAP1+1
	JS=JMAX-1
	JMAX=JGO+1
	DO J= JS,JMAX,-1
	K=K+1
	IC2(K)=ib0(J)
	END DO

200	IMAX=IMAX-1
	JMAX=JMAX-1
	END DO

	IF(IMAX.GT.1) THEN
		DO I=IMAX,1,-1
			K=K+1
			IC1(K)=ia0(I)
		END DO
	ELSE IF(JMAX.GT.1) THEN
		DO J=JMAX,1,-1
			K=K+1
			IC2(K)=ib0(J)
		END DO
	END IF

500	if(verbose .ge. 2 ) WRITE(6,1005) KGAP1,KGAP2
!1005	FORMAT(' match1d>   # of gaps = ',i3,', ',i3)
1005	FORMAT(' thread-I2>   # of gaps = ',i3,', ',i3)
	CALL output_ndlmn_1d(IC1,IC2,K,'thread')

	end !subroutine needleman_thread

!
! thread_ab is a clone of match_ab with the following 
! modification:
!  a switch is added to control what subroutine 
!  (needleman_1d or _thread) is called.
! thread_ab('match1d') can replace match_ab.
!
	subroutine thread_ab(switch0)
 	include 'edp_dim.inc'
!	use edp_dim

	PARAMETER 	(MAX_T=  max_rt )
	parameter 	(max_n=  max_L)
	parameter 	(max_2n=max_n*2)

!	integer, PARAMETER :: MAX_T=  max_rt 
!	integer, parameter :: max_n=  max_L
!	integer, parameter :: max_2n=max_n*2

! array ia0 will be randomized in a random trial to calculate the significance.
	integer ia0(max_n), ib0(max_n), ic0(max_n)

	common /cmm_1d/ num_aa(2), ad (max_n) ,bd(max_n) !&
     1  ,ia0, ib0, ic0

	character*1 ss, pp
	common /cmm_tbl_1d/ kp, ss(max_t), sc(max_t,max_t) !&
     1  ,mp ,pp(max_t), dd(max_t)

	INTEGER*2 iaa(max_n)

	LOGICAL LF(max_n)

	common /cmm_ctl_1d/ nr, iseed, pe, n_end, sl0, sl1, sl2, !&
     1	igr0, igr1,igr2, blk_file
	character*(*)  switch0
	character*(16) switch

	switch=switch0
	
	n1=num_aa(1)
	n2=num_aa(2)
	AV=0.
	SGM=0.
	DO J=0,NR
	if(switch(:ltrim(switch)) .eq. 'match1d') then
	  CALL NEEDLEMAN_1d(RATIO,J)
	else !if(switch(:ltrim(switch)).eq. 'thread') then
 	  call needleman_thread(ratio,j)
	endif
	IF(J.GT.0) THEN
	AV=AV+RATIO
	SGM=SGM+RATIO*RATIO
	ELSE
	RATIO_1ST=RATIO
	END IF
	IF(J.EQ.NR) GOTO 800

	DO I=1,N1
	LF(I)=.FALSE.
	iaa(I)=ia0(I)
	END DO

	DO I=1, N1
	N=NINT(RAN(ISEED)*N1)+1
210	IF(N.GT.N1) N=N-N1
	IF(LF(N)) THEN
		N=N+1
		GOTO 210
	END IF
	LF(N)=.TRUE.
	ia0(I)=iaa(N)
	END DO
	END DO

800	IF(NR.GT.2) THEN
	RN=1./FLOAT(NR)
	AV=AV*RN
	SGM=SQRT(MAX(0.,SGM*RN-AV*AV))
	WRITE(6,1007) !&
     1 switch(:ltrim(switch)), NR, switch(:ltrim(switch))
     1 , AV, switch(:ltrim(switch)), SGM
	IF(SGM.GT.0.) WRITE(6,1008) switch(:ltrim(switch))
     1 , (RATIO_1ST-AV)/SGM
	
1007	FORMAT( !&
     1 /' ',a,'-I> # of RANDOM TRY= ',i8 !& 
     1 /' ',a,'-I> AV_RATIO       = ',F8.3 !&
     1 /' ',a,'-I> SIGMA          = ',F8.3)
1008	FORMAT( !&
     1  ' ',a,'-I> SIGNIFICANCE   = ',f8.3,' sgm')
	END IF

	end !subroutine thread_ab


	integer function get_thread_score_table(r1,r2)
 	include 'edp_dim.inc'
!	use edp_dim
 	include 'edp_dat.inc'
!	use edp_dat

	PARAMETER (MAX_T=  max_rt )
	parameter (max_n=  max_L)
	parameter (max_2n=max_n*2)
	parameter (max_thr=max_res/2)
!	integer, PARAMETER :: MAX_T=  max_rt 
!	integer, parameter :: max_n=  max_L
!	integer, parameter :: max_2n=max_n*2
!	integer, parameter :: max_thr=max_res/2
	common /cmm_thread/ nr, sc(max_t,max_thr)

	integer ia0(max_n), ib0(max_n), ic0(max_n)
	common /cmm_1d/ num_aa(2), ad (max_n) ,bd(max_n) !&
     1  ,ia0, ib0, ic0

 	character*1 ss, pp
	common /cmm_tbl_1d/ kp, ss(max_t), sh_sc(max_t,max_t) !&
     1  ,mp ,pp(max_t), dd(max_t)

  	get_thread_score_table=1
!  call   score_table_1d('score_table.txt',*901)

  	n2=num_aa(2)
  	do i=1,n2
    	ii=ib0(i)
    	do j=1,kp
      	sc(j,i)=r1*sc(j,i)+r2*sh_sc(j,ii)
      	enddo
    	enddo
  	get_thread_score_table=0
  	return
901	return
	end !function get_thread_score_table

	integer function w2t()
 	include 'edp_main.inc'
!	use edp_main
 	include 'edp_dat.inc'
!	use edp_dat

	parameter (MAX_T=  max_rt )
	parameter (max_thr=max_res/2)
!	integer, parameter :: MAX_T=  max_rt 
!	integer, parameter :: max_thr=max_res/2
	common /cmm_thread/ nr, sc(max_t,max_thr)
	real w_t(10,0:max_t) 
	logical open_file	!, w2t_file
	character*(108) score_file

	logical	nword0
!	logical	nword, nword0
	character*(max_num_chars) txt
	common /cmm_txt/n_len,txt,ib,ie

	!external trim; character trim

	w2t=1

	r=1.0
call read_ar(1,r      ,*901,*50)   !               1.0

50	if(nword0(n_len,txt,ib,ie)) return
	score_file=txt(ib:ie)

	if(.not.open_file(79, score_file, 'old', '.txt')) then
 	score_file=edp_data(:ltrim(edp_data))//
     1 score_file(:ltrim(score_file))
 	if(.not.open_file(79, score_file, 'old', '.txt'))  goto 901
 	endif

	i0=0
	kp=0
	do while(.true.)
	read(79, '(a)',end=200) txt
	if(txt(1:1) .eq. ' ') goto 200
	if(txt(1:1) .ne. "!") then
	  if(i0 .eq. 0) then
	    ie=1
		n_len=ltrim(txt)
	    do i=1,10
		  call read_ar(1,w_t(i,kp),*900,*60) 
		  enddo
60	    i0=i-1
	  else
	    read(txt(3:32),*,err=900) (w_t(i,kp),i=1,i0)
	    endif
	  kp=kp+1
	  endif
	end do

200	close(79)
	kp=kp-1
	if(verbose .ge. 12) write(6,'(a10,i5,a10,i5,a10)') 
     1 ' w2t-I9> ',i0,' columns x',kp,' rows input'

	j=0
	do  jj=1,n_atom
	 if(lf(jj)) then
	   j=j+1
	   if(j.lt.max_thr) then
	    write(errmsg,'(a,i5,a)') !&
     1	' errmsg: too many atoms to select.(max_res/2=',max_thr,')'
	    return
	    endif

	curr_w= w(jj)
 	  do i=i0, 1, -1
		if(curr_w .ge. w_t(i,0) ) then
		  do k=1,kp
            sc(k,j)=w_t(i,k) +r*sc(k,j)
		    enddo
		  goto 70
		  endif
		enddo
70    	continue
      	endif
     	enddo

	w2t=0
901	return
900	errmsg=' errmsg: error during read ['//
     1 score_file(:ltrim(score_file))//']'
	end !function w2t

	integer function get_pattern(tmp,template, i_template, length) 
 	include 'edp_main.inc'
!	use edp_main
 	include 'edp_dat.inc'
!	use edp_dat

	character*(max_num_chars) tmp
	character*(1) template(32,max_num_chars), ic
	integer i_template(max_num_chars)

	character*(max_num_chars) txt
	common /cmm_txt/ n_len,txt,ib,ie
!	logical nword 

	!external trim; character trim

	get_pattern=1

	j=0	! checking []
	k=1	! checking ^
	m=1	! checking the position 
	jj=1	! how many characters at a given position
	n=ltrim(tmp)
	do i=1,n
	ic=tmp(i:i)
	if(ic .eq. '[') then
	  if(mod(j,2) .ne. 0 ) return
	  j=j+1
	  k=1
	else if(ic .eq. ']') then
	  if(mod(j,2) .eq. 0 ) return
	  j=j+1
	  k=1
	m=m+1
	  jj=1
	else if( ic .eq. '^' ) then
	  if(jj .ne. 1 ) return
	  k=-1
	else
	  template(jj,m)=ic
	  i_template(m)=jj*k
	  if(mod(j,2) .eq. 0 ) then
	    m=m+1
		k=1
	  else
	    jj=jj+1
	  endif
	endif
	end do

	length=m-1
	if( verbose .ge. 12 ) then 
	  do i=1,length
	    write(6,*) i_template(i), (template(j,i),j=1,abs(i_template(i)))
	  enddo
	endif

	get_pattern=0  	
	end !function get_pattern
