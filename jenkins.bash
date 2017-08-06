#!/bin/bash
cloneorpull() {
        if test -d "$1" ; then
                (cd "$1" && git pull)
        else
                git clone "$2"
        fi
}
venv() {
        if ! test -d "$1" ; then
                virtualenv -p python${PYTHON_VERSION} "$1"
        fi
	# shellcheck source=/dev/null
        source "$1"/bin/activate
}
git clean --force -d -x || /bin/true
pip install virtualenv
cloneorpull common-workflow-language https://github.com/common-workflow-language/common-workflow-language.git
venv cwltool-venv
# docker pull node:slim
pip${PYTHON_VERSION} install -U setuptools wheel pip
pip${PYTHON_VERSION} install .
pip${PYTHON_VERSION} install "cwltest>=1.0.20160825151655"
pushd common-workflow-language
git clean --force -d -x || /bin/true
# shellcheck disable=SC2154
if [[ "$version" = *dev* ]]
then
	EXTRA="EXTRA=--enable-dev"
fi
./run_test.sh --junit-xml=result.xml RUNNER=cwltool -j16 DRAFT=${version}
CODE=$?
popd
# if [ "$GIT_BRANCH" = "origin/master" ] && [[ "$version" = "v1.0" ]]
# then
#   ./build-cwl-docker.sh && docker push commonworkflowlanguage/cwltool_module && docker push commonworkflowlanguage/cwltool
# fi
#docker rm -v $(docker ps -a -f status=exited | sed 's/  */ /g' | cut -d' ' -f1)
exit ${CODE}
