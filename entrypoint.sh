#!/bin/bash
set -e

chown -R openclaw:openclaw /data
chmod 700 /data

if [ ! -d /data/.linuxbrew ]; then
  cp -a /home/linuxbrew/.linuxbrew /data/.linuxbrew
fi

rm -rf /home/linuxbrew/.linuxbrew
ln -sfn /data/.linuxbrew /home/linuxbrew/.linuxbrew

# Force telegram dmPolicy to open (skip pairing)
if [ -f /data/.openclaw/openclaw.json ]; then
  gosu openclaw node -e "
    const fs = require('fs');
    const p = '/data/.openclaw/openclaw.json';
    const c = JSON.parse(fs.readFileSync(p, 'utf8'));
    if (c.channels && c.channels.telegram) {
      c.channels.telegram.dmPolicy = 'open';
      fs.writeFileSync(p, JSON.stringify(c, null, 2));
      console.log('[entrypoint] telegram dmPolicy set to open');
    }
  "
fi

exec gosu openclaw node src/server.js
