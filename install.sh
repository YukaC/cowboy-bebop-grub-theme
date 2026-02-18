#! /usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

GRUB_THEME='cowboy-bebop-grub-theme'
INSTALLER_LANG='English'

# Handle --uninstall
if [[ ${1:-} == "--uninstall" ]]; then
    echo 'Uninstalling Cowboy Bebop GRUB theme...'

    # Pre-authorise sudo
    sudo echo

    # Detect GRUB directory
    GRUB_DIR='grub'
    UPDATE_GRUB=''

    if [[ -e /etc/os-release ]]; then
        ID=""
        ID_LIKE=""
        source /etc/os-release

        if [[ "$ID" =~ (debian|ubuntu|solus|void) || \
              "$ID_LIKE" =~ (debian|ubuntu|void) ]]; then
            UPDATE_GRUB='update-grub'
        elif [[ "$ID" =~ (arch|gentoo|artix) || \
                "$ID_LIKE" =~ (^arch|gentoo|^artix) ]]; then
            UPDATE_GRUB="grub-mkconfig -o /boot/${GRUB_DIR}/grub.cfg"
        elif [[ "$ID" =~ (centos|fedora|opensuse) || \
                "$ID_LIKE" =~ (fedora|rhel|suse) ]]; then
            GRUB_DIR='grub2'
            UPDATE_GRUB="grub2-mkconfig -o /boot/${GRUB_DIR}/grub.cfg"
        fi
    fi

    # Remove theme directory
    if [[ -d /boot/${GRUB_DIR}/themes/${GRUB_THEME} ]]; then
        echo 'Removing theme files'
        sudo rm -rf /boot/${GRUB_DIR}/themes/${GRUB_THEME}
    else
        echo 'Theme directory not found, skipping'
    fi

    # Remove theme settings from GRUB config
    echo 'Removing theme settings from GRUB config'
    sudo sed -i '/^GRUB_THEME=/d' /etc/default/grub
    sudo sed -i '/^GRUB_GFXMODE=/d' /etc/default/grub
    sudo sed -i '/^GRUB_GFXPAYLOAD_LINUX=/d' /etc/default/grub

    # Restore text terminal output (remove gfxterm, uncomment terminal)
    echo 'Restoring default text terminal'
    sudo sed -i '/^GRUB_TERMINAL_OUTPUT="gfxterm"/d' /etc/default/grub
    sudo sed -i 's/^#\(GRUB_TERMINAL\w*=.*\)/\1/' /etc/default/grub

    # Update GRUB
    echo 'Updating GRUB'
    if [[ $UPDATE_GRUB ]]; then
        eval sudo "$UPDATE_GRUB"
    else
        echo 'Cannot detect your distro, please run grub-mkconfig manually.'
    fi

    echo 'Cowboy Bebop GRUB theme uninstalled. Default text GRUB restored.'
    exit 0
fi

# Check dependencies
INSTALLER_DEPENDENCIES=(
    'mktemp'
    'sed'
    'sort'
    'sudo'
    'tar'
    'tee'
    'tr'
)

# Require wget or curl
if command -v wget > /dev/null 2>&1; then
    download() { wget -O - "$1"; }
elif command -v curl > /dev/null 2>&1; then
    download() { curl -fsSL "$1"; }
else
    echo >&2 "'wget' or 'curl' is required, but neither is available. Aborting."
    exit 1
fi

for i in "${INSTALLER_DEPENDENCIES[@]}"; do
    command -v $i > /dev/null 2>&1 || {
        echo >&2 "'$i' command is required, but not available. Aborting.";
        exit 1;
    }
done

# Change to temporary directory
cd $(mktemp -d)

# Pre-authorise sudo
sudo echo

# Select language, optional
declare -A INSTALLER_LANGS=(
    [Chinese_simplified]=zh_CN
    [Chinese_traditional]=zh_TW
    [English]=EN
    [French]=FR
    [German]=DE
    [Hungarian]=HU
    [Italian]=IT
    [Korean]=KO
    [Latvian]=LV
    [Norwegian]=NO
    [Polish]=PL
    [Portuguese]=PT
    [Russian]=RU
    [Rusyn]=RUE
    [Spanish]=ES
    [Turkish]=TR
    [Ukrainian]=UA
)

if [[ ${1:-} == "--lang" && -v 2 && -v INSTALLER_LANGS[$2] ]]; then
    INSTALLER_LANG=$2
else
    INSTALLER_LANG_NAMES=($(echo ${!INSTALLER_LANGS[*]} | tr ' ' '\n' | sort -n))

    PS3='Please select language #: '
    select l in "${INSTALLER_LANG_NAMES[@]}"; do
        if [[ -v INSTALLER_LANGS[$l] ]]; then
            INSTALLER_LANG=$l
            break
        else
            echo 'No such language, try again'
        fi
    done < /dev/tty
fi

# Select resolution
INSTALLER_RESOLUTIONS=(
    '1024x768'
    '1280x720'
    '1366x768'
    '1600x900'
    '1920x1080'
    '2560x1440'
)

GFX_RESOLUTION='1024x768'

