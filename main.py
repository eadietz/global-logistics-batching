
# coding: utf-8
import argparse
import gc
import clingo
from clingo.control import Control
from clingo.backend import Observer
import matplotlib
import pandas as pd
import networkx as nx
from datetime import datetime
import threading
import sys

import helper_functions as hf

import os
import plotly.graph_objects as go
import time
import shutil
import csv
import json
import pickle
#import compute_similarity
#import create_best_model_dataframe

#import create_best_model_dataframe

matplotlib.use('TkAgg')
import matplotlib.pyplot as plt

YELLOW = "\033[33m"
RESET = "\033[0m"  

showModel = False
showDataframes = False
foundModelIndex = 0
analyzedModelIndex = 0
all_data_frames = {}
costs = []
modelAtomTemplates = [
       {'name':'location','filter':lambda s: s.name=='location', 'columns':['location']},
      {'name':'part','filter':lambda s: s.name=='part', 'columns':['part']},
       {'name':'transportFreq', 'filter':lambda s: s.name=='transportFreq', 'columns':['from', 'to', 'TM','pidx', 'freq']},
        {'name':'packingPattern','filter':lambda s: s.name=='packingPattern', 'columns':['pidx','part', 'tm', 'amount']},
        {'name':'demandSupply','filter':lambda s: s.name=='demandSupply', 'columns':['part', 'location', 'amount']}
]



def check_correctness(modelIndex, all_data_frames):
   
    packing_pattern_df = all_data_frames["packingPattern"]
    demand_supply_df = all_data_frames["demandSupply"]
    transport_freq_df = all_data_frames["transportFreq"]
    locations_df = all_data_frames["location"]
    parts_df = all_data_frames["part"]

    for location in list(locations_df['location']):
      demand_supply_location_df = demand_supply_df.loc[demand_supply_df['location']==location]
      for part in list(parts_df['part']):
        packing_pattern_part = packing_pattern_df.loc[packing_pattern_df['part']==part]
        count_in_amount = 0
        count_out_amount = 0
        
        # count amount of this part SUPPLIED/ DEMANDED by this location
        part_supply_demand_amount = demand_supply_location_df.loc[demand_supply_location_df['part']==part, 'amount'].values 
        count_supply_demand_amount = int(str(part_supply_demand_amount[0]))
        
        # count amount of this part TO this location (incoming)
        in_idx = transport_freq_df.loc[transport_freq_df['to']==location, ('pidx', 'freq')].values

        if in_idx.any() == True:
          for (pidx,freq) in in_idx:
            part_in_amount = packing_pattern_part.loc[packing_pattern_part['pidx']==pidx, 'amount'].values
            if part_in_amount.size > 0:
              count_in_amount += int(str(part_in_amount[0])) * int(str(freq)) 
            
        # count amount of this part FROM this location (outgoing)
        out_idx = transport_freq_df.loc[transport_freq_df['from']==location,  ('pidx', 'freq')].values
        if out_idx.any() == True:
          for (pidx,freq) in out_idx:
            part_out_amount = packing_pattern_part.loc[packing_pattern_part['pidx']==pidx, 'amount'].values
            if part_out_amount.size > 0:
              count_out_amount += int(str(part_out_amount[0])) * int(str(freq)) 
        
        if not count_out_amount - count_in_amount == count_supply_demand_amount:
          print(f"+++++++++++++{modelIndex}+++++++++++++++ {location} : {part} {count_out_amount} (out) - {count_in_amount} (in) != {count_supply_demand_amount} (supply/ demand)")
      
def get_programs_by_categories(categories: list[str]):
    programs = []
    for category in categories:
        if os.path.isdir(category):
            programs += hf.get_artifacts(category)
        elif os.path.isfile(category):
            programs += [category]
        else:
            print(f"Folder or file \'{category}\' does not exist.")
    return programs

def solve_clingo(programs, max_models=1):
    global start_time_solving, produced_at_atoms, ctl
    print('Configuring Clingo ...')
    print(f'--models={max_models}')

    ctl = clingo.Control(
        ['--warn=no-atom-undefined', f'--models={max_models}', "--opt-mode=optN"])
    print(f'Configuration Keys: {ctl.configuration.solve.keys}')
    ctl.register_observer(myobs)
    myobs.start()#

    print("programs", programs)
    for program in programs:
        ctl.load(program)
    start_time_grounding = time.process_time()
    ctl.ground([("base", [])])
    print(
        f"Grounding programs: {programs} ...\n=== Grounding done ({round((time.process_time() - start_time_grounding) / 60, 2)} minutes, {myobs.number_rules} rules, {myobs.number_choice_rules} choice rules) ===")

    start_time_solving = time.process_time()

    res = ctl.solve(on_model=on_model)
    ctl.cleanup()
    return res


def processModel(symbols, modelIndex):
    global all_data_frames
    print(f"Start processing Model {modelIndex} ... ")
    print("creating template atoms ...")
    for modelAtomTemplate in modelAtomTemplates:
        showModelAtoms(symbols, modelAtomTemplate['name'], modelAtomTemplate['filter'], modelAtomTemplate['columns'],
                       modelIndex)
        
    print("check correctness ...")
    #check_correctness(modelIndex, all_data_frames)
    print(f"Done processing Model {modelIndex} ... ")


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


