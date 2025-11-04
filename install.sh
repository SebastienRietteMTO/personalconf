#!/usr/bin/bash

# Installation script

#set -x
set -e
set -o pipefail #abort if left command on a pipe fails

#######################
### FUNCTIONS
#######################

function usage {
  echo "Usage: $0 [-h] [--doc-only]"
}
doc_only=false
while [ -n "$1" ]; do
  case "$1" in
    '-h') usage; exit;;
    '--doc-only') doc_only=true;;
    *) usage; exit 1;;
  esac
  shift
done

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SUB=$ROOT/sub
WEB=$ROOT/web
[ ! -d $SUB ] && mkdir $SUB
[ ! -d $WEB ] && mkdir $WEB

function clone_or_pull {
  repository=$1
  if [ "$2" != "" ]; then
    directory=$2
  else
    directory=$(basename $repository .git)
  fi
  CWD=$PWD
  cd $SUB
  if [ -d $directory ]; then
    cd $directory
    git pull 1>&2
  else
    git clone $repository $directory 1>&2
    cd $directory
  fi
  echo $SUB/$directory
  cd $CWD
}

function mvold {
  filename=$1
  basedest=${filename}.save$(date '+%Y%m%d')
  dest=$basedest
  i=0
  while [ -f $dest ]; do
    i=$(($i+1))
    dest=${basedest}.$i
  done
  mv $filename $dest
}

VERBOSE=true
function log {
  [ $VERBOSE == true ] && echo $@
}

#######################
### Main doc
#######################
cat - <<EOF > $WEB/index.html
<!DOCTYPE html>
<html lang="en">
  <head>
    <title>Personal conf documentation</title>
  </head>
  <body>
    <p>Different documentations are available here:</p>
    <ul>
EOF

#######################
### Crontab entries
#######################
freq='--daily'
comment='# update personalconf'
if [ $doc_only == false ]; then
  # We want to update the configuration once a day but we cannot
  # guarantee that the system will be up at midnight. So we try
  # to run the script hourly and at reboot time. And, in addition,
  # the update script performs a check to limit hourly execution.
  for line in "@reboot $ROOT/update.sh $freq" \
              "@hourly $ROOT/update.sh $freq"; do
    if ! grep "^${line}" <(crontab -l) > /dev/null; then
      log "Adding '$line' to crontab"
      ( crontab -l; echo "$line $comment" ) | crontab -
    fi
  done
fi

#######################
### vim
#######################
log "VIM"

# Gist repository
log "  cloning"
repository_vimrc=https://gist.github.com/SebastienRietteMTO/9e6086bca1acb3321b4a296cc05a107b
VIMFILE=$(clone_or_pull $repository_vimrc vim)/.vimrc

# Doc generation
log "  doc generation"
grep '^" DOC' $VIMFILE | cut -c 7- | pandoc -f markdown -o $WEB/vimrc.html
cp $VIMFILE $WEB/vimrc
echo "      <li>VIM: <a href='vimrc.html'>doc</a> and associated <a href='vimrc'>conf</a></li>" >> $WEB/index.html

# Installation
if [ $doc_only == false ]; then
  # Installation of dependancies
  log "  dependancies installation"
  bash -c "$(grep '^\" EXEC' $VIMFILE | cut -c 8-)"
  
  # Install file
  log "  installation"
  destfile=~/.vimrc
  if [ ! $destfile -ef $VIMFILE ]; then
    mvold $destfile
    ln -s $VIMFILE $destfile
  fi
fi

#######################
### END
#######################
cat - <<EOF >> $WEB/index.html
    </ul>
  </body>
</html>
EOF
log "END"
