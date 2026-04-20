from urllib.parse import urlparse
import os
import wget
from pathlib import Path
import geopandas as gpd
from shapely.geometry import box



def get_filetype_from_url(url: str):
    return os.path.splitext(urlparse(url).path)[1][1:]

def download_from_url(url: str, destination_folder: str, filename: str):
    filetype = get_filetype_from_url(url)
    file = Path(destination_folder, filename).with_suffix("." + filetype)
    if file.exists():
        file.unlink()
    wget.download(url, out = str(file))

def get_gisco_continental_europe(
        bbox = box(
        minx=-11,   # west  (Ireland)
        miny= 34,   # south (Greece/Cyprus)
        maxx= 35,   # east  (western Turkey border)
        maxy= 72,   # north (Norway)
    ),
    url = "https://gisco-services.ec.europa.eu/distribution/v2/nuts/geojson/NUTS_RG_20M_2021_4326.geojson") -> gpd.GeoDataFrame:

    gisco = gpd.read_file(url)
    gisco = gisco.clip(bbox)

    return gisco