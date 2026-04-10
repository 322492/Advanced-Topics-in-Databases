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
    SELECT proj_track FROM tracks_braga
"""

cur = conn.cursor()
cur.execute(query)
rows = cur.fetchall()
cur.close()
conn.close()

tracks = [wkb.loads(row[0]) for row in rows]

fig, ax = plt.subplots(figsize=(8, 8), facecolor="black")
ax.set_facecolor("black")

for track in tracks:
    x, y = track.coords.xy
    ax.plot(x, y, color="white", linewidth=0.35, alpha=0.95)

ax.set_aspect("equal")
ax.axis("off")
plt.tight_layout(pad=0)
plt.show()
