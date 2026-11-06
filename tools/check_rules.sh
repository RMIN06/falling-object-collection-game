#!/bin/bash
# Checks the assembly file for things the course book does not cover
# or that the 8088 cannot run. Run it before every commit.
# usage: bash tools/check_rules.sh [file]

f="${1:-src/game.asm}"
fail=0

# strip comments so words inside comments do not trigger anything
clean=$(sed -E 's/;.*//' "$f")

check_fail () {   # $1 = message, $2 = regex
    hits=$(echo "$clean" | grep -n -i -E "$2")
    if [ -n "$hits" ]; then
        echo "FAIL  $1"
        echo "$hits" | sed 's/^/        line /'
        fail=1
    fi
}

check_warn () {   # $1 = message, $2 = regex
    hits=$(echo "$clean" | grep -n -i -E "$2")
    if [ -n "$hits" ]; then
        echo "WARN  $1 (ask the student before keeping it)"
        echo "$hits" | sed 's/^/        line /'
    fi
}

check_fail "80186+ instruction (not on the 8088)" '\b(pusha|popa|imul|movzx|movsx|bound|enter|leave|insb|insw|outsb|outsw)\b'
check_fail "32-bit register (only for the protected mode chapter)" '\be(ax|bx|cx|dx|si|di|bp|sp)\b'
check_fail "push with a number (8088 cannot push an immediate)" '\bpush\s+(word\s+)?(0x[0-9a-f]+|[0-9]+)\s*$'
# shift or rotate by a number: allowed only when the number is exactly 1
check_fail "shift or rotate by a number other than 1 (load the count in cl)" '\b(shl|shr|sal|sar|rol|ror|rcl|rcr)\s+[a-z]+\s*,\s*(0x[0-9a-f]+|[02-9]|[1-9][0-9]+)\s*$'
check_fail "directive not in the book (equ, macros, includes, MASM style)" '(^|\s)(equ|%macro|%define|%include|%assign|struc|proc|endp|\.model|\.data|\.code|assume)\b'
check_warn "instruction not used in the book" '\b(lea|neg|not|cwd|cbw|sar|sal|xlat|loopz|loopnz|loope|loopne)\b'

if [ $fail -eq 0 ]; then
    echo "OK    nothing outside the book found in $f"
fi
exit $fail
