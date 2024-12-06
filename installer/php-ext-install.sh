#!/usr/bin/env bash
###
# @Author: Cloudflying
# @Date: 2024-12-06 13:36:50
# @LastEditTime: 2024-12-06 13:38:42
# @LastEditors: Cloudflying
# @Description: Install PHP Extension
###

NON_ZTS_FILENAME=no-debug-non-zts-20121212
if [ "$VERSION" == "56" ]; then
  NON_ZTS_FILENAME=no-debug-non-zts-20131226
elif [[ "$VERSION" == "70" ]]; then
  NON_ZTS_FILENAME=no-debug-non-zts-20151012
elif [[ "$VERSION" == "71" ]]; then
  NON_ZTS_FILENAME=no-debug-non-zts-20160303
elif [[ "$VERSION" == "72" ]]; then
  NON_ZTS_FILENAME=no-debug-non-zts-20170718
elif [[ "$VERSION" == "73" ]]; then
  NON_ZTS_FILENAME=no-debug-non-zts-20180731
elif [[ "$VERSION" == "74" ]]; then
  NON_ZTS_FILENAME=no-debug-non-zts-20190902
elif [[ "$VERSION" == "80" ]]; then
  NON_ZTS_FILENAME=no-debug-non-zts-20200930
elif [[ "$VERSION" == "81" ]]; then
  NON_ZTS_FILENAME=no-debug-non-zts-20201009
elif [[ "$VERSION" == "82" ]]; then
  NON_ZTS_FILENAME=no-debug-non-zts-20220829
else
  NON_ZTS_FILENAME=no-debug-non-zts-20121212
fi
