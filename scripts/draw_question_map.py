"""Draw the seven-question map as an accessible SVG and a printable PNG.

The layout and questions follow Katalin Tamási's original teaching mind map,
preserved in archive/2026-10-02/tutorial-draft/mind_map.png beside this project.
The Type II error label uses the current module's precise description of
non-rejection at a specified true difference. The archived image is untouched.

Figure content: CC BY 4.0. Generator code: MIT (see project licences).
Run from any directory with Python and Pillow installed.
"""

from pathlib import Path
from xml.sax.saxutils import escape
import math

from PIL import Image, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parents[1]
WIDTH, HEIGHT = 1000, 1030
CENTER = (500, 520, 153)
CENTER_LINES = (
    "Relevant",
    "questions for",
    "determining the",
    "minimum required",
    "sample size",
)
NODES = (
    {
        "id": "q1", "x": 840, "y": 365, "r": 107, "fill": "#fafbe7",
        "lines": ("What is", "the main outcome", "measure of your", "study?"),
    },
    {
        "id": "q2", "x": 840, "y": 690, "r": 111, "fill": "#fff0e6",
        "lines": ("What", "effect do", "you expect with", "the standard", "treatment?"),
    },
    {
        "id": "q3", "x": 547, "y": 902, "r": 95, "fill": "#e5f3f5",
        "lines": ("What effect", "do you expect with", "the novel", "treatment?"),
    },
    {
        "id": "q4", "x": 226, "y": 840, "r": 109, "fill": "#e4f3fa",
        "lines": ("What is a clinically", "relevant treatment", "difference that", "you want to", "detect?"),
    },
    {
        "id": "q5", "x": 153, "y": 529, "r": 96, "fill": "#e4ebf4",
        "lines": ("What are your", "null and alternative", "hypotheses?"),
    },
    {
        "id": "q6", "x": 232, "y": 226, "r": 137, "fill": "#eee8f3",
        "lines": ("What is the", "degree of risk that", "you are willing to", "accept to conclude that", "a treatment difference", "exists when in fact it", "doesn't (risk of", "type I error)?"),
    },
    {
        "id": "q7", "x": 601, "y": 165, "r": 135, "fill": "#fbeaf5",
        "lines": ("What is the degree of", "risk you are willing to", "accept when failing to", "reject the null hypothesis", "at a specified true", "treatment difference", "(risk of type II error)?"),
    },
)


def text_svg(x, y, lines, size, line_height, bold=False):
    """Centre several lines without relying on SVG automatic text wrapping."""
    start = y - (len(lines) - 1) * line_height / 2
    weight = ' font-weight="600"' if bold else ""
    lines_xml = "".join(
        f'<tspan x="{x}" y="{start + i * line_height:.1f}">{escape(line)}</tspan>'
        for i, line in enumerate(lines)
    )
    return (
        f'<text text-anchor="middle" dominant-baseline="central" '
        f'font-family="Arial, Helvetica, sans-serif" font-size="{size}" '
        f'fill="#17242d"{weight} aria-hidden="true">{lines_xml}</text>'
    )


def badge_position(node):
    # Sit just outside the upper-right edge so long labels remain unobscured.
    return node["x"] + node["r"] * .76, node["y"] - node["r"] * .78


def connector(node):
    cx, cy, cr = CENTER
    dx, dy = node["x"] - cx, node["y"] - cy
    length = math.hypot(dx, dy)
    return (
        cx + cr * dx / length, cy + cr * dy / length,
        node["x"] - node["r"] * dx / length,
        node["y"] - node["r"] * dy / length,
    )


