#!/usr/bin/env python3
"""Gera o video de demonstracao do template (oscilador harmonico quantico).

Saida:
  videos/demo-oscilador.mp4   video H.264, 480x270, 15 fps, 5 s
  videos/demo-oscilador.png   capa (poster) extraida do video

Requisitos: python3, numpy, matplotlib e ffmpeg no PATH.

Uso:
  python3 tools/gerar-video-demo.py
"""

from __future__ import annotations

import math
from pathlib import Path

import matplotlib

matplotlib.use("Agg")

import matplotlib.pyplot as plt
import numpy as np
from matplotlib.animation import FFMpegWriter

# ---------------------------------------------------------------------
#  Paleta do tema
# ---------------------------------------------------------------------
BG = "#0A1020"
BG_ALT = "#0E1830"
FG = "#E9EFF8"
MUTED = "#8EA3C0"
CYAN = "#5BD8E8"
VIOLET = "#B49CFF"
AMBER = "#FFC46B"

ROOT = Path(__file__).resolve().parent.parent
OUT_DIR = ROOT / "videos"
MP4 = OUT_DIR / "demo-oscilador.mp4"
POSTER = OUT_DIR / "demo-oscilador.png"

WIDTH_PX, HEIGHT_PX = 480, 270
DPI = 100
FPS = 15
DURATION = 5.0
N_FRAMES = int(FPS * DURATION)


def psi(n: int, x: np.ndarray) -> np.ndarray:
    """Funcao de onda normalizada do oscilador harmonico (hbar = m = omega = 1)."""
    hermite = np.polynomial.hermite.hermval(x, [0] * n + [1])
    norm = math.sqrt(2**n * math.factorial(n) * math.sqrt(math.pi))
    return hermite * np.exp(-(x**2) / 2) / norm


def main() -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)

    x = np.linspace(-5.0, 5.0, 700)
    p0 = psi(0, x)
    p1 = psi(1, x)
    potencial = 0.5 * x**2 + 0.6  # deslocado para caber no grafico

    fig, ax = plt.subplots(figsize=(WIDTH_PX / DPI, HEIGHT_PX / DPI), dpi=DPI)
    fig.patch.set_facecolor(BG)
    ax.set_facecolor(BG)

    ax.plot(x, potencial, color=MUTED, lw=1.0, ls="--", alpha=0.65, label="V(x)")
    (onda,) = ax.plot([], [], color=CYAN, lw=2.0, label=r"Re $\psi(x,t)$")
    densidade = ax.fill_between(x, 0, np.zeros_like(x), color=VIOLET, alpha=0.28,
                                linewidth=0)

    ax.set_xlim(-5.0, 5.0)
    ax.set_ylim(-0.95, 4.3)
    ax.tick_params(colors=MUTED, labelsize=7)
    fig.subplots_adjust(left=0.055, right=0.985, top=0.855, bottom=0.135)
    for spine in ax.spines.values():
        spine.set_color("#2A3A5A")

    leg = ax.legend(loc="upper right", fontsize=7, frameon=False,
                    labelcolor=FG, ncol=1)
    leg.get_frame().set_alpha(0)

    titulo = fig.suptitle("", x=0.02, y=0.965, ha="left",
                          color=FG, fontsize=9, fontweight="bold")
    texto = fig.text(0.02, 0.035, "", color=MUTED, fontsize=7)
    fig.text(0.98, 0.035, r"$x\,/\,\sqrt{\hbar/m\omega}$",
             color=MUTED, fontsize=7, ha="right")

    writer = FFMpegWriter(fps=FPS, codec="libx264", bitrate=1400,
                          extra_args=["-pix_fmt", "yuv420p",
                                      "-movflags", "+faststart"])

    def atualizar(i: int):
        t = i / N_FRAMES  # um ciclo completo no video
        fase = np.exp(-2j * np.pi * t)

        # Superposicao dos dois primeiros niveis: a densidade "respira"
        psi_t = (p0 + p1 * fase) / math.sqrt(2.0)
        real = np.real(psi_t) * 1.9 + 1.35
        mod2 = np.abs(psi_t) ** 2

        onda.set_data(x, real)

        # Atualiza a area preenchida (curva superior + base em zero)
        altura = mod2 * 2.6
        vertices = np.vstack([
            np.column_stack([x, np.zeros_like(x)]),
            np.column_stack([x[::-1], altura[::-1]]),
        ])
        densidade.set_verts([vertices])

        titulo.set_text(r"$\psi = (\psi_0 + \psi_1 e^{-i\omega t})/\sqrt{2}$")
        texto.set_text("Oscilador harmonico quantico  |  t = {:4.2f} T".format(t))
        return onda, densidade, titulo, texto

    # Quadros: salvamos tambem um instante com assimetria para a capa
    poster_frame = int(0.18 * N_FRAMES)
    poster_img = None

    with writer.saving(fig, str(MP4), dpi=DPI):
        for i in range(N_FRAMES):
            artistas = atualizar(i)
            writer.grab_frame(facecolor=BG)
            if i == poster_frame:
                fig.canvas.draw()
                buf = np.asarray(fig.canvas.buffer_rgba())
                poster_img = buf[:, :, :3].copy()

    if poster_img is not None:
        plt.imsave(POSTER, poster_img)

    plt.close(fig)
    print(f"video : {MP4} ({MP4.stat().st_size / 1024:.1f} KiB)")
    print(f"capa  : {POSTER} ({POSTER.stat().st_size / 1024:.1f} KiB)")


if __name__ == "__main__":
    main()
