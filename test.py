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
    '07_variance.vsl': {
        'in': '5\n1\n0\n-2\n42\n7\n9\n5\n17\n0',
        'out': 't[0]? t[1]? t[2]? t[3]? t[4]? t[5]? t[6]? t[7]? t[8]? t[9]? 84,8,153',
    },
    '08_sort.vsl': {
        'in': '5\n1\n0\n-2\n42\n7\n9\n5\n17\n0',
        'out': 't[0]? t[1]? t[2]? t[3]? t[4]? t[5]? t[6]? t[7]? t[8]? t[9]? -2,0,0,1,5,5,7,9,17,42',
    },
    '10_block.vsl': { 'in': '', 'out': '2,1,3,0,1,3' },
    '11_intfun.vsl': { 'in': '', 'out': '8,625' },
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
