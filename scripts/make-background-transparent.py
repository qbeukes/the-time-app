from PIL import Image
import numpy as np
from pathlib import Path
from scipy.ndimage import binary_opening, binary_closing, gaussian_filter
from scipy.ndimage import distance_transform_edt

src = Path("static_sun.png")
img = Image.open(src).convert("RGB")
arr = np.asarray(img).astype(np.float32)
h, w = arr.shape[:2]

# The checkerboard is mostly neutral black/gray. Estimate square size and phase
# from the top row/left column, then build the expected checkerboard background.
# In this image the checkers are regular and axis-aligned.
def transition_positions(vals):
    # classify dark vs light from grayscale values
    m = vals > ((vals.min() + vals.max()) / 2.0)
    return np.where(m[1:] != m[:-1])[0] + 1

gray = arr.mean(axis=2)
# Use border strips where foreground is least present.
top_band = gray[:40, :].mean(axis=0)
left_band = gray[:, :40].mean(axis=1)
tx = transition_positions(top_band)
ty = transition_positions(left_band)

# Robustly estimate cell size from transition gaps.
def estimate_period(t):
    d = np.diff(t)
    d = d[(d > 10) & (d < 80)]
    return int(round(np.median(d))) if len(d) else 26

cell_x = estimate_period(tx)
cell_y = estimate_period(ty)
cell = int(round((cell_x + cell_y) / 2))

# Estimate phase: choose phase that best predicts dark/light classes on clean border pixels.
border_mask = np.zeros((h, w), dtype=bool)
border_mask[:60, :] = True
border_mask[-60:, :] = True
border_mask[:, :60] = True
border_mask[:, -60:] = True

# Exclude obvious foreground glow from phase/color estimation.
neutral = np.max(arr, axis=2) - np.min(arr, axis=2) < 18
clean_border = border_mask & neutral

best = None
for ox in range(cell):
    for oy in range(cell):
        yy, xx = np.indices((h, w))
        cls = (((xx + ox) // cell + ((yy + oy) // cell)) & 1).astype(bool)
        # score against the two clusters in grayscale on border
        g = gray[clean_border]
        c = cls[clean_border]
        if c.sum() == 0 or (~c).sum() == 0:
            continue
        m0 = g[~c].mean()
        m1 = g[c].mean()
        pred_light = c if m1 > m0 else ~c
        actual_light = g > ((m0 + m1) / 2.0)
        acc = (pred_light == actual_light).mean()
        if best is None or acc > best[0]:
            best = (acc, ox, oy, m0, m1, m1 > m0)

_, ox, oy, _, _, c_is_light = best
yy, xx = np.indices((h, w))
cls = (((xx + ox) // cell + ((yy + oy) // cell)) & 1).astype(bool)

# Estimate the RGB color of each checker class from clean border pixels.
colors = []
for class_value in [False, True]:
    pix = arr[clean_border & (cls == class_value)]
    colors.append(np.median(pix, axis=0))
bg0, bg1 = colors
bg = np.where(cls[..., None], bg1, bg0).astype(np.float32)

# Compute foreground likelihood. Difference from expected checker background is foreground.
diff = np.linalg.norm(arr - bg, axis=2)

# Pure checkerboard pixels have very low diff; foreground has orange/yellow chroma and luminance.
# Convert diff to alpha. Use a soft ramp to keep the solar glow feathered.
low, high = 8.0, 95.0
alpha = np.clip((diff - low) / (high - low), 0, 1)

# Improve detection of warm glow on gray/black squares.
r, g, b = arr[..., 0], arr[..., 1], arr[..., 2]
warm = np.maximum.reduce([
    (r - b) / 170.0,
    (g - b) / 160.0,
    (r + g - 2 * b) / 300.0
])
warm = np.clip(warm, 0, 1)

brightness = np.clip((gray - 35.0) / 220.0, 0, 1)
alpha = np.maximum(alpha, warm * brightness)

# Preserve the full solar disk and strong flares; soften only the edge.
strong = (diff > 75) | ((r > 145) & (g > 75) & (b < 90))
alpha[strong] = np.maximum(alpha[strong], 0.98)

# Remove isolated checker noise and smooth the alpha boundary.
mask = alpha > 0.08
mask = binary_opening(mask, structure=np.ones((2, 2)))
mask = binary_closing(mask, structure=np.ones((3, 3)))

# Keep only the largest connected component around the sun/flares to avoid checker artifacts.
from scipy import ndimage
labels, n = ndimage.label(mask)
if n:
    sizes = ndimage.sum(mask, labels, range(1, n + 1))
    keep_label = int(np.argmax(sizes) + 1)
    mask = labels == keep_label

# Re-introduce soft alpha around the retained object.
dist_in = distance_transform_edt(mask)
dist_out = distance_transform_edt(~mask)
edge_soft = np.clip((dist_in + 4) / 8, 0, 1) * mask + np.clip((4 - dist_out) / 4, 0, 1) * (~mask)
alpha = np.where(mask, np.maximum(alpha, 0.15), np.minimum(alpha, 0.12))
alpha = np.maximum(alpha, edge_soft * 0.25)
alpha = gaussian_filter(alpha, sigma=0.8)
alpha = np.clip(alpha, 0, 1)

# For pixels with alpha, uncomposite the checkerboard to estimate original foreground color.
# C = A*F + (1-A)*B  =>  F = (C - (1-A)*B) / A
a = np.maximum(alpha[..., None], 1e-4)
fg = (arr - (1 - a) * bg) / a
fg = np.clip(fg, 0, 255)

# For almost opaque areas keep original color to avoid overcorrection.
fg = np.where(alpha[..., None] > 0.95, arr, fg)

rgba = np.dstack([fg, alpha * 255]).astype(np.uint8)

# Hard-clear truly background pixels to avoid RGB checker remnants in fully transparent areas.
rgba[alpha < 0.01, :3] = 0
rgba[alpha < 0.01, 3] = 0

out = Path("static_sun_transparent_background.png")
Image.fromarray(rgba, mode="RGBA").save(out)

# Also make a preview composited on white for quick sanity check.
preview_bg = np.full_like(arr, 255)
prev = (rgba[..., :3].astype(np.float32) * (rgba[..., 3:4] / 255.0) + preview_bg * (1 - rgba[..., 3:4] / 255.0)).astype(np.uint8)
Image.fromarray(prev, mode="RGB").save("static_sun_transparent_preview_white.png")

print(f"Created: {out}")
print(f"Estimated checker cell size: {cell}px")
