.data
    welcome: .asciiz "Welcome to Hangman game\nThe game is about to start!\nLet's play Hangman!\n"
    hint: .asciiz "Hint: a programming language\n"
    score: .asciiz "\nScore: "
    guess: .asciiz " Guess: "
    word: .asciiz " Word: "
    guessALetter: .asciiz "Please guess a letter: \n"
    inputInt: .asciiz "\nPlease write a number (1-6): \n"
    newLine: .asciiz "\n"
    true: .asciiz "\nWell done! That letter is in the word."
    false: .asciiz "\nThat letter is not in the word."
    win: .asciiz "You win! :)\n"
    lose: .asciiz "\nYou lose! :(\n"
    playAgain: .asciiz "\nPlay Again? (1/0)\n"
    gameOver: .asciiz "\nGame Over"
    guessWord: .space 32
    stageZero: .asciiz  "\n--------\n|       |\n|       0\n|      \|/\n|       |\n|      / \\n-\n"
    stageOne: .asciiz   "\n--------\n|       |\n|       0\n|      \|/\n|       |\n|      /\n-\n"
    stageTwo: .asciiz   "\n--------\n|       |\n|       0\n|      \|/\n|       |\n|      \n-\n"
    stageThree: .asciiz "\n--------\n|       |\n|       0\n|      \|\n|       |\n|      \n-\n"
    stageFour: .asciiz  "\n--------\n|       |\n|       0\n|       |\n|       |\n|      \n-\n"
    stageFive: .asciiz  "\n--------\n|       |\n|       0\n|        \n|        \n|      \n-\n"
    stageSix: .asciiz   "\n--------\n|       |\n|        \n|        \n|        \n|      \n-\n"
    word1: .asciiz "javascript"
    word2: .asciiz "python"
    word3: .asciiz "assembly"
    word4: .asciiz "delphi"
    word5: .asciiz "cobol"
    word6: .asciiz "pascal"
