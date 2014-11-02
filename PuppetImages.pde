class PuppetImages {
  PImage ali_top, ali_bottom;
  PImage spider_body,spider_ll,spider_rl;
  PImage angler_body,angler_jaw,angler_light;
  PImage bird_body,bird_head,bird_wing;
  PImage jelly_head,jelly_left,jelly_right;
  PImage  baby_body,baby_head,baby_left_arm, baby_right_arm;
  PImage cabaret_dancer_body,cabaret_dancer_left_arm,cabaret_dancer_right_arm,cabaret_dancer_head;
  PImage clown_body,clown_left_arm,clown_right_arm,clown_head;
  PImage death_horse,death_arm,death_skeleton;
  PImage fighter_body,fighter_arm,fighter_arm_sword,fighter_head;
  PImage hunter_body,hunter_arm,hunter_stick,hunter_head;
  PImage man_body,man_left_arm,man_right_arm,man_head;
  PImage sea_horse_body,sea_horse_fin;
  PImage old_man_body,old_man_left_arm,old_man_right_arm,old_man_head,old_man_left_upper_arm,old_man_right_upper_arm;
  PImage pierrot_body,pierrot_left_arm,pierrot_right_arm,pierrot_head;
  PImage soldier_body,soldier_head,soldier_arm;
  PImage scorpion_body,scorpion_tail,scorpion_left_claw,scorpion_right_claw,
  scorpion_left_leg_1,scorpion_left_leg_2,scorpion_left_leg_3,scorpion_left_leg_4,
  scorpion_right_leg_1,scorpion_right_leg_2,scorpion_right_leg_3,scorpion_right_leg_4;
  PImage venus_flytrap_closed_left,venus_flytrap_closed_right,venus_flytrap_open_left,
  venus_flytrap_open_right,venus_flytrap_side,venus_flytrap_stem;
  PImage fly_body,fly_back_leg,fly_front_leg,fly_middle_leg,fly_wing;
  //Is there a way you can only load the image when you're displaying it?

  void loadImages()
  {
    println("Loading puppet images...");
    ali_top = loadImage("alligator/alligator_top.png");
    ali_bottom = loadImage("alligator/alligator_bottom.png");

    spider_body = loadImage("spider/body.png");
    spider_ll = loadImage("spider/left_leg.png");
    spider_rl = loadImage("spider/right_leg.png");

    angler_body = loadImage("angler/body.png");
    angler_jaw = loadImage("angler/jaw.png");
    angler_light = loadImage("angler/light.png");

    bird_body = loadImage("skbird/body.png");
    bird_head = loadImage("skbird/head.png");
    bird_wing = loadImage("skbird/wing.png");

    jelly_head = loadImage("jelly/head.png");
    jelly_left = loadImage("jelly/left.png");
    jelly_right = loadImage("jelly/right.png");

    baby_body = loadImage("baby/body.png");
    baby_head = loadImage("baby/head.png");
    baby_left_arm = loadImage("baby/left_arm.png");
    baby_right_arm = loadImage("baby/right_arm.png");

    cabaret_dancer_body = loadImage("cabaret_dancer/body.png");
    cabaret_dancer_left_arm = loadImage("cabaret_dancer/left_arm.png");
    cabaret_dancer_right_arm = loadImage("cabaret_dancer/right_arm.png");
    cabaret_dancer_head=loadImage("cabaret_dancer/head.png");

    clown_body = loadImage("clown/body.png");
    clown_left_arm = loadImage("clown/left_arm.png");
    clown_right_arm = loadImage("clown/right_arm.png");
    clown_head=loadImage("clown/head.png");

    death_horse = loadImage("death/horse.png");
    death_arm = loadImage("death/arm.png");
    death_skeleton = loadImage("death/skeleton.png");

    fighter_body = loadImage("fighter/body.png");
    fighter_arm = loadImage("fighter/arm.png");
    fighter_arm_sword = loadImage("fighter/arm_sword.png");
    fighter_head=loadImage("fighter/head.png");

    hunter_body = loadImage("hunter/body.png");
    hunter_arm = loadImage("hunter/arm.png");
    hunter_stick = loadImage("hunter/stick.png");
    hunter_head=loadImage("hunter/head.png");

    man_body = loadImage("man/body.png");
    man_left_arm = loadImage("man/left_arm.png");
    man_right_arm = loadImage("man/right_arm.png");
    man_head=loadImage("man/head.png");

    sea_horse_body = loadImage("sea_horse/body.png");
    sea_horse_fin = loadImage("sea_horse/fin.png");
  
    old_man_body = loadImage("old_man/body.png");
    old_man_left_arm = loadImage("old_man/left_arm.png");
    old_man_right_arm = loadImage("old_man/right_arm.png");
    old_man_head=loadImage("old_man/head.png");
    old_man_left_upper_arm=loadImage("old_man/left_upper_arm.png");
    old_man_right_upper_arm=loadImage("old_man/right_upper_arm.png");
  
    pierrot_body = loadImage("pierrot/body.png");
    pierrot_left_arm = loadImage("pierrot/left_arm.png");
    pierrot_right_arm = loadImage("pierrot/right_arm.png");
    pierrot_head=loadImage("pierrot/head.png");
  
    soldier_body = loadImage("soldier/body.png");
    soldier_head = loadImage("soldier/head.png");
    soldier_arm = loadImage("soldier/arm.png");
  
    scorpion_body = loadImage("scorpion/body.png");
    scorpion_tail = loadImage("scorpion/tail.png");
    scorpion_left_claw = loadImage("scorpion/left_claw.png");
    scorpion_right_claw=loadImage("scorpion/right_claw.png");
    scorpion_left_leg_1=loadImage("scorpion/left_leg_1.png");
    scorpion_left_leg_2=loadImage("scorpion/left_leg_2.png");
    scorpion_left_leg_3=loadImage("scorpion/left_leg_3.png");
    scorpion_left_leg_4=loadImage("scorpion/left_leg_4.png");
    scorpion_right_leg_1=loadImage("scorpion/right_leg_1.png");
    scorpion_right_leg_2=loadImage("scorpion/right_leg_2.png");
    scorpion_right_leg_3=loadImage("scorpion/right_leg_3.png");
    scorpion_right_leg_4=loadImage("scorpion/right_leg_4.png");
  
    venus_flytrap_closed_left = loadImage("venus_flytrap/closed_left.png");
    venus_flytrap_closed_right = loadImage("venus_flytrap/closed_right.png");
    venus_flytrap_open_left = loadImage("venus_flytrap/open_left.png");
    venus_flytrap_open_right=loadImage("venus_flytrap/open_right.png");
    venus_flytrap_side=loadImage("venus_flytrap/side.png");
    venus_flytrap_stem=loadImage("venus_flytrap/stem.png");
  
    fly_body = loadImage("fly/body.png");
    fly_back_leg = loadImage("fly/back_leg.png");
    fly_front_leg = loadImage("fly/front_leg.png");
    fly_middle_leg=loadImage("fly/middle_leg.png");
    fly_wing=loadImage("fly/wing.png");
    println("Done.");
  }
}
