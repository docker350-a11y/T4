#!/bin/bash

LOG_FILE="./user_mgmt.log"

created=0
deleted=0
failed=0
checked=0

# =========================
# ROOT CHECK
# =========================
if [[ $EUID -ne 0 ]]; then
    echo "❌ Run as root (use sudo)"
    exit 1
fi

# =========================
# LOG FUNCTION
# =========================
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') | $1" >> "$LOG_FILE"
}

# =========================
# VALIDATION
# =========================
validate_user() {
    local user="$1"

    if [[ -z "$user" ]]; then
        echo "❌ Username cannot be empty"
        return 1
    fi

    if [[ "$user" == *" "* ]]; then
        echo "❌ Spaces not allowed"
        return 1
    fi

    if [[ ! "$user" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
        echo "❌ Invalid username format"
        return 1
    fi

    return 0
}

# =========================
# CREATE USER
# =========================
create_user() {

    read -p "Enter username: " username

    validate_user "$username" || { ((failed++)); return; }

    ((checked++))

    if id "$username" &>/dev/null; then
        echo "❌ User already exists"
        log "CREATE | $username | FAILED | already exists"
        ((failed++))
        return
    fi

    read -sp "Enter password: " password
    echo

    if useradd -m "$username"; then

        echo "$username:$password" | chpasswd

        echo "Welcome $username 👋" > /home/"$username"/WELCOME.txt

        echo "User created successfully"
        log "CREATE | $username | SUCCESS"
        ((created++))

    else
        echo "❌ Failed to create user"
        log "CREATE | $username | FAILED | system error"
        ((failed++))
    fi
}

# =========================
# DELETE USER (SAFE VERSION)
# =========================
delete_user() {

    echo ""
    echo "========== AVAILABLE USERS =========="
    awk -F: '$3 >= 1000 && $3 < 65534 {print "- " $1}' /etc/passwd
    echo "====================================="
    echo ""

    read -p "Enter username to delete: " username

    if ! id "$username" &>/dev/null; then
        echo "❌ User not found"
        log "DELETE | $username | FAILED | not found"
        ((failed++))
        return
    fi

    echo ""
    echo "⚠️ You selected: $username"
    echo "====================================="

    read -p "Are you sure? (yes/no): " ans

    if [[ "${ans,,}" == "yes" ]]; then

        # extra safety check (double confirm)
        read -p "Type username again to confirm: " confirm_user

        if [[ "$confirm_user" != "$username" ]]; then
            echo "❌ Username mismatch! Abort."
            log "DELETE | $username | FAILED | mismatch confirmation"
            ((failed++))
            return
        fi

        if userdel -r "$username"; then
            echo "✅ User deleted successfully"
            log "DELETE | $username | SUCCESS"
            ((deleted++))
        else
            echo "❌ Delete failed"
            log "DELETE | $username | FAILED | system error"
            ((failed++))
        fi

    else
        echo "❌ Cancelled"
        log "DELETE | $username | CANCELLED"
    fi
}

# =========================
# VIEW LOGS
# =========================
view_logs() {
    echo ""
    echo "========== LOGS =========="
    cat "$LOG_FILE"
    echo "=========================="
}

# =========================
# SUMMARY REPORT
# =========================
summary() {
    echo ""
    echo "=========================="
    echo "   SUMMARY REPORT"
    echo "=========================="
    echo "Checked Users : $checked"
    echo "Created Users : $created"
    echo "Deleted Users : $deleted"
    echo "Failed Ops    : $failed"
    echo "=========================="
}

# =========================
# MENU
# =========================
while true; do

    echo ""
    echo "=============================="
    echo "   USER MANAGEMENT TOOL"
    echo "=============================="
    echo "1. Create User"
    echo "2. Delete User"
    echo "5. View Logs"
    echo "7. Summary"
    echo "8. Exit"
    echo "=============================="

    read -p "Choose option: " opt

    case $opt in
        1) create_user ;;
        2) delete_user ;;
        5) view_logs ;;
        7) summary ;;
        8) echo "Bye 👋"; exit 0 ;;
        *) echo "Invalid option" ;;
    esac

done
