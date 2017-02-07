//
//  Bloom.fsh
//  Snake
//
//  Created by Alexander Pagliaro on 11/14/14.
//  Copyright (c) 2014 Limit Point LLC. All rights reserved.
//

precision lowp float;

void main() {
    
    vec4 sum = vec4(0.0);
    int j;
    int i;
    
    for( i= -2 ;i < 2; i++) {
        for (j = -2; j < 2; j++) {
            sum += texture2D(u_texture, v_tex_coord + vec2(j, i)*0.004) * 0.25;
        }
    }
    
    gl_FragColor = sum + texture2D(u_texture, v_tex_coord);
    
    /*
    if (texture2D(u_texture, v_tex_coord).r < 0.3) {
        gl_FragColor = sum*sum*0.012 + texture2D(u_texture, v_tex_coord);
    }
    else {
        if (texture2D(u_texture, v_tex_coord).r < 0.5) {
            gl_FragColor = sum*sum*0.009 + texture2D(u_texture, v_tex_coord);
        }
        else {
            gl_FragColor = sum*sum*0.0075 + texture2D(u_texture, v_tex_coord);
        }
    }
     */
}