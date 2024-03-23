mkdir -p ~/.ros/mab/config > /dev/null 2>&1
set -e
colcon build --symlink-install --executor parallel --cmake-args -DCMAKE_EXPORT_COMPILE_COMMANDS=On -DCMAKE_BUILD_TYPE=Release -Wall -Wextra -Wpedantic
if ([ ! -f ~/.ros/mab/config/global.json ]) then
    echo "Copying local config from repo to ~/.ros/mab/config/global.json"
    ln -s {$HOME}/honey_badger_ws/src/hb40/src/hb40_commons/config ~/.ros/mab/config/global.json
fi

echo "Syncing workspace"
rsync -ruz --info=progress2 --copy-links ./install $1:~/
echo "Syncing scripts"
rsync -ruz --copy-links ./src/hb40/scripts $1:~/
echo "Syncing config"
rsync -ruz --copy-links ~/.ros/mab/ $1:~/.ros/mab/
