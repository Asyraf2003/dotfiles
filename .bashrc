export PATH="$HOME/bin:$PATH"

alias helpme="cat ~/.dotfiles/notes/shortcuts.txt"
alias update="sudo pacman -Syu | tee -a ~/pacman-update.log"

DATE_COLOR="\e[1;34m"
TIME_COLOR="\e[1;32m"
RESET_COLOR="\e[0m"

echo -e "${DATE_COLOR}$(date +'%A, %d %B %Y')${RESET_COLOR} — ${TIME_COLOR}$(date +'%H:%M:%S %Z')${RESET_COLOR}"
