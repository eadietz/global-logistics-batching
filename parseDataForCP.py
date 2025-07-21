import json
import re 

location_name_id_mapping = {}
tr_name_id_mapping = {}
part_name_id_mapping = {}
tr_id_cost_mapping = {}

def reformulate(text):

    temp_text = str(text)
    temp_text = temp_text.replace(".","")
    temp_text = temp_text.replace("-","")
    temp_text = temp_text.replace(" ","")
    return temp_text[0].lower() + temp_text[1:]


def write_locations(file_out):
    global location_name_id_mapping
    indent = "  "
    with open(f"./airbus/datalocal/locations.json", 'r') as filehandle:
        json_data = json.load(filehandle)

        location_names = [reformulate(x.get('name')) for x in json_data]

        names_for_mapping = list(map(lambda x: reformulate(x.get('name')), json_data))        
        ids_for_mapping = list(map(lambda x: x.get('id'), json_data))

        location_name_id_mapping = dict(zip(ids_for_mapping,names_for_mapping))

    locations_list = []
    net_supply = []
    for idx, name in enumerate(location_names):
        locations_list.append(f"{indent}{name} = Location(id='{name}', net_supply={name}_net_supply)")
    


    file_out.writelines(net_supply)
    file_out.write("\n\n")
    locations = "\n".join(locations_list)
    file_out.writelines(locations)
    file_out.write("\n\n")
    file_out.write(f"{indent}locations_list = {location_names}")
    file_out.write("\n\n")
    file_out.write(f'{indent}# Helper to map location IDs to Location objects')
    file_out.write(indent + "loc_map = {loc.id: loc for loc in locations_list}")
    file_out.write("\n\n")

def write_tr_infos(file_out):
    global tr_name_id_mapping
    indent = '  '
    file_out.write(f"{indent}# --- 1. Define TransportType Instances --- \n")
    with open(f"./airbus/datalocal/transportResources.json", 'r') as filehandle:
        json_data = json.load(filehandle)
        name_for_cp = [reformulate(x.get('name')) for x in json_data]
        cost_for_cp = [reformulate(x.get('recurringCost')) for x in json_data]
        speed_for_cp = [reformulate(x.get('speed')) for x in json_data]
        co2_for_cp = [reformulate(x.get('co2Emissions')) for x in json_data]
        cap_for_cp = [reformulate(x.get('capacity')) for x in json_data]


        names_for_mapping = list(map(lambda x: reformulate(x.get('name')), json_data))        
        ids_for_mapping = list(map(lambda x: x.get('id'), json_data))

        tr_name_id_mapping = dict(zip(ids_for_mapping,names_for_mapping))

    transportTypes = []
    for idx, name in enumerate(name_for_cp):
        transportTypes.append(f"{indent}{name} = TransportType(id={name}, " \
        f"cost={cost_for_cp[idx]}, speed={speed_for_cp[idx]}, emissions={co2_for_cp[idx]}, capacity{cap_for_cp[idx]})\n")
    
    file_out.writelines(transportTypes)
    file_out.write("\n\n")
    file_out.write(f"{indent}transport_types_list = {name_for_cp}")
    file_out.write("\n\n")

def write_part_infos(file_out):
    global tr_name_id_mapping
    indent = '  '

    file_out.write("# --- 2. Define Product Instances ---\n # Valid transports are frozensets of TransportType objects")
    
    tr_dict = {}
    
    with open(f"./airbus/datalocal/products.json", 'r') as filehandle:
        json_data = json.load(filehandle)

        names = [reformulate(x.get('name')) for x in json_data]
        sizes = [reformulate(x.get('length')) for x in json_data]

        for item in json_data:
            name = reformulate(item.get("name"))
            tr_list = []
            for tr in item.get("transportResources"):
                 if tr != "None":
                    tr_list.append(tr_name_id_mapping.get((tr)))
            tr_dict[name] = tr_list
    
    productTypes = []
    for idx, name in enumerate(names):
        productTypes.append(f"{indent}{name} = Product(id={name}, " \
        f"size={sizes[idx]}, value=0, valid_transports={tr_dict.get(name)})\n")
    
    file_out.writelines(productTypes)
    file_out.write("\n\n")
    file_out.writelines(f"{indent}products_list = {names}")
    file_out.write("\n")

    
    file_out.write("# --- 3. Define Location Instances with Net Supply (Scenario 2 data) ---\n")
    file_out.write("# Initialize net_supply for each location with zeros for all products\n")
    file_out.write("# Then update based on scenario 2 demands\n")

    file_out.write("\n\n")
    file_out.writelines([indent, 'all_products_dict = {p.id: p for p in products_list}'])

def write_demand_offer(file_out):
    global part_name_id_mapping, location_name_id_mapping
    indent = '  '
    file_out.write("\n% ----------------------- demands and offers -----------------------\n")
    with open(f"./airbus/datalocal/demand_supply.lp", 'r') as filehandle:


        all_locations_supply_demand = []
        location_dict = {}
        for line in filehandle:
            if line.startswith("demandSupply"):
                start = line.find('demandSupply(')
                end = line.find(',')
                part = line[start+len('demandSupply('):end]
                location = re.findall(',(.*),', line)[0]
                nr = re.findall("\d+", line)[-1]
                if location not in location_dict:
                    location_dict[location] = {part: nr}
                else: 
                    location_dict[location].update({part: nr})

        for key in location_dict.keys():
            all_locations_supply_demand.append(f'{indent}{key}_net_supply = {location_dict[key]}\n')
            
        file_out.writelines(all_locations_supply_demand)
        file_out.write("\n")

def write_routes(file_out):
    global tr_name_id_mapping, location_name_id_mapping, tr_id_cost_mapping

    indent = '  '

    file_out.write('\n' + indent + "\ --- 4. Define TransportLink Instances (based on routes_info from CP-SAT script) ---\n")
    with open(f"./airbus/datalocal/transportRoutes.json", 'r') as filehandle:
        json_data = json.load(filehandle)
        transport_links_list = []
        for route in json_data:
            source = location_name_id_mapping.get(route.get("sourceId"))
            destination = location_name_id_mapping.get(route.get("destinationId"))
            for tr in route.get("transportResources"):
                tr_id = tr.get("transportResourceId")
                tr_name = tr_name_id_mapping.get(tr_id)
                distance = int(tr.get("distance"))
                #costs = int(tr_id_cost_mapping.get(tr_id) * distance)
                transport_links_list.append(f"TransportLink(location_{source}=loc_map['{source}'], location_{destination}=loc_map['{destination}'], distance={distance}, transport_type={tr_name})")

        transport_links = f'\n{indent}{indent}'.join(transport_links_list)
        file_out.write(f'{indent}transport_links_list = [{transport_links}]')

with open(f"./lps/factsCP.lp", 'w') as file_out:
    file_out.write('from multibatching.problem import * \n\n')
    file_out.write('def init_instance(): \n')
    write_tr_infos(file_out)
    write_part_infos(file_out)
    write_demand_offer(file_out)
    write_locations(file_out)
    write_routes(file_out)
    file_out.write('\n')
    