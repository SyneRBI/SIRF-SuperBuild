# CMake path
[ -d /opt/cmake/bin ] && export PATH="/opt/cmake/bin${PATH:+:${PATH}}"

# ccache
[ -d /usr/lib/ccache ] && export PATH=/usr/lib/ccache:"$PATH"
[ -d /opt/ccache ] && ccache -o cache_dir=/opt/ccache
#[ -d /devel/.ccache ] && ccache -o cache_dir=/devel/.ccache

# completion
[ -f /etc/bash_completion ] && . /etc/bash_completion
[ -f ~/.git-prompt.sh ] || \
  curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh \
  > ~/.git-prompt.sh
  . ~/.git-prompt.sh

[ -f ~/.bash_aliases ] && . ~/.bash_aliases
#export PS1='sirf:\w$(__git_ps1)\$ '
# play safe with an innocent prompt that also works in the Bourne shell
export PS1='sirf$ '
# Python (virtualenv)
[ -f /opt/pyvenv/bin/activate ] && . /opt/pyvenv/bin/activate

# SIRF env
[ -f /opt/SIRF-SuperBuild/INSTALL/bin/env_sirf.sh ] && \
   . /opt/SIRF-SuperBuild/INSTALL/bin/env_sirf.sh

# Need to add this as we have built using some of these shared libraries
# See https://github.com/SyneRBI/SIRF-SuperBuild/issues/573
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/opt/pyvenv/lib

# .local/bin (used by pip for instance)
export PATH="${PATH}:~/.local/bin"

# shared permissions
# [ $(ls -l / | grep devel | awk '{print $3}') == $(whoami) ] || sudo chown -R $(whoami) /devel
# [ $(ls -l / | grep devel | awk '{print $4}') == $(whoami) ] || sudo chgrp -R $(whoami) /devel