def on_model(m: clingo.Model):
    global start_time_solving, output_hundredth_model, foundModelIndex, analyzedModelIndex, showModel, outputfolder

    if not output_hundredth_model or foundModelIndex % 100 == 0:
        print(
            f"=== New Model [{foundModelIndex}] found after {str(round((time.process_time() - start_time_solving) / 60, 2))} minutes of solving (Optimality proven: {m.optimality_proven}) === ")
        
        hf.emptyFolder(f"./{outputfolder}/model_{analyzedModelIndex}")
        if m.optimality_proven:
            print(str(m))
            sys.exit()
        with open(f"./{outputfolder}/model_{analyzedModelIndex}/model.txt", "w") as model_file:
            model_file.write(str(m))
            path_symbols = list(filter(lambda s: s.name == 'packingPattern', m.symbols(atoms=True))) + \
                        list(filter(lambda s: s.name == 'transportFreq', m.symbols(atoms=True))) + \
                        list(filter(lambda s: s.name == 'location', m.symbols(atoms=True))) + \
                        list(filter(lambda s: s.name == 'demandSupply', m.symbols(atoms=True)))+ \
                        list(filter(lambda s: s.name == 'part', m.symbols(atoms=True)))
            print(f"Generated {len(path_symbols)} path symbols")

            processModel(path_symbols, foundModelIndex)

            #path_df = ...
            #fOMs = m.cost
            #thread = threading.Thread(target=processModel, args=(m, path_df, fOMs, analyzedModelIndex,), daemon=False)
            #thread.start()

        analyzedModelIndex += 1 

    foundModelIndex += 1

def run_asp(): 
    global output_hundredth_model, outputfolder, start_time_solving, ctl, foundModelIndex, analyzedModelIndex, costs, showModel
  
    parser = argparse.ArgumentParser(description="Runs logic-programs in sub-folders 'facts' and 'rules'.")
    parser.add_argument("-t", "--timeout", required=False, default=100, type=int, help="time out.")
    parser.add_argument("-d", "--details", required=False, default=False, help="show details on configuration.")
    
    parser.add_argument("-n", "--models", required=False, default=1,
                        help="Maximum number of models returned by the tool.")
    parser.add_argument("-o", "--outputfolder", required=False, default=f'./output-{datetime.now()}', help="The folder to put results into.")
    parser.add_argument("-m", "--showmodel", required=False, action="store_true", default=False,
                        help="Print each model entirely.")
    parser.add_argument("-df", "--showdataframes", required=False, action="store_true", default=False, help="Print each dataframe.")
    parser.add_argument("-e", "--example", required=False, action="store_true", default=False,
                        help="Considers only the logic programs in the example.")
    parser.add_argument("-s", "--output_hundredth_model", required=False, action="store_true", default=False, help="will output each 100th model")
    parser.add_argument("-hr", "--heuristics", required=False, default=False, help="Will run different heuristics combinations from heuristics folder")
    parser.add_argument("-j", "--json_file", required=False,default=0, help="reads json file with all required paramters")
    parser.add_argument("-ts", "--timestamp_on_results_folder", required=False,default=True, help="timestamp_on_results_folder")
    args = parser.parse_args()

    json_file = args.json_file


    if json_file:

        with open(json_file, 'r') as file_open:
            json_data = json.load(file_open)[0]
        timeout = json_data["timeout"]
        max_nr_models = json_data["max_nr_models"]
        showModel = json_data["show_model"]
        showDataframes = json_data["show_dataframes"]
        example = json_data["example"]
        output_hundredth_model = json_data["output_hundredth_model"]
        heuristics_runs = json_data["runs"]
        all_results_folder = f'{json_data["all_results_folder"]}'
        if json_data["timestamp_on_results_folder"]:
            all_results_folder = f'{all_results_folder}_{datetime.now()}'
    else:
        timeout = args.timeout
        max_nr_models = args.models
        showModel = args.showmodel
        showDataframes = args.showdataframes
        example = args.example
        output_hundredth_model = args.output_hundredth_model
        heuristics_runs = args.heuristics
        json_file = args.json_file
        all_results_folder = F'{args.outputfolder}'
        if args.timestamp_on_results_folder:
            all_results_folder = f'{all_results_folder}_{datetime.now()}'

    categories = ["lps/example"] if example else ["lps/rules", "lps/facts"]
   
    hf.emptyFolder(all_results_folder)
    
    if heuristics_runs:
        for heuristic_name, program_folders in heuristics_runs.items():
        
            costs = []
            print(f"{YELLOW}============================== heuristic: {heuristic_name} ============================== {RESET}") 
            outputfolder = f'{all_results_folder}/{heuristic_name}_results'
            hf.emptyFolder(outputfolder)
            categories = program_folders 
            foundModelIndex = 0
            analyzedModelIndex = 0
            solve_clingo(get_programs_by_categories(categories), timeout=timeout)
            gc.collect()  
    else:  
        print(f"{YELLOW}============================== {categories} ============================== {RESET}") 
        outputfolder = f'{all_results_folder}'
        solve_clingo(get_programs_by_categories(categories), max_nr_models)
        gc.collect()  

if __name__ == "__main__":
    myobs = hf.MyObserver()
    run_asp()