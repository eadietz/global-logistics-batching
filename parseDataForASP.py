import json

location_name_id_mapping = {}
tr_name_id_mapping = {}
part_name_id_mapping = {}
tr_id_cost_mapping = {}

folder = 'airbus'
file_name = 'config-local' # 'oneheart-kerosene-aircraft' #'config-local.json' # 
input_file = f'{file_name}.json'

cap_size_divde = 1000000000

# only used for text and not 
def reformulate(text):

    temp_text = str(text)
    temp_text = temp_text.replace(".","")
    temp_text = temp_text.replace("-","")
    temp_text = temp_text.replace(" ","")
    return temp_text[0].lower() + temp_text[1:]

def json2asp(file_out):

    with open(f"./{folder}/{input_file}", 'r') as filehandle:
        json_data = json.load(filehandle)
        locations_data = json_data["locations"]
        locations = list(map(lambda x: f"location({reformulate(locations_data.get(x)['name'])}).\n", locations_data))

        file_out.write("% ----------------------- locations -----------------------\n")
        file_out.writelines(locations)

        names_for_mapping = list(map(lambda x: f"{reformulate(locations_data.get(x)['name'])}", locations_data))    
        ids_for_mapping =  list(map(lambda x: str(x), locations_data))
        location_name_id_mapping = dict(zip(ids_for_mapping,names_for_mapping))
        
        transportation_data = json_data["transportResources"]
        names = list(map(lambda x: f"transportResource({reformulate(transportation_data.get(x)['name'])}).\n", transportation_data))
        co2 = list(map(lambda x: f"transportCO2({reformulate(transportation_data.get(x)['name'])},{max([1,int(reformulate(int(transportation_data.get(x)['co2Emissions'])))])}).\n",transportation_data))
        costs = list(map(lambda x: f"transportCost({reformulate(transportation_data.get(x)['name'])},{max([1,int(reformulate(int(transportation_data.get(x)['cost'])))])}).\n", transportation_data))
        capacities = list(map(lambda x: f"transportCapacity({reformulate(transportation_data.get(x)['name'])},{max([1,int(int(reformulate(int(transportation_data.get(x)['capacity'])))/cap_size_divde)])}).\n", transportation_data))
        speeds = list(map(lambda x: f"transportSpeed({reformulate(transportation_data.get(x)['name'])},{max([1,int(reformulate(int(transportation_data.get(x)['speed'])))])}).\n", transportation_data))

        file_out.write("\n% ----------------------- transport resources -----------------------\n")
        file_out.writelines(names)
        file_out.write("\n")
        file_out.writelines(co2)
        file_out.write("\n")
        file_out.writelines(costs)
        file_out.write("\n")
        file_out.writelines(capacities)
        file_out.write("\n")
        file_out.writelines(speeds)
        file_out.write("\n")
        file_out.write("\n")

        names_for_mapping = list(map(lambda x: reformulate(transportation_data.get(x)['name']), transportation_data))        
        ids_for_mapping = list(map(lambda x: x, transportation_data))
        tr_name_id_mapping = dict(zip(ids_for_mapping,names_for_mapping))
        costs_for_mapping = list(map(lambda x: max([1,int(reformulate(int(transportation_data.get(x)['cost'])))]), transportation_data))
        tr_id_cost_mapping = dict(zip(ids_for_mapping,costs_for_mapping))

        routes_data = json_data["routes"]
        routes = []

        for route in routes_data:
            route_dict = routes_data.get(route)
            source = location_name_id_mapping.get(route_dict["from"])
            destination = location_name_id_mapping.get(route_dict["to"])
            for tr_id in route_dict.get("transportResources"):
                tr_dict = route_dict.get("transportResources").get(tr_id)
                tr_name = tr_name_id_mapping.get(tr_id)
                distance = int(tr_dict["distance"])
                costs = int(tr_id_cost_mapping.get(tr_id) * distance)
                routes.append(f"route({source},{destination},{tr_name},{distance},{costs}).\n")

    
        file_out.write("\n% ----------------------- routes -----------------------\n")
        file_out.writelines(routes)


        parts_data = json_data["products"]
        names = list(map(lambda x: f"part({reformulate(parts_data.get(x).get('name'))}).\n", parts_data))
        sizes = list(map(lambda x: f"partSize({reformulate(parts_data.get(x).get('name'))},{int(int(reformulate(parts_data.get(x).get('size')))/cap_size_divde)}).\n", parts_data))
        
        parts_tr = ""
        for part in parts_data:
            part_dict = parts_data.get(part)
            name = reformulate(part_dict.get("name"))
            for tr in part_dict.get("validTR"):
                 parts_tr += f"partTR({name},{tr_name_id_mapping.get(str(tr))}).\n"

        file_out.write("\n% ----------------------- parts -----------------------\n")
        file_out.writelines(names)
        file_out.write("\n")
        file_out.writelines(sizes)
        file_out.write("\n")
        file_out.writelines(parts_tr)
        file_out.write("\n")

        names_for_mapping = list(map(lambda x: reformulate(parts_data.get(x).get('name')), parts_data))        
        ids_for_mapping = list(map(lambda x: x, parts_data))

        part_name_id_mapping = dict(zip(ids_for_mapping,names_for_mapping))


        for part in parts_data:
            part_dict = parts_data.get(part)
            part_name = reformulate(parts_data.get(part).get("name"))
            supply_demand_dict = part_dict.get("netSupplyDemand")
            demandOffers = list(map(lambda x: f"demandOffer({part_name},{location_name_id_mapping.get(x)},{supply_demand_dict.get(x)}).\n", supply_demand_dict))
            check_on_balance =  list(map(lambda x: supply_demand_dict.get(x), supply_demand_dict))
            #print("check_on_balance", part_name, sum(check_on_balance))

            file_out.writelines(demandOffers)
            file_out.write("\n")


with open(f"./lps/airbus/factsASP.lp", 'w') as file_out:
    json2asp(file_out)
    file_out.write("% ----------------------- harbors -----------------------\n")
    file_out.write("harbor(naplesHarbor;marseilleHarbor;montoirHarbor;tunisHarbor;mobileHarbor;dunkerqueHarbor;gruenendeichHarbor;taichungHarbor;shanghaiHarbor;hamburgHarbor;gibraltarHarbor;portoHarbor;tianjinHarbor;casablancaHarbor;sacheonHarbor;stNazaire;houstonHarbor;savannaHarbor).")
    