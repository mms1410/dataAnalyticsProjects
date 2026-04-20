from matplotlib import pyplot as plt
import cartopy.crs as ccrs
import cartopy.feature as cfeature
from pathlib import Path

root = Path(__file__).resolve().parents[3]

def get_europe_canvas(ax = None, figsize = (18,22)):

    EXTENT       = [-11, 35, 34, 72]
    LAEA  = ccrs.LambertAzimuthalEqualArea(central_longitude=10, central_latitude=52) # Projection
    OCEANCOLOR   = "#d6e8f5"
    LANDCOLOR    = "#f0ede8"
    COASTCOLOR   = "#888880"
    BORDERCOLOR  = "#aaaaaa"
    WGS84 = ccrs.PlateCarree()

    if ax is None:
        _, ax = plt.subplots(figsize=figsize, subplot_kw={"projection": LAEA})

    ax.set_extent(EXTENT, crs=WGS84)
    ax.add_feature(cfeature.OCEAN.with_scale("50m"),     color=OCEANCOLOR,  zorder=0)
    ax.add_feature(cfeature.LAND.with_scale("50m"),      color=LANDCOLOR,   zorder=1)
    ax.add_feature(cfeature.COASTLINE.with_scale("50m"), linewidth=0.5,
                       edgecolor=COASTCOLOR,  zorder=2)
    ax.add_feature(cfeature.BORDERS.with_scale("50m"),   linewidth=0.4,
                       edgecolor=BORDERCOLOR, zorder=2)

    # return axis and coordinate reference system
    return ax, WGS84


def save_fig(filename:str, destination:Path = Path(root, "assets", "plots"),dpi = 300, **kwargs) -> None:
    destination.mkdir(parents=True, exist_ok=True)
    plt.savefig(Path(destination, filename).with_suffix(".png"),dpi = dpi, **kwargs)