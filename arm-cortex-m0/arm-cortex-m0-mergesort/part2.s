        AREA    MergeSort_M0, CODE, READONLY
        THUMB
        ENTRY
        EXPORT  main
        EXPORT  my_MergeSort
        EXPORT  my_Merge

main    PROC
;Fill in these functions according to the merge logic; you may use additional helper functions
		LDR R7,=arrayB			;address of arrayB loaded. R7 = &arrayB
		MOVS R0,#0				;first index of array
		MOVS R1,#7				;last index of array
		PUSH {R0,R1}			;Push first and last index for first call 
		BL my_MergeSort			;my_MergeSort(arrayB,0,7)
		;sort is finished load the sorted array into R0-R7 registers
		LDR     R0, [R7, #0]	;R0 = arrayB[0]
        LDR     R1, [R7, #4]	;R1 = arrayB[1]
        LDR     R2, [R7, #8]	;R2 = arrayB[2]
        LDR     R3, [R7, #12]	;R3 = arrayB[3]
        LDR     R4, [R7, #16]	;R4 = arrayB[4]
        LDR     R5, [R7, #20]	;R5 = arrayB[5]
        LDR     R6, [R7, #24]	;R6 = arrayB[6]
        LDR     R7, [R7, #28]	;R7 = arrayB[7]

stop    B       stop             ; put breakpoint here to work 
        ENDP

my_MergeSort 	PROC
		POP {R0,R1}				;restore R0,R1. R0 = left, R1 = right
		PUSH {LR}				;save the return address
		CMP R0,R1				;compare left and Right
		BHS return				;go return if left>=right
		SUBS R2,R1,R0			;R2 = right - left
		ASRS R2,#1				;R2 = (right - left)/2
		ADDS R2,R0				;R2 = (right - left)/2 + left , R2 = mid 
		PUSH {R0,R1,R2}			;save the values of R0=left,R1=right,R2=mid for current function
		PUSH {R0,R2}			;push left and mid values of current function for next call.
		BL my_MergeSort			;my_MergeSort(arrayB,left,mid)
		POP {R0,R1,R2}			;restore R0=left,R1=right,R2=mid for current function
		PUSH {R0,R1,R2}			;save the values of R0=left,R1=right,R2=mid for current function
		ADDS R2,#1				;mid = mid + 1 
		PUSH {R1}				;push right value of current function for next call.
		PUSH {R2}				;push mid+1 value of current function for next call.
		BL my_MergeSort			;my_MergeSort(arrayB,mid+1,right)
		POP {R0,R1,R2}			;restore R0=left,R1=right,R2=mid for current function
		BL my_Merge				;now R0=left,R1=right,R2=mid and with these values we can call Merge(arrayB,left,mid,right)
	
return		POP{PC}					;POP PC, return saved address


my_Merge PROC
		;r0=left,r1=right,r2=mid
						
		SUBS R5,R2,R0			;R5 = mid-left
		ADDS R5,#1				;R5 = mid -left + 1  =  size of left array (n1)
		SUBS R6,R1,R2			;R6 = right-mid = size of right array (n2)
		LSLS R5,#2				;n1 = n1*4
		LSLS R6,#2				;n2 = n2*4
		LSLS R0,#2				;left= left*4
		LSLS R2,#2				;mid = mid*4  these operations made for reach the word easily
		MOV  R4,SP				;R4 = current SP
		SUBS R1,R4,R5			;R1 = R4 - size of left array (saved place for left array in stack) (R1 = SP - n1)
		SUBS R3,R1,R6			;R3 = R1 - size of right array (saved place for right array in stack) (R3 = SP - n1 -n2)
		ADDS R7,R5,R6			;R7 = n1 + n2
		SUBS R4,R7				;R4 = R4 - R7 (R4 = SP - (n1+n2))
		MOV SP,R4				;SP = SP - (n1+n2) saved place in stack for temp arrays
		
		;at this point, there are 7 variable: 
		;R5 = n1, R6 = n2, R1 = Starting address of Left Array, R3 = Starting address of Right Array
		;R0=left, R2 = mid
		;with pop and push operations without losing their exact values, registers will use other operations in continue of merge

		
		LDR  R7,=arrayB
		PUSH {R3,R6}			;store R3 and R6
		MOVS R6,#0				;i=0
copydata_loop1
		
		CMP R6,R5				;compare i and n1
		BHS break_first_loop	;branch break_first_loop if i>=n1
		ADDS R3,R0,R6			;r3 = left+i
		LDR R3, [R7,R3]			;r3 = arr[left+i]
		STR R3, [R1,R6]			;leftarray[i] = arr[left+i]
		ADDS R6,#4				;i++
		B copydata_loop1		;branch first_loop
break_first_loop		
		POP {R3,R6}				;restore R3 and R6
		
		PUSH {R1,R5}			;store R1 and R5
		MOVS R5,#0				;j=0
copydata_loop2
		CMP R5,R6				;compare j and n2
		BHS break_second_loop	;branch break_second_loop if j>=n2
		ADDS R1,R2,#4			;r1=mid+1
		ADDS R1,R1,R5			;r1=mid+1+j
		LDR R1, [R7,R1]			;r2= arr[mid+1+j]
		STR R1, [R3,R5]			;rightarray[j] = arr[mid+1+j]
		ADDS R5,#4				;j++
		B copydata_loop2		;branch copydata_loop2
break_second_loop		
		POP {R1,R5}				;restore R1 and R5
		
		
		;R5 = n1, R6 = n2, R1 = Starting address of Left Array, R3 = Starting address of Right Array
		;R0=left
		MOVS R2,#0			;i=0
		MOVS R7,#0			;j=0
		MOVS R4,#0			;initializied 0 to R4, after merge operation in R4 there will be merged numbers.
mergetemparrays 				;merge temp arrays back into array
		
		CMP R2,R5			;compare i and n1 
		BHS firstwhile		;branch firstwhile if i >= n1 
		CMP R7,R6			;compare j and n2
		BHS firstwhile		;branch firstwhile if j >=n2
		PUSH {R5,R6}		;store R5 and R6 (n1,n2)
		LDR R5,[R1,R2]		;R5 = leftarray[i]
		LDR R6,[R3,R7]		;R6 = rightarray[j]
		CMP R5,R6			;compare R5 and R6
		BGT go_else			;branch go_else if R5>R6
		PUSH {R7}			;store R7 (j) 
		LDR R7,=arrayB		;address of arrayB loaded. R7 = &arrayB
		STR R5,[R7,R0]		;arrayB[left] = leftarray[i]
		;below two operation are making to see merging values. 
		LSLS R4,#8			;shift 8 bit left R4. (shift the last merged value)
		ADDS R4,R4,R5		;add leftarray[i](merged element) to R4 
		POP {R7}			;restore R7 (j)
		ADDS R2,#4			;i++
		ADDS R0,#4			;left++
		POP {R5,R6}			;restore R5 and R6 (n1,n2)
		B mergetemparrays	;branch mergetemparrays
go_else
		PUSH {R7}			;store R7 (j)
		LDR R7,=arrayB		;address of arrayB loaded. R7 = &arrayB
		STR R6,[R7,R0]		;arrayB[left] = rightarray[j]
		LSLS R4,#8			;shift 8 bit left R4. (shift the last merged value)
		ADDS R4,R4,R6		;add rightarray[j](merged element) to R4 
		POP {R7}			;restore R7 (j)
		ADDS R7,#4			;j++
		ADDS R0,#4			;left++
		POP {R5,R6}			;restore R5 and R6 (n1,n2)
		B mergetemparrays	;branch mergetemparrays
	
;R2 = i, R7=j , R0= left
;R5 = n1, R6 = n2, R1 = Starting address of Left Array, R3 = Starting address of Right Array
;copy remaing elements for leftarray
firstwhile
		CMP R2,R5			;compare R2 and R5, i and n1
		BHS secondwhile		;branch endmerge if i>=n1
		PUSH {R5}			;store R5 (n1)
		PUSH {R7}			;store R7 (j)
		LDR R5,[R1,R2]		;R5 = leftarray[i]
		LDR R7,=arrayB		;address of arrayB loaded. R7 = &arrayB
		STR R5,[R7,R0]		;arrayB[left] = leftarray[i]
		LSLS R4,#8			;shift 8 bit left R4. (shift the last merged value)
		ADDS R4,R4,R5		;add leftarray[i](merged element) to R4 
		POP {R7}			;restore R7 (j)
		POP {R5}			;restore R5 (n1)
		ADDS R2,#4			;i++
		ADDS R0,#4			;left++
		B firstwhile		;branch firstwhile
;copy remaing elements for rightarray

secondwhile
		CMP R7,R6			;compare R7 and R6 (j and n2)
		BHS endmerge		;branch endmerge if j>=n2
		PUSH {R5}			;store R5 (n1)
		LDR R5,[R3,R7]		;R5 = rightarray[j]
		PUSH {R7}			;store R7 (j)
		LDR R7,=arrayB		;address of arrayB loaded. R7 = &arrayB
		STR R5,[R7,R0]		;arrayB[left] = rightarray[j]
		LSLS R4,#8			;shift 8 bit left R4. (shift the last merged value)
		ADDS R4,R4,R5		;add rightarray[j](merged element) to R4 
		POP {R7}			;restore R7 (j)
		POP {R5}			;restore R5 (n1)
		ADDS R7,#4			;j++
		ADDS R0,#4			;left++
		B secondwhile		;branch secondwhile

endmerge
		;you can put breakpoint here to see R4 (merged values)
		MOV R3,SP			;R3 = SP
		ADDS R7,R5,R6		;R7 = n1+n2
		ADDS R3,R3,R7		;R3 = SP + n1 + n2 
		MOV SP,R3			;SP = SP + n1 + n2 (saved place for temp arrays restored)
		LDR R7,=arrayB		;address of arrayB loaded. R7 = &arrayB
		BX LR				;return
		
		AREA mydata, DATA, READWRITE ;data section
arrayB  DCD 	13, 27, 10, 7, 22, 56, 28, 2 ;arrayB stored in memory by word 
	
	
        END

