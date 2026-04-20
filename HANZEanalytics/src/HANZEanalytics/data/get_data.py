from pathlib import Path
import yaml
from HANZEanalytics.data.utils import download_from_url

root = Path.cwd()
data_folder = Path(root, "data")
docs_folder = Path(root, "docs")
docs_folder.mkdir(exist_ok=True, parents=True)
data_folder.mkdir(exist_ok=True, parents=True)
with Path(root, "conf", "data").with_suffix(".yaml").open("r") as configfile:
    conf = yaml.safe_load(configfile)

# TODO: trafo for function that maked data_folder default arg
download_from_url(conf["HANZE_events"], destination_folder=data_folder, filename="events")
download_from_url(conf["HANZE_floods_regions_2010"], data_folder, "flood_regions_2010")
download_from_url(conf["HANZE_floods_regions_2021"], data_folder, "flood_regions_2021")
download_from_url(conf["S1_countries_codes_and_names"], data_folder, "s1_countries")
download_from_url(conf["S4_list_of_all_currencies_by_country"], data_folder, "s4_currencies")
download_from_url(conf["HANZE_references"], data_folder, "hanze_ref")


