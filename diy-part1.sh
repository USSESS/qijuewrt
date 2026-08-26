#!/bin/bash

# 添加第三方软件源（fanchmwrt 多包合集，必须用 feeds 方式添加）
echo "src-git fanchm https://github.com/fanchmwrt/fanchmwrt-packages.git" >> feeds.conf.default
