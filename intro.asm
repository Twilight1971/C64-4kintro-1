
//-----------------------------------------------------------------------------------
//
// Code by TWILIGHT / Excess 2019 - ...
// Kick Assembler V5.14
//
//-----------------------------------------------------------------------------------


      .pc = $0800 "logo charset"
      .import binary "rasterlogo.pimap",2
			
      .pc = $0c00 "logo screen"
      .import binary "rasterlogo.piscr",2
      
      
.pc = $1000 "music"
      .import binary "Vector_Runner.dat",2
      

.pc= $1310 "maincode"


			
			
			lda #$0f
			sta $0286
			jsr $e544
			lda #$00
			sta $d022
			lda #$00
			sta $d020
			lda #$00
			jsr $1000
			jsr scrinit
			jsr disable
			
			ldx #$00
lop11:		lda textcol,x
			sta $dbbe,x
			inx
			cpx #$29
			bne lop11
			
        	sei
        	lda #$7F
        	sta $DC0D    
        	sta $DD0D    
        	lda $DC0D    
        	lda $DD0D    
        	lda #$01
        	sta $D01A    
        	lda #$31
        	sta $D012    
        	lda #<INT0
        	sta $0314    
        	lda #>INT0
        	sta $0315    
        	cli
        	jmp *
//	 		    01234567890123456789012345678901234567890		
textcol:  .text"kkllooaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaoollkk "       	
        	
CheckKB:	lda $dc00    
        	eor $dc01    
        	asl
        	bne exit1     
        	rts
exit1:     	jmp exit


//----- RESTORE DEAD -----------------------------------------------
disable:        lda #<nmi             //Set NMI vector
                sta $0318
                sta $fffa
                lda #>nmi
                sta $0319
                sta $fffb
                lda #$81
                sta $dd0d             //Use Timer A
                lda #$01              //Timer A count ($0001)
                sta $dd04
                lda #$00
                sta $dd05
                lda #%00011001        //Run Timer A
                sta $dd0e
                rts

nmi:            rti
//----------------------------------------------------


INT0:    	
				
			lda $dd00
			and #$fc
			ora #$03
			sta $dd00
			lda #$32
			sta $d018								
			lda #$d1				
			sta $d016				
			lda #$1b				
			sta $d011				
        	ldx #<INT1
        	ldy #>INT1
        	lda #$31
        	jsr INTe
 			jsr CheckKB
 			jsr scroll
        	jmp $ea81
        	
scrtxt: 

         .byte $f0,$fa
         .text "ortsar k4                             "
         .byte $f1,$f8
         .text "by TWILIGHT of excess for ICC2019     sid by drumtex     logo by twilight  "
         .byte $fa
	//	 .byte $f8	
		 .text "greets fly to atlantis, fairlight, genesis project, hokuto force, laxity, mayday, nostalgia, onslaught, role, triad..."	
		 .text "                                        "			
		 .byte $00
        	
         
.align $0100
//------------------------------------------------------------------------------
// Rasters  logo oben

INT1:	   	ldy #$0d
lop1:      	dey
        	bpl lop1
        	nop
        	bit $EA
        	ldx #$00
INT1_J1: 	lda color1,x
			sta $D021    
        	sta $D021   
logoc1:    	lda color11,x
        	sta $D023    
        	nop
        	nop
        	inx
        	ldy #$06
INT1_J2: 	lda color1,x
			sta $D021    
        	sta $D021    
logoc11:   	lda color11,x
			sta $D023    
        	jsr Delay
        	bpl INT1_J2
        	nop
        	cpx #$c0
        	bne INT1_J1
        	
        	
			lda #[[$0c00 & $3fff] / 64] | [[$d400 & $3fff] / 1024]
			sta $d018
        	
        	lda scrpos
        	sta $d016
        	ldx #<INT0
        	ldy #>INT0
        	lda #$fa
        	jsr INTe
        	
        	
        	
        	jsr rasterro
        	jsr $1058
        	jmp $ea81


//------------------------------------------------------------------------------
// Exit the interrupt
INTe:  	  	stx $0314    
        	sty $0315    
        	sta $D012    
        	inc $D019    
        	rts
//------------------------------------------------------------------------------
Delay:   	
			lda ($ea,x)
        	lda ($ea,x)
        	lda ($ea,x)
        	inx
        	dey
        	nop
        	nop
        	rts

