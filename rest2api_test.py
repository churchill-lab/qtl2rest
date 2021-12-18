import random
import re
import sys

import requests
import httpx

MAIN = "/datasets"

ENDPOINTS = [
    {
        "id": "lodpeaks",
        "url": "/lodpeaks?dataset={dataset_id}",
        "pheno": True
    }, {
        "id": "rankings",
        "url": "/rankings?dataset={dataset_id}",
        "pheno": False 
    }, {
        "id": "lodscan",
        "url": "/lodscan?dataset={dataset_id}&id={annot_id}",
        "pheno": True
    }, {
        "id": "lodscan_covar",
        "url": "/lodscan?dataset={dataset_id}&id={annot_id}&intcovar={intcovar}",
        "pheno": True
    }, {
        "id": "lodscanbysample",
        "url": "/lodscansamples?dataset={dataset_id}&id={annot_id}&chrom={chrom}&intcovar={intcovar}",
        "pheno": True
    }, {
        "id": "foundercoefs",
        "url": "/foundercoefs?dataset={dataset_id}&id={annot_id}&chrom={chrom}&intcovar={intcovar}",
        "pheno": True
    }, {
        "id": "foundercoefs_covar",
        "url": "/foundercoefs?dataset={dataset_id}&id={annot_id}&chrom={chrom}&intcovar={intcovar}",
        "pheno": True
    }, {
        "id": "expression",
        "url": "/expression?dataset={dataset_id}&id={annot_id}",
        "pheno": True
    }, {
        "id": "mediate",
        "url": "/mediate?dataset={dataset_id}&id={annot_id}&marker_id={marker_id}",
        "pheno": False
    }, {
        "id": "mediate_against",
        "url": "/mediate?dataset={dataset_id}&id={annot_id}&marker_id={marker_id}&dataset_mediate={dataset_id_mediate}",
        "pheno": False
    }, {
        "id": "snpassoc",
        "url": "/snpassoc?dataset={dataset_id}&id={annot_id}&chrom={chrom}&location={location}",
        "pheno": True
    }, {
        "id": "snpassoc_covar",
        "url": "/snpassoc?dataset={dataset_id}&id={annot_id}&chrom={chrom}&location={location}&intcovar={intcovar}",
        "pheno": True
    }, {
        "id": "correlation",
        "url": "/correlation?dataset={dataset_id}&id={annot_id}",
        "pheno": True
    }, {
        "id": "correlation_against",
        "url": "/correlation?dataset={dataset_id}&id={annot_id}&dataset_correlate={dataset_id_correlate}",
        "pheno": True
    }, {
        "id": "correlation_covar",
        "url": "/correlation?dataset={dataset_id}&id={annot_id}&intcovar={intcovar}",
        "pheno": True
    }, {
        "id": "correlation_against_covar",
        "url": "/correlation?dataset={dataset_id}&id={annot_id}&intcovar={intcovar}&dataset_correlate={dataset_id_correlate}",
        "pheno": True
    }, {
        "id": "correplationplot",
        "url": "/correlation?dataset={dataset_id}&id={annot_id}&dataset_correlate={dataset_id_correlate}&id_correlate={annot_id_correlate}",
        "pheno": True
    }, {
        "id": "correplationplot_covar",
        "url": "/correlation?dataset={dataset_id}&id={annot_id}&dataset_correlate={dataset_id_correlate}&id_correlate={annot_id_correlate}&intcovar={intcovar}",
        "pheno": True
    }
]

def parse_variables(url):
    elems = re.findall(r"{\w+}", url)
    ret = {e[1:-1]: '' for e in elems}
    return ret
    
def get_random_id(dataset):
    if dataset["datatype"].lower() == "mrna":
        annots = dataset["annotations"]
        random_index = random.randint(0, len(annots) - 1)
        return annots[random_index]["gene_id"]
    elif dataset["datatype"].lower() == "protein":
        annots = dataset["annotations"]
        random_index = random.randint(0, len(annots) - 1)
        return annots[random_index]["protein_id"]
    elif dataset["datatype"][:5].lower() == "pheno":
        annots = dataset["annotations"]
        random_index = random.randint(0, len(annots) - 1)
        return annots[random_index]["data_name"]
    
def get_random_intcovar(dataset):
    covar_info = dataset["covar_info"]
    all_intcovars = []
    for covar_entry in covar_info:
        if covar_entry['interactive']:
            all_intcovars.append(covar_entry['sample_column'])
    random_index = random.randint(0, len(all_intcovars) - 1)
    return all_intcovars[random_index]

def get_random_chrom(dataset):
    return str(random.randint(1, 19))

def get_random_nonpheno(datasets):
    datasets_nonpheno = []
    for dataset_id, dataset in datasets.items():
        if dataset["datatype"].lower() == "mrna":
            datasets_nonpheno.append(dataset)
        elif dataset["datatype"].lower() == "protein":
            datasets_nonpheno.append(dataset)
    random_index = random.randint(0, len(datasets_nonpheno) - 1)
    return datasets_nonpheno[random_index]

def test_apis(base_url):
    # grab the datasets information
    datasets_req = requests.get(f'{base_url}/datasets')
    datasets_data = datasets_req.json()
    datasets_data = datasets_data['result']['datasets']

    datasets = {}

    for d in datasets_data:
        datasets[d['id']] = d

    for dataset_id, dataset in datasets.items():
        print(dataset_id, dataset['display_name'])
        annot_id = get_random_id(dataset)
        intcovar = get_random_intcovar(dataset)
        chrom = get_random_chrom(dataset)

        # find non pheno datasets, pick random
        dataset_nonpheno = get_random_nonpheno(datasets)
        dataset_id_mediate = dataset_nonpheno["id"]
        dataset_id_correlate = dataset_nonpheno["id"]
        annot_id_correlate = get_random_id(dataset_nonpheno)

        # TODO: fix hardcoding
        marker_id = "6_53071252"
        location = 53071252

        is_pheno = True if dataset["datatype"][:5].lower() == "pheno" else False

        params = {
            "dataset_id": dataset_id,
            "dataset_id_mediate": dataset_id_mediate,
            "dataset_id_correlate": dataset_id_correlate,
            "annot_id": annot_id,
            "annot_id_correlate": annot_id_correlate,
            "intcovar": intcovar,
            "chrom": chrom,
            "marker_id": marker_id,
            "location": location
        }


        for endpoint in ENDPOINTS:
            url = endpoint['url']
            variables = parse_variables(url)
            url_api = url.format(**params)
            
            print(url_api)
            if is_pheno and not endpoint["pheno"]:
                # skip non pheno urls
                continue

            api_req = requests.get(f'{base_url}{url_api}')
            if api_req.status_code != 200:
                
                try:
                    j = api_req.json()
                    msg = j["error"]
                except:
                    msg = 'Unknown'

                print(f'ERROR: {msg}')
            else:
                print('OK')





        



        


        
        
    
    


if __name__ == '__main__':
    if len(sys.argv) != 2:
        print(f'Usage: {sys.argv[0]} baseurl')
        sys.exit(1)
    
    base_url = sys.argv[1]

    # strip the last '/
    if base_url[-1] == '/':
        base_url = base_url[:-1]

    test_apis(base_url)

