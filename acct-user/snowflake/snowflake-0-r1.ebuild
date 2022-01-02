# Copyright 2019-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit acct-user

DESCRIPTION="user for snowflake proxy"
ACCT_USER_ID=-1
ACCT_USER_GROUPS=( snowflake )

acct-user_add_deps
