#
# Utility methods
#

flatten_nested_array = (array) -> _.flatten(array, true)
includes = (target, coll) -> _.any(coll, (item) -> _.isEqual(item, target))
frequencies = (coll) -> _.countBy(coll, _.identity) # given a list, return a map of how many times each element appears in the list

# Javascript only supports strings as keys for associative arrays. This converts a "1,1" into [1,1]
key_to_array = (string) ->
  return string if typeof string != 'string'
  splitted = string.split(',')
  [parseInt(splitted[0]), parseInt(splitted[1])]

#
# Conway's Game of Life
#

neighbours_of = ([x, y]) ->
  [[x-1, y+1], [x, y+1], [x+1, y+1],
   [x-1, y  ],           [x+1, y  ],
   [x-1, y-1], [x, y-1], [x+1, y-1]]
  
neighbour_frequencies = (world) ->
  all_neighbours_of_live_cells = (neighbours_of(cell) for cell in world)
  frequencies(flatten_nested_array(all_neighbours_of_live_cells))

survives = (num_of_neighbours, alive) ->
  return yes if alive and (num_of_neighbours == 2 or num_of_neighbours == 3)
  return yes if not alive and num_of_neighbours == 3 
  no

evolve = (world) ->
  (key_to_array(cell) for cell, count of neighbour_frequencies(world) when survives(count, includes(key_to_array(cell), world)))

# world is a set of live cells
world = []

#
# Canvas renderer and game loop
#

canvas_renderer = (new_world) ->
    # Get context
    canvas = $('#conway')[0]
    ctx = canvas.getContext('2d')
    
    # Clear the screen
    ctx.fillStyle = "white"
    ctx.fillRect(0, 0, canvas.width, canvas.height)
    
    # Fill in the live cells
    ctx.fillStyle = "purple"
    size_of_cell = 10
    (ctx.fillRect(x * size_of_cell, y * size_of_cell, size_of_cell, size_of_cell) for [x, y] in new_world)
    
randomise_world = ->
    for x in [30...50]
        for y in [15...30]
            world.push [x,y] if Math.floor(Math.random() + 0.5) == 1

randomise_world()
setInterval (->
    world = evolve(world)
    canvas_renderer(world) ), 250
