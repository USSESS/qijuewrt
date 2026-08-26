#!/bin/bash

# 添加第三方软件源（fanchmwrt 多包合集，必须用 feeds 方式添加）
echo "src-git fanchm https://github.com/fanchmwrt/fanchmwrt-packages.git" >> feeds.conf.default

# 2. 添加 iStore 官方源和依赖源
echo "src-git istore https://github.com/linkease/istore;main" >> feeds.conf.default
echo "src-git nas https://github.com/linkease/nas-packages.git;master" >> feeds.conf.default
echo "src-git nas_luci https://github.com/linkease/nas-packages-luci.git;main" >> feeds.conf.default