def draw_svg():
    desc = (
        "Seven questions surround the minimum required sample size: primary outcome; "
        "expected effect with standard treatment; expected effect with novel treatment; "
        "clinically relevant difference; null and alternative hypotheses; risk of a "
        "Type I error; and risk of a Type II error at a specified true difference. "
        "Activate an information link to read the explanation below the map."
    )
    svg = [
        '<?xml version="1.0" encoding="UTF-8"?>',
        f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {WIDTH} {HEIGHT}" '
        f'width="{WIDTH}" height="{HEIGHT}" role="group" '
        'aria-labelledby="question-map-title question-map-description">',
        '<title id="question-map-title">Seven questions for determining the minimum required sample size</title>',
        f'<desc id="question-map-description">{escape(desc)}</desc>',
        '<style>.question-link {cursor:pointer;} '
        '.question-link:hover .info-disc, .question-link:focus-visible .info-disc {fill:#73217d;} '
        '.question-link:focus-visible .question-circle {stroke:#73217d;stroke-width:5;} '
        '.question-link:focus-visible .info-ring {stroke:#73217d;stroke-width:4;}</style>',
        '<g aria-hidden="true" fill="none" stroke="#64717a" stroke-width="1.5">',
    ]
    for node in NODES:
        x1, y1, x2, y2 = connector(node)
        svg.append(f'<path d="M{x1:.1f},{y1:.1f} L{x2:.1f},{y2:.1f}"/>')
    svg.extend([
        '</g>',
        f'<circle cx="{CENTER[0]}" cy="{CENTER[1]}" r="{CENTER[2]}" fill="#cce9f4" aria-hidden="true"/>',
        text_svg(CENTER[0], CENTER[1], CENTER_LINES, 27, 34, bold=True),
    ])
    for number, node in enumerate(NODES, 1):
        label = " ".join(node["lines"])
        bx, by = badge_position(node)
        svg.extend([
            f'<a class="question-link" href="#sample-size-question-{node["id"]}" '
            f'data-question="{node["id"]}" tabindex="0" '
            f'aria-label="{escape(f"Read explanation for question {number}: {label}", {chr(34): "&quot;"})}">',
            f'<circle class="question-circle" cx="{node["x"]}" cy="{node["y"]}" '
            f'r="{node["r"]}" fill="{node["fill"]}" stroke="transparent" stroke-width="5" aria-hidden="true"/>',
            text_svg(node["x"], node["y"], node["lines"], 19, 23),
            f'<circle class="info-ring" cx="{bx:.1f}" cy="{by:.1f}" r="31" '
            'fill="#fff" stroke="#d9dde0" stroke-width="1.5" aria-hidden="true"/>',
            f'<circle class="info-disc" cx="{bx:.1f}" cy="{by:.1f}" r="25" '
            'fill="#951aa4" aria-hidden="true"/>',
            f'<text x="{bx:.1f}" y="{by + 1:.1f}" text-anchor="middle" '
            'dominant-baseline="central" font-family="Georgia, serif" '
            'font-size="39" font-weight="bold" fill="#fff" aria-hidden="true">i</text>',
            '</a>',
        ])
    svg.append('</svg>')
    (ROOT / "figures/study_questions.svg").write_text("\n".join(svg) + "\n", encoding="utf-8")


def draw_png():
    # Draw the same native shapes and text as the SVG at a high print resolution.
    # This creates a new figure; it never reads or modifies the archived bitmap.
    scale = 3
    picture = Image.new("RGB", (WIDTH * scale, HEIGHT * scale), "white")
    drawing = ImageDraw.Draw(picture)

    def font(size, bold=False, serif=False):
        candidates = (
            ["C:/Windows/Fonts/georgiab.ttf", "DejaVuSerif-Bold.ttf"] if serif else
            ["C:/Windows/Fonts/arialbd.ttf", "DejaVuSans-Bold.ttf"] if bold else
            ["C:/Windows/Fonts/arial.ttf", "DejaVuSans.ttf"]
        )
        for candidate in candidates:
            try:
                return ImageFont.truetype(candidate, round(size * scale))
            except OSError:
                continue
        raise RuntimeError("Install Arial or DejaVu fonts to regenerate the printable map.")

    def circle(x, y, radius, fill, outline=None, stroke=1):
        bounds = [(x - radius) * scale, (y - radius) * scale,
                  (x + radius) * scale, (y + radius) * scale]
        drawing.ellipse(bounds, fill=fill, outline=outline, width=round(stroke * scale))

    def text(x, y, lines, size, line_height, bold=False):
        selected_font = font(size, bold=bold)
        for i, line in enumerate(lines):
            yy = y - (len(lines) - 1) * line_height / 2 + i * line_height
            drawing.text((x * scale, yy * scale), line, font=selected_font,
                         anchor="mm", fill="#17242d")

    for node in NODES:
        x1, y1, x2, y2 = connector(node)
        drawing.line([(x1 * scale, y1 * scale), (x2 * scale, y2 * scale)],
                     fill="#64717a", width=round(1.5 * scale))
    circle(CENTER[0], CENTER[1], CENTER[2], "#cce9f4")
    text(CENTER[0], CENTER[1], CENTER_LINES, 27, 34, bold=True)
    for node in NODES:
        circle(node["x"], node["y"], node["r"], node["fill"])
        text(node["x"], node["y"], node["lines"], 19, 23)
        bx, by = badge_position(node)
        circle(bx, by, 31, "white", outline="#d9dde0", stroke=1.5)
        circle(bx, by, 25, "#951aa4")
        drawing.text((bx * scale, (by + 1) * scale), "i", anchor="mm",
                     font=font(39, serif=True), fill="white")
    picture.resize((WIDTH * 2, HEIGHT * 2), Image.Resampling.LANCZOS).save(
        ROOT / "figures/study_questions.png", dpi=(200, 200)
    )


if __name__ == "__main__":
    draw_svg()
    draw_png()
    print("Generated figures/study_questions.svg and figures/study_questions.png")
