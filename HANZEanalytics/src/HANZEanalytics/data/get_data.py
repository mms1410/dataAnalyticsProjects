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

for name, url in conf["data"].items():
    download_from_url(url, data_folder, name)


