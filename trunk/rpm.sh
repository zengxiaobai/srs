#!/bin/bash
set -x

if [ "$1" == "help" ]; then
	echo "Usage: $0 <name> <dstdir>"
	exit 1
fi

chmod 777 ./configure
cur_path=$(cd "$(dirname "$0")"; pwd)
dist_root=${2:-$cur_path}
if [ "x${dist_root:0:1}" = "x/" ];then
	dist_root=$dist_root
else
	dist_root=$cur_path/$dist_root
fi
rpmdir=$dist_root/build
rm -rf $rpmdir
mkdir -p $rpmdir

name=${1:-srs}
version=`cat VERSION`
release=`cat RELEASE`

spec=$name.spec
spec_in=$spec.in
[ ! -f $spec_in ] && echo "$spec_in doesn't exist." && exit 1
sed -e "s/@@name@@/${name}/g" -e "s/@@version@@/${version}/g" -e "s/@@release@@/${release}/g" $spec_in > $spec

SUBDIR=(src conf 3rdparty scripts research etc srs.spec.in conf man auto contrib configure VERSION RELEASE rpm.sh)
tar czvf ${rpmdir}/$name-${version}.tar.gz ${SUBDIR[@]}

rpmbuild -bb  --define "_topdir ${rpmdir}" \
	--define "_rpmdir ${rpmdir}" \
	--define "_builddir ${rpmdir}" \
	--define "_sourcedir ${rpmdir}" \
	--define "_specdir ${rpmdir}" \
	--define "_srcrpmdir ${rpmdir}" \
	$spec   --clean  --rmsource

if [ $? -eq 0 ]
then
	echo "create rpm success"
else
	echo "create rpm fail"
fi

