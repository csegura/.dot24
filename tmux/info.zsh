#!/bin/zsh
function cpu() {
  awk -v OFMT='%.3g' '$1 == "cpu" {print(100*($2+$4)/($2+$4+$5))}' /proc/stat
}
function mem() {
  free | grep Mem | awk -v OFMT='%.4g' '{print(100*($3/$2))}'
}
echo "$(cpu)%] $(mem)%]"


