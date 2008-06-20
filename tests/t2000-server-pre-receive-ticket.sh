
#!/bin/sh

test_description='server pre-receive ticket enforcer'

. ./test-lib.sh

test_expect_success 'setup' '
	echo This is a test. >a &&
	git add a &&
	git commit -m "a" &&
	git clone ./. server &&
	rm -fr server/.git/hooks &&
	git remote add origin ./server &&
	git config --add branch.master.remote origin &&
	git config --add branch.master.merge refs/heads/master
'

# setup the pre-receive hook
install_server_hook 'pre-receive-ticket' 'pre-receive'

test_expect_success 'reject with bad message' '
	echo $test_name >a &&
	git commit -a -m "foo" &&
	git push >push.out 2>push.err
	head=$(git rev-parse HEAD)
	cat push.err | grep "Commit $head does not reference a ticket"
'

# the last test has a dirty commit message, so ammend it with a good message
test_expect_success 'accept with re' '
	echo $test_name >a &&
	git commit --amend -m "foo re #3222" &&
	git push
'

test_expect_success 'accept with re on second line' '
	echo $test_name >a &&
	echo "first subject line" >msg
	echo "second line re #322" >>msg
	git commit -a -F msg &&
	git push
'

test_done