//-------------------------------------------------------------------------
rasterro:	
			lda color11+$b7
            sta color11+$00
            ldx #$b7
cycle:      lda color11-$01,x
            sta color11+$00,x
            dex
            bne cycle
            
            
			lda color1+11+$00
            sta color1+11+$a1
            ldx #$00
cycle1:     lda color1+11+$01,x
            sta color1+11+$00,x
            inx
            cpx #$a1
            bne cycle1
            
            
			rts

//-------------------------------------------------------------------------
            
.var line     = $0fc0


scrinit: lda #>scrtxt   //; textstart
         sta txtpos+2
         lda #<scrtxt
         sta txtpos+1
         lda #$01       //; speed 1
         sta fscrspd+1
         sta bscrspd+1
         lda #$07
         sta scrpos
         lda #$01       //; forward
         sta scrdir
         rts


scroll:   lda scrdir
         cmp #$01       //; forward ?
         bne backward   //; no !

forward:  lda scrpos
         sec
fscrspd:  sbc #$01
         and #$07
         sta scrpos
         bcc fver
         rts

fver:     ldx #$00
flp1:     lda line+1,x
         sta line,x
         inx
         cpx #$27
         bne flp1

         jmp txtpos

backward: lda scrpos
         and #$07
         clc
bscrspd:  adc #$01
         tax
         and #$07
         sta scrpos
         txa
         adc #$f8
         bcs bver
         rts

bver:     ldx #$26
blp1:     lda line,x
         sta line+1,x
         dex
         cpx #$ff
         bne blp1

txtpos:   lda $dead      
         cmp #$00       //; end of txt ?
         bne lp2        //; no !

         lda #>scrtxt
         sta txtpos+2
         lda #<scrtxt
         sta txtpos+1
         jmp txtpos

lp2:      cmp #$f8       //; speedbyte ?
         bcc lp4        //; no !
         and #$07
         clc
         adc #$01
         sta fscrspd+1
         sta bscrspd+1
         jmp txtcount

lp4:      cmp #$f1          //; dir. forw ?
         bcc lp6           //; no !
         ldx #$01
         stx scrdir
         jmp txtcount

lp6:      cmp #$f0          //; dir. back ?
         bcc lp5           //; no !
         ldx #$00
         stx scrdir
         jmp txtcount

lp5:      ldx scrdir
         cpx #$01          //; forward ?
         bne back          //; no !

         and #$3f
         sta line+$27
         lda scrpos
         clc
         adc #$08
         and #$07
         sta scrpos
         jmp txtcount

back:     and #$3f
         sta line
         lda scrpos
         sec
         sbc #$08
         and #$07
         sta scrpos

txtcount: inc txtpos+1
         bne lp3
         inc txtpos+2
lp3:

ende:     rts

scrdir:   .byte $01
scrpos:   .byte $07

exit:        
end2:		
			sei
			lda #$00
			sta $d01a
			
        	ldx #<$ea31
        	ldy #>$ea31
        	jsr INTe
        	jsr $fda3    //$fda3 (jmp) - initialize cia & irq
        	ldx #$1f
        	jsr $e5aa    //get a vic ii chip initialisation value



        	ldx #$18
        	lda #$00
lop7:      	sta $d400,x  //;select filter mode and volume
        	dex
        	bpl lop7
        	lda #$00
        	sta $d011

        	
       		jmp $fce2    //$080d   // Gamestart Jump
        	

		
//-------------------------------------------------------------------------

.align $0100
color11:		

.text "i@ii@ihihhheheeececccgcgggagaaagagggogooojgjjjhjhhhbhbbbibiiififffkfkkknknnncncccgcgggagaaagagggcgcccncnnnknkkkfkfffifiiibibbbhbhhhjhjjjojooogogggagaaagagggogooojgjjjhjhhhbhbbbibiiiiiii"
//-------------------------------------------------------------------------

.pc = $0b00 "raster colors"
color1:			
.text "klogagolk ibbh bhhj hjjg jgga gaag aggj gjjo jool ollk "		
.text "kllo looj ojjg jgga gaag aggc gccn cnnd nddf "			
.text "ibbh bhhj hjjg jgga gaag aggj gjjo jool ollk "		
.text "kllo looj ojjg jgga gaag ag  fkncacnkf        k"			



