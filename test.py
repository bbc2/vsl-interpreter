#!/usr/bin/env python

import os
import logging
import subprocess
from colorama import init, Fore, Style

INTERPRETER = './interpreter.native'
TEST_DIR = 'tests/'
TESTS = {
    '00_print.vsl': { 'in': '', 'out': 'Hello 17' },
    '01_op.vsl': { 'in': '', 'out': '5' },
    '02_var.vsl': { 'in' : '', 'out': '17' },
    '03_array.vsl': { 'in' : '', 'out': '17,42' },
    '04_read.vsl': { 'in' : '17\n42', 'out': '18,43' },
    '05_if.vsl': { 'in' : '', 'out': '1,0,0,0' },
    '06_while.vsl': { 'in' : '', 'out': '3,2,1,0' },
}

def red(msg):
    return '{}{}{}{}{}'.format(Fore.RED, Style.BRIGHT, msg, Style.NORMAL, Fore.RESET)

def green(msg):
    return '{}{}{}{}{}'.format(Fore.GREEN, Style.BRIGHT, msg, Style.NORMAL, Fore.RESET)

def test(interpreter, filename, input, expected_out):
    p = subprocess.Popen([interpreter, filename], stdin=subprocess.PIPE,
                         stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    (o, e) = p.communicate(input=input.encode())
    out = o.decode()
    err = e.decode()

    if err != '':
        print('{}: {}'.format(red('ERROR'), filename))
        print(red('>>> Got:'))
        print(err)
        return

    if out == expected_out:
        print('{}: {}'.format(green('PASS'), filename))
    else:
        print('{}: {}'.format(red('FAIL'), filename))
        print(green('>>> Expected:'))
        print(expected_out)
        print(red('>>> Got:'))
        print(out)

if __name__ == '__main__':
    init()
    for filename in sorted(os.listdir(TEST_DIR)):
        try:
            t = TESTS[filename]
        except KeyError:
            print('Skipped: {}'.format(filename))
        else:
            test(INTERPRETER, os.path.join(TEST_DIR, filename), t['in'], t['out'])
