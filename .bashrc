export PATH="$HOME/bin:$PATH"

mariastart() {
    echo "Starting MariaDB (Database)..."
    sudo systemctl start mariadb.service

    echo "Starting PHP-FPM (PHP Processor)..."
    sudo systemctl start php-fpm.service

    echo "Starting Nginx (Web Server)..."
    sudo systemctl start nginx.service
    
    echo "-------------------------------------"
    echo "Web Stack services STARTED. 🎉"
    echo "Access phpMyAdmin at http://localhost/phpmyadmin"
}

mariastop() {
    echo "Stopping Nginx..."
    sudo systemctl stop nginx.service

    echo "Stopping PHP-FPM..."
    sudo systemctl stop php-fpm.service

    echo "Stopping MariaDB..."
    sudo systemctl stop mariadb.service

    echo "-------------------------------------"
    echo "Web Stack services STOPPED. 🛑"
}

mariastatus() {
    echo "Checking MariaDB status..."
    systemctl status mariadb.service --no-pager
}

phpstatus() {
    echo "Checking PHP-FPM status..."
    systemctl status php-fpm.service --no-pager
}

nginxstatus() {
    echo "Checking Nginx status..."
    systemctl status nginx.service --no-pager
}
alias helpme="batcat ~/.local/share/system-notes.md 2>/dev/null || cat ~/.local/share/system-notes.md"
alias helpme="cat ~/.local/share/system-shortcuts.txt"
