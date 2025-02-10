import argparse
import os
from symtable import Symbol
from typing import List, Sequence
from clingo import Number, Function, String
import clingo
import shutil
import urllib.request
from string import Template
import bios
import time
from datetime import datetime
from clingo.control import Control
from clingo.backend import Observer
import re
from functools import reduce
import plotly.express as px
import threading
import json
import clingodl

import pandas as pd
import random
from MyObserver import MyObserver

foundModelIndex = 0
analyzedModelIndex = 0
all_data_frames = {}
showDataframes = False

modelAtomTemplates = [
    {'name':'transport','filter':lambda s: s.name=='transport','columns':['idx','from','to','Freq', 'TR']},
]

# tr: name: {capacity, co2, cost, speed}
tr = {'tr1':{10,60,56,3},'tr2':{15,45,42,2}}

class Run():
    hiddenFiles = re.compile('/\.')
    myobs = MyObserver()
    outputfolder = './data'

    def __init__(self):
        global outputfolder
        parser = argparse.ArgumentParser(description="Runs logic-programs in sub-folders 'lps/facts' and 'lps/rules'.")

        parser.add_argument("-e", "--example", required=False, action="store_true", default=False,
                        help="Considers only the logic programs in the lps/example folder.")
        parser.add_argument("-o", "--outputfolder", required=False, default=f'./output-{datetime.now()}',
                            help="The folder to put results into.")
        parser.add_argument("-a", "--assertions", required=False, action="store_true", default=False,
                        help="Includes logic-programs contained in the sub-folder 'assertions'.")
        parser.add_argument("-n", "--models", required=False, default=10,
                            help="Maximum number of models returned by the tool.")
        parser.add_argument("-r", "--random_gen", required=False, default=0,
                        help="Perform random decisions (takes a value between 0 and 1).")
        args = parser.parse_args()

        ex = args.example
        outputfolder = args.outputfolder
        assertions = args.assertions
        models = args.models
        random_gen = args.random_gen

        emptyFolder(outputfolder)

        self.build_lp_and_solve(ex, assertions, models, random_gen)

    def build_lp_and_solve(self, ex, assertions, models, random_gen):

        categories = ["lps/example"] if ex else ["lps/rules", "lps/facts"]
        categories += ["lps/assertions"] if assertions else categories

        self.solve_clingo(self.get_programs_by_categories(categories), max_models=models, random_gen=random_gen)

    def solve_clingo(self, programs: List[str], max_models=1, random_gen=0):
        global start_time_solving, produced_at_atoms, ctl
        print('Configuring Clingo ...')
        print(f'--models={max_models}')
        seed = 1
        if random_gen:
            seed = random.randint(0, 10000)

        ctl = clingo.Control(
            ['--warn=no-atom-undefined', f'--models={max_models}', f'--rand-freq={random_gen}', f'--seed={seed}',
             "--opt-mode=optN"])
        print(f'Configuration Keys: {ctl.configuration.solve.keys}')
        ctl.register_observer(self.myobs)
        self.myobs.start()
        for program in programs:
            ctl.load(program)
        start_time_grounding = time.process_time()
        ctl.ground([("base", [])])
        print(
            f"Grounding programs: {programs} ...\n=== Grounding done ({round((time.process_time() - start_time_grounding) / 60, 2)} minutes, {self.myobs.number_rules} rules, {self.myobs.number_choice_rules} choice rules) ===")

        start_time_solving = time.process_time()

        res = ctl.solve(on_model=on_model)
        ctl.cleanup()
        return res

    def get_programs_by_categories(self, categories: List[str]):
        programs = []
        for category in categories:
            if os.path.isdir(category):
                programs += self.get_artifacts(category)
            else:
                print(f"Folder \'{category}\' does not exist.")
        return programs

    def get_artifacts(self, type: str):
        return filter(lambda x: (self.hiddenFiles.search(x) is None),
                      list(map(lambda x: './' + type + '/' + x, os.listdir('./' + type))))

def emptyFolder(folder):
    print(f"Creating emtpy folder: '{folder}' ")
    try:
        shutil.rmtree(folder)
    except:
        pass
    finally:
        os.mkdir(folder)

def on_model(m: clingo.Model):
    global foundModelIndex, analyzedModelIndex, \
        start_time_solving, produced_at_atoms, output_hundredth_model

    printModel(m)
    emptyFolder(f"./{outputfolder}/model_{analyzedModelIndex}")

    print(
        f"=== New Model [{foundModelIndex}] found after {str(round((time.process_time() - start_time_solving) / 60, 2))} minutes of solving === ")
    print("Analyzing Model ...")
    print(f"=== Optimality proven ? {m.optimality_proven} === ")

    print("creating symbols ...")
    path_symbols = list(filter(lambda s: s.name == 'transport', m.symbols(atoms=True))) + \
                   list(filter(lambda s: s.name == 'route', m.symbols(atoms=True)))+ \
                   list(filter(lambda s: s.name == 'transportResource', m.symbols(atoms=True)))
    print(f"Generated {len(path_symbols)} path symbols")

    print("creating model.txt ...")
    with open(f"./{outputfolder}/model_{analyzedModelIndex}/model.txt", "w") as model_file:
            model_file.write(str(m))

    processModel(path_symbols, analyzedModelIndex)
    analyzedModelIndex+=1


def processModel(symbols, index):
    print(f"Start processing Model {index} ... ")
    global costs

    print("creating template atoms ...")
    for modelAtomTemplate in modelAtomTemplates:
        showModelAtoms(symbols, modelAtomTemplate['name'], modelAtomTemplate['filter'], modelAtomTemplate['columns'],
                       index)

    #df = pd.read_csv(f"{outputfolder}/model_{index}/transport.csv")
    #compute_costs(df, index)

def showModelAtoms(s, dataName, symbolFilter, columns, index):
    global iD_conversion

    filteredSymbols = list(filter(symbolFilter, s))
    arguments = list(map(lambda s: s.arguments, filteredSymbols))
    df = pd.DataFrame(data=arguments, columns=columns)
    all_data_frames[dataName] = df

    df.to_csv(f"{outputfolder}/model_{index}/{dataName}.csv")
    if showDataframes:
        print(f"========================== {dataName} ==========================")
        print(df.to_string())

def printModel(m: clingo.Model):
    print(m)

def compute_costs(df, index):

    costs = df['freq'] #* df['costs']
    print(f"total costs for {index}: ", costs.sum())



Run()