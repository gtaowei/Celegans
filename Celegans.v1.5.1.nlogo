globals [tb tp rec kk t.conc]
breed [worms worm]
breed [larvae larva]
breed [bags bag]
turtles-own [energy siz tick.b age.l age.w age.b prog]
patches-own [conc]

to setup
  set rec find-file
  file-open rec
  file-print (word "agent " "age.l " "age.w " "age.b " "energy " "prog " "death from")
  ;;file-print "Program initializing"
  clear-all
  ask patches [
    set pcolor white
    set conc initial-bacteria-concentration
    ]
  set-default-shape worms "worm"
  create-worms initial-number-worms
  [
    set color red
    set size 5 
    set energy random (1000) + 3000
    setxy random-xcor random-ycor
    set age.l 0
    set age.w 0
    set age.b 0
    set tick.b 0
    set prog 0
    set siz 10
    ;;file-print (word self "initial worm placed at: (" precision xcor 3 "," precision ycor 3 ") energy: " energy)
  ]
  set-default-shape larvae "worm"
  set-default-shape bags "worm_c"
  display-labels
  reset-ticks
  ;;file-print (word "-------------------- Tick#: " ticks " --------------------")
  set tb 0
  set tp 0
  ;;file-print "Program initialized"
end

to-report find-file
  let k 0
  let file (word "log_" k ".txt")
  ;;set tab (word "log_agents_" k ".txt")
  ;;while [file-exists? rec or file-exists? tab] [
  while [file-exists? file] [
    set k k + 1
    set file (word "log_" k ".txt")
    ;;set tab (word "log_agents_" k ".txt")
  ]
  report file
end

to go
  if no-worms [ stop ]
  ask patches [
    set pcolor scale-color black conc 0 100
  ]
  ask worms [
    set age.w (age.w + 1)
    move_w
    set energy energy - 20
    ;;file-open rec
    ;;file-print (word self "moving to: (" precision xcor 3 "," precision ycor 3 ") energy: " energy "age: " age.w)
    ;;file-close
    catch-bacteria
    death
    wormbag
    reproduce-worms
  ]
  ask larvae [
    set age.l (age.l + 1)
    move_w
    set energy energy - 10
    catch-bacteria
    death
    grow
  ]
  ask bags [
    set age.b (age.b + 1)
    explode
  ]
  tick
  file-flush
  set tb (tb + 1)
  if tb = bacteria-replenish-interval [
    replenish-bacteria
    set tb 0
  ]
  set tp (tp + 1)
  if tp = predation-interval [
    ask worms [predation]
    ask larvae [predation]
    ask bags [predation]
    set tp 0
  ]
  let temp 0
  ask patches [set temp temp + conc]
  set t.conc temp / ((max-pxcor - min-pxcor + 1) * (max-pycor - min-pycor + 1))
  display-labels
end

to-report no-worms
  if ((not any? worms) and (not any? larvae) and (not any? bags)) [report true]
  report false
end
  
to move_b
  rt random 50
  lt random 50
  fd 0.05
end

to move_w
  rt random 50
  lt random 50
  fd 0.5
end

to replenish-bacteria
    ask patches [
      set conc conc + bacteria-replenish-concentration
    ]
end

to reproduce-worms
  if energy > reproduce-energy [ 
    set energy (energy - 100 * worms-progeny)        
    hatch-larvae worms-progeny [ 
      rt random-float 360 fd 0.5
      set age.l 0
      set age.w 0
      set age.b 0
      set prog 0
      set color yellow
      set size 3
      set siz 1
      set energy 200
      set tick.b ticks
    ]
    set prog prog + worms-progeny
  ]
end

to catch-bacteria 
  let psiz siz
  let ee 0
  let p false
  let q false
  ask patch-here [
       if ((conc - psiz * 20 ) > 0 ) [set p true]
       if (conc > 0 ) [set q true]
       ifelse p 
       [set conc conc - psiz * 20]
       [if q [ 
         set ee conc / 20
         set conc 0
       ]
       ]
  ]
  ifelse (p) [
    set energy energy + siz * (worms-gain-from-food / 2)
    if siz + siz * (worms-gain-from-food / 2 / 2000) <= 20 [set siz siz + siz * (worms-gain-from-food / 2 / 2000)]
  ]
  [
    set energy energy + ee * (worms-gain-from-food / 2)
    if siz + ee * (worms-gain-from-food / 2 / 2000) <= 20 [set siz siz + ee * (worms-gain-from-food / 2 / 2000)]
  ]
end

to predation
  if random-float 100 < predation-percentage [
    record "predation"
    die 
  ]
end

to grow
  if siz >= 10 [
      hatch-worms 1 [
        set color red
        set size 5
      ]
      die
    ]
end

to death 
  if energy <= 0 [ 
    record "starvation"
    die
  ]
  let age (age.l + age.w)
  let p (100 / (1 + e ^ ( -0.05 * (age - 150)))) ;change age to appropriate function of age
  if random-float 100 < p [
    record "ageing"
    die
  ]
end

to wormbag
  if energy < 1000 [
    hatch-bags 1 [
      set color grey
      set size 4]
    die
  ]
end

to explode
  if age.b > 10 [
      let p random 10
      hatch-larvae p [
        rt random-float 360 fd 0.5
        set age.l 0
        set age.w 0
        set age.b 0
        set color yellow
        set size 3
        set siz 1
        set energy (energy / p)
        set prog prog + p
      ]
      record "wormbag explosion"
      die
    ]
end

to record [way]
  file-print (word self " " age.l " " age.w " " age.b " " precision energy 0 " " prog " death from: " way)
end

to display-labels
  ask turtles [
    set label ""
    set label-color black
  ]
  if show-energy? [
    ask worms [ set label round energy]
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
409
20
932
510
28
25
9.0
1
14
1
1
1
0
1
1
1
-28
28
-25
25
1
1
1
ticks
30.0

SLIDER
9
102
213
135
initial-bacteria-concentration
initial-bacteria-concentration
0
100
100
1
1
NIL
HORIZONTAL

SLIDER
220
100
385
133
initial-number-worms
initial-number-worms
0
500
150
1
1
NIL
HORIZONTAL

SLIDER
221
139
387
172
worms-gain-from-food
worms-gain-from-food
0.0
1000
200
1.0
1
NIL
HORIZONTAL

SLIDER
221
178
401
211
reproduce-energy
reproduce-energy
0.0
5000
800
1.0
1
NIL
HORIZONTAL

BUTTON
4
29
64
63
Setup
setup
NIL
1
T
OBSERVER
NIL
S
NIL
NIL
1

BUTTON
82
30
138
64
Go!
go
T
1
T
OBSERVER
NIL
G
NIL
NIL
0

PLOT
12
312
392
509
populations
time
number
0.0
100.0
0.0
500.0
false
true
"set kk 0" "set kk kk + 1\nif kk = 100 [\n  set-plot-y-range 0 150 ;;precision ((count larvae) / 2) -2\n  ;;set kk 0\n]\nif kk mod 100 = 0 [set-plot-x-range 0 kk + 100]"
PENS
"bacteria" 1.0 0 -13345367 true "" "plot t.conc"
"adults" 1.0 0 -2674135 true "" "plot count worms"
"larvae/10" 1.0 0 -1184463 true "" "plot count larvae / 10"
"wormbags" 1.0 0 -14737633 true "" "plot count bags"

MONITOR
235
259
306
304
bacteria
t.conc
3
1
11

MONITOR
310
260
392
305
worms
count worms + count larvae + count bags
3
1
11

TEXTBOX
14
82
154
101
Bacteria settings
11
0.0
0

TEXTBOX
221
79
334
97
Worms settings
11
0.0
0

SWITCH
256
31
388
64
show-energy?
show-energy?
1
1
-1000

SLIDER
8
140
213
173
bacteria-replenish-interval
bacteria-replenish-interval
1
100
20
1
1
NIL
HORIZONTAL

SLIDER
8
178
213
211
bacteria-replenish-concentration
bacteria-replenish-concentration
0
100
20
1
1
NIL
HORIZONTAL

SLIDER
220
217
386
250
worms-progeny
worms-progeny
0
20
2
1
1
NIL
HORIZONTAL

SLIDER
8
214
180
247
predation-interval
predation-interval
1
100
20
1
1
NIL
HORIZONTAL

SLIDER
8
252
197
285
predation-percentage
predation-percentage
0
100
10
1
1
NIL
HORIZONTAL

BUTTON
159
32
236
66
Close file
file-close
NIL
1
T
OBSERVER
NIL
C
NIL
NIL
0

@#$#@#$#@
Author: Wei Tao
Washington University
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

bacterium
true
0
Circle -7500403 true true 129 84 42
Circle -7500403 true true 129 84 42
Circle -7500403 true true 129 177 42
Rectangle -7500403 true true 129 103 171 196

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

worm
true
0
Polygon -7500403 true true 45 204 63 240 76 257 90 268 113 274 138 274 174 256 188 221 191 188 182 158 171 131 165 107 156 77 162 51 185 39 223 43 181 33 147 44 136 85 149 143 168 195 160 239 133 255 117 255 105 254 88 243 66 228

worm_c
true
0
Polygon -7500403 true true 165 210 165 225 135 255 105 270 90 270 75 255 75 240 90 210 120 195 135 165 165 135 165 105 150 75 150 60 135 60 120 45 120 30 135 15 150 15 180 30 180 45 195 45 210 60 225 105 225 135 210 150 210 165 195 195 180 210
Line -16777216 false 135 255 90 210
Line -16777216 false 165 225 120 195
Line -16777216 false 135 165 180 210
Line -16777216 false 150 150 201 186
Line -16777216 false 165 135 210 150
Line -16777216 false 165 120 225 120
Line -16777216 false 165 106 221 90
Line -16777216 false 157 91 210 60
Line -16777216 false 150 60 180 45
Line -16777216 false 120 30 96 26
Line -16777216 false 124 0 135 15

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.0.4
@#$#@#$#@
setup
set grass? true
repeat 75 [ go ]
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 1.0 0.0
0.0 1 1.0 0.0
0.2 0 1.0 0.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
