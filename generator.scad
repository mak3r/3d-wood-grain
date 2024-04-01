// Define block dimensions
block_length = 610;  // length of the block in mm
block_width = 150;    // width of the block in mm
block_height = 25;   // height of the block in mm

// Parameters for the wood grain pattern
grain_overlap = 20; //grain development needs to overlap the block so the ends don't all come to a point
grain_width = 2.5;
function grain_count() = block_width/80; //Higher divisor is more lines, lower divisor is less lines
function segments_in_line(seed) = rands(.1 * block_length, .2 * block_length, 1, seed=seed);
function line_amplitude(x, seed) = rands(x-(2), x+(2), 1, seed=seed);

module grainSegment(xStart, xEnd, seed) {
    seg1 = [ for (y = [-grain_overlap:segments_in_line(seed=seed)[0]:block_length+grain_overlap]) let(x = line_amplitude(x=xStart,seed=seed)[0]) [x,y]];
    seg2 = [ for (y = [block_length+grain_overlap:-segments_in_line(seed=seed)[0]:-grain_overlap]) let(x = line_amplitude(x=xEnd,seed=seed)[0]) [x,y]];
    
    segment = concat(seg1,seg2);
    polygon(segment);
}

// TEST grainSegment
*linear_extrude(height = block_height)
    grainSegment(xStart=-grain_width,xEnd=grain_width, seed=22);


module grainPattern() {
    btwn_grains = grain_width * grain_count();
    width_grain = grain_width * 1.6 * grain_count();
    seedlings = [ for (xLeft = [0:width_grain:block_width]) let(xRight = xLeft+btwn_grains) let(seed = rands(1,5000,1)) [xLeft, xRight, seed[0]] ];
    for (i = [ 0 : len(seedlings) - 1 ]) {
        linear_extrude(height = block_height)
            grainSegment(xStart=seedlings[i][0], xEnd=seedlings[i][1], seed=seedlings[i][2]);
    }
    //TODO: implement grainPattern so that a desired set of seedlings can be re-used to render an identical pattern
    echo(seedlings);
}

difference() {
cube([block_width, block_length, block_height]);
translate([0,0,block_height*.8])
    grainPattern();
}
