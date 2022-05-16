.text
start:
	add  $t8, $zero, $zero
	add  $t9, $zero, $zero
	add  $s0, $zero, $zero		# $s0 is the first operand
	add  $s1, $zero, $zero		# $s1 is the second operand
	add  $s2, $zero, $zero		# $s2 is the operator
waitForTheFirstOperand:
	beq  $t9, $zero, waitForTheFirstOperand
	# Get rid of the MSB
	sll  $t0, $t9, 1
	srl  $t0, $t0, 1
	# Check whether it is a digit
	slti $t1, $t0, 10
	beq  $t1, $zero, maybeOperator
	sll  $t1, $s0, 3		# $t1 = $s0 * 8
	add  $t1, $t1, $s0		# $t1 = ($s0 * 8) + $s0
	add  $s0, $t1, $s0		# $s0 = $s0 * 10
	add  $s0, $s0, $t0		# Add another digit to the first operand
	add  $t8, $zero, $s0
	add  $t9, $zero, $zero
	j    waitForTheFirstOperand
maybeOperator:
	addi $t1, $zero, 15		# $t1 = 15
	beq  $t0, $t1, start		# Press C...go to start
	addi $t1, $zero, 14		# $t1 = 14
	beq  $t0, $t1, result		# Press =...go to show result
	add  $s2, $zero, $t0		# $s2 is the operator
	add  $t9, $zero, $zero
waitForTheSecondOperand:
	beq  $t9, $zero, waitForTheSecondOperand
	# Get rid of the MSB
	sll  $t0, $t9, 1
	srl  $t0, $t0, 1
	# Check whether it is a digit
	slti $t1, $t0, 10
	beq  $t1, $zero, maybeEqual
	sll  $t1, $s1, 3		# $t1 = $s0 * 8
	add  $t1, $t1, $s1		# $t1 = ($s0 * 8) + $s0
	add  $s1, $t1, $s1		# $s0 = $s0 * 10
	add  $s1, $s1, $t0		# Add another digit to the first operand
	add  $t8, $zero, $s1
	add  $t9, $zero, $zero
	j    waitForTheSecondOperand
maybeEqual:
	addi $t1, $zero, 15
	beq  $t0, $t1, start
	addi $t1, $zero, 14
	beq  $t0, $t1, result
	# User press another operator...do nothing
result:
	bne  $s2, $zero, calculateResult
	add  $t8, $zero, $s0
	add  $t9, $zero, $zero
	j    waitForClear
calculateResult:
	addi $t0, $zero, 10
	beq  $s2, $t0, calculateAdd
	addi $t0, $zero, 11
	beq  $s2, $t0, calculateSub
	addi $t0, $zero, 12
	beq  $s2, $t0, calculateMul
	addi $t0, $zero, 13
	beq  $s2, $t0, calculateDiv
	# Something wrong
	j    start
calculateAdd:
	add  $t8, $s0, $s1
	add  $t9, $zero, $zero
	j    waitForClear
calculateSub:
	sub  $t8, $s0, $s1
	add  $t9, $zero, $zero
	j    waitForClear
calculateMul:
	add  $t0, $zero, $s0
	add  $t1, $zero, $s1
	add  $t2, $zero, $zero
mulLoop:
	beq  $t1, $zero, mulDone
	andi $t3, $t1, 0x1
	beq  $t3, $zero, mulNext
	add  $t2, $t2, $t0
mulNext:
	sll  $t0, $t0, 1
	srl  $t1, $t1, 1
	j    mulLoop
mulDone:
	add  $t8, $t2, $zero
	add  $t9, $zero, $zero
	j    waitForClear
calculateDiv:
	add  $t0, $zero, $s0
	sll  $t1, $s1, 16
	add  $t2, $zero, $zero
	addi $t3, $zero, 17
divLoop:
	beq  $t3, $zero, divDone
	slt  $t4, $t0, $t1		# if dividend < divisor
	bne  $t4, $zero, shiftInZero
	sub  $t0, $t0, $t1
	sll  $t2, $t2, 1
	ori  $t2, $t2, 0x1
	j    divNext
shiftInZero:
	sll  $t2, $t2, 1
divNext:
	srl  $t1, $t1, 1
	addi $t3, $t3, -1
	j    divLoop
divDone:
	add  $t8, $t2, $zero
	add  $t9, $zero, $zero
	j    waitForClear
waitForClear:
	beq  $t9, $zero, waitForClear
	sll  $t0, $t9, 1
	srl  $t0, $t0, 1
	addi $t1, $zero, 15
	beq  $t0, $t1, start
	# User press something that is not C
	add  $t9, $zero, $zero
	j    waitForClear