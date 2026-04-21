from matplotlib import pyplot as plt
import cartopy.crs as ccrs
import cartopy.feature as cfeature
from pathlib import Path
from PIL import Image
import numpy as np


root = Path(__file__).resolve().parents[3]
dest_plots = Path(root, "assets", "plots")
dest_gifs = Path(root, "assets")


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


    ax.add_feature(cfeature.OCEAN.with_scale("50m"),     color=OCEANCOLOR,  zorder=0)
    ax.add_feature(cfeature.LAND.with_scale("50m"),      color=LANDCOLOR,   zorder=1)
    ax.add_feature(cfeature.COASTLINE.with_scale("50m"), linewidth=0.5,
                       edgecolor=COASTCOLOR,  zorder=2)
    ax.add_feature(cfeature.BORDERS.with_scale("50m"),   linewidth=0.4,
                       edgecolor=BORDERCOLOR, zorder=2)

    ax.set_extent(EXTENT, crs=WGS84)
    ax.set_autoscale_on(False)
    ax.set_aspect("auto")

# also return crs for later use of axis
    return ax, WGS84


def save_fig(filename:str, destination:Path = dest_plots ,dpi = 300, **kwargs) -> None:
    destination.mkdir(parents=True, exist_ok=True)
    plt.savefig(Path(destination, filename).with_suffix(".png"),dpi = dpi, **kwargs)


def area_to_gif(regions, years, cummulative:bool = False, title:str = None):

    frames = []

    fig, ax = plt.subplots(subplot_kw={"projection": ccrs.PlateCarree()})
    ax, crs = get_europe_canvas(ax)


    for year in years:
        data = regions[regions["Year"] == year].to_crs(epsg=4326)

        if not cummulative:
            ax.clear()
            ax, crs = get_europe_canvas(ax)

        data.plot(
            ax=ax,
            color="red",
            alpha=0.2,   # key: low transparency
            zorder=4,
            transform=ccrs.PlateCarree()
        )

        if title is not None:
            ax.set_title(title)

        fig.canvas.draw()
        frame = Image.fromarray(np.asarray(fig.canvas.buffer_rgba())).copy()
        frames.append(frame)

    return frames