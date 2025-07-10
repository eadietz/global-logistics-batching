
import os
import re
from clingo import Number, Function, String
import clingo
import shutil
from clingo.control import Control
from clingo.backend import Observer
import pandas as pd

all_data_frames = {}
hiddenFiles = re.compile('/\.')

class MyObserver(Observer):
    def __init__(self):
        self.number_rules = 0
        self.number_choice_rules = 0
        self.list_of_rules = []

    def start(self):
        self.number_rules = 0

    def rule(self, choice, head, body):
        self.list_of_rules.append([choice, head, body])
        if choice:
            self.number_choice_rules += 1
        self.number_rules += 1

def emptyFolder(folder):
    #print(f"Creating emtpy folder: '{folder}' ")
    try:
        shutil.rmtree(folder)
    except:
        pass
    finally:
        os.mkdir(folder)

def printModel(m: clingo.Model):
    print(m)

def get_artifacts(type: str):
    return filter(lambda x: (hiddenFiles.search(x) is None),
                  list(map(lambda x: './' + type + '/' + x, os.listdir('./' + type))))

#def get_artifacts(type: str):
#    return list(map(lambda x: './' + type + '/' + x, os.listdir('./' + type)))

