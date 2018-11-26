#!/usr/bin/python
#-*- coding: utf-8 -*-
#TempTest
from __future__ import division
from sklearn import cross_validation, svm
from sklearn.metrics import mean_absolute_error,accuracy_score
import numpy as np
import pandas as pd
import re
import random
from sympy import *
import re


def main():
    matchSource = open(r'D:\Desktop\music.txt', 'r')
    origSource = open(r'D:\Desktop\origmusic.txt', 'r')
    writeSource = open(r'D:\Desktop\writemusic.txt', 'wb')
    match = matchSource.read()
    orig = origSource.readlines()
    for i in range(len(orig)):
        if(re.match('^[0-9]+$',orig[i].strip(" "))):
            if ("MV" in orig[i + 1]):
                line = orig[i + 1][:-3]
            else:
                line = orig[i + 1]
            if(line not in match):
                writeSource.write(line + "\n")
        print(i)
    return


if(__name__=='__main__'):
    main()
