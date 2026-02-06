		AREA    MergeSort_M0, CODE, READONLY
        THUMB
        ENTRY
        EXPORT  main
        EXPORT  my_MergeSort
        EXPORT  my_Merge

main
		MOVS R0,#38				;R0 = 38
		MOVS R1,#27				;R1 = 27
		MOVS R2,#43				;R2 = 43
		MOVS R3,#10				;R3 = 10
		MOVS R4,#55				;R4 = 55
		
		MOVS R5,#0				;R5 = 0 (left)
		MOVS R6,#4				;R6 = 4 (right)
		PUSH {R5,R6}			;push the left and right values for first my_MergeSort call
		BL my_MergeSort			;branch my_MergeSort and save LR (my_MergeSort(arr,0,4))
		;CLEAR THE OTHER REGISTERS
		MOVS R5,#0				;R5 = 0
		MOVS R6,#0				;R6 = 0
		MOVS R7,#0				;R7 = 0
stop	B stop

my_MergeSort PROC
		POP {R5,R6}				;R5 = left ,R6 = right 
		PUSH {LR}				;save return address
		CMP R5,R6				;compare left and right
		BHS return				;branch return if left>=right
		SUBS R7,R6,R5			;R7 = right - left
		ASRS R7,#1				;R7 = (right - left)/2
		ADDS R7,R5				;R7(mid) = (right - left)/2 + left
		PUSH {R5,R6,R7}			;save the values of R5=left,R6=right,R7=mid for current function
		PUSH {R5,R7}			;push left and mid values of current function for next call.
		BL my_MergeSort			;my_MergeSort(arrayB,left,mid)
		POP {R5,R6,R7}			;restore R5=left,R6=right,R7=mid for current function
		PUSH {R5,R6,R7}			;save the values of R5=left,R6=right,R7=mid for current function
		ADDS R7,#1				;mid++
		PUSH {R6}				;push right value of current function for next call.
		PUSH {R7}				;push mid+1 value of current function for next call.
		BL my_MergeSort			;my_MergeSort(arrayB,mid+1,right)
		POP {R5,R6,R7}			;restore R5=left,R6=right,R7=mid for current function
		BL my_Merge				;my_Merge(left,mid,right)
	
return	POP{PC}					;POP PC, return saved address

my_Merge PROC
		;r5=left,r6=right,r7=mid
		PUSH {R0,R1,R2,R3,R4}	;store array values 
		MOV  R4,SP				;R4 = SP, R4 = starting address of array 
		SUBS R0,R7,R5			;R0 = mid - left
		ADDS R0,#1				;R0 = mid-left+1, R0 =size of left array n1
		SUBS R1,R6,R7			;R1 = right-mid, R1= size of right array n2
		LSLS R0,#2				;n1=n1*4 
		LSLS R1,#2				;n2=n2*4
		LSLS R5,#2				;left=left*4
		LSLS R7,#2				;mid=mid*4
		;saving place in stack for temp arrays
		SUBS R2,R4,R0			;R2 = SP - n1 (R2 = Starting address of Left Array)
		SUBS R3,R2,R1			;R3 = SP - n1 - n2 (R3 = Starting address of Right Array)
		ADDS R6,R0,R1			;R6 = n1+n2 (total using memory for temparrays)
		SUBS R6,R4,R6			;R6 = SP-(n1+n2)
		MOV  SP,R6				;SP = SP-(n1+n2)
		;at this point, there are 7 variable:
		;R0 = n1, R1 = n2, R2 = Starting address of Left Array, R3 = Starting address of Right Array, R4 = Starting address of sorting array 
		;R5 = left, R7 = mid 
		;with pop and push operations without losing their exact values, registers will use other operations in continue of merge


		PUSH {R1,R3,R7}			;store n2,rightarray,mid
		MOVS R1,#0				;i=0
