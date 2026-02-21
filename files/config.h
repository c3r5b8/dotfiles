/*
  distancethreshold: Minimum cutoff for a gestures to take effect
  degreesleniency: Offset degrees within which gesture is recognized (max=45)
  timeoutms: Maximum duration for a gesture to take place in miliseconds
  orientation: Number of 90 degree turns to shift gestures by
  verbose: 1=enabled, 0=disabled; helpful for debugging
  device: Path to the /dev/ filesystem device events should be read from
  gestures: Array of gestures; binds num of fingers / gesturetypes to commands
            Supported gestures: SwipeLR, SwipeRL, SwipeDU, SwipeUD,
                                SwipeDLUR, SwipeURDL, SwipeDRUL, SwipeULDR
*/

unsigned int distancethreshold = 20;
unsigned int distancethreshold_pressed = 60;
unsigned int degreesleniency = 15;
unsigned int timeoutms = 800;
unsigned int orientation = 0;
unsigned int verbose = 0;
double edgesizeleft = 50.0;
double edgesizetop = 200.0;
double edgesizeright = 50.0;
double edgesizebottom = 200.0;
double edgessizecaling = 1.0;
/*
 * Run the `sudo libinput list-devices`, and find the line
 * `Capabilities: touch`.
 * Check the `/dev/input/eventN`, and find the static name by running
 * the `ls -l /dev/input/by-path`.
 */
char *device = "/dev/input/by-path/pci-0000:00:19.1-platform-i2c_designware.2-event";

//Gestures can also be specified interactively from the command line using -g
Gesture gestures[] = {
{ 2,         SwipeDU,     EdgeLeft,  DistanceAny, ActModeReleased, "pactl set-sink-volume @DEFAULT_SINK@ +5%" },
{ 2,         SwipeUD,     EdgeLeft,  DistanceAny, ActModeReleased, "pactl set-sink-volume @DEFAULT_SINK@ -5%" },
{ 2,         SwipeDU,     EdgeRight, DistanceAny, ActModeReleased, "brightnessctl set +5%" },
{ 2,         SwipeUD,     EdgeRight, DistanceAny, ActModeReleased, "brightnessctl --min-value=1 set 5%-" },
{ 3,         SwipeRL,     EdgeRight, DistanceAny, ActModeReleased, "swaymsg fullscreen toggle" },
};
