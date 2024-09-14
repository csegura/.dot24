LAPTOP="eDP-1"
LEFT="DP-2-2-2"
RIGHT="DP-2-2-1"

extramonitor() {
  case "$1" in
      "laptopoff") xrandr --output "$LAPTOP" --off ;;
      "laptopon") xrandr --output "$LAPTOP" --auto ;;
      "external") xrandr --output "$LEFT" --auto --right-of "$RIGHT" --output "$RIGHT" --auto --output "$LAPTOP" --off ;;
      "all") xrandr --output "$LEFT" --auto --right-of "$RIGHT" --output "$RIGHT" --auto --output "$LAPTOP" --right-of "$RIGHT" --auto ;;
      "allthree") xrandr --output "$RIGHT" --mode 1920x1080 && xrandr --output "$LEFT" --mode 1920x1080 && xrandr --output "$LAPTOP" --auto --output "$RIGHT" --left-of "$LAPTOP" --output "$LEFT" --right-of "$LAPTOP";;
      "duplicate") xrandr --output "$LEFT" --mode 1920x1080 && xrandr --output "$LAPTOP" --auto --output "$main" --same-as "$LAPTOP" ;;
      *) notify-send "Multi Monitor" "Unknown Operation" ;;
  esac
}

if [ -z "$1" ]; then
  selection=$(printf "laptopon\nlaptopoff\nexternal\nall" | dmenu -i -p "Monitor Configuration")
else
  selection=$1
fi

extramonitor "$selection" 