.text
    main:
        la $a0, welcome # karşılama cümlelerini yazdır
        jal print

        jal start # oyun baslıyor

    start:
        la $a0, hint # oyuncuya kelime hakkında ipucu göster
        jal print
        
        li $s0, 7 # oyuncunun skoru s0 da tutulacak 7 ile başlat
        # 6 adet kelimeden birini seçmek için kullanıcıdan (1-6) arasında bir sayı istiyoruz
        la $a0, inputInt 
        jal print
        
        jal getInputInt

        # girilen sayıya göre kelimeyi belirliyoruz s1'e atıyoruz
        move $a0, $v0 
        jal chooseWord
        
        move $a0, $s1
        jal strlen

        la $a0, guessWord 
        move $a1, $v0 
        jal fillGuessWord # oyuncunun tahminini tutacak olan değişkenin harflerinin boşluklarını underscore ile doldur

        jal gameLoop # oyun döngüsü başlıyor
    
    gameLoop:
        beq $s0, $0, gameLoopEndLose #skor 0'a eşitse oyunu bitir oyuncu kaybetti
        
        la $a0, score #"Score: "
        jal print

        move $a0, $s0  # "? " 
        jal printInt

        la $a0, guess  # "Guess: "
        jal print

        la $a0, guessWord # "____"
        jal print

        la $a0, newLine # "\n"
        jal print

        la $a0, guessALetter # "Please guess a letter: "
        jal print

        jal getInputChar # kullanıcıdan input al
        move $s2, $v0 # fonksiyondan dönen karakteri s2'de tut

        move $a0, $s1 
        move $a1, $s2
        jal wordContains  # tahmin edilecek kelimede kullanıcının girdiği karakter var mı diye kontrol eden fonksiyon
        
        bne $v0, $0, charFound # karakter bulunduysa

        addi $s0, $s0, -1 # karakter yoksa skoru 1 azalt

        la $a0, false # "That letter is not in the word."
        jal print

        jal stagePrint # oyuncunun bulunduğu skora göre şekli yazdır
        
        j gameLoop # oyun devam eder

    charFound:
        la $a0, guessWord 
        move $a1, $s1
        move $a2, $s2
        jal updateGuessWord # tahmini kelimeyi günceller

        la $a0, guessWord 
        addi $a1, $0, 95
        jal wordContains # tahmini kelimede underscore var mı

        beq $v0, $0, gameLoopEndWin # underscore yoksa oyun bitti oyuncu kazandı
        
        la $a0, true # "Well done! That letter is in the word."
        jal print

        j gameLoop # oyun devam eder

    updateGuessWord:
        # argüman olarak tahmini depolama alanını, tahmin edilecek kelimeyi ve kullanıcının girdiği karakteri alır 
        # kullanıcının girdiği karaktere göre tahmini kelimede bulunduğu yerlere o karakteri yerleştirir
        addi $sp, $sp, -8
        sw $a0, 0($sp)
        sw $a1, 4($sp)
        updateWhile:
            lb $t0, 0($a1)
            beq $t0, $0, updateWhileEnd
            bne $t0, $a2, charNotFound
            sb $a2, 0($a0) # karakteri yerleştir
            charNotFound:
                addi $a0, $a0, 1
                addi $a1, $a1, 1
                j updateWhile
    updateWhileEnd:
        lw $a1, 4($sp)
        lw $a0, 0($sp)
        addi $sp, $sp, 8
        jr $ra

    wordContains:
        # argüman olarak tahmin edilecek kelimeyi ve kullanıcının girdiği karakteri alır 
        # karakter kelimede var mı diye kontrol eder varsa 1 yoksa 0 değerini döndürür
        addi $sp, $sp, -4
        sw $a0, 0($sp)

        and $v0, $v0, $0 # başlangıçta 0 değerini atıyoruz
        containsWhile:
            lb $t0, 0($a0) # kelimeden karakteri alıyoruz
            beq $t0, $0, containsWhileEnd
            beq $t0, $a1, isContains
            addi $a0, $a0, 1
            j containsWhile

    isContains:
        addi $v0, $zero, 1 # kelimede karakter var
    containsWhileEnd:
        lw $a0, 0($sp)
        addi $sp, $sp, 4
        jr $ra

    fillGuessWord:
        # argüman olarak tahmini kelimeyi tutacak depolama alanı ve kelimenin uzunluk bilgisini alır 
        # depolama alanını kelimenin uzunluğu kadar underscore ile doldurur
        addi $sp, $sp, -8
        sw $a0, 0($sp)
        sw $a1, 4($sp)
        
        add $a0, $a0, $a1 # a0 da depolama alanının adresine kelime uzunluğunu ekliyoruz
        addi $t1, $0, 95 # 95: underscore ascii değeri
        sb $0, 0($a0) # kelimenin son baytına null değer atıyoruz
        
        fillWhile:
            beq $a1, $t0, fillWhileEnd 
            addi $a0, $a0, -1 # kelimenin sonundan başına doğru ilerliyoruz
            addi $a1, $a1, -1
            sb $t1, 0($a0) # kelimenin her baytına underscore atıyoruz
            j fillWhile
    fillWhileEnd:
        lw $a0, 0($sp)
        lw $a1, 4($sp)
        addi $sp, $sp, 8
        jr $ra
    
    gameLoopEndWin:
        la $a0, true 
        jal print

        la $a0, score #"Score: "
        jal print

        move $a0, $s0  #"? "
        jal printInt

        la $a0, guess  #"Guess: "
        jal print

        la $a0, guessWord 
        jal print

        la $a0, newLine #"\n"
        jal print

        jal stagePrint

        la $a0, win
        jal print

        jal again
    
    gameLoopEndLose:
        la $a0, score #"Score: "
        jal print

        move $a0, $s0  #"? "
        jal printInt

        la $a0, word  #"Guess: "
        jal print

        move $a0, $s1  #"Guess: "
        jal print

        la $a0, lose
        jal print

        jal again
    
    again:
        la $a0, playAgain
        jal print

        jal getInputInt
        move $s3, $v0

        bne $s3, $0, start
        beq $s3, $0, finish
    stagePrint:
        # oyuncunun skoruna göre şekli yazdıracak fonksiyonu çağırır
        addi $sp, $sp, -4
        sw $ra, 0($sp)

        beq $s0, 0, printZero
        beq $s0, 1, printOne
        beq $s0, 2, printTwo
        beq $s0, 3, printThree
        beq $s0, 4, printFour
        beq $s0, 5, printFive
        beq $s0, 6, printSix
    stagePrintEnd:
        lw $ra, 0($sp)
        addi $sp, $sp, 4
        jr $ra
    printZero:
        la $a0, stageZero
        jal print
        j stagePrintEnd
    printOne:
        la $a0, stageOne
        jal print
        j stagePrintEnd
    printTwo:
        la $a0, stageTwo
        jal print
        j stagePrintEnd
    printThree:
        la $a0, stageThree
        jal print
        j stagePrintEnd
    printFour:
        la $a0, stageFour
        jal print
        j stagePrintEnd
    printFive:
        la $a0, stageFive
        jal print
        j stagePrintEnd
    printSix:
        la $a0, stageSix
        jal print
        j stagePrintEnd

    chooseWord:
        # argüman olarak integer değer alır
        # integer değere göre kelimeyi belirler
        addi $sp, $sp, -4
        sw $ra, 0($sp)
        beq $a0, 1, wordOne
        beq $a0, 2, wordTwo
        beq $a0, 3, wordThree
        beq $a0, 4, wordFour
        beq $a0, 5, wordFive
        beq $a0, 6, wordSix
        
    wordOne:
        la $s1, word1
        lw $ra, 0($sp)
        addi $sp, $sp, 4
        jr $ra
    wordTwo:
        la $s1, word2
        lw $ra, 0($sp)
        addi $sp, $sp, 4
        jr $ra
    wordThree:
        la $s1, word3
        lw $ra, 0($sp)
        addi $sp, $sp, 4
        jr $ra
    wordFour:
        la $s1, word4
        lw $ra, 0($sp)
        addi $sp, $sp, 4
        jr $ra
    wordFive:
        la $s1, word5
        lw $ra, 0($sp)
        addi $sp, $sp, 4
        jr $ra
    wordSix:
        la $s1, word6
        lw $ra, 0($sp)
        addi $sp, $sp, 4
        jr $ra

    strlen:
        # argüman olarak kelimeyi alır
        # kelimenin uzunluğunu hesaplar ve geri döndürür
        addi $sp, $sp, -4      
        sw $a0, 0($sp)
        li $v0, 0 
        loop:
            lb $t1, 0($a0) 
            beqz $t1, exit
            addi $a0, $a0, 1 
            addi $v0, $v0, 1 
            j loop 
        exit:
            lw $a0, 0($sp) 
            addi $sp, $sp, 4
            jr $ra

    getInputInt:
        # kullanıcıdan integer inputu alan ve geri döndüren fonksiyon
        addi $sp, $sp, -4
        sw $ra, 0($sp)

        li $v0, 5
        syscall

        lw $ra, 0($sp)
        addi $sp, $sp, 4
        jr $ra
        

    getInputChar:
        # kullanıcıdan karakter inputu alan ve geri döndüren fonksiyon
        addi $sp, $sp, -4
        sw $ra, 0($sp)

        addi $v0, $0, 12
        syscall

        lw $ra, 0($sp)
        addi $sp, $sp, 4
        jr $ra
        
    print:
        # kullanıcıya string yazdıran fonksiyon
        addi $sp, $sp, -4
        sw $ra, 0($sp)

        addi $v0, $0, 4
        syscall

        lw $ra, 0($sp)
        addi $sp, $sp, 4
        jr $ra

    printInt:
        # kullanıcıya integer yazdıran fonksiyon
        addi $sp, $sp, -4
        sw $ra, 0($sp)

        addi $v0, $0, 1
        syscall

        lw $ra, 0($sp)
        addi $sp, $sp, 4
        jr $ra
    finish:
        la $a0, gameOver
        jal print

        li $v0,10
        syscall