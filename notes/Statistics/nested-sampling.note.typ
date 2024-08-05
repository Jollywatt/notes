#import "@local/notes:0.1.0"
#show: notes.style

#import "@preview/cetz:0.4.2"


= Nested Sampling

The goal of nested sampling is to compute a multidimensional integral
$
  Z = integral_Omega L(theta) dif mu(theta)
$ <Z>
for some $L(theta) >= 0$.
We assume the total volume of parameter space is $integral_Omega dif mu(theta) = mu(Omega) = 1$.
In applications, $L(theta)$ is usually interpreted as a likelihood and the measure as a prior
$
  dif mu(theta) = pi(theta) dif theta
$
which is normalised so that $integral pi(theta) dif theta = 1$. 

== Transforming the integral to one dimension

#notes.result-box[
  *Summary*.
  We can rewrite @Z as a one-dimensional integral
  $
    Z = integral_0^1 tilde(L)(X) dif X
  $
  where we define:
  $
  tilde(L)(xi) &= inline(sup{L^* in [0, oo) mid(|) X(L^*) > xi}) \
  X(L^*) &= mu({theta in Omega | L(theta) > L^*}) \
  $
]

We will build up to this incomprehensible result below.

Similar to the construction of a Lebesgue integral, we can rewrite @Z as
$
  Z = integral_0^oo X(L) dif L
$
where $X(L) dif L$ is volume of a horizontal slice through $L(theta)$ as in @fig-slice.
Formally, $X(L^*)$ is the the $mu$-measure of the $L^*$-super-level sets, or the volume of points in parameter space having larger likelihood than $L^*$.
$
  X(L^*) := integral_(L(theta) > L^*) dif mu (theta)
  = mu({theta in Omega | L(theta) > L^*}) \
$
In the Bayesian interpretation, $X(L^*)$ is the prior mass of minimum likelihood $L^*$, or the probability that a sample drawn from the prior has likelihood at least $L^*$.
$
  X(L^*) = integral_(L > L^*) pi(theta) dif theta = PP_(theta ~ pi)[L(theta) > L^*]
$ <X-PP>

#let f(x) = calc.exp(-0.5*x*x)*(2 + calc.pow(calc.cos(3*x*x + 6) + calc.cos(2.6*x + 1), 2))*0.7
#let N = 300
#let t = range(N + 1).map(t => t/N)
#let (x0, x1) = (-3, 3)
#let x = t.map(t => (1 - t)*x0 + t*x1)
#let l0 = 2
#let accent = blue

#let fig-slice = cetz.canvas({
  import cetz.draw: *
  set-style(content: (padding: 0.5em))



  let curve = line(..x.map(x => (x, f(x))), name: "curve")
  on-layer(1, curve)
  content("curve.50%", $L(theta)$, anchor: "south-west")


  let test-line = line((x0, l0), (x1, l0))
  hide(intersections("slice", test-line + curve))
  get-ctx(ctx => {
    let anchors = (ctx.nodes.slice.anchors)(()).map(a => (name: "slice", anchor: a))
    anchors.chunks(2).map(((a, b)) => {
      line(a, b, stroke: 4pt + accent)
    }).join()
  })
  
  content("slice.0", text(accent, $X(L^*)$), anchor: "south-east")
  line((x0, 0), (x1, 0), stroke: 0.5pt, name: "x")
  content("x.mid", $theta$, anchor: "north")
  line((x0, 0), (x0, 3), stroke: 0.5pt, name: "y")
  content("y.end", $L$, anchor: "east")

  line(("slice.0", "|-", (0, 0)), "slice.0", stroke: (dash: "dashed", paint: accent))
  content(("slice.0", "|-", (0, 0)), text(accent, $theta^*$), anchor: "north")

  line(("slice.0", "-|", (x0, 0)), "slice.0", stroke: (dash: "dashed", paint: accent))
  content(("slice.0", "-|", (x0, 0)), text(accent, $L^*$), anchor: "east")

})

#figure(fig-slice, caption: [
  The integral $Z = integral L(theta) dif mu(theta) = integral_0^oo X(L) dif L$ can be computed by integrating together all the horizontal slices with measure $X(L)$.
]) <fig-slice>


Notice that the range of $X$ is $[0, 1]$ because the total $mu$-measure of parameter space $X(0)$ is one (or in the Bayesian picture, because the prior is normalised). 
It is also clear that $X$ is monotonically decreasing; the slices get smaller as you go up.
If we assume that $L(theta)$ is never flat (no likelihood plateaux) then $X$ is also continuous.
Together, these facts mean that $X : im(L) -> [0, 1]$ is invertible, as in @fig-slice-sizes.
$
  X^(-1)(L^*)= sup{L^* in im(L) | X(L^*) > x}
$ <inv>

#let fig-slice-sizes = cetz.canvas({
  import cetz.draw: *
  set-style(content: (padding: 0.5em))

  let y1 = calc.max(..x.map(f))
  let y = t.map(t => y1*t)

  scale(x: x1 - x0)

  let X = y.map(y => x.map(x => int(f(x) > y)).sum()/N)
  let points = X.zip(y)

  // smoothen curve a bit
  for _ in range(4) {
    for (i, (x, y)) in points.enumerate() {
      if i == 0 { continue }
      points.at(i).first() = (points.at(i).first() + points.at(i - 1).first())/2
      points.at(i).last() = (points.at(i).last() + points.at(i - 1).last())/2
    }
    points.push((X.last(), y.last()))
  }


  on-layer(1, line(..points, name: "curve", stroke: (join: "round")))
  line((0,0), (1, 0), stroke: 0.5pt, name: "x")
  content("x.mid", $X$, anchor: "north")
  line((0,0), (0, y1), stroke: 0.5pt, name: "y")
  content("y.end", $L$, anchor: "east")

  let i = y.position(y => y > l0)
  let l00 = y.at(i)
  let X00 = X.at(i)

  content("curve.20%", $X(L)$, anchor: "south-west")

  line((0, l00), (X00, l00), stroke: 4pt + accent)
  line((X00, l00), (X00, 0), stroke: (dash: "dashed", paint: accent))
  content((0, l00), text(accent, $L^* = X^(-1)(xi)$), anchor: "east")
  content((X00, 0), text(accent, $xi = X(L^*)$), anchor: "north")

})

#figure(fig-slice-sizes, caption: [
  The measure of the $L$-super-level sets $X(L)$ plotted horizontally as a function of $L$ on the vertical.
  Since $X$ is monotonically decreasing and continuous, it has an inverse.
]) <fig-slice-sizes>

Now, we can change coordinates $L |-> X$ to transform the integral
$
  Z = integral_0^oo X(L) dif L = integral_0^1 X^(-1)(xi) dif xi
$
which pictorially just says that integrating vertical slices $X(L) dif L$ under the curve in @fig-slice-sizes is the same as integrating the horizontal slices, $X^(-1)(xi) dif xi$.


== Evaluating the integral

Suppose we sample som points $theta_i ~ pi$ from the prior.
The volumes $X(L(theta_i))$ associated to these points are uniformly distributed.
#block[
  _Proof_.
  The random variable $X(L(theta)) in [0, 1]$ is uniformly distributed if for any $0 <= u <= 1$ we have
  $PP_(theta ~ pi)[X(L(theta)) < u] = u$.
  Applying the inverse @inv (remembering that it is decreasing so the inequality is reversed) we get
  $
    PP_(theta ~ pi)[X(L(theta)) < u] = PP_(theta ~ pi)[L(theta) > X^(-1)(u)] = X(X^(-1)(u)) = u
  $
  where the middle step follows by substituting @X-PP.
  #sym.qed
]