;copydata to temp left array
first_loop
		CMP R1,R0				;compare i and n1
		BHS break_first_loop	;branch break_first_loop if i >=n1
		ADDS R6,R5,R1			;R6=left+i
		LDR R3, [R4,R6]			;r3 = arr[left+i]
		STR R3, [R2,R1]			;left[i] = arr[left+i]
		ADDS R1,#4				;i++
		B first_loop			;branch first_loop
break_first_loop		
		POP {R1,R3,R7}			;restore n2, rightarray , mid		

		PUSH {R0,R2,R5}			;store n1, leftarray, left
		MOVS R0,#0				;j=0
		
;copydata to temp left array		
second_loop	
		CMP R0,R1				;compare j and n2
		BHS break_second_loop 	;branch break_second_loop if j >= n2
		ADDS R6,R7,#4			;r6=mid+1
		ADDS R6,R6,R0			;r6=mid+1+j
		LDR R2, [R4,R6]			;r2= arr[mid+1+j]
		STR R2, [R3,R0]			;right[j] = arr[mid+1+j]
		ADDS R0,#4				;j++
		B second_loop			;branch second_loop
break_second_loop		
		POP {R0,R2,R5}			;restore n1, leftarray, left
		
;merging vectors 
		MOVS R6,#0 				;i=0
		MOVS R7,#0 				;j=0
mergetemparrays
		CMP R6,R0				;compare i and n1
		BHS first_while			;branch first_while if i>=n1
		CMP R7,R1				;compare j and n2
		BHS first_while			;branch first_while if j>=n2
		PUSH {R0,R1}			;store n1 and n2
		LDR R0,[R2,R6]			;r0=leftarray[i]
		LDR R1,[R3,R7]			;r1=rightarray[j]
		CMP R0,R1				;compare leftarray[i] and rightarray[j]
		BGT go_else				;branch go_else if leftarray[i]>rightarray[j]
		LDR R0,[R2,R6]			;r0=leftarray[i]
		STR R0,[R4,R5]			;arr[left]=leftarray[i]
		ADDS R6,#4				;i++
		ADDS R5,#4				;left++
		POP {R0,R1}				;restore n1 and n2
		B mergetemparrays		;branch mergetemparrays
go_else 
		LDR R0,[R3,R7]			;r0=rightarray[j]
		STR R0,[R4,R5]			;arr[left]=rightarray[j]
		ADDS R7,#4				;j++
		ADDS R5,#4				;left++
		POP {R0,R1}				;restore n1 and n2
		B mergetemparrays		;branch mergetemparrays

;copy remaining temp arrays to arr
first_while
		CMP R6,R0				;compare i and n1
		BHS secondwhile		;branch end_of_merge if i >=n1
		PUSH {R0,R1}			;store n1 and n2
		LDR R0,[R2,R6]			;R0 = leftarray[i]
		STR R0,[R4,R5]			;arr[left] = leftarray[i]
		ADDS R6,#4				;i++
		ADDS R5,#4				;left++
		POP {R0,R1}				;restore n1 and n2
		B first_while			;branch first_while
		
secondwhile	
		CMP R7,R1				;compare j and n2
		BHS end_of_merge		;branch end_of_merge if j >=n2
		PUSH {R0,R1}			;store n1 and n2
		LDR R0,[R3,R7]			;R0= rightarray[j]
		STR R0,[R4,R5]			;arr[left]=rightarray[j]
		ADDS R7,#4				;j++
		ADDS R5,#4				;left++
		POP {R0,R1}				;restore n1 and n2
		B secondwhile			;branch secondwhile
		
end_of_merge				
		;restore SP value, SP will be what it is before merge
		MOV R4,SP				;R4 = SP 
		ADDS R6,R0,R1			;R6 = n1+n2
		ADDS R4,R6				;R4 = SP + n1 +n2
		MOV SP,R4				;SP = SP + n1 +n2
		POP {R0,R1,R2,R3,R4}	;restore R0-R4 registers, after the swap operation made in stack, changed array store back to the R0-R4 registers
		BX LR					;return
		
        END