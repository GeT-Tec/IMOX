/* IMOX — shell.js: formatadores e gráficos SVG vanilla */
(function () {
  "use strict";

  var NS = "http://www.w3.org/2000/svg";
  var nf = new Intl.NumberFormat("pt-BR", { maximumFractionDigits: 0 });

  var fmt = {
    brl: function (val) { return "R$ " + nf.format(Math.round(Number(val) || 0)); },
    num: function (val) { return "R$ " + nf.format(Math.round(Number(val) || 0)); }
  };

  function resolveFormat(f) {
    if (typeof f === "function") return f;
    if (f === "num") return function (v) { return nf.format(Math.round(v)); };
    return fmt.brl;
  }

  function el(name, attrs, parent) {
    var n = document.createElementNS(NS, name);
    for (var k in attrs) if (Object.prototype.hasOwnProperty.call(attrs, k)) n.setAttribute(k, attrs[k]);
    if (parent) parent.appendChild(n);
    return n;
  }

  function text(parent, x, y, str, opts) {
    var t = el("text", {
      x: x, y: y,
      "text-anchor": (opts && opts.anchor) || "middle",
      "font-size": (opts && opts.size) || 11,
      "font-weight": (opts && opts.weight) || 500,
      fill: (opts && opts.fill) || "#64748b"
    }, parent);
    t.textContent = str;
    return t;
  }

  function size(container) {
    var w = container.clientWidth || 320;
    var h = container.clientHeight || 220;
    return { w: w, h: h };
  }

  function makeSvg(container, w, h) {
    container.innerHTML = "";
    return el("svg", {
      viewBox: "0 0 " + w + " " + h,
      width: "100%", height: "100%",
      preserveAspectRatio: "xMidYMid meet",
      role: "img"
    }, container);
  }

  function line(container, o) {
    o = o || {};
    var labels = o.labels || [], values = o.values || [];
    if (!container || !values.length) return;
    var s = size(container), W = s.w, H = s.h;
    var color = o.color || "#0f766e", f = resolveFormat(o.format);
    var svg = makeSvg(container, W, H);
    var padL = 16, padR = 16, padT = 28, padB = 28;
    var min = Math.min.apply(null, values), max = Math.max.apply(null, values);
    if (min === max) { min -= 1; max += 1; }
    var range = max - min;
    var n = values.length;
    var step = n > 1 ? (W - padL - padR) / (n - 1) : 0;
    var pts = values.map(function (v, i) {
      return [n > 1 ? padL + i * step : W / 2, padT + (1 - (v - min) / range) * (H - padT - padB)];
    });
    // baseline
    el("line", { x1: padL, x2: W - padL, y1: H - padB, y2: H - padB, stroke: "#e2e8f0" }, svg);
    var d = pts.map(function (p, i) { return (i ? "L" : "M") + p[0] + " " + p[1]; }).join(" ");
    var area = d + " L" + pts[n - 1][0] + " " + (H - padB) + " L" + pts[0][0] + " " + (H - padB) + " Z";
    var a = el("path", { d: area, opacity: "0.10" }, svg);
    a.style.fill = color;
    var p = el("path", { d: d, fill: "none", "stroke-width": 2.5, "stroke-linejoin": "round", "stroke-linecap": "round" }, svg);
    p.style.stroke = color;
    pts.forEach(function (pt, i) {
      var c = el("circle", { cx: pt[0], cy: pt[1], r: 4.5, stroke: "#fff", "stroke-width": 2 }, svg);
      c.style.fill = color;
      var anchor = n > 1 ? (i === 0 ? "start" : i === n - 1 ? "end" : "middle") : "middle";
      text(svg, pt[0], pt[1] - 10, f(values[i]), { anchor: anchor, size: 11, weight: 700, fill: "#0f172a" });
      text(svg, pt[0], H - 8, labels[i] != null ? labels[i] : "", { anchor: anchor });
    });
  }

  function bar(container, o) {
    o = o || {};
    var labels = o.labels || [], values = o.values || [];
    if (!container || !values.length) return;
    var s = size(container), W = s.w, H = s.h;
    var color = o.color || "#0f766e", f = resolveFormat(o.format);
    var svg = makeSvg(container, W, H);
    var padL = 12, padR = 12, padT = 26, padB = 26;
    var max = Math.max.apply(null, values) || 1;
    var n = values.length;
    var slot = (W - padL - padR) / n;
    var bw = Math.min(56, slot * 0.62);
    el("line", { x1: padL, x2: W - padR, y1: H - padB, y2: H - padB, stroke: "#e2e8f0" }, svg);
    values.forEach(function (v, i) {
      var h = (v / max) * (H - padT - padB);
      var x = padL + i * slot + (slot - bw) / 2;
      var y = H - padB - h;
      var r = el("rect", { x: x, y: y, width: bw, height: Math.max(h, 0), rx: 3 }, svg);
      r.style.fill = color;
      text(svg, x + bw / 2, y - 6, f(v), { size: 10.5, weight: 700, fill: "#0f172a" });
      text(svg, x + bw / 2, H - 8, labels[i] != null ? labels[i] : "");
    });
  }

  function donut(container, o) {
    o = o || {};
    var labels = o.labels || [], values = o.values || [];
    var colors = o.colors || ["#0f766e", "#0284c7", "#f59e0b", "#64748b"];
    if (!container) return;
    var W = 340, H = 220;
    var svg = makeSvg(container, W, H);
    var total = values.reduce(function (a, b) { return a + b; }, 0);
    var cx = 100, cy = H / 2, R = 78, r = 48;
    if (!total) {
      el("circle", { cx: cx, cy: cy, r: (R + r) / 2, fill: "none", stroke: "#e2e8f0", "stroke-width": R - r }, svg);
      text(svg, cx, cy + 4, "Sem dados", { size: 12 });
    } else {
      var ang = -Math.PI / 2;
      values.forEach(function (v, i) {
        if (v <= 0) return;
        var frac = v / total;
        if (frac >= 0.9999) {
          el("circle", { cx: cx, cy: cy, r: (R + r) / 2, fill: "none", stroke: colors[i % colors.length], "stroke-width": R - r }, svg);
          return;
        }
        var a2 = ang + frac * 2 * Math.PI;
        var large = frac > 0.5 ? 1 : 0;
        var x1 = cx + R * Math.cos(ang), y1 = cy + R * Math.sin(ang);
        var x2 = cx + R * Math.cos(a2), y2 = cy + R * Math.sin(a2);
        var x3 = cx + r * Math.cos(a2), y3 = cy + r * Math.sin(a2);
        var x4 = cx + r * Math.cos(ang), y4 = cy + r * Math.sin(ang);
        el("path", {
          d: "M" + x1 + " " + y1 + " A" + R + " " + R + " 0 " + large + " 1 " + x2 + " " + y2 +
             " L" + x3 + " " + y3 + " A" + r + " " + r + " 0 " + large + " 0 " + x4 + " " + y4 + " Z",
          fill: colors[i % colors.length], stroke: "#fff", "stroke-width": 1.5
        }, svg);
        ang = a2;
      });
      text(svg, cx, cy + 2, nf.format(total), { size: 18, weight: 800, fill: "#0f172a" });
      text(svg, cx, cy + 18, "unidades", { size: 10 });
    }
    // legenda lateral
    var lx = 200, ly = cy - (labels.length * 24) / 2 + 8;
    labels.forEach(function (lb, i) {
      var y = ly + i * 24;
      el("rect", { x: lx, y: y - 9, width: 11, height: 11, rx: 2, fill: colors[i % colors.length] }, svg);
      var pct = total ? Math.round((values[i] / total) * 100) : 0;
      text(svg, lx + 17, y, lb, { anchor: "start", size: 11, weight: 600, fill: "#0f172a" });
      text(svg, lx + 17, y + 12, nf.format(values[i] || 0) + " (" + pct + "%)", { anchor: "start", size: 10 });
    });
  }

  window.skipShell = { fmt: fmt };
  window.skipChart = { line: line, bar: bar, donut: donut };
})();
