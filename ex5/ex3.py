import psycopg2
from shapely import wkb
import matplotlib.pyplot as plt
import matplotlib.cm as cm
import matplotlib.colors as mcolors
import contextily as ctx
from shapely.ops import transform
from pyproj import Transformer


conn = psycopg2.connect(
    dbname="aut2021",
    user="postgres",
    password="12345",
    host="localhost",
    port="5432",
)

query = """
    SELECT geom AS geom_wkb, LOG(COUNT(*) + 1) AS log_count
    FROM taxi_services
    CROSS JOIN cont_freguesias
    WHERE ST_Within(final_point_proj, geom)
    AND distrito_ilha = 'Porto'
    GROUP BY geom
"""

cur = conn.cursor()
cur.execute(query)
rows = cur.fetchall()
cur.close()
conn.close()

geoms = [wkb.loads(row[0]) for row in rows]
log_counts = [float(row[1]) for row in rows]

to_3857 = Transformer.from_crs(3763, 3857, always_xy=True).transform

norm = mcolors.Normalize(min(log_counts), max(log_counts))
cmap = cm.get_cmap("YlOrRd")

fig, ax = plt.subplots(figsize=(10, 6))

for geom, value in zip(geoms, log_counts):
    color = cmap(norm(value))
    g = transform(to_3857, geom)
    if g.geom_type == "Polygon":
        x, y = g.exterior.xy
        ax.fill(x, y, alpha=0.75, edgecolor="black", facecolor=color, linewidth=0.4)
    elif g.geom_type == "MultiPolygon":
        for poly in g.geoms:
            x, y = poly.exterior.xy
            ax.fill(x, y, alpha=0.75, edgecolor="black", facecolor=color, linewidth=0.4)

ctx.add_basemap(ax, source=ctx.providers.CartoDB.Positron, alpha=0.8)

ax.set_title("Taxi drop-offs per parish in Porto district")
ax.set_xlabel("X")
ax.set_ylabel("Y")
ax.set_aspect("equal")
ax.grid(False)

sm = cm.ScalarMappable(norm=norm, cmap=cmap)
sm.set_array([])
plt.colorbar(sm, ax=ax, label="log(count + 1)")

plt.tight_layout()
plt.show()