PS3='Please select resolution #: '
select r in "${INSTALLER_RESOLUTIONS[@]}"; do
    if [[ -n "$r" ]]; then
        GFX_RESOLUTION="$r"
        break
    else
        echo 'Invalid option, try again'
    fi
done < /dev/tty

echo "Selected resolution: ${GFX_RESOLUTION}"

echo 'Fetching and unpacking theme'
download https://github.com/YukaC/${GRUB_THEME}/archive/master.tar.gz | tar -xzf - --strip-components=1

if [[ "$INSTALLER_LANG" != "English" ]]; then
    echo "Changing language to ${INSTALLER_LANG}"
    sed -i -r -e '/^\s+# EN$/{n;s/^(\s*)/\1# /}' \
              -e '/^\s+# '"${INSTALLER_LANGS[$INSTALLER_LANG]}"'$/{n;s/^(\s*)#\s*/\1/}' theme.txt
fi

# Detect distro and set GRUB location and update method
GRUB_DIR='grub'
UPDATE_GRUB=''
BOOT_MODE='legacy'

if [[ -d /boot/efi && -d /sys/firmware/efi ]]; then
    BOOT_MODE='UEFI'
fi

echo "Boot mode: ${BOOT_MODE}"

if [[ -e /etc/os-release ]]; then

    ID=""
    ID_LIKE=""
    source /etc/os-release

    if [[ "$ID" =~ (debian|ubuntu|solus|void) || \
          "$ID_LIKE" =~ (debian|ubuntu|void) ]]; then

        UPDATE_GRUB='update-grub'

    elif [[ "$ID" =~ (arch|gentoo|artix) || \
            "$ID_LIKE" =~ (^arch|gentoo|^artix) ]]; then

        UPDATE_GRUB="grub-mkconfig -o /boot/${GRUB_DIR}/grub.cfg"

    elif [[ "$ID" =~ (centos|fedora|opensuse) || \
            "$ID_LIKE" =~ (fedora|rhel|suse) ]]; then

        GRUB_DIR='grub2'
        UPDATE_GRUB="grub2-mkconfig -o /boot/${GRUB_DIR}/grub.cfg"

        # BLS entries have 'kernel' class, copy corresponding icon
        if [[ -d /boot/loader/entries && -e icons/${ID}.jpg ]]; then
            cp icons/${ID}.jpg icons/kernel.jpg
        fi
    fi
fi

# Copy fallback icon if distro-specific icon is missing
if [[ -n "$ID" && ! -e icons/${ID}.jpg && -e icons/unknown.jpg ]]; then
    echo "No icon for '${ID}', using fallback icon"
    cp icons/unknown.jpg icons/${ID}.jpg
fi

echo 'Creating GRUB themes directory'
sudo mkdir -p /boot/${GRUB_DIR}/themes/${GRUB_THEME}

echo 'Copying theme to GRUB themes directory'
sudo cp -r * /boot/${GRUB_DIR}/themes/${GRUB_THEME}

echo 'Removing other themes from GRUB config'
sudo sed -i '/^GRUB_THEME=/d' /etc/default/grub

echo 'Making sure GRUB uses graphical output'
sudo sed -i 's/^\(GRUB_TERMINAL\w*=.*\)/#\1/' /etc/default/grub

echo 'Removing old GFXMODE and GFXPAYLOAD settings'
sudo sed -i '/^GRUB_GFXMODE=/d' /etc/default/grub
sudo sed -i '/^GRUB_GFXPAYLOAD_LINUX=/d' /etc/default/grub

echo 'Removing empty lines at the end of GRUB config' # optional
sudo sed -i -e :a -e '/^\n*$/{$d;N;};/\n$/ba' /etc/default/grub

echo 'Adding new line to GRUB config just in case' # optional
echo | sudo tee -a /etc/default/grub

echo 'Adding theme and graphics settings to GRUB config'
echo "GRUB_THEME=/boot/${GRUB_DIR}/themes/${GRUB_THEME}/theme.txt" | sudo tee -a /etc/default/grub
echo 'GRUB_TERMINAL_OUTPUT="gfxterm"' | sudo tee -a /etc/default/grub
echo "GRUB_GFXMODE=\"${GFX_RESOLUTION},auto\"" | sudo tee -a /etc/default/grub

echo 'Removing theme installation files'
rm -rf "$PWD"
cd

echo 'Updating GRUB'
if [[ $UPDATE_GRUB ]]; then
    eval sudo "$UPDATE_GRUB"
else
    cat << '    EOF'
    --------------------------------------------------------------------------------
    Cannot detect your distro, you will need to run `grub-mkconfig` (as root) manually.

    Common ways:
    - Debian, Ubuntu, Solus and derivatives: `update-grub` or `grub-mkconfig -o /boot/grub/grub.cfg`
    - RHEL, CentOS, Fedora, SUSE and derivatives: `grub2-mkconfig -o /boot/grub2/grub.cfg`
    - Arch, Artix, Gentoo and derivatives: `grub-mkconfig -o /boot/grub/grub.cfg`
    --------------------------------------------------------------------------------
    EOF
fi
