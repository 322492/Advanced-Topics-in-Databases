import psycopg2
from shapely import wkb
import matplotlib.pyplot as plt

conn = psycopg2.connect(
    dbname="aut2021",
    user="postgres",
    password="12345",
    host="localhost",
    port="5432",
)

query = """
    WITH base AS (
        SELECT ST_Union(geom) AS geom
        FROM cont_freguesias
        WHERE distrito_ilha = 'Porto'
    )
    SELECT
        geom,
        ST_NPoints(geom) AS points,
        ST_Simplify(geom, 50) AS geom50,
        ST_NPoints(ST_Simplify(geom, 50)) AS points50,
        ST_Simplify(geom, 500) AS geom500,
        ST_NPoints(ST_Simplify(geom, 500)) AS points500,
        ST_Simplify(geom, 5000) AS geom5000,
        ST_NPoints(ST_Simplify(geom, 5000)) AS points5000
    FROM base;
"""

cur = conn.cursor()
cur.execute(query)
row = cur.fetchone()
cur.close()
conn.close()

variants = [
    (wkb.loads(row[0]), row[1], "no tolerance"),
    (wkb.loads(row[2]), row[3], "tolerance 50 m"),
    (wkb.loads(row[4]), row[5], "tolerance 500 m"),
    (wkb.loads(row[6]), row[7], "tolerance 5000 m"),
]

def plot_geom(ax, geom, facecolor="black", edgecolor="black", alpha=0.5):
    x, y = geom.exterior.xy
    ax.fill(x, y, alpha=alpha, edgecolor=edgecolor, facecolor=facecolor)

fig, axes = plt.subplots(2, 2, figsize=(12, 10))
fig.suptitle("district of Porto", fontsize=14)

for ax, (geom, n_pts, title) in zip(axes.flat, variants):
    plot_geom(ax, geom)
    c = geom.centroid
    ax.text(
        c.x,
        c.y,
        str(n_pts),
        ha="center",
        va="center",
        fontsize=18,
        color="cyan",
        fontweight="bold",
    )
    ax.set_title(title)
    ax.set_xlabel("X")
    ax.set_ylabel("Y")
    ax.grid(True)
    ax.set_aspect("equal")

plt.tight_layout()
plt.show()
