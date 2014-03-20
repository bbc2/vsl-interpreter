#!/usr/bin/env python

import os
import logging
import subprocess
from colorama import init, Fore, Style

INTERPRETER = './interpreter.native'
TEST_DIR = 'tests/'
OUT = {
    '00_print.vsl': 'Hello 17',
    '01_op.vsl': '5',
    '02_var.vsl': '17',
    '03_array.vsl': '17,42',
}

def red(msg):
    return '{}{}{}{}{}'.format(Fore.RED, Style.BRIGHT, msg, Style.NORMAL, Fore.RESET)

def green(msg):
    return '{}{}{}{}{}'.format(Fore.GREEN, Style.BRIGHT, msg, Style.NORMAL, Fore.RESET)

def test(interpreter, filename, expected_out):
    out = subprocess.check_output([interpreter, filename]).decode()
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
            test(INTERPRETER, os.path.join(TEST_DIR, filename), OUT[filename])
        except KeyError:
            print('Not processed: {}'.format(filename))
