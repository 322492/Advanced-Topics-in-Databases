import psycopg2
import matplotlib.pyplot as plt
import numpy as np

CONN_KWARGS = dict(
    dbname="aut2021",
    user="postgres",
    password="12345",
    host="localhost",
    port="5432",
)


def fetch_speed_profile(conn, track_id: int) -> tuple[list[int], list[float]]:
    """Fetches seq and speed_kmh from track_speed_profile function."""
    with conn.cursor() as cur:
        cur.execute(
            """
            SELECT seq, speed_kmh
            FROM track_speed_profile(%s)
            ORDER BY seq
            """,
            (track_id,),
        )
        rows = cur.fetchall()
    if not rows:
        return [], []
    seqs = [int(r[0]) for r in rows]
    speeds = [float(r[1]) for r in rows]
    return seqs, speeds


def filter_gps_speed_errors(
    speeds: list[float] | np.ndarray,
    *,
    max_kmh: float = 150.0,
    median_window: int = 7,
) -> np.ndarray:
    """
    Filters out single spikes from bad GPS readings:
    - moving median smooths spikes,
    - clipping above max_kmh removes unrealistic values.
    """
    arr = np.asarray(speeds, dtype=float)
    n = len(arr)
    if n == 0:
        return arr
    w = max(3, median_window | 1)
    half = w // 2
    smoothed = np.empty_like(arr)
    for i in range(n):
        lo = max(0, i - half)
        hi = min(n, i + half + 1)
        smoothed[i] = np.median(arr[lo:hi])
    return np.clip(smoothed, 0.0, max_kmh)


def plot_instantaneous_speed(
    track_id: int,
    *,
    conn_kwargs: dict | None = None,
    show: bool = True,
) -> None:
    kw = conn_kwargs or CONN_KWARGS
    conn = psycopg2.connect(**kw)
    try:
        _seqs, speeds = fetch_speed_profile(conn, track_id)
        speeds_clean = filter_gps_speed_errors(speeds)
        x = np.arange(len(speeds_clean))

        fig, ax = plt.subplots(figsize=(12, 5))
        ax.plot(x, speeds_clean, color="tab:blue", linewidth=0.85)
        ax.set_title(f"Instantaneous Speed of Track {track_id}")
        ax.set_xlabel("Point Index")
        ax.set_ylabel("Speed (km/h)")
        ax.grid(True, alpha=0.35)
        ax.set_xlim(left=0)
        ax.set_ylim(bottom=0)
        plt.tight_layout()
        if show:
            plt.show()
    finally:
        conn.close()


if __name__ == "__main__":
    plot_instantaneous_speed(3594)
