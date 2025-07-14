import json

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

    file_out.write("% ----------------------- locations -----------------------")
    file_out.write("\n")

    with open(f"./airbus/datalocal/locations.json", 'r') as filehandle:
        json_data = json.load(filehandle)
        locations = list(map(lambda x: f"location({reformulate(x.get('name'))}).\n", json_data))

        names_for_mapping = list(map(lambda x: reformulate(x.get('name')), json_data))        
        ids_for_mapping = list(map(lambda x: x.get('id'), json_data))

        location_name_id_mapping = dict(zip(ids_for_mapping,names_for_mapping))


    file_out.writelines(locations)

def write_tr_infos(file_out):
    global tr_name_id_mapping, tr_id_cost_mapping
    file_out.write("\n")
    file_out.write("% ----------------------- transport resources")
    with open(f"./airbus/datalocal/transportResources.json", 'r') as filehandle:
        json_data = json.load(filehandle)
        names = list(map(lambda x: f"transportResource({reformulate(x.get('name'))}).\n", json_data))
        co2 = list(map(lambda x: f"transportCO2({reformulate(x.get('name'))},{max([1,int(reformulate(int(x.get('co2Emissions'))))])}).\n",json_data))
        costs = list(map(lambda x: f"transportCost({reformulate(x.get('name'))},{max([1,int(reformulate(int(x.get('recurringCost'))))])}).\n", json_data))
        
        names_for_mapping = list(map(lambda x: reformulate(x.get('name')), json_data))        
        ids_for_mapping = list(map(lambda x: x.get('id'), json_data))

        tr_name_id_mapping = dict(zip(ids_for_mapping,names_for_mapping))

        costs_for_mapping = list(map(lambda x: x.get('recurringCost'), json_data))

        tr_id_cost_mapping = dict(zip(ids_for_mapping,costs_for_mapping))

    file_out.writelines(names)
    file_out.write("\n")
    file_out.writelines(co2)
    file_out.write("\n")
    file_out.writelines(costs)
    file_out.write("\n")

    with open(f"./airbus/datalocal/extraData.json", 'r') as filehandle:
        # ommiting the container
        json_data = json.load(filehandle).get("transportResources")
        capacities = list(map(lambda x: f"transportCapacity({reformulate(json_data.get(x)['name'])},{int(reformulate(json_data.get(x)['capacity']))}).\n", json_data.keys()))
    file_out.writelines(capacities)

def write_part_infos(file_out):
    global tr_name_id_mapping, part_name_id_mapping

    file_out.write("\n")
    file_out.write("% ----------------------- parts")
    with open(f"./airbus/datalocal/products.json", 'r') as filehandle:
        json_data = json.load(filehandle)
        names = list(map(lambda x: f"part({reformulate(x.get('name'))}).\n", json_data))
        sizes = list(map(lambda x: f"partSize({reformulate(x.get('name'))},{reformulate(x.get('length'))}).\n", json_data))

        parts_tr = ""
        for item in json_data:
            name = reformulate(item.get("name"))
            for tr in item.get("transportResources"):
                 parts_tr += f"partTR({name},{tr_name_id_mapping.get(str(tr))}).\n"

        names_for_mapping = list(map(lambda x: reformulate(x.get('name')), json_data))        
        ids_for_mapping = list(map(lambda x: x.get('id'), json_data))

        part_name_id_mapping = dict(zip(ids_for_mapping,names_for_mapping))

    file_out.writelines(names)
    file_out.write("\n")
    file_out.writelines(sizes)
    file_out.write("\n")
    file_out.writelines(parts_tr)
    file_out.write("\n")

def write_demand_offer(file_out):
    global part_name_id_mapping, location_name_id_mapping
    file_out.write("\n")
    file_out.write("% ----------------------- demand and offers ")
    with open(f"./airbus/datalocal/recipeAllocations.json", 'r') as filehandle:
        json_data = json.load(filehandle)

        demands = []
        offers = []

        demand_sum = 0
        offers_sum = 0

        for part in json_data:
            product_id = part.get("productId")
            part_name = part_name_id_mapping.get(product_id)
            demand_locations = part.get("customerLocations")
            for item in demand_locations:
                location_id = item.get("locationId")
                location_name = location_name_id_mapping.get(location_id)
                rate = item.get("rate")
                demands.append(f"demand({part_name},{location_name},{rate}).\n")
                demand_sum += rate
 
            offer_locations = part.get("supplierLocations")
            for item in offer_locations:
                location_name = location_name_id_mapping.get(item.get("locationId"))
                rate = item.get("rate")
                offers.append(f"demand({part_name},{location_name},{rate}).\n")
                offers_sum += rate

        print("dem/ off", demand_sum, offers_sum)
        file_out.writelines(demands)
        file_out.write("\n")
        file_out.writelines(offers)

def write_routes(file_out):
    global tr_name_id_mapping, location_name_id_mapping, tr_id_cost_mapping

    file_out.write("\n")
    file_out.write("% ----------------------- routest ")
    with open(f"./airbus/datalocal/transportRoutes.json", 'r') as filehandle:
        json_data = json.load(filehandle)
        routes = []
        for route in json_data:
            source = location_name_id_mapping.get(route.get("sourceId"))
            destination = location_name_id_mapping.get(route.get("destinationId"))
            for tr in route.get("transportResources"):
                tr_id = tr.get("transportResourceId")
                tr_name = tr_name_id_mapping.get(tr_id)
                distance = int(tr.get("distance"))
                costs = int(tr_id_cost_mapping.get(tr_id) * distance)
                routes.append(f"route({source},{destination},{tr_name},{distance},{costs}).\n")


        file_out.writelines(routes)

with open(f"./lps/airbus-facts.lp", 'w') as file_out:
    write_locations(file_out)
    write_tr_infos(file_out)
    write_part_infos(file_out)
    write_demand_offer(file_out)
    write_routes(file_out)